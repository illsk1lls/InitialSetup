# InitialSetup.cmd and InitialSetupB.cmd, for Win8-11

If the CMD script is renamed to contain a "B" or "b" at the end of the filename it will switch actions from business/non-business (e.g InitialSetup.cmd and InitialSetupB.cmd)<br>

This is an example CMD script that can be adapted to suit your needs.<br>

It is possible to run this CMD script from a USB and remove the USB while it is running, when launched it copies itself into %ProgramData% and runs that, when completed it deletes its temporary version. The file you actually click runs for only a second or so and closes, so you won't get stuck on a slow workstation or have to copy the script every time before you use it.<br>

This template can be run on new machines to adjust some commonly changed settings quickly.<br>

Actions the script performs in this example state:<br>

(Win 11 Only for these -> Fixed right-click menu, reduced spacing between lines in explorer)<br>

Disables Device Encryption<br>
Cleans up leftover Windows Installation Files<br>
Enables F8 Boot Menu<br>
Enables System Restore and Creates a restore point.<br>
Sets power options to highest performance (usb selective suspend off/pci link state mgmt off/never sleep/hibernate off/etc)<br>
Disables UAC<br>
Show Hidden Files in File Explorer<br>
Show File Extensions in File Explorer<br>
Set's TimeZone (User Enters at top of script, currently set to "Eastern Standard Time")<br>
Set's Correct Date and Time<br>
Enables Network Discovery<br>
Enables File and Printer Sharing<br>
Initiates Windows Update in the background<br>

---Software Downloaded/Installed---<br>

--ALL--<br>
7zip<br>
Chrome<br>
Adobe Reader (Without bloat)<br>
ADWCleaner<br>

--NON-BUSINESS--<br>
Malwarebytes<br>
VLC<br>

--BUSINESS--<br>
GotoAssist<br>
Open Webpage for Avast Business AV<br>

-----<br>

Pretty basic but something this simple can save a bunch of time. ;)<br>
