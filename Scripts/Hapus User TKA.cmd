@echo off
REM ======================================================================
REM Batch Script: Delete User 'TKA' and Log Out (Self-Elevating)
REM Description: Checks for Admin rights, deletes the specified user,
REM              and then forces a log out.
REM ======================================================================

:: ----------------------------------------------------------------------
:: 1. CHECK FOR ADMINISTRATOR PRIVILEGES (Self-Elevation)
:: This section checks if the script is running with elevated rights.
:: If not, it uses VBScript to re-launch itself with "Run as administrator".
:: ----------------------------------------------------------------------
:check_admin
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO --------------------------------------------------------
    ECHO ADMINISTRATOR RIGHTS REQUIRED!
    ECHO The script will now attempt to re-launch itself with elevated permissions.
    ECHO Please click 'Yes' on the User Account Control (UAC) prompt.
    ECHO --------------------------------------------------------

    REM Create a temporary VBScript file to perform the elevation
    SET "script=%~dpnx0"
    ECHO Set UAC = CreateObject^("Shell.Application"^)>"%temp%\getadmin.vbs"
    ECHO UAC.ShellExecute "%script%", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    EXIT /B
) ELSE (
    GOTO :main
)


:: ----------------------------------------------------------------------
:: 2. MAIN LOGIC: CONFIRMATION, DELETION, AND LOG OUT
:: This section executes only after the script has admin privileges.
:: ----------------------------------------------------------------------
:main
CLS
ECHO ########################################################
ECHO #        USER DELETION AND LOGOUT UTILITY              #
ECHO ########################################################
ECHO.
ECHO [STEP 1/2] Attempting to delete user: TKA...
NET USER TKA /DELETE

IF %ERRORLEVEL% EQU 0 (
    ECHO SUCCESS: User TKA was deleted (or did not exist).
) ELSE (
    ECHO WARNING: Failed to delete user TKA. Error code: %ERRORLEVEL%.
    ECHO The account might already be deleted or an error occurred. Continuing to log out.
)

ECHO.
ECHO [STEP 2/2] Deletion complete. Logging out current session...

:: Logout command
SHUTDOWN /L

:end
EXIT /B