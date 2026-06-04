@echo off
setlocal

set "TARGET_DIR=%USERPROFILE%\.codex\skills\context-checkpoint"

if exist "%TARGET_DIR%\" (
    rmdir /s /q "%TARGET_DIR%"
    if errorlevel 1 (
        echo Failed to remove Codex skill directory: "%TARGET_DIR%"
        set "EXIT_CODE=1"
        goto :ExitWithPause
    )

    echo Removed Codex context-checkpoint skill:
    echo "%TARGET_DIR%"
    set "EXIT_CODE=0"
    goto :ExitWithPause
)

if exist "%TARGET_DIR%" (
    del /f /q "%TARGET_DIR%"
    if errorlevel 1 (
        echo Failed to remove Codex skill file: "%TARGET_DIR%"
        set "EXIT_CODE=1"
        goto :ExitWithPause
    )

    echo Removed Codex context-checkpoint skill file:
    echo "%TARGET_DIR%"
    set "EXIT_CODE=0"
    goto :ExitWithPause
)

echo Codex context-checkpoint skill is not installed:
echo "%TARGET_DIR%"
set "EXIT_CODE=0"
goto :ExitWithPause

:ExitWithPause
pause
exit /b %EXIT_CODE%
