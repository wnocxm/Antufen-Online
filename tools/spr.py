import struct
class R:
    def __init__(s,d,o=0): s.d=d; s.o=o
    def u8(s): v=s.d[s.o]; s.o+=1; return v
    def s8(s): v=struct.unpack_from('>b',s.d,s.o)[0]; s.o+=1; return v
    def u16(s): v=struct.unpack_from('>H',s.d,s.o)[0]; s.o+=2; return v
    def s16(s): v=struct.unpack_from('>h',s.d,s.o)[0]; s.o+=2; return v
def parse(d, verbose=False):
    r=R(d); ver=r.u8(); r.u16(); nm=r.u16()
    mods=[(r.u16(),r.u16(),r.u16(),r.u16(),r.u16()) for _ in range(nm)]
    nf=r.u16(); frames=[]
    for i in range(nf):
        rect=(r.s16(),r.s16(),r.s16(),r.s16())
        np_=r.u16(); parts=[]
        for j in range(np_):
            m=r.u8(); fl=r.u8(); x=r.s16(); y=r.s16(); a=r.u8(); parts.append((m,fl,x,y,a))
        frames.append((rect,parts))
    pos=r.o
    return dict(ver=ver,mods=mods,frames=frames,rest=d[pos:],pos=pos)
