# Oyunun veri paketi: BÜTÜN sahneler, haritalar, görseller, animasyonlar ve paletler www/assets içine yazılır.
# Kullanım (depo kökünden):  python3 tools/pack_all.py
# Girdi: kaynak/orijinal (ham dosyalar) + kaynak/cikti/cozulmus (çözülmüş sahne, harita, animasyon, kayıt tablosu)
import sys, os, json, re, shutil, collections
sys.path.insert(0, 'tools')
import numpy as np
from PIL import Image
import godat
from lstr import lstrings
from extract_all import decode8

SRC, COZ, OUT = 'kaynak/orijinal', 'kaynak/cikti/cozulmus', 'www/assets'
reg = json.load(open(f'{COZ}/kayit.json', encoding='utf-8'))
scenes = json.load(open(f'{COZ}/sahneler.json', encoding='utf-8'))
rows = json.load(open(f'{COZ}/tablolar/anireg.json', encoding='utf-8'))
import struct
def strs(b):
    """Kayıttaki metinler (uzunluk + UTF-16). Tek karakterlik sekme/satır sonu 'metinleri' aslında bir sonraki metnin uzunluk alanıdır (9, 10, 13): atlanır."""
    out = []; i = 0
    while i + 4 <= len(b):
        n = struct.unpack_from('<I', b, i)[0]
        if 1 <= n <= 400 and i + 4 + 2 * n <= len(b):
            try:
                t = b[i + 4:i + 4 + 2 * n].decode('utf-16le')
                if all(c.isprintable() or c in '\n\r\t' for c in t) and not (n == 1 and t in '\t\n\r'):
                    out.append(t); i += 4 + 2 * n; continue
            except UnicodeDecodeError: pass
        i += 1
    return out
CIT = {i: strs(d) for i, n, d in godat.named(f'{SRC}/all_citizen.godat')}
MON = {i: strs(d) for i, n, d in godat.named(f'{SRC}/all_monster.godat')}
# nöbetçiler (şehir ve kamp muhafızları, kuleler): ayrı tabloda durur; oyunda NPC gibi yerleştirilir
for i, n, d in godat.named(f'{SRC}/all_guarder.godat'):
    if i not in CIT and i not in MON: CIT[i] = strs(d)

# ---------- geçitler: hedef sahne numarası ----------
# Orijinal tabloda geçit yalnızca hedefin ADINI taşır; aynı adlı birden çok sahne (kanal kopyaları, zindan katları) olabilir.
# Seçim: geri dönüş geçidi bu sahnenin adını taşıyan aday; birden çoksa numarası en yakın olan.
by_name = collections.defaultdict(list)
for sid, s in scenes.items(): by_name[s['name']].append(sid)
clean = lambda n: n.replace('(入口)', '')
amb = 0
for sid, s in scenes.items():
    for e in s['exits']:
        c = by_name.get(clean(e[1]), [])
        if len(c) > 1:
            back = [x for x in c if any(clean(b[1]) == s['name'] for b in scenes[x]['exits'])] or c
            c = sorted(back, key=lambda x: abs(int(x) - int(sid))); amb += 1
        e[:] = [e[0], e[1], c[0] if c else None]

# kesin hedefler: Android sürümünün geçit tablosu (sahne, kapı) -> hedef sahne. Tahmini eşleşmenin yanıldığı yerleri (lağım labirenti) düzeltir.
fixed = 0
if os.path.exists('kaynak/apk/gecitler.json'):
    G = json.load(open('kaynak/apk/gecitler.json'))
    for sid, s in scenes.items():
        for e in s['exits']:
            t = G.get(f'{sid}:{e[0]}')
            if t and t in scenes and t != e[2]: e[2] = t; fixed += 1
print('geçit tablosundan düzeltilen', fixed)

# ---------- sahne seviyesi: harita dosyası adının sonundaki sayı (…-10, …-50); yoksa komşulardan ----------
for sid, s in scenes.items():
    m = re.search(r'-(\d+)$', s['map']); s['lv'] = int(m.group(1)) if m and int(m.group(1)) >= 10 else 0
# gerçek seviye aralıkları: Android sürümünün dünya haritası tablosundaki adlardan ("…(27-29级)")
if os.path.exists('kaynak/apk/seviyeler.json'):
    for sid, r in json.load(open('kaynak/apk/seviyeler.json')).items():
        if sid in scenes: scenes[sid]['lvr'] = r; scenes[sid]['lv'] = r[1]
for _ in range(6):
    for sid, s in scenes.items():
        if s['lv']: continue
        nb = [scenes[e[2]]['lv'] for e in s['exits'] if e[2] and scenes[e[2]]['lv']]
        if nb: s['nlv'] = min(nb)
    for s in scenes.values():
        if 'nlv' in s: s['lv'] = s.pop('nlv')

# ---------- gereken görseller ----------
need = set(); cit = {}; mon = {}
for sid, s in scenes.items():
    m = json.load(open(f"{COZ}/harita/{s['map']}.json", encoding='utf-8'))
    need.update(m['names'])
    for id_, nm, pos in s['ents']:
        info = CIT.get(id_) or MON.get(id_)
        if id_ in CIT: cit[id_] = CIT[id_]
        if id_ in MON: mon[id_] = MON[id_]
        if info: need.update(x for x in info[1:4] if x in reg)
for k in reg:
    if re.match(r'^(group\d|default|frame_|HORSE|特效|LEVELUP|BLOOD|SPECIAL|LIGHT|RESUME|RELIVE|WATER|FIRE|EFFECT|特性|PET-|NPC-|路标|怪物)', k): need.add(k)
sub = dict(reg)   # kayıt tablosunun tamamı (evcil hayvanlar, binekler, efektler dahil)

# ---------- görseller (renk numarası + saydamlık), paletler ----------
os.makedirs(f'{OUT}/sheets', exist_ok=True); os.makedirs(f'{OUT}/maps', exist_ok=True)
CACHE = {}
def recs(f):
    if f not in CACHE: CACHE[f] = {i: d for i, n, d in godat.named(f'{SRC}/{f}.godat')}
    return CACHE[f]
palidx = {}; blob = bytearray(); anis = set(); bad = []
def add_pal(key, P):
    if key not in palidx: palidx[key] = len(blob) // 768; blob.extend(bytes(P))
done = set()
for k, r in sorted(sub.items()):
    f, bmp, ani, pal = r[:4]; key = f'{f}_{bmp}'
    if ani: anis.add(f'{f}_{ani}')
    if key not in done:
        done.add(key)
        try:
            P, L, A = decode8(recs(f)[bmp])
            Image.merge('LA', (Image.fromarray(L, 'L'), Image.fromarray(A, 'L'))).save(f'{OUT}/sheets/{key}.png', optimize=True)
            add_pal(key, P.astype(np.uint8).tobytes())
        except Exception as e: bad.append((key, str(e)[:60]))
    if pal:
        d = recs(f).get(pal)
        if d and d[:4] == b'RIFF': p = d[24:24 + 1024]; add_pal(f'{f}_{pal}', bytes(p[i * 4 + c] for i in range(256) for c in range(3)))
frames = {r[0]: int(r[3]) for r in rows if r[0].startswith('frame_')}
for v in frames.values(): anis.add(f'frame_ani_{v}')
anij = {a: json.load(open(f'{COZ}/animasyon/{a}.json')) for a in sorted(anis) if os.path.exists(f'{COZ}/animasyon/{a}.json')}
json.dump(anij, open(f'{OUT}/ani.json', 'w'), separators=(',', ':'))
open(f'{OUT}/pal.bin', 'wb').write(blob)
for mid in {s['map'] for s in scenes.values()}: shutil.copy(f'{COZ}/harita/{mid}.json', f'{OUT}/maps/{mid}.json')
data = dict(frames=frames, reg=sub, palidx=palidx, scenes=scenes, cit=cit, mon=mon)
json.dump(data, open(f'{OUT}/data.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('sahne', len(scenes), 'belirsiz geçit çözüldü', amb, 'kayıt', len(sub), 'görsel', len(done), 'animasyon', len(anij), 'palet', len(palidx), 'npc', len(cit), 'canavar', len(mon))
print('seviyesiz sahne', sum(1 for s in scenes.values() if not s['lv']), 'hata', len(bad), bad[:10])
