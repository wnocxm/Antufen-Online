import sys,struct; sys.path.insert(0,'tools')
from godat import named
def rs(d,o):
    n=struct.unpack_from('<I',d,o)[0]; return d[o+4:o+4+2*n].decode('utf-16le'), o+4+2*n
def parse_scene(d):
    o=0; name,o=rs(d,o); wim,o=rs(d,o)
    a,b,c=struct.unpack_from('<3I',d,o); o+=12
    music,o=rs(d,o)
    hdr=struct.unpack_from('<3I',d,o); o+=12
    # varlık listesi
    n=struct.unpack_from('<I',d,o)[0]; o+=4
    ents=[]
    for i in range(n):
        ln=struct.unpack_from('<I',d,o)[0]; st=o+4
        id_,z=struct.unpack_from('<2I',d,st); nm,p=rs(d,st+8)
        rest=struct.unpack_from('<%dI'%((st+ln-p)//4),d,p)
        ents.append((id_,nm,rest)); o=st+ln
    tail=d[o:]
    return dict(name=name,wim=wim,abc=(a,b,c),music=music,hdr=hdr,ents=ents,tail=tail)
