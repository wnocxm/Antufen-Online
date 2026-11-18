# -*- coding: utf-8 -*-
# Yolculuk ağı: orijinal NPC kayıtlarındaki (all_citizen) araba ve ışınlanma seçenekleri → www/assets/travel.json
#   Arabacılar (驿站老板 insan / 盲眼向导 elf): "我想去X" + npc_choise_trans_city_common + hedef; 100 altın (orijinal: 传送仅需100金币).
#   Işınlayıcılar (传送法阵, 风暴法师, 首席大法师 …): "前往X" + hedef; ücretsiz (【虚空商人】洛基: 100 altın, kendi metni).
#   Hedef, seçeneğin ardındaki tek karakterin kodu + 65536 = sahne numarası (ör. '한' 54620 → 120156 灰斧城; doğrulama: 噬魂远征军军需官 → 120276).
#   Varış: hedef sahnedeki bir yolculuk NPC'sinin önü (yoksa oyun sahnenin giriş bölgesini kullanır).
# Çıktı: {"npc": {"<NPC no>": [[tür, adÇince, hedefSahne, varışX|null, varışY|null], …]}, "cost": {...}}
# Kullanım (depo kökünden): python3 tools/seyahat.py
import json, re

CIT = json.load(open('kaynak/cikti/tablo/all_citizen.json', encoding='utf-8'))
D = json.load(open('www/assets/data.json', encoding='utf-8'))
S = D['scenes']
# başka yerde (dungeon.js DUNGEON_TP, görev ışınlanması) zaten işlenen ya da görev şartlı olanlar
ATLA = {'噬魂远征军军需官', '噬魂远征军军官', '瑟瑟发抖的勘察员', '矮人学者', '观林镇传送员', '神殿传送员'}
UCRET = {'【虚空商人】洛基': 100}

def options(m):
    out = []
    for i, s in enumerate(m[:-1]):
        nx = m[i + 1]
        if nx == 'npc_choise_trans_city_common' and i + 2 < len(m) and len(m[i + 2]) == 1:
            out.append(('araba', s, ord(m[i + 2]) + 65536))
        elif len(nx) == 1 and 0xD400 <= ord(nx) <= 0xD7FF and len(s) > 1 and s != 'npc_choise_trans_city_common':
            out.append(('tp', s, ord(nx) + 65536))
    return out

npc = {}
for x in CIT:
    m = x['metin']
    if not m or m[0] in ATLA: continue
    ops = [o for o in options(m) if str(o[2]) in S]
    if ops: npc[str(x['id'])] = (m[0], ops)
placed = {}   # sahne → o sahnedeki yolculuk NPC'lerinin yeri
for sid, sc in S.items():
    for e in sc['ents']:
        if str(e[0]) in npc: placed.setdefault(sid, []).append(e[2][:2])

# çevirisi olan adlar (www/js/tr_scenes.js); seçenekteki şehir adı çevrilemiyorsa (yazım farkı: 艺术家公会前厅 / 艺术家工会前厅) hedef haritanın adı
KNOWN = set(re.findall(r'"([^"]+)":"', open('www/js/tr_scenes.js', encoding='utf-8').read()))
def city(label, dest):
    t = re.split(r'[。.！!，,]', label)[0]
    m = re.match(r'^(?:我想去|我要去|前往|请送我到|帅哥我要去|我要回)(.+)$', t)
    c = m.group(1) if m else None
    return c if c in KNOWN else S[str(dest)]['name']

out = {}
for i, (cn, ops) in npc.items():
    L = []
    for kind, label, dest in ops:
        at = placed.get(str(dest))
        ax, ay = (at[0][0], at[0][1] + 1) if at else (None, None)
        L.append([kind, city(label, dest), str(dest), ax, ay])
    out[i] = L
cost = {'araba': 100}
json.dump({'npc': out, 'cost': cost, 'ucret': UCRET}, open('www/assets/travel.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
n = sum(len(v) for v in out.values())
print('yolculuk NPC', len(out), 'seçenek', n, 'yerleşik', sum(1 for i in out if any(str(e[0]) == i for s in S.values() for e in s['ents'])))
