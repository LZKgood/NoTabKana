#Requires AutoHotkey v2.0
#SingleInstance Force
global isKanaMode := false ; 假名输入标记
global pageMode := false   ; 翻页模式标记：按下=之后激活

GetCurrentLangID() {
    hWnd := WinActive("A")
    ThreadId := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "Ptr", 0)
    Layout := DllCall("GetKeyboardLayout", "UInt", ThreadId, "Ptr")
    return Layout & 0xFFFF
}

#HotIf GetCurrentLangID() = 1041

; ========== 字母a-z：按下开启假名模式，关闭翻页模式 ==========
$a:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "a"
}
$b:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "b"
}
$c:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "c"
}
$d:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "d"
}
$e:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "e"
}
$f:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "f"
}
$g:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "g"
}
$h:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "h"
}
$i:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "i"
}
$j:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "j"
}
$k:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "k"
}
$l:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "l"
}
$m:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "m"
}
$n:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "n"
}
$o:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "o"
}
$p:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "p"
}
$q:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "q"
}
$r:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "r"
}
$s:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "s"
}
$t:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "t"
}
$u:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "u"
}
$v:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "v"
}
$w:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "w"
}
$x:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "x"
}
$y:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "y"
}
$z:: {
    global isKanaMode := true
    global pageMode := false
    SendEvent "z"
}

; ========== 数字键：选词，选词完成后关闭pageMode和isKanaMode ==========
$1:: {
    global isKanaMode
    global pageMode := false ; 按数字选词，翻页模式重置
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "1"
}
$2:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "2"
}
$3:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "3"
}
$4:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "4"
}
$5:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "5"
}
$6:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "6"
}
$7:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "7"
}
$8:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "8"
}
$9:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "9"
}
$0:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "0"
}

; ========== = 等号：只有在假名输入状态才执行翻页，否则输出等号 ==========
$=:: {
    global isKanaMode
    if isKanaMode {
        global pageMode := true ; 按下等号，开启翻页模式
        SendEvent "{Tab}"
        Sleep 1
        SendEvent "{PgDn}"
    } else {
        SendEvent "=" ; 没有打假名，直接输出=号
    }
}

; ========== - 减号：判断翻页模式 ==========
$-:: {
    global pageMode
    if pageMode {
        SendEvent "{Tab}"
        Sleep 1
        SendEvent "{PgUp}"
    } else {
        SendEvent "-" ; 模式关闭 → 输出长音符号
    }
}

; ========== Enter回车：行为等同于数字键，直接保留假名确认 ==========
$Enter:: {
    global isKanaMode
    global pageMode := false
    if isKanaMode {
        SendEvent "{Tab}"
        Sleep 1
        global isKanaMode := false
    }
    SendEvent "{Enter}"
}

#HotIf
