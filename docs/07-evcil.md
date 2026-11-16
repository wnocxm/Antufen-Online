# 07 · Evcil hayvanlar (魔法兽 "büyülü hayvan")

Kullanıcı onayladı (zindanlardan sonra). Orijinal sistem dört aşamada kurulur; her aşama ayrı commit.

## Kaynaklar (orijinal)
- `kaynak/cikti/tablo/all_pet.json` (Symbian): 31 tür; her kayıt `[ad, görünüm, "PET-召唤", ikon]` blokları: temel + 6 renk varyantı + dönüşüm sonrası biçim; aradaki satırlar konuşma.
- APK `1023` (tür sınıfı `subtype`: 1 yardımcı, 2 fiziksel, 3 savunma, 4 büyü; `default_skill` **kaymış**, kullanılmaz), `1024` (nitelik şablonları, 7 evrim kademesi, beceri havuzları), `1022` (12 kişilik).
- Symbian `all_prop`: yumurtalar `魔法兽蛋（tür）` (açıklamada gereken kutu: 木质 tahta / 金属 metal / 魔法 büyülü), kuluçka kutuları, Biluo meyvesi (+50 tokluk), evcil can/mana iksirleri, 龙之救赎 (diriltme), 契约石 (+1 hayvan hakkı), 内丹 (hayvana deneyim), yetenek meyveleri, dönüşüm ve beceri aktarma eşyaları.
- NPC: 驯兽师（人类/夜精灵） Hayvan Terbiyecisi (dükkân APK 1015 `100038/100039`), 魔法兽强化大师 Güçlendirme Ustası (dönüşüm, beceri aktarma), 魔宠大师 (Akademi).
- Görevler: insan 80268 → 80249 (Güneşli Orman Doğu Bal Perileri, kayıp yumurta) → 80221 (kuluçka kutusu al) → 80254 (kuluçka); elf 80410 → 80255 (邪气荒野 slime'ları) → 80222 → 80260; besleme 80405/80411; taktik 80045/80046; besin 80250/80256; dönüşüm 80408/80414/80259; ömür 80613.
- Orijinal bilgiler: "yumurta canavar öldürerek de elde edilir" (80268); taktik modları (80593): **saldırı** (sahibinin hedefi), **karşı saldırı** (sahibine saldıran), **destek** (yalnız destek becerisi), **serbest** (görüşteki düşman), **bekleme** (izler, bir şey yapmaz).

## Aşamalar
1. **Temel** ✔: yumurta + kuluçka, çağırma/geri çağırma, izleme ve savaş (taktik modları), seviye/deneyim, tokluk ve mutluluk, ölme/diriltme, evcil iksirler, Terbiyeci dükkânı ve görev zinciri, yumurtaların canavardan düşmesi, evcil hayvan penceresi (`n_petcomplex`, `n_newpetai`), konuşma baloncukları.
2. **Yetenek**: doğal yetenek (kuluçka kutusuna göre), yetenek meyveleri, kişilik, ömür/gençleştirme.
3. **Güçlendirme**: dönüşüm (7 kademe, `n_fantasize_pet`), beceri aktarma, Güçlendirme Ustası.
4. **Çevrimiçi**: çiftleştirme, evcil hayvan pazarı.

## Kararlar (bizim)
- Ana beceriler türün adına göre eşlendi (APK eşleşmesi kaymış): Panda → 熊猫之力, Peri → 仙子之舞, Kaplan → 撕咬 … (`tools/evcil.py` BECERI).
- Nitelikler: şablon oranları APK 1024'ten; seviye ölçeği bizim (evcil hayvan oyuncudan zayıf, öldürme hızına ~%25 katkı).

## 1. aşama: nasıl çalışıyor
- Dosyalar: `www/js/pet.js` (modül `Pet`), `www/assets/pets.json` (`tools/evcil.py`: 26 elde edilebilir tür, şablonlar, beceriler), eşyalar ve Terbiyeci dükkânları `items.json`'a aynı araçla eklenir; çeviriler `kaynak/ceviri/evcil.json`.
- Kayıt: `P.pets[] {uid, sp, v, lv, xp, hp, mp, sat, joy, tal, dead, deadAt}`, `P.petOn`, `P.petMode`, `P.petSlots` (varsayılan 2; Sözleşme Taşı +1). Çevrimiçide `extra` sütununda.
- Kuluçka: yumurtayı kullan → çantadaki uygun kutu (yumurtanın istediği ya da daha iyisi) harcanır; yetenek: tahta 0,85–1,0, metal 0,95–1,1, büyülü 1,05–1,25; %25 renk varyantı. `questFlag('hatch')`.
- Nitelikler (`Pet.stats`): can `(400+170·L)·hp_growth/6400·yetenek`, saldırı `(22+9·L)·oran`, savunma `(20+10·L)·base_def/550`. Seviye en çok sahibinin seviyesi; deneyim payı öldürmenin %50'si (5+ seviye geriyse ×3).
- Savaş: taktik modları (`Pet.MODES`); 1,5 sn'de bir saldırı (büyü sınıfı ateş topuyla, menzil 5); ana beceri 8 sn'de bir (`SK` tablosu: hasar, alan, öfke çekme, sahibine iyileştirme/güçlendirme). Canavar son vuranı hedef alır (`m.foe`); hayvan öfkeyi yalnız kendi başlattığı dövüşte ya da öfke çeken beceriyle alır; alan becerisi uyuyan canavarı uyandırmaz. Ölçüm: hayvan öldürme hızına ~%25-30 katkı (`tools/test/evcil.js`).
- Tokluk 2 dakikada −1; tokluk 0 ya da mutluluk ≤20 → savaşmaz. Biluo +50 tokluk +10 mutluluk. Ölünce 10 dk sonra kendiliğinden ya da Ejderin Kurtuluşu ile dirilir.
- Yumurta düşmesi: canavarın görünüş ailesi bir türünkiyle aynıysa (ör. 怪物-狼) normal %0,4, seçkin %3, boss %25.
- Pencere: menüde "Evcil" (GM düğmesi Sistem penceresine taşındı); `n_petcomplex` + taktik `n_newpetai`.
- Görevler (`kaynak/ceviri/gorevler/evcilgorev.json`, elle yapı `evcilelle_kaynak.json`): yeni üretici alanları `teslim` (deliver), `ozel` (special, bayrak), `hedefler` (hedef cümlesi).
