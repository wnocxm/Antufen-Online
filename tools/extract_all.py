# Orijinal oyun dosyalarının TAMAMINI çıkarır: görseller, paletler, sesler, müzikler, ekran tanımları, betikler, tablolar, metinler.
# Kullanım (depo kökünden):  python3 tools/extract_all.py
# Girdi: kaynak/orijinal/*.godat   Çıktı: kaynak/cikti/...   Dökümü: kaynak/cikti/dokum.json
import sys, os, struct, zlib, json, glob, wave, collections
sys.path.insert(0, 'tools')
import numpy as np
from PIL import Image
import godat
from lstr import lstrings

SRC, OUT = 'kaynak/orijinal', 'kaynak/cikti'
def mk(p): os.makedirs(p, exist_ok=True); return p

def chunks(b, p, need):
    """(sıkışık boy, ham boy) başlıklı parçaları 'need' bayta ulaşana dek okur"""
    out = b''
    while p + 8 <= len(b) and len(out) < need:
        cs, rs = struct.unpack_from('<II', b, p); p += 8
        if cs == 0 or p + cs > len(b): break
        out += zlib.decompress(b[p:p + cs]) if rs else b[p:p + cs]; p += cs
    return out, p

def spans(table, h):
    sp = []; q = 0
    for y in range(h):
        if q + 2 > len(table): break
        n = struct.unpack_from('<H', table, q)[0] // 8; q += 2
        for s in range(n):
            off, x0, x1 = struct.unpack_from('<IHH', table, q); q += 8; sp.append((y, off, x0, x1))
    return sp

def image8(b):
    """256 renkli görsel -> RGBA. Düz (satırlar 4 bayta tamamlanır) ya da satır-aralık sıkıştırmalı; bazıları piksel başına renk + saydamlık taşır."""
    hdr = struct.unpack_from('<6I', b, 0); w, h = hdr[3], hdr[4]
    a = b.find(b'\x78\x9c', 24); cs, rs = struct.unpack_from('<II', b, a - 8)
    epal = zlib.decompress(b[a:a + cs]); p = a + cs
    pal = np.frombuffer(epal[:1024], dtype=np.uint8).reshape(256, 4)[:, [2, 1, 0]]
    L = np.zeros((h, w), np.uint8); A = np.zeros((h, w), np.uint8)
    if hdr[5] in (1, 3):
        # çok kareli görsel: kare boyu başlıkta (24, 28); kareler soldan sağa, her biri ayrı parça(lar) halinde
        fw, fh = struct.unpack_from('<II', b, 24); key = (pal[:, 0] == 255) & (pal[:, 1] == 0) & (pal[:, 2] == 255)
        for fy in range(h // fh):
            for fx in range(w // fw):
                if hdr[5] == 1:
                    st = (fw + 3) & ~3; px, p = chunks(b, p, 1)
                    row = st if len(px) >= st * fh else fw
                    fr = np.frombuffer(px[:row * fh], np.uint8).reshape(fh, row)[:, :fw]
                    L[fy * fh:(fy + 1) * fh, fx * fw:(fx + 1) * fw] = fr; A[fy * fh:(fy + 1) * fh, fx * fw:(fx + 1) * fw] = np.where(key[fr], 0, 255)
                else:
                    table, p = chunks(b, p, 1); px, p = chunks(b, p, 1); pxa = np.frombuffer(px, np.uint8)
                    for y, off, x0, x1 in spans(table, fh):
                        x1 = min(x1, fw); n = x1 - x0
                        if n <= 0: continue
                        seg = pxa[off:off + n]; L[fy * fh + y, fx * fw + x0:fx * fw + x0 + len(seg)] = seg; A[fy * fh + y, fx * fw + x0:fx * fw + x0 + len(seg)] = 255
    elif hdr[5] == 0:
        st = (w + 3) & ~3
        px, p = chunks(b, p, st * h)
        if len(px) >= st * h: L = np.frombuffer(px[:st * h], np.uint8).reshape(h, st)[:, :w].copy()
        elif len(px) >= w * h: L = np.frombuffer(px[:w * h], np.uint8).reshape(h, w).copy()
        else: raise ValueError('eksik piksel')
        key = (pal[:, 0] == 255) & (pal[:, 1] == 0) & (pal[:, 2] == 255)
        A = np.where(key[L], 0, 255).astype(np.uint8)
    else:
        groups = []
        while p + 8 <= len(b):
            tot, cnt = struct.unpack_from('<II', b, p); p += 8; parts = []
            for k in range(cnt):
                cs, rs = struct.unpack_from('<II', b, p); p += 8
                parts.append(zlib.decompress(b[p:p + cs]) if rs else b[p:p + cs]); p += cs
            groups.append(b''.join(parts))
        table, px = groups[0], groups[1]; sp = spans(table, h)
        two = len(sp) > 1 and all(y[1] - x[1] == 2 * (x[3] - x[2]) for x, y in zip(sp, sp[1:])) and not all(y[1] - x[1] == (x[3] - x[2]) for x, y in zip(sp, sp[1:]))
        pxa = np.frombuffer(px, np.uint8)
        for y, off, x0, x1 in sp:
            x1 = min(x1, w); n = x1 - x0
            if n <= 0: continue
            if two: seg = pxa[off:off + 2 * n]; L[y, x0:x0 + len(seg[0::2])] = seg[0::2]; A[y, x0:x0 + len(seg[1::2])] = seg[1::2]
            else: seg = pxa[off:off + n]; L[y, x0:x0 + len(seg)] = seg; A[y, x0:x0 + len(seg)] = 255
    return Image.fromarray(np.dstack([pal[L], A]).astype(np.uint8), 'RGBA')

def rgb565(a):
    return np.dstack([((a >> 11) & 31) * 255 // 31, ((a >> 5) & 63) * 255 // 63, (a & 31) * 255 // 31]).astype(np.uint8)

def image16(b):
    """65 bin renkli (RGB565) görsel -> RGBA. Düz ya da satır-aralık sıkıştırmalı."""
    hdr = struct.unpack_from('<6I', b, 0); w, h = hdr[3], hdr[4]
    if hdr[5] == 0:
        raw, p = chunks(b, 36, w * h * 2)
        if len(raw) < w * h * 2: raise ValueError('eksik piksel')
        a = np.frombuffer(raw[:w * h * 2], '<u2').reshape(h, w)
        rgb = rgb565(a); al = np.where(a == 0xF81F, 0, 255).astype(np.uint8)
        return Image.fromarray(np.dstack([rgb, al]), 'RGBA')
    p = 36; groups = []
    while p + 8 <= len(b):
        tot, cnt = struct.unpack_from('<II', b, p); p += 8; parts = []
        for k in range(cnt):
            cs, rs = struct.unpack_from('<II', b, p); p += 8
            parts.append(zlib.decompress(b[p:p + cs]) if rs else b[p:p + cs]); p += cs
        groups.append(b''.join(parts))
    table, px = groups[0], groups[1]; sp = spans(table, h)
    out = np.zeros((h, w, 4), np.uint8)
    step = None
    for x, y in zip(sp, sp[1:]):
        if x[3] > x[2]: step = (y[1] - x[1]) // (x[3] - x[2]); break
    step = step or 2
    for y, off, x0, x1 in sp:
        x1 = min(x1, w); n = x1 - x0
        if n <= 0: continue
        seg = np.frombuffer(px[off:off + step * n], np.uint8)
        if len(seg) < step * n: continue
        if step == 2: a = seg.view('<u2'); out[y, x0:x1, :3] = rgb565(a.reshape(1, -1))[0]; out[y, x0:x1, 3] = 255
        else: s = seg.reshape(n, step); a = (s[:, 0].astype(np.uint16) | (s[:, 1].astype(np.uint16) << 8)); out[y, x0:x1, :3] = rgb565(a.reshape(1, -1))[0]; out[y, x0:x1, 3] = s[:, 2]
    return Image.fromarray(out, 'RGBA')

def kind(d, name):
    if d[:4] == b'MThd': return 'midi'
    if d[:4] == b'RIFF': return 'pal'
    if d[:6] == b'UIFORM': return 'form'
    if name.endswith('.pcm'): return 'pcm'
    if name.endswith(('.lua', '.ini')): return 'text'
    if len(d) >= 24 and d[:4] == b'\0\0\0\0':
        h = struct.unpack_from('<6I', d, 0)
        if h[1] in (8, 16) and 0 < h[3] <= 4096 and 0 < h[4] <= 4096 and h[2] < 64: return 'img%d' % h[1]
    if d[:2] == b'\xff\xfe': return 'utf16'
    return 'data'

def main():
    rep = collections.OrderedDict(); fails = []; tot = collections.Counter()
    files = sorted(glob.glob(SRC + '/*.godat'))
    for fi, f in enumerate(files):
        base = os.path.basename(f)[:-6]
        try: recs = godat.named(f)
        except Exception as e: fails.append((base, 'dosya', str(e))); continue
        c = collections.Counter(); table = []
        for id_, name, d in recs:
            k = kind(d, name); c[k] += 1
            try:
                if k in ('img8', 'img16'):
                    im = image8(d) if k == 'img8' else image16(d)
                    im.save(os.path.join(mk(f'{OUT}/gorsel/{base}'), f'{id_}.png'), optimize=False)
                elif k == 'pal': open(os.path.join(mk(f'{OUT}/palet/{base}'), f'{id_}.pal'), 'wb').write(d)
                elif k == 'midi': open(os.path.join(mk(f'{OUT}/muzik'), name.replace('\\', '/').split('/')[-1]), 'wb').write(d)
                elif k == 'pcm':
                    w = wave.open(os.path.join(mk(f'{OUT}/ses'), name.replace('\\', '/').split('/')[-1][:-4] + '.wav'), 'wb')
                    w.setnchannels(1); w.setsampwidth(2); w.setframerate(8000); w.writeframes(d); w.close()
                elif k == 'text':
                    p = os.path.join(mk(f'{OUT}/betik/{base}'), name.replace('\\', '/').split('/')[-1]); open(p, 'wb').write(d)
                elif k == 'utf16': open(os.path.join(mk(f'{OUT}/metin/{base}'), f'{id_}.txt'), 'w', encoding='utf-8').write(d.decode('utf-16', 'replace'))
                elif k == 'form': open(os.path.join(mk(f'{OUT}/form/{base}'), f'{id_}.bin'), 'wb').write(d); table.append({'id': id_, 'metin': [s for o, s in lstrings(d)]})
                else:
                    ss = [s for o, s in lstrings(d)]
                    table.append({'id': id_, 'ad': name, 'boy': len(d), 'metin': ss} if name else {'id': id_, 'boy': len(d), 'metin': ss})
            except Exception as e:
                fails.append((base, id_, k + ': ' + str(e)[:80])); c['HATA'] += 1
                open(os.path.join(mk(f'{OUT}/ham/{base}'), f'{id_}.bin'), 'wb').write(d)
        if table: json.dump(table, open(os.path.join(mk(f'{OUT}/tablo'), base + '.json'), 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
        rep[base] = dict(c); tot.update(c)
        if fi % 40 == 0: print(f'{fi}/{len(files)} {base}', flush=True)
    json.dump({'toplam': dict(tot), 'dosyalar': rep, 'hatalar': fails}, open(f'{OUT}/dokum.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('TOPLAM', dict(tot)); print('HATA', len(fails)); [print(' ', x) for x in fails[:40]]

if __name__ == '__main__': main()
