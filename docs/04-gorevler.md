# 04 · Görevler

## Görev nesnesi (oyunda `QUESTS[]`)
`{id, giver, to, type, target, node, count, sc, chance, item, req, race, rw:{gold, items}, lv0, lvMin, title, text, ok, wait, done, goal}`
- `giver/to/target/node` **orijinal Çince adlar**; gösterimde `trName()`.
- Türler: `talk` (kabul edince hazır; `to` ile konuşunca biter; `item` varsa "eşyayı götür"), `kill` (`target` × `count`),
  `collect` (`target` canavardan `chance` olasılıkla `item`), `pickup` (`node` toplama noktası), `deliver`, `special` (`flag`).
- `req`: önceki görev (dizi = "herhangi biri", ırk yolları için). `race`: yalnızca o ırk.
- Ödül: altın ve eşya orijinal (`q.rw` ← `QRW`, ham kayıt); TP şimdilik seviyeden hesaplanır (`q.reward`), orijinali `q.rw.xp`.

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
- **Deneyim:** görevlerin orijinal deneyimi `q.rw.xp`'de duruyor. Oyun henüz bizim formülü kullanıyor (`game.js` `q.reward.xp`), çünkü seviye tablosu orijinal görev deneyimine göre yeniden kurulmadı (karar bekliyor, docs/01).

### Orijinalden bilinçli sapmalar (istisnalar, denetim aracında `ISTISNA`)
- 81063 / 81396 Obur Ormanı: orijinal 15 食人鬼 + 15 恶咒食人鬼 + 15 鬼骑士. İlk ikisi orijinal harita verisinde de yok; yalnız 15 Hayalet Şövalye kaldı.
- 80597 Hedef Seçme: orijinalde vereni boş bir eğitim görevi; bizde 初级战斗导师 → 教练员.
- 81993 / 81998 zindan: "啃食者" başvuru listesinde yok, ilerleme metninde var (haritada ☆啃食者).
- 81786 "Hızlı Öldürme": Symbian'da yok, APK eklemesi; atlandı.
- `zincir:bizim` (59): orijinalde öncesi olmayan ama bizde bağlanan görevler.
  - `tr.js` eğitim sırası (kamp ve Guanlin girişi).
  - Evcil hayvan görevleri (hayvan şartı orijinalde sunucudaydı).
  - Birkaç bölge bağı.

## Seviye kilidi (`game.js`)
`questState(q)` → `done | ready | active | new | soon | locked`. `soon` = `P.lv < questMinLv(q)` (5 seviye içindeyse "Alınabilir"de gri görünür).
`questMinLv(q)`:
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
