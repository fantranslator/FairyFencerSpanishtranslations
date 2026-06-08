# Anonimato y distribución

Para fan-traducciones conviene separar identidad real del proyecto.

## Identidad
- Cuenta de GitHub (o **Codeberg.org**, más privado) con **pseudónimo**.
- Email dedicado tipo **Proton Mail**, distinto del personal.
- No reutilices usuarios/handles que apunten a tu identidad real.

## Dónde publicar
- **GitHub / Codeberg Releases** — para el `.exe` del parche y el código.
- **itch.io** — para subir el `.exe` directo sin exponer código.
- **F95Zone** y comunidades de VN/JRPG — para el anuncio a la comunidad.

## Qué NO subir nunca al repo
- **Archivos originales del juego** (`*.bra`, vídeos, audio): son propiedad de
  Idea Factory / Compile Heart. Redistribuirlos es infracción de copyright.
  → Por eso `.gitignore` excluye `*.bra`, `work/`y los `.bra`
    dentro de `_PRIVADO_NO_SUBIR/`.
- Por eso el modo de distribución pública es **xdelta**: el parche solo contiene
  la *diferencia*; el usuario aplica el parche sobre los archivos que ya posee.

## Aviso legal recomendado (incluir en la Release)
> Traducción de fans sin ánimo de lucro. Sin afiliación con Idea Factory ni
> Compile Heart. Requiere una copia legítima del juego. No se distribuye ningún
> material con copyright; el parche solo modifica archivos que el usuario ya
> posee.
