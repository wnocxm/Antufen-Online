import struct,zlib,sys,re
def read(path):
    b=open(path,'rb').read()
    assert b[:8] in (b'sy2dr2.6',b'GODAT2.5',b'\0'*8), path   # bazı yeni arşivlerde imza boş bırakılmış
    n,tsize=struct.unpack_from('<II',b,15)
    p=23; ents=[]
    for i in range(n):
        id_,off,nl=struct.unpack_from('<III',b,p); p+=12
        name=b[p:p+nl].decode('latin1'); p+=nl
        ents.append((id_,off,name))
    out=[]
    # kayıt sonu: dosyadaki bir sonraki başlangıç (dizin her zaman konuma göre sıralı değildir)
    offs=sorted(set(e[1] for e in ents))+[len(b)]
    import bisect
    for i,(id_,off,name) in enumerate(ents):
        end=offs[bisect.bisect_right(offs,off)]
        out.append((id_,name,b[off:end]))
    return out
def unpack(r):
    if len(r)>=16:
        t,n,cs,rs=struct.unpack_from('<IIII',r,0)
        if t==1 and 16+cs<=len(r):
            try:
                out=[zlib.decompress(r[16:16+cs])]; p=16+cs
                for k in range(n-1):
                    cs,rs=struct.unpack_from('<II',r,p); p+=8
                    out.append(zlib.decompress(r[p:p+cs])); p+=cs
                return b''.join(out)
            except Exception as e:
                pass
    return r
def records(path):
    return [(id_,unpack(r)) for id_,name,r in read(path)]
def named(path):
    return [(id_,name,unpack(r)) for id_,name,r in read(path)]
