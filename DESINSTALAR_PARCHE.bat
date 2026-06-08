@echo off
REM  Restaura los archivos originales desde _es_patch_backup
setlocal
set GAME=C:\Program Files (x86)\Steam\steamapps\common\Fairy Fencer F Advent Dark Force
if not exist "%GAME%\FairyFencerAD.exe" (
  set /p GAME=No encuentro el juego. Pega la ruta de su carpeta:
)
set BACKUP=%GAME%\_es_patch_backup
if not exist "%BACKUP%" (
  echo No hay backup que restaurar.
  pause & exit /b 1
)
for %%F in (ENSystem.bra ENExtend.bra ENExtend01.bra DLC01.bra DLC02.bra DLC03.bra DLC04.bra DLC05.bra DLC06.bra DLC07.bra DLC08.bra) do (
  if exist "%BACKUP%\%%F" (
    echo Restaurando %%F...
    copy /y "%BACKUP%\%%F" "%GAME%\%%F" >nul
    del "%BACKUP%\%%F"
  )
)
rmdir "%BACKUP%" 2>nul
echo Originales restaurados.
pause
