#Requires AutoHotkey v2.0
#SingleInstance Force
#InputLevel 1
; ==================== 全局变量 ====================
global isKanaMode := false   ; 是否处于假名输入状态
global pageMode   := false   ; 是否处于翻页状态（按下=激活）
global kanaCount  := 0       ; 当前未确定的假名数量（核心）
; ==================== 工具函数 ====================
GetCurrentLangID() {
    hWnd := WinActive("A")
    if !hWnd
        return 0
    ThreadId := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "Ptr", 0)
    Layout := DllCall("GetKeyboardLayout", "UInt", ThreadId, "Ptr")
    return Layout & 0xFFFF
}
; ==================== 只在日语输入法下生效 ====================
#HotIf GetCurrentLangID() = 1041

; ---------- 数字回调，不带~，捕获按键；关闭模式时手动转发
Num_Block(ThisHotkey) {
    global isKanaMode, pageMode, kanaCount
    num := SubStr(ThisHotkey,2)
    if (!isKanaMode) {
        SendEvent num ; 模式关闭，把数字原样发出去，模拟穿透
        return
    }
    if (kanaCount > 0) {
        Sleep 1
        SendEvent "{Down}"
        Sleep 1
        SendEvent num
        ResetMode()
    }
}

; ---------- 减号回调：pageMode=false输出长音；true发送PgUp
Minus_Block(ThisHotkey) {
    global isKanaMode, pageMode
    if (!isKanaMode) {
        SendEvent "-"
        return
    }
    if (!pageMode) {
        SendEvent "-" ; 未开启翻页，输出长音
        return
    }
    SendEvent "{PgUp}" ; PutUp
}

; ---------- 等号回调：按下=激活翻页，先调出候选列表，发送PgDn
Equal_Block(ThisHotkey) {
    global isKanaMode, pageMode
    if (!isKanaMode) {
        SendEvent "="
        return
    }
    pageMode := true
    Sleep 1
    SendEvent "{Down}" ; 弹出候选框
    Sleep 1
    SendEvent "{PgDn}" ; PutDown
}

; ---------- 字母 a‑z：~$ 开启假名模式，按键穿透
Loop 26 {
    key := Chr(96 + A_Index)
    Hotkey("~$" key, LetterHandler)
}
LetterHandler(ThisHotkey) {
    global isKanaMode, pageMode, kanaCount
    if(!isKanaMode){
        isKanaMode := true
    }
    pageMode   := false ; 新输入字母，重置翻页状态，恢复长音
    kanaCount += 1
}

; ---------- 退格：~$Backspace，原生穿透，只扣计数，归零不Reset
~$Backspace:: {
    global isKanaMode, pageMode, kanaCount
    if (kanaCount > 0) {
        kanaCount -= 1
        pageMode := false ; 退格关闭翻页，恢复长音
    }
}

; ---------- 回车：~$Enter，原生穿透，确认后重置全部状态
~$Enter:: {
    global isKanaMode, pageMode, kanaCount
    ResetMode()
}

; ---------- ESC：【穿透】，按下重置，isKanaMode=false
~$Esc:: {
    global isKanaMode
    if(isKanaMode){
        ResetMode()
    }
}

; ---------- ResetMode：仅重置变量
ResetMode() {
    global isKanaMode, pageMode, kanaCount
    isKanaMode := false
    pageMode   := false
    kanaCount  := 0
}

; =========注册热键：不带~，捕获按键=========
Loop 10 {
    n := A_Index -1
    Hotkey("$" n, Num_Block)
}
Hotkey("$-", Minus_Block)
Hotkey("$=", Equal_Block)
#HotIf
