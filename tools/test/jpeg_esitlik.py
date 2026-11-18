#!/usr/bin/env python3
"""C++ JPEG çözücüsü ↔ libjpeg-turbo (Pillow) piksel karşılaştırması: www/assets altındaki bütün JPEG'ler.
   python3 tools/test/jpeg_esitlik.py   (önce: cmake --build native/build)"""
import glob, os, subprocess, sys, tempfile
from PIL import Image
files = sorted(glob.glob('www/assets/**/*.jpg', recursive=True))
tmp = tempfile.mkdtemp()
scen = os.path.join(tmp, 's.txt')
with open(scen, 'w') as f:
    for i, p in enumerate(files): f.write(f'jpeg {p} {tmp}/{i}.png\n')
subprocess.run(['native/build/anrufen_test', scen], check=True, stdout=subprocess.DEVNULL)
bad = 0
for i, p in enumerate(files):
    a = Image.open(p).convert('RGB'); b = Image.open(f'{tmp}/{i}.png').convert('RGB')
    if a.size != b.size: print(f'{p}: boy farklı {a.size} {b.size}'); bad += 1; continue
    A = a.tobytes(); B = b.tobytes(); n = sum(1 for k in range(0, len(A), 3) if A[k:k + 3] != B[k:k + 3]); mx = max((abs(x - y) for x, y in zip(A, B)), default=0)
    print(f'{p}: {a.size[0]}x{a.size[1]} · farklı piksel {n} · en büyük fark {mx}')
    bad += n > 0
print('hepsi birebir' if not bad else f'{bad} dosya farklı'); sys.exit(1 if bad else 0)
