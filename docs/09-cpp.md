# 09 · C++ istemcisi (`native/`)

## Karar (18.11, kullanıcı)
- Oyun C++ ile devam eder: güçlü (akıcı, az bellek/pil), içerik şifreli paketlerde, sonradan yamalarla genişletilebilir; kullanıcı C++'ta kendini geliştirmek istiyor.
- Aynı depoda, ayrı klasörde (`native/`), adım adım. HTML sürümü (`www/`) **usta kopya**: yalnız hata düzeltmesi alır; C++ sürümünün karşılaştırma testlerinde referanstır.
- İçerik iki kez yazılmaz: veri hattı (Python araçları, `kaynak/ceviri`, üretilen veri dosyaları) ortak; C++ aynı verileri okur.
- **Eksik haritalar ve zindanlar C++ sürümünde tamamlanacak** (HTML'de eksik kalanlar: yanlış seviyeli sahneler, kahraman modları, 60+ zindanlar; docs/01, docs/04).
- Orijinal godat biçimi sürdürülür: orijinal dosyalar dokunulmadan kaynak kalır; bizim içeriğimiz aynı yapıda, şifreli GODAT3.0 paketlerine yazılır.
- Grafik kütüphanesi: SDL2 (kullanıcı onayı); kaynağı depoda (`native/third_party/SDL2`), oyunla birlikte derlenir.
- Sunucu değişmez (Node + PostgreSQL); C++ yalnız istemci. Hileye karşı asıl koruma sunucu tarafı denetimdir (şifreleme içeriği korur, sunucu oyunu korur).

## Yol haritası
1. **godat kütüphanesi ✔ (18.11)**: orijinal okuma, GODAT3.0 şifreli paket, katmanlı yama, araçlar, testler.
2. **Motor iskeleti + test modu ✔ (18.11)**: SDL2 depoda; veri paketi; sahne (zemin, nesneler, NPC'ler), oyuncu katmanları, kamera, 4 yönlü yürüme; ekransız test modu. HTML ile karşılaştırma: 6 sahnede çizim birebir (en kötü %0,018), 6 yönde yürüme aynı.
3. Sistemler tek tek, her biri "aynı senaryo iki sürümde aynı sonuç" testiyle: **canavarlar + temel savaş ✔ (18.11)** → **beceri/efekt ✔ (18.11)** → **görev ✔ (18.11)** → arayüz: **oyun ekranı ✔ (18.11)**, **pencereler 1 + yol bulma ✔ (18.11)** (konuşma, görev listesi, ana menü, ölüm, onay), pencereler 2 (karakter, çanta, beceri) → eşya/dükkân → evcil → zindan → yolculuk → GM → ağ (mevcut sunucu).
4. Paketleme: Android (GitHub otomatik derleme), iOS (Mac gerekir).

## Klasör ve derleme
```
native/
  CMakeLists.txt          derleme (C++17, zlib, SDL2)
  src/godat/              godat.h/.cpp (arşiv, paketleyici), chacha20.h/.cpp (şifre)
  src/core/               png (PNG okuma/yazma, zlib ile), json (küçük JSON okuyucu)
  src/engine/             vfs (veri: klasör ya da paket), canvas (yazılımla çizim), assets (palet, sprite, karakter katmanları),
                          map (harita, zemin, nesneler), world (sahne, NPC, oyuncu, kamera, yürüme, çizim sırası)
  src/app/                main.cpp (pencereli oyun: anrufen), headless.cpp (ekransız test modu: anrufen_test)
  src/tools/              godat_dump.cpp, godat_pack.cpp (komut satırı araçları)
  tests/                  test_godat.cpp, test_motor.cpp (birim testleri)
  third_party/SDL2/       SDL 2.30.9 kaynağı (sürüm, kaynak, ayıklananlar: third_party/README.md)
  third_party/zlib/       zlib 1.3.1 (sistemde yoksa: Windows, Android, iOS)
  build/                  derleme çıktısı + build/veri/oyun.gdp (git dışı)
  anahtar.txt             yayın anahtarı (git dışı; yoksa geliştirme anahtarı)
```
```bash
cmake -S native -B native/build -G Ninja && cmake --build native/build && ctest --test-dir native/build
cmake --build native/build --target anrufen     # pencereli oyun (SDL2 burada derlenir, ~10 sn)
cmake --build native/build --target veri        # www/assets → build/veri/oyun.gdp (2956 dosya, 56 → 33 MB, şifreli)
                                                # anrufen derlenirken de yapılır; www/assets'te dosya değişince/eklenince yeniden üretilir
```

### Kendi bilgisayarında (kullanıcı)
- **Windows:** Visual Studio 2022 ("C++ ile masaüstü geliştirme" iş yükü; CMake içinde gelir). "x64 Native Tools Command Prompt" içinde, depo kökünde:
  `cmake -S native -B native/build` → `cmake --build native/build --config Release --target anrufen veri` → `native\build\Release\anrufen.exe` (veriyi `native\build\veri\oyun.gdp`'den bulur).
  Windows'ta zlib yoktur; depodaki kopya kendiliğinden derlenir. SDL2 de depodan derlenir (ilk sefer birkaç dakika).
- **Linux:** derleyici, CMake, Ninja ve ekran kütüphanelerinin geliştirme paketleri (X11 ya da Wayland); komutlar yukarıdaki gibi, program `native/build/anrufen`.
- Bu ortamda (bulut) yalnız ekransız test modu ve sahte ekran sürücüsüyle duman testi yapılabiliyor; gerçek pencere senin bilgisayarında.

## Motor (2. adım)
- **Çizim yazılımla** (`Canvas`, RGBA): her kare işlemcide çizilir, pencerede SDL dokusu olarak büyütülür (keskin piksel). Aynı kod ekransız testte PNG'ye yazar → test görüntüsü oyundakiyle aynıdır. 2D ve 640×360 mantıksal ekran için yeterince hızlı; gerekirse sonra GPU'ya taşınır.
- **Veri**: `Vfs` önce klasör (geliştirme: `www/assets`) ya da şifreli paket (`oyun.gdp`) bağlar; sonra bağlanan üstte (yama). Pakette her dosya bir kayıt (ad = yol, numara = `pathId` FNV-1a). Klasörden ve paketten okunan görüntüler bayt bayt aynı.
- **HTML karşılıkları** (aynı mantık, aynı sayılar): `assets.js` → `assets.cpp` (palet: gri değer = palet numarası, macenta saydam; `drawParts` ayna/çevirme kuralı; `Paperdoll` katmanları), `world.js` → `map.cpp` (zemin iki katman, düz nesneler önce), `game.js`/`ui.js` → `world.cpp` (giriş bölgesi, geçilmez karede kaçış, `snapScreen4`/`dirOf`, `moveEnt`, RUN 4,2, adım sayacı, kamera, derinlik sırası, kırpma sınırları). JS `Math.round` için `jsRound` (yarım yukarı).
- **Pencereli oyun** `anrufen [--veri <klasör|paket.gdp>] [--sahne <no>] [--sinif …] [--irk …] [--cinsiyet …]`: ok tuşları/WASD, F12 ekran görüntüsü, Esc. Burada yalnız sahte ekran sürücüsüyle (`SDL_VIDEODRIVER=dummy`) çalıştırılabildi; gerçek pencere kullanıcının bilgisayarında.
- **Kapsam (sırada)**: canavarlar, savaş, efektler, arayüz pencereleri, görevler … (yol haritası 3. adım). Ayak gölgesi çiziliyor; adlar/yazı tipi henüz yok.

## Canavarlar ve temel savaş (3. adım, ilk parça)
- **Zar**: oyunun bütün rastgele sayıları tek üreteçten (`engine/rng.h`, mulberry32; HTML'deki `Math.random` yerine). Tohum verilince dizi sabittir; karşılaştırma testinde HTML'de `Math.random` aynı üreteçle değiştirilir. Zarlar HTML ile **aynı sırayla** atılır (varlık oluşturma: NPC/canavar/oyuncu `t`, canavar gezinme süresi ve yönü; yerleşim; hasar; ıska; öldürmede altın → Yaşam Elementi → iksirler → ganimet → evcil yumurtası).
- **JS hesap karşılıkları**: `jsRound` (yarım yukarı), `jsHypot` (V8'in Kahan toplamlı Math.hypot'u; son basamak farkı dallanmayı değiştirmesin), JS nesne anahtar sırası (tam sayı anahtarlar artan: eşya ve canavar kayıtları).
- **Denge verisi** `www/assets/denge.json` ← `tools/denge_cikar.js` (game.js'ten: MON, XPT, MXPT, sınıf tabanları; elle düzenleme). `engine/balance.cpp`: canavar tanımı (elle yazılmış + sahne seviyesinden otomatik, ilk hesaplandığı sahne belirler — HTML önbelleği gibi), deneyim, eşyalar (items.json), canavar kayıtları (fixMonData düzeltmesiyle), evcil yumurtası ailesi (pets.json).
- **`engine/world.cpp`** (HTML'deki sırayla): sahne yükleme (NPC, sabit "canavar" düğümleri + geçilmez kare, canavar yerleşimi), oyuncu istatistikleri (sınıf + seviye + ekipman + ırk becerileri), zamanlayıcılar (`later`, sondan başa), hedefe koşma/takılma/saldırı (yakın dövüş vuruşu 0,25 sn sonra; büyücü/elçi ateş topu mermisi), canavar yapay zekâsı (kendiliğinden saldırma, 12 kare sonra vazgeçme, kovalama, 1,6 sn'de bir darbe, gezinme), hasar formülü, ıska, ölüm ve yeniden doğma, deneyim/seviye atlama, altın, iksir, ganimet, evcil yumurtası, efektler (ölüm, kan, mermi, seviye), geçitten başka haritaya geçiş.
- **Pencereli oyunda**: boşluk tuşu en yakın canavara saldırır.
- **Henüz yok**: görevler, evcil hayvan, zindan kuralları (boss ayarı, kesilen canavar, kapılar), arayüz (can çubuğu, adlar, hasar sayıları, pencereler, kısayol halkası), ses.
- **Bulgu (HTML hatası, düzeltildi):** harita değişince bekleyen zamanlayıcılar silinmiyordu; önceki haritadaki bir canavarın bekleyen darbesi yeni haritada oyuncuya vuruyordu. HTML `loadScene` artık zamanlayıcıları temizliyor (C++ zaten öyle).

## Beceriler ve efektler (4. adım)
- **`engine/skills.h/.cpp`**: 3 sınıf × 24 beceri (38 etkin, 34 edilgen) + 4 ırk becerisi, HTML `CLS[...].skills` ile **aynı sırada** (sıra = kısayol numarası) ve aynı sayılarla. Her beceri: mana, bekleme, menzil, efekt alanları (`self/hit/proj/fx/fx2/bfx/totem`, sayı + yarıçap) ve işlevleri: `f` (vuruş sayıları `SkF`: çarpan, ek hasar, kritik, yavaşlatma, kanama, yanma, donma, sersemletme, çürüme, Büyü Hayali, Büyü Darbesi…), `pas` (edilgen), `buff` + `dur` (güçlendirme), `heal`, `mpPct`. `K("sabit")` kademe değeri (skills.json, orijinal). Ağır Yarık (`tearHit`) ve Gölge Yakışı (`burnHit`) zarları HTML sırasıyla.
- **Güçlendirmeler** `Vals`: JS nesnesi gibi sıralı (ekleme sırası), toplamlar HTML'deki sırayla. `stats()`: sınıf + seviye + ekipman → edilgenler (ırk dahil) → yüzdeler → İlahi Işık Dökümü → güçlendirmeler → dönüşümler (Kan Ruhu, Çelik İrade, Büyü Yankısı) → yuvarlama.
- **`World`**: `useSkill` (bekleme, mana, Gölge Hükümdarı şifa engeli, aç/kapa, menzil dışında `pending` ile yürüyüp kullanma, 0,25 sn sonra mermi / alan / vuruş / şifa / güçlendirme; çoklu mermi; Şifa Pınarı yere konur), `hitMob` seçenekleri (savunmasız, sürekli hasar, Hız Patlaması kritiği, Kan Damgası, Element Ustalığı, Büyü Darbesi katları, Element Bağışı, tetiklenen mühür/umutsuzluk/sersemlik), `hurtPlayer` (Büyücü Bedeni, Zifiri Perde, Büyü Kalkanı, Karşı Saldırı Fırtınası, Kutsanmış Beden), süren etkiler (kanama, yanma, Çürüme + can emme), güçlendirme etkileri (şifa/mana akışı, Karanlık Ahit, Gölge Hükümdarı), Büyü Hayali, `fxBurst` (saçılan efektler, zamanlı), `auraSync` (güçlendirme ve zayıflatma haleleri), totem. Ağaç kuralları: `skLock`, `treePts`, `skillUp`, `skillAutoSpend` (puanları oyuncu gibi dağıtma), `skillReset`.
- **Pencereli oyunda**: 1-9 tuşları beceri listesindeki sırayla; `--seviye <n> [--uzmanlik 0|1]` seviyeyi yükseltip puanları dağıtır (40'ta sınıf, 80'de ikinci yükseltme).
- **GM**: `World::god` (ölümsüzlük) ve `gmNoCd` (beklemesiz + manasız) hazır; GM paneli arayüz adımında.
- **Bulgular (HTML hataları, ikisi de düzeltildi):** (1) `stats()` hız oranını da tam sayıya yuvarlıyordu: Hız Patlaması (%25), Büyü Kalkanı'nın hız şansı (%30) 0'a iniyor, hiç hızlandırmıyordu. Artık `spd` yuvarlanmıyor. (2) Büyü Hayali harita değişince eski haritanın canavarını hedeflemeye devam ediyordu; artık hedefi bırakıyor.
- **Bilinen (HTML ile aynı bırakıldı):** büyücünün İsabet edilgeni (`acc`), Kutsal Akış'ın `convert` değeri, Umutsuzluk (`despairT`) ve `noSlow` henüz bir şeyi değiştirmiyor (orijinal etkileri sunucudaydı).

## Görevler (5. adım)
- **Veri** `www/assets/quests.json` ← `tools/gorev_cikar.js`: HTML'deki `QUESTS` dizisinin son hâli (tr.js elle yazılanlar + quests_gen.js; ödüller game.js kuralıyla), aynı sırada; Türkçe ve İngilizce metinler (başlık, anlatım, düğme, bekleme, bitiş, hedef, eşya, seçenekler), kişi/harita adları ve NPC sözleri. Araç HTML dosyalarını Node'da çalıştırır (iki dil); game.js'teki ödül satırları değişirse araç durur.
- **`engine/quests.h/.cpp`**: görev kayıtları (hedef türleri: öldür, düşen eşya, yerdeki nesne, eşya kullan; çok eşyalı toplama; ışınlanma; ödül eşyasının sınıfı) ve **açılma seviyesi** (HTML `questMinLv`: hedef canavarın haritası, verenin komşu haritaları, zincirde önceki/sonraki görev, şehir seviyesi, elle verilen alt sınır). Hesap sırasından bağımsız (düz ve ters sırada aynı; döngü yok).
- **`engine/world_quests.cpp`**: `questState` (done/ready/active/locked/soon/new), `acceptQuest`, `questKill` (çok hedefli sayaçlar, düşen eşya şansı, "önce eşyayı kullan", çok eşyalı toplama, tek hedef; zarlar HTML sırasıyla, ganimetten sonra yumurtadan önce), `questUseItem`, `questFlag` (çanta, hedef değiştir, yumurta), `completeQuest` (teslim eşyası, altın + ırk payı, sınıfa göre eşya, deneyim, sınıf yükseltmesi), `autoQuests` (seviye atlayınca), `questsFor`/`npcMark` (! ?), `interact` (toplama noktası, "kullan/ver", konuşma görevleri), `pickupNode`, `questTeleport` (ev), konuşma düğmeleri `dialogAccept`/`dialogComplete`, `cycleTarget`, GM `gmQuestReady`/`gmQuestDone`.
- **Pencereli oyunda** (konuşma penceresi gelene dek): E en yakın kişiyle konuşur, görevleri alır/teslim eder; Tab hedef değiştirir; olaylar konsolda ve pencere başlığında.
- **Bulgu (C++ hatası, düzeltildi):** pets.json'da APK'ya özel evcil türler `apk: 1` (sayı) diye işaretli; C++ bunu yalnız `true` olarak okuduğundan o türleri de yumurta listesine alıyor, Domuz Kral gibi canavarlarda fazladan zar atıyordu (görev botu 300. saniyede yakaladı). JSON'a JS doğruluğu (`truthy()`) eklendi; bayraklar onunla okunuyor.

## Arayüz 1: yazı ve oyun ekranı (6. adım)
- **Yazı atlası** `tools/yazi_atlasi.py` → `www/assets/fonts/atlas.json` + `fonts/atlas/*.png`: oyunun yazı tipleri (Alegreya 400/700 gövde, Metamorphous başlık; woff2, latin + latin-ext) ve yedekler (DejaVu: HTML'deki "Noto Serif"/serif/sans-serif ve ✦ ★ ◎ ⚔ gibi işaretler) her boy için harf tablosuna çevrilir (Python Pillow, FreeType woff2 okur). 53 yüz, ~18.700 harf; harf çifti aralıkları (kerning) da. C++'ta yazı tipi kitaplığı gerekmez; şifreli pakete girer. Emojiler (🔒 🛒) yok.
- **`ui/font`**: UTF-8, hizalama, taban çizgisi (alfabetik/orta/üst), dış çizgi (HTML strokeText: örtünün yuvarlak genişletilmesi), sığdırma (maxWidth: yatayda sıkıştırma), dikey degrade (yuvarlak düğme harfleri), yapay kalın (Metamorphous'un kalını yok; tarayıcı da yapay kalınlaştırır). En yakın boy seçilir.
- **Tuval** (`engine/canvas`): kesirli koordinatlı yarı saydam dikdörtgen (kenar örtüsü), çizgi dikdörtgen, elips/daire dolgu ve çizgi (4×4 alt örnek), ölçekli görsel (en yakın komşu ya da çift doğrusal; ışık olarak), radyal degrade, dikdörtgen/daire kırpma.
- **`ui/hud`** (HTML ui.js drawWorld sonu + drawHud): kişi adları, görev işaretleri (! ? ve toplama yıldızı), canavar adı + seviye + can çubuğu, uçan sayılar; portre (7143 çerçeve), ad, can/mana/tecrübe çizgileri; hedef çerçevesi (canavar/kişi); küçük harita (zemin 0,18 ölçek, noktalar, geçitler, Android çerçevesi) ve altı yuvarlak düğme; görev takibi; ejderha yürüme kolu ve turuncu küre; saldırı düğmesi (hedef kişiyse konuşma düğmesi) ve 7 kısayol yuvası (beceri simgesi, kilit, bekleme karartması, mana yetmezliği, iksir adedi); hedef değiştir düğmesi; mesaj kutusu (son 10 sn); bölge/bildirim/seviye duyuruları, hasar kızarması, ölüm karartması. Dokunma: HUD düğmeleri, yürüme kolu (sol alt bölgenin herhangi bir yeri), dünyaya dokunma (canavar: seç / ikinci dokunuş saldır; kişi: seç / ikinci dokunuş konuş).
- **Dünya**: arayüz olayları (HTML UI.float/log/toast/zone/levelUp/hurt) aynı yerlerde (`floats`, `log` renkli, `toast`…); hedef halkası ve ayak gölgesi kesirli konumda yumuşak elips; karakterin adı, portresi, kısayol yuvaları; iksir/yiyecek kullanma (`useItem`; kuşanma eşya adımında).
- **Pencereli oyun**: fare + dokunma (SDL parmak olayları), HTML tuşları (1-6, Q, E, Tab, boşluk). Konuşma ve görev pencereleri 7. adımda geldi; çanta, karakter, beceri, harita sonraki adımda.
- **Bulgular**: (1) tarayıcı `imageSmoothingQuality` varsayılanında ("low") küçültmede de düz çift doğrusal örnekler (ara boyut/mip yok) — C++ aynısını yapar; (2) en yakın komşuda tarayıcının seçtiği kaynak pikseline en yakın formül: hedef piksel merkezinden ölçeğe bölmek, tek duyarlıklı; (3) HTML hatası: killMob'da bir yorumun arkasında kalan öldürme sesi, altın sesi ve "X altın alındı" mesajı hiç çalışmıyordu (düzeltildi).

## Arayüz 2: pencereler, yol bulma, ölüm (7. adım)
- **`ui/forms`**: Android sürümünün ekran tanımları (`forms.json` + `forms2.json`, NEW_FORM_*; görseller `ui2/<kaynak>_<no>.png`). `Xf` dönüşümü: pencere 320 birim (konuşma ve ölüm 373) yüksekliğe göre tasarlanmış, ekran yüksekliğine ölçeklenir, görseller yumuşatılarak büyütülür. Denetim çizimi (döşeme görsel, dikdörtgen, dolgu, düğme yazısı), etiket/düğme/metin yazı kuralları, satır kırma ve HTML forms.js'teki 69 düğme çevirisi.
- **`ui/win`** (HTML win.js): ana menü (v5_menu; Karakter/Beceri/Çanta/Evcil/Görev/Harita/Sistem — şimdilik yalnız Görev açılır, ötekiler "yakında"), **konuşma** (uzun parşömen, ad, 5 satırlık sayfalar, seçenek satırları: görev al/bırak/teslim + ödül seçimi, yolculuk listesi 3'erli sayfa, sınıf yükseltme, ozan, ışınlanma, araba; dükkân ve evcil "yakında"), **görev listesi** (Aktif / Alınabilir, ayrıntı paneli, "Yol Bul" ve "Bırak" → onay kutusu), **ölüm** (deadselect: "Yeniden doğ: <yer>"), **onay kutusu** (dialog_yesno). Dokunma: en küçük isabet, çerçeve dışına dokunmak kapatır (ölüm penceresi hariç). `Hud` istekleri işler (konuşma, menü, görev), ölümden 1,2 sn sonra ölüm penceresini açar.
- **Yol bulma** (`engine/world_nav.cpp`, HTML world.js findPath + game.js): A* (4 yön, en çok 5000 adım; hedef geçilmezse 5 kare içindeki en yakın boş kare), yol izleme (yürüme kolu ya da başka iş yolu keser), **kişiye yürü** (varınca konuşur), **haritalar arası rota** (geçitler + yolculuk kenarları üzerinde genişlik öncelikli arama; her varışta 0,4 sn sonra sonraki adım; arabacı/ışınlayıcı gerekiyorsa ipucu), **görev "Yol Bul"** (questWalk: teslim kişisi, hedef haritası, en yakın hedef canavar ya da toplama noktası), kişinin/canavarın bulunduğu en yakın harita, yolculuk (ücret, araba), **yeniden doğma** (yarı can/mana; ev ya da bölgenin ilk haritası).
- **Harita geçişi ertelenir**: HTML'de gotoScene eşzamansız olduğu için geçide basılan kare eski haritada biter, yeni harita sonra yüklenir; C++ da geçişi karenin sonuna bırakır (aynı kare sayısı, aynı zar sırası).
- **Yazı atlası**: pencere yazıları yarım boylarda (ör. 10,5 px) çizildiği için boylar yarım adımlarla üretilir (B/Bb 7–18, H 9–20); 91 yüz. Harf çifti aralıkları yazı tipi başına em biriminde (her boyda aynı tablo).
- **Bulgular**: (1) pencere görselleri tarayıcıda yumuşatılarak büyütülüyor (oyun ekranında keskin); (2) görev listesinde "Alınabilir" sekmesindeki satırlar R2 7019 görseliyle çizilir.

## Ekransız test modu (`anrufen_test <senaryo.txt|->`)
Satır başına bir komut: `veri <klasör|paket.gdp>` · `tohum <sayı>` · `karakter <sınıf> <ırk> <cinsiyet>` (yeni karakter) · `seviye <n>` · `doldur` · `sahne <no> [x y]` · `konum <x> <y>` (denetimsiz) · `yon <0-3>` ·
`hedef <yakın|sıra>` · `savas <dt> <sn> <iz.json> [oto|beceri]` (sabit adım, her saniye iz satırı; oto: en yakın canavarı hedef al; beceri: oto + sırayla dönen hazır beceri) · `canavarlar <dosya|->` ·
`ust <0-2>` (sınıf yükseltmesi) · `beceriler <no=kademe,…|->` · `dagit <puan> <uzmanlık> [dosya]` (puanları oyuncu gibi dağıt) · `beceri <sıra>` · `zaman0` (yalnız oyun saati) ·
`olumsuz <0|1>` (GM) · `otogorev` · `arayuz <0|1>` · `yazi <0|1>` · `halka <0|1>` · `ad <ad>` · `portre <kod>` · `hedefle <sıra>` · `bekleme <beceri> <sn>` · `can <oran>` · `mana <oran>` · `gorevver <no>` · `gorevhazir <no> [sayı]` · `temizle` · `zemin <dosya>` · `gorevseviye <dosya> [ters]` · `gorevbot <adım> <dt> <iz.json>` (görev botu; kurallar cpp_gorev.js'te) · `gmbitir <no,…> <dosya>` (GM: görevleri bitir) ·
`pencere <ad|kapat> [varlık]` · `ciz` · `dokun <x> <y>` · `konus <varlık>` · `yol <sx> <sy> <tx> <ty> <dosya>` (A* yolu dosyaya eklenir) · `rotagecikme <sn>` · `kisiyeyuru <varlık>` · `gorevyuru <no>` · `ilerle <dt> <sn> <dosya.json>` (kareleri ilerlet; harita varışları, son yer, hedef, açılan konuşma) ·
`saat0` (zaman ve animasyon sayaçları 0) · `bekle <sn>` · `yuru <sag|sol|yukari|asagi|sag+yukari…> <sn>` (1/60 sn adımlar, tuşlar HTML'deki gibi) ·
`ekran <g> <y>` · `golge <0|1>` · `goruntu <dosya.png>` · `durum <dosya.json|->`. Ben (Claude) C++ sürümünü bununla çalıştırıp görüntüsüne bakarak denetlerim.

## HTML ile karşılaştırma (`node tools/test/cpp_karsilastir.js`, `cpp_savas.js`, `cpp_gorev.js`, `cpp_arayuz.js`, `cpp_pencere.js`, `cpp_yol.js`)
- `URL` verilmezse `www/` geçici bir statik sunucuyla açılır (çevrimdışı kip; oyun sunucusu gerekmez). HTML'de oyunun kendi çizim parçalarıyla aynı kare (640×360, zaman 0, canavarsız, gölgesiz, adsız) çizilir; C++ aynı senaryoyu çizer; `tools/test/goruntu_fark.py` piksel piksel karşılaştırır (kanal farkı > 3 = farklı; sınır %0,1). Yan yana + kırmızı farklar: `OUT/<ad>_fark.png`.
- Sahneler: Guanlin (iki yer), elf acemi kampı, Altındalga Limanı, Bozbalta Şehri, Ruh Arafı; üç sınıf, iki ırk, iki cinsiyet, dört yön. 18.11: 0 / 0 / 1 / 0 / 41 / 11 piksel.
- Yürüme: aynı kareden 6 tuş birleşimiyle 0,5 sn; konum, yön ve adım sayacı iki sürümde aynı.
- Canavarlar da çizilir (aynı tohum → aynı yerleşim): Güneşli Orman Kuzey'de 24 örümcek, 1 piksel fark.
- **`cpp_savas.js`**: 26 senaryo. 8'i yalnız normal saldırı (üç sınıf, iki ırk, Sv 9-88, sahne seviyesi 7-80; biri 24 canavarın ortasında ölüm); 18'i becerili: acemi ağacı (Sv 20-32), sınıf ağacı (45-70), 80'de altı uzmanlığın her biri (Sv 88 ve 120; 120'de 5.-6. kademe uzmanlık becerileri de açık). Becerili senaryolarda puanlar iki sürümde de oyuncu gibi dağıtılır ve dağılım ayrıca karşılaştırılır; savaşta her adımda sırayla dönen ilk hazır beceri kullanılır (38 etkin becerinin hepsi en az bir kez). Karşılaştırılan: canavar yerleşimi (ad, yer, yön, can, seviye, saldırı, savunma, gezinme) ve **her saniye** oyuncu canı/manası, seviye, deneyim, altın, yer, hedef ve canı, yaşayan canavar, canavarların toplam yeri ve canı, güçlendirmeler, ölüm, çanta. 18.11: 26/26 birebir aynı (toplam 25 dakika).
- **`cpp_gorev.js`**: (1) 945 görevin açılma seviyesi; (2) 4 görev botu (insan savaşçı, elf büyücü, insan rahip, elf savaşçı; 80 adım): başlangıç kampından başlar, herkesle konuşur (konuşma görevleri, teslim, yeni görev, ışınlanma), sonra teslim edilecek görevin kişisine, sürmekte olanın hedef haritasına (savaş en çok 90 sn, toplama, özel görev bayrağı, teslim eşyası "dükkândan almış gibi") ya da yeni görevin verenine gider; iş kalmayınca seviye kasar (60 sn). Haritalar arası ışınlanmayla; savaşta uzaktaki hedefin yanına konur; karakter ölümsüz (ekipman eşya adımında). Her adımdan sonra eylem, harita, seviye, deneyim, altın, yükseltme, çanta, görev sayaçları, bitmiş görevler, yer; sonda ~1500 kişinin baş işareti. (3) 6 sınıf yükseltme zinciri (40 ve 80) GM ile görev görev. 18.11: hepsi birebir aynı (botlar Sv 6'ya, 26-37 göreve varıyor; öldür, topla, konuş, teslim, özel, toplama noktası, ışınlanma).
- **`cpp_arayuz.js`**: oyun ekranı 3 durumda (orman: savaşçı, canavar hedefli, bekleme, iki görev; kasaba: elf rahibe, kişi hedefli → konuşma düğmesi, görev; büyücü 60: düşük can/mana, bütün yuvalar dolu). Yazısız piksel karşılaştırması 18.11: %0,87 / %1,09 / %1,18 (kalan: portrenin en yakın komşu küçültmesi, kenar yumuşatması); yazılı kareler yan yana göz denetimi (yazı yumuşatması farklı; yerler, boylar, dış çizgiler aynı).
- **`cpp_pencere.js`**: 8 durum: konuşma (muhtar), konuşmada görev satırı ve yeni görev, görev listesi (Aktif, Alınabilir + ayrıntı), ana menü, ölüm penceresi, "Bırak" onay kutusu. Her dokunuştan sonra iki sürümde de bir kare çizilir. Yazısız piksel 18.11: en kötü %1,84 (sınır %2; kalan: yumuşatılmış büyütmede kenar yuvarlaması); yazılı kareler yan yana.
- **`cpp_yol.js`**: (1) üç haritada 60 rastgele nokta çiftinin A* yolu (20'si yolsuz); (2) Guanlin'de uzak bir kişiye yürü → konuşma açılır; (3) "Domuz Avı"nın Yol Bul'u: geçitten domuzların haritasına, en yakın domuz hedeflenir; (4) görev hazırken Yol Bul: geri dönüp muhtarla konuşur. HTML'de harita yüklenirken kareler durur (setTimeout 400 için 0,5 sn beklenir); C++'ta `rotagecikme 0`. Karşılaştırılan: yollar, her varıştaki harita ve yer, son harita/yer/hedef/konuşma. 18.11: hepsi birebir aynı.
- **Efekt kareleri** (`cpp_karsilastir.js`): kılıç izi + kan, ateş topu uçarken, buz kırılması (10×50 px), Kutsal Işık (40×180 px), Gözdağı Totemi + zayıflatma haleleri, Büyü Kalkanı halesi, Büyü Hayali ve mermisi, Buz Novası: beceriden 9-30 kare sonra oyuncu, canavarlar ve efektler aynı karede. 18.11: en kötü %0,090 (totemin yıldırım ışığında tarayıcının ışık karıştırma yuvarlaması), ötekiler 1-6 piksel.
- **Bulgu (HTML kusuru):** tarayıcı yarı saydam pikselleri saklarken yuvarladığı için (önceden çarpılmış alfa) palet numarası kayıyor; alev, geçit, ışık gibi saydamlığı olan görseller HTML'de koyu benekli çıkıyor. C++ veriyi kayıpsız okuduğu için düzgün çiziyor (HTML'de düzeltmek PNG'yi elle çözmeyi gerektirir; usta kopyada bırakıldı). Karşılaştırmada C++ bu yuvarlamayı `ANRUFEN_TARAYICI_ALFA=1` ile taklit eder; taklit kapalıyken farkın tamamı bu (Guanlin 26, elf kampı 2666 piksel).
Kod düzeni: C++17, adlar İngilizce, yorumlar Türkçe; hata `godat::Error` istisnasıyla. Oyun sistemleri gelince GM kuralı aynen geçerli (her sistem GM komutuyla).

## godat
### Orijinal biçim (sy2dr2.6 / GODAT2.5 / APK'da 8 sıfır)
`[0,8)` imza · `[8,15)` sıfır · `[15,19)` kayıt sayısı · `[19,23)` dizin boyu (= sayı × 12) · her kayıt için `numara, konum, ad uzunluğu` (u32) + ad.
Dizin konuma göre sıralı değildir; kaydın sonu = dosyadaki bir sonraki başlangıç (ya da dosya sonu). Hiçbir dosyada aynı numara iki kez geçmez (346 dosya denetlendi).
Kayıt içeriği: `[tür=1, parça sayısı, sıkıştırılmış boy, ham boy]` + zlib; sonraki parçalar `[sıkıştırılmış boy, ham boy]` + zlib. Değilse (ya da açılamazsa) kayıt olduğu gibi kullanılır (`unpackOriginal`, Python `godat.unpack` ile aynı).

### Bizim paket biçimimiz (GODAT3.0)
`[0,8)` "GODAT3.0" · `[8,12)` bayraklar (1 şifreli, 2 zlib) · `[12,16)` kayıt sayısı · `[16,28)` tuz (her pakette rastgele) · `[28,32)` dizin boyu ·
dizin: "DIR1" + kayıt başına `numara, konum (veri bölgesine göre), boy, ham boy, CRC32` (u32) + ad uzunluğu (u16) + ad · veri bölgesi.
- Her kayıt zlib (düzey 9) ile sıkıştırılır, sonra ChaCha20 (RFC 8439) ile şifrelenir. Dizin de şifrelidir (kayıt adları okunmaz).
- Nonce: dizin = tuz; kayıt = tuzun ilk 4 baytı numarayla, 9. baytı 1 ile XOR (çakışmaz).
- Okurken: "DIR1" tutmazsa "anahtar yanlış ya da dosya bozuk"; kaydın boyu/CRC32'si tutmazsa "kayıt bozuk" (oynanmış dosya yakalanır). CRC kriptografik imza değildir; amaç bozulma ve basit kurcalamayı yakalamak.
- `--sifresiz` (`encrypt=false`): yalnız sıkıştırma, hata ayıklamak için.

### Katmanlı yama
`Packer::addArchive` sırayla eklenir; aynı numaralı kayıt sonraki arşivde varsa öncekinin yerine geçer (yerini korur), yeni numaralar sona eklenir.
Örnek: `godat_pack -o all_task.gdp kaynak/orijinal/all_task.godat yama_gorevler.godat` → orijinal görevler + bizim düzeltmelerimiz/yenilerimiz.
Güncellemede oyuncu yalnız yeni yama paketini indirir (oyun tarafındaki yükleme sırası 2. adımda).

### Anahtar
- Yayın anahtarı `native/anahtar.txt` (64 onaltılık karakter, **git dışı**, depoya konmaz; yedeğini kullanıcı saklar). CMake bunu `GODAT_RELEASE_KEY` olarak programa gömer.
- Dosya yoksa herkese açık geliştirme anahtarı kullanılır (testler bununla; araçlar "GELİŞTİRME anahtarı" diye uyarır).
- Anahtar programın içinde durduğu için kararlı biri çıkarabilir: şifreleme sıradan kopyalamayı ve kurcalamayı engeller, kesin koruma değildir.

## Araçlar ve testler
| Araç | İş |
|---|---|
| `native/build/godat_dump <dosya>` | Özet: kayıt başına numara, ad (onaltılık), açılmış boy, CRC32. `godat_dump <dosya> <numara> <çıktı>`: kaydı dosyaya yazar |
| `native/build/godat_pack [--sifresiz] -o <çıktı> <taban> [yama …]` | Bir ya da birkaç arşivi (orijinal ya da GODAT3.0) tek şifreli pakete yazar |
| `tools/godat_ozet.py <dosya>` | Aynı özetin Python karşılığı (`tools/godat.py` ile) |
| `native/build/test_godat` (`ctest`) | Birim testleri: ChaCha20 RFC 8439 resmî örneği, paket gidiş-dönüş, yama, yanlış anahtar/oynanmış kayıt, orijinal çok parçalı kayıt (22 denetim) |
| `native/build/test_motor` (`ctest`) | JSON, PNG gidiş-dönüş, tuval (ayna, saydamlık, ışık), zar üreteci = JS, JS yuvarlama/hypot, yön, Guanlin yükleme, yürüme, çizim, örümcek ormanında savaş (17 denetim) |
| `native/build/anrufen_test <senaryo>` | Ekransız test modu (yukarıda) |
| `node tools/test/cpp_savas.js` | C++ ↔ HTML canavar yerleşimi ve savaş izi (yukarıda) |
| `node tools/denge_cikar.js` | game.js → `www/assets/denge.json` (C++ denge verisi; game.js'te MON/XPT/sınıf değişince) |
| `node tools/gorev_cikar.js` | tr.js + quests_gen.js + game.js ödülleri → `www/assets/quests.json` (C++ görev verisi; görevler değişince) |
| `node tools/test/cpp_gorev.js` | C++ ↔ HTML görevler (yukarıda) |
| `python3 tools/yazi_atlasi.py` | yazı tipleri → `www/assets/fonts/atlas.json` + PNG (C++ yazısı) |
| `node tools/test/cpp_arayuz.js` | C++ ↔ HTML oyun ekranı (yukarıda) |
| `node tools/test/cpp_pencere.js` | C++ ↔ HTML pencereler (yukarıda) |
| `node tools/test/cpp_yol.js` | C++ ↔ HTML yol bulma, kişiye yürüme, görev rotası (yukarıda) |
| `node tools/test/cpp_karsilastir.js` | C++ ↔ HTML çizim ve yürüme karşılaştırması (yukarıda) |
| `python3 tools/test/godat_esitlik.py` | `kaynak/` altındaki 346 godat: C++ ile Python birebir aynı mı, paketleyip geri okuyunca içerik aynı mı. 18.11: 346/346 eşit, 24.427 kayıt; 29,5 MB → 29,2 MB |
