; ============================================================================
;  Fairy Fencer F: ADF - Traduccion ES (version DISTRIBUIBLE, sin copyright)
;  Aplica parches binarios VPatch sobre los archivos que el usuario YA posee.
;  NO contiene ningun archivo del juego: solo diferencias + subtitulos .srt.
; ============================================================================

Unicode true
SetCompressor /SOLID lzma

!define GAME_DIR    "Fairy Fencer F Advent Dark Force"
!define GAME_EXE    "FairyFencerAD.exe"
!ifndef PATCH_VERSION
  !define PATCH_VERSION "1.0.0"
!endif
!define BACKUP_DIR  "$INSTDIR\_es_patch_backup"

Name "Fairy Fencer F ADF - Traduccion ES ${PATCH_VERSION}"
OutFile "..\build\dist\FFFADF-ES-PatchLite-${PATCH_VERSION}.exe"
RequestExecutionLevel admin
InstallDir "$PROGRAMFILES\Steam\steamapps\common\${GAME_DIR}"
ShowInstDetails show
ShowUninstDetails show

!include "MUI2.nsh"
!include "LogicLib.nsh"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "English"

Function .onInit
  ReadRegStr $0 HKLM "Software\WOW6432Node\Valve\Steam" "InstallPath"
  ${If} $0 == ""
    ReadRegStr $0 HKLM "Software\Valve\Steam" "InstallPath"
  ${EndIf}
  ${If} $0 != ""
    StrCpy $1 "$0\steamapps\common\${GAME_DIR}"
    ${If} ${FileExists} "$1\${GAME_EXE}"
      StrCpy $INSTDIR "$1"
    ${EndIf}
  ${EndIf}
FunctionEnd

; Aplica un .pat sobre un archivo del juego, con backup y validacion MD5.
!macro PatchBra FNAME
  DetailPrint "Parcheando ${FNAME}..."
  vpatch::vpatchfile "$PLUGINSDIR\${FNAME}.pat" "$INSTDIR\${FNAME}.bra" "$INSTDIR\${FNAME}.bra.new"
  Pop $0
  StrCpy $1 $0 2
  ${If} $1 == "OK"
    ${If} $0 == "OK, new version already installed"
      Delete "$INSTDIR\${FNAME}.bra.new"
      DetailPrint "${FNAME}: ya estaba traducido."
    ${Else}
      CreateDirectory "${BACKUP_DIR}"
      ${IfNot} ${FileExists} "${BACKUP_DIR}\${FNAME}.bra"
        Rename "$INSTDIR\${FNAME}.bra" "${BACKUP_DIR}\${FNAME}.bra"
      ${Else}
        Delete "$INSTDIR\${FNAME}.bra"
      ${EndIf}
      Rename "$INSTDIR\${FNAME}.bra.new" "$INSTDIR\${FNAME}.bra"
      DetailPrint "${FNAME}: OK"
    ${EndIf}
  ${Else}
    Delete "$INSTDIR\${FNAME}.bra.new"
    DetailPrint "${FNAME}: $0 (se omite; quiza version distinta del juego)"
  ${EndIf}
!macroend

Section "!Traduccion completa (texto)" SecText
  SectionIn RO
  ${IfNot} ${FileExists} "$INSTDIR\${GAME_EXE}"
    MessageBox MB_ICONSTOP "No se encontro ${GAME_EXE} en:$\n$INSTDIR$\n$\nElige la carpeta de instalacion del juego."
    Abort
  ${EndIf}
  InitPluginsDir
  SetOutPath "$PLUGINSDIR"
  File "..\patch_files_lite\ENSystem.pat"
  File "..\patch_files_lite\ENExtend.pat"
  File "..\patch_files_lite\ENExtend01.pat"
  File "..\patch_files_lite\DLC01.pat"
  File "..\patch_files_lite\DLC02.pat"
  File "..\patch_files_lite\DLC03.pat"
  File "..\patch_files_lite\DLC04.pat"
  File "..\patch_files_lite\DLC05.pat"
  File "..\patch_files_lite\DLC06.pat"
  File "..\patch_files_lite\DLC07.pat"
  File "..\patch_files_lite\DLC08.pat"
  !insertmacro PatchBra "ENSystem"
  !insertmacro PatchBra "ENExtend"
  !insertmacro PatchBra "ENExtend01"
  !insertmacro PatchBra "DLC01"
  !insertmacro PatchBra "DLC02"
  !insertmacro PatchBra "DLC03"
  !insertmacro PatchBra "DLC04"
  !insertmacro PatchBra "DLC05"
  !insertmacro PatchBra "DLC06"
  !insertmacro PatchBra "DLC07"
  !insertmacro PatchBra "DLC08"
SectionEnd

Section "Cinematicas subtituladas (descarga ffmpeg ~30MB)" SecVid
  SetOutPath "$INSTDIR\subtitulos_es"
  File "..\source\es\videos\00001_intro.srt"
  File "..\source\es\videos\0003_flashback.srt"
  File "..\source\es\videos\0004_zelwinds.srt"
  File "..\source\es\videos\GENERAR_VIDEOS.bat"

  ; --- localizar o descargar ffmpeg (oculto, sin ventanas) ---
  StrCpy $R0 "ffmpeg"
  nsExec::Exec `cmd /c where ffmpeg`
  Pop $0
  ${If} $0 != 0
    DetailPrint "Descargando ffmpeg (unica vez, ~30 MB)..."
    nsExec::ExecToLog `powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol='Tls12'; Invoke-WebRequest 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile '$PLUGINSDIR\ff.zip'; Expand-Archive '$PLUGINSDIR\ff.zip' -DestinationPath '$PLUGINSDIR\ff' -Force; Copy-Item (Get-ChildItem '$PLUGINSDIR\ff' -Recurse -Filter ffmpeg.exe | Select-Object -First 1).FullName '$PLUGINSDIR\ffmpeg.exe'"`
    Pop $0
    ${If} ${FileExists} "$PLUGINSDIR\ffmpeg.exe"
      StrCpy $R0 "$PLUGINSDIR\ffmpeg.exe"
    ${Else}
      DetailPrint "AVISO: no se pudo descargar ffmpeg. Los videos quedan en ingles."
      DetailPrint "Puedes generarlos luego con: subtitulos_es\GENERAR_VIDEOS.bat"
      Goto vid_fin
    ${EndIf}
  ${EndIf}

  ; --- 1/3 intro narrado ---
  DetailPrint "Generando cinematica 1/3 (intro narrado)..."
  StrCpy $R1 "$INSTDIR\EN\EXTEND\EVENT\SCRIPT\00001\MOVIE\0001.wmv"
  ${If} ${FileExists} "$R1"
    ${IfNot} ${FileExists} "$R1.orig"
      CopyFiles /SILENT "$R1" "$R1.orig"
    ${EndIf}
    nsExec::Exec `"$R0" -v fatal -i "$R1.orig" -vf "subtitles=00001_intro.srt:force_style='FontName=Georgia,FontSize=17,Outline=1,Shadow=1,MarginV=22'" -c:v msmpeg4 -q:v 3 -c:a copy -y "$R1"`
    Pop $0
    CopyFiles /SILENT "$R1" "$INSTDIR\EN\EXTEND\EVENT\SCRIPT\00001\en\MOVIE\0001.wmv"
  ${EndIf}

  ; --- 2/3 flashback (mismo video en 3 escenas) ---
  DetailPrint "Generando cinematica 2/3 (flashback, 3 escenas)..."
  StrCpy $R1 "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\11040\MOVIE\0003.wmv"
  ${If} ${FileExists} "$R1"
    ${IfNot} ${FileExists} "$R1.orig"
      CopyFiles /SILENT "$R1" "$R1.orig"
    ${EndIf}
    nsExec::Exec `"$R0" -v fatal -i "$R1.orig" -vf "subtitles=0003_flashback.srt:force_style='FontName=Arial,FontSize=14,Outline=1,Shadow=1,MarginV=68'" -c:v msmpeg4 -q:v 3 -c:a copy -y "$R1"`
    Pop $0
    CopyFiles /SILENT "$R1" "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\11040\en\MOVIE\0003.wmv"
    CopyFiles /SILENT "$R1" "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\70020\MOVIE\0003.wmv"
    CopyFiles /SILENT "$R1" "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\70020\en\MOVIE\0003.wmv"
    CopyFiles /SILENT "$R1" "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\85020\MOVIE\0003.wmv"
    CopyFiles /SILENT "$R1" "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\85020\en\MOVIE\0003.wmv"
  ${EndIf}

  ; --- 3/3 rotulo de Zelwinds ---
  DetailPrint "Generando cinematica 3/3 (Zelwinds)..."
  StrCpy $R1 "$INSTDIR\EN\EXTEND\EVENT\SCRIPT\00080\MOVIE\0004.wmv"
  ${If} ${FileExists} "$R1"
    ${IfNot} ${FileExists} "$R1.orig"
      CopyFiles /SILENT "$R1" "$R1.orig"
    ${EndIf}
    nsExec::Exec `"$R0" -v fatal -i "$R1.orig" -vf "subtitles=0004_zelwinds.srt:force_style='FontName=Georgia,FontSize=22,Outline=1,Shadow=1,MarginV=30'" -c:v msmpeg4 -q:v 3 -c:a copy -y "$R1"`
    Pop $0
  ${EndIf}
  DetailPrint "Cinematicas subtituladas: OK"
vid_fin:
  SetOutPath "$INSTDIR"
SectionEnd

Section "-Escribir desinstalador"
  WriteUninstaller "$INSTDIR\Uninstall_ES_Patch.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFFADF-ES" \
    "DisplayName" "Fairy Fencer F ADF - Traduccion ES"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFFADF-ES" \
    "UninstallString" "$INSTDIR\Uninstall_ES_Patch.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFFADF-ES" \
    "DisplayVersion" "${PATCH_VERSION}"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecText} "Toda la traduccion: UI, base de datos, historia y DLC. Se aplica como parche sobre tus archivos."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecVid}  "Genera las cinematicas con subtitulos en espanol usando tu propia copia (ffmpeg, sin ventanas)."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!macro RestoreOriginal FNAME
  ${If} ${FileExists} "${BACKUP_DIR}\${FNAME}"
    Delete "$INSTDIR\${FNAME}"
    Rename "${BACKUP_DIR}\${FNAME}" "$INSTDIR\${FNAME}"
    DetailPrint "Restaurado: ${FNAME}"
  ${EndIf}
!macroend

Section "Uninstall"
  !insertmacro RestoreOriginal "ENSystem.bra"
  !insertmacro RestoreOriginal "ENExtend.bra"
  !insertmacro RestoreOriginal "ENExtend01.bra"
  !insertmacro RestoreOriginal "DLC01.bra"
  !insertmacro RestoreOriginal "DLC02.bra"
  !insertmacro RestoreOriginal "DLC03.bra"
  !insertmacro RestoreOriginal "DLC04.bra"
  !insertmacro RestoreOriginal "DLC05.bra"
  !insertmacro RestoreOriginal "DLC06.bra"
  !insertmacro RestoreOriginal "DLC07.bra"
  !insertmacro RestoreOriginal "DLC08.bra"
  RMDir "${BACKUP_DIR}"
  RMDir /r "$INSTDIR\subtitulos_es"
  Delete "$INSTDIR\Uninstall_ES_Patch.exe"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFFADF-ES"
SectionEnd
