# 07 · Evcil hayvanlar (魔法兽 "büyülü hayvan")

Kullanıcı onayladı (zindanlardan sonra). Orijinal sistem dört aşamada kurulur; her aşama ayrı commit.
16.11.2026: kullanıcının isteğiyle kaynaklar baştan, ham kayıttan denetlendi (aşağıda "Kaynak denetimi"). İlk sürümdeki üç yanlış düzeltildi:
1. "Renk varyantı" diye rastgele verilen biçimler aslında **dönüşüm (幻化) aşamalarıymış**.
2. Ana beceriler APK numaralarından tahminle eşlenmişti; artık **ham kayıttaki** beceriler kullanılıyor.
3. Tür sınıfı APK'dan alınmıştı; artık **Symbian şablonu** kullanılıyor.

## Kaynaklar (orijinal)
- **`kaynak/orijinal/all_pet.godat` (HAM, Symbian)**: `all_pet.json` metin dökümü yapıyı kaybettirdiği için ham kayıt `tools/evcil.py` içinde `tok.toks` + bayt okumayla çözülür.
  - Kayıt başı: `[1001, ad, 1, görünüş, "PET-召唤", simge, sohbet adı, 60|120, 1, n, n konuşma, 7]`.
  - Ardından 7 aşama bloğu: `[aşama no, ad, 1, görünüş, "PET-召唤", simge, 0, 60, 1, n, n konuşma]`. Bloklar sırasız gelir; aşama numarası bloğun başındadır.
  - Kuyruk: `[0, ömür 18000|9000, bayrak, 0, şablon, beceri sayısı, beceriler…]`.
  - 34 kayıt; 4'ü yer tutucu: 苍狼王, 深渊虺, 青翼蝠, 邪魂鸟 (şablon 0, görünüşleri yok). İkinci kayıtlar (鸭子/小鸡/灰烬法师, bayrak 1) eksik biçimleri tamamlar. 小野猪'ın yumurtası yok.
- **Şablonlar**:
  - 300001 fiziksel: İskelet, Kül Savaşçı, Zombi, Uçan Bıçak, Çakal, Akbaba, Kaplan, Beyaz Kaplan, Ateş Devi.
  - 300005 büyü: Yılan, Kül Büyücü, Akrep, Cinateşi, Örümcek, Bebek Ejderha.
  - 300006 savunma: Yaban Domuzu, Slime, Yeti, Horoz Yılan, Kurt.
  - 300007 destek: Civciv, Ördek, Yarasa, Peri, Solucan, Panda.
  - Nitelik oranları ve rastgele beceri havuzları APK `1024`'ten; havuzlar Symbian beceri numaralarıyla, Symbian'da olmayanlar atılır.
- **`all_petData.godat`**: 7 aşamanın `(bedel, gereken seviye)` değerleri: (200, 25), (400, 45), (600, 65), (800, 85), (1000, 95), (2000, 105), (3000, 115). Arayüzde "所需等级" yazar.
- **Doğuştan beceriler** (ham kuyruk, Symbian `all_skill` adlarıyla):
  - İskelet 魔法剑, Zombi 猛攻, Uçan Bıçak 致命穿刺, Çakal 撕咬, Akbaba 刁钻突袭, Kaplan 横扫, Beyaz Kaplan 利爪突袭, Ateş Devi 火焰冲击.
  - Yaban Domuzu 猪突猛进, Slime 灼热痰涕, Horoz Yılan 抗魔幻冰, Kurt 游斗.
  - Yılan 神蛇吐息, Kül Büyücü 地狱之火, Akrep 火焰戳刺, Örümcek 寒冷之牙, Bebek Ejderha 龙威.
  - Civciv 鸣叫, Ördek 鼓舞, Yarasa 尖啸, Peri 仙子之舞, Solucan 吸收, Panda 熊猫之力.
  - Kül Savaşçı, Yeti ve Cinateşi'nin becerisi 0'dır; bunlar şablonun sabit becerisini alır: 猛力攻击 / 健壮训练I / 火球术.
  - APK 1019 beceri tablosu Symbian'a göre **yeniden numaralanmış** (ör. APK 90181 = 魔法剑, Symbian 90181 = 横扫). Eşleme numarayla değil adla yapılmalı.
- **Rastgele beceriler**:
  - Yardım metni (310020): "1 doğuştan + 0-3 rastgele".
  - Usta'nın görev metni (80070): "en az bir, en fazla üç; kuluçkada belli olur". **Görev metni esas alındı (1-3).**
- **Dönüşüm (幻化) ve beceri aktarma (技能转移)** kuralları: yardım metni 310019/310020 ve 魔法兽强化大师 NPC metni. Orijinal arayüz `n_fantasize_pet`'tir (ana / yardımcı hayvan, 2 yardımcı eşya, sonuç, bedel).
  - Eşyalar: 龙之眷顾 30164 (+şans), 超级龙之眷顾 30730 (++şans), 幼龙之眷顾 31234 (düzey <3 kesin), 血脉符文 30731 (başarısızlıkta düşmez).
  - Rünler: 学习符文 30749/30023/30750 (ana hayvanın yuvası), 传承符文 30751-30753 (yardımcının yuvası). Orijinalde mağaza eşyası.
- **Sonraki resmî sürüm (APK) türleri**: yumurta numaraları 33xxx-34xxx (Symbian'da en büyüğü 32841).
  - 血天使 Kan Meleği: 34139 metal; görünüş 怪物-翼灵 (Peri'nin 7. biçimiyle aynı); beceri 燃血结界.
  - 暗影女王 Gölge Kraliçe: 33755 metal; APK `monster78`; beceri 暗冰.
  - 荣耀之刃 Şan Kılıcı ve 誓约之刃 Yemin Kılıcı: 34526 / 34527 tahta (lonca dükkânı); beceri 剑刃风暴.
  - 死灵灯 Ölü Feneri: 34528; beceri 迷幻梦境.
  - 杀意火神 Kıyıcı Ateş Tanrısı: yumurtası yok; görünüş 怪物-火巨灵-紫.
- **APK ekibinin değişiklikleri (ALINMAZ)**: APK'da `*.bak_*` yedekleri ekip değişikliklerini gösteriyor (ör. `pet_res.godat.bak_pal_20260917`: 6001/6002 paletleri ekip eklemiş).
  - `monster81` 雪怪 hiçbir resmî kayıtta kullanılmıyor; alınmadı.
  - 35000+ yumurtalar (insansı/boss hayvanları, nitelik 1) ve 140059+ türler ekibin eklemesi; alınmadı.
  - Kullanılanlar: `monster39` paletleri (resmî NPC ★【蛮王】提尔 kullanır) ve `monster78`. Bunlar `kaynak/apk/ek/` içinde ve `tools/pack_all.py` eksik kayıtları oradan tamamlıyor.
- Diğer: Symbian `all_prop` (yumurtalar, kutular, Biluo, iksirler, 龙之救赎, 契约石, 内丹); NPC'ler 驯兽师（人类/夜精灵） (dükkân APK 1015 `100038/100039`) ve 魔法兽强化大师 (Büyülü Canavar Ustası).
- Görevler: insan 80268 → 80249 → 80221 → 80254; elf 80410 → 80255 → 80222 → 80260; besleme 80405/80411; taktik 80045/80046; dönüşüm 80408/80414/80259; beceri aktarma 80070/80071; ömür 80613.
- Taktik modları (80593): **saldırı**, **karşı saldırı**, **destek**, **serbest**, **bekleme**.

## Kaynak denetimi: kararlar (bizim)
- **Ateş Devi**: Symbian'da 7 aşamanın hepsi aynı görünüş. Sonraki sürümde aynı görselin turuncu (6001) ve mor (6002) paletleri var. Kullanıcı mor biçimleri hatırlıyor.
  - 4-6. aşamalar turuncu.
  - 7. aşama mor **杀意火神 Kıyıcı Ateş Tanrısı** (APK 140040'ın adı ve konuşmasıyla).
- **Yeti (雪人)**:
  - Sorun: ham verideki temel biçim görselin kızıl-kahve paleti, 7. biçim 雪妖 orman trolü. İkisi de karlı bir yaratığa benzemiyor (kullanıcı bildirdi). Dünyadaki ☆雪人 canavarı beyaz paleti kullanıyor.
  - Temel biçim `怪物-雪人-白`; özgün temel palet 3. aşamaya alındı (orada beyaz vardı).
  - 雪妖 = aynı trol görselinin beyaz-gri paleti `森林巨魔-灰`.
  - Adı "Kar Adam" yerine **Yeti** oldu (görsel bir yeti).
- **APK türlerinin aşamaları**: kaynakta aşama yok. 1-6. aşamalar görselin renk paletleriyle sırayla doldurulur (`tint`), 7. aşama temel görünüş. Bu bir tamamlamadır.
- **Kalanlar orijinal veriyle aynı**: Ördek ve Panda'nın 7 aşaması aynı görünüş; Kaplan'ın 7. biçimi beyaz kaplan; Kül Savaşçı → Ateş Devi; Zombi → İskelet Savaşçı; Çakal/Kurt → Cehennem Üç Başlı Köpeği.
- **Değerler bizim** (orijinal değerler sunucudaydı):
  - Dönüşüm çarpanı `MULT` 1,0-2,5: APK 1024'ün 1,0-2,5 aralığı 8 düzeye yayıldı.
  - Başarı şansı `TFBASE` %80→%20; aynı tür +%10; yardımcının düzeyi ×%5.
  - Yardımcı eşyalar ve beceri aktarma bedeli (100 + 10·seviye).
  - Rastgele beceri sayısı ağırlıkları `RSK`.
  - Beceri etkileri `SK` (etki türleri orijinal açıklamalardan).

## Aşamalar
1. **Temel** ✔: yumurta + kuluçka, çağırma/geri çağırma, izleme ve savaş (taktik modları), seviye/deneyim, tokluk ve mutluluk, ölme/diriltme, evcil iksirler, Terbiyeci dükkânı ve görev zinciri, yumurtaların canavardan düşmesi, evcil hayvan penceresi, konuşma baloncukları.
2. **Kaynak denetimi + ağaç** ✔ (16.11): 8 biçimli dönüşüm ağacı, doğru beceri ve şablon, rastgele beceriler (kalıcı/hale/destek/saldırı), dönüşüm (幻化), beceri aktarma (技能转移), Büyülü Canavar Ustası, sonraki sürüm türleri.
3. **Yetenek**: doğal yetenek ayrıntıları (8 天赋: güç, büyü, can, mana, savunma, direnç, isabet, kaçınma), yetenek meyveleri (天然/养殖比罗果), kişilik, ömür/gençleştirme (长寿比罗果).
4. **Çevrimiçi**: çiftleştirme, evcil hayvan pazarı. Sırada: Usta'nın görevleri (80070/80071 beceri aktarma, 80259/80408/80414 dönüşüm + 仙子精华).

## Nasıl çalışıyor
- **Dosyalar**:
  - `www/js/pet.js` (modül `Pet`).
  - `www/assets/pets.json` (`tools/evcil.py`): 31 tür, her türün `forms[8]`'i; `templates` (oranlar + havuz); `stages[8]` `{cost, lv, mult}`; `skills` (67 beceri: ad, açıklama, simge, `kind` active/support/passive/aura).
  - Eşyalar, dükkânlar ve Usta'nın dükkânı (`魔法兽强化大师`: dönüşüm eşyaları ve rünler) `items.json`'a aynı araçla eklenir.
  - Çeviriler `kaynak/ceviri/evcil.json` (`adlar`, `beceri`, `konusma`). `beceri_tur` kaldırıldı.
- **Kayıt**: `P.pets[] {uid, sp, st, sk, lv, xp, hp, mp, sat, joy, tal, dead, deadAt}`.
  - `st` dönüşüm düzeyi 0-7; `sk` rastgele beceriler.
  - Eski kayıtlarda `v` (renk) silinir, `st=0`, `sk=[]`.
  - `P.petOn`, `P.petMode`, `P.petSlots`. Çevrimiçide `extra` sütununda.
- **Kuluçka**:
  - Yumurtayı kullanınca çantadaki uygun kutu (yumurtanın istediği ya da daha iyisi) harcanır.
  - Yetenek: tahta 0,85–1,0, metal 0,95–1,1, büyülü 1,05–1,25.
  - Rastgele beceri sayısı 1-3 (tahta 65/30/5, metal 45/40/15, büyülü 25/45/30). Havuzda I. kademe daha sık; aynı becerinin iki kademesi birlikte gelmez.
- **Nitelikler (`Pet.stats`)**:
  - Can `(400+170·L)·hp_growth/6400`, saldırı `(22+9·L)·oran/1040`, savunma `(20+10·L)·base_def/550`.
  - Hepsi × yetenek × dönüşüm çarpanı × (kalıcı + hale bonusu).
  - Büyü şablonu uzaktan (5), diğerleri yakın dövüş (1,9; canavarlarla aynı, 4 yönlü yürüyüşte takılmasın diye).
- **Beceriler**:
  - Doğuştan beceri önce, sonra rastgeleler; her becerinin kendi bekleme süresi var.
  - Kalıcılar (战斗训练/魔法学习/健壮训练) niteliklere eklenir.
  - Haleler (攻击/防御/体力/抗火/抗冰/闪避/命中灵气) çağrılıyken sahibine her saniye yenilenen `petaura` güçlendirmesi verir. Oyuncu `stats()`'ına `hpP`, `dodge`, `res` eklendi; isabet bizde kritik olarak işler.
  - Destekler: iyileştirme sahibinin canı %70'in altındayken, güçlendirme dövüşte.
  - Ölçüm: hayvan öldürme hızına ~%28-30 katkı (`tools/test/evcil.js`).
- **Dönüşüm (`Pet.tfInfo/transform`)**:
  - Ana ve yardımcı hayvan dinlenmede (çağrılmamış, ölü değil) olmalı; ana hayvanın seviyesi aşamanın gereken seviyesine ulaşmalı; bedel altınla ödenir.
  - Başarıda `st+1`: görünüş, ad (7. biçim) ve nitelikler değişir. Başarısızlıkta `st−1` (Soy Rünü korur).
  - Yardımcı hayvan her durumda kaybolur.
- **Beceri aktarma (`Pet.skInfo/transferSkill`)**:
  - Aynı şablon şart. Yardımcının rastgele becerisi ana hayvanın bir rastgele becerisinin yerine geçer (3'ten azsa bazen yeni yuvaya). Rünler yuvayı belirler.
  - Yardımcı hayvan kaybolur.
- **Pencere (`n_petcomplex`)**:
  - Yuvalar: Besle, Taktik, Dönüşüm.
  - Bilgi alanı üç sekme:
    - **Bilgi**: nitelikler, dönüşüm düzeyi ve sonraki gereken seviye, Bırak.
    - **Beceriler**: simgeli liste; dokununca açıklama.
    - **Ağaç**: 8 biçim 4×2 ızgarada. Ulaşılmayanlar soluk; dokununca ad, gereken seviye ve bedel görünür.
  - Taktik: `n_newpetai`.
  - Dönüşüm penceresi `petf` (`n_fantasize_pet`): yuvalara dokundukça dinlenen hayvanlar ve sahip olunan yardımcı eşyalar sırayla gelir. Sağ balonda kip sekmeleri (Dönüşüm / Beceri Aktarma) ve açıklama; sepet düğmesi Usta'nın dükkânını açar.
  - Usta NPC'sinde "Dönüşüm", "Beceri aktarma" ve "nedir?" seçenekleri var.
- **Tokluk ve ölüm**: tokluk 2 dakikada −1; tokluk 0 ya da mutluluk ≤20 → savaşmaz. Ölünce 10 dk sonra kendiliğinden ya da Ejderin Kurtuluşu ile dirilir.
- **Yumurta düşmesi**: canavarın görünüş ailesi bir Symbian türünün temel görünüşüyle aynıysa (ör. 怪物-狼) normal %0,4, seçkin %3, boss %25. APK türleri canavardan düşmez.
- **Görevler**: `kaynak/ceviri/gorevler/evcilgorev.json`; elle kurulan yapı `evcilelle_kaynak.json`.

## GM
`Pet.GM` ve GM paneli › Evcil sekmesi:
- `egg/give <tür>`, `level`, `care`, `items`, `hungry`, `clear`.
- **Dönüşüm ağacı satırı**:
  - `stage` (sonraki biçim; 7'den sonra 0), `stage0` (temel).
  - `skills` (3 rastgele beceri).
  - `tf`: dönüşüm eşyaları ×3, aynı türden 2 yardımcı hayvan ve 20000 altın verir.
  - `petf` / `petfs`: dönüşüm ve beceri aktarma penceresini açar.
- Tür satırları: şablon, kutu, doğuştan beceri ve 7. biçim adı. Arama biçim adlarında da çalışır.

## C++ sürümü (19.11)
- `native/src/engine/world_pet.cpp` + `pet.h` (mantık, HTML pet.js ile aynı sıra ve zar), `native/src/ui/win_pet.cpp` (pencereler). Veri aynı `pets.json`. GM: `gmPet*` (test modunda `evcilgm …`). Karşılaştırma: `node tools/test/cpp_evcil.js` (46 adım birebir), pencereler `cpp_pencere.js`. Ayrıntı docs/09 › Evcil hayvanlar.
- pet.js değişirse world_pet.cpp da aynı değişikliği almalı ve `cpp_evcil.js` yeniden çalıştırılmalı.

## Görsel denetim
- `node tools/test/evcil_kolaj.js`: bütün türlerin 8 biçimi, beceri simgesi ve yumurtaları tek görselde.
- `LOOKS='a,b' node tools/test/gorunus.js`: herhangi görünüşleri yan yana karşılaştırır.
