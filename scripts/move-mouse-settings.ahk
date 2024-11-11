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
        "Right", "d"
    )

    if FileExist(settingsPath) {
        try {
            ; Load Movement settings
            settings["Distance"] := IniRead(settingsPath, "Movement", "Distance", "5")
            settings["Interval"] := IniRead(settingsPath, "Movement", "Interval", "1")
            
            ; Load Keybind settings
            settings["Activation"] := IniRead(settingsPath, "Keybinds", "Activation", "RAlt")
            settings["Up"] := IniRead(settingsPath, "Keybinds", "Up", "w")
            settings["Down"] := IniRead(settingsPath, "Keybinds", "Down", "s")
            settings["Left"] := IniRead(settingsPath, "Keybinds", "Left", "a")
            settings["Right"] := IniRead(settingsPath, "Keybinds", "Right", "d")
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
settingsGui.Add("GroupBox", "w300 h100", "Movement Settings")
settingsGui.Add("Text", "xp+10 yp+20", "Movement Distance (pixels):")
distanceInput := settingsGui.Add("Edit", "w50", currentSettings["Distance"])
upDown1 := settingsGui.Add("UpDown", "Range1-100", currentSettings["Distance"])

settingsGui.Add("Text", "xp+0 y+10", "Movement Interval (ms):")
intervalInput := settingsGui.Add("Edit", "w50", currentSettings["Interval"])
upDown2 := settingsGui.Add("UpDown", "Range1-100", currentSettings["Interval"])

; Keybind Settings Group
settingsGui.Add("GroupBox", "x10 y+20 w300 h200", "Keybind Settings")
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
    
    ; Save settings to an INI file using full path
    settingsPath := A_ScriptDir "\settings.ini"
    
    try {
        ; Convert values to integers and then to strings
        distance := Integer(distanceInput.Value)
        interval := Integer(intervalInput.Value)
        
        ; Create INI content
        fileContent := "[Movement]`n"
        fileContent .= "Distance=" distance "`n"
        fileContent .= "Interval=" interval "`n"
        
        ; Add keybind settings
        fileContent .= "`n[Keybinds]`n"
        fileContent .= "Activation=" activationKeyInput.Value "`n"
        fileContent .= "Up=" upKeyInput.Value "`n"
        fileContent .= "Down=" downKeyInput.Value "`n"
        fileContent .= "Left=" leftKeyInput.Value "`n"
        fileContent .= "Right=" rightKeyInput.Value "`n"
        
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
