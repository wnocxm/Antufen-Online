# Orijinal ekran tanımları: denetimleri imzadan bulup çözer (konum, durumlar, katmanlar, yazılar, görseller)
import sys,struct,json; sys.path.insert(0,'tools')
from godat import named
class R:
    def __init__(s,b,p=0): s.b=b; s.p=p
    def i(s): v=struct.unpack_from('<i',s.b,s.p)[0]; s.p+=4; return v
    def u8(s): v=s.b[s.p]; s.p+=1; return v
    def st(s): n=s.u8(); v=s.b[s.p:s.p+n].decode('ascii'); s.p+=n; return v
def ctrl_at(d,p):
    r=R(d,p); h=[r.i() for _ in range(12)]
    if not (50000<=h[0]<=54000 and 0<=h[1]<=20 and h[2] in (0,1) and h[3] in (0,1) and h[4]==0 and h[5]==0 and -1<=h[7]<=64 and 0<=h[11]<=6): return None
    ev=[r.st() for _ in range(13)]
    if any(e and not e.startswith('C%d_On'%h[0]) for e in ev): return None
    states=[]
    for s in range(h[11]):
        rect=[r.i() for _ in range(4)]; sidx=r.i(); nl=r.i(); layers=[]
        if not (0<=nl<300 and -2000<rect[0]<2000 and 0<=rect[2]<2000 and 0<=rect[3]<2000): return None
        for l in range(nl):
            L=[r.i() for _ in range(16)]; txt=''
            if 0<L[15]<200: txt=d[r.p:r.p+2*L[15]].decode('utf-16le','replace'); r.p+=2*L[15]
            layers.append(dict(k=L[0],x=L[1],y=L[2],w=L[3],h=L[4],a=L[5:8],col=L[8]&0xffffffff,f=L[9],al=L[10],e=L[11],img=L[12],t=L[13:15],txt=txt))
        states.append(dict(rect=rect,idx=sidx,layers=layers))
    return dict(id=h[0],type=h[1],h=h[2:11],ev=[e[7:] for e in ev if e],states=states,end=r.p)
def parse(d):
    r=R(d,6); r.st(); name=r.st(); hdr=[r.i() for _ in range(9)]
    cs=[]; p=r.p
    while p<len(d)-48:
        c=None
        try: c=ctrl_at(d,p)
        except Exception: c=None
        if c: c['at']=p; cs.append(c); p=c['end']
        else: p+=1
    return dict(name=name,hdr=hdr,ctrls=cs)
if __name__=='__main__':
    F={}; tot=0; exp=0
    for fid,n,d in named('files/AnbufenUI.godat'):
        f=parse(d); F[fid]=f; tot+=len(f['ctrls']); exp+=f['hdr'][8]
        gap=sum(1 for a,b in zip(f['ctrls'],f['ctrls'][1:]) if b['at']-a['end']>64)
        if len(sys.argv)>2: print(fid,f['name'],'ctrls',len(f['ctrls']),'hdr',f['hdr'][8],'bigGaps',gap)
    print('toplam denetim',tot,'başlıklarda',exp)
    json.dump(F,open(sys.argv[1],'w'),ensure_ascii=False)
