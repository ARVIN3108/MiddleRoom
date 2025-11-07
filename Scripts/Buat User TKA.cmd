@echo off
REM ====================================================================
REM BATCH SCRIPT: User Creation and Administrator Elevation
REM This script creates a new local user 'TKA' and adds them to the
REM local 'Administrators' group.
REM
REM WARNING: Creating new admin accounts should only be done for legitimate
REM system administration purposes and requires extreme caution.
REM Please change the placeholder password immediately after execution.
REM ====================================================================

setlocal

:: --- 1. ELEVATION CHECK (MANDATORY) --------------------------------
:: Check if the script is running with administrative privileges.
:: The 'net session' command will only succeed (ErrorLevel 0) if elevated.
net session >nul 2>&1

if %errorlevel% equ 0 (
    goto :Admin_Commands
) else (
    goto :Elevate_Script
)

:: --- 2. SELF-ELEVATION ROUTINE --------------------------------------
:Elevate_Script
    echo.
    echo -----------------------------------------------------------------
    echo WARNING: Administrative privileges are required.
    echo Requesting User Account Control (UAC) prompt to relaunch script...
    echo -----------------------------------------------------------------
    echo.

    :: This small PowerShell snippet executes the current batch file (%~fs0)
    :: with the 'RunAs' verb, forcing the UAC prompt.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~fs0' -Verb RunAs"

    endlocal
    exit /b


:: --- 3. ADMINISTRATIVE COMMANDS -------------------------------------
:Admin_Commands
    echo.
    echo Running with Administrator privileges...

    set "USERNAME=TKA"
    :: IMPORTANT: Replace "P@$$wOrd1234!" with a unique, strong password immediately.
    set "PASSWORD=P@$$wOrd1234!"
    set "ADMIN_GROUP=Administrators"

    echo -----------------------------------------------------------------
    echo 1. Creating user '%USERNAME%'...
    net user "%USERNAME%" "%PASSWORD%" /add /y

    if not errorlevel 0 (
        echo ERROR: Failed to create user '%USERNAME%'. Exiting.
        goto :eof
    )

    echo -----------------------------------------------------------------
    echo 2. Setting account expiration to 'never' and checking status...
    wmic useraccount where "name='%USERNAME%'" set passwordExpires=FALSE

    echo -----------------------------------------------------------------
    echo 3. Adding user '%USERNAME%' to local group '%ADMIN_GROUP%'...
    net localgroup "%ADMIN_GROUP%" "%USERNAME%" /add

    if not errorlevel 0 (
        echo ERROR: Failed to add user '%USERNAME%' to '%ADMIN_GROUP%'.
    ) else (
        echo SUCCESS: User '%USERNAME%' has been created and is now a local administrator.
        echo.
        echo ACTION REQUIRED: Please change the temporary password immediately.
    )

    echo -----------------------------------------------------------------
    REM --- NEW LOGOUT STEPS ADDED BELOW ---
    echo 4. Logging off current user...
    
    :: /l = Log off the current user
    :: /f = Force running applications to close without warning
    shutdown /l /f

    endlocal
    REM No pause needed, as shutdown /l is immediate.
    exit /b