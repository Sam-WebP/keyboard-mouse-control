#Requires AutoHotkey v2.0
#SingleInstance Force
SetDefaultMouseSpeed(0)  ; Instant mouse movement.

; Create tray menu
A_TrayMenu.Delete() ; Clear default menu
A_TrayMenu.Add("Settings", ShowSettings)
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Create the ShowSettings function
ShowSettings(*) {
    Run(A_ScriptDir "\move-mouse-settings.exe")
}

; === Configuration ===
settingsPath := A_ScriptDir "\settings.ini"

; Function to parse INI content manually
ReadSettingsFile() {
    global settingsPath
    
    try {
        ; Read the file content
        fileContent := FileRead(settingsPath)
        
        ; Initialize default values
        distance := 50
        interval := 1
        
        ; Parse for Distance value
        if (RegExMatch(fileContent, "Distance=(\d+)", &match))
            distance := Integer(match[1])
            
        ; Parse for Interval value
        if (RegExMatch(fileContent, "Interval=(\d+)", &match))
            interval := Integer(match[1])
            
        return [distance, interval]
    } catch as err {
        MsgBox("Error reading file:`n" err.Message)
        return [50, 1]  ; Return defaults if there's an error
    }
}

; Read settings
try {
    if FileExist(settingsPath) {
        settings := ReadSettingsFile()
        moveDistance := settings[1]
        moveInterval := settings[2]
        
        MsgBox("Successfully loaded settings:`n"
            . "Distance = " moveDistance "`n"
            . "Interval = " moveInterval)
    } else {
        moveDistance := 50
        moveInterval := 1
        MsgBox("Settings file not found. Using defaults.")
    }
} catch as err {
    MsgBox("Error in settings initialization:`n" err.Message)
    moveDistance := 50
    moveInterval := 1
}

; === Hotkey for debugging ===
^!d:: {  ; Ctrl+Alt+D to show current values
    MsgBox("Current Settings:`n"
        . "Distance = " moveDistance "`n"
        . "Interval = " moveInterval "`n"
        . "Settings Path = " settingsPath "`n"
        . "File Exists: " (FileExist(settingsPath) ? "Yes" : "No"))
}

; === Hotkey Definitions ===

; Define hotkeys for Right Alt press and release
RAlt:: {
    ; Start the timer to check key states at specified intervals
    SetTimer(CheckKeys, moveInterval)
}

RAlt Up:: {
    ; Stop the timer when Right Alt is released
    SetTimer(CheckKeys, 0)
}

; === Function Definitions ===

; Function to check the current keys pressed and determine direction
CheckKeys() {
    global moveDistance

    ; Determine current keys pressed
    wPressed := GetKeyState("w", "P")
    aPressed := GetKeyState("a", "P")
    sPressed := GetKeyState("s", "P")
    dPressed := GetKeyState("d", "P")

    ; Determine direction based on keys pressed
    if (wPressed && aPressed)
        direction := "up-left"
    else if (wPressed && dPressed)
        direction := "up-right"
    else if (sPressed && aPressed)
        direction := "down-left"
    else if (sPressed && dPressed)
        direction := "down-right"
    else if (wPressed)
        direction := "up"
    else if (aPressed)
        direction := "left"
    else if (sPressed)
        direction := "down"
    else if (dPressed)
        direction := "right"
    else
        direction := ""

    ; Move the mouse if any direction is pressed
    if (direction != "") {
        MoveMouse(direction)
    }
}

; Function to move the mouse based on the direction
MoveMouse(direction) {
    global moveDistance

    ; Initialize movement values
    x := 0
    y := 0

    ; Determine movement based on direction
    switch direction {
        case "up":
            y := -moveDistance
        case "down":
            y := moveDistance
        case "left":
            x := -moveDistance
        case "right":
            x := moveDistance
        case "up-right":
            y := -moveDistance
            x := moveDistance
        case "up-left":
            y := -moveDistance
            x := -moveDistance
        case "down-right":
            y := moveDistance
            x := moveDistance
        case "down-left":
            y := moveDistance
            x := -moveDistance
    }

    ; Move the mouse by the computed x and y values relative to current position
    MouseMove(x, y, 0, "R")
}
