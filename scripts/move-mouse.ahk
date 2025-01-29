#Requires AutoHotkey v2.0
#SingleInstance Force
SetDefaultMouseSpeed(0)

; Create tray menu
A_TrayMenu.Delete() ; Clear default menu
A_TrayMenu.Add("Settings", ShowSettings)
A_TrayMenu.Add("Exit", (*) => ExitApp())
TraySetIcon("../icons/mouse-icon.ico")

; Define global variables at the start of the script
global isDragging := false
global movementStartTime := 0  ; Variable to track the start time of movement
global keyPageUp, keyPageDown

; Function to suppress key inputs
KeySuppressor(*) {
    ; Empty function to suppress keys
    return
}

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

        ; Initialise default values
        settings := Map()
        settings["interval"] := 1
        settings["activation"] := "CapsLock"
        settings["up"] := "w"
        settings["down"] := "s"
        settings["left"] := "a"
        settings["right"] := "d"
        settings["leftClick"] := "j"
        settings["rightClick"] := "k"
        settings["minDistance"] := 1
        settings["maxDistance"] := 20
        settings["accelerationDuration"] := 2000
        settings["pageUp"] := "i"
        settings["pageDown"] := "o"

        ; Parse Movement settings
        if (RegExMatch(fileContent, "Interval=(\d+)", &match))
            settings["interval"] := Round(Number(match[1]))

        ; Parse Acceleration settings
        if (RegExMatch(fileContent, "MinDistance=(\d+)", &match))
            settings["minDistance"] := Round(Number(match[1]))
        if (RegExMatch(fileContent, "MaxDistance=(\d+)", &match))
            settings["maxDistance"] := Round(Number(match[1]))
        if (RegExMatch(fileContent, "AccelerationDuration=(\d+)", &match))
            settings["accelerationDuration"] := Round(Number(match[1]))

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
        if (RegExMatch(fileContent, "LeftClick=(.+)\n", &match))
            settings["leftClick"] := Trim(match[1])
        if (RegExMatch(fileContent, "RightClick=(.+)\n", &match))
            settings["rightClick"] := Trim(match[1])
        if (RegExMatch(fileContent, "PageUp=([^\r\n]+)", &match))
            settings["pageUp"] := match[1]
        if (RegExMatch(fileContent, "PageDown=([^\r\n]+)", &match))
            settings["pageDown"] := match[1]

        return settings
    } catch as err {
        MsgBox("Error reading file:`n" err.Message)
        return Map(
            "interval", 1,
            "activation", "CapsLock",
            "up", "w",
            "down", "s",
            "left", "a",
            "right", "d",
            "minDistance", 1,
            "maxDistance", 20,
            "accelerationDuration", 2000,
            "pageUp", "i",
            "pageDown", "o"
        )
    }
}

; Read settings and set up variables
global moveInterval, keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick, activationKey,
    isDragging, minMoveDistance, maxMoveDistance, accelerationDuration

try {
    if FileExist(settingsPath) {
        settings := ReadSettingsFile()
        moveInterval := settings["interval"]
        keyUp := settings["up"]
        keyDown := settings["down"]
        keyLeft := settings["left"]
        keyRight := settings["right"]
        activationKey := settings["activation"]
        keyLeftClick := settings["leftClick"]
        keyRightClick := settings["rightClick"]
        minMoveDistance := settings["minDistance"]
        maxMoveDistance := settings["maxDistance"]
        accelerationDuration := settings["accelerationDuration"]
        keyPageUp := settings["pageUp"]
        keyPageDown := settings["pageDown"]
    } else {
        ; Default values
        moveInterval := 1
        keyUp := "w"
        keyDown := "s"
        keyLeft := "a"
        keyRight := "d"
        activationKey := "CapsLock"
        keyLeftClick := "j"
        keyRightClick := "k"
        minMoveDistance := 1
        maxMoveDistance := 20
        accelerationDuration := 2000
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

ActivateMove(*) {
    global keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick, moveInterval, movementStartTime
    movementStartTime := 0  ; Reset movement start time

    ; Suppress movement keys
    Hotkey("$" keyUp, KeySuppressor, "On")
    Hotkey("$" keyLeft, KeySuppressor, "On")
    Hotkey("$" keyDown, KeySuppressor, "On")
    Hotkey("$" keyRight, KeySuppressor, "On")

    ; Define hotkeys for keyLeftClick and keyRightClick
    Hotkey("$" keyLeftClick, LeftClickDown, "On")
    Hotkey("$" keyLeftClick " Up", LeftClickUp, "On")
    Hotkey("$" keyRightClick, RightClick, "On")
    Hotkey("$" keyPageUp, PageUpScroll, "On")
    Hotkey("$" keyPageDown, PageDownScroll, "On")

    ; Start the timer
    SetTimer(CheckKeys, moveInterval)
}

DeactivateMove(*) {
    global keyUp, keyDown, keyLeft, keyRight, keyLeftClick, keyRightClick, isDragging, movementStartTime

    movementStartTime := 0  ; Reset movement start time

    ; End drag if active
    if (isDragging) {
        Click("Left Up")
        isDragging := false
    }

    ; Remove hotkeys
    try {
        Hotkey("$" keyUp, "Off")
        Hotkey("$" keyLeft, "Off")
        Hotkey("$" keyDown, "Off")
        Hotkey("$" keyRight, "Off")
        Hotkey("$" keyLeftClick, "Off")
        Hotkey("$" keyLeftClick " Up", "Off")
        Hotkey("$" keyRightClick, "Off")
        Hotkey("$" keyPageUp, "Off")
        Hotkey("$" keyPageDown, "Off")
    }

    ; Stop the timer
    SetTimer(CheckKeys, 0)
}

; === Function Definitions ===

; Function to check the current keys pressed and determine direction
CheckKeys() {
    global keyUp, keyDown, keyLeft, keyRight, movementStartTime, minMoveDistance, maxMoveDistance, accelerationDuration

    ; Determine current keys pressed
    upPressed := GetKeyState(keyUp, "P")
    leftPressed := GetKeyState(keyLeft, "P")
    downPressed := GetKeyState(keyDown, "P")
    rightPressed := GetKeyState(keyRight, "P")

    anyKeyPressed := upPressed || downPressed || leftPressed || rightPressed

    ; Start or reset movementStartTime
    if (anyKeyPressed) {
        if (movementStartTime == 0) {
            movementStartTime := A_TickCount  ; Record the start time
        }
    } else {
        movementStartTime := 0  ; Reset when no movement keys are pressed
        return
    }

    ; Determine direction based on keys pressed
    direction := ""
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

    if (direction != "") {
        ; Calculate moveDistanceAdjusted based on duration
        duration := A_TickCount - movementStartTime

        ; Calculate moveDistanceAdjusted
        moveDistanceAdjusted := minMoveDistance + (maxMoveDistance - minMoveDistance) * (duration /
            accelerationDuration)

        ; Ensure moveDistanceAdjusted is within limits
        if (moveDistanceAdjusted > maxMoveDistance)
            moveDistanceAdjusted := maxMoveDistance
        if (moveDistanceAdjusted < minMoveDistance)
            moveDistanceAdjusted := minMoveDistance

        ; Move the mouse
        MoveMouse(direction, moveDistanceAdjusted)
    }
}

LeftClickDown(*) {
    global isDragging
    if (!isDragging) {
        Click("Left Down")
        isDragging := true
    }
}

LeftClickUp(*) {
    global isDragging
    if (isDragging) {
        Click("Left Up")
        isDragging := false
    }
}

RightClick(*) {
    Click("Right")
}

PageUpScroll(*) {
    Click("WheelUp", , , 3)  ; Scroll up 3 clicks
}

PageDownScroll(*) {
    Click("WheelDown", , , 3)  ; Scroll down 3 clicks
}

; Function to move the mouse based on the direction
MoveMouse(direction, moveDistanceAdjusted) {
    ; Initialize movement values
    x := 0
    y := 0

    ; Determine movement based on direction
    switch direction {
        case "up":
            y := -moveDistanceAdjusted
        case "down":
            y := moveDistanceAdjusted
        case "left":
            x := -moveDistanceAdjusted
        case "right":
            x := moveDistanceAdjusted
        case "up-right":
            y := -moveDistanceAdjusted
            x := moveDistanceAdjusted
        case "up-left":
            y := -moveDistanceAdjusted
            x := -moveDistanceAdjusted
        case "down-right":
            y := moveDistanceAdjusted
            x := moveDistanceAdjusted
        case "down-left":
            y := moveDistanceAdjusted
            x := -moveDistanceAdjusted
    }

    ; Move the mouse by the computed x and y values relative to current position
    MouseMove(x, y, 0, "R")
}
