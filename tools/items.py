import sys,struct,re,json; sys.path.insert(0,'tools')
from godat import named
from tok import table, toks
E={i:d for i,n,d in named('files/all_equip.godat')}
PRP={i:d for i,n,d in named('files/all_prop.godat')}
PR=table('all_property'); C=table('all_citizen'); SH=table('all_shop')
ICON={}
for f in ['icon_res_equip','icon_res_item']:
    for i,n,d in named(f'files/{f}.godat'):
        if n: ICON[n.lower()]=(f,i)
CLS={130001:'战士',130002:'法师',130010:'牧师'}
SLOT={0:'weap',1:'head',3:'body',5:'glove',7:'neck'}
ATTR={20:'atk',22:'matk',21:'def',30:'hp',43:'hit',32:'hpreg',101:'fireres'}
WANT={'剑':(20,),'杖':(22,),'魔典':(22,),'圣器':(22,),'衣服':(21,),'头部':(30,),'腰带':(21,30,31,2000),'鞋子':(31,30),'手套':(43,20),'项链':(32,33,21,102,103),'戒指':(101,103,120,44)}
def props(d,typ):
    tail=d[-90:]; cand=[]
    for k in range(0,len(tail)-5):
        if tail[k:k+4]!=b'\x01\x00\x00\x00': continue
        v=struct.unpack_from('<I',tail,k+4)[0]
        if v in PR: a=PR[v][1]; cand.append((a[1],a[2]))
    good=[c for c in cand if c[0] in WANT.get(typ,())] or cand
    out={}
    for a,v in good[:1]: out[ATTR.get(a,str(a))]=v
    return out
def icon(path):
    k=path.lower(); r=ICON.get(k)
    return [r[0].replace('icon_res_',''),r[1]] if r else None
items={}
def equip(i):
    t=toks(E[i]); slot_raw=t[11]
    it=dict(cn=t[1],icon=icon(t[2]),gfx=t[4] if isinstance(t[4],str) else None,slot=t[13],price=t[14],sell=t[15],lv=t[20],cls=CLS.get(t[22]),stats=props(E[i],t[13]),desc=t[8] if isinstance(t[8],str) else '')
    items[i]=it
def prop(i):
    d=PRP[i]; t=toks(d)
    heal=None
    for k in range(len(d)-8):
        pass
    dbl=[struct.unpack_from('<d',d,k)[0] for k in range(0,len(d)-7)]
    it=dict(cn=t[1],icon=icon(t[2]),desc=t[3],type=t[8],price=t[10],sell=t[11])
    if t[8]=='药水':
        vals=[v for v in dbl if v in (800.0,2000.0,4000.0,600.0,1500.0,3000.0,8000.0,12000.0,400.0,1000.0)]
        it['heal']=vals[0] if vals else None
        it['res']='mp' if '法力' in t[3] else 'hp'
    items[i]=it
shops={}
for cid in [50178,50179,50027,50030]:
    n,t=C[cid]; name=t[1]; tabs=[]
    sids=[t[k+1] for k,x in enumerate(t) if x==21 and k+1<len(t) and isinstance(t[k+1],int) and t[k+1]>=100000]
    for sid in sids[:1]:
        st=SH[sid][1]; k=1
        while k<len(st):
            if isinstance(st[k],str) and k+1<len(st) and isinstance(st[k+1],int) and 0<st[k+1]<60:
                cnt=st[k+1]; ids=[x for x in st[k+2:k+2+cnt] if isinstance(x,int)]
                if all(x in E or x in PRP for x in ids) and ids: tabs.append([st[k],ids])
                k+=2+cnt
            else: k+=1
    shops[name]=tabs
for tabs in shops.values():
    for tab,ids in tabs:
        for i in ids:
            if i in E: equip(i)
            elif i in PRP: prop(i)
json.dump(dict(items=items,shops=shops),open(sys.argv[1],'w'),ensure_ascii=False)
print({k:[(a,len(b)) for a,b in v] for k,v in shops.items()}, len(items))
