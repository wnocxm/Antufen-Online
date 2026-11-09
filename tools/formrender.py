import json,sys,os
from PIL import Image,ImageDraw,ImageFont
UI='/home/user/antufen-online/www/assets/ui/'
F=json.load(open('forms.json'))
cache={}
def img(i):
    if i not in cache:
        p=f'{UI}AnbufenUI_Resource_{i}.png'
        cache[i]=Image.open(p).convert('RGBA') if os.path.exists(p) else None
    return cache[i]
try: font=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',11)
except Exception: font=ImageFont.load_default()
def render(fid,state=0,scale=2,labels=False):
    f=F[str(fid)]; W=max(f['hdr'][4],50); H=max(f['hdr'][5],50)
    if W<0 or W>1000: W,H=640,360
    C=Image.new('RGBA',(W,H),(70,70,90,255)); d=ImageDraw.Draw(C)
    for c in reversed(f['ctrls']):
        if not c['states']: continue
        s=c['states'][min(state,len(c['states'])-1)]; cx,cy,cw,ch=s['rect']
        for L in reversed(s['layers']):
            x=cx+L['x']; y=cy+L['y']; w=L['w']; h=L['h']
            if L['k']==2 and L['img']:
                im=img(L['img'])
                if im is None: d.rectangle([x,y,x+w,y+h],outline=(255,0,255)); continue
                sx,sy=L['a'][0],L['a'][1]
                if w<=0 or h<=0: w,h=im.size
                tile=im.crop((sx,sy,min(im.width,sx+w),min(im.height,sy+h)))
                for yy in range(0,h,max(1,tile.height)):
                    for xx in range(0,w,max(1,tile.width)):
                        t=tile.crop((0,0,min(tile.width,w-xx),min(tile.height,h-yy))); C.alpha_composite(t,(max(0,x+xx),max(0,y+yy))) if x+xx>=0 and y+yy>=0 else None
            elif L['k']==0:
                col=L['col']; a=(col>>24)&255; rgb=((col>>16)&255,(col>>8)&255,col&255)
                if a: d.rectangle([x,y,x+max(w,1)-1,y+max(h,1)-1],fill=rgb+(255,))
            elif L['txt']:
                col=L['col']; d.text((x+2,y+2),L['txt'],fill=((col>>16)&255,(col>>8)&255,col&255,255),font=font)
        if labels: d.text((cx,cy),str(c['id']%1000),fill=(0,255,0,255))
    return C.resize((W*scale,H*scale),Image.NEAREST)
if __name__=='__main__':
    for a in sys.argv[1:]: render(int(a)).save(f'form_{a}.png')
