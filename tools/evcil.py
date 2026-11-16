# -*- coding: utf-8 -*-
# Evcil hayvan (魔法兽) verisi: Symbian all_pet (türler, renk varyantları, dönüşüm sonrası biçim, konuşma satırları)
# + APK 1023 (tür sınıfı: 1 yardımcı, 2 fiziksel, 3 savunma, 4 büyü; ana beceri) + APK 1024 (nitelik şablonları, evrim çarpanları)
# + Symbian all_prop (yumurta eşyaları ve gereken kuluçka kutusu). Çıktı: www/assets/pets.json
# Kullanım (depo kökünden): python3 tools/evcil.py
import json, re
A = json.load(open('kaynak/cikti/tablo/all_pet.json'))
C = 'kaynak/apk/cikti/metin/config/'
APK = {p['name']: p for p in json.load(open(C + '1023.txt'))['pets']}
TPL = {p['subtype_map']: p for p in json.load(open(C + '1024.txt'))['pets']}
PROP = json.load(open('kaynak/cikti/tablo/all_prop.json'))
SK = {x['id']: x['metin'] for x in json.load(open('kaynak/cikti/tablo/all_skill.json'))}
REG = json.load(open('www/assets/data.json'))['reg']
species, seen = [], set()
for p in A:
    m = p['metin']
    if len(m) < 5: continue
    blocks = [i for i, x in enumerate(m) if x == 'PET-召唤']
    if not blocks: continue
    b0 = blocks[0]; name = m[b0 - 2]
    if name in seen: continue   # aynı türün kopya kaydı (ör. 小鸡 iki kez)
    seen.add(name)
    chat = [x for x in m[b0 + 3:blocks[1] - 2 if len(blocks) > 1 else len(m)] if x.strip() and not x.startswith('monster')][1:]
    look = lambda i: m[i - 1] if m[i - 1] in REG else None
    variants = [look(i) for i in blocks[1:7] if look(i)]
    evo = None
    if len(blocks) > 7:
        i = blocks[7]; ev_name = m[i - 2] if m[i - 2] != name and not m[i - 2].startswith('monster') else None
        if ev_name: evo = {'name': ev_name, 'look': look(i)}
    a = APK.get(name, {})
    alt = a.get('resource') if a.get('resource') in REG else None   # Symbian görünümü eksikse APK tablosundaki
    species.append({'id': p['id'], 'name': name, 'look': look(b0) or alt or (variants[0] if variants else None), 'variants': variants, 'evo': evo,
                    'cls': a.get('subtype', 2), 'skill': a.get('default_skill') or TPL.get(a.get('subtype', 2), {}).get('fixed_skill'), 'chat': chat})
# yumurtalar: "魔法兽蛋（X）"; açıklamada gereken kutu (木质/金属/魔法)
eggs = {}
for x in PROP:
    n = x['metin'][0]; mm = re.match(r'魔法兽蛋（(.+)）$', n)
    if not mm or mm.group(1) in eggs: continue
    box = 'wood' if '木质' in x['metin'][3] else 'metal' if '金属' in x['metin'][3] else 'magic'
    eggs[mm.group(1)] = {'item': str(x['id']), 'box': box}
for s in species:
    e = eggs.get(s['name'])
    if e: s['egg'] = e['item']; s['box'] = e['box']
tpl = {str(k): {kk: v[kk] for kk in ('name', 'base_phys_atk', 'base_mag_atk', 'base_def', 'hp_growth', 'mp_growth', 'hit_growth', 'dodge', 'fixed_skill', 'evolutions')} for k, v in TPL.items()}
skills = {}
for s in species + [{'skill': t['fixed_skill']} for t in TPL.values()]:
    k = s.get('skill')
    if k and k in SK: skills[str(k)] = {'name': SK[k][0], 'desc': SK[k][1], 'icon': SK[k][2]}
out = {'species': species, 'templates': tpl, 'skills': skills, 'eggsWithoutSpecies': sorted(set(eggs) - {s['name'] for s in species})}
json.dump(out, open('www/assets/pets.json', 'w'), ensure_ascii=False, separators=(',', ':'))
if __name__ == '__main__':
    print('tür', len(species), 'yumurtalı', sum(1 for s in species if s.get('egg')), 'görünümsüz', [s['name'] for s in species if not s['look']])
    print('türü olmayan yumurta', out['eggsWithoutSpecies'])
    print('sınıf', {s['name']: s['cls'] for s in species})
    print('konuşma satırı', sum(len(s['chat']) for s in species), 'benzersiz', len({c for s in species for c in s['chat']}))

# ---------- çeviriler: yalnız yumurtası olan (elde edilebilir) türler ----------
TRN = json.load(open('kaynak/ceviri/evcil.json', encoding='utf-8'))
AD, KN, BT, BC = TRN['adlar'], TRN['konusma'], TRN['beceri_tur'], TRN['beceri']
game = []
for s in species:
    if not s.get('egg'): continue
    sk = BT[s['name']]
    g = {'id': s['id'], 'cn': s['name'], 'tr': AD[s['name']][0], 'en': AD[s['name']][1], 'look': s['look'], 'variants': s['variants'],
         'cls': s['cls'], 'skill': sk, 'egg': s['egg'], 'box': s['box'],
         'chatTr': [KN[c][0] for c in s['chat'] if c in KN], 'chatEn': [KN[c][1] for c in s['chat'] if c in KN]}
    if s['evo']: g['evo'] = {'cn': s['evo']['name'], 'tr': AD[s['evo']['name']][0], 'en': AD[s['evo']['name']][1], 'look': s['evo']['look']}
    game.append(g)
SKG = {}
for k, v in BC.items():
    m = SK.get(int(k)); SKG[k] = {'tr': v['tr'], 'en': v['en'], 'icon': m[2] if m else None}
json.dump({'species': game, 'templates': tpl, 'skills': SKG}, open('www/assets/pets.json', 'w'), ensure_ascii=False, separators=(',', ':'))

# ---------- eşyalar ve Terbiyeci dükkânları (www/assets/items.json) ----------
import sys; sys.path.insert(0, 'tools')
from godat import named
from tok import toks
PR = {i: d for i, n, d in named('kaynak/orijinal/all_prop.godat')}
ICON = {}
for f in ['icon_res_equip', 'icon_res_item']:
    for i, n, d in named(f'kaynak/orijinal/{f}.godat'):
        if n: ICON[n.lower()] = [f.replace('icon_res_', ''), i]
BOXN = {'wood': ('Tahta', 'Wooden'), 'metal': ('Metal', 'Metal'), 'magic': ('Büyülü', 'Magic')}
# (TR ad, EN ad, TR açıklama, EN açıklama, kullanım)
PETIT = {
    30166: ('Tahta Kuluçka Kutusu', 'Wooden Incubator', 'Sıradan yumurtaları çıkarır. Büyüsü yoktur ama hayvanın sağlıkla doğmasını sağlar.', 'Hatches common eggs. It has no magic, but ensures a healthy birth.', {'box': 'wood'}),
    31147: ('Metal Kuluçka Kutusu', 'Metal Incubator', 'İyi yumurtaları çıkarır. Doğa büyüsünü toplar; doğan hayvanın yeteneği daha yüksek olur.', 'Hatches fine eggs. It gathers natural magic, so the hatchling is more talented.', {'box': 'metal'}),
    31149: ('Büyülü Kuluçka Kutusu', 'Magic Incubator', 'Seçkin yumurtaları çıkarır. Büyüsünün tamamı hayvana geçer; yeteneği çok yüksek olur.', 'Hatches superior eggs. All its magic passes to the hatchling, giving it great talent.', {'box': 'magic'}),
    30022: ('Biluo Meyvesi', 'Biluo Fruit', 'Kaya yarıklarında yetişen narin meyve; evcil hayvanların asıl yiyeceği. Tokluğu +50 artırır.', 'A delicate fruit growing in rock crevices; the main food of pets. +50 satiety.', {'food': 50}),
    30020: ('Hayvan Kanı', 'Beast Blood', 'Evcil hayvana özel iksir: canını az miktarda yeniler.', 'Pet potion: restores a little of its HP.', {'petHp': 800}),
    30021: ('Yırtıcı Kanı', 'Predator Blood', 'Evcil hayvana özel iksir: canının bir kısmını yeniler.', 'Pet potion: restores some of its HP.', {'petHp': 2000}),
    30485: ('Hayvan Kralı Kanı', 'Beast King Blood', 'Evcil hayvana özel iksir: canını epey yeniler.', 'Pet potion: restores a good deal of its HP.', {'petHp': 4000}),
    30754: ('Hayvan Ruhu', 'Beast Soul', 'Evcil hayvana özel iksir: manasını az miktarda yeniler.', 'Pet potion: restores a little of its mana.', {'petMp': 400}),
    30755: ('Yırtıcı Ruhu', 'Predator Soul', 'Evcil hayvana özel iksir: manasının bir kısmını yeniler.', 'Pet potion: restores some of its mana.', {'petMp': 1000}),
    30756: ('Hayvan Kralı Ruhu', 'Beast King Soul', 'Evcil hayvana özel iksir: manasını epey yeniler.', 'Pet potion: restores a good deal of its mana.', {'petMp': 2000}),
    30025: ('Ejderin Kurtuluşu', 'Dragon\'s Redemption', 'Değerli bir ilaç: can çekişen evcil hayvanı diriltir ve biraz can verir.', 'A precious medicine: revives a dying pet with a little HP.', {'petRevive': 0.3}),
    30595: ('Sözleşme Taşı', 'Contract Stone', 'Sahibinin sözleşme gücünü artıran gizemli taş: beslenebilecek evcil hayvan sayısı +1.', 'A mysterious stone that strengthens its owner\'s pact: +1 pet you can keep.', {'petSlot': 1}),
    30006: ('Canavar İç Özü', 'Beast Core', 'Kadim canavarın nadir iç özü: çağrılmış evcil hayvana 7000 deneyim verir.', 'The rare core of an ancient beast: grants 7000 XP to the summoned pet.', {'petXp': 7000}),
}
items = json.load(open('www/assets/items.json', encoding='utf-8')); IT = items['items']
def base(i):
    t = toks(PR[i]); ic = ICON.get(t[2].lower()) or ICON['item\\consume\\icon_dj_dan1.bmp']   # İç Öz'ün simgesi beceri simgesi: yumurta simgesi kullanılır
    return dict(icon=ic, price=t[10], sell=max(1, t[11]))
for i, (a, b, c, d, use) in PETIT.items():
    IT[str(i)] = dict(base(i), name=a, en=b, desc=c, den=d, pet=use)
for g in game:
    bt, be = BOXN[g['box']]
    IT[g['egg']] = dict(base(int(g['egg'])), name=f"Evcil Hayvan Yumurtası ({g['tr']})", en=f"Pet Egg ({g['en']})",
                        desc=f"Gizemli bir yumurta; kuluçkadan bir evcil hayvan çıkar. {bt} Kuluçka Kutusu gerekir.", den=f"A mysterious egg that hatches into a pet. Requires a {be} Incubator.", pet={'egg': g['cn'], 'box': g['box']})
# Terbiyeci dükkânları (APK 1015: 100038 insan, 100039 elf)
SH = {s['id']: s for s in json.load(open(C + '1015.txt'))['shops']}
for sid, npc in [(100038, '驯兽师（人类）'), (100039, '驯兽师（夜精灵）')]:
    ids = [str(i) for i in SH[sid]['items'] if str(i) in IT]
    if '30166' not in ids: ids.append('30166')   # elf dükkânında eksik; görev 80222 bu kutuyu satın almayı ister
    items['shops'][npc] = [['Evcil Hayvan', ids]]
json.dump(items, open('www/assets/items.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('oyuna giren tür', len(game), 'eşya', len(PETIT) + len(game), 'dükkân', {n: items['shops'][n] for n in ('驯兽师（人类）', '驯兽师（夜精灵）')})
