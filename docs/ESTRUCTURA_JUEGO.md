# Estructura del juego — hallazgos

Notas reales obtenidas inspeccionando la carpeta de instalación
`Fairy Fencer F Advent Dark Force`.

## Motor

- **No es Ren'Py, ni Unity, ni Unreal, ni RPG Maker.**
- Es el motor propio de **Idea Factory / Compile Heart** (mismo de la saga
  Neptunia). Ejecutable: `FairyFencerAD.exe` (PE32, Win32).
- Los assets viven en archivos **`.bra`** = formato **PDArc**.
  Cabecera mágica confirmada: los primeros 4 bytes son `50 44 41 00` = `PDA\0`.

## Cómo el .exe resuelve los archivos

Strings extraídos del ejecutable:

```
.\%s.bra            → p.ej. "Game"   → Game.bra
.\%s%s.bra          → p.ej. "EN"+"Game" → ENGame.bra
.\DLC%02d.bra       → DLC01.bra ... DLC08.bra
TextLanguage   = english | japanese | tchinese
SoundLanguage  = english | japanese
"Change between English, Japanese and Chinese text."
```

→ El prefijo de idioma es **EN / JP / CN**. **No hay prefijo ES.** El menú de
idioma solo ofrece inglés/japonés/chino. Por eso la traducción al español se
entrega **sobre el slot inglés** (ver README).

## Archivos `.bra` en la raíz

| Archivo            | Tamaño aprox | Contenido probable                          |
|--------------------|-------------:|---------------------------------------------|
| `Game.bra`         | ~224 MB      | Datos base del juego                        |
| `System.bra`       | ~13 MB       | Sistema / UI base                           |
| `Sound.bra`        | ~455 MB      | Audio base                                  |
| `Extend.bra`       | ~1.8 GB      | Contenido extendido (eventos, etc.)         |
| `Extend01.bra`     | ~372 MB      | Contenido extendido 2                       |
| `ENGame.bra`       | ~164 MB      | **Datos en inglés** ← traducir              |
| `ENSystem.bra`     | ~10 MB       | **UI/menús en inglés** ← traducir (empezar) |
| `ENExtend.bra`     | ~133 MB      | **Eventos/diálogo en inglés** ← traducir    |
| `ENExtend01.bra`   | ~346 MB      | **Eventos/diálogo 2 en inglés** ← traducir  |
| `ENSound.bra`      | ~136 MB      | Voces en inglés (no traducible sin doblaje) |
| `JP*.bra`          | varios       | Equivalentes en japonés                     |
| `CN*.bra`          | varios       | Equivalentes en chino                       |
| `DLC01..08.bra`    | varios       | DLC                                         |

> Los tamaños son aproximados y solo orientativos para priorizar.

## Carpetas sueltas (no empaquetadas)

`EN/`, `JP/`, `CN/`, `Common/` contienen sobre todo **vídeos** (`.wmv`) bajo
`EXTEND/EVENT/SCRIPT/<id>/MOVIE/`. Texto traducible aquí: prácticamente nulo
(son cinemáticas). El grueso del texto está dentro de los `.bra`.

## Orden de prioridad para traducir

1. **`ENSystem.bra`** — menús, botones, UI. Es el más pequeño y el de mayor
   impacto visible. Empezar aquí para validar todo el pipeline (unpack → editar
   → repack → instalar → ver en el juego) con poco volumen.
2. **`ENGame.bra`** — nombres de ítems, habilidades, descripciones, nombres de
   personajes.
3. **`ENExtend.bra`** y **`ENExtend01.bra`** — el diálogo principal de eventos
   (el grueso del trabajo de traducción).

## Lo que NO se puede traducir sin más

- **Voces** (`ENSound.bra`) — requieren doblaje.
- **Texto incrustado en imágenes** (logos, títulos baked) — requieren editar PNG.
- **Vídeos** (`.wmv`) con texto quemado.

## Formato del contenedor `.bra` (reverse-engineering confirmado)

Analizando los archivos reales:

```
Cabecera (16 bytes):
  0x00  4   magic        = "PDA\0"
  0x04  4   version      = 2  (uint32 LE)
  0x08  4   index_offset = offset donde empieza el índice (cerca del fin del archivo)
  0x0C  4   file_count   = número de archivos

Datos: desde 0x10 hasta index_offset (payloads, COMPRIMIDOS).

Índice (en index_offset): file_count entradas. Cada entrada (campos confirmados):
  0x00  4   marker  = 0x5770F0D5 (constante por entrada)
  0x04  4   hash    (por archivo; CRC/seed)
  0x08  4   csize   (tamaño comprimido en el archivo)
  0x0C  4   usize   (tamaño descomprimido)
  0x10  2   ? (= 32 en tablas; bloque/alineación)
  0x12  2   ?
  0x14  4   offset  (posición del payload en el .bra)
  0x18  …   name    (ruta interna, p.ej. "database\dbCharaLevelUp01.gbin")
            + terminador + relleno hasta la siguiente entrada
```

Verificado: en `ENSystem.bra`, `index_offset` y `file_count=50` correctos, y la
primera entrada apunta a `database\dbCharaLevelUp01.gbin` (off=16, csize=1259,
usize=5600). El encadenado de offsets cuadra (offset_n + csize_n = offset_n+1).

**La compresión de los payloads NO es zlib/gzip/deflate** (probado y descartado).
Es un esquema propio de Idea Factory, con una pequeña cabecera por bloque
(`usize, csize, hash, ...`). Reimplementarla a mano es el agujero negro; por eso
se usa **QuickBMS + el script `.bra`** que ya la maneja (ver `docs/GUIA_TRADUCCION.md`).

`tools/fff_tool.py` lee/escribe el contenedor completo (unpack/repack/gstr),
pero **no descomprime**: eso lo hace QuickBMS.

## Riesgos / incógnitas a resolver en el pipeline

- El formato interno de los scripts de diálogo dentro de `.bra` es binario y
  propietario. Hay que confirmar codificación (probablemente UTF-16/Shift-JIS o
  tablas propias) y si hay longitudes/punteros que respetar al reinyectar.
- Posible **checksum o índice** en la cabecera `PDA` que debe recalcularse al
  reempaquetar — `bra_write()` de `tools/fff_tool.py` lo regenera (DEFLATE + CRC32).
