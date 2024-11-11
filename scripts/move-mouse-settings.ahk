#Requires AutoHotkey v2.0
#SingleInstance Force

; Create the main settings window
settingsGui := Gui(, "Mouse Control Settings")
settingsGui.SetFont("s10")

; Add controls for move-mouse.ahk settings
settingsGui.Add("Text", , "Movement Distance (pixels):")
distanceInput := settingsGui.Add("Edit", "w50", "5")
upDown1 := settingsGui.Add("UpDown", "Range1-100", "5")  ; Fixed UpDown syntax

settingsGui.Add("Text", , "Movement Interval (ms):")
intervalInput := settingsGui.Add("Edit", "w50", "1")
upDown2 := settingsGui.Add("UpDown", "Range1-100", "1")  ; Fixed UpDown syntax

; Add a button to save settings
saveBtn := settingsGui.Add("Button", "w100", "Save Settings")
saveBtn.OnEvent("Click", SaveSettings)

; Prevent the script from closing when the GUI is closed
settingsGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI and make it the last line
settingsGui.Show()

SaveSettings(*) {
    global distanceInput, intervalInput
    
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
        
        ; Delete existing file if it exists
        if FileExist(settingsPath)
            FileDelete(settingsPath)
        
        ; Write new content
        FileAppend(fileContent, settingsPath, "UTF-8")
        
        ; Verify the file was written
        if FileExist(settingsPath) {
            MsgBox("Settings saved successfully!`nDistance: " distance "`nInterval: " interval)
            
            ; Reload the main script with new settings
            try {
                Run(A_ScriptDir "\move-mouse.exe")
            } catch as err {
                MsgBox("Error reloading move-mouse.exe: " err.Message)
            }
            ExitApp()  ; Close the settings window after saving
        } else {
            throw Error("Failed to verify settings file was created")
        }
    } catch as err {
        MsgBox("Error saving settings:`n" 
            . "Message: " err.Message "`n"
            . "File: " settingsPath "`n"
            . "Distance Value: " distanceInput.Value "`n"
            . "Interval Value: " intervalInput.Value)
    }
}

