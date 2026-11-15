# Dünya haritası: Android sürümündeki renkli bölge resimlerinden kıta haritasını birleştirir, bölge/sahne yerleşimini yazar.
# Kullanım (depo kökünden):  python3 tools/dunya.py     Çıktı: www/assets/wm/ (world.jpg, r1..r7.jpg, simgeler, wm.json)
import json, os, re
from PIL import Image
A = 'kaynak/apk/cikti'; G = f'{A}/gorsel/UIData_iphone'; OUT = 'www/assets/wm'; os.makedirs(OUT, exist_ok=True)
# bölge resmi -> kıta üzerindeki konumu (mürekkep haritayla eşleştirilerek bulundu) ve yerleşim tablosundaki bölge numarası
REG = {1: (2063, 0, 0), 3: (2064, 0, 448), 2: (2065, 0, 960), 4: (2066, 704, 0), 5: (2067, 832, 448), 6: (2068, 1024, 896), 7: (2069, 608, 960)}
W = Image.new('RGB', (1760, 1504), (96, 92, 88))
for ai, (k, x, y) in REG.items(): W.paste(Image.open(f'{G}/{k}.png').convert('RGB'), (x, y))
W.paste(W.crop((900, 950, 964, 1398)), (640, 0))   # resimlerin kapsamadığı dar deniz şeridi
W.resize((1100, 940), Image.LANCZOS).save(f'{OUT}/world.jpg', quality=86)
for ai, (k, x, y) in REG.items(): Image.open(f'{G}/{k}.png').convert('RGB').save(f'{OUT}/r{ai}.jpg', quality=86)
for name, k in (('wild', 7093), ('city', 7094), ('dungeon', 7095), ('camp', 7096), ('ring', 7097)): Image.open(f'{A}/gorsel/UIData_iphone1/{k}.png').save(f'{OUT}/{name}.png')
lay = json.load(open(f'{A}/metin/config/1029.txt', encoding='utf-8'))
have = json.load(open('kaynak/cikti/cozulmus/sahneler.json', encoding='utf-8'))
ICON = {1: 'city', 2: 'wild', 3: 'camp', 4: 'dungeon'}
def lvr(n):
    m = re.search(r'[（(](\d+)(?:-(\d+))?级[)）]', n)
    return [int(m.group(1)), int(m.group(2) or m.group(1))] if m else None
areas = []; levels = {}
for a in lay['areas']:
    k, x, y = REG[a['areaIndex']]; w, h = Image.open(f'{G}/{k}.png').size; seen = set(); S = []
    for s in a['scenes']:
        sid = str(s['sid']); L = lvr(s['name'])
        if L and sid not in levels: levels[sid] = L
        if sid not in have or sid in seen: continue
        seen.add(sid); S.append({'sid': sid, 'x': round(s['x'], 2), 'y': round(s['y'], 2), 'icon': ICON.get(s['layer'], 'wild'), 'lv': L})
    areas.append({'i': a['areaIndex'], 'img': f"r{a['areaIndex']}.jpg", 'cx': round((x + w / 2) / 1760 * 100, 2), 'cy': round((y + h / 2) / 1504 * 100, 2), 'scenes': S})
json.dump({'areas': areas}, open(f'{OUT}/wm.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
json.dump(levels, open('kaynak/apk/seviyeler.json', 'w'), separators=(',', ':'))
print('bölge', len(areas), 'haritadaki sahne', sum(len(a['scenes']) for a in areas), 'seviye aralığı bilinen sahne', len(levels))
