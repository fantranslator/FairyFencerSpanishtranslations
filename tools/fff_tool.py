#!/usr/bin/env python3
"""
fff_tool.py - Motor nativo (Python puro) para traducir Fairy Fencer F: ADF.

NO necesita QuickBMS. Implementa todo lo descubierto por reverse-engineering:

  .bra (PDArc)  : contenedor. Cabecera PDA\\0, indice al final, payloads en
                  DEFLATE (raw, wbits=-15), hash = CRC32 de los datos sin comprimir.
  .gstr (GSTL)  : tablas de UI. Cabecera + tabla de entradas [keyoff,id,valoff]
                  (24 bytes) + footer + tabla de cadenas. Reconstruible con
                  longitud variable (recalcula offsets).
  .cl3 / gbin   : eventos (STCM2L) y base de datos (GBNL). Para estos se usa
                  edicion IN SITU (traducir dentro del presupuesto de bytes de
                  cada cadena, rellenando con nulos) -> sin tocar punteros, 0 riesgo.

Uso:
  python fff_tool.py unpack  <archivo.bra> <carpeta_salida>
  python fff_tool.py repack  <archivo.bra.orig> <carpeta_con_cambios> <salida.bra>
  python fff_tool.py gstr-extract <archivo.gstr> <salida.csv>
  python fff_tool.py gstr-inject  <archivo.gstr> <traduccion.csv> <salida.gstr>

Para flujos a gran escala se importa como modulo (ver funciones bra_*, gstr_*).
"""
import struct, zlib, binascii, sys, os, csv

MAGIC = b"PDA\x00"
ENTRY_MARKER = 0x5770F0D5

# ----------------------------- .bra container -----------------------------
def bra_read(path):
    d = open(path, "rb").read()
    assert d[:4] == MAGIC, "no es .bra"
    ver, info_off, files = struct.unpack_from("<III", d, 4)
    pos = info_off; ents = []
    for _ in range(files):
        zsize, size = struct.unpack_from("<II", d, pos + 8)
        namesz, flags = struct.unpack_from("<HH", d, pos + 16)
        offset = struct.unpack_from("<I", d, pos + 20)[0]
        rawname = d[pos + 24:pos + 24 + namesz]; pos += 24 + namesz
        block = d[offset:offset + zsize]
        bc = struct.unpack_from("<I", block, 4)[0]
        ents.append(dict(rawname=rawname, name=rawname.split(b"\x00")[0].decode("latin1"),
                         namesz=namesz, flags=flags, size=size, bc=bc,
                         extra=struct.unpack_from("<I", block, 12)[0],
                         block=block, newraw=None))
    return ver, ents

def bra_getraw(e):
    return zlib.decompress(e["block"][16:16 + e["bc"]], -15) if e["bc"] != e["size"] else e["block"][16:16 + e["size"]]

def bra_write(path, ver, ents):
    data = bytearray(); index = bytearray(); H = 16
    for e in ents:
        if e["newraw"] is not None:
            raw = e["newraw"]; comp = zlib.compress(raw, 9)[2:-4]
            crc = binascii.crc32(raw) & 0xffffffff
            block = struct.pack("<IIII", len(raw), len(comp), crc, e["extra"]) + comp
            size = len(raw)
        else:
            block = e["block"]; crc = struct.unpack_from("<I", block, 8)[0]; size = e["size"]
        off = H + len(data); data += block
        index += struct.pack("<QIIHHI", ENTRY_MARKER | (crc << 32), len(block), size,
                             e["namesz"], e["flags"], off) + e["rawname"]
    out = bytearray(MAGIC + struct.pack("<III", ver, H + len(data), len(ents))) + data + index
    open(path, "wb").write(out)
    return len(out)

# ----------------------------- .gstr (GSTL) -----------------------------
def gstr_entries(d):
    _, ver, diroff, dircnt = struct.unpack_from("<4sIII", d, 0)
    dirs = [struct.unpack_from("<II", d, diroff + i * 8) for i in range(dircnt)]
    et = dirs[0][1]; N = dirs[1][0]; base = dirs[3][1]
    out = []
    for i in range(N):
        k, ident, v = struct.unpack_from("<QQQ", d, et + i * 24)
        out.append((ident,
                    d[base + k:].split(b"\x00")[0].decode("latin1", "replace"),
                    d[base + v:].split(b"\x00")[0].decode("utf-8", "replace")))
    return out

def gstr_rebuild(d, trans):
    """trans = {id: 'texto en espanol'}. Reconstruye con longitud variable."""
    _, ver, diroff, dircnt = struct.unpack_from("<4sIII", d, 0)
    dirs = [list(struct.unpack_from("<II", d, diroff + i * 8)) for i in range(dircnt)]
    et = dirs[0][1]; N = dirs[1][0]; base = dirs[3][1]
    ents = [list(struct.unpack_from("<QQQ", d, et + i * 24)) for i in range(N)]
    role = {}; valids = {}
    for k, ident, v in ents:
        role.setdefault(k, "key")
        if v not in role: role[v] = "val"
        valids.setdefault(v, []).append(ident)
    newregion = bytearray(); mapoff = {}
    for o in sorted(role.keys()):
        orig = d[base + o:].split(b"\x00")[0]
        if role[o] == "val":
            nt = None
            for ident in valids.get(o, []):
                if ident in trans: nt = trans[ident]; break
            content = nt.encode("utf-8") if nt is not None else orig
        else:
            content = orig
        mapoff[o] = len(newregion); newregion += content + b"\x00"
    out = bytearray(d[:base])
    for i, (k, ident, v) in enumerate(ents):
        struct.pack_into("<QQQ", out, et + i * 24, mapoff[k], ident, mapoff[v])
    return bytes(out) + bytes(newregion)

# ------------------- in-place patch (CL3 events / GBNL db) -------------------
def inplace_patch(raw, edits):
    """edits = [(offset, original_len, 'spanish')]. Spanish <= original_len bytes."""
    raw = bytearray(raw)
    for off, ln, es in edits:
        b = es.encode("utf-8")
        if len(b) > ln:
            raise ValueError("overflow @0x%x: %d>%d (%r)" % (off, len(b), ln, es))
        raw[off:off + ln] = b + b"\x00" * (ln - len(b))
    return bytes(raw)

# ----------------------------- CLI -----------------------------
def _main(argv):
    cmd = argv[0] if argv else ""
    if cmd == "unpack":
        ver, ents = bra_read(argv[1]); out = argv[2]
        for e in ents:
            p = os.path.join(out, e["name"].replace("\\", "/"))
            os.makedirs(os.path.dirname(p) or ".", exist_ok=True)
            open(p, "wb").write(bra_getraw(e))
        print("unpacked %d files -> %s" % (len(ents), out))
    elif cmd == "repack":
        ver, ents = bra_read(argv[1]); folder = argv[2]
        for e in ents:
            p = os.path.join(folder, e["name"].replace("\\", "/"))
            if os.path.isfile(p):
                nb = open(p, "rb").read()
                if nb != bra_getraw(e): e["newraw"] = nb
        print("repacked", bra_write(argv[3], ver, ents), "bytes")
    elif cmd == "gstr-extract":
        d = open(argv[1], "rb").read()
        with open(argv[2], "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f); w.writerow(["id", "english", "spanish"])
            for ident, k, v in gstr_entries(d): w.writerow([ident, v, ""])
        print("extracted to", argv[2])
    elif cmd == "gstr-inject":
        d = open(argv[1], "rb").read(); trans = {}
        for row in csv.DictReader(open(argv[2], encoding="utf-8")):
            if row.get("spanish", "").strip(): trans[int(row["id"])] = row["spanish"]
        open(argv[3], "wb").write(gstr_rebuild(d, trans))
        print("injected %d strings -> %s" % (len(trans), argv[3]))
    else:
        print(__doc__)
        return 1
    return 0

if __name__ == "__main__":
    raise SystemExit(_main(sys.argv[1:]))
