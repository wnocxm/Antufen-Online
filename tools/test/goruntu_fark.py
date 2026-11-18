# -*- coding: utf-8 -*-
# İki görüntüyü piksel piksel karşılaştırır (C++ ↔ HTML; tools/test/cpp_karsilastir.js çağırır).
#   python3 tools/test/goruntu_fark.py <klasör> <ad> [ad …]   → <ad>_html.png ile <ad>_cpp.png; <ad>_fark.png (yan yana + farklar kırmızı)
# Farklı piksel: herhangi bir kanalda 3'ten büyük fark (tarayıcının saydamlık yuvarlaması tolerans içinde kalır). Sınır: SINIR=%
# (varsayılan 0,1); yalnız yan yana görüntü için SINIR=100.
import sys, os
from PIL import Image, ImageChops

d = sys.argv[1]; worst = 0; LIM = float(os.environ.get('SINIR', '0.1'))
for ad in sys.argv[2:]:
    a = Image.open(os.path.join(d, ad + '_html.png')).convert('RGB'); b = Image.open(os.path.join(d, ad + '_cpp.png')).convert('RGB')
    if a.size != b.size: print('%-12s boyut farklı %s / %s' % (ad, a.size, b.size)); worst = 100; continue
    diff = ImageChops.difference(a, b); px = diff.load(); W, H = a.size; n = 0
    mask = Image.new('RGB', a.size, (0, 0, 0)); mp = mask.load()
    for y in range(H):
        for x in range(W):
            if max(px[x, y]) > 3: n += 1; mp[x, y] = (255, 0, 0)
    pct = 100.0 * n / (W * H); worst = max(worst, pct)
    side = Image.new('RGB', (W * 3, H)); side.paste(a, (0, 0)); side.paste(b, (W, 0)); side.paste(Image.blend(b, mask, 0.6), (W * 2, 0))
    side.save(os.path.join(d, ad + '_fark.png'))
    print('%-12s farklı piksel %6d / %d (%.3f%%)' % (ad, n, W * H, pct))
print('en kötü: %.3f%%' % worst, '· GEÇTİ' if worst < LIM else '· KALDI (sınır %%%g)' % LIM)
sys.exit(0 if worst < LIM else 1)
