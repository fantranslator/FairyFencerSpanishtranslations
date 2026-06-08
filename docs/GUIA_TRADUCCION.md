# Guía de traducción — Fairy Fencer F: ADF (método actual)

El motor de edición es **nativo** (`tools/fff_tool.py`, Python 3 puro, sin
QuickBMS ni dependencias). Ver formatos en `ESTRUCTURA_JUEGO.md`.

## Flujo usado en esta traducción

1. **Leer** un `.bra`: `bra_read()` + `bra_getraw()` por entrada.
2. **UI (`.gstr`)**: `gstr_extract`/`gstr-inject` (longitud variable, sin límite).
3. **Eventos y base de datos (`.cl3` STCM2L/GBNL)**: edición *in situ* —
   el español en UTF-8 debe caber en los bytes de la cadena original
   (relleno con nulos). Los punteros no se tocan: riesgo cero.
4. **Reempaquetar** con `bra_write()` (recalcula DEFLATE y CRC32 por entrada)
   y verificar CRC de lo modificado antes de reemplazar.
5. Los aplicadores con todas las salvaguardas: `tools/apply_safe.py`
   (ENExtend) y `tools/apply_safe01.py` (ENExtend01).

## Distribución

- **Pública**: `installer/patch_installer_lite.nsi` + `patch_files_lite/*.pat`
  (VPatch: solo diferencias, sin assets del juego) + `.srt` de cinemáticas.
  Ver `docs/PUBLICACION.md`.
- **Personal**: `installer/patch_installer.nsi` con los `.bra` completos en
  `_PRIVADO_NO_SUBIR/patch_files/` (NO publicar).

## Vídeos

Subtítulos quemados con ffmpeg (`source/es/videos/`): el script
`GENERAR_VIDEOS.bat` los genera sobre la copia del juego del usuario.
