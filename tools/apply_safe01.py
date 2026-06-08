#!/usr/bin/env python3
"""
apply_safe.py - Aplicador SEGURO de traducciones in situ a ENExtend01.bra.

Toma uno o varios JSON {"EVENT\\SCRIPT\\<id>\\main.CL3": [[offset, len_orig, "es"], ...]}
y los aplica sobre ENExtend01.bra con TODAS las salvaguardas:

  * Valida cada línea contra el ORIGINAL (ENExtend01.bra.orig): el offset debe ser
    el inicio de una cadena terminada en nulo de longitud len_orig, y el español
    en UTF-8 debe caber (<= len_orig). Lo que no cumple, se DESCARTA (no se aplica).
  * Reempaqueta a un archivo temporal, verifica CRC de cada entrada modificada,
    y solo entonces reemplaza ENExtend01.bra. Si algo falla, no toca el original.
  * Actualiza progress.json con los eventos completados.

Uso: python3 apply_safe.py <game_dir> <progress.json> <trans1.json> [trans2.json ...]
Nunca corrompe el .bra: ante cualquier duda, descarta o aborta.
"""
import struct, zlib, binascii, json, sys, os

def bra_read(path):
    d = open(path, "rb").read(); ver, info_off, files = struct.unpack_from("<III", d, 4)
    pos = info_off; ents = []
    for _ in range(files):
        zsize, size = struct.unpack_from("<II", d, pos + 8)
        namesz, flags = struct.unpack_from("<HH", d, pos + 16)
        offset = struct.unpack_from("<I", d, pos + 20)[0]
        rawname = d[pos + 24:pos + 24 + namesz]; pos += 24 + namesz
        block = d[offset:offset + zsize]; bc = struct.unpack_from("<I", block, 4)[0]
        ents.append(dict(rawname=rawname, namesz=namesz, flags=flags, size=size, bc=bc,
                         extra=struct.unpack_from("<I", block, 12)[0], block=block,
                         name=rawname.split(b"\x00")[0].decode("latin1"), newraw=None))
    return ver, ents

def getraw(e):
    return zlib.decompress(e["block"][16:16 + e["bc"]], -15) if e["bc"] != e["size"] else e["block"][16:16 + e["size"]]

def bra_write(path, ver, ents):
    data = bytearray(); index = bytearray(); H = 16
    for e in ents:
        if e["newraw"] is not None:
            raw = e["newraw"]; comp = zlib.compress(raw, 9)[2:-4]
            crc = binascii.crc32(raw) & 0xffffffff
            block = struct.pack("<IIII", len(raw), len(comp), crc, e["extra"]) + comp; size = len(raw)
        else:
            block = e["block"]; crc = struct.unpack_from("<I", block, 8)[0]; size = e["size"]
        off = H + len(data); data += block
        index += struct.pack("<QIIHHI", 0x5770f0d5 | (crc << 32), len(block), size,
                             e["namesz"], e["flags"], off) + e["rawname"]
    buf = bytes(bytearray(b"PDA\x00" + struct.pack("<III", ver, H + len(data), len(ents))) + data + index)
    with open(path, "wb") as f:
        CH = 16 * 1024 * 1024
        for i in range(0, len(buf), CH):
            f.write(buf[i:i + CH]); f.flush()
        os.fsync(f.fileno())

def main():
    game = sys.argv[1]; progress_path = sys.argv[2]; jsons = sys.argv[3:]
    bra = os.path.join(game, "ENExtend01.bra")
    orig = os.path.join(game, "ENExtend01.bra.orig")
    assert os.path.exists(orig), "falta ENExtend01.bra.orig (backup)"

    merged = {}
    for jf in jsons:
        for ev, lines in json.load(open(jf, encoding="utf-8")).items():
            merged.setdefault(ev, []).extend(lines)

    _, oents = bra_read(orig); obyname = {e["name"]: e for e in oents}
    ver, ents = bra_read(bra); byname = {e["name"]: e for e in ents}

    applied = skipped = 0; touched = []
    for ev, lines in merged.items():
        e = byname.get(ev); oe = obyname.get(ev)
        if not e or not oe:
            skipped += len(lines); continue
        oraw = getraw(oe)             # validar contra ORIGINAL
        raw = bytearray(getraw(e))    # aplicar sobre ACTUAL (preserva trad. previas)
        ok_here = 0
        for off, ln, es in lines:
            if not isinstance(es, str):
                skipped += 1; continue
            b = es.encode("utf-8")
            if off + ln >= len(oraw) or oraw[off + ln] != 0 or (0 in oraw[off:off + ln]) or len(b) > ln:
                skipped += 1; continue
            raw[off:off + ln] = b + b"\x00" * (ln - len(b)); applied += 1; ok_here += 1
        if ok_here:
            e["newraw"] = bytes(raw); touched.append(ev)

    tmp = bra + ".tmp%d" % os.getpid()
    bra_write(tmp, ver, ents)
    # verificar CRC del temporal
    _, tents = bra_read(tmp)
    for e in tents:
        if e["name"] in touched:
            r = getraw(e)
            if (binascii.crc32(r) & 0xffffffff) != struct.unpack_from("<I", e["block"], 8)[0]:
                os.remove(tmp); print("CRC FAIL en %s -> ABORTADO, .bra intacto" % e["name"]); return 1
    os.replace(tmp, bra)

    # actualizar progreso
    prog = json.load(open(progress_path, encoding="utf-8")) if os.path.exists(progress_path) else {"done": []}
    done = set(prog.get("done", [])) | {ev.split("\\")[2] for ev in touched}
    prog["done"] = sorted(done)
    json.dump(prog, open(progress_path, "w", encoding="utf-8"))
    print("APLICADAS:%d  DESCARTADAS:%d  eventos:%d  total_hechos:%d" % (applied, skipped, len(touched), len(done)))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
