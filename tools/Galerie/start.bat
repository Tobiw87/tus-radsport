@echo off
cd /d "%~dp0"

echo Starte Event-Erstellung...
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0new-event.ps1"

echo.
pause