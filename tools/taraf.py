# -*- coding: utf-8 -*-
# Harita tarafları: APK 1009 muhafız tablosundaki "camp" (1 = insan, 2 = gece elfi) ve 1011 sahne türleri (4 = zindan, 5/6 = savaş alanı).
# Muhafızı olan alanın tarafı muhafızdan; muhafızsız şehir/kamp komşu alanlardan (çoğunluk) bulunur; zindan ve savaş alanı ortak.
# Çıktı: kaynak/apk/taraflar.json  {sahneId: "人类" | "精灵" | "ortak"}.  Kullanım: python3 tools/taraf.py
import json, collections
CFG = 'kaynak/apk/cikti/metin/config/'
G = {g['id']: g['camp'] for g in json.load(open(CFG + '1009.txt'))['GuardList']}
TYP = {str(x['SceneId']): x['SceneType'] for x in json.load(open(CFG + '1011.txt'))['SceneTypes']}
S = json.load(open('www/assets/data.json'))['scenes']
R = {1: '人类', 2: '精灵'}
side = {}
for sid, s in S.items():
    c = {G[e[0]] for e in s['ents'] if e[0] in G and G[e[0]] in (1, 2)}
    if TYP.get(sid) in (4, 5, 6) or len(c) == 2: side[sid] = 'ortak'
    elif len(c) == 1: side[sid] = R[c.pop()]
nb = collections.defaultdict(set)
for sid, s in S.items():
    for e in s['exits']:
        t = str(e[2])
        if t in S: nb[sid].add(t); nb[t].add(sid)
base = dict(side)
for sid, s in S.items():   # adında ırk geçen mahalle/kamp (夜精灵社区, 人类营地 …)
    if sid in base and base[sid] == 'ortak' and TYP.get(sid) in (4, 5, 6): continue
    if '夜精灵' in s['name']: side[sid] = '精灵'
    elif '人类' in s['name']: side[sid] = '人类'
for _ in range(6):   # muhafızsız sahneler: komşuların çoğunluğu; iki tarafa eşit komşu (liman, meydan, lağım) ortak kalır
    for sid in S:
        if sid in side: continue
        v = collections.Counter(side[n] for n in nb[sid] if n in side and side[n] != 'ortak')
        if v:
            (a, na), *rest = v.most_common()
            side[sid] = a if not rest or na > rest[0][1] else 'ortak'
for sid in S: side.setdefault(sid, 'ortak')
json.dump(side, open('kaynak/apk/taraflar.json', 'w'), ensure_ascii=False, indent=0)
if __name__ == '__main__':
    for nm in ['观林镇', '奔马城', '军情前哨', '帝都', '人类社区', '望山城', '魔法学院', '金波港', '夜精灵社区', '公正广场', '先知神殿', '守望者营地', '望日城', '浓雾镇', '艺术家工会前厅', '下水道', '噬魂远征军前哨', '幽暗营地', '山麓营地', '黑暗哨塔', '人类营地', '夜精灵营地', '新兵营地']:
        print(nm, sorted({side[k] for k, s in S.items() if s['name'] == nm}))
