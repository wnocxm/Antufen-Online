# -*- coding: utf-8 -*-
# Orijinal beceri ağaçları ve beceriler → www/assets/skills.json
# Kaynaklar (hepsi orijinal Symbian istemcisi):
#   kaynak/orijinal/all_skilltree.godat  ağaç → 6 beceri ve sütunu (1 sol, 2 orta, 3 sağ); ırk ağaçları 2 beceri
#   kaynak/orijinal/all_skill.godat      ad, açıklama şablonu ($const(x)$, $cd$, $cost_mp$), simge yolu, en yüksek kademe,
#                                        ön koşul (beceri + kademe), ağacın kök şartı (önceki ağaçta harcanan puan + sınıf), dışlayan kök
#   kaynak/orijinal/icon_res_skill.godat simge yolu → simge numarası (www/assets/ui/icon_res_skill_N.png)
#   kaynak/cikti/betik/clt_script/skill_const_2nd.lua  kademe sabitleri (TABLE_SKILL_CONST[sn] = {ad = tablo}); sonraki tanım öncekini ezer
# Kullanım (depo kökünden): python3 tools/beceriler.py
import sys, struct, re, json
sys.path.insert(0, 'tools')
from godat import named
from lstr import lstrings

SK = {i: d for i, n, d in named('kaynak/orijinal/all_skill.godat')}
TRD = {i: d for i, n, d in named('kaynak/orijinal/all_skilltree.godat')}
ICON = {n.lower().split('\\')[-1]: i for i, n, d in named('kaynak/orijinal/icon_res_skill.godat') if n}
ICON_IT = {n.lower().split('\\')[-1]: i for f in ('icon_res_item', 'icon_res_equip') for i, n, d in named(f'kaynak/orijinal/{f}.godat') if n}   # bazı beceriler eşya simgesi kullanır

# sınıf → [acemi, sınıf, uzmanlık A, uzmanlık B]; ırk ağaçları
TREES = {'战士': [150008, 150009, 150010, 150011], '法师': [150014, 150015, 150016, 150017], '牧师': [150022, 150023, 150024, 150025]}
RACE = {'人类': 150019, '精灵': 150013}
# yaşam becerileri (meslekler): 5 kademe (初级 → 宗师); öğretmen NPC'den öğrenilir
LIFE = {'采矿': [90324, 90325, 90326, 90327, 90328], '考古': [90553, 90554, 90555, 90556, 90557], '淬炼': [90561, 90562, 90563, 90564, 90565], '分解': [90592, 90593, 90594, 90595, 90596]}
CLASS_ID = {130004: ('战士', 1), 130005: ('法师', 1), 130011: ('牧师', 1), 130006: ('战士', 2), 130008: ('法师', 2), 130012: ('牧师', 2)}

def lua_consts():
    src = open('kaynak/cikti/betik/clt_script/skill_const_2nd.lua', 'rb').read().decode('gbk', 'replace')
    src = '\n'.join(l.split('--')[0] for l in src.split('\n'))   # yorumlar
    V, T = {}, {}
    for m in re.finditer(r'(\w+)\s*=\s*\{([^{}]*)\}|TABLE_SKILL_CONST\[(\d+)\]\s*=\s*\{([^{}]*)\}', src):
        if m.group(3):
            t = {}
            for k, v in re.findall(r'(\w+)\s*=\s*(\w+)', m.group(4)):
                if v in V: t[k] = V[v]
            T[int(m.group(3))] = t   # sonraki tanım öncekinin yerine geçer (Lua'daki gibi)
        elif m.group(1) != 'TABLE_SKILL_CONST':
            nums = re.findall(r'-?\d+(?:\.\d+)?', m.group(2))
            if nums and len(nums) == len([x for x in m.group(2).split(',') if x.strip()]):
                V[m.group(1)] = [float(x) if '.' in x else int(x) for x in nums]
    return T

def tree_cells(t):
    a = struct.unpack_from('<%di' % (len(TRD[t]) // 4), TRD[t], 0)
    out = []
    for k, x in enumerate(a):
        if 90000 < x < 91000: out.append([x, a[k + 1] if k + 1 < len(a) and a[k + 1] in (1, 2, 3) else 2])
    return out

def tree_name(t):
    ss = lstrings(TRD[t]); return ss[0][1] if ss else ''

def skill(i):
    d = SK[i]; ss = lstrings(d)
    name = ss[0][1]
    desc = next((s for o, s in ss[1:] if len(s) > 6 and not s.startswith('skill\\') and not s.startswith('特')), '')
    cur, _, nxt = desc.partition('\\n下一阶：')
    ic = next(((o, s) for o, s in ss if s.lower().endswith('.bmp')), None)
    key = ic[1].lower().split('\\')[-1] if ic else ''
    icon, ik = (ICON[key], None) if key in ICON else (ICON_IT[key], 'item') if key in ICON_IT else (None, None)
    # en yüksek kademe ve ön koşul: simge yolundan sonra [u16 kademe, …, u32 ön koşul beceri @+12, u32 gereken kademe @+16]
    mx, pre, prk = 1, 0, 0
    if ic:
        p0 = ic[0] + 4 + 2 * len(ic[1])
        for q in range(p0, min(len(d) - 20, p0 + 400), 2):
            m = struct.unpack_from('<H', d, q)[0]
            if m in (1, 5, 10, 15, 20):
                pr, rk = struct.unpack_from('<2i', d, q + 12)
                if (pr == 0 or 90000 < pr < 91000) and 0 <= rk <= 20: mx, pre, prk = m, pr, rk; break
    # kök şartı: (önceki ağaç, harcanmış puan), sınıf (+ dışlayan kök)
    root = None
    for off in range(0, len(d) - 7):
        v = struct.unpack_from('<i', d, off)[0]
        if 150000 <= v <= 150030 and root is None: root = {'tree': v, 'pts': struct.unpack_from('<i', d, off + 4)[0]}
        if v in CLASS_ID and root is not None:
            root['cls'] = v; x = struct.unpack_from('<i', d, off + 4)[0]
            if 90000 < x < 91000: root['excl'] = x
    # bekleme süresi: 350 işaretinden sonraki milisaniye
    cd = None
    for off in range(0, len(d) - 7):
        if struct.unpack_from('<i', d, off)[0] == 350:
            v = struct.unpack_from('<i', d, off + 4)[0]
            if 500 <= v <= 3600000: cd = v / 1000; break
    fx = [s for o, s in ss if s.startswith('特效-') or s.startswith('特性-')]
    return {'cn': name, 'icon': icon, 'ik': ik, 'mx': mx, 'pre': [pre, prk] if pre else None, 'root': root, 'cd': cd, 'fx': fx,
            'pas': cur.startswith('被动'), 'desc': cur.replace('\\n', '\n'), 'next': nxt.replace('\\n', '\n')}

def main():
    C = lua_consts(); out = {'trees': {}, 'race': {}, 'skills': {}}
    want = set()
    for cls, ts in TREES.items():
        out['trees'][cls] = [{'id': t, 'cn': tree_name(t), 'cells': tree_cells(t)} for t in ts]
        for t in ts: want |= {c[0] for c in tree_cells(t)}
    for r, t in RACE.items():
        out['race'][r] = {'id': t, 'cn': r, 'cells': tree_cells(t)}; want |= {c[0] for c in tree_cells(t)}
    TRN = json.load(open('kaynak/ceviri/beceriler.json', encoding='utf-8'))
    for i in sorted(want):
        s = skill(i); s['c'] = C.get(i, {}); t = TRN['beceriler'].get(str(i))
        if t: s['tr'], s['en'] = t['tr'], t['en']
        else: print('  çevirisiz beceri', i, s['cn'])
        out['skills'][str(i)] = s
    for ts in list(out['trees'].values()) + [[x] for x in out['race'].values()]:
        for t in ts: t['tr'], t['en'] = TRN['agaclar'].get(t['cn'], [t['cn'], t['cn']])
    out['life'] = {'tr': TRN['agaclar']['生活'][0], 'en': TRN['agaclar']['生活'][1], 'jobs': []}
    for job, ids in LIFE.items():
        tiers = []
        for i in ids:
            ss = lstrings(SK[i]); ic = next((x for o, x in ss if x.lower().endswith('.bmp')), '')
            k = ic.lower().split('\\')[-1]; tiers.append({'id': i, 'cn': ss[0][1], 'icon': ICON.get(k) or ICON_IT.get(k), 'ik': None if k in ICON else 'item'})
        tr = TRN['yasam'][job]['tr']; en = TRN['yasam'][job]['en']
        for k, t in enumerate(tiers): t['tr'] = [tr[1][k], tr[2][k]]; t['en'] = [en[1][k], en[2][k]]
        out['life']['jobs'].append({'cn': job, 'tr': tr[0], 'en': en[0], 'tiers': tiers})
    json.dump(out, open('www/assets/skills.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    for cls, ts in out['trees'].items():
        for t in ts:
            print(cls, t['id'], t['cn'], [(c[0], out['skills'][str(c[0])]['cn'], out['skills'][str(c[0])]['mx'], out['skills'][str(c[0])]['pre']) for c in t['cells']])
    print('beceri', len(out['skills']), 'sabitsiz', [k for k, v in out['skills'].items() if not v['c']])

if __name__ == '__main__':
    main()
