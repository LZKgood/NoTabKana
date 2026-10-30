#Requires AutoHotkey v2.0
#SingleInstance Off
#InputLevel 1
; =====================================================================
; NoTabKana v1.4.0 —— 微软日语 IME 数字直选候选（罗马音输入辅助）
;   自检：AutoHotkey.exe NoTabKana.ahk test   → 跑完自动退出，退出码 = 失败数
;   常驻：双击运行，托盘图标；暂停/恢复 = Ctrl+Alt+K 或托盘菜单
; 同步策略：罗马音组合跟踪 + 退格防抖 + 看门狗（失焦/切输入法/空闲/翻页超时）
; 输入模式：v1.4.0 起只读 IME 转换模式位（ImmGetConversionStatus / WM_IME_CONTROL），
;           英数 / 直接入力状态下所有键原样放行；不读、也不改 IME 组合缓冲
; 托盘界面：中 / 日 / 英 可切换（菜单“界面语言”，选择记在 NoTabKana.ini）
; v1.4.0 改动：
;   ① 数字/等号/减号先过 IME かな 判定：英数模式下不再发 {Down}（不再移动光标）
;   ② 没有真实假名组合时 = 原样输出，不再发 {Down}{PgDn}
;   ③ 罗马音解析支持 tch（matcha / kotchi → 3 个假名）
;   ④ 小键盘 Numpad0-9 也能选候选（NumLock 开启时）
;   ⑤ 暂停/恢复热键 + 托盘菜单；“状态显示”会弹出右下角实时悬浮窗
;   ⑥ 热键门控只读缓存（看门狗刷新），按键时不再重复 DllCall 查窗口/输入法
;   ⑦ 自检 Chk 改为类型严格比较（"1" 与 1 不再等价）
; =====================================================================
; ---- 可调参数 ----
global PAGE_MS  := 1800   ; 翻页状态存活(ms)
global IDLE_MS  := 15000  ; 组合空闲失效(ms)
global BS_WAIT  := 45     ; 退格防抖合并窗口(ms)
global WD_MS    := 200    ; 看门狗周期(ms)
global PROBE_MS := 500    ; IME 模式探测最小间隔(ms)，看门狗用
global PROBE_TO := 150    ; WM_IME_CONTROL 查询超时(ms)，防止被挂起的 IME 拖住
; ---- 状态 ----
global SCRIPT_VERSION := "1.4.0"
global isKanaMode := false, pageMode := false, kanaCount := 0, pageArmedAt := 0
global lastActAt := 0, bsPending := 0
global RM_BUF := "", RM_T := 0, LIT := Chr(1), gMutex := 0
global gDry := false, gKeys := ""        ; 自检用：干跑开关 + 发键记录
; ---- 环境缓存（供热键门控零成本读取；看门狗与处理器负责刷新）----
global gHwnd := 0, gLang := 0, gImeKana := -1, gProbeAt := 0, gProbeSrc := ""
; ---- 开关与 UI ----
global gPaused := false, gDebug := false, gTrayReady := false, gTipAt := 0
global INI_PATH := A_ScriptDir "\NoTabKana.ini"
global UI_LANG := "zh"                   ; zh / ja / en，启动时由 DetectUiLang() 决定
; ---- 自检注入 ----
global gFrozen := false                  ; true = 冻结环境查询，用注入的 gLang/gImeKana

LangIdOf(hwnd) {
    if !hwnd
        return 0
    tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0)
    return DllCall("GetKeyboardLayout", "UInt", tid, "Ptr") & 0xFFFF
}
GetCurrentLangID() {
    return LangIdOf(WinActive("A"))
}

; ==================== IME 输入模式（只读）====================
; 纯函数：转换模式位 + IME 打开状态 → 1=かな系 0=非かな
;   实测（本机 MS IME）：かな = (0x9, open=1)；直接入力/英数 = (0x9, open=0)；
;   模式位在 IME 关闭时会被保留，所以必须同时看 open，只看模式位会误判。
ImeModeVerdict(conv, open) {
    static IME_CMODE_NATIVE := 0x0001
    return (open && (conv & IME_CMODE_NATIVE)) ? 1 : 0
}
ImeQuery(hIme, code) {                                   ; 返回数值；超时/拒绝返回 ""
    static WM_IME_CONTROL := 0x0283, SMTO_ABORTIFHUNG := 0x0002, SMTO_BLOCK := 0x0001
    global PROBE_TO
    v := 0
    ok := DllCall("SendMessageTimeout", "Ptr", hIme, "UInt", WM_IME_CONTROL, "Ptr", code, "Ptr", 0
        , "UInt", SMTO_ABORTIFHUNG | SMTO_BLOCK, "UInt", PROBE_TO, "Ptr*", &v, "Ptr")
    return ok ? v : ""
}
; 1=かな系 0=英数/直接入力 -1=探测不到
;   1) IMM32 上下文：原生应用基本都有；Chromium/Electron 拿不到（实测 hIMC=0）
;   2) 默认 IME 窗口 + WM_IME_CONTROL：TSF 应用（Chromium）走这条，实测可用
; 两条路径都只读转换模式/打开状态，不碰组合缓冲
ProbeImeKana(hwnd) {
    global gProbeSrc
    if !hwnd {
        gProbeSrc := "none"
        return -1
    }
    hIMC := DllCall("imm32\ImmGetContext", "Ptr", hwnd, "Ptr")
    if (hIMC) {
        conv := 0, sentence := 0
        ok := DllCall("imm32\ImmGetConversionStatus", "Ptr", hIMC, "Int*", &conv, "Int*", &sentence, "Int")
        open := DllCall("imm32\ImmGetOpenStatus", "Ptr", hIMC, "Int")
        DllCall("imm32\ImmReleaseContext", "Ptr", hwnd, "Ptr", hIMC)
        if (ok) {
            gProbeSrc := "ctx"
            return ImeModeVerdict(conv, open)
        }
    }
    hIme := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    if (hIme) {
        conv := ImeQuery(hIme, 0x0001)                   ; IMC_GETCONVERSIONMODE
        open := ImeQuery(hIme, 0x0005)                   ; IMC_GETOPENSTATUS
        if (conv != "" && open != "") {
            gProbeSrc := "ime"
            return ImeModeVerdict(conv, open)
        }
    }
    gProbeSrc := "none"
    return -1
}
; 纯函数：这一刻是否应按假名组合语义处理按键
;   imeKana = -1（探测不到）时退回 v1.3 的启发式：最近打过字母就当作在组词
KanaKeyAllowed(lang, imeKana, kanaSeen) {
    if (lang != 1041)
        return false
    if (imeKana = 0)
        return false
    return kanaSeen
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
        if (c = "t" && SubStr(s, i + 1, 2) = "ch") {         ; tch：t + cha/chi/chu/cho → っ
            kana.Push("っ"), lens.Push(1), i += 1            ; （唯一的双字母促音例外）
            continue
        }
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

; ==================== 环境刷新 ====================
; 刷新窗口/语言/IME 模式缓存；返回 true 表示窗口或输入法变了（已重置组合状态）
RefreshEnv(forceProbe := false) {
    global gHwnd, gLang, gImeKana, gProbeAt, gProbeSrc, gFrozen, PROBE_MS
    if (gFrozen)                                         ; 自检：环境由用例注入
        return false
    hwnd := WinActive("A")
    lang := hwnd ? LangIdOf(hwnd) : 0
    now := A_TickCount
    changed := (hwnd != gHwnd || lang != gLang)
    gHwnd := hwnd, gLang := lang
    if (changed || forceProbe || !gProbeAt || now - gProbeAt >= PROBE_MS) {
        if (lang = 1041)
            gImeKana := ProbeImeKana(hwnd)
        else
            gImeKana := -1, gProbeSrc := "n/a"
        gProbeAt := now
    }
    if (changed)
        ResetMode()
    return changed
}
; 拦截类按键的统一前置判定：按“此刻”的真实环境决定
AllowKanaKey() {
    global gLang, gImeKana, isKanaMode
    RefreshEnv(true)
    return KanaKeyAllowed(gLang, gImeKana, isKanaMode)
}
; 看门狗：窗口/输入法切换、翻页超时、空闲过期、调试状态
Watchdog() {
    global gDebug, gPaused, pageMode, pageArmedAt, isKanaMode, kanaCount, lastActAt
    if (gPaused)
        return
    if (RefreshEnv())
        return
    now := A_TickCount
    if (pageMode && PageExpiredAt(pageArmedAt, now))
        pageMode := false
    if ((isKanaMode || kanaCount > 0 || BufPending() != "") && IdleExpiredAt(lastActAt, now))
        ResetMode()
    if (gDebug)
        UpdateOverlay()
}
AcquireMutex() {                                         ; 手动单实例：自检不干扰常驻实例
    global gMutex
    gMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", "NoTabKana_SingleInstance", "Ptr")
    return (A_LastError != 183)
}
OldInstanceRunning() {                                   ; v1.3.x 的互斥体名不同，单独探测
    h := DllCall("OpenMutex", "UInt", 0x00100000, "Ptr", 0, "Str", "notabkana_v136", "Ptr")
    if (h) {
        DllCall("CloseHandle", "Ptr", h)
        return true
    }
    return false
}
SendKey(k) {                                             ; 统一出口：自检只记录不发键
    global gDry, gKeys
    gKeys .= k "|"
    if (!gDry)
        SendEvent k
}

; ==================== 界面文案（中 / 日 / 英）====================
; 托盘菜单、气泡提示、悬浮状态窗都走这里；加语言只需再加一列
UiStr(key) {
    static L := Map(
        "pause",   ["暂停 / 恢复`tCtrl+Alt+K", "一時停止 / 再開`tCtrl+Alt+K", "Pause / Resume`tCtrl+Alt+K"],
        "debug",   ["状态显示（调试）", "状態表示（デバッグ）", "Status display (debug)"],
        "lang",    ["界面语言", "表示言語", "Language"],
        "reload",  ["重新加载", "再読み込み", "Reload"],
        "exit",    ["退出", "終了", "Exit"],
        "paused",  ["已暂停：所有热键放行", "一時停止：全ホットキーを素通し", "Paused: all hotkeys pass through"],
        "resumed", ["已恢复", "再開しました", "Resumed"],
        "dbgon",   ["状态显示已开启：右下角显示实时状态", "状態表示オン：右下にリアルタイム表示", "Status display on: live state at bottom-right"],
        "dbgoff",  ["状态显示已关闭", "状態表示オフ", "Status display off"],
        "langset", ["界面语言已切换", "表示言語を変更しました", "UI language changed"],
        "running", ["已有实例在运行，请先右键托盘退出它", "既に実行中です。トレイから終了してください", "Already running; quit it from the tray first"],
        "old",     ["检测到旧版 v1.3.x 正在运行，请先右键托盘退出旧版", "旧バージョン v1.3.x が動作中です。トレイから終了してください", "An older v1.3.x instance is running; quit it from its tray first"],
        "tip",     ["NoTabKana 实时状态", "NoTabKana ライブ状態", "NoTabKana live state"],
        "pausetip", ["已暂停 · Ctrl+Alt+K 恢复", "一時停止中 · Ctrl+Alt+K で再開", "Paused · Ctrl+Alt+K to resume"],
        "r_kana",  ["かな组合中：按数字 = 选候选", "かな変換中：数字キー = 候補選択", "Kana composing: digits select candidates"],
        "r_alpha", ["英数 / 直接入力：数字不接管", "英数・直接入力：数字は素通し", "英数 / direct input: digits pass through"],
        "r_nolang",["非日语输入法：全部放行", "日本語 IME 以外：すべて素通し", "Not a Japanese IME: everything passes through"],
        "r_noinput",["かな输入，但还没打字母：数字放行", "かな入力だが未入力：数字は素通し", "Kana mode but no romaji yet: digits pass through"],
        "r_pending",["只有未完成罗马音：数字放行", "未確定ローマ字のみ：数字は素通し", "Only a pending romaji tail: digits pass through"]
    )
    if !L.Has(key)
        return "«" key "»"                                ; 缺文案时显眼，自检会抓
    return L[key][(UI_LANG = "ja") ? 2 : (UI_LANG = "en") ? 3 : 1]
}
DetectUiLang() {                                         ; ini 记忆优先，否则跟随系统 UI 语言
    global INI_PATH
    v := ""
    try v := IniRead(INI_PATH, "ui", "Lang", "")
    if (v = "zh" || v = "ja" || v = "en")
        return v
    lid := DllCall("GetUserDefaultUILanguage", "UInt") & 0x3FF
    if (lid = 0x11)
        return "ja"
    if (lid = 0x04)
        return "zh"
    return "en"
}
; 写语言记忆；首次创建时给 ini 打上隐藏属性，免得在脚本目录里多出一个文件
; 返回 true = 这次是新建（自检用）
WriteUiLang(path, lang) {
    fresh := !FileExist(path)
    IniWrite(lang, path, "ui", "Lang")
    if (fresh)
        FileSetAttrib("+H", path)              ; 隐藏不影响 IniRead；想手改就先取消隐藏
    return fresh
}
SaveUiLang() {
    global INI_PATH, UI_LANG
    try WriteUiLang(INI_PATH, UI_LANG)
}

; ==================== 托盘 / 暂停 / 调试 ====================
; 每次状态或语言变化都整菜单重建：勾选状态与文案一起刷新，不用记菜单项名字
BuildTrayMenu() {
    global gPaused, gDebug, UI_LANG
    m := A_TrayMenu
    try m.Delete()                                       ; 清掉默认项，换成自己的菜单
    m.Add(UiStr("pause"), (*) => TogglePause())
    if (gPaused)
        m.Check(UiStr("pause"))
    m.Add(UiStr("debug"), ToggleDebug)
    if (gDebug)
        m.Check(UiStr("debug"))
    m.Add()
    sub := Menu()
    sub.Add("简体中文", SetLangZh, "Radio")
    sub.Add("日本語", SetLangJa, "Radio")
    sub.Add("English", SetLangEn, "Radio")
    sub.Check(UI_LANG = "ja" ? "日本語" : (UI_LANG = "en" ? "English" : "简体中文"))
    m.Add(UiStr("lang"), sub)
    m.Add()
    m.Add(UiStr("reload"), (*) => Reload())
    m.Add(UiStr("exit"), (*) => ExitApp())
    m.Default := UiStr("pause")
}
SetLangZh(*) {
    SwitchLang("zh")
}
SetLangJa(*) {
    SwitchLang("ja")
}
SetLangEn(*) {
    SwitchLang("en")
}
SwitchLang(l) {
    global UI_LANG, gDebug, gTrayReady
    if (l = UI_LANG)
        return false
    UI_LANG := l
    if (gTrayReady) {                                    ; 自检时不碰菜单、不写 ini
        SaveUiLang()
        BuildTrayMenu()
        UpdateTrayTip()
        try TrayTip(UiStr("langset"), "NoTabKana")
        UpdateOverlay(true)
    }
    return true
}
SetupTray() {
    global gTrayReady
    BuildTrayMenu()
    gTrayReady := true
    UpdateTrayTip()
}
TogglePause(*) {
    global gPaused, gTrayReady, gDebug
    gPaused := !gPaused
    if (gPaused)
        ResetMode()
    Suspend(gPaused)                                     ; 暂停时热键全部放行，键盘钩子不拦截
    if (gTrayReady) {
        BuildTrayMenu()                                  ; 勾选状态跟着变
        try TrayTip(gPaused ? UiStr("paused") : UiStr("resumed"), "NoTabKana")
        UpdateTrayTip()
        UpdateOverlay(true)                              ; 暂停时右下角常驻提示，避免“怎么没反应”
    }
}
ToggleDebug(*) {
    global gDebug, gTrayReady
    gDebug := !gDebug
    if (gTrayReady) {
        BuildTrayMenu()
        try TrayTip(gDebug ? UiStr("dbgon") : UiStr("dbgoff"), "NoTabKana")
        UpdateOverlay(true)                              ; 点了立刻能看到，关掉立刻收起
    }
    UpdateTrayTip()
}
; 诊断用纯函数：解释“现在按数字会发生什么”，返回文案 key
;   （探测不到 IME 模式时按本地罗马音推断，所以 -1 与 1 走同一套分支）
KeyReasonKey(lang, imeKana, kanaSeen, count, pending, paused) {
    if (paused)
        return "pausetip"
    if (lang != 1041)
        return "r_nolang"
    if (imeKana = 0)
        return "r_alpha"
    if (!kanaSeen)
        return "r_noinput"
    if (count = 0)
        return "r_pending"
    return "r_kana"
}
; 右下角悬浮窗：调试打开或暂停时显示；看门狗每 200ms 刷新
UpdateOverlay(force := false) {
    global gDebug, gPaused, gTrayReady, gLang, gImeKana, gProbeSrc, isKanaMode, kanaCount, pageMode, RM_BUF, LIT, gTipAt
    if (!gTrayReady)
        return
    if (!gDebug && !gPaused) {
        ToolTip()
        return
    }
    now := A_TickCount
    if (!force && now - gTipAt < 200)
        return
    gTipAt := now
    t := "NoTabKana v" SCRIPT_VERSION
    if (gPaused)
        t .= "  [pause]"
    t .= "`n" UiStr(KeyReasonKey(gLang, gImeKana, isKanaMode, kanaCount, BufPending(), gPaused))
    t .= "`nlang=" gLang "  ime=" gImeKana " (" gProbeSrc ")  kana=" (isKanaMode ? 1 : 0)
    t .= "  n=" kanaCount "  pg=" (pageMode ? 1 : 0)
    t .= "`nbuf=" (RM_BUF = "" ? "-" : StrReplace(RM_BUF, LIT, "-"))
    ToolTip(t, A_ScreenWidth - 360, A_ScreenHeight - 190)
}
UpdateTrayTip() {                                        ; 悬停提示：只放简称，细节在悬浮窗
    global gPaused
    t := "NoTabKana v" SCRIPT_VERSION
    if (gPaused)
        t .= " [pause]"
    try A_IconTip := t
}

; =====================================================================
; ==================== 内置自检（test 分支）====================
; =====================================================================
Say(t) {
    try FileAppend(t "`n", "*")
    try FileAppend(t "`n", A_ScriptDir "\selftest.log", "UTF-8")
}
; 严格比较：类型也必须一致，"1" 与 1 视为不同（v1.3 的 = 会放过类型错误）
SameVal(a, b) {
    return (Type(a) = Type(b) && a = b)
}
Chk(name, got, want) {
    global T_OK, T_BAD, T_FAILS
    if SameVal(got, want)
        T_OK += 1, Say("PASS " name)
    else
        T_BAD += 1, T_FAILS .= name " ", Say("FAIL " name " got=" got " (" Type(got) ") want=" want " (" Type(want) ")")
}
ResetKeys() {
    global gKeys
    gKeys := ""
}
; 自检里的环境注入：冻结真实查询，模拟“日语键盘 + 指定 IME 模式”
TestEnv(lang, imeKana) {
    global gFrozen, gLang, gImeKana, gProbeSrc
    gFrozen := true, gLang := lang, gImeKana := imeKana, gProbeSrc := "test"
}
RunTests() {
    global T_OK := 0, T_BAD := 0, T_FAILS := ""
    global isKanaMode, pageMode, kanaCount, pageArmedAt, lastActAt, bsPending
    global PAGE_MS, IDLE_MS, RM_BUF, LIT, gDry, gKeys, gFrozen, gLang, gImeKana
    global gHwnd, gProbeAt, gProbeSrc, gPaused, UI_LANG
    try FileDelete(A_ScriptDir "\selftest.log")
    Say("[selftest] NoTabKana v" SCRIPT_VERSION)

    ; ---- 1. 罗马音切分：组合音/促音按 1 个假名计（问题 1、2、③）----
    for t in ["a=1","ka=1","chi=1","shita=2","kya=1","tsu=1","ja=1","konnichiwa=5","sumimasen=4"
            , "sumimasenn=5","tta=2","kko=2","gakkou=4","xtu=1","ltsu=1","tt=1","nn=1","nka=2","nya=1","kan=1"
            , "matcha=3","kotchi=3","niccha=3","tcha=2","tch=1"] {
        p := StrSplit(t, "=")
        Chk("parse_" p[1], ParseRomaji(p[1]).kana.Length, p[2] + 0)
    }
    Chk("parse_chik_tail", ParseRomaji("chik").tail, "k")
    Chk("parse_lit_2",     ParseRomaji("a" LIT).kana.Length, 2)
    Chk("parse_matcha_tail", ParseRomaji("matcha").tail, "")
    Chk("parse_tch_tail",  ParseRomaji("kotch").tail, "ch")
    Chk("parse_tch_kana",  ParseRomaji("kotch").kana.Length, 2)

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

    ; ---- 4. 依赖的字符串语义、字母判定与 Chk 严格性（问题 ⑦）----
    Chk("substr_neg",      SubStr("abc", 1, -1), "ab")
    for t in ["a=1","z=1","~=0","=0"] {
        p := StrSplit(t, "=")
        Chk("lower_" (p[1] = "" ? "empty" : p[1]), IsLowerLetter(p[1]), p[2] + 0)
    }
    Chk("same_num",        SameVal(4, 4), true)
    Chk("same_type",       SameVal("4", 4), false)       ; 类型不同必须判失败
    Chk("same_str",        SameVal("か", "か"), true)
    Chk("same_empty",      SameVal("", ""), true)
    Chk("same_bool",       SameVal(true, 1), true)       ; v2 的布尔就是 1/0

    ; ---- 5. 翻页状态超时自动复原（问题 5）----
    now := A_TickCount
    Chk("page_never",      PageExpiredAt(0, now), true)
    Chk("page_alive",      PageExpiredAt(now, now + PAGE_MS - 1), false)
    Chk("page_expired",    PageExpiredAt(now, now + PAGE_MS + 1), true)
    Chk("idle_alive",      IdleExpiredAt(now, now + IDLE_MS - 1), false)
    Chk("idle_expired",    IdleExpiredAt(now, now + IDLE_MS + 1), true)
    gFrozen := false, gHwnd := WinActive("A"), gLang := GetCurrentLangID(), gProbeAt := A_TickCount
    pageMode := true, pageArmedAt := now - PAGE_MS - 1, kanaCount := 2, lastActAt := now
    Watchdog()
    Chk("wd_page_timeout", pageMode, false)

    ; ---- 6. 窗口/输入法切换重置三个全局（问题 4）----
    ResetMode()
    isKanaMode := true, pageMode := true, kanaCount := 3, gHwnd := 999999
    Watchdog()
    Chk("wd_win_reset_kana", kanaCount, 0)
    Chk("wd_win_reset_mode", isKanaMode, false)
    Chk("wd_win_reset_page", pageMode, false)
    ResetMode()
    isKanaMode := true, kanaCount := 3
    gHwnd := WinActive("A"), gLang := GetCurrentLangID(), gProbeAt := A_TickCount
    lastActAt := A_TickCount
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

    ; ---- 8. 处理器级联调（干跑，日语假名模式）----
    gDry := true, TestEnv(1041, 1), ResetMode()
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

    ; ---- 10. 问题 ②：没有真实组合时 = 与 - 原样输出，绝不发 {Down}{PgDn} ----
    ResetMode(), LetterHandler("~$k")               ; 只有未完成罗马音 k：kanaCount=0
    Chk("eq2_pend_count",  kanaCount, 0)
    ResetKeys(), Equal_Block("$=")
    Chk("eq2_pend_passthru", gKeys, "=|")
    Chk("eq2_no_page",     pageMode, false)
    ResetKeys(), Num_Block("$7")
    Chk("eq2_pend_digit",  gKeys, "7|")
    ResetMode()                                     ; 完全没有组合
    ResetKeys(), Equal_Block("$=")
    Chk("eq2_empty_passthru", gKeys, "=|")

    ; ---- 11. 问题 ①：英数 / 直接入力模式下所有拦截键原样放行 ----
    TestEnv(1041, 0), ResetMode()
    LetterHandler("~$k"), LetterHandler("~$a")
    Chk("e_kana_count",    kanaCount, 1)            ; 字母仍被记录
    ResetKeys(), Num_Block("$1")
    Chk("e_num_passthru",  gKeys, "1|")             ; 但绝不发 {Down}
    ResetMode(), LetterHandler("~$a")
    ResetKeys(), Equal_Block("$=")
    Chk("e_eq_passthru",   gKeys, "=|")
    Chk("e_no_page",       pageMode, false)
    ResetKeys(), Minus_Block("$-")
    Chk("e_minus_passthru", gKeys, "-|")
    ResetKeys(), Num_Block("$Numpad2")
    Chk("e_numpad_passthru", gKeys, "{Numpad2}|")
    ; 非日语键盘同样放行
    TestEnv(1033, 1), ResetMode(), LetterHandler("~$a")
    ResetKeys(), Num_Block("$3")
    Chk("e_lang_passthru", gKeys, "3|")

    ; ---- 12. 探测不到 IME 模式（-1）时退回旧启发式 ----
    TestEnv(1041, -1), ResetMode(), LetterHandler("~$a")
    ResetKeys(), Num_Block("$4")
    Chk("u_fallback_down", gKeys, "{Down}|4|")
    ResetMode()
    ResetKeys(), Num_Block("$4")
    Chk("u_fallback_none", gKeys, "4|")             ; 没有字母 → 仍然穿透

    ; ---- 13. 问题 ④：小键盘选候选 & 原样放行 ----
    TestEnv(1041, 1), ResetMode(), LetterHandler("~$a")
    ResetKeys(), Num_Block("$Numpad3")
    Chk("np_select",       gKeys, "{Down}|3|")
    ResetMode(), LetterHandler("~$k")
    ResetKeys(), Num_Block("$Numpad0")
    Chk("np_pend_passthru", gKeys, "{Numpad0}|")

    ; ---- 14. 问题 ⑤：暂停开关清空状态 ----
    TestEnv(1041, 1), ResetMode(), LetterHandler("~$a")
    gPaused := false
    TogglePause()
    Chk("pause_on",        gPaused, true)
    Chk("pause_clear",     kanaCount, 0)
    TogglePause()
    Chk("pause_off",       gPaused, false)

    ; ---- 15. IME 模式判定矩阵（实测值）----
    Chk("imev_hira_open",  ImeModeVerdict(0x9, 1), 1)     ; かな：0x9 + open
    Chk("imev_hira_roman", ImeModeVerdict(0x19, 1), 1)    ; かな（含 ROMAN 位）
    Chk("imev_direct",     ImeModeVerdict(0x9, 0), 0)     ; 直接入力/英数：模式位保留，open=0
    Chk("imev_zenkaku",    ImeModeVerdict(0x18, 1), 0)    ; 全角英数：open 但无 NATIVE
    Chk("imev_none",       ImeModeVerdict(0x0, 0), 0)
    Chk("allow_kana",      KanaKeyAllowed(1041, 1, true), true)
    Chk("allow_alpha",     KanaKeyAllowed(1041, 0, true), false)
    Chk("allow_unknown",   KanaKeyAllowed(1041, -1, true), true)
    Chk("allow_lang",      KanaKeyAllowed(1033, 1, true), false)
    Chk("allow_noinput",   KanaKeyAllowed(1041, 1, false), false)

    ; ---- 16. 界面语言：三语文案齐全、切换生效（不碰菜单、不写 ini）----
    for l in ["zh", "ja", "en"] {
        UI_LANG := l
        ok := true
        for k in ["pause", "debug", "lang", "reload", "exit", "paused", "resumed"
                , "dbgon", "dbgoff", "langset", "running", "old", "tip"
                , "pausetip", "r_kana", "r_alpha", "r_nolang", "r_noinput", "r_pending"] {
            if (UiStr(k) = "" || InStr(UiStr(k), "«"))
                ok := false
        }
        Chk("i18n_" l, ok, true)
    }
    UI_LANG := "zh"
    Chk("i18n_switch",     SwitchLang("ja"), true)
    Chk("i18n_ja_pause",   UiStr("pause"), "一時停止 / 再開`tCtrl+Alt+K")
    SwitchLang("zh")
    Chk("i18n_back",       UI_LANG, "zh")
    Chk("i18n_same",       SwitchLang("zh"), false)

    ; ---- 17. 悬浮窗“为什么没接管”判定（纯函数）----
    Chk("reason_paused",   KeyReasonKey(1041, 1, true, 2, "", true), "pausetip")
    Chk("reason_nolang",   KeyReasonKey(1033, 1, true, 2, "", false), "r_nolang")
    Chk("reason_alpha",    KeyReasonKey(1041, 0, true, 2, "", false), "r_alpha")
    Chk("reason_noinput",  KeyReasonKey(1041, 1, false, 0, "", false), "r_noinput")
    Chk("reason_pending",  KeyReasonKey(1041, 1, true, 0, "k", false), "r_pending")
    Chk("reason_kana",     KeyReasonKey(1041, 1, true, 2, "", false), "r_kana")
    Chk("reason_unknown",  KeyReasonKey(1041, -1, true, 2, "", false), "r_kana")   ; 探测不到 → 走推断

    ; ---- 18. 语言 ini：首次生成自动隐藏、可读、已存在时不改属性 ----
    tmpIni := A_Temp "\notabkana_selftest.ini"
    try FileDelete(tmpIni)
    Chk("ini_fresh_new",   WriteUiLang(tmpIni, "ja"), true)
    Chk("ini_hidden",      InStr(FileGetAttrib(tmpIni), "H") > 0, true)
    Chk("ini_readback",    IniRead(tmpIni, "ui", "Lang", ""), "ja")
    Chk("ini_not_new",     WriteUiLang(tmpIni, "en"), false)
    Chk("ini_readback2",   IniRead(tmpIni, "ui", "Lang", ""), "en")
    Chk("ini_kept_hidden", InStr(FileGetAttrib(tmpIni), "H") > 0, true)
    try FileDelete(tmpIni)
    Chk("ini_deleted",     FileExist(tmpIni), "")

    gDry := false, gFrozen := false, gPaused := false, UI_LANG := "zh", ResetMode()
    Say("RESULT " T_OK "/" (T_OK + T_BAD) (T_BAD ? " FAIL: " T_FAILS : " ALL PASS"))
    return T_BAD
}

; ==================== 命令行分支 ====================
if (A_Args.Length && A_Args[1] = "test") {
    OnExit((*) => Say("EXIT"))       ; 结束标记：证明自检跑完会自动退出
    ExitApp(RunTests() ? 1 : 0)
}
UI_LANG := DetectUiLang()            ; 界面语言：ini 记忆 > 系统 UI 语言
if (OldInstanceRunning()) {
    try TrayTip(UiStr("old"), "NoTabKana")
    Sleep 2500
    ExitApp()
}
if (!AcquireMutex()) {
    try TrayTip(UiStr("running"), "NoTabKana")
    Sleep 2500
    ExitApp()
}

; ==================== 只在日语输入法下生效 ====================
; 门控只读缓存（看门狗每 200ms 刷新）；真正的模式判定在处理器内部再做一次
#HotIf gLang = 1041

; ---------- 数字：无假名组合一律穿透，有组合则调候选并选择
Num_Block(ThisHotkey) {
    global kanaCount
    name := SubStr(ThisHotkey, 2)          ; 去掉 $ → "1" / "Numpad1"
    num := SubStr(name, -1)
    FlushBackspace()
    if (!AllowKanaKey() || kanaCount = 0) {
        pass := (SubStr(name, 1, 6) = "Numpad") ? "{" name "}" : name
        SendKey pass                            ; 原样重放：小键盘仍按小键盘发
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
    global kanaCount, pageMode, pageArmedAt, lastActAt
    FlushBackspace()
    if (!AllowKanaKey()) {
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

; ---------- 等号：有组合时激活翻页并把候选列表翻到下一页
Equal_Block(ThisHotkey) {
    global kanaCount, pageMode, pageArmedAt, lastActAt
    FlushBackspace()
    if (!AllowKanaKey() || kanaCount = 0) { ; 没有真实组合 → 原样输出，绝不发 {Down}{PgDn}
        SendKey "="
        return
    }
    lastActAt := A_TickCount
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
Hotkey("$-", Minus_Block)
Hotkey("$=", Equal_Block)
#HotIf

; =====================================================================
; 数字键：静态定义 + #HotIf 条件
;   - 静态定义保证 #HotIf 在每次按键时动态求值（而非注册时快照）
;   - 条件不成立 → 热键不激活 → 键盘事件原样透传，零 AHK 介入
;   - gImeKana = 0（英数/直接入力）时同样不激活：绝不发 {Down} 移动光标
; =====================================================================
#HotIf gLang = 1041 && isKanaMode && gImeKana != 0
$0::Num_Block("$0")
$1::Num_Block("$1")
$2::Num_Block("$2")
$3::Num_Block("$3")
$4::Num_Block("$4")
$5::Num_Block("$5")
$6::Num_Block("$6")
$7::Num_Block("$7")
$8::Num_Block("$8")
$9::Num_Block("$9")
#HotIf

; 小键盘：只在 NumLock 开启（真数字）时接管，关闭时保持 End/Home 等导航语义
#HotIf gLang = 1041 && isKanaMode && gImeKana != 0 && GetKeyState("NumLock", "T")
$Numpad0::Num_Block("$Numpad0")
$Numpad1::Num_Block("$Numpad1")
$Numpad2::Num_Block("$Numpad2")
$Numpad3::Num_Block("$Numpad3")
$Numpad4::Num_Block("$Numpad4")
$Numpad5::Num_Block("$Numpad5")
$Numpad6::Num_Block("$Numpad6")
$Numpad7::Num_Block("$Numpad7")
$Numpad8::Num_Block("$Numpad8")
$Numpad9::Num_Block("$Numpad9")
#HotIf

; 暂停热键：即使 Suspend 生效也要能用，故单独豁免
; 想换键就改下面这一行（同时改 UiStr("pause") 里的文案）
#SuspendExempt
^!k::TogglePause()
#SuspendExempt false

; ==================== 常驻启动 ====================
CoordMode("ToolTip", "Screen")       ; 悬浮状态窗用屏幕坐标（右下角）
SetupTray()
RefreshEnv(true)
lastActAt := A_TickCount
SetTimer(Watchdog, WD_MS)
