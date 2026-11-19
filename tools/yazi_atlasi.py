#!/usr/bin/env python3
"""Yazı atlası: C++ istemcisinin yazı tiplerini (HTML'deki ui.js/win.js/forms.js yazıları) harf tablolarına çevirir.

Kaynak: www/assets/fonts (Alegreya 400/700 gövde, Metamorphous başlık; woff2, latin + latin-ext) ve sistemdeki DejaVu (HTML'de
"Noto Serif"/serif/sans-serif yedekleri ve ✦ ★ ◎ ✕ gibi işaretler). Her (aile, boy) için bir PNG (gri: harfin örtüsü) ve
www/assets/fonts/atlas.json: harf yeri, kayması, ilerlemesi, satır ölçüleri, harf çifti aralıkları (kerning).
İlerlemeler ve harf çifti aralıkları tarayıcı gibi HarfBuzz'la (Pillow RAQM) ve yuvarlanmadan ölçülür (büyük boyda ölçüp küçültülür):
tarayıcının DOM yerleşimi (GM paneli düğmelerinin genişliği) bunlarla 1/64 px'e kadar aynı çıkar.
Renkli emoji (GM paneli sekmeleri 🗺 ⚔ 🐾 🎓; Android'deki Noto Color Emoji): fonts/atlas/emoji.png + atlas.json "emoji".
C++ (native/src/ui/font.cpp) bunları okur; dış çizgi (HTML strokeText) C++'ta harf örtüsünden üretilir.
Çıktı üretilmiş veridir: elle düzenleme; yazı tipi ya da boy değişince yeniden çalıştır.
  python3 tools/yazi_atlasi.py
"""
import json
import math
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
    [ord(c) for c in '–—‘’‚“”„•…‹›←↑→↓−▲▶▸▼▾◀◎●○■□★☆⚔✦✓✗✕♥']
KERN = [c for c in range(0x21, 0x7F)] + [ord(c) for c in 'ÇçĞğİıÖöŞşÜü']
SS = 4   # harf görüntüleri bu kat büyük çizilip küçültülür
EMOJI_FONT = '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf'
EMOJI = '🗺⚔🐾🎓'
EMOJI_PPEM = 109   # Noto Color Emoji'nin tek bit eşlem boyu (136 x 128)


def upem(path):
    """Yazı tipinin em birimi (1000 / 2048): bu boyda ilerlemeler tam sayı birimdir (ölçüm yuvarlamasız)."""
    for u in (1000, 2048):
        F = ImageFont.truetype(path, u, layout_engine=ImageFont.Layout.RAQM)
        if all(abs(F.getlength(c) - round(F.getlength(c))) < 1e-6 for c in 'aAgW.,iMx'): return u
    return 2048


def unit_font(path):
    """Yazı tipi em biriminde (1 px = 1 birim): ilerleme ve harf çifti aralığı birebir."""
    u = upem(path)
    return ImageFont.truetype(path, u, layout_engine=ImageFont.Layout.RAQM), u


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
    hi = {id(f): unit_font(path) for f, path in ((fl, lat), (fe, ext), (ff, fb)) if f}
    big = {id(f): ImageFont.truetype(path, size * SS) for f, path in ((fl, lat), (fe, ext), (ff, fb)) if f}   # harf görüntüsü SS kat büyük çizilir
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
        # tarayıcı (Skia + FreeType): ilerleme = birim × x_scale; x_scale = FT_DivFix(boy × 64, em) 16.16 sabit noktada yuvarlanır
        U, u = hi[id(font)]; adv = round(U.getlength(ch)) * round(size * 64 * 65536 / u) / 4194304
        # harf: SS kat büyük, ipucusuza yakın çizilip alan ortalamasıyla küçültülür (tarayıcı Linux'ta yatay ipucu kullanmaz; harfin
        # kalınlığı ve yeri bozulmaz). Başlangıç noktası tam piksel; kesirli konumu C++ çeyrek piksel kaydırmayla verir.
        B = big[id(font)]; L4, T4, R4, B4 = B.getbbox(ch, anchor='ls')
        l, t = math.floor(L4 / SS), math.floor(T4 / SS)
        w, h = max(0, math.ceil(R4 / SS) - l), max(0, math.ceil(B4 / SS) - t)
        im = None
        if w and h and R4 > L4 and B4 > T4:
            im = Image.new('L', (w * SS, h * SS), 0)
            ImageDraw.Draw(im).text((-l * SS, -t * SS), ch, font=B, fill=255, anchor='ls')
            im = im.resize((w, h), Image.BOX)
            if not im.getbbox(): im, w, h = None, 0, 0
        else: w = h = 0
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
        g[str(cp)] = [px, py, w, h, l, t, round(adv, 7)]
    return atlas, {'size': size, 'asc': asc, 'desc': desc, 'g': g}


def kerning(fam, lang=None):
    """Harf çifti aralıkları em cinsinden (HarfBuzz/GPOS; em biriminde ölçülür, yazıda boyla çarpılır): aynı yazı tipi dosyasındaki çiftler.
    lang 'tr': DOM yazısı (sayfa lang="tr"; Türkçe kuralı "fi" bitişik harfini kapatır); tuval yazısı dilsiz şekillenir."""
    lat, ext, _ = FAM[fam]
    fl, S = unit_font(lat); fe = unit_font(ext)[0] if ext else None
    L = {}
    k = {}
    for a in KERN:
        for b2 in KERN:
            ca, cb = chr(a), chr(b2)
            fa = fl if in_latin(a) or not fe else fe
            fbb = fl if in_latin(b2) or not fe else fe
            if fa is not fbb: continue
            if (id(fa), ca) not in L: L[(id(fa), ca)] = fa.getlength(ca)
            if (id(fbb), cb) not in L: L[(id(fbb), cb)] = fbb.getlength(cb)
            d = fa.getlength(ca + cb, language=lang) - L[(id(fa), ca)] - L[(id(fbb), cb)]
            if abs(d) / S >= 0.0001: k[ca + cb] = round(d / S, 5)
    return k


def kerning_space(fam):
    """Boşluklu harf çiftleri (ör. '. '): tarayıcı DOM yazısında uygular, tuval yazısında (fillText) uygulamaz; yalnız DOM genişliği için."""
    lat, ext, _ = FAM[fam]
    fl, S = unit_font(lat); fe = unit_font(ext)[0] if ext else None
    sp = fl.getlength(' '); k = {}
    for a in sorted(set(KERN) | {c for c in CHARS if c > 0x20 and in_latin(c)}):   # boşluğun yanındaki her harf ve işaret (· – … gibi)
        ch = chr(a); f = fl if in_latin(a) or not fe else fe
        if f is not fl: continue
        la = fl.getlength(ch)
        for pair in (ch + ' ', ' ' + ch):
            d = fl.getlength(pair, language='tr') - la - sp
            if abs(d) / S >= 0.0001: k[pair] = round(d / S, 5)
    return k


def emoji():
    """Renkli emoji: Noto Color Emoji'nin bit eşlemleri (109 px) tek RGBA görselde; [x, y, g, y, sol, üst (taban çizgisinden), ilerleme]."""
    F = ImageFont.truetype(EMOJI_FONT, EMOJI_PPEM)
    ims = []
    for ch in EMOJI:
        l, t, r, b = F.getbbox(ch, anchor='ls')
        im = Image.new('RGBA', (r - l, b - t), (0, 0, 0, 0))
        ImageDraw.Draw(im).text((-l, -t), ch, font=F, embedded_color=True, anchor='ls')
        ims.append((ord(ch), l, t, im))
    W = sum(im.width + 1 for *_, im in ims); H = max(im.height for *_, im in ims)
    atlas = Image.new('RGBA', (W, H), (0, 0, 0, 0)); meta = {}; x = 0
    for cp, l, t, im in ims:
        atlas.paste(im, (x, 0)); meta[str(cp)] = [x, 0, im.width, im.height, l, t, 136]; x += im.width + 1
    atlas.save(f'{OUT}/emoji.png', optimize=True)
    return {'png': 'fonts/atlas/emoji.png', 'ppem': EMOJI_PPEM, 'g': meta}


def main():
    os.makedirs(OUT, exist_ok=True)
    out = {}; kern = {}; kern_dom = {}
    for fam, sizes in SIZES.items():
        kern[fam] = kerning(fam); kern_dom[fam] = {**kerning(fam, 'tr'), **kerning_space(fam)}   # DOM: Türkçe çiftler + boşluklu çiftler
        for s in sizes:
            key = f'{fam}_{s:g}'
            atlas, meta = build(fam, s)
            atlas.save(f'{OUT}/{key}.png', optimize=True)
            meta['png'] = f'fonts/atlas/{key}.png'
            out[key] = meta
    with open(FD + '/atlas.json', 'w', encoding='utf-8') as f:
        json.dump({'kaynak': 'tools/yazi_atlasi.py (elle düzenleme)', 'kern': kern, 'kernDom': kern_dom, 'yuzler': out, 'emoji': emoji()}, f, ensure_ascii=False, separators=(',', ':'))
    tot = sum(os.path.getsize(f'{OUT}/{k}.png') for k in out)
    print(f'atlas: {len(out)} yüz, {sum(len(v["g"]) for v in out.values())} harf, PNG {tot // 1024} KB, json {os.path.getsize(FD + "/atlas.json") // 1024} KB')


if __name__ == '__main__':
    main()
