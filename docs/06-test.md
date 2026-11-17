# 06 · Test ve yerel çalıştırma

## Yerel sunucu
```bash
service postgresql start            # küme sık sık kapalı bulunur
cd server && PORT=8099 DATABASE_URL=postgres://anrufen:anrufen_dev@localhost:5432/anrufen node server.js   # arka planda
```
Sunucu `www/`'yi de sunar → oyun `http://localhost:8099/`. Veritabanı kullanıcısı/şifresi yalnızca geliştirme içindir.
Sunucu testi: `cd server && DATABASE_URL=… node test.js` → "TÜM TESTLER GEÇTİ".

## Playwright betikleri (`tools/test/`)
Chromium ve Playwright konteynerde hazır (`require('playwright')`). Adres `URL` ortam değişkeniyle değişir, ekran görüntüleri `OUT` klasörüne yazılır.
| Betik | Ne yapar |
|---|---|
| `off.js` | Çevrimdışı yeni karakter, kayıt, yeniden yükleme ("Devam Et" görünüyor mu) — her değişiklikten sonra hızlı duman testi |
| `qtest.js` | Bütün üretilmiş görevlerin statik denetimi (veren/teslim/canavar/nokta haritada mı, metin Çince kalmış mı) + bir zinciri oynatma (`for (const id of [...])`, `gmLevel(..)`) |
| `qlv.js` | Bütün görevlerin açılma seviyesi dökümü: `id | seviye | tür | başlık | veren | req | hedef` |
| `fx.js <sınıf>` | Sınıfın her becerisini sırayla kullanıp 3'er kare ekran görüntüsü (`OUT/<sınıf>_<k>_<j>.png`) |
| `fx2.js`, `auto.js <sınıf>` | Kare kare efekt / normal saldırı görüntüsü |
| `tap.js` | Boş yere dokununca karakterin yürümediğini doğrular |
| `tan.js [klasör]` | Tanıtım ekran görüntüleri (deviceScaleFactor 2) |
| `e2e.js` | Çevrimiçi akış (kayıt, giriş, karakter) |

Başlık ekranında çevrimdışı ilerleme: ~1200 ms bekle, `Enter` (ilk menü öğesi), sınıf seç `[data-cls="法师"]`, ad `#cname`, `#cstart`.
Oyun hazır: `window.__G && window.__G.player`. Konsoldan: `gmLevel(n)`, `loadScene(sid)`, `useSkill(i)`, `acceptQuest(q)`, `questKill(ad)`, `completeQuest(q)`.

## Sık karşılaşılanlar
- `ERR_CONNECTION_REFUSED`: sunucu düşmüş (oturum yeniden başlayınca arka plan süreçleri ölür) → yeniden başlat.
- `ECONNREFUSED 5432`: PostgreSQL kapalı → `service postgresql start`.
- Komut onayı geçici "no verdict" hatası verirse aynı komutu bir kez daha dene; olmazsa salt okunur işlerle devam et.
- Yeni görsel/efekt görünmüyorsa: sürüm (`?v=`) artırıldı mı, ad `preload` listesinde mi (`loadScene` içindeki `names`).

- `tools/test/adlar.js`: bütün haritalardaki adların TR/EN'de Çince kalmadığını denetler (beklenen: `cn: []`).
- `tools/test/denge.js`: 1-55 deneyim benzetimi (RACE=人类|精灵, MAX, GRIND=0 kasmasız). Görevleri sırayla yapar, hedef için gereken canavarları ve kasmayı sayar; deneyim tablosu değişince görev payının ~%40 kaldığını buradan doğrula. `tools/test/savas.js`: sınıf × seviye dövüş benzetimi (gerçek `update` döngüsü, en iyi dükkân eşyası).
- `tools/test/zindan.js`: zindan giriş/çıkış, kesilenlerin geri gelmemesi, boss sandığı, günlük sınır, ölüm. `BOSS=… node tools/test/savas.js`: boss dövüşleri.
- `tools/test/zindan40.js`, `tools/test/zindan50.js`: 40 ve 50. seviye zindan grupları (ışınlanma, kapılar, ön görev, çok hedefli görev, boss'lar).
- `tools/test/evcil.js`: kuluçka, savaş katkısı, besleme, ölüm/diriltme, yumurta düşmesi, rastgele beceri dağılımı, ağaç (8 biçim), dönüşüm, beceri aktarma, hale. Pencere görüntüleri: `_pencere`, `_taktik`, `_beceri`, `_agac`, `_donusum`.
- `tools/test/gorev_denetim.js` (tarayıcısız): oyundaki her görevi orijinal ham kayıtla alan alan karşılaştırır (zincir, adet, hedef, altın, deneyim, eşya). Görev işinden sonra ilk çalıştırılacak test.
- `tools/test/gorev_seviye.js`: her ırk için seviye başına açılan görev sayısı, orijinal ve bizim görev deneyimi, gereken deneyim.
- `tools/test/odul.js`: orijinal altın + sınıfa göre ödül eşyası (her sınıf yalnız kendi eşyası), görev penceresinde ödül satırı.
- `tools/test/yolbul.js`: görev yol bulma (alınmamış → veren, alınmış → canavarın haritası, varınca yanına yürür ama saldırmaz, hazır → ödülü veren).
- `tools/test/alisveris.js`: adet girişi (dokunmatik sayı kutusu, bilgisayar rakamları, altın sınırı, satarken adet, ekipman onayı) ve NPC'nin içinden geçme.
- `tools/test/hedef.js`: hedef seçme saldırı başlatmaz; ikinci dokunuş ve saldırı düğmesi saldırır; yön tuşu bırakır.
- `tools/test/evcilgorev.js`: RACE=人类|精灵 Terbiyeci zinciri.
- `tools/test/evcil_kolaj.js`: bütün türlerin 8 biçimi ve beceri simgeleri tek görselde (görsel denetim).
- `tools/test/gorunus.js`: `LOOKS='ad1,ad2'` görünüşleri yan yana çizer (palet/görsel karşılaştırma).
