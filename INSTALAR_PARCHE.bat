@echo off
REM ============================================================
REM  Instala el parche ES SIN necesidad de compilar el .exe.
REM  Copia los .bra traducidos de _PRIVADO_NO_SUBIR\patch_files\ al juego,
REM  haciendo copia de seguridad de los originales.
REM ============================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

set GAME=C:\Program Files (x86)\Steam\steamapps\common\Fairy Fencer F Advent Dark Force
if not exist "%GAME%\FairyFencerAD.exe" (
  set /p GAME=No encuentro el juego. Pega la ruta de su carpeta:
)
if not exist "%GAME%\FairyFencerAD.exe" (
  echo [ERROR] No existe FairyFencerAD.exe en esa carpeta.
  pause & exit /b 1
)

set BACKUP=%GAME%\_es_patch_backup
if not exist "%BACKUP%" mkdir "%BACKUP%"

for %%F in (ENSystem.bra ENExtend.bra ENExtend01.bra DLC01.bra DLC02.bra DLC03.bra DLC04.bra DLC05.bra DLC06.bra DLC07.bra DLC08.bra) do (
  if exist "_PRIVADO_NO_SUBIR\patch_files\%%F" (
    if exist "%GAME%\%%F" if not exist "%BACKUP%\%%F" (
      echo Backup de %%F...
      copy /y "%GAME%\%%F" "%BACKUP%\%%F" >nul
    )
    echo Instalando %%F...
    copy /y "_PRIVADO_NO_SUBIR\patch_files\%%F" "%GAME%\%%F" >nul
  )
)
echo.
echo Parche instalado. En el juego elige idioma "English": se vera en espanol.
echo Para desinstalar: ejecuta DESINSTALAR_PARCHE.bat
pause
