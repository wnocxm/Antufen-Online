import struct,zlib
from PIL import Image
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
        st=(w+3)&~3   # satırlar 4 bayta tamamlanır (BMP gibi)
        if st!=w and len(px)>=st*h: px=b''.join(px[y*st:y*st+w] for y in range(h))
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
