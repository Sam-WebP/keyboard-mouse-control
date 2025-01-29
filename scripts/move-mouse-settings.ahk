#Requires AutoHotkey v2.0
#SingleInstance Force

; Function to load existing settings
LoadSettings() {
    settingsPath := A_ScriptDir "\settings.ini"
    settings := Map(
        "Interval", "1",
        "Activation", "CapsLock",
        "Up", "w",
        "Down", "s",
        "Left", "a",
        "Right", "d",
        "LeftClick", "j",
        "RightClick", "k",
        "PageUp", "i",
        "PageDown", "o",
        "MinDistance", "1",
        "MaxDistance", "20",
        "AccelerationDuration", "100"
    )

    try {
        if FileExist(settingsPath) {
            ; Read the file content
            fileContent := FileRead(settingsPath)

            ; Parse Movement settings
            if (RegExMatch(fileContent, "Interval=(\d+)", &match))
                settings["Interval"] := match[1]

            ; Parse Acceleration settings
            if (RegExMatch(fileContent, "MinDistance=(\d+)", &match))
                settings["MinDistance"] := match[1]
            if (RegExMatch(fileContent, "MaxDistance=(\d+)", &match))
                settings["MaxDistance"] := match[1]
            if (RegExMatch(fileContent, "AccelerationDuration=(\d+)", &match))
                settings["AccelerationDuration"] := match[1]

            ; Parse Keybind settings
            if (RegExMatch(fileContent, "Activation=(.+)\n", &match))
                settings["Activation"] := Trim(match[1])
            if (RegExMatch(fileContent, "Up=(.+)\n", &match))
                settings["Up"] := Trim(match[1])
            if (RegExMatch(fileContent, "Down=(.+)\n", &match))
                settings["Down"] := Trim(match[1])
            if (RegExMatch(fileContent, "Left=(.+)\n", &match))
                settings["Left"] := Trim(match[1])
            if (RegExMatch(fileContent, "Right=(.+)\n", &match))
                settings["Right"] := Trim(match[1])
            if (RegExMatch(fileContent, "LeftClick=(.+)\n", &match))
                settings["LeftClick"] := Trim(match[1])
            if (RegExMatch(fileContent, "RightClick=(.+)\n", &match))
                settings["RightClick"] := Trim(match[1])
            if (RegExMatch(fileContent, "PageUp=([^\r\n]+)", &match))
                settings["PageUp"] := match[1]
            if (RegExMatch(fileContent, "PageDown=([^\r\n]+)", &match))
                settings["PageDown"] := match[1]
        }
    } catch as err {
        MsgBox("Error reading settings file:`n" err.Message)
    }
    return settings
}

; Load existing settings
currentSettings := LoadSettings()

; Create the main settings window
settingsGui := Gui(, "Mouse Control Settings")
settingsGui.SetFont("s10")

; Movement Settings Group
settingsGui.Add("GroupBox", "x10 y10 w300 h180", "Movement Settings")
settingsGui.Add("Text", "xp+10 yp+20", "Maximum Movement Distance (pixels):")
distanceInput := settingsGui.Add("Edit", "x+5 yp w50", currentSettings["MaxDistance"])
upDown1 := settingsGui.Add("UpDown", "Range1-100", currentSettings["MaxDistance"])

settingsGui.Add("Text", "x20 y+10", "Minimum Movement Distance (pixels):")
minDistanceInput := settingsGui.Add("Edit", "x+5 yp w50", currentSettings["MinDistance"])
upDownMin := settingsGui.Add("UpDown", "Range1-100", currentSettings["MinDistance"])

settingsGui.Add("Text", "x20 y+10", "Acceleration Duration (ms):")
accelDurationInput := settingsGui.Add("Edit", "x+5 yp w50", currentSettings["AccelerationDuration"])
upDownAccel := settingsGui.Add("UpDown", "Range100-5000", currentSettings["AccelerationDuration"])

settingsGui.Add("Text", "x20 y+10", "Movement Interval (ms):")
intervalInput := settingsGui.Add("Edit", "x+5 yp w50", currentSettings["Interval"])
upDown2 := settingsGui.Add("UpDown", "Range1-100", currentSettings["Interval"])

; Keybind Settings Group
settingsGui.Add("GroupBox", "x320 y10 w344 h180", "Keybind Settings")
settingsGui.Add("Text", "xp+10 yp+20", "Activation Key:")
activationKeyInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["Activation"])

; First column of keybinds
settingsGui.Add("Text", "x330 y+10", "Up:")
upKeyInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["Up"])

settingsGui.Add("Text", "x330 y+5", "Down:")
downKeyInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["Down"])

settingsGui.Add("Text", "x330 y+5", "Left:")
leftKeyInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["Left"])

settingsGui.Add("Text", "x330 y+5", "Right:")
rightKeyInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["Right"])

; Second column of keybinds
settingsGui.Add("Text", "x480 y55", "Left Click:")
leftClickInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["LeftClick"])

settingsGui.Add("Text", "x480 y+5", "Right Click:")
rightClickInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["RightClick"])

settingsGui.Add("Text", "x480 y+5", "Page Up:")
pageUpInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["PageUp"])

settingsGui.Add("Text", "x480 y+5", "Page Down:")
pageDownInput := settingsGui.Add("Hotkey", "x+5 yp w100", currentSettings["PageDown"])

; Add a button to save settings
saveBtn := settingsGui.Add("Button", "x10 y200 w100", "Save Settings")
saveBtn.OnEvent("Click", SaveSettings)

; Prevent the script from closing when the GUI is closed
settingsGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
settingsGui.Show()

SaveSettings(*) {
    global distanceInput, intervalInput, activationKeyInput
    global upKeyInput, downKeyInput, leftKeyInput, rightKeyInput
    global minDistanceInput, accelDurationInput, leftClickInput, rightClickInput
    global pageUpInput, pageDownInput

    ; Save settings to an INI file using full path
    settingsPath := A_ScriptDir "\settings.ini"

    try {
        ; Convert values to numbers and round them to integers
        maxDistance := Round(Number(distanceInput.Value))
        minDistance := Round(Number(minDistanceInput.Value))
        interval := Round(Number(intervalInput.Value))
        accelDuration := Round(Number(accelDurationInput.Value))

        ; Validate that the numeric values are within acceptable ranges
        if (maxDistance <= 0)
            throw Error("Maximum Distance must be a positive number.")
        if (minDistance <= 0)
            throw Error("Minimum Distance must be a positive number.")
        if (interval <= 0)
            throw Error("Interval must be a positive number.")
        if (accelDuration <= 0)
            throw Error("Acceleration Duration must be a positive number.")

        ; Create INI content
        fileContent := "[Movement]`n"
        fileContent .= "Interval=" interval "`n"

        ; Add acceleration settings
        fileContent .= "`n[Acceleration]`n"
        fileContent .= "MinDistance=" minDistance "`n"
        fileContent .= "MaxDistance=" maxDistance "`n"
        fileContent .= "AccelerationDuration=" accelDuration "`n"

        ; Add keybind settings
        fileContent .= "`n[Keybinds]`n"
        fileContent .= "Activation=" activationKeyInput.Value "`n"
        fileContent .= "Up=" upKeyInput.Value "`n"
        fileContent .= "Down=" downKeyInput.Value "`n"
        fileContent .= "Left=" leftKeyInput.Value "`n"
        fileContent .= "Right=" rightKeyInput.Value "`n"
        fileContent .= "LeftClick=" leftClickInput.Value "`n"
        fileContent .= "RightClick=" rightClickInput.Value "`n"
        fileContent .= "PageUp=" pageUpInput.Value "`n"
        fileContent .= "PageDown=" pageDownInput.Value "`n"

        ; Delete existing file if it exists
        if FileExist(settingsPath)
            FileDelete(settingsPath)

        ; Write new content
        FileAppend(fileContent, settingsPath, "UTF-8")

        if FileExist(settingsPath) {
            MsgBox("Settings saved successfully!")

            ; Reload the main script with new settings
            try {
                Run(A_ScriptDir "\move-mouse.exe")
            } catch as err {
                MsgBox("Error reloading move-mouse.exe: " err.Message)
            }
            ExitApp()
        } else {
            throw Error("Failed to verify settings file was created")
        }
    } catch as err {
        MsgBox("Error saving settings:`n" err.Message)
    }
}
