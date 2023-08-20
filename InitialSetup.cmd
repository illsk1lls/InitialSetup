@ECHO OFF
::Request admin if not
>nul 2>&1 reg add hkcu\software\classes\.InitSetup\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul 2>&1 fltmc|| if "%f0%" neq "%~f0" (cd.>"%ProgramData%\runas.InitSetup" & start "%~n0" /high "%ProgramData%\runas.InitSetup" "%~f0" "%_:"=""%" & exit /b)
>nul 2>&1 reg delete hkcu\software\classes\.InitSetup\ /f &>nul 2>&1 del %ProgramData%\runas.InitSetup /f /q
::Enter local time zone on next line, (In cmd prompt, tzutil.exe /L will give you a list of available timezones, each zone is listed with 2 lines, the 2nd line without parenthesis of text only is what you want to put here in quotes.)
SET TZNAME="Eastern Standard Time"
::InitialSetup can be run two ways. Business and Non-Business. Add the letter B to the end of the filename for the business version, remove the B switch back. For example purposes only. Adapt to your needs. (Only The last letter of the name matters, the CMD script can be named anything.)
SET RUNMODE=%~n0
SET RUNMODE=%RUNMODE:~-1%
IF "%RUNMODE%"=="b" SET "RUNMODE=B"
IF "%RUNMODE%"=="B" (
TITLE Initial Setup for Business v1.1
) ELSE (
TITLE Initial Setup v1.1
)
CD /D %~dp0
IF NOT "%~f0" EQU "%ProgramData%\%~nx0" (
IF EXIST "%ProgramData%\InitialSetup" RD "%ProgramData%\InitialSetup" /S /Q>nul
MD "%ProgramData%\InitialSetup\Junkbin">nul
COPY /Y "%~f0" "%ProgramData%">nul
START "" "%ProgramData%\%~nx0"
EXIT /b
)
ECHO Checking System...
FOR /F "usebackq skip=2 tokens=3-4" %%i IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul`) DO set "ProductName=%%i %%j"
IF "%ProductName%"=="Windows 7" ECHO. & ECHO Windows 7 detected. & ECHO. & ECHO SYSTEM NOT SUPPORTED! & ECHO. & PAUSE & EXIT
::Win 11 Specific Fixes
POWERSHELL -nop -c "Get-WmiObject -Class Win32_OperatingSystem | Format-List -Property Caption" | find "Windows 11" > nul
IF %errorlevel% == 0 ECHO. & ECHO Windows 11 detected. Fixing File Explorer... & reg.exe ADD HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32 /t REG_SZ /d "" /f>nul & reg.exe ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v UseCompactMode /t REG_DWORD /d 1 /f>nul
::All machines get these settings
ECHO. & ECHO Disabling Device Encryption...
MANAGE-BDE -OFF C:>nul
ECHO. & ECHO Cleaning Up Windows Installation Files...
CLEANMGR /d c: /Autoclean
ECHO. & ECHO Enabling F8 Boot Menu...
BCDEDIT /SET {DEFAULT} BOOTMENUPOLICY LEGACY>nul
ECHO. & ECHO Enabling System Restore and Creating a Restore Point...
POWERSHELL -nop -c "Enable-ComputerRestore -Drive 'C:\'">nul
::SMBv1 Option Disabled by default, un-comment next 2 lines to enable
::ECHO. & ECHO Enabling SMBv1...
::POWERSHELL -nop -c "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart"; "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client -NoRestart"; "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart"; "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation -NoRestart">nul
ECHO. & ECHO Setting Power Options...
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
powercfg /hibernate off
powercfg /setACvalueIndex scheme_current sub_buttons lidAction 0
powercfg /setDCvalueIndex scheme_current sub_buttons lidAction 0
powercfg /setACvalueindex scheme_current sub_buttons a7066653-8d6c-40a8-910e-a1f54b84c7e5 0
powercfg /setDCvalueindex scheme_current sub_buttons a7066653-8d6c-40a8-910e-a1f54b84c7e5 0
powercfg /setACvalueindex scheme_current sub_buttons PBUTTONACTION 3
powercfg /setDCvalueindex scheme_current sub_buttons PBUTTONACTION 3
powercfg /setACvalueindex scheme_current sub_buttons SBUTTONACTION 0
powercfg /setDCvalueindex scheme_current sub_buttons SBUTTONACTION 0
powercfg /setACvalueindex scheme_current sub_pciexpress ASPM 0
powercfg /setDCvalueindex scheme_current sub_pciexpress ASPM 0
powercfg /setACvalueindex scheme_current 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
powercfg /setDCvalueindex scheme_current 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
powercfg /setACvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setDCvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setActive scheme_current
ECHO. & ECHO Disabling UAC...
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f>nul
ECHO. & ECHO Enabling Automatic Registry Backups...
reg.exe ADD "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Configuration Manager" /v EnablePeriodicBackup /t REG_DWORD /d 1 /f>nul
ECHO. & ECHO Showing Hidden Files...
reg.exe ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f>nul
ECHO. & ECHO Making File Extenstions Visible...
reg.exe ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f>nul
ECHO. & ECHO Setting Time Zone...
tzutil /s %TZNAME%
PING -n 1 "google.com" | findstr /r /c:"[0-9] *ms">nul
IF NOT %errorlevel% == 0 ECHO. & ECHO Internet connection not detected! & ECHO. & RD "%ProgramData%\InitialSetup" /S /Q>nul & PAUSE & (GOTO) 2>nul & del "%~f0">nul & EXIT
ECHO. & ECHO Updating Time and Date...
w32tm /config /manualpeerlist:time.windows.com>nul
>nul 2>&1 NET STOP w32time
reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters /v Type /t REG_SZ /d NTP /f>nul
sc config w32time start= demand>nul
>nul 2>&1 NET START w32time
w32tm /resync>nul
ECHO. & ECHO Enabling Network Discovery...
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes>nul
ECHO. & ECHO Enabling File and Printer Sharing...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes>nul
ECHO. & ECHO Running Windows Update...
wuauclt /resetauthorization /detectnow /updatenow
ECHO. & ECHO Preparing for Software Downloads...
PUSHD "%ProgramData%\InitialSetup" & PUSHD "%ProgramData%\InitialSetup\Junkbin"
POWERSHELL -nop -c "Invoke-WebRequest -Uri https://www.7-zip.org/a/7zr.exe -o '7zr.exe'"; "Invoke-WebRequest -Uri https://www.7-zip.org/a/7z2300-extra.7z -o '7zExtra.7z'"; "Invoke-WebRequest -Uri https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip -o 'Aria2c.zip'"
7zr.exe e -y 7zExtra.7z>nul & 7za.exe e Aria2c.zip Aria2c.exe -r>nul
MOVE 7za.* ..>nul & MOVE Aria2c.exe ..>nul & POPD
ECHO. & ECHO Starting 7-Zip Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://www.7-zip.org/a/7z2300-x64.exe
ECHO. & ECHO Installing 7-Zip...
START /WAIT "" "%ProgramData%\InitialSetup\7z2300-x64.exe" /S
ECHO. & ECHO Complete!
ECHO. & ECHO Starting Chrome Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B01BE02E1-8E3F-B3BD-885C-6A7E4415E17F%7D%26lang%3Den%26browser%3D5%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip
"%ProgramData%\InitialSetup\7za.exe" e "%ProgramData%\InitialSetup\GoogleChromeEnterpriseBundle64.zip" GoogleChromeStandaloneEnterprise64.msi -r>nul
DEL "%ProgramData%\InitialSetup\GoogleChromeEnterpriseBundle64.zip" /F /Q>nul
ECHO. & ECHO Installing Chrome...
START /WAIT "" "%ProgramData%\InitialSetup\GoogleChromeStandaloneEnterprise64.msi" /qn /norestart
ECHO. & ECHO Complete!
ECHO. & ECHO Starting Adobe Reader Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2000920063/AcroRdrDC2000920063_en_US.exe
ECHO. & ECHO Installing Adobe Reader...
START /WAIT "" "%ProgramData%\InitialSetup\AcroRdrDC2000920063_en_US.exe" /sAll /rs /msi EULA_ACCEPT=YES
ECHO. & ECHO Complete!
ECHO. & ECHO Starting ADWCleaner Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://adwcleaner.malwarebytes.com/adwcleaner?channel=release -o adwcleaner.exe
ECHO. & ECHO Running ADWCleaner...
START /WAIT "" "%ProgramData%\InitialSetup\adwcleaner.exe" /eula /clean /noreboot /preinstalled
ECHO. & ECHO Complete!
IF NOT "%RUNMODE%"=="B" (
::Non-Business Example Section
ECHO. & ECHO Starting Malwarebytes Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://www.malwarebytes.com/api/downloads/mb-windows?filename=MBSetup.exe
ECHO. & ECHO Installing Malwarebytes...
START /WAIT "" "%ProgramData%\InitialSetup\MBSetup.exe" /verysilent /norestart
ECHO. & ECHO Complete!
ECHO. & ECHO Starting VLC Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://mirror.clarkson.edu/videolan/vlc/3.0.18/win64/vlc-3.0.18-win64.exe
ECHO. & ECHO Installing VLC...
START /WAIT "" "%ProgramData%\InitialSetup\vlc-3.0.18-win64.exe" /S
ECHO. & ECHO Complete!
)
IF "%RUNMODE%"=="B" (
::Business Example Section
ECHO. & ECHO Starting GoToAssist Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://fastsupport.gotoassist.com/download/unattendedDownloadAuto -o g2ax_unattended.exe
ECHO. & ECHO Installing GoToAssist Unattended...
START /WAIT "" "%ProgramData%\InitialSetup\g2ax_unattended.exe"
ECHO. & ECHO Complete!
START https://us.cloudcare.avg.com/#/
)
POPD & RD "%ProgramData%\InitialSetup" /S /Q>nul & (GOTO) 2>nul & del "%~f0">nul & EXIT