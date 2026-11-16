# -*- coding: utf-8 -*-
# Symbian all_task.godat HAM görev kaydı çözücü -> kaynak/cikti/cozulmus/tablolar/gorev_ham.json
# Kullanım (depo kökünden): python3 tools/gorev_ham.py
#
# Neden: APK 1025 tablosu bu kaydı yanlış okumuş ("level" = hedef adedi, "exp" = bir metin bloğunun bayt boyu, ödül eşyalarının
# sınıf bilgisi kayıp). Orijinal altın, deneyim ve sınıfa göre ödül eşyaları yalnız bu ham kayıtta (bkz. docs/04-gorevler.md).
# Kayıt yapısı (uzunluk önekli UTF-16 metinler + int32):
#   [1000, başlık, hedef cümlesi, …, 3 konuşma bloğu (kabul / bekleme / bitiş; düğme eylemleri 11 = görevi al, 12 = teslim et),
#    ilerleme metni (%d), {veren sahne adı, veren adı}, 4 bayrak, verenSahne, verenId, teslimSahne, teslimId, teslim sahne adı, teslim adı,
#    0, sonrakiGörev, a, b, c, c × adet, 0, 0, ÖDÜL_BOYU, [altın, deneyim, W, n, n × eşya, 8 × 0], …, hedef başvuruları]
#   eşya = [eşyaId, adet, k, k × 7 sayı]  (k = 1 ise 3. sayı sınıf: 130001 savaşçı, 130002 büyücü, 130010 rahip; 0 = herkese)
import sys, struct, json
sys.path.insert(0, 'tools')
from godat import named

CLS = {130001: '战士', 130002: '法师', 130010: '牧师'}

def isstr(b, i):
    if i + 4 > len(b): return None
    n = struct.unpack_from('<I', b, i)[0]
    if not (1 <= n <= 600 and i + 4 + 2 * n <= len(b)): return None
    try: s = b[i + 4:i + 4 + 2 * n].decode('utf-16le')
    except UnicodeDecodeError: return None
    if not all(c.isprintable() or c in '\n\r\t' for c in s): return None
    if n <= 2 and not any(ord(c) > 0x2e80 for c in s): return None
    return s

def toks(b):
    out, i = [], 0
    while i + 4 <= len(b):
        s = isstr(b, i)
        if s is not None: out.append((i, s)); i += 4 + 2 * len(s); continue
        out.append((i, struct.unpack_from('<i', b, i)[0])); i += 4
    return out

I = lambda d, o: struct.unpack_from('<i', d, o)[0] if o + 4 <= len(d) else None

def parse(qid, d):
    t = toks(d)
    # çapa: [teslimSahne(120xxx), teslimId, sahne adı, teslim adı, 0, sonraki] — sondan aranır (başlıktaki metinler karışmasın)
    k = None
    for j in range(len(t) - 6, 3, -1):
        v = [x for _, x in t[j:j + 6]]
        if isinstance(v[0], int) and 120000 <= v[0] < 121000 and isinstance(v[1], int) and isinstance(v[2], str) and isinstance(v[3], str) and v[4] == 0 and isinstance(v[5], int):
            k = j; break
    if k is None: return None
    g = [x for _, x in t[k - 2:k]]   # veren sahne + veren (yoksa 0, 0)
    r = {'id': qid, 'title': t[1][1] if isinstance(t[1][1], str) else '', 'gsid': g[0] if isinstance(g[0], int) else 0, 'gnpc': g[1] if isinstance(g[1], int) else 0,
         'tsid': t[k][1], 'tnpc': t[k + 1][1], 'tscene': t[k + 2][1], 'tname': t[k + 3][1]}
    # veren adı: çapanın önündeki "sahne adı, ad" çifti (varsa)
    gs = [x for _, x in t[max(0, k - 8):k - 6]]
    r['gscene'], r['gname'] = (gs[0], gs[1]) if len(gs) == 2 and all(isinstance(x, str) for x in gs) else ('', '')
    o = t[k + 5][0]; r['next'] = I(d, o); o += 4
    r['a'], r['b'], c = I(d, o), I(d, o + 4), I(d, o + 8); o += 12
    if not (0 <= c <= 8): return dict(r, err='c')
    r['counts'] = [I(d, o + 4 * j) for j in range(c)]; o += 4 * c
    r['z'] = [I(d, o), I(d, o + 4)]; o += 8
    X = I(d, o); o += 4; end = o + X
    r['gold'], r['xp'], r['w'], n = I(d, o), I(d, o + 4), I(d, o + 8), I(d, o + 12); o += 16
    items = []
    for _ in range(max(0, min(n or 0, 12))):
        iid, cnt, kk = I(d, o), I(d, o + 4), I(d, o + 8); o += 12
        cls = []
        for _ in range(max(0, min(kk or 0, 4))):
            ex = [I(d, o + 4 * m) for m in range(7)]; o += 28
            if ex[2] in CLS: cls.append(CLS[ex[2]])
        items.append([str(iid), cnt] + ([cls[0]] if len(cls) == 1 else [cls] if cls else []))
    r['items'] = items
    if o > end: r['err'] = 'ödül bloğu taştı'
    r['extra'] = [I(d, m) for m in range(o, end, 4)] if o <= end else []
    # hedef başvuruları: ödül bloğundan sonra [0, 0, 0, blok boyu, sayı, (ad, id, sahne)…] — bayt bayt okunur
    # (genel okuyucu "1 + eşya numarası"nı tek harfli metin sanabildiği için toks kullanılmaz)
    refs = []; o = end + 12
    if o + 8 <= len(d):
        n = I(d, o + 4); o += 8
        for _ in range(max(0, min(n or 0, 16))):
            ln = I(d, o)
            if ln is None or not (0 <= ln <= 200) or o + 4 + 2 * ln + 8 > len(d): r['err'] = 'başvuru'; break
            nm = d[o + 4:o + 4 + 2 * ln].decode('utf-16le', 'replace'); o += 4 + 2 * ln
            refs.append([nm, I(d, o), I(d, o + 4)]); o += 8
    r['refs'] = refs
    return r

def main():
    R = {i: d for i, n, d in named('kaynak/orijinal/all_task.godat') if i < 10000000}
    out, bad = {}, []
    for i, d in sorted(R.items()):
        try: r = parse(i, d)
        except Exception as e: r = {'err': str(e)}
        if not r or 'err' in r: bad.append(i)
        if r: out[str(i)] = r
    json.dump(out, open('kaynak/cikti/cozulmus/tablolar/gorev_ham.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    print('kayıt', len(R), 'çözülen', len(out) - len(bad), 'sorunlu', len(bad), bad[:20])
    return out

if __name__ == '__main__':
    main()
