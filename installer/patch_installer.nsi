; ============================================================================
;  Fairy Fencer F: Advent Dark Force - Parche de traduccion al Espanol
;  Instalador NSIS. Compilar: makensis patch_installer.nsi (o COMPILAR_INSTALADOR.bat)
;  Payload en ..\_PRIVADO_NO_SUBIR\patch_files\ : .bra traducidos + movies\ (videos subtitulados)
; ============================================================================

Unicode true
SetCompress off

!define GAME_DIR    "Fairy Fencer F Advent Dark Force"
!define GAME_EXE    "FairyFencerAD.exe"
!ifndef PATCH_VERSION
  !define PATCH_VERSION "1.0.0"
!endif
!define BACKUP_DIR  "$INSTDIR\_es_patch_backup"

Name "Fairy Fencer F ADF - Traduccion ES ${PATCH_VERSION}"
OutFile "..\build\dist\FFFADF-ES-Patch-${PATCH_VERSION}.exe"
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

!macro BackupOriginal FNAME
  ${If} ${FileExists} "$INSTDIR\${FNAME}"
    ${IfNot} ${FileExists} "${BACKUP_DIR}\${FNAME}"
      CreateDirectory "${BACKUP_DIR}"
      CopyFiles /SILENT "$INSTDIR\${FNAME}" "${BACKUP_DIR}\${FNAME}"
      DetailPrint "Backup: ${FNAME}"
    ${EndIf}
  ${EndIf}
!macroend

; ============================ SECCIONES ======================================

Section "!Traduccion base - UI/Sistema (requerido)" SecSystem
  SectionIn RO
  ${IfNot} ${FileExists} "$INSTDIR\${GAME_EXE}"
    MessageBox MB_ICONSTOP "No se encontro ${GAME_EXE} en:$\n$INSTDIR$\n$\nElige la carpeta de instalacion del juego."
    Abort
  ${EndIf}
  !insertmacro BackupOriginal "ENSystem.bra"
  SetOutPath "$INSTDIR"
  File "..\_PRIVADO_NO_SUBIR\patch_files\ENSystem.bra"
SectionEnd

Section "Dialogo / eventos (historia completa)" SecExtend
  !insertmacro BackupOriginal "ENExtend.bra"
  !insertmacro BackupOriginal "ENExtend01.bra"
  SetOutPath "$INSTDIR"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\ENExtend.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\ENExtend01.bra"
SectionEnd

Section "Contenido DLC (items, hadas, mazmorras extra)" SecDLC
  !insertmacro BackupOriginal "DLC01.bra"
  !insertmacro BackupOriginal "DLC02.bra"
  !insertmacro BackupOriginal "DLC03.bra"
  !insertmacro BackupOriginal "DLC04.bra"
  !insertmacro BackupOriginal "DLC05.bra"
  !insertmacro BackupOriginal "DLC06.bra"
  !insertmacro BackupOriginal "DLC07.bra"
  !insertmacro BackupOriginal "DLC08.bra"
  SetOutPath "$INSTDIR"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC01.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC02.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC03.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC04.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC05.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC06.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC07.bra"
  File /nonfatal "..\_PRIVADO_NO_SUBIR\patch_files\DLC08.bra"
SectionEnd

Section "Subtitulos en cinematicas (videos)" SecVideos
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND\EVENT\SCRIPT\00001\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND\EVENT\SCRIPT\00001\en\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND\EVENT\SCRIPT\00080\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND01\EVENT\SCRIPT\11040\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND01\EVENT\SCRIPT\11040\en\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND01\EVENT\SCRIPT\70020\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND01\EVENT\SCRIPT\70020\en\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND01\EVENT\SCRIPT\85020\MOVIE"
  CreateDirectory "${BACKUP_DIR}\EN\EXTEND01\EVENT\SCRIPT\85020\en\MOVIE"
  !insertmacro BackupOriginal "EN\EXTEND\EVENT\SCRIPT\00001\MOVIE\0001.wmv"
  !insertmacro BackupOriginal "EN\EXTEND\EVENT\SCRIPT\00001\en\MOVIE\0001.wmv"
  !insertmacro BackupOriginal "EN\EXTEND\EVENT\SCRIPT\00080\MOVIE\0004.wmv"
  !insertmacro BackupOriginal "EN\EXTEND01\EVENT\SCRIPT\11040\MOVIE\0003.wmv"
  !insertmacro BackupOriginal "EN\EXTEND01\EVENT\SCRIPT\11040\en\MOVIE\0003.wmv"
  !insertmacro BackupOriginal "EN\EXTEND01\EVENT\SCRIPT\70020\MOVIE\0003.wmv"
  !insertmacro BackupOriginal "EN\EXTEND01\EVENT\SCRIPT\70020\en\MOVIE\0003.wmv"
  !insertmacro BackupOriginal "EN\EXTEND01\EVENT\SCRIPT\85020\MOVIE\0003.wmv"
  !insertmacro BackupOriginal "EN\EXTEND01\EVENT\SCRIPT\85020\en\MOVIE\0003.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND\EVENT\SCRIPT\00001\MOVIE"
  File /nonfatal /oname=0001.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0001_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND\EVENT\SCRIPT\00001\en\MOVIE"
  File /nonfatal /oname=0001.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0001_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND\EVENT\SCRIPT\00080\MOVIE"
  File /nonfatal /oname=0004.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0004_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\11040\MOVIE"
  File /nonfatal /oname=0003.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0003_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\11040\en\MOVIE"
  File /nonfatal /oname=0003.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0003_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\70020\MOVIE"
  File /nonfatal /oname=0003.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0003_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\70020\en\MOVIE"
  File /nonfatal /oname=0003.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0003_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\85020\MOVIE"
  File /nonfatal /oname=0003.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0003_es.wmv"
  SetOutPath "$INSTDIR\EN\EXTEND01\EVENT\SCRIPT\85020\en\MOVIE"
  File /nonfatal /oname=0003.wmv "..\_PRIVADO_NO_SUBIR\patch_files\movies\0003_es.wmv"
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
  !insertmacro MUI_DESCRIPTION_TEXT ${SecSystem} "Menus, UI, base de datos y textos de sistema. Imprescindible."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecExtend} "Dialogo principal y eventos (parte grande del parche)."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDLC}    "Items, hadas y mazmorras de los 8 DLC."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecVideos} "Subtitulos en espanol quemados en las cinematicas con voz."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ============================ DESINSTALADOR ==================================

!macro RestoreOriginal FNAME
  ${If} ${FileExists} "${BACKUP_DIR}\${FNAME}"
    CopyFiles /SILENT "${BACKUP_DIR}\${FNAME}" "$INSTDIR\${FNAME}"
    Delete "${BACKUP_DIR}\${FNAME}"
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
  !insertmacro RestoreOriginal "EN\EXTEND\EVENT\SCRIPT\00001\MOVIE\0001.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND\EVENT\SCRIPT\00001\en\MOVIE\0001.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND\EVENT\SCRIPT\00080\MOVIE\0004.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND01\EVENT\SCRIPT\11040\MOVIE\0003.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND01\EVENT\SCRIPT\11040\en\MOVIE\0003.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND01\EVENT\SCRIPT\70020\MOVIE\0003.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND01\EVENT\SCRIPT\70020\en\MOVIE\0003.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND01\EVENT\SCRIPT\85020\MOVIE\0003.wmv"
  !insertmacro RestoreOriginal "EN\EXTEND01\EVENT\SCRIPT\85020\en\MOVIE\0003.wmv"
  RMDir /r "${BACKUP_DIR}\EN"
  RMDir "${BACKUP_DIR}"
  Delete "$INSTDIR\Uninstall_ES_Patch.exe"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFFADF-ES"
SectionEnd
