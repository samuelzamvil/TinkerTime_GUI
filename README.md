# TinkerTime_GUI
TinkerTime GUI is an application built on Windows Forms. Used to modify and reset time based on user selection.
Release 1/22/20

## Usage
Download executable or run .ps1 file directly commenting out lines 38 and 44

## Build
Use PS2GUI application to build TinkerTime.exe. The name of the application is hard coded on line 38 which extracts the icon used when compiling the application with PS2EXE. To use the default icon, comment out lines 38 and 44.

## Considerations
This application disables and resets Windows Automatic Time Syncronization(NTP). To reenable this feature use the "Resync Time" button or
go to: Settings > Time & Language > Set Time Automatically
Please note  your computer may require a reboot to accurately show the settings change.

This program was written and tested on Windows 10 ver. 1809

Certificate Thumbprint
9D58F72EFD8AE922829BB492F931348FA9537110
