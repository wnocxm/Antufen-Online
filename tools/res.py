import sys,struct,json,functools
sys.path.insert(0,'tools')
from godat import records
from img import chunks
from spr import parse
from PIL import Image
@functools.lru_cache(maxsize=None)
def recs(f): return dict(records('files/'+f))
def pal_from_riff(d):
    # RIFF PAL: 24 bayt başlık, sonra 256 x (R,G,B,flag)
    p=d[24:24+1024]; return [ (p[i*4],p[i*4+1],p[i*4+2]) for i in range(256)]
@functools.lru_cache(maxsize=None)
def sheet(f,bmp,pal=0):
    from img2 import index_image
    L,P0=index_image(recs(f)[bmp])
    P=pal_from_riff(recs(f)[pal]) if pal else [tuple(p) for p in P0]
    l,a=L.split(); lut=bytes(x for c in P for x in c)
    rgb=l.convert("P"); rgb.putpalette(lut); im=rgb.convert("RGB").convert("RGBA"); im.putalpha(a); return im
def _old_sheet(f,bmp,pal=0):
    """görseli RGBA olarak döndür; pal=0 gömülü palet (BGR), aksi halde RIFF palet kaydı"""
    b=recs(f)[bmp]
    hdr=struct.unpack_from('<6I',b,0); w,h=hdr[3],hdr[4]
    ch=chunks(b); epal=ch[0][1]
    if pal:
        P=pal_from_riff(recs(f)[pal])
    else:
        P=[(epal[k*4+2],epal[k*4+1],epal[k*4]) for k in range(256)]
    rest=ch[1:]; groups=[]; i=0
    while i<len(rest):
        pre,raw=rest[i]
        tot,cnt=struct.unpack_from('<II',pre,len(pre)-8) if len(pre)>=8 else (len(raw),1)
        groups.append(b''.join(r for _,r in rest[i:i+cnt])); i+=cnt
    im=Image.new('RGBA',(w,h),(0,0,0,0))
    if len(groups)==1 and len(groups[0])>=w*h:
        px=groups[0]; data=bytearray(w*h*4)
        for k in range(w*h):
            c=px[k]; r,g,bb=P[c]; data[k*4:k*4+4]=bytes((r,g,bb,0 if (r,g,bb)==(255,0,255) else 255))
        return Image.frombytes('RGBA',(w,h),bytes(data))
    table,px=groups[0],groups[1]
    data=bytearray(w*h*4); p=0
    for y in range(h):
        if p+2>len(table): break
        n=struct.unpack_from('<H',table,p)[0]//8; p+=2
        for s in range(n):
            off,x0,x1=struct.unpack_from('<IHH',table,p); p+=8
            for x in range(x0,min(x1,w)):
                r,g,bb=P[px[off+x-x0]]; q=(y*w+x)*4; data[q:q+4]=bytes((r,g,bb,255))
    return Image.frombytes('RGBA',(w,h),bytes(data))
@functools.lru_cache(maxsize=None)
def anidef(f,ani): return parse(recs(f)[ani])
def parse_anims(rest):
    o=0; n=struct.unpack_from('>H',rest,0)[0]; o=2; anims=[]
    for i in range(n):
        nf=struct.unpack_from('>H',rest,o)[0]; o+=2; seq=[]
        for j in range(nf):
            fr,du=struct.unpack_from('>HH',rest,o); o+=4; seq.append((fr,du))
        o+=1; anims.append(seq)
    return anims,o
def frame_image(f,bmp,ani,pal,frame_idx,shadow=True):
    """bir kareyi çiz; (görüntü, çapa_x, çapa_y) döndür"""
    A=anidef(f,ani); S=sheet(f,bmp,pal)
    rect,parts=A['frames'][frame_idx]
    if not parts: return None,0,0
    boxes=[]
    for m,fl,x,y,a in parts:
        mx,my,mw,mh,_=A['mods'][m]; boxes.append((x,y,x+mw,y+mh))
    x0=min(b[0] for b in boxes); y0=min(b[1] for b in boxes); x1=max(b[2] for b in boxes); y1=max(b[3] for b in boxes)
    out=Image.new('RGBA',(x1-x0,y1-y0),(0,0,0,0))
    for m,fl,x,y,a in parts:
        mx,my,mw,mh,_=A['mods'][m]; piece=S.crop((mx,my,mx+mw,my+mh))
        if fl&1: piece=piece.transpose(Image.FLIP_LEFT_RIGHT)
        if fl&2: piece=piece.transpose(Image.FLIP_TOP_BOTTOM)
        out.alpha_composite(piece,(x-x0,y-y0))
    return out,-x0,-y0
