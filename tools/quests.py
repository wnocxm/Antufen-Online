# Orijinal görev kayıtlarını çözer: veren/teslim alan NPC ve sahne, hedef, adet, sonraki görev
import sys,struct,json,re; sys.path.insert(0,'tools')
from godat import named
from tok import toks
L={i:d for i,n,d in named('files/all_task.godat')}
TX=json.load(open('tables/tasks.json'))
SC=json.load(open('exp/scenes.json'))
def clean(s): return re.sub(r'\\C\(\d+,\d+,\d+\)','',s)
def decode(k):
    t=toks(L[k]); out=dict(id=k,title=t[1],count=t[3] if isinstance(t[3],int) else 0)
    ints=[(i,x) for i,x in enumerate(t) if isinstance(x,int)]
    # sahne+NPC çiftleri
    pairs=[]
    for i in range(len(t)-1):
        if isinstance(t[i],int) and isinstance(t[i+1],int) and 120000<=t[i]<=120999 and 50000<=t[i+1]<=51999: pairs.append((t[i],t[i+1]))
    out['giver']=pairs[0] if pairs else None; out['to']=pairs[1] if len(pairs)>1 else (pairs[0] if pairs else None)
    # hedef canavar: ad + kimlik + sahne
    tg=[]
    for i in range(len(t)-2):
        if isinstance(t[i],str) and isinstance(t[i+1],int) and 70000<=t[i+1]<=79999 and isinstance(t[i+2],int) and 120000<=t[i+2]<=120999: tg.append((t[i],t[i+1],t[i+2]))
    out['targets']=tg
    nxt=[x for i,x in ints if 80000<=x<=89999 and x!=k]; out['next']=nxt[:2]
    tx=TX.get(str(k)); out['texts']=[clean(x) for x in tx[:10]] if tx else []
    return out
if __name__=='__main__':
    want=set(map(int,sys.argv[1].split(',')))
    res=[]
    for k in L:
        try: q=decode(k)
        except Exception as e: continue
        if q['giver'] and q['giver'][0] in want: res.append(q)
    json.dump(res,open(sys.argv[2],'w'),ensure_ascii=False)
    for q in sorted(res,key=lambda q:q['id']): print(q['id'],q['title'],'veren',q['giver'],'teslim',q['to'],'adet',q['count'],'hedef',[x[0] for x in q['targets']],'sonraki',q['next'])
