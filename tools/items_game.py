# items.json'u oyuna uygun biçime çevirir (Türkçe ad, sınıf, oyun ölçeğinde değerler)
import json,sys; sys.path.insert(0,sys.argv[3])
from items_tr import TRN,TAB,SLOT,WCLS
D=json.load(open(sys.argv[1])); IT=D['items']; out={}; shops={}
CL=['战士','法师','牧师']
for npc,tabs in D['shops'].items():
    T=[]
    for tab,ids in tabs:
        if tab not in TAB: continue
        keep=[]
        for k,i in enumerate(ids):
            it=IT[str(i)]
            if tab=='药品' and not it.get('heal'): continue
            keep.append(str(i))
            if str(i) in out: continue
            if tab=='药品':
                out[str(i)]=dict(name=TRN[it['cn']],icon=it['icon'],price=it['price'],sell=max(1,it['sell']),use={it['res']:round(it['heal']/4)},
                    desc=f"{round(it['heal']/4)} {'can' if it['res']=='hp' else 'mana'} yeniler.")
                continue
            slot=SLOT[it['slot']]; cls=it['cls'] or WCLS.get(it['slot']) or (CL[k%3] if slot in ('body','head','belt','shoe') else None)
            st=it['stats']; lv=it['lv']; g={}
            a=next(iter(st.items()),(None,0)); key,v=a
            if slot=='weap': g['atk']=round((v or 60+4*lv)/12)
            elif slot=='body': g['def']=round((st.get('def') or 80+9*lv)/12)
            elif slot=='head':
                hv=st.get('hp') or {'战士':900,'法师':250,'牧师':580}[cls]*(1+lv/25)
                g['hp']=round(hv/20)
            elif slot=='belt': g['def']=max(1,round(v/14)); g['hp']=round(lv*1.5)
            elif slot=='shoe':
                mv=st.get('31') or {'战士':80,'法师':480,'牧师':480}[cls]*(1+lv/20); g['mp']=round(mv/10)
            elif slot=='glove':
                if 'atk' in st: g['atk']=round(st['atk']/12)
                else: g['crit']=round(st.get('hit',20)/5)
            elif slot=='neck':
                if 'hpreg' in st: g['hpreg']=st['hpreg']
                elif '33' in st: g['mpreg']=st['33']
                elif 'def' in st: g['def']=round(st['def']/4)
                else: g['res']=round(lv/2)+5
            elif slot=='ring':
                if '44' in st: g['dodge']=round(st['44']/4)
                else: g['res']=round(v/6)
            gfx=it['gfx']; gp=gfx.rsplit('_',1)[0] if gfx else None
            out[str(i)]=dict(name=TRN[it['cn']],icon=it['icon'],price=it['price'],sell=max(1,it['sell']),slot=slot,cls=cls,lv=lv,st=g,gfx=gp)
        if keep: T.append([TAB[tab],keep])
    shops[npc]=T
json.dump(dict(items=out,shops=shops),open(sys.argv[2],'w'),ensure_ascii=False,separators=(',',':'))
print(len(out),{k:[(a,len(b)) for a,b in v] for k,v in shops.items()})
