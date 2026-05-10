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
myGui.SetFont("s14 w300 c" TEXT, "Segoe UI Light")
myGui.Add("Text", "x22 y14 w200 h22 Background" BG, "SuperFarm")

; ---- Subtitle ----
myGui.SetFont("s8 w400 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y36 w200 Background" BG, "Hypixel Skyblock")

; ---- Window controls (top right) ----
myGui.SetFont("s9 w400 c" SUB, "Segoe UI")
myGui.Add("Button", "x272 y16 w18 h18", "_").OnEvent("Click", DoMinimise)
myGui.Add("Button", "x294 y16 w18 h18", "X").OnEvent("Click", DoClose)

; ---- Thin divider ----
myGui.Add("Text", "x0 y54 w320 h1 Background" STROKE)

; ============================================================
;  MODE SECTION
; ============================================================
myGui.SetFont("s7 w600 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y68 w276", "MODE")

myGui.SetFont("s10 w400 c000000", "Segoe UI")
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
myGui.SetFont("s7 w600 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y135 w180", "PEST REPELLENT")

; ---- Switch (toggle) ----
myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
global pestSwitch := myGui.Add("CheckBox", "vPestSwitch x248 y132 w20 h20").OnEvent("Click", TogglePestRepellent)

; ---- Character input box ----
myGui.SetFont("s11 w600 c" TEXT, "Segoe UI")
global pestCharInput := myGui.Add("Edit", "vPestChar x22 y158 w50 h24 Limit1", pestRepellentChar)

; ---- Thin divider ----
myGui.Add("Text", "x0 y190 w320 h1 Background" STROKE)

; ============================================================
;  CROP INFO SECTION
; ============================================================
myGui.SetFont("s7 w600 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y203 w276", "REFERENCE")

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y220 w180", "Wheat / Potatoes")
myGui.SetFont("s10 w600 c" YELLOW, "Segoe UI")
myGui.Add("Text", "x248 y220 w52", "126") ; <-- fill in here

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y240 w180", "Carrot / Nether Wart")
myGui.SetFont("s10 w600 c" LBLUE, "Segoe UI")
myGui.Add("Text", "x248 y240 w52", "127") ; <-- fill in here

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y260 w180", "Sugar Cane")
myGui.SetFont("s10 w600 c" GREEN, "Segoe UI")
myGui.Add("Text", "x248 y260 w52", "51") ; <-- fill in here

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y280 w180", "Cocoa Beans")
myGui.SetFont("s10 w600 cFF9F0A", "Segoe UI")
myGui.Add("Text", "x248 y280 w52", "76") ; <-- fill in here

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y300 w180", "Melon / Pumpkin")
myGui.SetFont("s10 w600 c30D158", "Segoe UI")
myGui.Add("Text", "x248 y300 w52", "76") ; <-- fill in here

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y320 w180", "Mushroom")
myGui.SetFont("s10 w600 cFF453A", "Segoe UI")
myGui.Add("Text", "x248 y320 w52", "116") ; <-- fill in here

myGui.SetFont("s10 w400 c" TEXT, "Segoe UI")
myGui.Add("Text", "x22 y340 w180", "Eclipse / Wild Rose")
myGui.SetFont("s10 w600 cBF5AF2", "Segoe UI")
myGui.Add("Text", "x248 y340 w52", "21") ; <-- fill in here

; ---- Thin divider ----
myGui.Add("Text", "x0 y360 w320 h1 Background" STROKE)

; ============================================================
;  STATUS SECTION
; ============================================================
myGui.SetFont("s7 w600 c" SUB, "Segoe UI")
myGui.Add("Text", "x22 y373 w276", "STATUS")

myGui.SetFont("s10 w300 c" SUB, "Segoe UI Light")
global statusText := myGui.Add("Text", "x22 y389 w276 h18", "Idle")

; ---- Thin divider ----
myGui.Add("Text", "x0 y413 w320 h1 Background" STROKE)

; ============================================================
;  ACTION BUTTONS
; ============================================================
myGui.SetFont("s10 w500 c" TEXT, "Segoe UI")
myGui.Add("Button", "x22 y425 w130 h34", "Start  Ctrl+1").OnEvent("Click", DoStart)
myGui.Add("Button", "x162 y425 w136 h34", "Stop  Ctrl+2").OnEvent("Click", DoStop)

; ---- Hint row ----
myGui.SetFont("s7 w400 c" STROKE, "Segoe UI")
myGui.Add("Text", "x22 y467 w276", "Ctrl+3 pause    Ctrl+4 resume")

myGui.Show("w320 h487")

; ============================================================
;  ROUNDED CORNERS via DWM (Windows 11)
; ============================================================
; DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2
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
^1:: DoStart()     ; Ctrl+1 = force start (stops then restarts)
^2:: DoStop()      ; Ctrl+2 = force stop
^3:: DoPause()     ; Ctrl+3 = pause
^4:: DoResume()    ; Ctrl+4 = resume (only if paused)

; ============================================================
;  HELPERS
; ============================================================
SetStatus(msg) {
    global statusText
    statusText.Value := msg
}

TogglePestRepellent(*) {
    global pestRepellentEnabled, pestSwitch, pestCharInput
    pestRepellentEnabled := pestSwitch.Value
    if (!pestRepellentEnabled) {
        pestCharInput.Value := ""
        SavePestChar("")
    }
}

SavePestChar(char) {
    global pestRepellentChar
    pestRepellentChar := char
    ; Read the entire file
    filePath := A_ScriptFullPath
    fileContent := FileRead(filePath)
    
    ; Replace the global pestRepellentChar line
    newContent := RegExReplace(fileContent, "global pestRepellentChar := "".*?""", "global pestRepellentChar := """ char """")
    
    ; Write back to file
    FileDelete(filePath)
    FileAppend(newContent, filePath)
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

; Hold a key WITHOUT left click (for movement/turn keys like W, S, D steps)
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
;  START  (Ctrl+1 — force restarts if already running)
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
;  STOP  (Ctrl+2 — force stop)
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
;  RESUME  (Ctrl+4 — only works if paused)
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

    ; Run the cycle (optionally twice if pest repellent is enabled)
    Loop (pestRepellentEnabled && pestRepellentChar ? 2 : 1) {
        cycleNumber := A_Index
        
        ; ---- WHEAT / POTATOES ----
        if (Mode = "Wheat / Potatoes") {
            SetStatus("Wheat - D (1/5)")
            if (!HoldKey("d", holdMs))
                return
            SetStatus("Wheat - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Wheat - A (1/2)")
            if (!HoldKey("a", holdMs))
                return
            SetStatus("Wheat - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Wheat - D (2/5)")
            if (!HoldKey("d", holdMs))
                return
            SetStatus("Wheat - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Wheat - A (2/2)")
            if (!HoldKey("a", holdMs))
                return
            SetStatus("Wheat - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Wheat - D (final)")
            if (!HoldKey("d", holdMs))
                return
        }

        ; ---- CARROT / NETHER WART ----
        else if (Mode = "Carrot / Nether Wart") {
            SetStatus("Carrot - A (1/5)")
            if (!HoldKey("a", holdMs))
                return
            SetStatus("Carrot - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Carrot - D (1/2)")
            if (!HoldKey("d", holdMs))
                return
            SetStatus("Carrot - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Carrot - A (2/5)")
            if (!HoldKey("a", holdMs))
                return
            SetStatus("Carrot - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Carrot - D (2/2)")
            if (!HoldKey("d", holdMs))
                return
            SetStatus("Carrot - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Carrot - A (final)")
            if (!HoldKey("a", holdMs))
                return
        }

        ; ---- SUGAR CANE ----
        else if (Mode = "Sugar Cane") {
            Loop 4 {
                i := A_Index
                SetStatus("Sugar Cane - D (" i "/4)")
                if (!HoldKey("d", holdMs))
                    return
                SetStatus("Sugar Cane - S (" i "/4)")
                if (!HoldKey("s", holdMs))
                    return
            }
            SetStatus("Sugar Cane - D (final)")
            if (!HoldKey("d", holdMs))
                return
        }

        ; ---- COCOA BEANS ----
        else if (Mode = "Cocoa Beans") {
            Loop 14 {
                i := A_Index
                SetStatus("Cocoa - W (" i "/14)")
                if (!HoldKey("w", holdMs))
                    return
                SetStatus("Cocoa - D step (" i "/14)")
                if (!HoldKeyNoClick("d", 1000))
                    return
                SetStatus("Cocoa - S (" i "/14)")
                if (!HoldKey("s", holdMs))
                    return
                SetStatus("Cocoa - D step (" i "/14)")
                if (!HoldKeyNoClick("d", 1000))
                    return
            }
        }

        ; ---- MELON / PUMPKIN ----
        ; 5x (D(x) -> W(1s) -> A(x) -> W(1s)) then final D(x)
        else if (Mode = "Melon / Pumpkin") {
            Loop 5 {
                i := A_Index
                SetStatus("Melon - D (" i "/5)")
                if (!HoldKey("d", holdMs))
                    return
                SetStatus("Melon - W step (" i "/5)")
                if (!HoldKeyNoClick("w", 1000))
                    return
                SetStatus("Melon - A (" i "/5)")
                if (!HoldKey("a", holdMs))
                    return
                SetStatus("Melon - W step (" i "/5)")
                if (!HoldKeyNoClick("w", 1000))
                    return
            }
            SetStatus("Melon - D (final)")
            if (!HoldKey("d", holdMs))
                return
        }

        ; ---- MUSHROOM ----
        ; W(x) -> A(0.5s) -> S(x) -> W(x) -> A(0.5s) -> S(x)
        else if (Mode = "Mushroom") {
            SetStatus("Mushroom - W (1/2)")
            if (!HoldKey("w", holdMs))
                return
            SetStatus("Mushroom - A nudge (1/2)")
            if (!HoldKeyNoClick("a", 500))
                return
            SetStatus("Mushroom - S (1/2)")
            if (!HoldKey("s", holdMs))
                return
            SetStatus("Mushroom - W (2/2)")
            if (!HoldKey("w", holdMs))
                return
            SetStatus("Mushroom - A nudge (2/2)")
            if (!HoldKeyNoClick("a", 500))
                return
            SetStatus("Mushroom - S (2/2)")
            if (!HoldKey("s", holdMs))
                return
        }

        ; ---- ECLIPSE / WILD ROSE ----
        ; 15x (D(x) -> S(x)) then final D(x) only — 15.5 cycles
        else if (Mode = "Eclipse / Wild Rose") {
            Loop 15 {
                i := A_Index
                SetStatus("Eclipse - D (" i "/15)")
                if (!HoldKey("d", holdMs))
                    return
                SetStatus("Eclipse - S (" i "/15)")
                if (!HoldKey("s", holdMs))
                    return
            }
            SetStatus("Eclipse - D (final)")
            if (!HoldKey("d", holdMs))
                return
        }

        ; If pest repellent is enabled and this isn't the last cycle, press the key and wait
        if (pestRepellentEnabled && pestRepellentChar && cycleNumber = 1) {
            SetStatus("Pest Repellent - waiting 2s")
            if (!SafeWait(2000))
                return
            SetStatus("Pest Repellent - pressing " pestRepellentChar)
            Send(pestRepellentChar)
            SetStatus("Pest Repellent - waiting 2s")
            if (!SafeWait(2000))
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