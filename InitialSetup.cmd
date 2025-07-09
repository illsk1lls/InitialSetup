@ECHO OFF
REM Allow only one instance at a time
TASKLIST /V /NH /FI "imagename eq cmd.exe"|FINDSTR /I /C:"Initial Setup">nul
IF NOT %errorlevel%==1 (
	POWERSHELL -nop -c "$^={$Notify=[PowerShell]::Create().AddScript({$Audio=New-Object System.Media.SoundPlayer;$Audio.SoundLocation=$env:WinDir + '\Media\Windows Notify System Generic.wav';$Audio.playsync()});$rs=[RunspaceFactory]::CreateRunspace();$rs.ApartmentState="^""STA"^"";$rs.ThreadOptions="^""ReuseThread"^"";$rs.Open();$Notify.Runspace=$rs;$Notify.BeginInvoke()};&$^;$PopUp=New-Object -ComObject Wscript.Shell;$PopUp.Popup("^""Initial Setup is already running!"^"",0,'ERROR:',0x10)">nul&EXIT
)
TITLE Initial Setup - Mode Selection
REM Copy self to %ProgramData% and request RunAsAdmin
IF /I NOT "%~dp0" == "%ProgramData%\" (
	>nul 2>&1 REG ADD HKCU\Software\classes\.InitialSetup\shell\runas\command /f /ve /d "CMD /x /d /r SET \"f0=1\"&CALL \"%%2\" %%3"
	CD.>"%ProgramData%\launcher.InitialSetup"
	>nul 2>&1 COPY /Y "%~f0" "%ProgramData%"
	>nul 2>&1 FLTMC && (
		TITLE Re-Launching...
		CALL :SETTERMINAL
		START "" "%ProgramData%\launcher.InitialSetup" "%ProgramData%\%~nx0"
		CALL :RESTORETERMINAL
		>nul 2>&1 REG DELETE HKCU\Software\classes\.InitialSetup\ /F
		>nul 2>&1 DEL "%ProgramData%\launcher.InitialSetup" /F /Q
		EXIT /b
	) || IF NOT "%f0%"=="1" (
		TITLE Re-Launching...
		CALL :SETTERMINAL
		START "" /high "%ProgramData%\launcher.InitialSetup" "%ProgramData%\%~nx0"
		CALL :RESTORETERMINAL
		>nul 2>&1 REG DELETE HKCU\Software\classes\.InitialSetup\ /F
		>nul 2>&1 DEL "%ProgramData%\launcher.InitialSetup" /F /Q
		EXIT /b
	)
)
REM Script stops here if admin request is declined
CALL :CENTERWINDOW
REM InitialSetup can be run two ways. Use the GUI to select Normal or Business modes (For example purposes only, use this template to suit your needs)
ECHO USE THE GUI TO BEGIN
FOR /F "usebackq tokens=*" %%# IN (`POWERSHELL -nop -c "Add-Type -AssemblyName System.Windows.Forms;$f = New-Object System.Windows.Forms.Form;$f.ClientSize='220,130';$f.BackColor='#AAAAAA';$f.FormBorderStyle='none';$f.TopMost='true';$tz = New-Object System.Windows.Forms.ComboBox;$tz.Width=164;$tz.AutoSize=$true;$tzList = (tzutil /l | Where-Object {$_ -match '^\s*[^\(]'} | ForEach-Object {$_ -replace '^\s*',''});$tzList | ForEach-Object {[void] $tz.Items.Add($_)};$currentTZ = (tzutil /g);$tz.SelectedIndex = $tzList.IndexOf($currentTZ);if ($tz.SelectedIndex -eq -1) {$tz.SelectedIndex = 0};$tz.DropDownStyle='DropDownList';$tz.Location=New-Object System.Drawing.Point(28,55);$m = New-Object System.Windows.Forms.ComboBox;$m.Width=114;$m.AutoSize=$true;@('Normal Mode','Business Mode') | ForEach-Object {[void] $m.Items.Add($_)};$m.SelectedIndex=0;$m.DropDownStyle='DropDownList';$m.Location=New-Object System.Drawing.Point(53,19);$g = New-Object System.Windows.Forms.Button;$g.Location=New-Object System.Drawing.Size(28,90);$g.Size=New-Object System.Drawing.Size(40,22);$g.Text='Go';$g.Add_Click({$f.Close();Write-Host ($tz.SelectedItem + '|' + $m.SelectedIndex)});$q = New-Object System.Windows.Forms.Button;$q.Location=New-Object System.Drawing.Size(150,90);$q.Size=New-Object System.Drawing.Size(40,22);$q.Text='Exit';$q.Add_Click({$f.Close();Write-Host 'EXIT|2'});$f.Controls.Add($g);$f.Controls.Add($q);$f.Controls.Add($tz);$f.Controls.Add($m);$f.StartPosition=[System.Windows.Forms.FormStartPosition]::CenterScreen;[void]$f.ShowDialog()"`) DO (
    SET "GUI_OUTPUT=%%#"
	SETLOCAL ENABLEDELAYEDEXPANSION
    FOR /F "tokens=1,2 delims=|" %%A IN ("!GUI_OUTPUT!") DO (
		ENDLOCAL
        SET TZNAME="%%A"
        SET /A "RUNMODE=%%B"
    )
    CLS
)
IF "%RUNMODE%"=="2" (
	CALL :CLEANUPANDEXIT
)
IF "%RUNMODE%"=="1" (
	TITLE Initial Setup for Business v1.2
) ELSE (
	TITLE Initial Setup v1.2
)
IF EXIST "%ProgramData%\InitialSetup" (
	RD "%ProgramData%\InitialSetup" /S /Q>nul
)
MD "%ProgramData%\InitialSetup\Junkbin">nul
ECHO Checking System...
FOR /F "usebackq skip=2 tokens=3-4" %%i IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul`) DO (
	SET "ProductName=%%i %%j"
)
IF /I "%ProductName%"=="Windows 7" (
	ECHO/
	ECHO Windows 7 detected.
	ECHO/
	ECHO SYSTEM NOT SUPPORTED!
	ECHO/
	PAUSE
	EXIT
)
REM Win 11 Specific Fixes
POWERSHELL -nop -c "Get-WmiObject -Class Win32_OperatingSystem | Format-List -Property Caption" | find "Windows 11" > nul
IF %errorlevel% == 0 (
	ECHO/
	ECHO Windows 11 detected. Fixing File Explorer...
	REG.EXE ADD HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32 /t REG_SZ /d "" /f>nul
	REG.EXE ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v UseCompactMode /t REG_DWORD /d 1 /f>nul
)
REM All machines get these settings
ECHO/
ECHO Disabling Device Encryption...
MANAGE-BDE -OFF C:>nul
ECHO/
ECHO Cleaning Up Windows Installation Files...
CLEANMGR /d c: /Autoclean
ECHO/
ECHO Enabling F8 Boot Menu...
BCDEDIT /SET {DEFAULT} BOOTMENUPOLICY LEGACY>nul
ECHO/
ECHO Enabling System Restore and Creating a Restore Point...
POWERSHELL -nop -c "Enable-ComputerRestore -Drive 'C:\'">nul
ECHO/
ECHO Setting Power Options...
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
ECHO/
ECHO Disabling UAC...
REG.EXE ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f>nul
ECHO/
ECHO Disabling Edge Bar...
REG.EXE ADD HKLM\SOFTWARE\Policies\Microsoft\Edge /v WebWidgetAllowed /t REG_DWORD /d 0 /f>nul
ECHO/
ECHO Enabling Automatic Registry Backups...
REG.EXE ADD "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Configuration Manager" /v EnablePeriodicBackup /t REG_DWORD /d 1 /f>nul
ECHO/
ECHO Showing Hidden Files...
REG.EXE ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f>nul
ECHO/
ECHO Making File Extenstions Visible...
REG.EXE ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f>nul
ECHO/
ECHO Setting Time Zone...
TZUTIL /s %TZNAME%
CALL :CHECKCONNECTION ONLINE
SETLOCAL ENABLEDELAYEDEXPANSION
IF !ONLINE! NEQ 1 (
	ENDLOCAL
	ECHO/
	ECHO Internet connection not detected!
	ECHO/
	PAUSE
	CALL :CLEANUPANDEXIT
)
ENDLOCAL
ECHO/
ECHO Updating Time and Date...
W32TM /config /manualpeerlist:time.windows.com>nul
>nul 2>&1 NET STOP w32time
REG.EXE ADD HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters /v Type /t REG_SZ /d NTP /f>nul
SC config w32time start= demand>nul
>nul 2>&1 NET START w32time
W32TM /resync>nul
ECHO/
ECHO Enabling Network Discovery...
NETSH advfirewall firewall set rule group="Network Discovery" new enable=Yes>nul
ECHO/
ECHO Enabling File and Printer Sharing...
NETSH advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes>nul
ECHO/
ECHO Running Windows Update...
WUAUCLT /resetauthorization /detectnow /updatenow
ECHO/
ECHO Preparing for Software Downloads...
PUSHD "%ProgramData%\InitialSetup"
PUSHD "%ProgramData%\InitialSetup\Junkbin"
POWERSHELL -nop -c "Invoke-WebRequest -Uri https://www.7-zip.org/a/7zr.exe -o '7zr.exe'"; "Invoke-WebRequest -Uri https://www.7-zip.org/a/7z2300-extra.7z -o '7zExtra.7z'"; "Invoke-WebRequest -Uri https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip -o 'Aria2c.zip'"
7zr.exe e -y 7zExtra.7z>nul
7za.exe e Aria2c.zip Aria2c.exe -r>nul
MOVE 7za.* ..>nul
MOVE Aria2c.exe ..>nul
POPD
ECHO/
ECHO Starting 7-Zip Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://www.7-zip.org/a/7z2300-x64.exe
ECHO/
ECHO Installing 7-Zip...
START /WAIT "" "%ProgramData%\InitialSetup\7z2300-x64.exe" /S
ECHO/
ECHO Complete!
ECHO/
ECHO Starting Chrome Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://dl.google.com/tag/s/appguid%%3D%%7B8A69D345-D564-463C-AFF1-A69D9E530F96%%7D%%26iid%%3D%%7B01BE02E1-8E3F-B3BD-885C-6A7E4415E17F%%7D%%26lang%%3Den%%26browser%%3D5%%26usagestats%%3D0%%26appname%%3DGoogle%%2520Chrome%%26needsadmin%%3Dtrue%%26ap%%3Dx64-stable-statsdef_0%%26brand%%3DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip
"%ProgramData%\InitialSetup\7za.exe" e "%ProgramData%\InitialSetup\GoogleChromeEnterpriseBundle64.zip" GoogleChromeStandaloneEnterprise64.msi -r>nul
DEL "%ProgramData%\InitialSetup\GoogleChromeEnterpriseBundle64.zip" /F /Q>nul
ECHO/
ECHO Installing Chrome...
START /WAIT "" "%ProgramData%\InitialSetup\GoogleChromeStandaloneEnterprise64.msi" /qn /norestart
ECHO/
ECHO Complete!
ECHO/
ECHO Starting Adobe Reader Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2000920063/AcroRdrDC2000920063_en_US.exe
ECHO/
ECHO Installing Adobe Reader...
START /WAIT "" "%ProgramData%\InitialSetup\AcroRdrDC2000920063_en_US.exe" /sAll /rs /msi EULA_ACCEPT=YES
ECHO/
ECHO Complete!
ECHO/
ECHO Starting ADWCleaner Download...
"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://adwcleaner.malwarebytes.com/adwcleaner?channel=release -o adwcleaner.exe
ECHO/
ECHO Running ADWCleaner...
START /WAIT "" "%ProgramData%\InitialSetup\adwcleaner.exe" /eula /clean /noreboot /preinstalled
ECHO/
ECHO Complete!
IF "%RUNMODE%"=="1" (
	REM Business Example Section
	ECHO/
	ECHO Starting GoToAssist Download...
	"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://fastsupport.gotoassist.com/download/unattendedDownloadAuto -o g2ax_unattended.exe
	ECHO/
	ECHO Installing GoToAssist Unattended...
	START /WAIT "" "%ProgramData%\InitialSetup\g2ax_unattended.exe"
	ECHO/
	ECHO Complete!
	START "" https://us.cloudcare.avg.com/#/
) ELSE (
	REM Non-Business Example Section
	ECHO/
	ECHO Starting Malwarebytes Download...
	"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://data-cdn.mbamupdates.com/web/mb5-setup-consumer/MBSetup.exe
	ECHO/
	ECHO Installing Malwarebytes...
	START /WAIT "" "%ProgramData%\InitialSetup\MBSetup.exe" /verysilent /norestart
	ECHO/
	ECHO Complete!
	ECHO/
	ECHO Starting VLC Download...
	"%ProgramData%\InitialSetup\aria2c.exe" --summary-interval=0 https://mirror.clarkson.edu/videolan/vlc/3.0.20/win64/vlc-3.0.20-win64.exe
	ECHO/
	ECHO Installing VLC...
	START /WAIT "" "%ProgramData%\InitialSetup\vlc-3.0.20-win64.exe" /S
	ECHO/
	ECHO Complete!
)
POPD 
CALL :CLEANUPANDEXIT

:SETTERMINAL
SET "LEGACY={B23D10C0-E52E-411E-9D5B-C09FDF709C7D}"
SET "LETWIN={00000000-0000-0000-0000-000000000000}"
SET "TERMINAL={2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
SET "TERMINAL2={E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
POWERSHELL -nop -c "Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption | Find 'Windows 11'">nul
IF ERRORLEVEL 0 (
	SET isEleven=1
	>nul 2>&1 REG QUERY "HKCU\Console\%%%%Startup" /v DelegationConsole
	IF ERRORLEVEL 1 (
		REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%LETWIN%" /f>nul
		REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%LETWIN%" /f>nul
	)
	FOR /F "usebackq tokens=3" %%# IN (`REG QUERY "HKCU\Console\%%%%Startup" /v DelegationConsole 2^>nul`) DO (
		IF NOT "%%#"=="%LEGACY%" (
			SET "DEFAULTCONSOLE=%%#"
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%LEGACY%" /f>nul
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%LEGACY%" /f>nul
		)
	)
)
FOR /F "usebackq tokens=3" %%# IN (`REG QUERY "HKCU\Console" /v ForceV2 2^>nul`) DO (
	IF NOT "%%#"=="0x1" (
		SET LEGACYTERM=0
		REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 1 /f>nul
	) ELSE (
		SET LEGACYTERM=1
	)
)
EXIT /b

:RESTORETERMINAL
IF "%isEleven%"=="1" (
	IF DEFINED DEFAULTCONSOLE (
		IF "%DEFAULTCONSOLE%"=="%TERMINAL%" (
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%TERMINAL%" /f>nul
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%TERMINAL2%" /f>nul
		) ELSE (
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%DEFAULTCONSOLE%" /f>nul
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%DEFAULTCONSOLE%" /f>nul
		)
	)
)
IF "%LEGACYTERM%"=="0" (
	REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 0 /f>nul
)
EXIT /b

:CENTERWINDOW
>nul 2>&1 POWERSHELL -nop -ep Bypass -c "$w=Add-Type -Name WAPI -PassThru -MemberDefinition '[DllImport(\"user32.dll\")]public static extern void SetProcessDPIAware();[DllImport(\"shcore.dll\")]public static extern void SetProcessDpiAwareness(int value);[DllImport(\"kernel32.dll\")]public static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")]public static extern void GetWindowRect(IntPtr hwnd, int[] rect);[DllImport(\"user32.dll\")]public static extern void GetClientRect(IntPtr hwnd, int[] rect);[DllImport(\"user32.dll\")]public static extern void GetMonitorInfoW(IntPtr hMonitor, int[] lpmi);[DllImport(\"user32.dll\")]public static extern IntPtr MonitorFromWindow(IntPtr hwnd, int dwFlags);[DllImport(\"user32.dll\")]public static extern int SetWindowPos(IntPtr hwnd, IntPtr hwndAfterZ, int x, int y, int w, int h, int flags);';$PROCESS_PER_MONITOR_DPI_AWARE=2;try {$w::SetProcessDpiAwareness($PROCESS_PER_MONITOR_DPI_AWARE)} catch {$w::SetProcessDPIAware()}$hwnd=$w::GetConsoleWindow();$moninf=[int[]]::new(10);$moninf[0]=40;$MONITOR_DEFAULTTONEAREST=2;$w::GetMonitorInfoW($w::MonitorFromWindow($hwnd, $MONITOR_DEFAULTTONEAREST), $moninf);$monwidth=$moninf[7] - $moninf[5];$monheight=$moninf[8] - $moninf[6];$wrect=[int[]]::new(4);$w::GetWindowRect($hwnd, $wrect);$winwidth=$wrect[2] - $wrect[0];$winheight=$wrect[3] - $wrect[1];$x=[int][math]::Round($moninf[5] + $monwidth / 2 - $winwidth / 2);$y=[int][math]::Round($moninf[6] + $monheight / 2 - $winheight / 2);$SWP_NOSIZE=0x0001;$SWP_NOZORDER=0x0004;exit [int]($w::SetWindowPos($hwnd, [IntPtr]::Zero, $x, $y, 0, 0, $SWP_NOSIZE -bOr $SWP_NOZORDER) -eq 0)"
EXIT /b

:CHECKCONNECTION
FOR /F "usebackq tokens=* delims=" %%# IN (`POWERSHELL -nop -c "$ProgressPreference='SilentlyContinue';irm http://www.msftncsi.com/ncsi.txt;$ProgressPreference='Continue'"`) DO (
	IF "%%#"=="Microsoft NCSI" (
		SET "%1=1"
	) ELSE (
		SET "%1=0"
	)
)
EXIT /b

:CLEANUPANDEXIT
RD "%ProgramData%\InitialSetup" /S /Q>nul
(GOTO) 2>nul&DEL "%~f0">nul&EXIT
EXIT /b
