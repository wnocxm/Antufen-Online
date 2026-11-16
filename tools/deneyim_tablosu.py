# -*- coding: utf-8 -*-
# Seviye deneyim tablosu ve canavar deneyimi — orijinal görev deneyimine göre (kullanıcı kararı 16.11.2026: "orijinal + %40 görev").
# Orijinalde seviye tablosu ve canavar deneyimi sunucudaydı; hiçbir dosyada yok (docs/04 › Orijinal kaynak). Görev deneyimleri ise orijinal
# (gorev_ham.json). Bu araç tabloyu öyle kurar ki her seviyede, o seviyeye kadar açılan bütün görevlerin orijinal deneyimi gereken toplam
# deneyimin ~%40'ını, canavarlar kalan %60'ını versin; seviye başına canavar sayısı her seviyede aşağı yukarı aynı olsun.
# Girdi: kaynak/cikti/cozulmus/tablolar/gorev_seviye.json  (JSON=… node tools/test/gorev_seviye.js — oyunun kendi açılma seviyeleriyle)
# Çıktı: www/js/game.js içindeki XPT (seviye → bir sonraki seviyeye gereken deneyim) ve MXPT (normal canavar deneyimi) dizileri.
# Kullanım (depo kökünden): python3 tools/deneyim_tablosu.py
import json, math, re

PAY = 0.40            # görevlerin payı (kullanıcı kararı)
KAMP = 745           # benzetimde (tools/test/denge.js) insan oyuncunun 1. seviyedeyken yapabildiği kamp görevlerinin orijinal deneyimi (zincir kilitleri yüzünden 1. seviyede açılanların hepsi değil)
OLCEK = 0.83         # genel ölçek: gerçekçi benzetimle (GRIND=1 tools/test/denge.js, hedef öldürmeleri dahil) toplam görev payı ~%40'a oturtulur
KILLS = lambda L: min(200, 40 + 8 * L)   # seviye başına normal canavar sayısı: 20. seviyeye kadar ısınma (48 → 200), sonra 200 
MAXLV = 120

def main():
    d = json.load(open('kaynak/cikti/cozulmus/tablolar/gorev_seviye.json'))
    # iki ırkın ortalama birikimli orijinal görev deneyimi (55'e kadar; kapsam)
    C, acc = {}, {r: 0 for r in d}
    for L in range(1, 56):
        for r in d: acc[r] += d[r][str(L)]['xpOrig']
        C[L] = sum(acc.values()) / len(acc)
    # basamakları yumuşat: 5 seviyelik dayanaklar (±2 seviye ortalaması), aralarda log-doğrusal ara değer; seviye başına artışlar
    # azalmasın (bitişik düşük blokları birleştir, PAV) ve her seviye bir öncekinden en az %3 büyük olsun. Bu, orijinal görev deneyiminin
    # seviyelere dağılışını yakından izler (kübik eğri 20-30 arasını fazla yumuşatıp görev payını %20'ye düşürüyordu).
    anc = [1] + list(range(5, 56, 5))
    A = {}
    for a in anc:
        w = range(max(1, a - 2), min(55, a + 2) + 1); A[a] = sum(C[l] for l in w) / len(w)
    def ci(L):
        for a, b in zip(anc, anc[1:]):
            if a <= L <= b: return math.exp(math.log(A[a]) + (math.log(A[b]) - math.log(A[a])) * (L - a) / (b - a))
        return A[55]
    inc = [ci(L + 1) - ci(L) for L in range(1, 55)]
    blocks = [[v, 1] for v in inc]; i = 0
    while i < len(blocks) - 1:
        if blocks[i][0] > blocks[i + 1][0]:
            v = (blocks[i][0] * blocks[i][1] + blocks[i + 1][0] * blocks[i + 1][1]) / (blocks[i][1] + blocks[i + 1][1])
            blocks[i] = [v, blocks[i][1] + blocks[i + 1][1]]; del blocks[i + 1]; i = max(0, i - 1)
        else: i += 1
    mono = []
    for v, k in blocks: mono += [v] * k
    for L in range(1, len(mono)): mono[L] = max(mono[L], mono[L - 1] * 1.03)
    XPT = [0] + [OLCEK * v / PAY for v in mono]
    # başlangıç kampı: kamp görevleri (en az veren ırkın 1. seviye görevleri) oyuncuyu en az 2. seviyeye çıkarsın (orijinalde kamptan 2-3. seviyede çıkılır);
    # 2-4. seviyeler 1'den 5'e geometrik geçiş
    camp = KAMP
    XPT[1] = min(XPT[1], 0.9 * camp)
    for L in (2, 3, 4): XPT[L] = XPT[1] * (XPT[5] / XPT[1]) ** ((L - 1) / 4)
    r = min(1.08, XPT[54] / XPT[53])
    while len(XPT) <= MAXLV: XPT.append(XPT[-1] * r)
    rnd = lambda v: int(round(v, -int(max(0, math.floor(math.log10(max(v, 1))) - 2))))   # 3 anlamlı basamak
    XPT = [0] + [rnd(v) for v in XPT[1:]]
    MXPT = [0] + [max(1, rnd(XPT[L] * (1 - PAY) / KILLS(L))) for L in range(1, MAXLV + 1)]
    for L in range(2, MAXLV + 1): MXPT[L] = max(MXPT[L], MXPT[L - 1])   # yüksek seviyeli canavar düşükten az vermesin
    # rapor
    for L in (1, 2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 54, 55, 60):
        print(f'sv{L:>3}: sonraki seviyeye {XPT[L]:>9}  normal canavar {MXPT[L]:>6}  (görev birikimi ort. {round(C.get(L, 0)):>8})')
    tot = sum(KILLS(L) for L in range(1, 55)); print('1→55 toplam normal canavar (görevler yapılırsa):', tot)
    # game.js'e yaz
    p = 'www/js/game.js'; s = open(p, encoding='utf-8').read()
    blk = ('// Seviye deneyim tablosu ve normal canavar deneyimi: tools/deneyim_tablosu.py üretir (elle değiştirme; orijinal görev deneyimine göre,\n'
           '// görevler gereken deneyimin ~%40\'ı, canavarlar ~%60\'ı; docs/04). XPT[L] = L → L+1 için gereken, MXPT[L] = L. seviye normal canavar.\n'
           f'const XPT = {json.dumps(XPT)};\nconst MXPT = {json.dumps(MXPT)};\n')
    s, k = re.subn(r'// Seviye deneyim tablosu ve normal canavar deneyimi: tools/deneyim_tablosu.py.*?\nconst MXPT = \[[^\]]*\];\n', lambda m: blk, s, flags=re.S)
    if not k:
        i = s.index('function xpNeed(l)'); i = s.rindex('\n', 0, s.rindex('//', 0, i)) + 1; s = s[:i] + blk + s[i:]
    open(p, 'w', encoding='utf-8').write(s)
    print('game.js: XPT/MXPT yazıldı')

if __name__ == '__main__':
    main()
