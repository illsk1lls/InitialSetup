@ECHO OFF
>nul 2>&1 reg add hkcu\software\classes\.InitSetup\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul 2>&1 fltmc|| if "%f0%" neq "%~f0" (cd.>"%ProgramData%\runas.InitSetup" & start "%~n0" /high "%ProgramData%\runas.InitSetup" "%~f0" "%_:"=""%" & exit /b)
>nul 2>&1 reg delete hkcu\software\classes\.InitSetup\ /f &>nul 2>&1 del %ProgramData%\runas.InitSetup /f /q
ECHO Starting Downloads...
BITSADMIN /transfer "7-Zip" /download /priority FOREGROUND "https://www.7-zip.org/a/7z2300-x64.exe" "%~dp07z2300-x64.exe"
ECHO. & ECHO Installing 7-Zip...
START /WAIT "" "%~dp07z2300-x64.exe" /S>nul
DEL "%~dp07z2300-x64.exe" /F /Q>nul
BITSADMIN /transfer "Google Chrome" /download /priority FOREGROUND "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B01BE02E1-8E3F-B3BD-885C-6A7E4415E17F%7D%26lang%3Den%26browser%3D5%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip" "%~dp0GoogleChromeEnterpriseBundle64.zip"
"C:\Program Files\7-Zip\7z.exe" e "%~dp0GoogleChromeEnterpriseBundle64.zip" GoogleChromeStandaloneEnterprise64.msi -r>nul
DEL "%~dp0GoogleChromeEnterpriseBundle64.zip" /F /Q>nul
ECHO. & ECHO Installing Google Chrome...
START /WAIT "" "%~dp0GoogleChromeStandaloneEnterprise64.msi" /qn /norestart>nul
DEL "%~dp0GoogleChromeStandaloneEnterprise64.msi" /F /Q>nul
BITSADMIN /transfer "ADW Cleaner" /download /priority FOREGROUND "https://adwcleaner.malwarebytes.com/adwcleaner?channel=release" "%~dp0ADWCleaner.exe"
ECHO. & ECHO Installing ADW Cleaner...
START /WAIT "" "%~dp0ADWCleaner.exe" /eula /clean /noreboot /preinstalled>nul
DEL "%~dp0ADWCleaner.exe" /F /Q>nul
BITSADMIN /transfer "VLC" /download /priority FOREGROUND "https://mirror.clarkson.edu/videolan/vlc/3.0.18/win64/vlc-3.0.18-win64.exe" "%~dp0vlc-3.0.18-win64.exe"
ECHO. & ECHO Installing VLC...
START /WAIT "" "%~dp0vlc-3.0.18-win64.exe" /S
DEL "%~dp0vlc-3.0.18-win64.exe" /F /Q>nul
BITSADMIN /transfer "Adobe Reader DC" /download /priority FOREGROUND "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2000920063/AcroRdrDC2000920063_en_US.exe" "%~dp0AcroRdrDC2000920063_en_US.exe"
ECHO. & ECHO Installing Adobe Reader DC...
START /WAIT "" "%~dp0AcroRdrDC2000920063_en_US.exe" /sAll /rs /msi EULA_ACCEPT=YES
DEL "%~dp0AcroRdrDC2000920063_en_US.exe" /F /Q>nul