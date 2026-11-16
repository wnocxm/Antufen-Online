# -*- coding: utf-8 -*-
# Evcil hayvan (魔法兽) verisi -> www/assets/pets.json ve evcil eşyaları/dükkânları (www/assets/items.json).
# Kaynaklar ve kararlar: docs/07-evcil.md. Kullanım (depo kökünden): python3 tools/evcil.py
#
#  1) Symbian all_pet.godat (HAM kayıt): her tür = temel biçim + 7 幻化 (dönüşüm) aşaması. Her biçimin adı, görünüşü,
#     simgesi, aşamaya özel konuşma satırı; kuyrukta ömür, şablon (300001 fiziksel / 300005 büyü / 300006 savunma /
#     300007 destek) ve doğuştan beceri. (all_pet.json metin dökümü bu yapıyı kaybettiği için ham kayıt okunur.)
#  2) Symbian all_petData.godat: 7 aşamanın bedeli (altın) ve "所需等级" (gereken evcil seviyesi).
#  3) APK 1024: şablon nitelik oranları + rastgele beceri havuzları (Symbian beceri numaralarıyla).
#  4) APK 1023/1013/1019 (sonraki resmî sürümün verisi): Symbian'da olmayan türler (Kan Meleği, Gölge Kraliçe,
#     Şan/Yemin Kılıcı, Ölü Fener) ve Ateş Devi'nin turuncu/mor paletleri (kaynak/apk/ek).
#  5) Symbian all_skill (beceri adı, açıklaması, simgesi), all_prop (yumurtalar, kutular, dönüşüm eşyaları).
import sys, json, re, struct
sys.path.insert(0, 'tools')
from godat import named
from tok import toks

C = 'kaynak/apk/cikti/metin/config/'
REG = json.load(open('www/assets/data.json'))['reg']
SK = {x['id']: x['metin'] for x in json.load(open('kaynak/cikti/tablo/all_skill.json'))}
ASK = {x['id']: x for x in json.load(open(C + '1019.txt'))}
APK = {p['name']: p for p in json.load(open(C + '1023.txt'))['pets']}
APKT = {p['id']: p for p in json.load(open(C + '1024.txt'))['pets']}
APROP = {x['id']: x for x in json.load(open(C + '1013.txt'))['props']}
PR = {i: d for i, n, d in named('kaynak/orijinal/all_prop.godat')}
SKICON = {n.lower(): i for i, n, d in named('kaynak/orijinal/icon_res_skill.godat') if n}
TRN = json.load(open('kaynak/ceviri/evcil.json', encoding='utf-8'))
AD, KN, BC = TRN['adlar'], TRN['konusma'], TRN['beceri']
eksik = {'ad': set(), 'konusma': set(), 'beceri': set()}
def ad(cn):
    if cn not in AD: eksik['ad'].add(cn); return [cn, cn]
    return AD[cn]
def kn(lines):
    for c in lines:
        if c not in KN: eksik['konusma'].add(c)
    return [KN[c][0] for c in lines if c in KN], [KN[c][1] for c in lines if c in KN]

# ---------- 1) ham all_pet ----------
TPLS = (300001, 300005, 300006, 300007)
def tail(d):
    """kayıt sonu: [0, ömür, bayrak, 0, şablon, beceri sayısı, beceriler...]"""
    for life in (18000, 9000):
        j = len(d)
        while True:
            j = d.rfind(struct.pack('<ii', 0, life), 0, j)
            if j < 0: break
            v = struct.unpack_from('<iiiii', d, j)
            if v[4] in TPLS + (0,) and v[3] == 0 and j + 24 <= len(d):
                n = struct.unpack_from('<i', d, j + 20)[0]
                sk = list(struct.unpack_from(f'<{n}i', d, j + 24)) if 0 < n < 5 and j + 24 + 4 * n <= len(d) else []
                return dict(life=life, flag=v[2], tpl=v[4], skills=sk)
    return None
raw = []
for pid, _, d in named('kaynak/orijinal/all_pet.godat'):
    if pid >= 10000000: continue
    t = toks(d); B = [i for i, x in enumerate(t) if x == 'PET-召唤']
    def S(i): return t[i] if 0 <= i < len(t) and isinstance(t[i], str) else ''
    def chats(i):
        n = t[i + 5] if isinstance(t[i + 5], int) and 0 <= t[i + 5] < 30 else 0
        return [x for x in t[i + 6:i + 6 + n] if isinstance(x, str)]
    h = B[0]; forms = [None] * 8
    forms[0] = dict(cn=S(h - 3), look=S(h - 1), icon=S(h + 1), chat=[])
    for i in B[1:]:
        k = t[i - 4]
        if isinstance(k, int) and 1 <= k <= 7: forms[k] = dict(cn=S(i - 3), look=S(i - 1), icon=S(i + 1), chat=chats(i))
    raw.append(dict(id=pid, cn=forms[0]['cn'], forms=forms, chat=chats(h), **(tail(d) or {})))

def okf(f): return f and f['look'] in REG
species = {}
for r in raw:
    if not r.get('tpl'): continue   # yer tutucu kayıtlar (苍狼王, 深渊虺, 青翼蝠, 邪魂鸟): şablonsuz, görünüşleri yok
    old = species.get(r['cn'])
    if old:   # aynı türün ikinci kaydı (ör. ödül sürümü): eksik biçimleri bundan tamamla
        for k in range(8):
            if not okf(old['forms'][k]) and okf(r['forms'][k]): old['forms'][k] = r['forms'][k]
        old['ids'].append(r['id']); continue
    r['ids'] = [r['id']]; species[r['cn']] = r

# ---------- Ateş Devi: sonraki sürümün paletleri (APK monster39 6001 turuncu, 6002 mor) ----------
# Symbian'da 7 aşamanın hepsi aynı görünüş; APK'da aynı görselin turuncu ve mor paletleri ve mor "杀意火神" türü var.
# Karar (docs/07): 4-6. aşama turuncu, 7. aşama mor 杀意火神 (APK 140040'ın adı ve konuşmasıyla).
fg = species['火巨灵']; a = APK['杀意火神']
for k in (4, 5, 6): fg['forms'][k] = dict(fg['forms'][k], look='怪物-火巨灵-桔')
fg['forms'][7] = dict(cn='杀意火神', look='怪物-火巨灵-紫', icon=a['icon'], chat=[a['dialog1']])
fg['ek'] = 'aşama 4-6 turuncu, 7 mor (APK paletleri)'

# ---------- Yeti (雪人): ham veride temel biçim görselin kendi (kızıl-kahve) paleti, 7. biçim 雪妖 orman trolü ----------
# İkisi de karlı bir yaratığa benzemiyor (kullanıcı bildirdi). Dünyadaki ☆雪人 canavarı beyaz paleti kullanır.
# Karar (docs/07): temel = 怪物-雪人-白, beyazın durduğu 3. aşamaya özgün temel palet; 雪妖 = aynı trol görselinin beyaz-gri paleti.
ye = species['雪人']; f0, f3 = ye['forms'][0], ye['forms'][3]
ye['forms'][0] = dict(f0, look='怪物-雪人-白'); ye['forms'][3] = dict(f3, look='怪物-雪人')
ye['forms'][7] = dict(ye['forms'][7], look='森林巨魔-灰')
ye['ek'] = 'temel beyaz palet, 7. biçim trolün beyaz-gri paleti'

# ---------- 4) sonraki sürümde eklenen türler (APK) ----------
# 1023 alt türü: 1 destek, 2 fiziksel, 3 savunma, 4 büyü
SUB = {1: 300007, 2: 300001, 3: 300006, 4: 300005}
COLORS = ['黑', '红', '白', '灰', '桔', '蓝', '黄', '绿', '紫', '青']
def tint(look, k):
    """aşama verisi olmayan tür için: görselin (aynı ailenin) renk paletleri sırayla, yoksa temel görünüş"""
    root = re.sub('-(' + '|'.join(COLORS) + ')$', '', look)
    v = [f'{root}-{c}' for c in COLORS if f'{root}-{c}' in REG and f'{root}-{c}' != look] + ([root] if root != look else [])
    return v[(k - 1) % len(v)] if v else look
APKNEW = {   # tür: (yumurta, kutu, APK beceri numarası)
    '血天使': ('34139', 'metal', 90910), '暗影女王': ('33755', 'metal', 90908),
    '荣耀之刃': ('34526', 'wood', 91035), '誓约之刃': ('34527', 'wood', 91035), '死灵灯': ('34528', 'metal', 90080),
}
for cn, (egg, box, sk) in APKNEW.items():
    a = APK[cn]; look = a['resource']
    if look not in REG: print('UYARI görünüş yok', cn, look); continue
    forms = [dict(cn=cn, look=look, icon=a['icon'], chat=[])] + [dict(cn=cn, look=tint(look, k) if k < 7 else look, icon=a['icon'], chat=[]) for k in range(1, 8)]
    species[cn] = dict(id=a['id'] + 100000, ids=[], cn=cn, forms=forms, chat=[a[f'dialog{i}'] for i in range(1, 5)], life=18000, flag=0,
                       tpl=SUB[a['subtype']], skills=['a%d' % sk], apk=True, egg=egg, box=box, ek='APK türü; aşamalar renk paletleriyle tamamlandı')

# ---------- 2-3) şablonlar ve aşamalar ----------
st = []
for i, n, d in named('kaynak/orijinal/all_petData.godat'):
    if i == 300001:
        n0 = struct.unpack_from('<I', d, 0)[0]; o = 4 + 2 * n0; cnt = struct.unpack_from('<I', d, o)[0]
        st = [struct.unpack_from('<III', d, o + 4 + 12 * k) for k in range(cnt)]
MULT = [1.0, 1.1, 1.25, 1.45, 1.7, 2.0, 2.25, 2.5]   # APK 1024 attr_multiplier (1.0-2.5) 8 düzeye yayıldı
stages = [dict(cost=0, lv=1, mult=1.0)] + [dict(cost=c, lv=l, mult=MULT[k]) for k, c, l in st]
TPLN = {300001: ('Fiziksel saldırı', 'Physical attack', 'phys'), 300005: ('Büyü saldırısı', 'Magic attack', 'mag'),
        300006: ('Savunma', 'Defense', 'def'), 300007: ('Destek', 'Support', 'sup')}
def kind(i):
    m = SK.get(i)
    if not m: return None
    d = m[1]
    return 'passive' if d.startswith('被动') else 'aura' if d.startswith('光环') else 'support' if d.startswith('辅助') else 'active'
templates = {}
for tid, t in APKT.items():
    pool = [i for k in ('active', 'passive', 'aura') for i in t['skill_pool'][k] if i in SK and kind(i) and i != t['fixed_skill']]
    templates[str(tid)] = dict(tr=TPLN[tid][0], en=TPLN[tid][1], cls=TPLN[tid][2], fixed=t['fixed_skill'], pool=sorted(set(pool), key=pool.index),
                               **{k: t[k] for k in ('base_phys_atk', 'base_mag_atk', 'base_def', 'hp_growth', 'mp_growth', 'hit_growth', 'dodge')})

# ---------- yumurtalar (Symbian all_prop: "魔法兽蛋（X）", açıklamada kutu) ----------
for i, d in PR.items():
    t = toks(d)
    if len(t) < 5 or not isinstance(t[1], str): continue
    m = re.match(r'魔法兽蛋（(.+)）$', t[1])
    if not m or m.group(1) not in species: continue
    s = species[m.group(1)]; s.setdefault('eggs', []).append(str(i))
    if 'egg' not in s: s['egg'] = str(i); s['box'] = 'wood' if '木质' in t[4] else 'metal' if '金属' in t[4] else 'magic'

# ---------- 5) beceriler ----------
def icon_of(path): return SKICON.get((path or '').lower())
skills = {}
def add_skill(k):
    k = str(k)
    if k in skills or k in ('0', ''): return
    if k.startswith('a'):   # APK becerisi (sonraki sürüm): 1019 tablosundan
        x = ASK[int(k[1:])]; icon = icon_of(x['icon']); kd = 'support' if x['desc'].startswith('辅助') else 'active'
    else:
        m = SK[int(k)]; icon = icon_of(next((s for s in m if isinstance(s, str) and s.lower().endswith('.bmp')), '')); kd = kind(int(k))
    if k not in BC: eksik['beceri'].add(k)
    b = BC.get(k, {'tr': [k, ''], 'en': [k, '']})
    skills[k] = dict(tr=b['tr'], en=b['en'], icon=icon, kind=kd)
for t in templates.values():
    add_skill(t['fixed'])
    for i in t['pool']: add_skill(i)

# ---------- oyuna giren türler (yumurtası olanlar) ----------
game = []
for s in species.values():
    if not s.get('egg'): continue
    t = templates[str(s['tpl'])]
    sk = [x for x in s.get('skills', []) if x] or [t['fixed']]   # doğuştan beceri: kayıttaki; yoksa (0) şablonun sabit becerisi
    for x in sk: add_skill(x)
    forms = []
    for k, f in enumerate(s['forms']):
        f = f if okf(f) else dict(forms[-1], chat=[]) if forms else None   # görünüşü olmayan aşama: bir öncekinin görünüşü
        n = ad(f['cn']); ctr, cen = kn(f.get('chat', []))
        forms.append(dict(cn=f['cn'], tr=n[0], en=n[1], look=f['look'], **({'sayTr': ctr, 'sayEn': cen} if ctr else {})))
    ctr, cen = kn(s['chat']); n = ad(s['cn'])
    g = dict(id=s['id'], cn=s['cn'], tr=n[0], en=n[1], tpl=s['tpl'], skill=str(sk[0]), life=s['life'], egg=s['egg'], eggs=s.get('eggs', [s['egg']]),
             box=s['box'], forms=forms, chatTr=ctr, chatEn=cen)
    if s.get('apk'): g['apk'] = 1
    game.append(g)
json.dump({'species': game, 'templates': templates, 'stages': stages, 'skills': skills}, open('www/assets/pets.json', 'w'), ensure_ascii=False, separators=(',', ':'))

# ---------- eşyalar ve dükkânlar (www/assets/items.json) ----------
ICON = {}
for f in ['icon_res_equip', 'icon_res_item']:
    for i, n, d in named(f'kaynak/orijinal/{f}.godat'):
        if n: ICON[n.lower()] = [f.replace('icon_res_', ''), i]
BOXN = {'wood': ('Tahta', 'Wooden'), 'metal': ('Metal', 'Metal'), 'magic': ('Büyülü', 'Magic')}
# (TR ad, EN ad, TR açıklama, EN açıklama, kullanım)
PETIT = {
    30166: ('Tahta Kuluçka Kutusu', 'Wooden Incubator', 'Sıradan yumurtaları çıkarır. Büyüsü yoktur ama hayvanın sağlıkla doğmasını sağlar.', 'Hatches common eggs. It has no magic, but ensures a healthy birth.', {'box': 'wood'}),
    31147: ('Metal Kuluçka Kutusu', 'Metal Incubator', 'İyi yumurtaları çıkarır. Doğa büyüsünü toplar; doğan hayvanın yeteneği daha yüksek olur.', 'Hatches fine eggs. It gathers natural magic, so the hatchling is more talented.', {'box': 'metal'}),
    31149: ('Büyülü Kuluçka Kutusu', 'Magic Incubator', 'Seçkin yumurtaları çıkarır. Büyüsünün tamamı hayvana geçer; yeteneği çok yüksek olur.', 'Hatches superior eggs. All its magic passes to the hatchling, giving it great talent.', {'box': 'magic'}),
    30022: ('Biluo Meyvesi', 'Biluo Fruit', 'Kaya yarıklarında yetişen narin meyve; evcil hayvanların asıl yiyeceği. Tokluğu +50 artırır.', 'A delicate fruit growing in rock crevices; the main food of pets. +50 satiety.', {'food': 50}),
    30020: ('Hayvan Kanı', 'Beast Blood', 'Evcil hayvana özel iksir: canını az miktarda yeniler.', 'Pet potion: restores a little of its HP.', {'petHp': 800}),
    30021: ('Yırtıcı Kanı', 'Predator Blood', 'Evcil hayvana özel iksir: canının bir kısmını yeniler.', 'Pet potion: restores some of its HP.', {'petHp': 2000}),
    30485: ('Hayvan Kralı Kanı', 'Beast King Blood', 'Evcil hayvana özel iksir: canını epey yeniler.', 'Pet potion: restores a good deal of its HP.', {'petHp': 4000}),
    30754: ('Hayvan Ruhu', 'Beast Soul', 'Evcil hayvana özel iksir: manasını az miktarda yeniler.', 'Pet potion: restores a little of its mana.', {'petMp': 400}),
    30755: ('Yırtıcı Ruhu', 'Predator Soul', 'Evcil hayvana özel iksir: manasının bir kısmını yeniler.', 'Pet potion: restores some of its mana.', {'petMp': 1000}),
    30756: ('Hayvan Kralı Ruhu', 'Beast King Soul', 'Evcil hayvana özel iksir: manasını epey yeniler.', 'Pet potion: restores a good deal of its mana.', {'petMp': 2000}),
    30025: ('Ejderin Kurtuluşu', 'Dragon\'s Redemption', 'Değerli bir ilaç: can çekişen evcil hayvanı diriltir ve biraz can verir.', 'A precious medicine: revives a dying pet with a little HP.', {'petRevive': 0.3}),
    30595: ('Sözleşme Taşı', 'Contract Stone', 'Sahibinin sözleşme gücünü artıran gizemli taş: beslenebilecek evcil hayvan sayısı +1.', 'A mysterious stone that strengthens its owner\'s pact: +1 pet you can keep.', {'petSlot': 1}),
    30006: ('Canavar İç Özü', 'Beast Core', 'Kadim canavarın nadir iç özü: çağrılmış evcil hayvana 7000 deneyim verir.', 'The rare core of an ancient beast: grants 7000 XP to the summoned pet.', {'petXp': 7000}),
    # dönüşüm (幻化) ve beceri aktarma (技能转移) yardımcıları
    30164: ('Ejderin Lütfu', 'Dragon\'s Favor', 'Kadim bir ejderin lütufkâr bakışı bu kristalde saklı. Dönüşümün başarı şansını biraz artırır.', 'A crystal holding the favoring glance of an ancient dragon. Slightly raises the chance of a successful transformation.', {'tf': 'luck', 'add': 10}),
    30730: ('Yüce Ejder Lütfu', 'Great Dragon\'s Favor', 'Kadim bir ejderin lütufkâr bakışı bu kristalde saklı. Dönüşümün başarı şansını çok artırır.', 'A crystal holding the favoring glance of an ancient dragon. Greatly raises the chance of a successful transformation.', {'tf': 'luck', 'add': 30}),
    31234: ('Yavru Ejder Lütfu', 'Young Dragon\'s Favor', 'Ejder yavrularına özgü dönüşüm yardımcısı: dönüşüm düzeyi 3\'ün altındaki hayvanın dönüşümü kesin başarılı olur.', 'A transformation aid of young dragons: a pet below transformation level 3 is sure to succeed.', {'tf': 'sure', 'below': 3}),
    30731: ('Soy Rünü', 'Bloodline Rune', 'Bir damla kan damlat; hayvanın asıl hâli hatırlanır. Dönüşüm başarısız olursa düzey düşmez.', 'Drip a drop of blood to remember the pet\'s true form. If the transformation fails, it loses no level.', {'tf': 'keep'}),
    30749: ('Öğrenme Rünü I', 'Learning Rune I', 'Beceri aktarmada ana hayvanın 1. rastgele becerisinin yerine geçilmesini sağlar.', 'In a skill transfer, makes sure the main pet\'s 1st random skill is the one replaced.', {'sk': 'learn', 'slot': 0}),
    30023: ('Öğrenme Rünü II', 'Learning Rune II', 'Beceri aktarmada ana hayvanın 2. rastgele becerisinin yerine geçilmesini sağlar (yoksa etkisiz).', 'In a skill transfer, makes sure the main pet\'s 2nd random skill is the one replaced (no effect if missing).', {'sk': 'learn', 'slot': 1}),
    30750: ('Öğrenme Rünü III', 'Learning Rune III', 'Beceri aktarmada ana hayvanın 3. rastgele becerisinin yerine geçilmesini sağlar (yoksa etkisiz).', 'In a skill transfer, makes sure the main pet\'s 3rd random skill is the one replaced (no effect if missing).', {'sk': 'learn', 'slot': 2}),
    30751: ('Miras Rünü I', 'Heritage Rune I', 'Beceri aktarmada yardımcı hayvanın 1. rastgele becerisinin aktarılmasını sağlar.', 'In a skill transfer, makes sure the helper pet\'s 1st random skill is the one passed on.', {'sk': 'give', 'slot': 0}),
    30752: ('Miras Rünü II', 'Heritage Rune II', 'Beceri aktarmada yardımcı hayvanın 2. rastgele becerisinin aktarılmasını sağlar (yoksa etkisiz).', 'In a skill transfer, makes sure the helper pet\'s 2nd random skill is the one passed on (no effect if missing).', {'sk': 'give', 'slot': 1}),
    30753: ('Miras Rünü III', 'Heritage Rune III', 'Beceri aktarmada yardımcı hayvanın 3. rastgele becerisinin aktarılmasını sağlar (yoksa etkisiz).', 'In a skill transfer, makes sure the helper pet\'s 3rd random skill is the one passed on (no effect if missing).', {'sk': 'give', 'slot': 2}),
}
# orijinalde mağaza (商城) eşyaları: çevrimdışında Evcil Hayvan Güçlendirme Ustası altınla satar (fiyat bizim)
TFPRICE = {30164: 300, 30730: 1500, 31234: 800, 30731: 1200, 30749: 400, 30023: 400, 30750: 400, 30751: 400, 30752: 400, 30753: 400}
items = json.load(open('www/assets/items.json', encoding='utf-8')); IT = items['items']
def base(i):
    if i in PR:
        t = toks(PR[i]); ic = ICON.get(t[2].lower()) or ICON['item\\consume\\icon_dj_dan1.bmp']   # İç Öz'ün simgesi beceri simgesi: yumurta simgesi kullanılır
        return dict(icon=ic, price=t[10], sell=max(1, t[11]))
    a = APROP[i]; ic = ICON.get(a['icon'].lower()) or ICON['item\\consume\\icon_dj_dan1.bmp']   # APK eşyası (sonraki sürüm)
    return dict(icon=ic, price=a['price'], sell=max(1, a['sell_price']))
for i, (a_, b, c, d, use) in PETIT.items():
    IT[str(i)] = dict(base(i), name=a_, en=b, desc=c, den=d, pet=use)
    if i in TFPRICE: IT[str(i)]['price'] = TFPRICE[i]; IT[str(i)]['sell'] = TFPRICE[i] // 10
for g in game:
    bt, be = BOXN[g['box']]
    for e in g['eggs']:
        IT[e] = dict(base(int(e)), name=f"Evcil Hayvan Yumurtası ({g['tr']})", en=f"Pet Egg ({g['en']})",
                     desc=f"Gizemli bir yumurta; kuluçkadan bir evcil hayvan çıkar. {bt} Kuluçka Kutusu gerekir.", den=f"A mysterious egg that hatches into a pet. Requires a {be} Incubator.", pet={'egg': g['cn'], 'box': g['box']})
# Terbiyeci dükkânları (APK 1015: 100038 insan, 100039 elf) + Güçlendirme Ustası
SH = {s['id']: s for s in json.load(open(C + '1015.txt'))['shops']}
for sid, npc in [(100038, '驯兽师（人类）'), (100039, '驯兽师（夜精灵）')]:
    ids = [str(i) for i in SH[sid]['items'] if str(i) in IT]
    if '30166' not in ids: ids.append('30166')   # elf dükkânında eksik; görev 80222 bu kutuyu satın almayı ister
    items['shops'][npc] = [['Evcil Hayvan', ids]]
items['shops']['魔法兽强化大师'] = [['Dönüşüm', [str(i) for i in TFPRICE]]]
json.dump(items, open('www/assets/items.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))

if __name__ == '__main__':
    print('ham kayıt', len(raw), 'tür', len(species), 'oyunda', len(game), 'beceri', len(skills))
    for g in game:
        print(f"  {g['cn']:<6} {g['tr']:<16} şablon {g['tpl']} beceri {g['skill']:<7} {skills[g['skill']]['tr'][0]:<22} yumurta {g['eggs']} {g['box']:<5}",
              ' | '.join(f"{f['cn']}:{f['look']}" for f in g['forms'][1:]))
    print('aşamalar', stages)
    for k, v in eksik.items():
        if v: print('ÇEVİRİ EKSİK', k, len(v), sorted(v))
