#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
;  STATE
; ============================================================
global cycleRunning := false
global paused       := false
global holdSec      := 1
global Mode         := "Wheat / Potatoes"
global statusText   := ""
global pestRepellentEnabled := false
global pestRepellentChar := ""

; ============================================================
;  PER-MODE HOLD TIMES (in seconds) — edit these to change timing
; ============================================================
global HOLD := Map(
    "Wheat / Potatoes",    126,
    "Carrot / Nether Wart", 127,
    "Sugar Cane",           51,
    "Cocoa Beans",          76,
    "Melon / Pumpkin",      76,
    "Mushroom",             116,
    "Eclipse / Wild Rose",  21
)

; ============================================================
;  COLOURS  (Apple dark palette)
; ============================================================
BG      := "161618"   ; near-black, slightly warm
SURFACE := "1E1E20"   ; card surface
STROKE  := "2C2C2E"   ; divider / border
TEXT    := "F2F2F7"   ; primary text
SUB     := "8E8E93"   ; secondary / labels
ACCENT  := "0A84FF"   ; Apple blue
YELLOW  := "FFD60A"   ; Apple yellow
LBLUE   := "5AC8FA"   ; Apple light blue
GREEN   := "34C759"   ; Apple green

; ============================================================
;  GUI
; ============================================================
myGui := Gui("+AlwaysOnTop -Caption +Border")
myGui.BackColor := BG
myGui.OnEvent("Close", DoClose)
myGui.MarginX := 0
myGui.MarginY := 0

; ---- drag handle strip at top ----
myGui.SetFont("s1", "Segoe UI")
dragBar := myGui.Add("Text", "x0 y0 w320 h54 Background" BG)

; ---- App name ----
myGui.SetFont("s14 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y14 w200 h22 Background" BG, "SuperFarm")

; ---- Subtitle ----
myGui.SetFont("s8 w700 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y36 w200 Background" BG, "Hypixel Skyblock")

; ---- Window controls (top right) ----
myGui.SetFont("s9 w700 c" SUB, "Segoe UI")
myGui.Add("Button", "x272 y16 w18 h18", "_").OnEvent("Click", DoMinimise)
myGui.Add("Button", "x294 y16 w18 h18", "X").OnEvent("Click", DoClose)

; ---- Thin divider ----
myGui.Add("Text", "x0 y54 w320 h1 Background" STROKE)

; ============================================================
;  MODE SECTION
; ============================================================
myGui.SetFont("s7 w700 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y68 w276", "MODE")

myGui.SetFont("s10 w700 c000000", "Segoe UI")
myGui.Add("DropDownList", "vMode x22 y84 w276 h130 Choose1 AltSubmit", [
    "Wheat / Potatoes",
    "Carrot / Nether Wart",
    "Sugar Cane",
    "Cocoa Beans",
    "Melon / Pumpkin",
    "Mushroom",
    "Eclipse / Wild Rose"
])

; ---- Thin divider ----
myGui.Add("Text", "x0 y122 w320 h1 Background" STROKE)

; ============================================================
;  PEST REPELLENT SECTION
; ============================================================
myGui.SetFont("s7 w700 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y135 w180", "PEST REPELLENT")

; ---- Switch (toggle) - repositioned lower ----
myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
global pestSwitch := myGui.Add("CheckBox", "vPestSwitch x22 y156 w276 h20").OnEvent("Click", TogglePestRepellent)

; ---- Character input box (white background, black text) ----
myGui.SetFont("s11 w700 c000000", "Segoe UI")
global pestCharInput := myGui.Add("Edit", "vPestChar x22 y176 w50 h24 Limit1", pestRepellentChar)

; ---- Thin divider ----
myGui.Add("Text", "x0 y208 w320 h1 Background" STROKE)

; ============================================================
;  CROP INFO SECTION
; ============================================================
myGui.SetFont("s7 w700 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y221 w276", "REFERENCE")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y238 w180", "Wheat / Potatoes")
myGui.SetFont("s10 w700 c" YELLOW, "Segoe UI")
myGui.Add("Text", "x248 y238 w52", "126")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y258 w180", "Carrot / Nether Wart")
myGui.SetFont("s10 w700 c" LBLUE, "Segoe UI")
myGui.Add("Text", "x248 y258 w52", "127")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y278 w180", "Sugar Cane")
myGui.SetFont("s10 w700 c" GREEN, "Segoe UI")
myGui.Add("Text", "x248 y278 w52", "51")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y298 w180", "Cocoa Beans")
myGui.SetFont("s10 w700 cFF9F0A", "Segoe UI")
myGui.Add("Text", "x248 y298 w52", "76")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y318 w180", "Melon / Pumpkin")
myGui.SetFont("s10 w700 c30D158", "Segoe UI")
myGui.Add("Text", "x248 y318 w52", "76")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y338 w180", "Mushroom")
myGui.SetFont("s10 w700 cFF453A", "Segoe UI")
myGui.Add("Text", "x248 y338 w52", "116")

myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y358 w180", "Eclipse / Wild Rose")
myGui.SetFont("s10 w700 cBF5AF2", "Segoe UI")
myGui.Add("Text", "x248 y358 w52", "21")

; ---- Thin divider ----
myGui.Add("Text", "x0 y378 w320 h1 Background" STROKE)

; ============================================================
;  STATUS SECTION
; ============================================================
myGui.SetFont("s7 w700 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y391 w276", "STATUS")

myGui.SetFont("s10 w700 c" SUB, "Segoe UI")
global statusText := myGui.Add("Text", "x22 y407 w276 h18", "Idle")

; ---- Thin divider ----
myGui.Add("Text", "x0 y431 w320 h1 Background" STROKE)

; ============================================================
;  ACTION BUTTONS
; ============================================================
myGui.SetFont("s10 w700 c" TEXT, "Segoe UI")
myGui.Add("Button", "x22 y443 w130 h34", "Start  Ctrl+1").OnEvent("Click", DoStart)
myGui.Add("Button", "x162 y443 w136 h34", "Stop  Ctrl+2").OnEvent("Click", DoStop)

; ---- Hint row ----
myGui.SetFont("s7 w700 c" STROKE, "Segoe UI")
myGui.Add("Text", "x22 y485 w276", "Ctrl+3 pause    Ctrl+4 resume")

myGui.Show("w320 h505")

; ============================================================
;  ROUNDED CORNERS via DWM (Windows 11)
; ============================================================
hwnd := myGui.Hwnd
DllCall("dwmapi\DwmSetWindowAttribute",
    "Ptr",  hwnd,
    "UInt", 33,
    "Int*", 2,
    "UInt", 4)

; ============================================================
;  WINDOW DRAG
; ============================================================
OnMessage(0x201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    PostMessage(0xA1, 2, 0,, "ahk_id " myGui.Hwnd)
}

; ============================================================
;  HOTKEYS
; ============================================================
^1:: DoStart()
^2:: DoStop()
^3:: DoPause()
^4:: DoResume()

; ============================================================
;  HELPERS
; ============================================================
SetStatus(msg) {
    global statusText
    statusText.Value := msg
}

TogglePestRepellent(GuiCtrlObj, Info) {
    global pestRepellentEnabled, pestCharInput
    pestRepellentEnabled := Info
    if (!pestRepellentEnabled) {
        pestCharInput.Value := ""
        SavePestChar("")
    }
}

SavePestChar(char) {
    global pestRepellentChar
    pestRepellentChar := char
    filePath := A_ScriptFullPath
    fileContent := FileRead(filePath)
    
    ; Escape the character for use in replacement
    escapedChar := StrReplace(char, "\", "\\")
    
    ; Build the replacement string safely
    newLine := 'global pestRepellentChar := "' . escapedChar . '"'
    
    ; Use simple string replacement instead of regex
    pattern := 'global pestRepellentChar := "'
    startPos := InStr(fileContent, pattern)
    
    if (startPos > 0) {
        endPos := InStr(fileContent, '"', , startPos + StrLen(pattern))
        if (endPos > 0) {
            beforePart := SubStr(fileContent, 1, startPos - 1)
            afterPart := SubStr(fileContent, endPos + 1)
            newContent := beforePart . newLine . afterPart
            
            FileDelete(filePath)
            FileAppend(newContent, filePath)
        }
    }
}

HoldKeyWithStatus(key, ms, statusPrefix) {
    global cycleRunning, paused, statusText
    Send("{" key " down}{LButton down}")
    done := 0
    Loop {
        if (!cycleRunning) {
            Send("{" key " up}{LButton up}")
            return false
        }
        if (paused) {
            Send("{" key " up}{LButton up}")
            while (paused && cycleRunning)
                Sleep(50)
            if (!cycleRunning)
                return false
            Send("{" key " down}{LButton down}")
        }
        
        ; Update status with remaining seconds
        remaining := (ms - done) / 1000
        statusText.Value := statusPrefix . " - " . Round(remaining, 1) . "s"
        
        Sleep(50)
        done += 50
        if (done >= ms)
            break
    }
    Send("{" key " up}{LButton up}")
    return true
}

HoldKey(key, ms) {
    global cycleRunning, paused
    Send("{" key " down}{LButton down}")
    done := 0
    Loop {
        if (!cycleRunning) {
            Send("{" key " up}{LButton up}")
            return false
        }
        if (paused) {
            Send("{" key " up}{LButton up}")
            while (paused && cycleRunning)
                Sleep(50)
            if (!cycleRunning)
                return false
            Send("{" key " down}{LButton down}")
        }
        Sleep(50)
        done += 50
        if (done >= ms)
            break
    }
    Send("{" key " up}{LButton up}")
    return true
}

HoldKeyNoClick(key, ms) {
    global cycleRunning, paused
    Send("{" key " down}")
    done := 0
    Loop {
        if (!cycleRunning) {
            Send("{" key " up}")
            return false
        }
        if (paused) {
            Send("{" key " up}")
            while (paused && cycleRunning)
                Sleep(50)
            if (!cycleRunning)
                return false
            Send("{" key " down}")
        }
        Sleep(50)
        done += 50
        if (done >= ms)
            break
    }
    Send("{" key " up}")
    return true
}

SafeWaitWithStatus(ms, statusMsg) {
    global cycleRunning, paused, statusText
    done := 0
    Loop {
        if (!cycleRunning)
            return false
        while (paused && cycleRunning)
            Sleep(50)
        if (!cycleRunning)
            return false
        
        ; Update status with remaining seconds
        remaining := (ms - done) / 1000
        statusText.Value := statusMsg . " - " . Round(remaining, 1) . "s"
        
        Sleep(50)
        done += 50
        if (done >= ms)
            break
    }
    return true
}

SafeWait(ms) {
    global cycleRunning, paused
    done := 0
    Loop {
        if (!cycleRunning)
            return false
        while (paused && cycleRunning)
            Sleep(50)
        if (!cycleRunning)
            return false
        Sleep(50)
        done += 50
        if (done >= ms)
            break
    }
    return true
}

; ============================================================
;  START  (Ctrl+1)
; ============================================================
DoStart(*) {
    global cycleRunning, paused, holdSec, Mode, pestRepellentEnabled, pestCharInput
    if (cycleRunning)
        ForceStop()
    saved   := myGui.Submit(false)
    Mode    := ["Wheat / Potatoes","Carrot / Nether Wart","Sugar Cane","Cocoa Beans","Melon / Pumpkin","Mushroom","Eclipse / Wild Rose"][saved.Mode]
    holdSec := HOLD[Mode]
    pestRepellentEnabled := saved.PestSwitch
    pestRepellentChar := pestCharInput.Value
    cycleRunning := true
    paused       := false
    SoundBeep(880, 80)
    SetStatus("Running")
    SetTimer(RunCycle, -10)
}

; ============================================================
;  STOP  (Ctrl+2)
; ============================================================
DoStop(*) {
    ForceStop()
}

; ============================================================
;  PAUSE  (Ctrl+3)
; ============================================================
DoPause(*) {
    global cycleRunning, paused
    if (!cycleRunning || paused)
        return
    paused := true
    SetStatus("Paused")
}

; ============================================================
;  RESUME  (Ctrl+4)
; ============================================================
DoResume(*) {
    global cycleRunning, paused
    if (!cycleRunning || !paused)
        return
    paused := false
    SetStatus("Running")
}

; ============================================================
;  MAIN CYCLE
; ============================================================
RunCycle() {
    global cycleRunning, paused, holdSec, Mode, pestRepellentEnabled, pestRepellentChar
    holdMs := holdSec * 1000

    Loop (pestRepellentEnabled && pestRepellentChar ? 2 : 1) {
        cycleNumber := A_Index
        
        ; ---- WHEAT / POTATOES ----
        if (Mode = "Wheat / Potatoes") {
            if (!HoldKeyWithStatus("d", holdMs, "Wheat - D (1/5)"))
                return
            if (!SafeWaitWithStatus(2000, "Wheat - waiting"))
                return
            if (!HoldKeyWithStatus("a", holdMs, "Wheat - A (1/2)"))
                return
            if (!SafeWaitWithStatus(2000, "Wheat - waiting"))
                return
            if (!HoldKeyWithStatus("d", holdMs, "Wheat - D (2/5)"))
                return
            if (!SafeWaitWithStatus(2000, "Wheat - waiting"))
                return
            if (!HoldKeyWithStatus("a", holdMs, "Wheat - A (2/2)"))
                return
            if (!SafeWaitWithStatus(2000, "Wheat - waiting"))
                return
            if (!HoldKeyWithStatus("d", holdMs, "Wheat - D (final)"))
                return
        }

        ; ---- CARROT / NETHER WART ----
        else if (Mode = "Carrot / Nether Wart") {
            if (!HoldKeyWithStatus("a", holdMs, "Carrot - A (1/5)"))
                return
            if (!SafeWaitWithStatus(2000, "Carrot - waiting"))
                return
            if (!HoldKeyWithStatus("d", holdMs, "Carrot - D (1/2)"))
                return
            if (!SafeWaitWithStatus(2000, "Carrot - waiting"))
                return
            if (!HoldKeyWithStatus("a", holdMs, "Carrot - A (2/5)"))
                return
            if (!SafeWaitWithStatus(2000, "Carrot - waiting"))
                return
            if (!HoldKeyWithStatus("d", holdMs, "Carrot - D (2/2)"))
                return
            if (!SafeWaitWithStatus(2000, "Carrot - waiting"))
                return
            if (!HoldKeyWithStatus("a", holdMs, "Carrot - A (final)"))
                return
        }

        ; ---- SUGAR CANE ----
        else if (Mode = "Sugar Cane") {
            Loop 4 {
                i := A_Index
                if (!HoldKeyWithStatus("d", holdMs, "Sugar Cane - D (" i "/4)"))
                    return
                if (!HoldKeyWithStatus("s", holdMs, "Sugar Cane - S (" i "/4)"))
                    return
            }
            if (!HoldKeyWithStatus("d", holdMs, "Sugar Cane - D (final)"))
                return
        }

        ; ---- COCOA BEANS ----
        else if (Mode = "Cocoa Beans") {
            Loop 14 {
                i := A_Index
                if (!HoldKeyWithStatus("w", holdMs, "Cocoa - W (" i "/14)"))
                    return
                if (!HoldKeyNoClick("d", 1000))
                    return
                if (!HoldKeyWithStatus("s", holdMs, "Cocoa - S (" i "/14)"))
                    return
                if (!HoldKeyNoClick("d", 1000))
                    return
            }
        }

        ; ---- MELON / PUMPKIN ----
        else if (Mode = "Melon / Pumpkin") {
            Loop 5 {
                i := A_Index
                if (!HoldKeyWithStatus("d", holdMs, "Melon - D (" i "/5)"))
                    return
                if (!HoldKeyNoClick("w", 1000))
                    return
                if (!HoldKeyWithStatus("a", holdMs, "Melon - A (" i "/5)"))
                    return
                if (!HoldKeyNoClick("w", 1000))
                    return
            }
            if (!HoldKeyWithStatus("d", holdMs, "Melon - D (final)"))
                return
        }

        ; ---- MUSHROOM ----
        else if (Mode = "Mushroom") {
            if (!HoldKeyWithStatus("w", holdMs, "Mushroom - W (1/2)"))
                return
            if (!HoldKeyNoClick("a", 500))
                return
            if (!HoldKeyWithStatus("s", holdMs, "Mushroom - S (1/2)"))
                return
            if (!HoldKeyWithStatus("w", holdMs, "Mushroom - W (2/2)"))
                return
            if (!HoldKeyNoClick("a", 500))
                return
            if (!HoldKeyWithStatus("s", holdMs, "Mushroom - S (2/2)"))
                return
        }

        ; ---- ECLIPSE / WILD ROSE ----
        else if (Mode = "Eclipse / Wild Rose") {
            Loop 15 {
                i := A_Index
                if (!HoldKeyWithStatus("d", holdMs, "Eclipse - D (" i "/15)"))
                    return
                if (!HoldKeyWithStatus("s", holdMs, "Eclipse - S (" i "/15)"))
                    return
            }
            if (!HoldKeyWithStatus("d", holdMs, "Eclipse - D (final)"))
                return
        }

        ; If pest repellent is enabled and this isn't the last cycle, press the key and wait
        if (pestRepellentEnabled && pestRepellentChar && cycleNumber = 1) {
            if (!SafeWaitWithStatus(2000, "Pest Repellent - waiting"))
                return
            SetStatus("Pest Repellent - pressing " pestRepellentChar)
            Send(pestRepellentChar)
            if (!SafeWaitWithStatus(2000, "Pest Repellent - waiting"))
                return
        }
    }

    ForceStop()
}

; ============================================================
;  FORCE STOP
; ============================================================
ForceStop() {
    global cycleRunning, paused, pestCharInput
    cycleRunning := false
    paused       := false
    Send("{a up}{d up}{w up}{s up}{LButton up}")
    SavePestChar(pestCharInput.Value)
    SetStatus("Idle")
    SoundBeep(440, 80)
}

; ============================================================
;  MINIMISE / CLOSE
; ============================================================
DoMinimise(*) {
    myGui.Minimize()
}

DoClose(*) {
    ForceStop()
    ExitApp()
}