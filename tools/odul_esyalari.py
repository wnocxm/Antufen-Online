# -*- coding: utf-8 -*-
# Görev ödülü eşyaları: oyundaki görevlerin orijinal ödül listesinde (gorev_ham.json) olup items.json'da bulunmayan eşyaları ekler.
# Değerler: seviye, sınıf, yuva, fiyat, simge Symbian all_equip/all_prop'tan; nitelik sayısı oyunun mevcut merdiveninden
# (aynı yuva + sınıf + nitelik türündeki eşyalar arasında seviyeye göre doğrusal ara değer; "优质的/纹饰的" kaliteli ×1,1).
# Kullanım (depo kökünden, tools/gorevler.py'den sonra): python3 tools/odul_esyalari.py
import sys, json, re, subprocess
sys.path.insert(0, 'tools')
from godat import named
from tok import toks
E = {i: d for i, n, d in named('kaynak/orijinal/all_equip.godat')}
P = {i: d for i, n, d in named('kaynak/orijinal/all_prop.godat')}
ICON = {}
for f in ['icon_res_equip', 'icon_res_item']:
    for i, n, d in named(f'kaynak/orijinal/{f}.godat'):
        if n: ICON[n.lower()] = [f.replace('icon_res_', ''), i]
CLS = {130001: '战士', 130004: '战士', 130006: '战士', 130007: '战士', 130002: '法师', 130005: '法师', 130008: '法师', 130009: '法师', 130010: '牧师', 130011: '牧师', 130012: '牧师'}
SLOT = {'剑': 'weap', '刀': 'weap', '杖': 'weap', '魔典': 'weap', '圣器': 'weap', '衣服': 'body', '头部': 'head', '腰带': 'belt', '鞋子': 'shoe', '手套': 'glove', '项链': 'neck', '戒指': 'ring'}
# takı türü (adından): nitelik anahtarı
KIND = [('体力恢复', 'hpreg'), ('法力恢复', 'mpreg'), ('抗性', 'res'), ('防御', 'def'), ('闪避', 'dodge'), ('命中', 'crit'), ('火', 'res'), ('暗影', 'res'), ('冰', 'res')]
N = {   # (TR, EN) — tüketimde (TR, EN, açıklama TR, açıklama EN, kullanım)
    10026: ('Büyülü Miğfer', 'Magic Helmet'), 10032: ('Kurt Postu Çizme', 'Wolfskin Boots'), 10034: ('Element Halkası', 'Elemental Circlet'), 10040: ('Büyülü Çizme', 'Magic Boots'),
    10047: ('Kaliteli Demir Kılıç', 'Fine Iron Sword'), 10050: ('Kaliteli Tahta Zırh', 'Fine Wooden Armor'), 10054: ('Kaliteli Tahta Kemer', 'Fine Wooden Belt'),
    10057: ('Kaliteli Hafif Ayakkabı', 'Fine Light Shoes'), 10060: ('Kemik Miğfer', 'Bone Helm'), 10061: ('Kaliteli Metal Taç', 'Fine Metal Circlet'),
    10062: ('Süvari Kılıcı', 'Sabre'), 10064: ('Kıdemli Savaş Zırhı', 'Veteran\'s Armor'), 10065: ('Kaliteli Oymalı Asa', 'Fine Carved Staff'),
    10066: ('Metal Kuşak', 'Metal Girdle'), 10067: ('Büyülü Baldırlık', 'Magic Greaves'), 10068: ('Kaliteli Kalın Cübbe', 'Fine Thick Robe'),
    10069: ('Mana Tacı', 'Mana Circlet'), 10070: ('Kaliteli Boyalı Kemer', 'Fine Dyed Belt'), 10071: ('Boğumlu Asa', 'Knotted Staff'),
    10072: ('Koruyucu Cübbe', 'Guardian Robe'), 10073: ('Kaliteli Çırak Çizmesi', 'Fine Apprentice Boots'), 10074: ('Trol Kemeri', 'Troll Belt'),
    10075: ('Yolcu Çizmesi', 'Travel Boots'), 10093: ('Orman Çizmesi', 'Forest Boots'), 10097: ('Geniş Kılıç', 'Broadsword'), 10110: ('Rün Asası', 'Rune Staff'),
    # 40. seviye sınıf yükseltme takımları (sinif.json): savaşçı 队长头盔/符文甲/金丝束带/大步靴, büyücü 琉璃圈/符文法袍/骨钉腰带/轻灵靴
    10095: ('Yüzbaşı Miğferi', 'Captain\'s Helm'), 10098: ('Rün Zırhı', 'Rune Armor'), 10100: ('Altın Telli Kuşak', 'Gold-Thread Sash'), 10101: ('Uzun Adım Çizmesi', 'Striding Boots'),
    10103: ('Sırlı Taç', 'Glazed Circlet'), 10105: ('Rün Cübbesi', 'Rune Robe'), 10107: ('Kemik Çivili Kemer', 'Bone-Stud Belt'), 10108: ('Hafif Adım Çizmesi', 'Lightstep Boots'),
    10128: ('Morsalkım Zırhı', 'Wisteria Armor'), 10130: ('Boz Ayı Savaş Eteği', 'Grizzly War Skirt'), 10131: ('Sık Orman Çizmesi', 'Deepwood Boots'),
    10132: ('Kaliteli Demir Miğfer', 'Fine Iron Helm'), 10135: ('Solgun Cübbe', 'Withered Robe'), 10137: ('Geyik Savaş Eteği', 'Stag War Skirt'),
    10148: ('Gizemli Miğfer', 'Mystic Helm'), 10156: ('Sırlı Peçe', 'Arcane Veil'), 10586: ('İsabet Bilekliği', 'Bracer of Accuracy'),
    10656: ('Can Yenileme Muskası', 'Amulet of Vitality'), 10657: ('Mana Yenileme Muskası', 'Amulet of Mana'), 10658: ('Direnç Muskası', 'Amulet of Resistance'),
    10659: ('Savunma Muskası', 'Amulet of Defense'), 10664: ('Yeşim Can Tılsımı', 'Jade Talisman of Vitality'), 10665: ('Yeşim Mana Tılsımı', 'Jade Talisman of Mana'),
    10666: ('Yeşim Direnç Tılsımı', 'Jade Talisman of Resistance'), 10718: ('Görkemli Ateş Ruhu Mücevheri', 'Ornate Fire Soul Jewel'),
    10720: ('Görkemli Gölge Mücevheri', 'Ornate Shadow Jewel'), 10726: ('Alev Ruhu İğnesi', 'Flame Soul Pin'), 10727: ('Buz Kalbi İğnesi', 'Frost Heart Pin'),
    10905: ('Nakışlı Kalın Başörtüsü', 'Embroidered Thick Headscarf'), 10906: ('Nakışlı Bilgin Kitabı', 'Embroidered Scholar\'s Tome'),
    10907: ('Nakışlı Kalın Giysi', 'Embroidered Thick Garb'), 10908: ('Nakışlı Kalın Kemer', 'Embroidered Thick Belt'), 10909: ('Nakışlı Kalın Ayakkabı', 'Embroidered Thick Shoes'),
    10915: ('Dirilik Başörtüsü', 'Headscarf of Vigor'), 10916: ('İlahi Kitabı', 'Book of Hymns'), 10917: ('Bağışlama Giysisi', 'Coat of Forgiveness'),
    10918: ('Kurtuluş Kemeri', 'Belt of Salvation'), 10919: ('Kefaret Pabucu', 'Shoes of Redemption'), 10925: ('Alacalı Başörtüsü', 'Shimmering Headscarf'),
    10926: ('Kutsal Ruh Kanunu', 'Holy Spirit Codex'), 10927: ('Işıltı Giysisi', 'Radiant Coat'), 10928: ('Kutsal Ruh Kemeri', 'Holy Spirit Belt'),
    10929: ('İlahi Pabucu', 'Aria Slippers'), 10937: ('Aziz Giysisi', 'Saint\'s Coat'), 10939: ('Kararlılık Pabucu', 'Slippers of Resolve'), 10945: ('Hiçlik Başörtüsü', 'Void Headscarf'),
    11196: ('Güçlendirilmiş İsabet Bilekliği', 'Reinforced Bracer of Accuracy'), 11232: ('Büyülü Can Tılsımı', 'Arcane Talisman of Vitality'),
    11233: ('Büyülü Mana Tılsımı', 'Arcane Talisman of Mana'), 11234: ('Büyülü Direnç Tılsımı', 'Arcane Talisman of Resistance'),
    11240: ('Rafine Ateş Ruhu Mücevheri', 'Refined Fire Soul Jewel'), 11243: ('Rafine Çeviklik Mücevheri', 'Refined Evasion Jewel'),
    30041: ('Orman Güveci', 'Forest Hotpot', 'Ormanın türlü malzemesiyle pişmiş, insanın içini ısıtan güveç. Zamanla çok miktarda can ve mana yeniler.', 'A warming hotpot of many forest ingredients. Slowly restores a lot of HP and mana.', {'hot': ['hp', 8000, 15], 'hot2': ['mp', 4000, 15]}),
    30357: ('Acılı Solucan Güveci', 'Spicy Worm Stew', 'Tofu gibi yumuşak pişmiş solucan eti, üstünde koyu et sosu. Zamanla az miktarda can ve mana yeniler.', 'Worm meat cooked tofu-soft under thick meat sauce. Slowly restores a little HP and mana.', {'hot': ['hp', 800, 15], 'hot2': ['mp', 400, 15]}),
    30766: ('Çıtır Kanat Kızartması', 'Crispy Roast Wings', 'Tapınak aşçısının yeni yemeği: kızarmış akbaba kanadı. Zamanla çok miktarda can ve mana yeniler.', 'The temple chef\'s new dish: roast vulture wings. Slowly restores a lot of HP and mana.', {'hot': ['hp', 8000, 15], 'hot2': ['mp', 4000, 15]}),
    30126: ('Tapınak Dostu Nişanı', 'Temple Friend Badge', 'Gece elflerine yaptığın katkının belgesi. Eskiden yalnız soylulara verilirdi; şimdi gençleri toplamak için bakırdan bolca yapılıyor.', 'Proof of your service to the night elves. Once only for nobles, now made of copper in bulk to recruit the young.', None),
    31218: ('Sırlı Cam Süs', 'Glazed Ornament', 'Eski ustaların göz alıcı işi. Sözleşme Neşe Elçisi\'nde özel ödülle değiştirilir.', 'A dazzling work of ancient craftsmen. Exchanged for a special reward with the Contract Joy Envoy.', None),
}
# görev ödülü olmayan ama bir sistemin gerektirdiği eşyalar: kimlik → satan NPC'ler (beceri ağacı: docs/03 › Beceri ağaçları)
EKSTRA = {30092: ['技能训练师（人类）', '技能训练师（夜精灵）'],   # 训练之书: beceri puanlarını sıfırlar (orijinal açıklama)
          30127: []}                                          # 生命元素: gece elfi ırk becerisi Yaşam Özütü düşürür
N[30092] = ('Eğitim Kitabı', 'Training Book', 'Bütün beceri puanlarını sıfırlar: beceri ağacında "Puanları Sıfırla"ya bas, kitap kendiliğinden harcanır.', 'Resets all skill points: press "Reset Points" in the skill tree; the book is used up automatically.', None)
N[30127] = ('Yaşam Elementi', 'Life Element', 'Gece elfi büyücülerinin bulduğu büyüyle can çekişen yaratıklardan toplanan yaşam özü.', 'Life essence gathered from dying creatures with a spell invented by night elf mages.', None)
PETN = {   # evcil hayvan eşyaları (pet.js useItem)
    30703: ('Ejderin Kurtuluşu', 'Dragon\'s Redemption', 'Değerli bir ilaç: can çekişen evcil hayvanı diriltir ve biraz can verir.', 'A precious medicine: revives a dying pet with a little HP.', {'petRevive': 0.3}),
    31137: ('Doğal Güç Biluo Meyvesi', 'Natural Strength Biluo Fruit', 'Evcil hayvanın fiziksel saldırı yeteneğini 10 artırır.', 'Raises your pet\'s physical attack talent by 10.', {'petGift': ['patk', 10]}),
}

def main():
    items = json.load(open('www/assets/items.json', encoding='utf-8')); IT = items['items']
    # ödül listesindeki eksikler
    need = set()
    HAM = json.load(open('kaynak/cikti/cozulmus/tablolar/gorev_ham.json', encoding='utf-8'))
    ids = set(map(int, re.findall(r'"id":(\d+)', open('www/js/quests_gen.js', encoding='utf-8').read()))) | set(map(int, re.findall(r'\{ id: (\d+)', open('www/js/tr.js', encoding='utf-8').read())))
    for i in ids:
        for x in (HAM.get(str(i)) or {}).get('items', []):
            if x[0] not in IT and x[0] != '30676': need.add(int(x[0]))
    for i in EKSTRA:
        if str(i) not in IT: need.add(i)
    # merdiven: (yuva, sınıf, nitelik) → [(seviye, değer)]
    lad = {}
    for v in IT.values():
        if v.get('slot') and v.get('st'):
            for k, val in v['st'].items(): lad.setdefault((v['slot'], v.get('cls'), k), []).append((v['lv'], val))
    def interp(key, lv):
        L = sorted(lad.get(key, []));
        if not L: return None
        if lv <= L[0][0]: return L[0][1]
        for (a, x), (b, y) in zip(L, L[1:]):
            if a <= lv <= b: return round(x + (y - x) * (lv - a) / max(1, b - a))
        return L[-1][1]
    added, miss = 0, []
    for i in sorted(need):
        if i in E:
            t = toks(E[i]); nm = t[1]; slot = SLOT[t[13]]; lv = t[20]; cls = CLS.get(t[22])
            if i not in N: miss.append((i, nm)); continue
            if slot in ('neck', 'ring', 'glove'):
                k = next(k for w, k in KIND if w in nm); st = {k: interp((slot, None, k), lv)}
            else:
                keys = {k for (s, c, k) in lad if s == slot and c == cls}
                st = {k: interp((slot, cls, k), lv) for k in sorted(keys)}
            if nm.startswith(('优质的', '纹饰的')): st = {k: round(v * 1.1) for k, v in st.items()}
            gfx = t[4].rsplit('_', 1)[0] if isinstance(t[4], str) and t[4].startswith('group') else None
            IT[str(i)] = dict(name=N[i][0], en=N[i][1], icon=ICON[t[2].lower()], price=t[14], sell=max(1, t[14] // 10), slot=slot, cls=cls if slot not in ('neck', 'ring', 'glove') else None, lv=lv, st=st, gfx=gfx)
        elif i in P:
            t = toks(P[i]); src = N.get(i) or PETN.get(i)
            if not src: miss.append((i, t[1])); continue
            it = dict(name=src[0], en=src[1], icon=ICON.get(t[2].lower()) or ICON['item\\consume\\icon_dj_dan1.bmp'], price=t[10], sell=max(1, t[11]), desc=src[2], den=src[3])
            if i in PETN: it['pet'] = src[4]
            elif src[4]: it['use'] = src[4]
            IT[str(i)] = it
        else: miss.append((i, '?'))
        added += 1
    for i, npcs in EKSTRA.items():   # satıcılar
        for n in npcs:
            tabs = items['shops'].setdefault(n, [])
            if not any(str(i) in t[1] for t in tabs): (tabs[0][1].append(str(i)) if tabs else tabs.append(['Eşya', [str(i)]]))
    json.dump(items, open('www/assets/items.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    print('eklenen ödül eşyası', added, 'adı eksik', miss)

if __name__ == '__main__':
    main()
