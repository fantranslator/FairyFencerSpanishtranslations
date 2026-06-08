@echo off
REM ============================================================
REM  Compila el instalador .exe del parche (requiere NSIS)
REM  Descarga NSIS de: https://nsis.sourceforge.io/Download
REM  Doble clic en este archivo una vez instalado NSIS.
REM ============================================================
setlocal
set VERSION=1.0.0
cd /d "%~dp0"

set MAKENSIS=
if exist "%ProgramFiles(x86)%\NSIS\makensis.exe" set MAKENSIS=%ProgramFiles(x86)%\NSIS\makensis.exe
if exist "%ProgramFiles%\NSIS\makensis.exe" set MAKENSIS=%ProgramFiles%\NSIS\makensis.exe
where makensis >nul 2>nul && set MAKENSIS=makensis

if "%MAKENSIS%"=="" (
  echo [ERROR] NSIS no esta instalado.
  echo Descargalo de https://nsis.sourceforge.io/Download e instalalo.
  pause
  exit /b 1
)

if not exist build\dist mkdir build\dist
echo Compilando instalador v%VERSION% (tardara unos minutos, payload ~570MB)...
"%MAKENSIS%" /DPATCH_VERSION=%VERSION% installer\patch_installer.nsi
if errorlevel 1 (
  echo [ERROR] Fallo la compilacion.
  pause
  exit /b 1
)
echo.
echo OK: build\dist\FFFADF-ES-Patch-%VERSION%.exe
pause
