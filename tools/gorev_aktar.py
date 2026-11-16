# -*- coding: utf-8 -*-
# Görev aktarımı: bir bölgenin (görev veren NPC'lerin durduğu şehir/kamp) görevlerini orijinal tablolardan okur.
#   Görev türü, hedef ve adet: Symbian görev kaydı (hedef cümlesi ve ilerleme satırı) — asıl kaynak.
#   Veren/teslim alan NPC, ödüller, zincir (sonraki görev): Android sürümünün görev tablosu (1025.txt).
# Kullanım (depo kökünden):
#   python3 tools/gorev_aktar.py 奔马城 koşanat   -> kaynak/ceviri/gorevler/koşanat_kaynak.json (Çince metin + yapı, çeviri için)
# Çeviriler kaynak/ceviri/gorevler/<ad>.json dosyasına yazılır; tools/gorevler.py ikisini birleştirip oyuna ekler.
import json, re, sys, os, collections

APK = {x['id']: x for x in json.load(open('kaynak/apk/cikti/metin/config/1025.txt', encoding='utf-8'))['tasks']}
SYM = json.load(open('kaynak/cikti/cozulmus/tablolar/tasks.json', encoding='utf-8'))
D = json.load(open('www/assets/data.json', encoding='utf-8')); S = D['scenes']
CIT = {int(k): v[0] for k, v in D['cit'].items()}
MON = {v[0] for v in D['mon'].values()}
SCN = {s['name'] for s in S.values()}
NPC_SC, ENT_SC = {}, collections.defaultdict(list)
for sid, s in S.items():
    for e in s['ents']:
        NPC_SC.setdefault(e[0], sid); ENT_SC[e[1]].append(sid)
RED = re.compile(r'\\C\(237,23,23\)(.*?)\\C\(255,0,255\)')
clean = lambda t: re.sub(r'\\C\(\d+,\d+,\d+\)', '', t or '').replace('\\n', '\n').strip()
hub = lambda nid: S[NPC_SC[nid]]['name'] if nid in NPC_SC else None

def parse(i):
    """Bir görevi oyunun görev biçimine çevirir. Desteklenmeyen ya da hedefi oyunda olmayan görevde (None, sebep) döner."""
    t, o = APK.get(i), SYM.get(str(i))
    if not t or not o: return None, 'kayıt yok'
    o = list(o)
    # zindan görevlerinde (副本) "reddet" alanı yok: ilerleme satırı 9. değil 8. alanda; konuşma görevinde bekleme alanı da yok
    if len(o) > 8 and '%d' in o[8] and not (len(o) > 9 and '%d' in o[9]): o.insert(4, '')
    elif len(o) > 6 and o[3] == '愿意为您效劳' and o[4] in ('结束', '离开'): o[4:4] = ['', '']
    if len(o) < 13: return None, 'kısa kayıt'
    g, d = t['acceptNpcId'], t['deliverNpcId']
    if g not in CIT or d not in CIT or g not in NPC_SC or d not in NPC_SC: return None, 'NPC oyunda yok'
    prog = o[9] if '%d' in o[9] else ''
    tail = o[13 if prog else 12:]
    q = {'id': i, 'giver': CIT[g], 'to': CIT[d], 'apk': t['taskCategory']}
    zh = {'title': o[0], 'goal': clean(o[1]), 'text': clean(o[2]), 'wait': clean(o[5]), 'done': clean(o[7])}
    goal_red = RED.findall(o[1])
    if prog:
        m = re.search(r'/(\d+)', prog); n = int(m.group(1)) if m else 1
        red = RED.findall(prog); name = red[0] if red else re.sub(r'^(已经|已)(获得|收集|取得|找到|拿到|得到|击杀|杀死|消灭)?', '', prog.split('：')[0].split(':')[0])
        name = clean(name)
        if '；' in prog or ';' in prog:   # çok hedefli: yalnız öldürme destekli ("…击杀A %d/10；B %d/5")
            if not re.search(r'杀|击败|消灭|打败|干掉', prog): return None, 'çok hedefli toplama'
            tg = []
            for part in re.split(r'[；;]', prog):
                if not part.strip(): continue
                m2 = re.search(r'/(\d+)', part); r2 = RED.findall(part)
                nm = clean(r2[0] if r2 else re.sub(r'^(已经|已)?(击杀|杀死|消灭|击败|打败|干掉)?', '', part.split('%')[0].split('：')[0].split(':')[0]).strip())
                nm = next((x for x in (nm, '☆' + nm, '☆☆' + nm, '★' + nm) if x in ENT_SC and x in MON), nm)   # ilerleme satırında yıldız yazılmamış olabilir
                if nm not in ENT_SC or nm not in MON: return None, f'canavar yok: {nm}'
                tg.append([nm, int(m2.group(1)) if m2 else 1])
            q.update(type='kill', target=tg[0][0], count=sum(c for _, c in tg), targets=tg)
            name = tg[0][0]
        elif re.search(r'杀|击败|消灭|打败|干掉', prog):
            name = next((x for x in (name, '☆' + name, '☆☆' + name, '★' + name) if x in ENT_SC and x in MON), name)
            if name not in ENT_SC or name not in MON: return None, f'canavar yok: {name}'
            q.update(type='kill', target=name, count=n)
        else:
            q.update(type='collect', item=name, count=n); zh['item'] = name
            src = [x for x in tail + goal_red if x in MON and x in ENT_SC]
            node = [x for x in tail + goal_red if (x == name or x.endswith(name)) and x in ENT_SC and x not in MON]
            field = [x for x in tail + goal_red if x in SCN and any(s2.get('lvr') for s2 in S.values() if s2['name'] == x)]
            if src: q['target'] = src[0]; q['chance'] = 1 if n == 1 else (0.6 if n <= 5 else 0.5)
            elif node: q.update(type='pickup', node=node[0])
            elif n == 1 and not field:
                q['type'] = 'talk'   # NPC eşyayı verir, oyuncu teslim alana götürür
            else: return None, f'kaynak yok: {name}'
        if q['type'] == 'talk': tg = None
        sc = [x for x in goal_red if x in SCN]
        tg = q.get('target') or q.get('node')
        if not tg: sc = []
        ok = [x for x in sc if any(S[s]['name'] == x for s in ENT_SC.get(tg, []))]
        if tg: q['sc'] = (ok or sc or [S[ENT_SC[tg][0]]['name']])[0]
    else:
        ev = (t.get('events') or [{}])[0]
        q['type'] = 'talk'   # Android tablosundaki "reach" olayları Symbian kaydında hep konuşma görevi
    q['zh'] = zh
    rw = t.get('rewards') or {}
    q['rw'] = {'gold': rw.get('gold', 0), 'items': [[str(x['itemId']), x['count']] for x in rw.get('items', []) if not x.get('career')]}
    q['next'] = t.get('nextTaskId') or 0
    return q, None

def region(hubname):
    """Bir bölgedeki görevler: veren NPC o bölgede ya da zincirle o bölgeye bağlı."""
    # birden çok bölge virgülle; "#82836" biçiminde tek görev de eklenebilir (ör. zindan merkezine giden görev)
    hubs = set(x for x in hubname.split(',') if not x.startswith('#')); extra = {int(x[1:]) for x in hubname.split(',') if x.startswith('#')}
    ids = sorted(i for i, t in APK.items() if hub(t['acceptNpcId']) in hubs or i in extra)
    out, bad = [], collections.Counter()
    for i in ids:
        q, why = parse(i)
        if q: out.append(q)
        else: bad[why.split(':')[0]] += 1
    # zincir: önceki görev
    have = {q['id'] for q in out}
    prev = {t['nextTaskId']: i for i, t in APK.items() if t.get('nextTaskId')}
    for q in out:
        p = prev.get(q['id']); k = 0
        while p and p not in have and k < 6: p = prev.get(p); k += 1
        if p in have: q['req'] = p
    return out, bad

if __name__ == '__main__':
    hubname, ad = sys.argv[1], sys.argv[2]
    out, bad = region(hubname)
    # aynı metinli kopyalar (kanal kopyaları) atılır
    seen, uniq = set(), []
    for q in out:
        k = (q['zh']['title'], q['giver'], q['zh']['text'][:40])
        if k in seen: continue
        seen.add(k); uniq.append(q)
    os.makedirs('kaynak/ceviri/gorevler', exist_ok=True)
    json.dump(uniq, open(f'kaynak/ceviri/gorevler/{ad}_kaynak.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(hubname, 'görev', len(uniq), 'elenen', dict(bad), collections.Counter(q['type'] for q in uniq))
