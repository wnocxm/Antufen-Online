# Beceri kayıtlarından gerçek değerleri çıkarır: bekleme süresi, kademe tabloları, açıklamadaki sabit adları
import sys,struct,re,json; sys.path.insert(0,'tools')
from godat import named
from lstr import lstrings
SK={i:d for i,n,d in named('files/all_skill.godat')}
def runs(d):
    out=[]
    for base in (0,1,2,3):
        vals=[]; 
        n=(len(d)-base)//4; a=struct.unpack_from('<%di'%n,d,base)
        i=0
        while i<n:
            j=i; seq=[]
            while j<n and 0<a[j]<2000000 and (not seq or a[j]>=seq[-1]) and len(seq)<10: seq.append(a[j]); j+=1
            if len(seq)>=9 and seq[-1]>seq[0]: out.append((base+i*4,seq)); i=j
            else: i+=1
    # aynı diziyi farklı hizada iki kez bulmayı ele: 65536 katlarını indir
    res=[]
    for o,s in sorted(out):
        if all(v%65536==0 for v in s): s=[v>>16 for v in s]
        if any(abs(o-o2)<4 for o2,_ in res): continue
        if max(s)>200000: continue
        res.append((o,s))
    return res
def info(k):
    d=SK[k]; ss=[s for o,s in lstrings(d)]; desc=next((s for s in ss if '$' in s),'')
    consts=[]; 
    for m in re.finditer(r'\$(const|const_next)\((\w+)\)\$',desc):
        if m.group(1)=='const' and m.group(2) not in consts: consts.append(m.group(2))
    cd=None
    for base in (0,2):
        n=(len(d)-base)//4; a=struct.unpack_from('<%di'%n,d,base)
        for i in range(n-1):
            if a[i]==350 and 200<=a[i+1]<=600000: cd=a[i+1]
            if a[i] in (550,) and 200<=a[i+1]<=600000 and cd is None: cd=a[i+1]
    return dict(name=ss[0],consts=consts,cd=cd,tables=[s for o,s in runs(d)],desc=desc[:200])
if __name__=='__main__':
    ids=[90020,90022,90043,90042,90095,90021,90044,90040,90096,90084,90104,90105,90122,90124,90125,90097,90126,90123,90127,90130,90131,90098,90129,90128,90312,90313,90314,90315,90316,90317,90319,90320,90318,90321,90323,90322]
    out={}
    for k in ids:
        r=info(k); out[k]=r; print(k,r['name'],'cd',r['cd'],r['consts']); 
        for t in r['tables']: print('     ',t)
    json.dump(out,open('skills_raw.json','w'),ensure_ascii=False)
