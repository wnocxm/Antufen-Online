# -*- coding: utf-8 -*-
# C++ godat eşitlik testi: kaynak/ altındaki bütün .godat dosyaları
#   1) C++ godat_dump ile Python tools/godat.py aynı kayıtları, aynı adları, aynı açılmış içeriği (boy + CRC32) veriyor mu;
#   2) her dosya GODAT3.0 şifreli pakete çevrilip (godat_pack) geri okununca içerik birebir aynı kalıyor mu.
# Önce derle: cmake -S native -B native/build -G Ninja && cmake --build native/build
# Kullanım: python3 tools/test/godat_esitlik.py   (PAKET=0: 2. adımı atla)
import glob, os, subprocess, sys, tempfile, time
sys.path.insert(0, 'tools')
from godat_ozet import ozet

B = 'native/build'
DUMP, PACK = os.path.join(B, 'godat_dump'), os.path.join(B, 'godat_pack')
if not (os.path.exists(DUMP) and os.path.exists(PACK)):
    sys.exit('önce derle: cmake -S native -B native/build -G Ninja && cmake --build native/build')
files = sorted(glob.glob('kaynak/**/*.godat', recursive=True))
paket = os.environ.get('PAKET', '1') != '0'
ok = bad = 0; kayit = 0; boy0 = boy1 = 0; t0 = time.time(); hatalar = []
tmp = tempfile.mkdtemp()
for f in files:
    py = ozet(f)
    cpp = subprocess.run([DUMP, f], capture_output=True, text=True)
    good = cpp.returncode == 0 and cpp.stdout == py
    if good and paket:
        out = os.path.join(tmp, 'p.gdp')
        r = subprocess.run([PACK, '-o', out, f], capture_output=True, text=True)
        back = subprocess.run([DUMP, out], capture_output=True, text=True)
        good = r.returncode == 0 and back.returncode == 0 and back.stdout == py
        if good: boy0 += os.path.getsize(f); boy1 += os.path.getsize(out)
    if good: ok += 1; kayit += int(py.split('\t', 2)[1].split('\n')[0])
    else: bad += 1; hatalar.append(f)
print('dosya %d · eşit %d · farklı %d · kayıt %d · %.1f sn' % (len(files), ok, bad, kayit, time.time() - t0))
if paket and boy0: print('paket boyu: orijinal %.1f MB → şifreli paket %.1f MB' % (boy0 / 1e6, boy1 / 1e6))
for f in hatalar[:10]: print('  FARKLI:', f)
sys.exit(1 if bad else 0)
