@echo off

:intro
color F4
    mode 33,35
    setlocal ENABLEDELAYEDEXPANSION
    Title Batch Based Task Manager
	
:Begin
    PUSHD
    CD /D "!TEMP!"
    set "TASKLIST=%windir%\\system32\tasklist.exe"
    set "FIND=%windir%\\system32\\find.exe"
    set "wmic=%windir%\\System32\\wbem\\wmic.exe"
    set "Explore=%windir%\\explorer.exe"

:Reload
    cls
    set num=0
    echo.---------------------------------
    echo.[ Process Name ]          [ PID ]
    echo.---------------------------------
    if not defined NAME set NAME=%USERNAME%
    !TASKLIST! /FI "USERNAME eq !NAME!" /FO TABLE /NH >"plist.txt"
    for /f "tokens=*" %%a in (plist.txt) do (
        set /a num+=1
        set "list=%%a"
        set "list=!list:~0,32!"
        echo.!list!
)
    Del /f /q "plist.txt" >nul 2>&1
echo.
    echo.---------------------------------
    echo.!NAME! - [!num!] Process Running      
    echo.---------------------------------
echo.
    if not defined ac (
        if /i "!NAME!"=="%USERNAME%" goto :USR
        if /i "!NAME!"=="SYSTEM" goto :SYS
    )
    if /i "!ac!"=="K" goto :Kill
    if /i "!ac!"=="S" goto :SYSTEM
    if /i "!ac!"=="U" goto :USER
    if /i "!ac!"=="E" goto :Explore
    set "ac="
    GOTO :Reload

:USER
    set "NAME="
    set "ac="
    GOTO :Reload
    :USR
    echo.Options: 
    echo.    K=Kill, S=System, E=Explore
    set /p "ac=Manage : "
    GOTO :Reload

:SYSTEM
    set NAME=SYSTEM
    set "ac="
    GOTO :Reload
    :SYS
    echo.Options: 
    echo.    K=Kill, U=User, E=Explore
    set /p "ac=Manage : "
    GOTO :Reload

:Kill
    echo.Type PID to Kill..
    set /p "PID=PID : "
    if not defined PID goto :Reload
    Taskkill /F /PID !PID! >nul 2>&1
    if errorlevel 1 (echo.No Task Running w/ this PID.) else (
    if !PID! geq 0 if !PID! lss 10 (
        echo.Can't kill Critical Process
        goto :clr_var2
    ) else (
        echo.Success : Task with PID=!PID!
        echo.          has been KILLED..
    ))
    :clr_var2
    set "ac="
    set "PID="
    PAUSE>NUL
    GOTO :Reload

:Explore
    echo.Type PID to Explore..
    set /p "PID=PID : "
    if not defined PID goto :Reload
    if !PID! lss 10 goto :clr_var
    if !PID! gtr 10000 goto :clr_var
    !wmic! process get ProcessID,ExecutablePath >"path.txt"
    for /f "tokens=1,2 delims=    " %%a in ('type "path.txt" ^| !FIND! " !PID! "') do (
        set "exepath=%%~dpa"
    )
    if not defined exepath (
        echo.No Task Running w/ this PID.
        PAUSE>NUL
    ) else (!Explore! "!exepath!")
    set "ac="
    :clr_var
    set "PID="
    set "exepath="
    Del /f /q "path.txt" >nul 2>&1
    GOTO :Reload

:END
