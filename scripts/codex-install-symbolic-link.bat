@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SOURCE_DIR=%SCRIPT_DIR%..\context-checkpoint"
set "TARGET_ROOT=%USERPROFILE%\.codex\skills"
set "TARGET_DIR=%TARGET_ROOT%\context-checkpoint"

if not exist "%SOURCE_DIR%\SKILL.md" (
    echo Source skill directory was not found: "%SOURCE_DIR%"
    set "EXIT_CODE=1"
    goto :ExitWithPause
)

if not exist "%TARGET_ROOT%" (
    mkdir "%TARGET_ROOT%"
    if errorlevel 1 (
        echo Failed to create Codex skills directory: "%TARGET_ROOT%"
        set "EXIT_CODE=1"
        goto :ExitWithPause
    )
)

if exist "%TARGET_DIR%\" (
    rmdir /s /q "%TARGET_DIR%"
    if errorlevel 1 (
        echo Failed to remove existing Codex skill directory: "%TARGET_DIR%"
        set "EXIT_CODE=1"
        goto :ExitWithPause
    )
) else if exist "%TARGET_DIR%" (
    del /f /q "%TARGET_DIR%"
    if errorlevel 1 (
        echo Failed to remove existing Codex skill file: "%TARGET_DIR%"
        set "EXIT_CODE=1"
        goto :ExitWithPause
    )
)

mklink /D "%TARGET_DIR%" "%SOURCE_DIR%"
if errorlevel 1 (
    echo Failed to create symbolic link. Run this script as administrator or enable Developer Mode.
    set "EXIT_CODE=1"
    goto :ExitWithPause
)

echo Installed Codex context-checkpoint skill as a symbolic link:
echo "%TARGET_DIR%" -^> "%SOURCE_DIR%"
set "EXIT_CODE=0"
goto :ExitWithPause

:ExitWithPause
pause
exit /b %EXIT_CODE%
