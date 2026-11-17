# 04 · Görevler

## Görev nesnesi (oyunda `QUESTS[]`)
`{id, giver, to, type, target, node, count, sc, chance, item, req, race, rw:{gold, items}, lv0, lvMin, title, text, ok, wait, done, goal}`
- `giver/to/target/node` **orijinal Çince adlar**; gösterimde `trName()`.
- Türler: `talk` (kabul edince hazır; `to` ile konuşunca biter; `item` varsa "eşyayı götür"), `kill` (`target` × `count`),
  `collect` (`target` canavardan `chance` olasılıkla `item`), `pickup` (`node` toplama noktası), `deliver`, `special` (`flag`).
- `req`: önceki görev (dizi = "herhangi biri", ırk yolları için). `race`: yalnızca o ırk.
- Ödül: deneyim, altın ve eşya orijinal (`q.rw` ← `QRW`, ham kayıt); `q.reward` bunlardan kurulur.

## Orijinal kaynak: ne var, ne yok (16.11.2026 denetimi)
**Kaynak hiyerarşisi:** Symbian `all_task.godat` HAM kaydı (`tools/gorev_ham.py` → `kaynak/cikti/cozulmus/tablolar/gorev_ham.json`) esastır.
- **APK 1025 / TaskBot tablosu güvenilmez:** Symbian kaydını yanlış okumuş. `level` = hedef adedi, `exp` = bir metin bloğunun bayt boyu. Ödül eşyalarının sınıf bilgisi kayıp, zincir bağları eksik ya da değiştirilmiş (APK ekibinin `task_server.json.bak_*` yedekleri). APK'dan yalnız yapı ipuçları alınır, sayı alınmaz.
- **Ham kayıtta olan (orijinal, birebir):** başlık, metinler, veren ve teslim alan (NPC + sahne), sonraki görev (zincir), hedef adetleri (çok hedefte her biri), altın, deneyim, ödül eşyaları (sınıfa göre: `[eşya, adet, sınıf]`), görev türü `b` ve hedef başvuruları.
  - `b` görev türleri: 1 ana hikâye, 2 yan görev, 3 ayak işi (yalnız altın), 4 sınıf yükseltme, 5 zindan, 6 ödül avı, 7 bitki/tabela, 8 etkinlik/hediye.
  - Ana ve yan görevlerin yaklaşık dörtte biri orijinalde 0 deneyim verir.
  - Ek alanlarda unvan (180xxx), evcil (140xxx) ve sınıf yükseltme (13000x) ödülleri var. Bu sistemler henüz yok.
- **Hiçbir dosyada OLMAYAN (orijinalde sunucudaydı):** görevlerin açılma seviyesi, seviye atlama deneyim tablosu, canavarların seviyesi, canı, deneyimi ve altını.
  - Metinlerde de seviye yok; yalnız 40/80 sınıf yükseltme, 20 arena, 75/80/85 hediyeleri geçiyor.
  - Bunlar bizim tahminimiz: açılma seviyesi aşağıda, canavarlar `game.js monDef`.
- **Üretim:** `tools/gorevler.py` sonunda "orijinal ham kayıt geçişi" var:
  - Zincir orijinalden kurulur. Oyunda olmayan ara görevlerin üstünden atlanır. Orijinalde önceki görev varsa elle bağın da üstündedir.
  - Orijinalde öncesi olmayan görevlerde yalnız elle bağlar kalır: `zincir` alanı ve `tr.js` eğitim sırası.
  - Adet ve çok hedef ilerleme metninden okunur.
  - Bütün görevlerin (`tr.js` dahil) ödülü `quests_gen.js` içindeki `QRW`'den gelir (`{gold, xp, items}`).
  - Ödül eşyası yalnız kendi sınıfına verilir (`rewardItems`). Görev penceresinde ödül satırı gösterilir.
- **Ödül eşyaları:** `tools/odul_esyalari.py` ödül listesinde olup `items.json`'da olmayan eşyaları ekler (77 eşya). Değerleri mevcut merdivenden seviyeye göre ara değerle verilir. `30676` 成长大礼包 = oyundaki `growthBox`.
- **Denetim:** `node tools/test/gorev_denetim.js` (`OUT=rapor`, `AYRINTI=1`). Bütün görevleri alan alan orijinalle karşılaştırır. Her görev değişikliğinden sonra çalıştır; `zincir:yanlış`, `zincir:eksik`, `adet`, `hedef`, `eşya`, `altın` sıfır olmalı.
- **Deneyim:** görevler orijinal deneyimi verir (`q.rw.xp`). Seviye tablosu ve canavar deneyimi buna göre kuruldu (docs/03 › Savaş › Deneyim sistemi). Görev listesi ya da açılma seviyeleri değişince sırayla şunlar çalıştırılır: `JSON=kaynak/cikti/cozulmus/tablolar/gorev_seviye.json node tools/test/gorev_seviye.js`, `python3 tools/deneyim_tablosu.py`, `GRIND=1 node tools/test/denge.js` (görev payı ~%40 mı).

### Orijinalden bilinçli sapmalar (istisnalar, denetim aracında `ISTISNA`)
- 81063 / 81396 Obur Ormanı: orijinal 15 食人鬼 + 15 恶咒食人鬼 + 15 鬼骑士. İlk ikisi orijinal harita verisinde de yok; yalnız 15 Hayalet Şövalye kaldı.
- 80597 Hedef Seçme: orijinalde vereni boş bir eğitim görevi; bizde 初级战斗导师 → 教练员.
- 81993 / 81998 zindan: "啃食者" başvuru listesinde yok, ilerleme metninde var (haritada ☆啃食者).
- 81786 "Hızlı Öldürme": Symbian'da yok, APK eklemesi; atlandı.
- `zincir:bizim` (69): orijinalde öncesi olmayan ama bizde bağlanan görevler.
  - `tr.js` eğitim sırası (kamp ve Guanlin girişi).
  - Evcil hayvan görevleri (hayvan şartı orijinalde sunucudaydı).
  - Birkaç bölge bağı.
  - Sınıf yükseltme zincirleri (10 bağ: giriş görevleri 80344'e, elçi zincirleri; orijinalde sunucudaydı).

## Sınıf yükseltme (40) — `sinif.json` + `sinif_kaynak.json` (17.11)
Orijinal ham kayıt (b=4, ek alanda 130004 Savaşçı / 130005 Büyücü / 130011 Kutsal Elçi; metinler `tasks.json`). Akış:
1. **80344 "Acemilikten Çıkış"** 40. seviyede kendiliğinden alınır (`auto`; orijinalde verensiz). Altındalga Limanı'ndaki Ozan'a teslim (2000 altın; unvan 180050 ödülü unvan sistemi olmadığı için yok).
2. Ozan'da **"✦ Sınıf değiştirmek istiyorum!"** satırı (orijinal “我要转职！”) sınıfa ve ırka göre giriş görevini verir (`cls` + ırk; orijinalde verensiz görevler, bizde veren Ozan, `zincir` ile 80344'e bağlı).
3. Zincirler (son görev `adv: 1` → `classUp`, sınıf ağacı açılır; ödül sınıfın 40. seviye takımı):
   - İnsan savaşçı: 80569 Tom → 80223 ☆Karagece'den yüzük (Başkent Batısı) → 80224 Şato Uşağı'ndan Yıldız Taşı (Gümüşkartal Avlusu).
   - Elf savaşçı: 80571 Özel Ataşe → 80238 ☆Su Perisi'nden 3 Ejder Dişi Yeşimi → 80239 Sınav Odası'nda 5 ☆Dehşet Bıçağı (Şan Zinciri).
   - İnsan büyücü: 80570 Arma Büyücüsü → 80225 Işınlanma Koridoru'nun uçan canavarlarından 5 Tören Malzemesi + 1 Büyülü Mum (`mobs` + `drops`: iki eşyalı toplama) → 80226 Orman İnziva Perisi: **iki seçenekli bitiş** (`choice`: yarala / bırak; ikisi de Büyücü yapar, sonuç metni farklı).
   - Elf büyücü: 80572 Büyücüler Loncası Başkanı → 80240 ☆Joule + ☆Dondur → 80241 Yetim Elf Kız.
   - İnsan elçi: 82940 Frey Rahibi → 82941 ☆Thomas Young (Şaşkınlık Koridoru) → 82942 Frey Başrahibesi. Elf elçi: 81965 Dia → 82938 Thomas Young → 82939 Kehanet Kâhini.
   - Bilgi görevleri: 80343 (Tom → Jessie, `tr.js`'te zaten vardı), 80346 (Yetim Elf Kız → Tapınak Öğretmeni).
- Yapı dosyası (`sinif_kaynak.json`) elle kuruldu: `cls`, `adv`, `auto`, `mobs`, `drops` alanları. Çeviri dosyasında yeni alanlar: `kaynak` (önce bu yapı dosyası okunur; diğer `_kaynak` dosyalarındaki aynı numaralı yapıların üstündedir), `seviye_kesin` (`seviyeler` = tam açılma seviyesi, `q.lvAt`; hedef haritası daha yüksek olsa da 40), `esyalar` (çok eşyalı toplamanın adları), `secim` (seçimli bitiş). 82942 `baskent.json`'dan buraya taşındı.
- **Seviye bulgusu:** harita dosyası adındaki sayı seviye değil (ör. 银鹰城 dosyası `-100` ama dünya haritasında 40-41; 哀嚎小径 `-70` ama 41-43). Dünya haritasında olmayan sahnelerin seviyesi bu yüzden yanlış çıkabiliyor. Orijinal görev deneyimi/altınından (seviyesi bilinen 571 görevle kurulan eğri) tahmin: `kaynak/seviye_tahmin.json` (`tools/pack_all.py` okur). Şimdilik: Gümüşkartal Avlusu 41-43 (eskiden 91-97 canavar!), Kışla/Depo 47-49, Sınav Odası 40-42.
  - Henüz düzeltilmeyen, aynı yöntemle yanlış görünenler: yoksul mahalle altı katları (120081-120084, dosya 70-80, tahmin ~47-48), lağım parçaları (120106-120122, dosya 39-50, tahmin 47-63), Gümüşkartal iç şehir/kule (120135-120143, dosya 100, tahmin 53-61), Tarikat Üssü 120001 (dosya 50, tahmin ~26-33). Kapsam 55'e kadar olduğu için bunlar ayrı bir işte ele alınmalı (o bölgelerin 55 altı görevleri de alınabilir).
- Thomas Young yalnız bu görevlerde geçen seçkin: `MON` ile 42. seviye (koridorun kendisi ~52; yanındaki ☆Taş Muhafız'a dikkat).
- Test: `tools/test/sinif.js` (insan savaşçı zinciri NPC konuşmalarıyla, her sınıf/ırk için giriş görevi, iki eşyalı toplama, seçim, eski kayıt).

## Seviye kilidi (`game.js`)
`questState(q)` → `done | ready | active | new | soon | locked`. `soon` = `P.lv < questMinLv(q)` (5 seviye içindeyse "Alınabilir"de gri görünür).
`questMinLv(q)` (`q.lvAt` varsa doğrudan o):
1. `questOwnLv(q)`: hedef canavarın/noktanın bulunduğu sahnenin `lvr[0]-1`'i (görevi verenin sahnesine yakın olanlar öncelikli). Başlangıç kampları 1.
2. Hedefsizse önceki görevin seviyesi; o da yoksa zincirde ileriye bakıp ilk savaş görevi.
3. Hâlâ yoksa `q.lv0` (bölge dosyasındaki `seviye`) ya da `hubLv` (o şehirdeki savaş görevlerinin en düşüğü).
4. Sonuç `max(…, önceki görev seviyesi, q.lvMin)`.

## Bölge ekleme yöntemi (her yeni bölge için aynı)
1. **Çöz**: `python3 tools/gorev_aktar.py <Çince şehir/kamp adı> <ad>` → `kaynak/ceviri/gorevler/<ad>_kaynak.json`.
   Araç: tür/hedef/adet **Symbian kaydından** (`tablolar/tasks.json`: [başlık, hedef cümlesi, metin, kabul, ret, bekleme, ayrıl, bitiş, tamam, ilerleme(%d), adlar…]);
   veren/teslim/ödül/zincir **APK 1025**'ten. Elenenler: kayıt yok, NPC oyunda yok, canavar yok, kaynak yok, çok hedefli (`；`).
   Eşyası NPC'den gelen tek adetli toplama görevleri `talk` (eşya götür) olur. APK'daki "reach" hep `talk`'tır.
   Zincir (`req`): APK `nextTaskId`'den, elenen görevlerin üstünden atlayarak.
2. **Seç ve dök**: `python3 tools/gorev_sec.py <ad1,ad2> 55 /tmp/dokum.txt`: 55 üstü sahnelere düşenleri ve onlara bağlı konuşma zincirlerini ele; etkinlik/hediye/eğitim veren NPC'leri ele (契约欢乐使者, 驿站老板, 盲眼向导, 驯兽师, 装备强化大师, 技能训练师, 采矿人, 考古, 源质炼金师, 神秘商人); APK'da kill/collect olup bizde `talk` çıkanları ele (Symbian'da ilerleme satırı yok = yanlış çözülür); savaş alanı görevlerini (bekleme metni 恩/谢谢/抱歉…) ele. Çince metinleri `## id [tür] başlık | veren→teslim | hedef eşya xN @sahne req` biçiminde dök, oku.
3. **Çevir**: `kaynak/ceviri/gorevler/<ad>.json`:
   ```json
   {"bolge": "…", "seviye": 33, "atla": [id…], "zincir": {"id": oncekiId}, "seviyeler": {"id": enDüşükSeviye},
    "adlar": {"Çince": ["Türkçe", "English"]},
    "irk": "人类" | "精灵",        // yedek ırk: veren NPC farklı taraflarda birden çok yerdeyse (asıl kural: NPC'nin haritasının tarafı, tools/taraf.py)
    "irklar": {"id": "精灵"},
    "sahneler": {"id": "Çince sahne"}, // hedefin asıl haritası (araç yanlış seçtiyse)
    "lv": 40,                       // zindan görevleri: haritaların seviye aralığı yok; ödül ve en düşük seviye buradan       // göreve özel ırk (ortak bölgedeki ırk zincirleri)
    "gorevler": {"id": {"tr": [başlık, metin, bekleme, bitiş, (eşya)], "en": [...]}}}
   ```
   `seviye`: o şehirde verilen hedefsiz konuşma görevlerinin en düşük seviyesi (aynı adlı NPC başka şehirde de durunca seviye yanlış çıkmasın).
   Bekleme/bitiş metni "结束/完成/离开" gibi düğme yazısıysa anlamlı kısa bir cümle yaz. Bir görevin yapısı bütün `_kaynak` dosyalarında aranır; bir çeviri dosyası birden çok bölgeyi kapsayabilir.
4. **Üret**: `python3 tools/gorev_ham.py && python3 tools/ceviri.py && python3 tools/gorevler.py && python3 tools/odul_esyalari.py`.
5. **Denetle** (`docs/06-test.md`): önce `node tools/test/gorev_denetim.js` (orijinalle alan alan), sonra `tools/test/qtest.js` (statik: veren/teslim/canavar/nokta haritada var mı + örnek zincir oynatma), `tools/test/qlv.js` (açılma seviyeleri). Seviyesi tuhaf çıkanları `seviyeler`/`zincir`/`atla` ile düzelt.
6. **SQL**: `cd server && node import.js` (quests tablosu). Sonra sürüm + commit + push.

## Bilinen tuzaklar
- Aynı adlı NPC birden çok şehirde (驿站老板 postacı, 走私者, 奴隶商人…) → `hubLv` en düşük şehri alır → `seviye` kullan; postacı görevlerini ele.
- Hedef canavar başka düşük bölgede de yaşıyorsa (狼, 巨魔) seviye düşük çıkar → `seviyeler`.
- Symbian `sc` (hedef cümlesindeki sahne) bazen yanlış (ör. 望日城 yazar, canavar Tarikat Üssü'ndedir) → hedef metnini kontrol et, gerekirse `atla`.
- 邪教基地 (Tarikat Üssü) iki kopya: `120012` 28-31 ve `120001` 50; üst katlar 60.

## Bölgeler (yapılanlar)
| Dosya | Bölge | Seviye | Görev |
|---|---|---|---|
| `tr.js` (elle) + `gorevler.py` içindeki `Q` | Acemi kampları, Guanlin ana zinciri, Karanlık Gözcü Kulesi, Trol Ormanı | 1-28 | 126 |
| `guanlin.json` | Guanlin hikâye kolları (muhtar, simyacı, Kral'ın fermanı) | 3-27 | 31 |
| `kosanat.json` | Koşanat Şehri 奔马城 | 17-34 | 96 |
| `kahin.json` | Kâhin Tapınağı 先知神殿 (elf) | 6-20 | 37 |
| `gozcu.json` | Gözcü Kampı 守望者营地 (elf) | 15-27 | 79 |
| `gunesgoren.json` | Güneşgören Şehri 望日城 + Dinlenme Bölgesi + lonca terasları | 20-49 | 124 |
| `karakol.json` | İstihbarat Karakolu 军情前哨 | 24-39 | 67 |
| `baskent.json` | Başkent 帝都 + Soylular/Kahramanlar/Tapınak + İnsan Mahallesi + lağım | 32-49 | 119 |
| `daggoren.json` | Dağgören Şehri 望山城 (55 altı kısmı) | 37-54 | 30 |
| `sisli.json` | Yoğunsis Kasabası 浓雾镇: Cinateşi Ormanı, kıyı, Feryat Patikası, Obur/Karakan Ormanı | 39-47 | 120 |
| `sanatci.json` | Sanatçılar Loncası 艺术家工会前厅 (Resim/Heykel koridorları 90, elendi). Loş Kamp 幽暗营地: hepsi 60+, alınmadı | 49-51 | 22 |
| `liman.json` | Altındalga Limanı 金波港 + lağım, Gece Elfi Mahallesi→Yoğunsis zinciri (81883→81884→81885→81914→81915). İtibar/unvan, zindan, tabela görevleri alınmadı. Dağ Eteği Kampı 60+ | 38-40 | 12 |
| `akademi.json` | Büyü Akademisi 魔法学院: Büyü Bahçesi, Peri Ormanı (sınıf yükseltme zincirleri alınmadı) | 49-52 | 10 |
| `zindan30.json` | Mehtap Korusu zindanı (insan Cromwell, elf Gecekanat) | 30 | 2 |
| `zindan40.json` | Ruhyiyen Ovası zindan grubu + merkezi (ortak) | 40 | 13 |
| `zindan50.json` | Kuleler (Ruh Balkonu) + Akankum Limanı (ortak) | 50 | 13 |

İnsan yolu: kamp → Guanlin (3-11) → korucu → Koşanat (17-34) → simyacı kolu → Kral'ın fermanı → Karakol (27-39) → Başkent (33-49).
Elf yolu: kamp → Kâhin Tapınağı (6-20) → Gözcü Kampı (19-27) → Güneşgören (29-49).

### NPC'ye eşya kullanma görevleri
`pickup` görevinin `node`'u bir NPC ise (ör. iksiri 护炉人加里 Gary'ye içir) `gorevler.py` ona `use: 1` koyar; hedef metni
"X eşyasını Y üzerinde kullan" olur ve oyunda o NPC'ye dokununca görev hazır olur (`interact()` içinde).

### Bilinçli olarak alınmayan görev türleri (sistemi yok)
İtibar / iyilik-kötülük değeri / unvan ödüllü görevler (ozan çırağı), zindan (副本) görevleri, lonca panosu tabelaları,
40. seviye sınıf yükseltme zincirleri (纹章法师, 烈焰导师 …), deniz mağarası. Bu sistemler gelince ayrı ele alınacak.
`gecemah_kaynak.json`, `insanmah_kaynak.json`, `adalet_kaynak.json` yalnızca başka bölgelerin zincir halkaları için yapı sağlar.

Araç: `python3 tools/gorev_aktar.py 'bölge1,bölge2,#görevId' ad` — virgülle birden çok bölge, `#id` ile tek görev.
