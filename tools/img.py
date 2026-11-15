import sys,struct,zlib; sys.path.insert(0,'tools')
from godat import records
def chunks(b):
    p=24; out=[]
    while p<len(b)-8:
        i=b.find(b'\x78\x9c',p)
        if i<0: break
        cs,rs=struct.unpack_from('<II',b,i-8)
        raw=zlib.decompressobj().decompress(b[i:i+cs])
        out.append((b[p:i-8],raw)); p=i+cs
    return out

def decode(b, bgr=True):
    from PIL import Image
    hdr=struct.unpack_from('<6I',b,0); w,h=hdr[3],hdr[4]
    ch=chunks(b)
    pal=ch[0][1]
    # group remaining chunks: header pre bytes contain total size + count
    rest=ch[1:]; groups=[]; i=0
    while i<len(rest):
        pre,raw=rest[i]
        tot,cnt=struct.unpack_from('<II',pre,len(pre)-8) if len(pre)>=8 else (len(raw),1)
        data=b''.join(r for _,r in rest[i:i+cnt]); groups.append(data); i+=cnt
    P=bytes(x for k in range(256) for x in ((pal[k*4+2],pal[k*4+1],pal[k*4]) if bgr else (pal[k*4],pal[k*4+1],pal[k*4+2])))
    if len(groups)==1 and len(groups[0])>=w*h:
        px=groups[0][:w*h]; im=Image.frombytes('P',(w,h),px); im.putpalette(P); return im.convert('RGBA')
    table,px=groups[0],groups[1]
    im=Image.new('RGBA',(w,h),(0,0,0,0)); pix=im.load(); p=0
    for y in range(h):
        if p+2>len(table): break
        n=struct.unpack_from('<H',table,p)[0]//8; p+=2
        for s in range(n):
            off,x0,x1=struct.unpack_from('<IHH',table,p); p+=8
            for x in range(x0,min(x1,w)):
                c=px[off+x-x0]; pix[x,y]=(P[c*3],P[c*3+1],P[c*3+2],255)
    return im
