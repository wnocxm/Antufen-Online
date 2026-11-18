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
- `tools/test/denge.js`: 1-55 deneyim benzetimi (RACE=人类|精灵, MAX, GRIND=0 kasmasız). Görevleri sırayla yapar, hedef için gereken canavarları ve kasmayı sayar; deneyim tablosu değişince görev payının ~%40 kaldığını buradan doğrula. `tools/test/savas.js`: sınıf × seviye dövüş benzetimi (gerçek `update` döngüsü, en iyi dükkân eşyası; 40 ve üstü sınıf, 80 ve üstü ikinci yükseltme sayılır, `ADV=0` ile yalnız acemi ağacı; puanlar oyuncu gibi dağıtılır, `SPEC=0|1` uzmanlık).
- `tools/test/zindan.js`: zindan giriş/çıkış, kesilenlerin geri gelmemesi, boss sandığı, günlük sınır, ölüm. `BOSS=… node tools/test/savas.js`: boss dövüşleri.
- `tools/test/zindan40.js`, `tools/test/zindan50.js`: 40 ve 50. seviye zindan grupları (ışınlanma, kapılar, ön görev, çok hedefli görev, boss'lar).
- `tools/test/evcil.js`: kuluçka, savaş katkısı, besleme, ölüm/diriltme, yumurta düşmesi, rastgele beceri dağılımı, ağaç (8 biçim), dönüşüm, beceri aktarma, hale. Pencere görüntüleri: `_pencere`, `_taktik`, `_beceri`, `_agac`, `_donusum`.
- `tools/test/gorev_denetim.js` (tarayıcısız): oyundaki her görevi orijinal ham kayıtla alan alan karşılaştırır (zincir, adet, hedef, altın, deneyim, eşya). Görev işinden sonra ilk çalıştırılacak test.
- `tools/test/gorev_seviye.js`: her ırk için seviye başına açılan görev sayısı, orijinal ve bizim görev deneyimi, gereken deneyim.
- `tools/test/odul.js`: orijinal altın + sınıfa göre ödül eşyası (her sınıf yalnız kendi eşyası), görev penceresinde ödül satırı.
- `tools/test/yolbul.js`: görev yol bulma (alınmamış → veren, alınmış → canavarın haritası, varınca yanına yürür ama saldırmaz, hazır → ödülü veren).
- `DIL=en node tools/test/gm.js`: GM paneli İngilizce; sekme adları ve çevrilmeyen yazılar yazdırılır.
- `tools/test/alisveris.js`: adet girişi (dokunmatik sayı kutusu, bilgisayar rakamları, altın sınırı, satarken adet, ekipman onayı) ve NPC'nin içinden geçme.
- `tools/test/yolculuk.js`: yolculuk ağı (Fırtına Büyücüsü → Bozbalta, arabacı 100 altın ve sayfalı liste, altın yetmezse, yürüyerek gidilemeyen yere otomatik yol, GM ücretsiz, çevrilmeyen ad yok).
- `tools/test/sinif.js` 6. bölüm: 80 zinciri (üç sınıf, NPC konuşmaları, sandık, küre). Boss dengesi: `ADV=1 BOSS='120499:☆☆【疯狂梦呓者】安德卡诺:80' node tools/test/savas.js`.
- `tools/test/efekt.js`: beceri efektleri. Kılıç izi şeridi (4 yön × `刀光` / `刀光-红`, `_iz.png`), üç sınıf × iki uzmanlıkta bütün etkin becerilerin oyundaki görüntüsü (pafta `_<sınıf>_<uzmanlık>.png`; oyun döngüsü durdurulup `__upd(0.05)` ile adım adım), süren etkiler (güç/canavar/totem/hayal satırları), Alev Yakışı tek hedef. Efekt değiştirince paftalara bak.
- `tools/test/beceri.js`: beceri ağaçları (6 sekme, ön koşul, sınıf ağacı 35 puan, uzmanlık 40 puan ve dışlama, Eğitim Kitabı ile sıfırlama, ırk becerileri, eski kayıt düzeltme, üç sınıfın iki uzmanlıkta bütün etkin becerileri). Görüntüler `_uzmanlik`, `_dislanan`.
- `tools/test/sinif.js`: 40. seviye sınıf yükseltme (kendiliğinden gelen görev, Ozan'ın sınıf seçeneği, NPC konuşmalarıyla insan savaşçı zinciri, her sınıf/ırk giriş görevi, iki eşyalı toplama, perinin seçimli bitişi, sınıf ağacı kilidi, eski kayıtta puan iadesi). Görüntüler `_agac_kilitli`, `_agac_acik`, `_ozan`, `_tom`, `_peri`.
- `tools/test/menu.js`: sol menü kaydırma (GM düğmesi sürükleyince / tekerlekle gelir, dokununca GM paneli; GM olmayanda kaymaz).
- `tools/test/hedef.js`: hedef seçme saldırı başlatmaz; ikinci dokunuş ve saldırı düğmesi saldırır; yön tuşu bırakır.
- `tools/test/evcilgorev.js`: RACE=人类|精灵 Terbiyeci zinciri.
- `tools/test/evcil_kolaj.js`: bütün türlerin 8 biçimi ve beceri simgeleri tek görselde (görsel denetim).
- `tools/test/gorunus.js`: `LOOKS='ad1,ad2'` görünüşleri yan yana çizer (palet/görsel karşılaştırma).

## C++ (`native/`, docs/09-cpp.md)
- Derleme + birim testleri: `cmake -S native -B native/build -G Ninja && cmake --build native/build && ctest --test-dir native/build` (ya da `./native/build/test_godat`).
- `python3 tools/test/godat_esitlik.py`: bütün godat dosyalarında C++ = Python, şifreli paket gidiş-dönüşü (`PAKET=0` yalnız okuma).
- `native/build/anrufen_test <senaryo>`: ekransız test modu (komutlar docs/09). `node tools/test/cpp_karsilastir.js` (sunucu açık): C++ ↔ HTML 6 sahne çizim + 6 yön yürüme; çıkış kodu 0 = geçti.
- `node tools/test/cpp_savas.js`: C++ ↔ HTML canavar yerleşimi + 26 senaryoda (18'i becerili) saniye saniye savaş izi (tohumlu zar); çıkış kodu 0 = geçti.
- `node tools/test/cpp_gorev.js` (`ADIM=80`): C++ ↔ HTML görevler: 945 görevin açılma seviyesi, 4 görev botu (her adım), 6 sınıf yükseltme zinciri. Karşılaştırma testlerinin hepsi oyun sunucusu olmadan (geçici statik sunucuyla, port 8097; aynı anda bir tane) çalışır.
