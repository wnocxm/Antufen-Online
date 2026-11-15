import sys,os,json,struct,re
sys.path.insert(0,'tools')
from godat import named, records
from img import chunks
from spr import parse
from res import parse_anims
from PIL import Image
OUT=sys.argv[1]
os.makedirs(OUT+'/sheets',exist_ok=True); os.makedirs(OUT+'/ani',exist_ok=True); os.makedirs(OUT+'/pal',exist_ok=True)
REGROWS=json.load(open('tables/anireg.json'))
CACHE={}
def recs(f):
    if f not in CACHE:
        try: CACHE[f]={i:d for i,n,d in named('files/'+f)}
        except Exception: CACHE[f]={}
    return CACHE[f]
def index_image(b):
    hdr=struct.unpack_from('<6I',b,0); w,h=hdr[3],hdr[4]
    import zlib
    a=b.find(b'\x78\x9c',24); cs,rs=struct.unpack_from('<II',b,a-8)
    epal=zlib.decompress(b[a:a+cs]); p=a+cs
    P=[[epal[k*4+2],epal[k*4+1],epal[k*4]] for k in range(256)]
    groups=[]
    if hdr[5]==0:
        cs,rs=struct.unpack_from('<II',b,p); p+=8
        px=zlib.decompress(b[p:p+cs]) if rs else b[p:p+cs]
        groups=[px]
    while hdr[5]!=0 and p+8<=len(b):
        tot,cnt=struct.unpack_from('<II',b,p); p+=8; parts=[]
        for k in range(cnt):
            cs,rs=struct.unpack_from('<II',b,p); p+=8
            parts.append(zlib.decompress(b[p:p+cs]) if rs else b[p:p+cs]); p+=cs
        groups.append(b''.join(parts))
    L=bytearray(w*h); A=bytearray(w*h)
    if len(groups)==1 and len(groups[0])>=w*h:
        px=groups[0]
        L[:]=px[:w*h]
        for k in range(w*h):
            A[k]=0 if P[px[k]]==[255,0,255] else 255
    else:
        table,px=groups[0],groups[1]; p=0
        for y in range(h):
            if p+2>len(table): break
            n=struct.unpack_from('<H',table,p)[0]//8; p+=2
            for s in range(n):
                off,x0,x1=struct.unpack_from('<IHH',table,p); p+=8
                x1=min(x1,w); q=y*w+x0
                L[q:q+x1-x0]=px[off:off+x1-x0]; A[q:q+x1-x0]=b'\xff'*(x1-x0)
    im=Image.merge('LA',(Image.frombytes('L',(w,h),bytes(L)),Image.frombytes('L',(w,h),bytes(A))))
    return im,P
FAIL=[]
done_sheet={}; done_ani=set(); done_pal=set()
def ex_sheet(f,bmp):
    key=f'{f[:-6]}_{bmp}'
    if key in done_sheet: return done_sheet[key]
    b=recs(f).get(bmp)
    if not b or b[:8]!=b'\0\0\0\0\x08\0\0\0': done_sheet[key]=None; return None
    try: im,P=index_image(b)
    except Exception as e:
        FAIL.append((key,str(e)[:60])); done_sheet[key]=None; return None
    im.save(f'{OUT}/sheets/{key}.png',optimize=True)
    json.dump(P,open(f'{OUT}/pal/{key}.json','w'),separators=(',',':'))
    done_sheet[key]=(im.width,im.height); return done_sheet[key]
def ex_pal(f,pal):
    key=f'{f[:-6]}_{pal}'
    if key in done_pal: return True
    d=recs(f).get(pal)
    if not d or d[:4]!=b'RIFF': return False
    p=d[24:24+1024]; P=[[p[i*4],p[i*4+1],p[i*4+2]] for i in range(256)]
    json.dump(P,open(f'{OUT}/pal/{key}.json','w'),separators=(',',':')); done_pal.add(key); return True
def ex_ani(f,ani):
    key=f'{f[:-6]}_{ani}'
    if key in done_ani: return True
    d=recs(f).get(ani)
    if not d: return False
    try: p=parse(d); anims,_=parse_anims(p['rest'])
    except Exception as e: FAIL.append((key,'ani '+str(e)[:40])); done_ani.add(key); return False
    j=dict(m=[list(m) for m in p['mods']], f=[[list(x) for x in parts] for rect,parts in p['frames']], a=[[list(x) for x in s] for s in anims])
    json.dump(j,open(f'{OUT}/ani/{key}.json','w'),separators=(',',':')); done_ani.add(key); return True
def i0(v):
    try: return int(v)
    except: return 0
reg={}
filt=re.compile(sys.argv[2]) if len(sys.argv)>2 else None
for r in REGROWS:
    name,f=r[0],r[1]
    if filt and not filt.search(name): continue
    bmp,ani,pal=i0(r[2]),i0(r[3]),i0(r[4])
    if not f.endswith('.godat') or not bmp: continue
    sz=ex_sheet(f,bmp)
    if not sz: continue
    if ani: ex_ani(f,ani)
    if pal and not ex_pal(f,pal): pal=0
    reg[name]=[f[:-6],bmp,ani,pal]+[i0(x) for x in r[5:8]]
json.dump(reg,open(f'{OUT}/reg.json','w'),ensure_ascii=False,separators=(',',':'))
print('fail',len(FAIL),FAIL[:8]); print('sheets',len([v for v in done_sheet.values() if v]),'ani',len(done_ani),'pal',len(done_pal),'reg',len(reg))
