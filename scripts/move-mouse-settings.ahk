#Requires AutoHotkey v2.0
#SingleInstance Force

; Function to load existing settings
LoadSettings() {
    settingsPath := A_ScriptDir "\settings.ini"
    settings := Map(
        "Distance", "5",
        "Interval", "1",
        "Activation", "RAlt",
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

    if FileExist(settingsPath) {
        try {
            ; Load Movement settings
            settings["Distance"] := IniRead(settingsPath, "Movement", "Distance", "5")
            settings["Interval"] := IniRead(settingsPath, "Movement", "Interval", "1")

            ; Load Acceleration settings
            settings["MinDistance"] := IniRead(settingsPath, "Acceleration", "MinDistance", "1")
            settings["MaxDistance"] := IniRead(settingsPath, "Acceleration", "MaxDistance", "20")
            settings["AccelerationDuration"] := IniRead(settingsPath, "Acceleration", "AccelerationDuration", "100")

            ; Load Keybind settings
            settings["Activation"] := IniRead(settingsPath, "Keybinds", "Activation", "RAlt")
            settings["Up"] := IniRead(settingsPath, "Keybinds", "Up", "w")
            settings["Down"] := IniRead(settingsPath, "Keybinds", "Down", "s")
            settings["Left"] := IniRead(settingsPath, "Keybinds", "Left", "a")
            settings["Right"] := IniRead(settingsPath, "Keybinds", "Right", "d")
            settings["LeftClick"] := IniRead(settingsPath, "Keybinds", "LeftClick", "j")
            settings["RightClick"] := IniRead(settingsPath, "Keybinds", "RightClick", "k")
            settings["PageUp"] := IniRead(settingsPath, "Keybinds", "PageUp", "i")
            settings["PageDown"] := IniRead(settingsPath, "Keybinds", "PageDown", "o")
        }
    }
    return settings
}

; Load existing settings
currentSettings := LoadSettings()

; Create the main settings window
settingsGui := Gui(, "Mouse Control Settings")
settingsGui.SetFont("s10")

; Movement Settings Group
settingsGui.Add("GroupBox", "w300 h120", "Movement Settings")
settingsGui.Add("Text", "xp+10 yp+20", "Maximum Movement Distance (pixels):")
distanceInput := settingsGui.Add("Edit", "w50", currentSettings["MaxDistance"])
upDown1 := settingsGui.Add("UpDown", "Range1-100", currentSettings["MaxDistance"])

settingsGui.Add("Text", "xp+0 y+10", "Minimum Movement Distance (pixels):")
minDistanceInput := settingsGui.Add("Edit", "w50", currentSettings["MinDistance"])
upDownMin := settingsGui.Add("UpDown", "Range1-100", currentSettings["MinDistance"])

settingsGui.Add("Text", "xp+0 y+10", "Acceleration Duration (ms):")
accelDurationInput := settingsGui.Add("Edit", "w50", currentSettings["AccelerationDuration"])
upDownAccel := settingsGui.Add("UpDown", "Range100-5000", currentSettings["AccelerationDuration"])

settingsGui.Add("Text", "xp+0 y+10", "Movement Interval (ms):")
intervalInput := settingsGui.Add("Edit", "w50", currentSettings["Interval"])
upDown2 := settingsGui.Add("UpDown", "Range1-100", currentSettings["Interval"])

; Keybind Settings Group
settingsGui.Add("GroupBox", "x10 y+20 w300 h220", "Keybind Settings")
settingsGui.Add("Text", "xp+10 yp+20", "Activation Key:")
activationKeyInput := settingsGui.Add("Hotkey", "w100", currentSettings["Activation"])

settingsGui.Add("Text", "x20 y+10", "Movement Keys:")
settingsGui.Add("Text", "x30 y+5", "Up:")
upKeyInput := settingsGui.Add("Hotkey", "w100", currentSettings["Up"])

settingsGui.Add("Text", "x30 y+5", "Down:")
downKeyInput := settingsGui.Add("Hotkey", "w100", currentSettings["Down"])

settingsGui.Add("Text", "x30 y+5", "Left:")
leftKeyInput := settingsGui.Add("Hotkey", "w100", currentSettings["Left"])

settingsGui.Add("Text", "x30 y+5", "Right:")
rightKeyInput := settingsGui.Add("Hotkey", "w100", currentSettings["Right"])

settingsGui.Add("Text", "x30 y+5", "Left Click:")
leftClickInput := settingsGui.Add("Hotkey", "w100", currentSettings["LeftClick"])

settingsGui.Add("Text", "x30 y+5", "Right Click:")
rightClickInput := settingsGui.Add("Hotkey", "w100", currentSettings["RightClick"])

settingsGui.Add("Text", "x30 y+5", "Page Up:")
pageUpInput := settingsGui.Add("Hotkey", "w100", currentSettings["PageUp"])

settingsGui.Add("Text", "x30 y+5", "Page Down:")
pageDownInput := settingsGui.Add("Hotkey", "w100", currentSettings["PageDown"])

; Add a button to save settings
saveBtn := settingsGui.Add("Button", "x10 y+20 w100", "Save Settings")
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
        fileContent .= "Distance=" maxDistance "`n"
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
