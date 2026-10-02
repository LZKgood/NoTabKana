; KanaTap
; Microsoft Japanese IME enhancement script
; Microsoft日本語IME補助スクリプト
; Windows微软日语输入法增强脚本
; Script License: MIT
; Requires AutoHotkey v2.0 (AutoHotkey is under GPLv2)
#Requires AutoHotkey v2.0
#SingleInstance Force
InstallMouseHook false ; 完全禁用鼠标钩子

KEY_DELAY := 1 ; 全局按键延时，需要调整只改这一处

global isKanaMode := false
global pageMode   := false
global firstPage  := true

GetCurrentLangID() {
    hWnd := WinActive("A")
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "Ptr", 0)
    layout := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    return layout & 0xFFFF
}

#HotIf GetCurrentLangID() = 1041

; ESC 重置所有状态
$Esc:: {
    global isKanaMode, pageMode, firstPage
    isKanaMode := false
    pageMode   := false
    firstPage  := true
    SendEvent "{Esc}"
}

; ====== 静态定义a-z字母热键，#HotIf可以正常生效，切中文输入法自动失效 ======
$a::LetterHotkey("a")
$b::LetterHotkey("b")
$c::LetterHotkey("c")
$d::LetterHotkey("d")
$e::LetterHotkey("e")
$f::LetterHotkey("f")
$g::LetterHotkey("g")
$h::LetterHotkey("h")
$i::LetterHotkey("i")
$j::LetterHotkey("j")
$k::LetterHotkey("k")
$l::LetterHotkey("l")
$m::LetterHotkey("m")
$n::LetterHotkey("n")
$o::LetterHotkey("o")
$p::LetterHotkey("p")
$q::LetterHotkey("q")
$r::LetterHotkey("r")
$s::LetterHotkey("s")
$t::LetterHotkey("t")
$u::LetterHotkey("u")
$v::LetterHotkey("v")
$w::LetterHotkey("w")
$x::LetterHotkey("x")
$y::LetterHotkey("y")
$z::LetterHotkey("z")

LetterHotkey(char) {
    global isKanaMode, pageMode, firstPage
    ; 如果按下 Ctrl / Alt / Shift，不进入假名模式
    if (GetKeyState("Ctrl") || GetKeyState("Alt") || GetKeyState("Shift")) {
        SendEvent char
        return
    }
    isKanaMode := true
    pageMode   := false
    firstPage  := true
    SendEvent char
}

; 数字 0~9 共用函数
$0::ResetStateAndSend("0")
$1::ResetStateAndSend("1")
$2::ResetStateAndSend("2")
$3::ResetStateAndSend("3")
$4::ResetStateAndSend("4")
$5::ResetStateAndSend("5")
$6::ResetStateAndSend("6")
$7::ResetStateAndSend("7")
$8::ResetStateAndSend("8")
$9::ResetStateAndSend("9")

ResetStateAndSend(key) {
    global isKanaMode, pageMode, firstPage
    pageMode  := false
    firstPage := true
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep KEY_DELAY
        isKanaMode := false
    }
    SendEvent key
}

; Enter 回车，行为等同于数字确认
$Enter:: {
    global isKanaMode, pageMode, firstPage
    pageMode  := false
    firstPage := true
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep KEY_DELAY
        isKanaMode := false
    }
    SendEvent "{Enter}"
}

; = 等号：假名模式下翻页，首次附带Tab
$=:: {
    global isKanaMode, pageMode, firstPage
    if isKanaMode {
        pageMode := true
        if firstPage {
            SendEvent "{Tab}"
            Sleep KEY_DELAY
            firstPage := false
        }
        SendEvent "{PgDn}"
    } else {
        SendEvent "="
    }
}

; - 减号：翻页模式开启则上翻，否则输出长音符号
$-:: {
    global pageMode
    if pageMode {
        SendEvent "{Tab}"
        Sleep KEY_DELAY
        SendEvent "{PgUp}"
    } else {
        SendEvent "-"
    }
}

#HotIf
