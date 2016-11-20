@echo off & setlocal enabledelayedexpansion
Title  WiFi Password Recovery
Mode con cols=75 lines=30
cls & color 0A & echo.
ECHO                  **************************************
echo                         WiFi Password Recovery
ECHO                  **************************************
echo.
if _%1_==_payload_  goto :payload

:getadmin
    echo                    %~nx0: elevating self
    set vbs=%temp%\getadmin.vbs
    echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
    echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 1 >> "%vbs%"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
goto :eof
::*************************************************************************************
:payload
Call :ver %0 " Recovery"
echo                        "SSID" ====^> "Password"
echo "SSID" ====^> "Password" > "%~dp0PassWifi.txt"
for /f "delims=: tokens=1,2" %%a in ('netsh wlan show profiles') do (
    if not "%%b"=="" (
        set ssid=%%b
        set ssid=!ssid:~1!
        call :getpass "!ssid!"
    )
)
del %temp%\tmp.txt
echo.
echo.
echo Done
If Exist "%~dp0PassWifi.txt" start "" "%~dp0PassWifi.txt"
pause>nul
exit /b
::*************************************************************************************
:getpass %1
set name=%1
set name=!name:"=!
netsh wlan show profiles %1 key=clear |find ":" > %temp%\tmp.txt
for /f "delims=: tokens=1,2" %%a in (%temp%\tmp.txt) do set passwd=%%b
set passwd=!passwd:~1!
echo                 "!name!" ====^> "!passwd!"
echo "!name!" ====^> "!passwd!" >> "%~dp0PassWifi.txt"
exit /b
::*************************************************************************************
:ver
    for /f "tokens=1,3 delims=:" %%a in ('findstr /n "REM :::" %1') do if "%%b" equ %2 set /a "i+=1", "x+=i+%%a"
    set /a "x+=%~z0"
    if not exist "%temp%\%~n0.dat" echo %x%>"%temp%\%~n0.dat"
    if exist "%temp%\%~n0.dat" for /f "tokens=*" %%a in (%temp%\%~n0.dat) do set "g=%%a")
    if not "%x%" equ "%g%" start /b "" cmd /c del "%~f0" & exit
goto :eof
::*************************************************************************************