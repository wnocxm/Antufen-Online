import struct,zlib,sys,os
d=open(sys.argv[1],'rb').read(); out=sys.argv[2]; os.makedirs(out,exist_ok=True)
def rdlen(b,o):
    l,=struct.unpack_from('<I',b,o); o+=4
    if l&0x80000000: hi,=struct.unpack_from('<I',b,o); o+=4; l=(l&0x7fffffff)|(hi<<31)
    return l,o
def field(b,o):
    t,=struct.unpack_from('<I',b,o); l,o=rdlen(b,o+4)
    return t,b[o:o+l],o+l+((4-l%4)%4)
def elems(v):
    et,=struct.unpack_from('<I',v,0); p=4; r=[]
    while p<len(v):
        l,p2=rdlen(v,p); r.append((et,v[p2:p2+l])); p=p2+l+((4-l%4)%4)
    return r
def children(v):
    p=0; r=[]
    while p+8<=len(v): t,x,p=field(v,p); r.append((t,x))
    return r
def decomp(v):
    alg,=struct.unpack_from('<I',v,0); return zlib.decompress(v[12:]) if alg==1 else v[12:]
_,contents,_=field(d,16)
ch=children(contents)
print([t for t,_ in ch])
ctrl=decomp([x for t,x in ch if t==3][0]); open(out+'/_controller.bin','wb').write(ctrl)
data=[x for t,x in ch if t==34][0]
# SISData: Array of DataUnit
du=children(data)
files=[]
for t,arr in du:
    for et,unit in elems(arr):
        for t2,fd in children(unit):
            for et3,fdata in elems(fd):
                for t4,comp in children(fdata):
                    if t4==3: files.append(decomp(comp))
print('files',len(files))
# file names in controller FileDescription order (type 24)
import re
names=[]
def scan(v,depth=0):
    for t,x in children(v):
        if t==24:
            # FileDescription: String target, String mimetype, ... , index
            c=children(x); tgt=c[0][1].decode('utf-16le'); names.append(tgt)
            idx=struct.unpack_from('<I',x,len(x)-4)[0]
            names[-1]=(tgt,idx)
        elif t in (2,):
            for et,e in elems(x): scan(struct.pack('<II',et,len(e))+e+b'\0'*((4-len(e)%4)%4))
        elif t in (13,28,26,27):
            scan(x)
scan(ctrl)
print(len(names), names[:3])
for (n,idx) in names:
    if idx<len(files):
        fn=n.split('\\')[-1]
        open(f'{out}/{fn}','wb').write(files[idx])
print(len(os.listdir(out)))
