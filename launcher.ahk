#Requires AutoHotkey v2.0
#SingleInstance Force

; Create tray menu
A_TrayMenu.Delete() ; Clear default menu
A_TrayMenu.Add("Settings", ShowSettings)
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Start the mouse control script
Run(A_ScriptDir "\scripts\move-mouse.exe")

ShowSettings(*) {
    Run(A_ScriptDir "\scripts\move-mouse-settings.exe")
}