#Requires AutoHotkey v2.0
#SingleInstance Off
#InputLevel 1
; =====================================================================
; NoTabKana v1.3.5 beta.ahk
; 日语罗马音输入辅助，仅在日语输入法 LangID=1041 下生效
;   自检：AutoHotkey.exe "NoTabKana v1.3.5 beta.ahk" test  → 跑完自动退出
;   无参：常驻后台热键服务
; 同步策略：罗马音组合跟踪 + 退格防抖 + 看门狗（失焦/切输入法/空闲/翻页超时）
; 不调用任何 IME 私有缓冲接口
; =====================================================================
; ---- 可调参数 ----
global PAGE_MS := 1800   ; 翻页状态存活(ms)
global IDLE_MS := 15000  ; 组合空闲失效(ms)
global BS_WAIT := 45     ; 退格防抖合并窗口(ms)
global WD_MS   := 200    ; 看门狗周期(ms)
; ---- 状态 ----
global isKanaMode := false, pageMode := false, kanaCount := 0, pageArmedAt := 0
global lastActAt := 0, lastHwnd := 0, lastLang := 0, bsPending := 0
global RM_BUF := "", RM_T := 0, LIT := Chr(1), gMutex := 0
global gDry := false, gKeys := ""        ; 自检用：干跑开关 + 发键记录

GetCurrentLangID() {
    hWnd := WinActive("A")
    if !hWnd
        return 0
    tid := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "Ptr", 0)
    return DllCall("GetKeyboardLayout", "UInt", tid, "Ptr") & 0xFFFF
}

; ==================== 罗马音 → 假名表 ====================
; 只做“罗马音串能切成几个假名”的切分，不依赖 IME 内部缓冲
RMTable() {
    global RM_T
    if (RM_T)
        return RM_T
    static g := ["a:あ i:い u:う e:え o:お ka:か ki:き ku:く ke:け ko:こ ga:が gi:ぎ gu:ぐ ge:げ go:ご"
        , "sa:さ si:し shi:し su:す se:せ so:そ za:ざ zi:じ zu:ず ze:ぜ zo:ぞ ja:じゃ ji:じ ju:じゅ je:じぇ jo:じょ"
        , "ta:た ti:ち chi:ち tu:つ tsu:つ te:て to:と da:だ di:ぢ du:づ de:で do:ど"
        , "na:な ni:に nu:ぬ ne:ね no:の ha:は hi:ひ hu:ふ fu:ふ he:へ ho:ほ"
        , "ba:ば bi:び bu:ぶ be:べ bo:ぼ pa:ぱ pi:ぴ pu:ぷ pe:ぺ po:ぽ ma:ま mi:み mu:む me:め mo:も"
        , "ya:や yu:ゆ yo:よ ra:ら ri:り ru:る re:れ ro:ろ wa:わ wi:うぃ wu:うぅ we:うぇ wo:を"
        , "va:ゔぁ vi:ゔぃ vu:ゔ ve:ゔぇ vo:ゔぉ fa:ふぁ fi:ふぃ fu:ふ fe:ふぇ fo:ふぉ qa:くぁ qi:くぃ qu:く qe:くぇ qo:くぉ"
        , "kya:きゃ kyi:きぃ kyu:きゅ kye:きぇ kyo:きょ gya:ぎゃ gyi:ぎぃ gyu:ぎゅ gye:ぎぇ gyo:ぎょ"
        , "sya:しゃ syi:しぃ syu:しゅ sye:しぇ syo:しょ sha:しゃ shu:しゅ she:しぇ sho:しょ"
        , "zya:じゃ zyi:じぃ zyu:じゅ zye:じぇ zyo:じょ jya:じゃ jyi:じぃ jyu:じゅ jye:じぇ jyo:じょ"
        , "tya:ちゃ tyi:ちぃ tyu:ちゅ tye:ちぇ tyo:ちょ cha:ちゃ chu:ちゅ che:ちぇ cho:ちょ"
        , "cya:ちゃ cyi:ちぃ cyu:ちゅ cye:ちぇ cyo:ちょ dya:ぢゃ dyi:ぢぃ dyu:ぢゅ dye:ぢぇ dyo:ぢょ"
        , "nya:にゃ nyi:にぃ nyu:にゅ nye:にぇ nyo:にょ hya:ひゃ hyi:ひぃ hyu:ひゅ hye:ひぇ hyo:ひょ"
        , "bya:びゃ byi:びぃ byu:びゅ bye:びぇ byo:びょ pya:ぴゃ pyi:ぴぃ pyu:ぴゅ pye:ぴぇ pyo:ぴょ"
        , "mya:みゃ myi:みぃ myu:みゅ mye:みぇ myo:みょ rya:りゃ ryi:りぃ ryu:りゅ rye:りぇ ryo:りょ"
        , "nn:ん n':ん xa:ぁ la:ぁ xi:ぃ li:ぃ xu:ぅ lu:ぅ xe:ぇ le:ぇ xo:ぉ lo:ぉ"
        , "xya:ゃ lya:ゃ xyu:ゅ lyu:ゅ xyo:ょ lyo:ょ xtu:っ ltu:っ xtsu:っ ltsu:っ xwa:ゎ lwa:ゎ xn:ん ln:ん"
        , "wha:うぁ whi:うぃ whu:う whe:うぇ who:うぉ"]
    T := Map()
    Loop g.Length
        Loop Parse, g[A_Index], " " {
            if (A_LoopField = "")
                continue
            p := StrSplit(A_LoopField, ":")
            T[p[1]] := p[2]
        }
    RM_T := T
    return T
}

IsConsonant(c) {
    static CONS := "bcdfghjklmnpqrstvwxyz"
    return (c != "" && InStr(CONS, c) > 0)
}
; 只做数值比较：字符串间的 < > 走区域相关比较路径，不稳定
IsLowerLetter(ch) {
    return (Ord(ch) >= 97 && Ord(ch) <= 122)
}
; 罗马音串 → {kana:[...], lens:[...], used:n, tail:"未完成前缀"}
ParseRomaji(s) {
    T := RMTable(), kana := [], lens := []
    n := StrLen(s), i := 1
    while (i <= n) {
        c := SubStr(s, i, 1)
        if (c = LIT) {                                       ; 字面量单元（ー / Shift+字母）
            kana.Push(LIT), lens.Push(1), i += 1
            continue
        }
        c2 := (i < n) ? SubStr(s, i + 1, 1) : ""
        if (c2 = c && IsConsonant(c) && c != "n") {          ; 促音：kk/tt/pp/ss → っ
            kana.Push("っ"), lens.Push(1), i += 1
            continue
        }
        if (c = "n" && IsConsonant(c2) && c2 != "y" && c2 != "n") { ; n+辅音 → ん
            kana.Push("ん"), lens.Push(1), i += 1
            continue
        }
        maxL := Min(4, n - i + 1), hit := 0
        Loop maxL {
            L := maxL - A_Index + 1
            sub := SubStr(s, i, L)
            if (T.Has(sub)) {
                kana.Push(T[sub]), lens.Push(L), i += L, hit := 1
                break
            }
        }
        if (!hit)
            break                                            ; 余下的是未完成罗马音
    }
    return {kana: kana, lens: lens, used: i - 1, tail: SubStr(s, i)}
}

; ==================== 缓冲操作 ====================
Feed(ch) {                                               ; ch=LIT 表示字面量单元
    global RM_BUF, LIT
    if (ch = LIT) {
        p := ParseRomaji(RM_BUF)
        if (p.tail != "")
            RM_BUF := SubStr(RM_BUF, 1, p.used)          ; 未完成罗马音无法续写，丢弃
    }
    RM_BUF .= ch
}
BufReset() {
    global RM_BUF
    RM_BUF := ""
}
BufCount() {
    global RM_BUF
    return ParseRomaji(RM_BUF).kana.Length
}
BufPending() {
    global RM_BUF
    return ParseRomaji(RM_BUF).tail
}
; 退格一个输入单元：先删未完成罗马音字符，再删整个假名（组合音一次删净）
PopUnit() {
    global RM_BUF
    if (RM_BUF = "")
        return false
    p := ParseRomaji(RM_BUF)
    if (p.tail != "") {
        RM_BUF := SubStr(RM_BUF, 1, -1)
        return true
    }
    if (!p.kana.Length)
        return false
    last := p.lens[p.lens.Length], start := p.used - last + 1, cut := start - 1
    c1 := SubStr(RM_BUF, start, 1)
    if (start > 1 && c1 = SubStr(RM_BUF, start - 1, 1) && IsConsonant(c1) && c1 != "n")
        cut := start                                     ; 促音共享辅音：tta 删 た 后保留 tt
    RM_BUF := SubStr(RM_BUF, 1, cut)
    return true
}

; ==================== 状态判定 ====================
PageExpiredAt(armedAt, now) {
    global PAGE_MS
    return (armedAt = 0 || now - armedAt > PAGE_MS)
}
IdleExpiredAt(lastAct, now) {
    global IDLE_MS
    return (now - lastAct > IDLE_MS)
}
PageActive() {                                           ; 翻页状态是否仍有效
    global pageMode, pageArmedAt
    return (pageMode && !PageExpiredAt(pageArmedAt, A_TickCount))
}
ResetMode() {
    global isKanaMode, pageMode, kanaCount, pageArmedAt, bsPending, lastActAt, RM_BUF
    isKanaMode := false, pageMode := false, kanaCount := 0
    pageArmedAt := 0, bsPending := 0, RM_BUF := "", lastActAt := A_TickCount
}
; 退格防抖：连打先攒着，等 IME 删完再一次性结算，避免读到中间态
FlushBackspace() {
    global bsPending, kanaCount, pageMode, pageArmedAt, isKanaMode
    if (bsPending = 0)
        return
    n := bsPending, bsPending := 0
    Loop n
        PopUnit()
    kanaCount := BufCount(), pageMode := false, pageArmedAt := 0
    if (kanaCount = 0 && BufPending() = "")              ; 组合被删空 → 退出假名模式，数字不再被吞
        isKanaMode := false
}
; 看门狗：窗口/输入法切换、翻页超时、空闲过期
Watchdog() {
    global isKanaMode, pageMode, kanaCount, pageArmedAt, lastActAt, lastHwnd, lastLang
    now := A_TickCount, hwnd := WinActive("A"), lang := GetCurrentLangID()
    if (hwnd != lastHwnd || lang != lastLang) {
        lastHwnd := hwnd, lastLang := lang
        return ResetMode()
    }
    if (pageMode && PageExpiredAt(pageArmedAt, now))
        pageMode := false
    if ((isKanaMode || kanaCount > 0 || BufPending() != "") && IdleExpiredAt(lastActAt, now))
        ResetMode()
}
AcquireMutex() {                                         ; 手动单实例：自检不干扰常驻实例
    global gMutex
    gMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", "notabkana_v131", "Ptr")
    return (A_LastError != 183)
}
SendKey(k) {                                             ; 统一出口：自检只记录不发键
    global gDry, gKeys
    gKeys .= k "|"
    if (!gDry)
        SendEvent k
}

; =====================================================================
; ==================== 内置自检（test 分支）====================
; =====================================================================
Say(t) {
    try FileAppend(t "`n", "*")
    FileAppend(t "`n", A_ScriptDir "\selftest.log", "UTF-8")
}
Chk(name, got, want) {
    global T_OK, T_BAD, T_FAILS
    if (got = want)
        T_OK += 1, Say("PASS " name)
    else
        T_BAD += 1, T_FAILS .= name " ", Say("FAIL " name " got=" got " want=" want)
}
ResetKeys() {
    global gKeys
    gKeys := ""
}
RunTests() {
    global T_OK := 0, T_BAD := 0, T_FAILS := ""
    global isKanaMode, pageMode, kanaCount, pageArmedAt, lastActAt, lastHwnd, lastLang
    global bsPending, PAGE_MS, IDLE_MS, RM_BUF, LIT, gDry, gKeys
    try FileDelete(A_ScriptDir "\selftest.log")
    Say("[selftest] note table kana v1.3.0.ahk")

    ; ---- 1. 罗马音切分：组合音/促音按 1 个假名计（问题 1、2）----
    for t in ["a=1","ka=1","chi=1","shita=2","kya=1","tsu=1","ja=1","konnichiwa=5","sumimasen=4"
            , "sumimasenn=5","tta=2","kko=2","gakkou=4","xtu=1","ltsu=1","tt=1","nn=1","nka=2","nya=1","kan=1"] {
        p := StrSplit(t, "=")
        Chk("parse_" p[1], ParseRomaji(p[1]).kana.Length, p[2] + 0)
    }
    Chk("parse_chik_tail", ParseRomaji("chik").tail, "k")
    Chk("parse_lit_2",     ParseRomaji("a" LIT).kana.Length, 2)

    ; ---- 2. 退格：组合音一次删净、未完成罗马音先删（问题 1、3）----
    for t in ["chi=0","chika=1,0","chik=1,0","tta=1,0","kko=1,0","itta=2,1"] {
        p := StrSplit(t, "="), exp := StrSplit(p[2], ",")
        BufReset(), Feed(p[1])
        Loop exp.Length {
            PopUnit()
            Chk("bs_" p[1] A_Index, BufCount(), exp[A_Index] + 0)
        }
    }
    BufReset(), Feed("chik"), PopUnit()
    Chk("bs_tail_keep1",   BufCount(), 1)
    Chk("bs_tail_now",     BufPending(), "")
    PopUnit()
    Chk("bs_tail_0",       BufCount(), 0)
    BufReset(), Feed("kko"), PopUnit()
    Chk("bs_kko_pend",     BufPending(), "k")
    BufReset()
    Chk("bs_empty_noop",   PopUnit(), false)

    ; ---- 3. 退格防抖批量结算 + 与字母的先后顺序（问题 3）----
    BufReset(), Feed("chika"), bsPending := 3, FlushBackspace()
    Chk("batch_bs3_0",     kanaCount, 0)
    Chk("batch_bs_clr",    bsPending, 0)
    BufReset(), Feed("chi"), bsPending := 1, FlushBackspace(), Feed("k")
    Chk("order_bs_letter", BufCount(), 0)
    Chk("order_tail",      BufPending(), "k")

    ; ---- 4. 依赖的字符串语义与字母判定 ----
    Chk("substr_neg",      SubStr("abc", 1, -1), "ab")
    for t in ["a=1","z=1","~=0","=0"] {
        p := StrSplit(t, "=")
        Chk("lower_" (p[1] = "" ? "empty" : p[1]), IsLowerLetter(p[1]), p[2] + 0)
    }

    ; ---- 5. 翻页状态超时自动复原（问题 5）----
    now := A_TickCount
    Chk("page_never",      PageExpiredAt(0, now), true)
    Chk("page_alive",      PageExpiredAt(now, now + PAGE_MS - 1), false)
    Chk("page_expired",    PageExpiredAt(now, now + PAGE_MS + 1), true)
    Chk("idle_alive",      IdleExpiredAt(now, now + IDLE_MS - 1), false)
    Chk("idle_expired",    IdleExpiredAt(now, now + IDLE_MS + 1), true)
    pageMode := true, pageArmedAt := now - PAGE_MS - 1, kanaCount := 2
    Watchdog()
    Chk("wd_page_timeout", pageMode, false)

    ; ---- 6. 窗口/输入法切换重置三个全局（问题 4）----
    ResetMode()
    isKanaMode := true, pageMode := true, kanaCount := 3, lastHwnd := 999999
    Watchdog()
    Chk("wd_win_reset_kana", kanaCount, 0)
    Chk("wd_win_reset_mode", isKanaMode, false)
    Chk("wd_win_reset_page", pageMode, false)
    ResetMode()
    isKanaMode := true, kanaCount := 3
    lastHwnd := WinActive("A"), lastLang := GetCurrentLangID(), lastActAt := A_TickCount
    Watchdog()
    Chk("wd_keep_count",   kanaCount, 3)
    Chk("wd_keep_mode",    isKanaMode, true)

    ; ---- 7. ResetMode 全清 ----
    BufReset(), Feed("chi")
    isKanaMode := true, pageMode := true, kanaCount := 1, bsPending := 2
    ResetMode()
    Chk("reset_kana",      kanaCount, 0)
    Chk("reset_mode",      isKanaMode, false)
    Chk("reset_page",      pageMode, false)
    Chk("reset_buf",       RM_BUF, "")
    Chk("reset_bs",        bsPending, 0)

    ; ---- 8. 处理器级联调（干跑，不发真按键）----
    gDry := true, ResetMode()
    LetterHandler("~$c"), LetterHandler("~$h"), LetterHandler("~$i")
    Chk("h_chi_count",     kanaCount, 1)
    Chk("h_chi_mode",      isKanaMode, true)
    LetterHandler("~$k")
    Chk("h_chik_count",    kanaCount, 1)
    Chk("h_chik_pend",     BufPending(), "k")
    Equal_Block("$=")
    Chk("h_eq_arm",        pageMode, true)
    Minus_Block("$-")
    Chk("h_pgup_noadd",    kanaCount, 1)
    pageArmedAt := A_TickCount - PAGE_MS - 1        ; 模拟翻页状态超时
    Minus_Block("$-")
    Chk("h_exp_kana",      kanaCount, 2)            ; 退回长音 ー，且 ー 计入假名
    Chk("h_exp_page",      pageMode, false)
    ResetMode(), Equal_Block("$=")
    Chk("h_eq_noarm",      pageMode, false)         ; 无组合不武装翻页
    LetterHandler("~$k"), LetterHandler("~$a")
    Chk("h_ka_count",      kanaCount, 1)
    BackspacePress(), SetTimer(FlushBackspace, 0)
    Chk("h_bs_pend",       bsPending, 1)
    FlushBackspace()
    Chk("h_bs_count",      kanaCount, 0)
    LetterHandler("~$a"), Num_Block("$5")
    Chk("h_num_reset",     isKanaMode, false)       ; 有组合：Down+数字 → 全清
    Chk("h_num_cnt",       kanaCount, 0)
    ResetMode(), Num_Block("$5")
    Chk("h_num_passthru",  isKanaMode, false)

    ; ---- 9. 实测 BUG：chi → 退格删空 → 数字/等号/减号不得被吞 ----
    ResetKeys(), ResetMode()
    LetterHandler("~$c"), LetterHandler("~$h"), LetterHandler("~$i")
    Chk("del_chi_count",   kanaCount, 1)
    BackspacePress(), SetTimer(FlushBackspace, 0), FlushBackspace()
    Chk("del_chi_empty",   kanaCount, 0)
    Chk("del_chi_mode",    isKanaMode, false)       ; 删空即退出假名模式
    ResetKeys(), Num_Block("$1")
    Chk("del_chi_digit",   gKeys, "1|")             ; 数字穿透，不再被吞
    ResetKeys(), Equal_Block("$=")
    Chk("del_chi_equal",   gKeys, "=|")             ; 不再误发 {Down}{PgDn}
    ResetKeys(), Minus_Block("$-")
    Chk("del_chi_minus",   gKeys, "-|")             ; 输出长音，不是 PgUp
    ResetMode(), LetterHandler("~$n")
    Chk("pend_n_count",    kanaCount, 0)
    ResetKeys(), Num_Block("$1")
    Chk("pend_n_digit",    gKeys, "1|")             ; 只有未完成罗马音时也穿透
    ResetMode(), LetterHandler("~$c"), LetterHandler("~$h")
    ResetKeys(), Num_Block("$1")
    Chk("pend_ch_digit",   gKeys, "1|")
    ResetMode(), LetterHandler("~$a")
    ResetKeys(), Num_Block("$5")
    Chk("cand_digit",      gKeys, "{Down}|5|")      ; 有组合仍走候选选择
    ResetMode(), LetterHandler("~$c"), LetterHandler("~$h"), LetterHandler("~$i"), LetterHandler("~$k")
    BackspacePress(), SetTimer(FlushBackspace, 0), FlushBackspace()
    Chk("keep_kana",       kanaCount, 1)            ; 只删一部分：计数与模式保持
    Chk("keep_mode",       isKanaMode, true)
    gDry := false, ResetMode()

    Say("RESULT " T_OK "/" (T_OK + T_BAD) (T_BAD ? " FAIL: " T_FAILS : " ALL PASS"))
    return T_BAD
}

; ==================== 命令行分支 ====================
if (A_Args.Length && A_Args[1] = "test") {
    OnExit((*) => Say("EXIT"))       ; 结束标记：证明自检跑完会自动退出
    ExitApp(RunTests() ? 1 : 0)
}
if (!AcquireMutex())
    ExitApp()

; ==================== 只在日语输入法下生效 ====================
#HotIf GetCurrentLangID() = 1041

; ---------- 数字：无假名组合一律穿透，有组合则调候选并选择
Num_Block(ThisHotkey) {
    global isKanaMode, kanaCount
    FlushBackspace()
    num := SubStr(ThisHotkey, -1)
    if (!isKanaMode || kanaCount = 0) {
        SendKey num
        return
    }
    Sleep 1
    SendKey "{Down}"
    Sleep 1
    SendKey num
    ResetMode()
}

; ---------- 减号：翻页有效时 PgUp，否则输出长音 ー
Minus_Block(ThisHotkey) {
    global isKanaMode, kanaCount, pageMode, pageArmedAt, lastActAt
    FlushBackspace()
    if (!isKanaMode) {
        SendKey "-"
        return
    }
    lastActAt := A_TickCount
    if (PageActive() && kanaCount > 0) {
        SendKey "{PgUp}"
        return
    }
    pageMode := false, pageArmedAt := 0    ; 翻页已失效（超时/无组合）就地复位
    SendKey "-"
    Feed(LIT)                              ; ー 也是一个假名，计入组合
    kanaCount := BufCount()
}

; ---------- 等号：激活翻页并调出候选列表
Equal_Block(ThisHotkey) {
    global isKanaMode, kanaCount, pageMode, pageArmedAt, lastActAt
    FlushBackspace()
    if (!isKanaMode) {
        SendKey "="
        return
    }
    lastActAt := A_TickCount
    if (kanaCount > 0)                     ; 只有真存在组合才武装翻页，避免卡在 true
        pageMode := true, pageArmedAt := A_TickCount
    Sleep 1
    SendKey "{Down}"
    Sleep 1
    SendKey "{PgDn}"
}

; ---------- 字母 a-z：开启假名模式，按键穿透
Loop 26 {
    key := Chr(96 + A_Index)
    Hotkey("~$" key, LetterHandler)
}
LetterHandler(ThisHotkey) {
    global isKanaMode, pageMode, pageArmedAt, kanaCount, lastActAt
    FlushBackspace()                       ; 先结算挂起的退格，保证先后顺序
    ch := SubStr(ThisHotkey, -1)
    if (!IsLowerLetter(ch))
        return
    lastActAt := A_TickCount
    if GetKeyState("Shift", "P")
        Feed(LIT)                          ; Shift+字母：非罗马音，占 1 个字符位
    else
        Feed(ch)
    isKanaMode := true
    pageMode := false, pageArmedAt := 0    ; 新输入字母，重置翻页状态
    kanaCount := BufCount()
}

; ---------- 退格：穿透，防抖后按“输入单元”结算
BackspacePress() {
    global bsPending, lastActAt
    lastActAt := A_TickCount
    bsPending += 1
    SetTimer(FlushBackspace, -BS_WAIT)     ; 连打合并，等 IME 删完再结算
}
~$Backspace::BackspacePress()
~$Enter::ResetMode()                       ; 回车确认后重置全部状态
~$Esc::ResetMode()                         ; ESC 取消后重置
~*LButton::ResetMode()                     ; 鼠标点击可能改插入点/提交组合 → 作废
~*RButton::ResetMode()

; =========注册热键：不带~，捕获按键=========
Loop 10 {
    n := A_Index - 1
    Hotkey("$" n, Num_Block)
}
Hotkey("$-", Minus_Block)
Hotkey("$=", Equal_Block)
#HotIf

; ==================== 常驻启动 ====================
lastHwnd := WinActive("A"), lastLang := GetCurrentLangID(), lastActAt := A_TickCount
SetTimer(Watchdog, WD_MS)
