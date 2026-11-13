import json,os,shutil,re,sys
sys.path.insert(0,'tools')
from godat import named
from lstr import lstrings
EXP='exp'; OUT=sys.argv[1]
reg=json.load(open(f'{EXP}/reg.json')); scenes=json.load(open(f'{EXP}/scenes.json'))
SCENES=['120207','120205','120005','120016','120004','120029','120018','120019','120020','120021']
CIT={i:[s for o,s in lstrings(d)] for i,n,d in named('files/all_citizen.godat')}
MON={i:[s for o,s in lstrings(d)] for i,n,d in named('files/all_monster.godat')}
need=set(); maps={}
for sid in SCENES:
    s=scenes[sid]; m=json.load(open(f"{EXP}/maps/{s['map']}.json")); maps[s['map']]=m
    for nm in m['names']: need.add(nm)
    for id_,nm,pos in s['ents']:
        info=CIT.get(id_) or MON.get(id_)
        if info:
            need.update(x for x in info[1:4] if x in reg)
for k in reg:
    if re.match(r'^(group\d|default|frame_|HORSE|特效|LEVELUP|BLOOD|SPECIAL|LIGHT|RESUME|RELIVE|WATER|FIRE|EFFECT|特性|PET-|NPC-新手引导|路标)',k): need.add(k)
# yaygın canavarlar (evcil hayvan ve sonraki bölgeler için)
for k in reg:
    if k.startswith(('怪物-狼','怪物-鸭子','怪物-鸡','野猪','蜘蛛','蝴蝶','森林巨魔','怪物-蛇','怪物-蠕虫','怪物-豺狼','怪物-秃鹫','高级魔法兽')): need.add(k)
sub={k:reg[k] for k in need if k in reg}
sheets=set(); anis=set(); pals=set()
for k,r in sub.items():
    f,bmp,ani,pal=r[:4]
    sheets.add(f'{f}_{bmp}'); pals.add(f'{f}_{bmp}')
    if ani: anis.add(f'{f}_{ani}')
    if pal: pals.add(f'{f}_{pal}')
for s in sheets: shutil.copy(f'{EXP}/sheets/{s}.png',f'{OUT}/sheets/{s}.png')
rows=json.load(open('tables/anireg.json'))
frames={r[0]:int(r[3]) for r in rows if r[0].startswith('frame_')}
for v in frames.values(): anis.add(f'frame_ani_{v}')
anij={a:json.load(open(f'{EXP}/ani/{a}.json')) for a in anis if os.path.exists(f'{EXP}/ani/{a}.json')}
json.dump(anij,open(f'{OUT}/ani.json','w'),separators=(',',':'))
palidx={}; blob=bytearray()
for p in sorted(pals):
    P=json.load(open(f'{EXP}/pal/{p}.json')); palidx[p]=len(blob)//768; blob+=bytes(x for c in P for x in c)
open(f'{OUT}/pal.bin','wb').write(blob)
for mid,m in maps.items(): json.dump(m,open(f'{OUT}/maps/{mid}.json','w'),ensure_ascii=False,separators=(',',':'))
cit={}; mon={}
for sid in SCENES:
    for id_,nm,pos in scenes[sid]['ents']:
        if id_ in CIT: cit[id_]=CIT[id_]
        if id_ in MON: mon[id_]=MON[id_]
data=dict(frames=frames,reg=sub,palidx=palidx,scenes={k:scenes[k] for k in SCENES},cit=cit,mon=mon)
json.dump(data,open(f'{OUT}/data.json','w'),ensure_ascii=False,separators=(',',':'))
print('reg',len(sub),'sheets',len(sheets),'ani',len(anij),'pals',len(palidx),'maps',len(maps))
