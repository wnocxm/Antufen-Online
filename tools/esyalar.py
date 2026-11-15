# -*- coding: utf-8 -*-
# Eşya tablosunu genişletir: oyunda bulunan dükkânların sattığı ve görevlerin ödül verdiği eşyalar.
# Değerler (fiyat, seviye, sınıf, simge, görünüş) Symbian sürümünün eşya tablolarından; dükkân içerikleri Android sürümünün
# dükkân tablosundan (yalnızca oyundaki NPC'lerin dükkânları). Adlar elle çevrildi. Mevcut eşyalara dokunulmaz.
# Kullanım (depo kökünden): python3 tools/esyalar.py
import sys, json, re
sys.path.insert(0, 'tools')
from godat import named
from tok import toks
E = {i: d for i, n, d in named('kaynak/orijinal/all_equip.godat')}
P = {i: d for i, n, d in named('kaynak/orijinal/all_prop.godat')}
ICON = {}
for f in ['icon_res_equip', 'icon_res_item']:
    for i, n, d in named(f'kaynak/orijinal/{f}.godat'):
        if n: ICON[n.lower()] = [f.replace('icon_res_', ''), i]
CLS = {130001: '战士', 130004: '战士', 130006: '战士', 130007: '战士', 130002: '法师', 130005: '法师', 130008: '法师', 130009: '法师', 130010: '牧师', 130011: '牧师', 130012: '牧师'}
SLOT = {'剑': 'weap', '刀': 'weap', '杖': 'weap', '魔典': 'weap', '圣器': 'weap', '衣服': 'body', '头部': 'head', '腰带': 'belt', '鞋子': 'shoe', '手套': 'glove', '项链': 'neck', '戒指': 'ring'}
# (TR, EN) adlar; tüketimde açıklama da
N = {
    10163: ('Mücevherli Kılıç', 'Gem Sword'), 10173: ('Kakmalı Asa', 'Inlaid Staff'), 10952: ('Kehanet Dokunuşu', 'Oracle\'s Touch'),
    10190: ('Mitril Kılıç', 'Mithril Sword'), 10198: ('Derin Çukur Asası', 'Abyss Staff'), 11344: ('Kapan Kitabı', 'Tome of Seizing'),
    10216: ('Dalgalı Kılıç', 'Rippled Blade'), 10222: ('Zalim Asa', 'Staff of Cruelty'),
    10164: ('Metal Göğüslük', 'Metal Breastplate'), 10169: ('Savaş Cübbesi', 'Battle Robe'), 10951: ('Rahip Giysisi', 'Clergy Vestment'),
    10191: ('Tam Zırh', 'Full Plate Armor'), 10195: ('Hanedan Cübbesi', 'Family Robe'), 11345: ('Yıpranmış Uzun Cübbe', 'Weathered Long Robe'),
    10217: ('Levha Zırh', 'Plate Armor'), 10220: ('Başbüyücü Cübbesi', 'Archmage Robe'),
    10588: ('Güç Bilekliği', 'Bracer of Strength'), 11242: ('Gölge Rafine Mücevheri', 'Refined Shadow Jewel'),
    31142: ('Şifa Suyu', 'Healing Water', 'Çok miktarda can yeniler.', 'Restores a lot of HP.'),
    31144: ('Büyü Suyu', 'Mana Water', 'Çok miktarda mana yeniler.', 'Restores a lot of mana.'),
    30195: ('Acılı Kanat', 'Spicy Wings', '15 saniyede az miktarda can yeniler.', 'Slowly restores a little HP over 15 seconds.'),
    30197: ('Kızarmış But', 'Fried Drumstick', '15 saniyede biraz can yeniler.', 'Slowly restores some HP over 15 seconds.'),
    30198: ('Sarımsaklı Sığır Eti', 'Garlic Beef', '15 saniyede epey can yeniler.', 'Slowly restores a fair amount of HP over 15 seconds.'),
    30199: ('Baharatlı Dolma Hindi', 'Spiced Stuffed Turkey', '15 saniyede çok miktarda can yeniler.', 'Slowly restores a lot of HP over 15 seconds.'),
    30201: ('Parlayan Elma', 'Glowing Apple', '15 saniyede az miktarda mana yeniler.', 'Slowly restores a little mana over 15 seconds.'),
    30202: ('Biscay Kurabiyesi', 'Biscay Biscuit', '15 saniyede biraz mana yeniler.', 'Slowly restores some mana over 15 seconds.'),
    30203: ('Yaban Mersinli Peynirli Dondurma', 'Blueberry Cheese Ice Cream', '15 saniyede epey mana yeniler.', 'Slowly restores a fair amount of mana over 15 seconds.'),
    30204: ('Güçlü Hardal Tozu', 'Strong Mustard Powder', '15 saniyede çok miktarda mana yeniler.', 'Slowly restores a lot of mana over 15 seconds.'),
    30024: ('Halk Teşekkürnamesi', 'Tribune\'s Commendation', 'Krallık halkına yaptığın yardımın belgesi. Guanlin\'deki Halk Koruyucusu ya da başkentteki saray tedarikçisinde hediyeyle değiştirilir.', 'Proof of your help to the people of the kingdom. Exchanged for gifts with the Tribune in Guanlin or the Royal Purveyor in the capital.'),
}
# oyunun ölçeğinde değerler (mevcut 140 eşyayla aynı merdiven: silah 30. seviyeden sonra her 10 seviyede +78, zırh savaşçı +83 / büyücü-rahip +68)
def weap_atk(lv): return {1: 78, 10: 113, 20: 152}.get(lv, 382 + (lv - 30) // 10 * 78)
def body_def(lv, cls): return (363 + (lv - 30) // 10 * 83) if cls == '战士' else (297 + (lv - 30) // 10 * 68)
HEAL = {'少量': 800, '部分': 2000, '较多': 4000, '很多': 8000}
items = json.load(open('www/assets/items.json', encoding='utf-8'))
IT = items['items']; added = 0
for i, n in N.items():
    if str(i) in IT: continue
    if i in E:
        t = toks(E[i]); slot = SLOT[t[13]]; lv = t[20]; cls = CLS.get(t[22]) if slot in ('weap', 'body') else None
        st = {'weap': {'atk': weap_atk(lv)}, 'body': {'def': body_def(lv, cls)}}.get(slot)
        if i == 10588: st = {'atk': 66}       # Güç eldiveni: dükkândaki aynı sınıf eldivenle aynı
        if i == 11242: st = {'res': 90}       # gölge direnci yüzüğü (25. seviye)
        gfx = t[4].rsplit('_', 1)[0] if isinstance(t[4], str) and t[4].startswith('group') else None
        IT[str(i)] = dict(name=n[0], en=n[1], icon=ICON[t[2].lower()], price=t[14], sell=max(1, t[15]), slot=slot, cls=cls, lv=lv, st=st, gfx=gfx)
    else:
        t = toks(P[i]); desc = t[3]; it = dict(name=n[0], en=n[1], icon=ICON[t[2].lower()], price=t[10], sell=max(1, t[11]), desc=n[2], den=n[3])
        if t[8] == '药水':
            amt = next(v for k, v in HEAL.items() if k in desc); res = 'mp' if '法力' in desc else 'hp'
            it['use'] = {'hot': [res, amt, 15]} if '逐渐' in desc else {res: amt}
        IT[str(i)] = it
    added += 1
# dükkânlar: oyundaki NPC'nin Android sürümünde açtığı dükkânların eşyaları, mevcut sekmelere eklenir (yoksa yeni sekme)
SH = json.load(open('kaynak/apk/cikti/metin/config/1015.txt', encoding='utf-8'))['shops']
TAB = {'药品': 'İksirler', '武器': 'Silahlar', '衣服': 'Zırhlar', '手套': 'Eldivenler'}
for s in SH:
    tab = TAB.get(s['name'])
    if not tab: continue
    for npc in {n['npc_name'] for n in s.get('npcs', [])} & set(items['shops']):
        tabs = items['shops'][npc]; T = next((t for t in tabs if t[0] == tab), None)
        if T is None: T = [tab, []]; tabs.append(T)
        for i in s['items']:
            if str(i) in IT and str(i) not in T[1]: T[1].append(str(i))
json.dump(items, open('www/assets/items.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('eklenen', added, 'toplam', len(IT), {k: [(a, len(b)) for a, b in v] for k, v in items['shops'].items()})
