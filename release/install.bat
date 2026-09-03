@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This installer requires Administrator privileges.
    echo Right-click and select "Run as administrator".
    pause
    exit /b 1
)
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
