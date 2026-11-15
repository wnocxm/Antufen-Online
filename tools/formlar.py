# Android sürümündeki yeni arayüz ekran tanımlarını (NEW_FORM_*) oyunun okuduğu biçime çevirir ve görsellerini kopyalar.
# Kullanım (depo kökünden): python3 tools/formlar.py      Çıktı: www/assets/forms2.json, www/assets/ui2/
# İsteğe bağlı: python3 tools/formlar.py onizle <klasör>  -> her ekranın her sayfasını PNG olarak çizer (inceleme için)
import sys, os, json, shutil, glob
sys.path.insert(0, 'tools')
import godat, forms3
APK = os.environ.get('APK_RES', '/tmp/claude-0/sp/apk/x/assets/Resources')
GOR = 'kaynak/apk/cikti/gorsel'
WANT = None   # None: hepsi
def conv(fm, res):
    cs = []
    for c in fm['ctrls']:
        h = c['h']
        cs.append({'id': c['id'], 't': c['type'], 'pg': h[5], 'g': h[6], 'gy': h[8], 'vis': h[0], 'ev': c['ev'],
                   's': [{'r': s['rect'], 'L': [[L['k'], L['x'], L['y'], L['w'], L['h'], L['a'][0], L['a'][1], L['a'][2], L['col'], L['al'], L['img'], L['txt'], L['f'], L['t'][0], L['t'][1]] for L in s['layers']]} for s in c['states']]})
    return {'id': None, 'res': res, 'w': fm['hdr'][4], 'h': fm['hdr'][5], 'hdr': fm['hdr'], 'c': cs}
out = {}
for f in ['AnbufenUI_1', 'AnbufenUI_2', 'AnbufenUI_3']:
    for i, nm, d in godat.named(f'{APK}/{f}.godat'):
        if d[:6] != b'UIFORM': continue
        try: fm = forms3.parse(d)
        except Exception: continue
        j = conv(fm, f + '_Resource'); j['id'] = i; out[fm['name'].replace('NEW_FORM_', '').lower()] = j
os.makedirs('www/assets/ui2', exist_ok=True)
used = {(v['res'], L[10]) for v in out.values() for c in v['c'] for s in c['s'] for L in s['L'] if L[0] == 2 and L[10]}
n = 0
for res, im in sorted(used):
    src = f'{GOR}/{res}/{im}.png'
    if os.path.exists(src): shutil.copy(src, f'www/assets/ui2/{res}_{im}.png'); n += 1
json.dump(out, open('www/assets/forms2.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('ekran', len(out), 'görsel', n, 'eksik görsel', len(used) - n)

if len(sys.argv) > 2 and sys.argv[1] == 'onizle':
    from PIL import Image, ImageDraw, ImageFont
    O = sys.argv[2]; os.makedirs(O, exist_ok=True); cache = {}
    try: font = ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc', 11)
    except Exception: font = ImageFont.load_default()
    def img(res, i):
        k = (res, i)
        if k not in cache:
            p = f'{GOR}/{res}/{i}.png'; cache[k] = Image.open(p).convert('RGBA') if os.path.exists(p) else None
        return cache[k]
    for name, f in out.items():
        pages = sorted({c['pg'] for c in f['c'] if c['pg'] >= 0}) or [-1]
        W, H = max(60, f['w'] if f['w'] > 0 else 480), max(60, f['h'] if f['h'] > 0 else 320)
        sheet = Image.new('RGBA', ((W + 6) * len(pages), H + 4), (40, 40, 70, 255))
        for pi, pg in enumerate(pages):
            cv = Image.new('RGBA', (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(cv)
            for c in reversed(f['c']):
                if not c['s'] or (c['pg'] != -1 and c['pg'] != pg) or c['g'] != -1: continue
                s = c['s'][0]; cx, cy = s['r'][0], s['r'][1]
                for L in reversed(s['L']):
                    k, x, y, w, h, a0, a1 = L[:7]; X, Y = cx + x, cy + y
                    if k == 2 and L[10]:
                        I = img(f['res'], L[10])
                        if I is None: d.rectangle((X, Y, X + w, Y + h), outline=(255, 0, 255)); continue
                        sw, sh = min(w, I.width - a0), min(h, I.height - a1)
                        if sw <= 0 or sh <= 0: continue
                        t = I.crop((a0, a1, a0 + sw, a1 + sh))
                        for yy in range(0, h, sh):
                            for xx in range(0, w, sw): cv.alpha_composite(t.crop((0, 0, min(sw, w - xx), min(sh, h - yy))), (max(0, X + xx), max(0, Y + yy))) if X + xx >= 0 and Y + yy >= 0 and X + xx < W and Y + yy < H else None
                    elif k == 3 and L[11]: d.text((X + 2, Y + 2), L[11], fill=(255, 255, 255), font=font)
                    elif k == 0: d.rectangle((X, Y, X + max(1, w), Y + max(1, h)), fill=(L[8] >> 16 & 255, L[8] >> 8 & 255, L[8] & 255))
            sheet.alpha_composite(cv, (pi * (W + 6) + 2, 2))
        sheet.save(f'{O}/{name}.png')
