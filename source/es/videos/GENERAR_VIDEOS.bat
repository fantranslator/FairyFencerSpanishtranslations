@echo off
REM ============================================================
setlocal enabledelayedexpansion
REM  Quema los subtitulos ES en las cinematicas usando TU copia
REM  del juego (no se distribuye ningun video del juego).
REM  Si no hay ffmpeg, lo descarga automaticamente (build oficial
REM  LGPL de gyan.dev, ~30MB) y lo usa de forma local.
REM ============================================================
setlocal
cd /d "%~dp0"
set GAME=C:\Program Files (x86)\Steam\steamapps\common\Fairy Fencer F Advent Dark Force
if not exist "%GAME%\FairyFencerAD.exe" (
  for /f "tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do set STEAM=%%b
  if defined STEAM if exist "!STEAM!\steamapps\common\Fairy Fencer F Advent Dark Force\FairyFencerAD.exe" set GAME=!STEAM!\steamapps\common\Fairy Fencer F Advent Dark Force
)
if not exist "%GAME%\FairyFencerAD.exe" set /p GAME=Ruta de la carpeta del juego:
if not exist "%GAME%\FairyFencerAD.exe" (echo No se encontro el juego. & pause & exit /b 1)

set FF=ffmpeg
where ffmpeg >nul 2>nul && goto :go
if exist "%~dp0ffmpeg.exe" (set FF=%~dp0ffmpeg.exe & goto :go)
echo Descargando ffmpeg (unica vez, ~30MB)...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol='Tls12';Invoke-WebRequest 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile '%TEMP%\ffmpeg_es.zip';Expand-Archive '%TEMP%\ffmpeg_es.zip' -DestinationPath '%TEMP%\ffmpeg_es' -Force"
for /r "%TEMP%\ffmpeg_es" %%f in (ffmpeg.exe) do if exist "%%f" set FF=%%f
if "%FF%"=="ffmpeg" (echo No se pudo obtener ffmpeg. Instalalo manualmente. & pause & exit /b 1)

:go
echo Usando: %FF%
echo [1/3] Intro narrado...
set V=%GAME%\EN\EXTEND\EVENT\SCRIPT\00001\MOVIE\0001.wmv
if not exist "%V%.orig" copy /y "%V%" "%V%.orig" >nul
"%FF%" -v fatal -i "%V%.orig" -vf "subtitles=00001_intro.srt:force_style='FontName=Georgia,FontSize=17,Outline=1,Shadow=1,MarginV=22'" -c:v msmpeg4 -q:v 3 -c:a copy -y "%V%"
copy /y "%V%" "%GAME%\EN\EXTEND\EVENT\SCRIPT\00001\en\MOVIE\0001.wmv" >nul

echo [2/3] Flashback (3 escenas)...
set V=%GAME%\EN\EXTEND01\EVENT\SCRIPT\11040\MOVIE\0003.wmv
if not exist "%V%.orig" copy /y "%V%" "%V%.orig" >nul
"%FF%" -v fatal -i "%V%.orig" -vf "subtitles=0003_flashback.srt:force_style='FontName=Arial,FontSize=14,Outline=1,Shadow=1,MarginV=68'" -c:v msmpeg4 -q:v 3 -c:a copy -y "%V%"
for %%E in (11040 70020 85020) do (
  copy /y "%V%" "%GAME%\EN\EXTEND01\EVENT\SCRIPT\%%E\MOVIE\0003.wmv" >nul
  copy /y "%V%" "%GAME%\EN\EXTEND01\EVENT\SCRIPT\%%E\en\MOVIE\0003.wmv" >nul
)

echo [3/3] Rotulo de Zelwinds...
set V=%GAME%\EN\EXTEND\EVENT\SCRIPT\00080\MOVIE\0004.wmv
if not exist "%V%.orig" copy /y "%V%" "%V%.orig" >nul
"%FF%" -v fatal -i "%V%.orig" -vf "subtitles=0004_zelwinds.srt:force_style='FontName=Georgia,FontSize=22,Outline=1,Shadow=1,MarginV=30'" -c:v msmpeg4 -q:v 3 -c:a copy -y "%V%"

echo.
echo Listo: cinematicas subtituladas (originales guardados como .orig).
pause
