import sys,os,json,struct
sys.path.insert(0,'tools')
from godat import named
from wim import parse_wim
from scene import parse_scene, rs
from lstr import lstrings
OUT=sys.argv[1]; os.makedirs(OUT+'/maps',exist_ok=True)
WIM={}
for f in os.listdir('files'):
    if f.startswith('mapfile_'):
        for i,n,d in named('files/'+f): 
            if n: WIM[n.lower()]=d
SC={i:d for i,n,d in named('files/all_scene.godat')}
def tail_exits(t):
    # çıkışlar: sayı, (id, ad) ...; ardından kaynak adları
    o=0; out=[]
    try:
        n=struct.unpack_from('<I',t,o)[0]; o+=4
        for k in range(n):
            id_=struct.unpack_from('<I',t,o)[0]; nm,o=rs(t,o+4); out.append([id_,nm])
    except Exception: pass
    return out
scenes={}; maps_done={}
for sid,d in SC.items():
    try: s=parse_scene(d)
    except Exception as e: continue
    key=s['wim'].lower()
    if key not in WIM: continue
    mid=key.replace('\\','/').split('/')[-1][:-4]
    if mid not in maps_done:
        m=parse_wim(WIM[key])
        regs=[m['ints'][i:i+6] for i in range(0,len(m['ints']),6)]
        cells=m['cells']
        json.dump(dict(w=m['w'],h=m['h'],names=m['names'],regions=regs,
            c=[c[0] for c in cells],o=[c[1] for c in cells],t=[c[2] for c in cells],a=[c[3] for c in cells],b=[c[4] for c in cells]),
            open(f'{OUT}/maps/{mid}.json','w'),ensure_ascii=False,separators=(',',':'))
        maps_done[mid]=(m['w'],m['h'])
    scenes[sid]=dict(name=s['name'],map=mid,music=s['music'],kind=s['abc'],ents=[[i,n,list(r)] for i,n,r in s['ents']],exits=tail_exits(s['tail']))
json.dump(scenes,open(f'{OUT}/scenes.json','w'),ensure_ascii=False,separators=(',',':'))
print('scenes',len(scenes),'maps',len(maps_done))
