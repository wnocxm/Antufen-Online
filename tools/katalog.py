# Katalog verisi: kaynak/cikti içindeki her şeyin listesi (kaynak/index.html bunu okur).
# Kullanım (depo kökünden):  python3 tools/katalog.py
import os, json, glob, collections
from PIL import Image
C = 'kaynak/cikti'
sc = json.load(open(f'{C}/cozulmus/sahneler.json', encoding='utf-8'))
have = sorted(os.path.basename(f) for f in glob.glob(f'{C}/muzik/*.mid'))
by = collections.defaultdict(list)
for k, s in sc.items(): by[s.get('music') or ''].append(k)
imgs = {}
for d in sorted(glob.glob(f'{C}/gorsel/*')):
    L = []
    for f in sorted(glob.glob(d + '/*.png'), key=lambda x: int(os.path.basename(x)[:-4])):
        w, h = Image.open(f).size; L.append([int(os.path.basename(f)[:-4]), w, h])
    imgs[os.path.basename(d)] = L
tabs = {os.path.basename(f)[:-5]: len(json.load(open(f, encoding='utf-8'))) for f in sorted(glob.glob(f'{C}/tablo/*.json'))}
out = {
    'muzik': [{'ad': m, 'var': m in have, 'sahneler': by[m]} for m in sorted(k for k in by if k)],
    'ses': sorted(os.path.basename(f) for f in glob.glob(f'{C}/ses/*.wav')),
    'sahne': {k: [s['name'], s['map'], s.get('music') or '', len(s['ents']), [e[1] for e in s.get('exits', [])]] for k, s in sc.items()},
    'gorsel': imgs, 'tablo': tabs,
    'harita': sorted(os.path.basename(f)[:-5] for f in glob.glob(f'{C}/cozulmus/harita/*.json')),
    'betik': sorted(os.path.relpath(f, C) for f in glob.glob(f'{C}/betik/*/*')),
    'dokum': json.load(open(f'{C}/dokum.json', encoding='utf-8'))['toplam'],
}
json.dump(out, open(f'{C}/katalog.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print({k: len(v) for k, v in out.items()}, sum(len(v) for v in imgs.values()), 'görsel')
