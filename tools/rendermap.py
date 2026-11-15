import sys; sys.path.insert(0,'tools')
from wim import parse_wim, REG
from res import *
from scene import parse_scene
from godat import named
from lstr import lstrings
CIT={i:[s for o,s in lstrings(d)] for i,n,d in named('files/all_citizen.godat')}
MON={i:[s for o,s in lstrings(d)] for i,n,d in named('files/all_monster.godat')}
def pal(v): return int(v) if v not in ('','0') else 0
def draw_sprite(name, anim=0, fr=0):
    r=REG.get(name)
    if not r or r[3] in ('','0') or int(r[3]) not in recs(r[1]): return None,0,0
    A=anidef(r[1],int(r[3])); anims,_=parse_anims(A['rest'])
    f=anims[anim][fr][0] if anim<len(anims) else anim
    return frame_image(r[1],int(r[2]),int(r[3]),pal(r[4]),f)
def render(m, scene=None, out='x.png', grid=False):
    W,H=m['w'],m['h']
    img=Image.new('RGBA',((W+H)*21+200,(W+H)*11+300),(10,10,10,255)); OX=H*21+100; OY=200
    sheets={}
    def tile(setidx,t):
        nm=m['names'][setidx-1]
        if not nm.startswith('GROUND'): return None
        if nm not in sheets:
            g=REG[nm]; sheets[nm]=sheet(g[1],int(g[2]),pal(g[4]))
        S=sheets[nm]; cols=S.width//42
        return S.crop((t%cols*42,t//cols*22,t%cols*42+42,t//cols*22+22))
    for i,c in enumerate(m['cells']):
        x,y=i%W,i//W
        for s,t in ((c[0]&255,c[2]&255),(c[0]>>8,c[2]>>8)):
            if s:
                tl=tile(s,t)
                if tl: img.alpha_composite(tl,(OX+(x-y)*21-21,OY+(x+y)*11))
        if grid and c[4]:
            img.alpha_composite(Image.new('RGBA',(6,4),(255,0,0,160)),(OX+(x-y)*21-3,OY+(x+y)*11+9))
    objs=[]
    for i,c in enumerate(m['cells']):
        if c[1]:
            x,y=i%W,i//W; im,ax,ay=draw_sprite(m['names'][c[1]-1],c[3])
            if im: objs.append((x+y,OX+(x-y)*21-ax,OY+(x+y)*11+11-ay,im))
    if scene:
        for id_,nm,(x,y,*_) in scene['ents']:
            info=CIT.get(id_) or MON.get(id_)
            if not info: continue
            im,ax,ay=draw_sprite(info[1])
            if im: objs.append((x+y+0.5,OX+(x-y)*21-ax,OY+(x+y)*11+11-ay,im))
    for _,px,py,im in sorted(objs,key=lambda o:o[0]): img.alpha_composite(im,(px,py))
    img.convert('RGB').save(out); return img.size
