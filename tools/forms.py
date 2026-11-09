# AnbufenUI.godat içindeki orijinal ekran tanımlarını (form) çözer: her denetimin konumu, boyutu, görseli, olayları
import sys,struct,re,json; sys.path.insert(0,'tools')
from godat import named
def forms():
    out={}
    for fid,n,d in named('files/AnbufenUI.godat'):
        q=7+d[6]; name=d[q+1:q+1+d[q]].decode('latin1'); q=q+1+d[q]
        hdr=struct.unpack_from('<9i',d,q); q+=36
        pos=[m.start() for m in re.finditer(rb'[\x00-\xff][\xc3-\xce]\x00\x00[\x00-\x20]\x00\x00\x00\x01\x00\x00\x00',d) if m.start()>=q]+[len(d)]
        cs=[]
        for a,b in zip(pos,pos[1:]):
            seg=d[a:b]; cid,typ=struct.unpack_from('<II',seg,0)
            ev=[x.decode()[7:] for x in re.findall(rb'C\d{5}_On\w+',seg)]
            rect=None
            for o in range(44,len(seg)-44):
                v=struct.unpack_from('<11i',seg,o)
                if 0<=v[0]<=960 and 0<=v[1]<=640 and 0<v[2]<=960 and 0<v[3]<=640 and v[2]==v[9] and v[3]==v[10] and v[7]==0 and v[8]==0:
                    rect=v[:4]; ro=o; break
            imgs=[]
            if rect:
                tail=seg[ro+44:]
                for k in range(0,len(tail)-3):
                    x=struct.unpack_from('<I',tail,k)[0]
                    if 7000<=x<=7200 or 2000<=x<=2600: imgs.append(x)
            cs.append(dict(id=cid,type=typ,rect=rect,ev=ev,img=imgs[:3]))
        out[fid]=dict(name=name,hdr=hdr,ctrls=cs)
    return out
if __name__=='__main__':
    F=forms()
    for fid in map(int,sys.argv[1:]):
        f=F[fid]; print(fid,f['name'],f['hdr'])
        for c in f['ctrls']: print('   ',c['id'],'t%d'%c['type'],c['rect'],c['img'],' '.join(c['ev']))
