## Quick Links

- [Overview](#overview)
- [Feature Comparison](#why-choose-this-over-built-in-microsoft-version)
- [Installation Guide](#installation-and-setup)
- [Usage Instructions](#how-it-works)
- [Configuration Options](#configuration-detailed-breakdown)
- [Known Issues](#known-issues-and-limitations)
- [Support](#support-and-contributions)

## Overview

Frustrated by constantly breaking my keyboard-centric workflow to reach for the mouse, I developed this AutoHotkey Mouse Control Suite as a superior alternative to Windows' limited Mouse Keys implementation. While Microsoft's accessibility tool offers basic numpad control with rigid settings and awkward diagonal movement, this suite provides _true keyboard-first navigation_ with fully customisable acceleration curves, **real 8-direction mouse control** and dedicated scroll/drag functions - all configurable through an intuitive GUI. By focusing on dynamic speed adjustments and providing the user to set their own key bindings, it transforms keyboard mouse control from a clunky accessibility fallback into a genuine productivity enhancer.

## Why Choose This Over Built-in Microsoft Version?

| Feature                        | Custom Script | Windows Mouse Keys | Notes                                                                                                 |
| ------------------------------ | ------------- | ------------------ | ----------------------------------------------------------------------------------------------------- |
| **Custom Key Bindings**        | ✅            | ❌                 | Custom Script: Full remapping of all controls<br>Windows: Fixed numpad bindings                       |
| **True Diagonal Movement**     | ✅            | ❌                 | Custom Script: Simultaneous keypresses for smooth diagonals<br>Windows: Sequential axis movement only |
| **Dynamic Speed Acceleration** | ✅            | ❌                 | Custom Script: Speed increases with keyhold duration<br>Windows: Fixed linear speed                   |
| **Left-Click Key**             | ✅            | ✅                 | Custom Script: Dedicated key binding<br>Windows: Numpad 5 with physical mouse button                  |
| **Right-Click Key**            | ✅            | ❌                 | Custom Script: Direct key binding<br>Windows: Requires menu interaction (Shift+F10)                   |
| **Drag & Hold**                | ✅            | ❌                 | Custom Script: Key-based drag support<br>Windows: Requires click-lock settings                        |
| **Vertical Scrolling**         | ✅            | ❌                 | Custom Script: Dedicated scroll keys<br>Windows: No native implementation                             |
| **Speed Adjustment**           | ✅            | ✅                 | Custom Script: Granular control (min/max/duration)<br>Windows: Single speed slider                    |
| **Portable Settings**          | ✅            | ❌                 | Custom Script: INI file configuration<br>Windows: System registry settings                            |
| **Numpad Independent**         | ✅            | ❌                 | Custom Script: Uses standard keyboard keys<br>Windows: Requires numpad                                |

## Installation and Setup

### Prerequisites

- Windows 10/11

### Steps

1. **Download**: Download the latest release from https://github.com/Sam-WebP/keyboard-mouse-control/releases
2. **Extract Files**: Extract all files from the downloaded archive to a directory of your choice.
3. **Run the Launcher**: Run `launcher.exe`, this will start the mouse control script.
4. **Configure Settings**:
   - Right-click the tray icon and select `Settings` to open the settings GUI.
   - Customise keybindings, movement settings, and other preferences as needed.
   - Click `Save Settings` to apply your changes.

> [!TIP]
> Have this script run automatically when your PC boots up by creating a shortcut of the `launcher.exe` and placing it within the folder that shows up after you press `windows key + r` and run `shell:startup`.

## How It Works

> [!NOTE]  
> All keys can be configured and rebound to whatever keys feel most comfortable to you.

- **Activation Key**: Press and hold the activation key (default `CapsLock`) to enable mouse control with your keyboard.
- **Activation Modes**:
  - _Hold Mode_ (Default): Keep activation key pressed to maintain mouse control
  - _Toggle Mode_: Press once to enable, press again to disable mouse control
- **Movement Keys**: Use `W`, `A`, `S`, `D` (or your configured keys) to move the mouse in the corresponding directions. Diagonal movements are supported with key combinations.
- **Mouse Buttons**: Use your configured keys for left (`J` by default) and right clicks (`K` by default).
- **Scrolling**: Use `I` and `O` (or your configured keys) for page up and page down.
- **Drag and Drop**: Hold the left mouse key (configured as `J` by default) to drag, and release to stop.

## Configuration: Detailed Breakdown

| Category         | Parameter            | Default Value | Description                                              | Notes & Recommendations                                                                                                                                                                                                                                                                              |
| ---------------- | -------------------- | ------------- | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Movement**     | Interval             | 1 ms          | Time between mouse position updates                      | • Keep at 1 for maximum responsiveness<br>• Increase if experiencing performance issues                                                                                                                                                                                                              |
| **Acceleration** | MinDistance          | 1 px          | Initial movement distance when pressing directional keys | • 1-10px recommended for precise control                                                                                                                                                                                                                                                             |
|                  | MaxDistance          | 30 px         | Maximum movement distance after full acceleration        | • 20-60px typical range<br>• 30-40px for 4K screens<br>• 15-25px for HD displays                                                                                                                                                                                                                     |
|                  | AccelerationDuration | 1000 ms       | Transition time from Min→Max distance                    | The `AccelerationDuration` value is particularly important for controlling your mouses acceleration curve. Set this value to `1` if you prefer a linear feel (not recommended since it makes small adjustments hard to control) or adjust this value up or down to suit your desired ramp up speeds. |
| **Keybindings**  | Activation           | CapsLock      | Modifier key enabling mouse controls                     | Hold to activate mouse functionality from script                                                                                                                                                                                                                                                     |
|                  | ActivationMode       | Hold          | Toggle/Hold activation behaviour                         | • `Hold`: Requires holding activation key<br>• `Toggle`: Single press to enable/disable mouse mode                                                                                                                                                                                                   |
|                  | Movement Keys        | W/A/S/D       | Directional controls                                     | Homogeneous keyboard layout recommended                                                                                                                                                                                                                                                              |
|                  | LeftClick/RightClick | J/K           | Mouse button controls                                    | • Sticky drag support<br>• Hold to drag, release to drop                                                                                                                                                                                                                                             |
|                  | Scrolling Keys       | I/O           | Vertical scrolling controls                              | • PageUp (I): 3 wheel increments up<br>• PageDown (O): 3 wheel increments down                                                                                                                                                                                                                       |

### Built-In GUI

For easier configuration, the settings GUI provides a user-friendly interface which can be accessed by right clicking the program within the system tray. Changes take effect immediately after saving. Alternatively, you can manually edit the `settings.ini` file.

## Known Issues and Limitations

### 1. Taskbar Interaction Issues

**Current limitations:**

- Taskbar clicks may trigger drag actions
- Potential script crashes when clicking taskbar
- Occasional unregistered clicks

_Workaround:_ Use physical mouse for taskbar interactions until resolved.  
[Details and progress →](https://github.com/Sam-WebP/keyboard-mouse-control/issues/2)

### 2. Modifier Key Binding Limitations

AHK v2 restricts direct binding of:

- LShift/RShift
- LAlt/LCtrl/RCtrl
- LWin/RWin

_Workaround:_ Manually edit `settings.ini` and restart script.  
[Details and progress →](https://github.com/Sam-WebP/keyboard-mouse-control/issues/1)

> [!NOTE]
> Check the [GitHub Issues](https://github.com/Sam-WebP/keyboard-mouse-control/issues) to view all issues.

## Support and Contributions

Feel free to reach out, share feedback, or contribute to the project. Issues and pull requests are welcome!
