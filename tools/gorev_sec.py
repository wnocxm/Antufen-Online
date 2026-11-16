# Görev seçici: bölge kaynak dökümlerinden 55 (ya da verilen) seviye altı hikâye görevlerini seçer, Çince metinleri çeviri için döker.
# Kullanım: python3 tools/gorev_sec.py <ad1,ad2,...> <en yüksek seviye> <çıktı.txt>   (ad = kaynak/ceviri/gorevler/<ad>_kaynak.json)
# bölge kaynağından 55 ve altı görevleri seçer, Çince metni döker
import json,re,sys
S=json.load(open('www/assets/data.json'))['scenes']
have=set(map(int,re.findall(r'"id":(\d+)',open('www/js/quests_gen.js').read())))|set(map(int,re.findall(r'\{ id: (\d+)',open('www/js/tr.js').read())))
def lvl(n):
    v=[(s.get('lvr') or [s.get('lv') or 0])[0] for s in S.values() if s['name']==n]
    return min(v) if v else 99
files=sys.argv[1].split(','); MAX=int(sys.argv[2]); out=sys.argv[3]
Q=[]
for f in files: Q+= [q for q in json.load(open(f'kaynak/ceviri/gorevler/{f}_kaynak.json')) if q['id'] not in have]
by={q['id']:q for q in Q}
ok={q['id'] for q in Q if q.get('sc') and lvl(q['sc'])<=MAX}
bad={q['id'] for q in Q if q.get('sc') and lvl(q['sc'])>MAX}
APK={x['id']:x for x in json.load(open('kaynak/apk/cikti/metin/config/1025.txt',encoding='utf-8'))['tasks']}
for q in Q:
    ev=[e.get('eventType') for e in APK[q['id']].get('events') or []]
    if q['type']=='talk' and any(e in ('kill','collect') for e in ev): bad.add(q['id'])
    if q['type']=='talk' and q['zh']['wait'] in ('恩','谢谢','抱歉','好的','知道了','当然不是') : bad.add(q['id'])
skipw=('契约欢乐使者','驿站老板','盲眼向导','驯兽师','装备强化大师','技能训练师','采矿人','考古','源质炼金师','神秘商人')
for _ in range(10):
    for q in Q:
        if q['id'] in ok or q['id'] in bad: continue
        if any(w in q['giver'] for w in skipw): bad.add(q['id']); continue
        r=q.get('req')
        if r in bad: bad.add(q['id'])
        elif r in ok: ok.add(q['id'])
        else:
            nx=[p for p in Q if p.get('req')==q['id']]
            if any(p['id'] in ok for p in nx): ok.add(q['id'])
            elif nx and all(p['id'] in bad for p in nx): bad.add(q['id'])
rest=[q for q in Q if q['id'] not in ok and q['id'] not in bad]
ok|={q['id'] for q in rest}   # bağımsız konuşma görevleri
src=open('www/js/tr.js').read()+open('www/js/tr_scenes.js').read()
need=set(); n=0
with open(out,'w') as o:
    for q in Q:
        if q['id'] not in ok: continue
        n+=1
        for k in ('giver','to','target','node','sc'):
            v=q.get(k)
            if v and f'"{v}"' not in src and f"'{v}'" not in src: need.add(v)
        z=q['zh']; o.write(f"## {q['id']} [{q['type']}] {z['title']} | {q['giver']}→{q['to']} | {q.get('target') or q.get('node') or ''} {q.get('item','')} x{q.get('count','')} @{q.get('sc','')} req {q.get('req','')}\nT: {z['text']}\nW: {z['wait']}\nD: {z['done']}\n")
print('seçilen',n,'elenen',len(bad)); print('ÇEVRİLMEMİŞ:',' '.join(sorted(need)))
