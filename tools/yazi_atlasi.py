#!/usr/bin/env python3
"""Yazı atlası: C++ istemcisinin yazı tiplerini (HTML'deki ui.js/win.js/forms.js yazıları) harf tablolarına çevirir.

Kaynak: www/assets/fonts (Alegreya 400/700 gövde, Metamorphous başlık; woff2, latin + latin-ext) ve sistemdeki DejaVu (HTML'de
"Noto Serif"/serif/sans-serif yedekleri ve ✦ ★ ◎ gibi işaretler). Her (aile, boy) için bir PNG (gri: harfin örtüsü) ve
www/assets/fonts/atlas.json: harf yeri, kayması, ilerlemesi, satır ölçüleri, harf çifti aralıkları (kerning).
C++ (native/src/ui/font.cpp) bunları okur; dış çizgi (HTML strokeText) C++'ta harf örtüsünden üretilir.
Çıktı üretilmiş veridir: elle düzenleme; yazı tipi ya da boy değişince yeniden çalıştır.
  python3 tools/yazi_atlasi.py
"""
import json
import os

from PIL import Image, ImageDraw, ImageFont

FD = 'www/assets/fonts'
OUT = FD + '/atlas'
DJ = '/usr/share/fonts/truetype/dejavu/'
# aile: (latin dosyası, latin-ext dosyası ya da None, yedek DejaVu)
FAM = {
    'B': (FD + '/alegreya-latin-400-normal.woff2', FD + '/alegreya-latin-ext-400-normal.woff2', DJ + 'DejaVuSans.ttf'),
    'Bb': (FD + '/alegreya-latin-700-normal.woff2', FD + '/alegreya-latin-ext-700-normal.woff2', DJ + 'DejaVuSans-Bold.ttf'),
    'H': (FD + '/metamorphous-latin-400-normal.woff2', FD + '/metamorphous-latin-ext-400-normal.woff2', DJ + 'DejaVuSans.ttf'),
    'S': (DJ + 'DejaVuSerif-Bold.ttf', None, DJ + 'DejaVuSans-Bold.ttf'),    # "Noto Serif" bold / serif bold (duyurular, işaretler)
    'N': (DJ + 'DejaVuSans.ttf', None, None),                               # sans-serif
    'Nb': (DJ + 'DejaVuSans-Bold.ttf', None, None),
}
# boylar (HTML'de kullanılanlar ve pencerelerin label boyu + 1)
HALF = lambda a, b: [x / 2 for x in range(int(a * 2), int(b * 2) + 1)]   # yarım boy adımlarıyla (pencereler ekrana ölçeklenir)
SIZES = {
    'B': HALF(7, 18),
    'Bb': HALF(7, 18) + [24],                               # 24: giriş ekranındaki seçili sözcük (#tword)
    'H': HALF(9, 20),
    'S': [13, 14, 17, 18, 20, 28],
    'N': [6, 7, 8, 9, 10, 11, 12],                         # kısayol yuvası içindeki kilit/bekleme yazıları yuvanın ölçeğiyle büyür
    'Nb': [8, 9, 10, 11, 12, 13, 14, 16, 17],
}
# latin dosyasının kapsadığı aralıklar (fonts.css unicode-range); dışındakiler latin-ext dosyasından
LATIN = [(0x0000, 0x00FF), (0x0131, 0x0131), (0x0152, 0x0153), (0x02BB, 0x02BC), (0x02C6, 0x02C6), (0x02DA, 0x02DA), (0x02DC, 0x02DC),
         (0x0304, 0x0304), (0x0308, 0x0308), (0x0329, 0x0329), (0x2000, 0x206F), (0x20AC, 0x20AC), (0x2122, 0x2122), (0x2191, 0x2191),
         (0x2193, 0x2193), (0x2212, 0x2212), (0x2215, 0x2215), (0xFEFF, 0xFEFF), (0xFFFD, 0xFFFD)]
# karakterler: ASCII, Latin-1, Latin Genişletilmiş-A (Türkçe ve öteki Avrupa harfleri), noktalama, oklar ve oyunda geçen işaretler
CHARS = [c for c in range(0x20, 0x7F)] + [c for c in range(0xA0, 0x180)] + \
    [ord(c) for c in '–—‘’‚“”„•…‹›←↑→↓−▲▶▸▼▾◀◎●○■□★☆⚔✦✓✗♥']
KERN = [c for c in range(0x21, 0x7F)] + [ord(c) for c in 'ÇçĞğİıÖöŞşÜü']


def in_latin(cp):
    return any(a <= cp <= b for a, b in LATIN)


def glyph_missing(font, ch, notdef):
    """Harf yazı tipinde yoksa FreeType .notdef kutusunu çizer: onunla aynı örtü = yok."""
    m = font.getmask(ch)
    return m.size == notdef.size and bytes(m) == bytes(notdef) and m.size != (0, 0)


def build(fam, size):
    lat, ext, fb = FAM[fam]
    fl = ImageFont.truetype(lat, size)
    fe = ImageFont.truetype(ext, size) if ext else None
    ff = ImageFont.truetype(fb, size) if fb else None
    nd = {id(f): f.getmask('') for f in (fl, fe, ff) if f}
    asc, desc = fl.getmetrics()
    glyphs = []
    for cp in CHARS:
        ch = chr(cp)
        cand = [fl if (in_latin(cp) or not fe) else fe]
        if ff: cand.append(ff)
        font = None
        for f in cand:
            if ch == ' ' or not glyph_missing(f, ch, nd[id(f)]): font = f; break
        if not font: continue
        l, t, r, b = font.getbbox(ch, anchor='ls')
        adv = font.getlength(ch)
        w, h = max(0, r - l), max(0, b - t)
        im = None
        if w and h:
            im = Image.new('L', (w, h), 0)
            ImageDraw.Draw(im).text((-l, -t), ch, font=font, fill=255, anchor='ls')
            if not im.getbbox(): im, w, h = None, 0, 0
        glyphs.append((cp, w, h, l, t, adv, im))
    # raf yerleşimi
    W = 256; x = y = rowh = 0; pos = {}
    for cp, w, h, *_ in sorted(glyphs, key=lambda g: -g[2]):
        if not w: pos[cp] = (0, 0); continue
        if x + w + 1 > W: x = 0; y += rowh + 1; rowh = 0
        pos[cp] = (x, y); x += w + 1; rowh = max(rowh, h)
    H = max(1, y + rowh)
    atlas = Image.new('L', (W, H), 0)
    g = {}
    for cp, w, h, l, t, adv, im in glyphs:
        px, py = pos[cp]
        if im: atlas.paste(im, (px, py))
        g[str(cp)] = [px, py, w, h, l, t, round(adv, 4)]
    return atlas, {'size': size, 'asc': asc, 'desc': desc, 'g': g}


def kerning(fam):
    """Harf çifti aralıkları em cinsinden (40 px'te ölçülür; yazıda boyla çarpılır): aynı yazı tipi dosyasındaki çiftler."""
    lat, ext, _ = FAM[fam]; S = 40
    fl = ImageFont.truetype(lat, S); fe = ImageFont.truetype(ext, S) if ext else None
    k = {}
    for a in KERN:
        for b2 in KERN:
            ca, cb = chr(a), chr(b2)
            fa = fl if in_latin(a) or not fe else fe
            fbb = fl if in_latin(b2) or not fe else fe
            if fa is not fbb: continue
            d = fa.getlength(ca + cb) - fa.getlength(ca) - fa.getlength(cb)
            if abs(d) >= 0.2: k[ca + cb] = round(d / S, 4)
    return k


def main():
    os.makedirs(OUT, exist_ok=True)
    out = {}; kern = {}
    for fam, sizes in SIZES.items():
        kern[fam] = kerning(fam)
        for s in sizes:
            key = f'{fam}_{s:g}'
            atlas, meta = build(fam, s)
            atlas.save(f'{OUT}/{key}.png', optimize=True)
            meta['png'] = f'fonts/atlas/{key}.png'
            out[key] = meta
    with open(FD + '/atlas.json', 'w', encoding='utf-8') as f:
        json.dump({'kaynak': 'tools/yazi_atlasi.py (elle düzenleme)', 'kern': kern, 'yuzler': out}, f, ensure_ascii=False, separators=(',', ':'))
    tot = sum(os.path.getsize(f'{OUT}/{k}.png') for k in out)
    print(f'atlas: {len(out)} yüz, {sum(len(v["g"]) for v in out.values())} harf, PNG {tot // 1024} KB, json {os.path.getsize(FD + "/atlas.json") // 1024} KB')


if __name__ == '__main__':
    main()
