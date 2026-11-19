#!/usr/bin/env python3
"""C++ müzikleri: APK'nın orijinal kayıtları (kaynak/apk/cikti/ses/<parça>.wav, 8 kHz tek kanal) www/assets/music/<parça>.wav'a
kopyalanır (git aynı içeriği bir kez saklar) ve her parçanın ses yüksekliği HTML'nin çaldığı MP3'e eşitlenir:
www/assets/music/seviye.json = {"<parça>.mid": kazanç}. HTML'deki MP3'ler ses yüksekliği eşitlenerek üretilmiş (hepsi ortalama
−19,4 dB; orijinaller −11,8 … −14,3 dB), yani HTML'de müzik orijinalden kısık; C++ aynı duyulsun diye kazanç = RMS(mp3) / RMS(wav).
Çıktı üretilmiş veridir (elle düzenleme); müzik dosyaları değişince yeniden çalıştır. ffmpeg gerekir.
  python3 tools/muzik_cpp.py
"""
import json
import os
import shutil
import subprocess

import numpy as np

SRC, DST = 'kaynak/apk/cikti/ses', 'www/assets/music'


def pcm(path):
    """dosyayı tek kanal 32 bit kayan noktalı örneklere çöz (ffmpeg)"""
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', path, '-ac', '1', '-f', 'f32le', '-'], check=True, capture_output=True).stdout
    return np.frombuffer(raw, dtype=np.float32)


def rms(x):
    return float(np.sqrt(np.mean(np.square(x.astype(np.float64)))))


out = {}
for f in sorted(os.listdir(DST)):
    if not f.endswith('.mp3'):
        continue
    n = f[:-4]
    src = os.path.join(SRC, n + '.wav')
    shutil.copyfile(src, os.path.join(DST, n + '.wav'))
    g = rms(pcm(os.path.join(DST, f))) / rms(pcm(src))
    out[n + '.mid'] = round(g, 4)
    print('%-26s kazanç %.4f (%+.1f dB)' % (n, g, 20 * np.log10(g)))
with open(os.path.join(DST, 'seviye.json'), 'w', encoding='utf-8') as fp:
    json.dump({'kaynak': 'tools/muzik_cpp.py (elle düzenleme)', 'kazanc': out}, fp, ensure_ascii=False, indent=1)
print('%d parça → %s/seviye.json' % (len(out), DST))
