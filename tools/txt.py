import sys,os,re
d=sys.argv[1]
for f in sorted(os.listdir(d)):
    b=open(os.path.join(d,f),'rb').read()
    best=None
    for enc in ('utf-8-sig','utf-16'):
        try:
            t=b.decode(enc); 
            cjk=len(re.findall(r'[一-鿿]',t))
            if cjk>20 and (best is None or cjk>best[1]): best=(enc,cjk,t)
        except Exception: pass
    if not best:
        try: t=b.decode('gbk'); c=len(re.findall(r'[一-鿿]',t)); 
        except Exception: c=0
        if c>200 and c>len(b)/6: best=('gbk',c,t)
    if best:
        open(f'txt/{f}.txt','w').write(best[2]); print(f,best[0],best[1],len(b))
