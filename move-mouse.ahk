#Requires AutoHotkey v2.0
#SingleInstance Force
SetDefaultMouseSpeed(0)  ; Instant mouse movement.

; === Configuration ===
; Movement distance per interval (in pixels)
moveDistance := 5

; Movement interval in milliseconds
moveInterval := 1

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
