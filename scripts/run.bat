@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==================================================================== #
REM  Name of the Python script to run (adjust as needed, or pass it     #
REM  as an argument: run.bat my_script.py)                              #
REM ==================================================================== #
if "%~1"=="" (
    set "PYTHON_SCRIPT=notebook.py"
) else (
    set "PYTHON_SCRIPT=%~1"
)

REM ==================================================================== #
REM  Find APPLICATION_HOME by walking up the directory tree             #
REM  until lib\bootstrap\bootstrap.py is found                          #
REM  (same mechanism as app-start.ps1 / app-start.sh)                   #
REM ==================================================================== #
set "CURRENT_DIR=%~dp0"
REM Remove trailing slash if present
if "%CURRENT_DIR:~-1%"=="\" set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

set "APPLICATION_HOME="

:FIND_APP_HOME
if exist "%CURRENT_DIR%\lib\bootstrap\bootstrap.py" (
    set "APPLICATION_HOME=%CURRENT_DIR%"
    goto :FOUND
)

REM Compute the parent directory
for %%I in ("%CURRENT_DIR%") do set "PARENT_DIR=%%~dpI"
REM Remove trailing slash from the parent
if "%PARENT_DIR:~-1%"=="\" set "PARENT_DIR=%PARENT_DIR:~0,-1%"

REM If the parent equals the current directory, we reached the drive root
if "%PARENT_DIR%"=="%CURRENT_DIR%" (
    echo [ERROR] Could not find lib\bootstrap\bootstrap.py while walking up from %~dp0
    exit /b 1
)

set "CURRENT_DIR=%PARENT_DIR%"
goto :FIND_APP_HOME

:FOUND
echo APPLICATION_HOME: %APPLICATION_HOME%

REM ==================================================================== #
REM  Paths derived from APPLICATION_HOME (EPY template layout)          #
REM ==================================================================== #
set "PS_SCRIPT=%APPLICATION_HOME%\scripts\powershell\app-start.ps1"
set "LOG_DIR=%APPLICATION_HOME%\log"
set "LOG_FILE=%LOG_DIR%\win_run_bat_%date:~-4%%date:~-7,2%%date:~-10,2%.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

if not exist "%PS_SCRIPT%" (
    echo [ERROR] PowerShell script not found: %PS_SCRIPT%
    exit /b 1
)

REM =================================================================== #
REM  Run                                                                #
REM  -> Start-Transcript keeps the process attached DIRECTLY            #
REM     to the console (unlike a pipe/Tee-Objects)                      #
REM     An existing prompt can now appears immediately.                 #
REM     The transcript still records a complete copy in the log file.   #
REM =================================================================== #
echo [%date% %time%] Starting - APPLICATION_HOME=%APPLICATION_HOME% - Script=%PYTHON_SCRIPT% >> "%LOG_FILE%"
echo ============================================================
echo  Lancement de %PYTHON_SCRIPT%
echo  Log complet : %LOG_FILE%
echo ============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Transcript -Path '%LOG_FILE%' -Append | Out-Null; & '%PS_SCRIPT%' '%PYTHON_SCRIPT%'; $ec = $LASTEXITCODE; Stop-Transcript | Out-Null; exit $ec"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo ============================================================
echo  Termine - code retour : %EXIT_CODE%
echo ============================================================
echo [%date% %time%] Done - exit code: %EXIT_CODE% >> "%LOG_FILE%"

endlocal
exit /b %EXIT_CODE%