# 04 · Görevler

## Görev nesnesi (oyunda `QUESTS[]`)
`{id, giver, to, type, target, node, count, sc, chance, item, req, race, rw:{gold, items}, lv0, lvMin, title, text, ok, wait, done, goal}`
- `giver/to/target/node` **orijinal Çince adlar**; gösterimde `trName()`.
- Türler: `talk` (kabul edince hazır; `to` ile konuşunca biter; `item` varsa "eşyayı götür"), `kill` (`target` × `count`),
  `collect` (`target` canavardan `chance` olasılıkla `item`), `pickup` (`node` toplama noktası), `deliver`, `special` (`flag`).
- `req`: önceki görev (dizi = "herhangi biri", ırk yolları için). `race`: yalnızca o ırk.
- Ödül: TP seviyeden hesaplanır (`q.reward`), altın/eşya `rw`'den.

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
    "gorevler": {"id": {"tr": [başlık, metin, bekleme, bitiş, (eşya)], "en": [...]}}}
   ```
   `seviye`: o şehirde verilen hedefsiz konuşma görevlerinin en düşük seviyesi (aynı adlı NPC başka şehirde de durunca seviye yanlış çıkmasın).
   Bekleme/bitiş metni "结束/完成/离开" gibi düğme yazısıysa anlamlı kısa bir cümle yaz. Bir görevin yapısı bütün `_kaynak` dosyalarında aranır; bir çeviri dosyası birden çok bölgeyi kapsayabilir.
4. **Üret**: `python3 tools/ceviri.py && python3 tools/gorevler.py`.
5. **Denetle** (`docs/06-test.md`): `tools/test/qtest.js` (statik: veren/teslim/canavar/nokta haritada var mı + örnek zincir oynatma), `tools/test/qlv.js` (açılma seviyeleri). Seviyesi tuhaf çıkanları `seviyeler`/`zincir`/`atla` ile düzelt.
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

İnsan yolu: kamp → Guanlin (3-11) → korucu → Koşanat (17-34) → simyacı kolu → Kral'ın fermanı → Karakol (27-39) → Başkent (33-49).
Elf yolu: kamp → Kâhin Tapınağı (6-20) → Gözcü Kampı (19-27) → Güneşgören (29-49).

### NPC'ye eşya kullanma görevleri
`pickup` görevinin `node`'u bir NPC ise (ör. iksiri 护炉人加里 Gary'ye içir) `gorevler.py` ona `use: 1` koyar; hedef metni
"X eşyasını Y üzerinde kullan" olur ve oyunda o NPC'ye dokununca görev hazır olur (`interact()` içinde).
