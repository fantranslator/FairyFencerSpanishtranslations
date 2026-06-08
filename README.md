# Fairy Fencer F: Advent Dark Force — Traducción al Español

Fan-traducción **completa** al español del juego de Steam: interfaz, ítems,
habilidades, enemigos, misiones, los 8 DLC, toda la historia (~37.000 cadenas)
y subtítulos en las cinemáticas con voz.

Esta traducción fue hecha **con ayuda de inteligencia artificial**, sin ánimo
de lucro, simplemente porque me gusta el juego y no existía forma de jugarlo
en español. Es un proyecto de fans, no oficial.

## 📥 Instalar (usuarios)

1. Descarga `FFFADF-ES-PatchLite-<versión>.exe` desde
   [Releases](../../releases).
2. Ejecútalo. Detecta el juego solo (esté donde esté tu Steam); si no, elige
   la carpeta del juego.
3. Marca el componente de **cinemáticas subtituladas** si las quieres
   (descarga ffmpeg ~30MB una vez y las genera en 1-2 min).
4. Al terminar, abre el juego y elige idioma **English** → se verá en español.

- El instalador hace copia de seguridad de tus archivos.
- Para desinstalar: "Agregar o quitar programas" → *Fairy Fencer F ADF -
  Traduccion ES* (restaura los originales).

Requisito: el juego original de Steam. El parche **no contiene archivos del
juego**, solo diferencias binarias verificadas (si tu versión del juego no
coincide, no se aplica y no rompe nada).

## 🔧 Generar tu propio instalador (desarrolladores)

1. Clona este repo.
2. Instala [NSIS](https://nsis.sourceforge.io) (en Linux: `sudo apt install nsis`).
3. Ejecuta:
   ```bash
   bash scripts/build.sh        # genera build/dist/FFFADF-ES-PatchLite-*.exe
   ```
   En Windows: `makensis installer\patch_installer_lite.nsi`.

Los parches binarios ya están en `patch_files_lite/` (formato VPatch).
Si quieres regenerarlos o editar la traducción, el motor de edición de los
`.bra` está en `tools/fff_tool.py` y el método documentado en
`docs/GUIA_TRADUCCION.md` y `docs/ESTRUCTURA_JUEGO.md`.

También hay un workflow de GitHub Actions que compila y publica el instalador
automáticamente al crear un tag `v*`.

## ❓ Notas

- Algunos nombres muy cortos (ítems/enemigos) permanecen en inglés por límites
  técnicos del motor; las descripciones van siempre en español. Detalles en
  `docs/TRADUCCION_ESTADO.md`.
- No se traducen: voces, texto dibujado en imágenes y los créditos en vídeo.

## ⚖️ Aviso legal

Traducción de fans, gratuita, no oficial y sin afiliación con Idea Factory,
Compile Heart ni Idea Factory International. No se redistribuye ningún archivo
original del juego: el parche contiene únicamente diferencias binarias y texto
de traducción propio, y requiere poseer el juego original en Steam. Se
retirará a petición del titular de los derechos.
