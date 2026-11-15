import struct,re,json
REG={r[0]:r for r in json.load(open('tables/anireg.json'))}
def parse_wim(d):
    ver,w,h,tw,th,ng=struct.unpack_from('<6I',d,0); o=24
    # isim listesinden önceki tamsayılar: sonuna kadar oku, isim sayısını bul
    ints=[]
    while True:
        n=struct.unpack_from('<I',d,o)[0]
        # isim sayısı ardından uzunluk + 'GROUND' gelirse dur
        if 0<n<50:
            ln=struct.unpack_from('<I',d,o+4)[0]
            if 0<ln<60:
                try:
                    s=d[o+8:o+8+2*ln].decode('utf-16le')
                    if s.startswith(('GROUND','OBJECT','ACT')): break
                except Exception: pass
        ints.append(n); o+=4
    nn=struct.unpack_from('<I',d,o)[0]; o+=4; names=[]
    for i in range(nn):
        ln=struct.unpack_from('<I',d,o)[0]; o+=4; names.append(d[o:o+2*ln].decode('utf-16le')); o+=2*ln
    cells=[struct.unpack_from('<6H',d,o+i*12) for i in range(w*h)]
    o2=o+w*h*12
    return dict(w=w,h=h,tw=tw,th=th,ng=ng,ints=ints,names=names,cells=cells,tail=d[o2:])
