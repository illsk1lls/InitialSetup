# InitialSetup.cmd and InitialSetupB.cmd, for Win8-11

This is an example CMD script that can be adapted to suit your needs. 

It is possible to run this CMD script from a USB and remove the USB while it is running, when launched it copies itself into %ProgramData% and runs that, when completed it deletes its temporary version. The file you actually click runs for only a second or so and closes, so you won't get stuck on a slow workstation or have to copy the script every time before you use it.

This template can be run on new machines to adjust some commonly changed settings quickly.
Business and Non-Business example sections are present.

Actions the script performs in this example state:

(Win 11 Only for these -> Fixed right-click menu, reduced spacing between lines in explorer)

Disables Device Encryption
Cleans up leftover Windows Installation Files
Enables F8 Boot Menu
Enables System Restore and Creates a restore point.
Sets power options to highest performance (usb selective suspend off/pci link state mgmt off/never sleep/hibernate off/etc)
Disables UAC
Show Hidden Files in File Explorer
Show File Extensions in File Explorer
Set's TimeZone (User Enters at top of script, currently set to "Eastern Standard Time")
Set's Correct Date and Time
Enables Network Discovery
Enables File and Printer Sharing
Initiates Windows Update in the background
---Software Downloaded/Installed---

--ALL--
7zip
Chrome
Adobe Reader (Without bloat)
ADWCleaner

--NON-BUSINESS--
Malwarebytes
VLC

BUSINESS--
GotoAssist
Open Webpage for Avast Business AV

-----

Pretty basic but something this simple can save a bunch of time. ;)
