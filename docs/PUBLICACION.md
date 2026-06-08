# Cómo publicar el parche (distribución limpia)

## Qué SÍ se puede subir/publicar
- `patch_files_lite/` (.pat de VPatch: solo diferencias; requieren que el
  usuario posea el juego original)
- `build/dist/FFFADF-ES-PatchLite-X.exe` (instalador hecho SOLO con esos .pat
  y los .srt) — súbelo a Releases de GitHub o Nexus Mods
- `source/es/videos/*.srt` y `GENERAR_VIDEOS.bat` (texto propio + script)
- Todo el código de `tools/`, `installer/`, docs

## Qué NO publicar nunca
- `_PRIVADO_NO_SUBIR/patch_files/` (los .bra completos: contienen TODO el juego)
- `FFFADF-ES-Patch-1.0.0.exe` y `FFFADF-ES-Videos-1.0.0.exe` (contienen
  archivos del juego / vídeo del juego re-codificado) — solo uso personal
- Cualquier `.orig`

## Pasos sugeridos
1. Cuenta de correo nueva (sin datos personales) → cuenta GitHub nueva.
2. `git init` en este repo (el .gitignore ya excluye lo prohibido), subir.
3. Release en GitHub con `FFFADF-ES-PatchLite-X.exe`.
4. Guía en Steam Community (con cualquier cuenta): instrucciones + enlace.
5. Disclaimer en README y en la guía:
   "Traducción de fans, no oficial y sin ánimo de lucro. No afiliada a
   Idea Factory / Compile Heart. Requiere el juego original de Steam.
   Se retirará a petición del titular de los derechos."

## Por qué este formato es seguro
Los .pat de VPatch solo contienen (a) referencias por offset a datos que el
usuario ya posee y (b) el texto traducido (obra propia derivada permitida en
la práctica de fan-TLs). No se redistribuye ningún asset del juego. Es el
mismo modelo que los parches de retraducción de Neptunia que llevan años
publicados en la propia Steam Community sin problemas con IFI.
