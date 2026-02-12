@echo off
cd /d "%~dp0"

echo Starte News-Erstellung...
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0new-news.ps1"

echo.
pause
