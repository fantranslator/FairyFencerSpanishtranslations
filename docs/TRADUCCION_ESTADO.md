# Estado de la traducción — Fairy Fencer F: ADF (ES)

## ✅ TRADUCCIÓN COMPLETA (texto)

Todo el texto traducible del juego está en español y desplegado en los `.bra`
(con backups `.orig` junto a cada archivo). El payload del parche está en
`_PRIVADO_NO_SUBIR/patch_files/` (11 archivos, ~570 MB).

| Bloque | Archivo(s) | Cadenas | Estado |
|---|---|---:|---|
| Interfaz (`.gstr`, GSTL) | ENSystem.bra | ~872 | ✅ |
| Dificultades (las 5) | ENSystem + DLC08 (database012) | — | ✅ |
| Tutoriales de Eryn | ENSystem (database.cl3) | 51 | ✅ |
| Base de datos (ítems, armas, magias, técnicas, pasivas, enemigos, ataques, lugares, misiones, perfiles, hadas, capítulos) | ENSystem (database.cl3) | ~7.900 | ✅ |
| Historia (eventos STCM2L) | ENExtend.bra (799) + ENExtend01.bra (330) | ~28.000 | ✅ |
| DLC 1-8 (ítems, enemigos, mazmorras, 8 hadas DLC) | DLC01-08.bra | ~500 | ✅ |

Notas de verificación:
- Cada despliegue validado contra el `.orig` (offsets, terminador nulo,
  presupuesto de bytes) y con CRC32 por entrada recomprimida.
- `ENGame.bra` y `HelpIntro.CL3` resultaron no contener texto de jugador
  (solo marcadores binarios y mensajes de depuración): no requieren parche.
- Los slots CN/JP no se tocan (el parche va sobre el slot English).

## Fuera de alcance (acordado)

- Texto incrustado en imágenes (títulos de menú/capítulo, AMATEUR/EASY/...,
  "3 days ago", botones sprite), vídeos `.wmv` y voces.
- Vídeos con subtítulos quemados: pendiente como mejora futura (prueba de
  concepto propuesta; ffmpeg no codifica WMV9, habría que validar WMV8).

## Deuda técnica conocida

1. **Edición in situ con límite de bytes** (los punteros STCM2L/GBNL no son
   relocalizables con seguridad): ~31 nombres cortos quedaron en inglés a
   propósito (Potion, Cyclops, "Enemy X DD", títulos de la BSO...), ~1% de
   líneas con alguna tilde omitida por falta de 1 byte, y ~50% de líneas
   ajustadas al byte (español más escueto pero correcto).
2. **QA in-game**: la validación es estructural (CRC/bytes), no visual.
   Posibles desbordes de caja o inconsistencias menores entre agentes.
3. **CRC de .ogg**: las entradas de voz fallan el chequeo CRC naïf TAMBIÉN en
   los `.bra` originales (otra convención de hash). Es normal, no es corrupción.

## Distribución

- `INSTALAR_PARCHE.bat` / `DESINSTALAR_PARCHE.bat`: instalación directa sin
  compilar nada (copia con backup / restauración).
- `COMPILAR_INSTALADOR.bat`: genera el `.exe` (requiere NSIS en Windows).
  El instalador NSIS hace backup y el desinstalador restaura originales.
- Para distribución pública usar modo xdelta (no redistribuir archivos del juego).

## Formatos (reverse-engineering) — ver ESTRUCTURA_JUEGO.md

- `.bra`: PDArc, DEFLATE raw + CRC32 del contenido sin comprimir (`tools/fff_tool.py`).
- `.gstr` (GSTL): reconstructor de longitud variable (`gstr_rebuild`).
- `.cl3` (STCM2L/GBNL): edición **in situ** (español ≤ bytes del original).
- Base de datos en capas: `database.cl3` (base) + `database001-025.cl3` (DLC)
  que sobrescriben/añaden (p. ej. AMATEUR/HELL viven en DLC08).
