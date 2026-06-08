#!/usr/bin/env bash
# ============================================================================
#  build.sh - Compila los instaladores NSIS del parche ES
#
#  Uso:
#     bash scripts/build.sh            # lite (publico): patch_files_lite/*.pat
#     bash scripts/build.sh --full     # completo (personal): patch_files/*.bra
#     PATCH_VERSION=1.0.0 bash scripts/build.sh
#
#  Requisitos: makensis (apt install nsis | nsis.sourceforge.io)
# ============================================================================
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
VERSION="${PATCH_VERSION:-1.0.0}"
MODE="lite"; [[ "${1:-}" == "--full" ]] && MODE="full"
mkdir -p build/dist

if ! command -v makensis >/dev/null 2>&1; then
  echo "ERROR: makensis no encontrado (apt install nsis)" >&2; exit 1
fi

if [[ "$MODE" == "lite" ]]; then
  ls patch_files_lite/*.pat >/dev/null 2>&1 || { echo "ERROR: faltan .pat en patch_files_lite/" >&2; exit 1; }
  makensis -DPATCH_VERSION="$VERSION" installer/patch_installer_lite.nsi
  OUT="build/dist/FFFADF-ES-PatchLite-${VERSION}.exe"
else
  ls _PRIVADO_NO_SUBIR/patch_files/*.bra >/dev/null 2>&1 || { echo "ERROR: faltan .bra en _PRIVADO_NO_SUBIR/patch_files/ (solo uso personal)" >&2; exit 1; }
  makensis -DPATCH_VERSION="$VERSION" installer/patch_installer.nsi
  OUT="build/dist/FFFADF-ES-Patch-${VERSION}.exe"
fi
[[ -f "$OUT" ]] && { echo "==> OK: $OUT"; ls -lh "$OUT"; } || { echo "ERROR: no se genero $OUT" >&2; exit 1; }
