#Requires AutoHotkey v2.0
#SingleInstance Force
SetDefaultMouseSpeed(0)

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
        settings := Map()
        settings["distance"] := 50
        settings["interval"] := 1
        settings["activation"] := "LAlt"
        settings["up"] := "w"
        settings["down"] := "s"
        settings["left"] := "a"
        settings["right"] := "d"
        settings["leftClick"] := "j"
        settings["rightClick"] := "k"

        ; Parse Movement settings
        if (RegExMatch(fileContent, "Distance=(\d+)", &match))
            settings["distance"] := Integer(match[1])
        if (RegExMatch(fileContent, "Interval=(\d+)", &match))
            settings["interval"] := Integer(match[1])

        ; Parse Keybind settings
        if (RegExMatch(fileContent, "Activation=(.+)\n", &match))
            settings["activation"] := Trim(match[1])
        if (RegExMatch(fileContent, "Up=(.+)\n", &match))
            settings["up"] := Trim(match[1])
        if (RegExMatch(fileContent, "Down=(.+)\n", &match))
            settings["down"] := Trim(match[1])
        if (RegExMatch(fileContent, "Left=(.+)\n", &match))
            settings["left"] := Trim(match[1])
        if (RegExMatch(fileContent, "Right=(.+)\n", &match))
            settings["right"] := Trim(match[1])

        ; Parse Click settings
        if (RegExMatch(fileContent, "LeftClick=(.+)\n", &match))
            settings["leftClick"] := Trim(match[1])
        if (RegExMatch(fileContent, "RightClick=(.+)\n", &match))
            settings["rightClick"] := Trim(match[1])

        return settings
    } catch as err {
        MsgBox("Error reading file:`n" err.Message)
        return Map(
            "distance", 50,
            "interval", 1,
            "activation", "RAlt",
            "up", "w",
            "down", "s",
            "left", "a",
            "right", "d"
        )
    }
}

; Read settings and set up variables
global moveDistance, moveInterval, keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick, activationKey

try {
    if FileExist(settingsPath) {
        settings := ReadSettingsFile()
        moveDistance := settings["distance"]
        moveInterval := settings["interval"]
        keyUp := settings["up"]
        keyDown := settings["down"]
        keyLeft := settings["left"]
        keyRight := settings["right"]
        activationKey := settings["activation"]
        keyLeftClick := settings["leftClick"]
        keyRightClick := settings["rightClick"]
    } else {
        ; Default values
        moveDistance := 50
        moveInterval := 1
        keyUp := "w"
        keyDown := "s"
        keyLeft := "a"
        keyRight := "d"
        activationKey := "RAlt"
        keyLeftClick := "j"
        keyRightClick := "k"
    }
} catch as err {
    MsgBox("Error in settings initialization:`n" err.Message)
    ExitApp()
}

; === Hotkey Definitions ===

; Dynamically create the hotkey
HotIfWinActive("A")  ; Apply to all windows
Hotkey(activationKey, ActivateMove)
Hotkey(activationKey " Up", DeactivateMove)

; Create suppression hotkeys using $ prefix to prevent recursion
ActivateMove(*) {
    global keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick

    ; Create hotkeys that suppress the original input
    Hotkey("$" keyUp, KeySuppressor, "On")
    Hotkey("$" keyLeft, KeySuppressor, "On")
    Hotkey("$" keyDown, KeySuppressor, "On")
    Hotkey("$" keyRight, KeySuppressor, "On")
    Hotkey("$" keyLeftClick, KeySuppressor, "On")
    Hotkey("$" keyRightClick, KeySuppressor, "On")

    ; Start the timer to check key states at specified intervals
    SetTimer(CheckKeys, moveInterval)
}

DeactivateMove(*) {
    global keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick

    ; Remove the suppression hotkeys
    try {
        Hotkey("$" keyUp, "Off")
        Hotkey("$" keyLeft, "Off")
        Hotkey("$" keyDown, "Off")
        Hotkey("$" keyRight, "Off")
        Hotkey("$" keyLeftClick, "Off")
        Hotkey("$" keyRightClick, "Off")
    }

    ; Stop the timer when activation key is released
    SetTimer(CheckKeys, 0)
}

; Function to suppress key input
KeySuppressor(*) {
    ; Do nothing, effectively suppressing the key
    return
}

; === Function Definitions ===

; Function to check the current keys pressed and determine direction
CheckKeys() {
    global moveDistance, keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick

    ; Determine current keys pressed
    upPressed := GetKeyState(keyUp, "P")
    leftPressed := GetKeyState(keyLeft, "P")
    downPressed := GetKeyState(keyDown, "P")
    rightPressed := GetKeyState(keyRight, "P")
    leftClickPressed := GetKeyState(keyLeftClick, "P")
    rightClickPressed := GetKeyState(keyRightClick, "P")

    ; Handle mouse clicks first
    if (leftClickPressed) {
        Click("Left")
        return  ; Return to prevent multiple actions in the same tick
    }
    if (rightClickPressed) {
        Click("Right")
        return  ; Return to prevent multiple actions in the same tick
    }

    ; Determine direction based on keys pressed
    if (upPressed && leftPressed)
        direction := "up-left"
    else if (upPressed && rightPressed)
        direction := "up-right"
    else if (downPressed && leftPressed)
        direction := "down-left"
    else if (downPressed && rightPressed)
        direction := "down-right"
    else if (upPressed)
        direction := "up"
    else if (leftPressed)
        direction := "left"
    else if (downPressed)
        direction := "down"
    else if (rightPressed)
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
