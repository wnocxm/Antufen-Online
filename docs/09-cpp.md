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
3. Sistemler tek tek, her biri "aynı senaryo iki sürümde aynı sonuç" testiyle: savaş → beceri/efekt → görev → pencereler → eşya/dükkân → evcil → zindan → yolculuk → GM → ağ (mevcut sunucu).
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
  build/                  derleme çıktısı + build/veri/oyun.gdp (git dışı)
  anahtar.txt             yayın anahtarı (git dışı; yoksa geliştirme anahtarı)
```
```bash
cmake -S native -B native/build -G Ninja && cmake --build native/build && ctest --test-dir native/build
cmake --build native/build --target anrufen     # pencereli oyun (SDL2 burada derlenir, ~10 sn)
cmake --build native/build --target veri        # www/assets → build/veri/oyun.gdp (2955 dosya, 56 → 33 MB, şifreli)
```

## Motor (2. adım)
- **Çizim yazılımla** (`Canvas`, RGBA): her kare işlemcide çizilir, pencerede SDL dokusu olarak büyütülür (keskin piksel). Aynı kod ekransız testte PNG'ye yazar → test görüntüsü oyundakiyle aynıdır. 2D ve 640×360 mantıksal ekran için yeterince hızlı; gerekirse sonra GPU'ya taşınır.
- **Veri**: `Vfs` önce klasör (geliştirme: `www/assets`) ya da şifreli paket (`oyun.gdp`) bağlar; sonra bağlanan üstte (yama). Pakette her dosya bir kayıt (ad = yol, numara = `pathId` FNV-1a). Klasörden ve paketten okunan görüntüler bayt bayt aynı.
- **HTML karşılıkları** (aynı mantık, aynı sayılar): `assets.js` → `assets.cpp` (palet: gri değer = palet numarası, macenta saydam; `drawParts` ayna/çevirme kuralı; `Paperdoll` katmanları), `world.js` → `map.cpp` (zemin iki katman, düz nesneler önce), `game.js`/`ui.js` → `world.cpp` (giriş bölgesi, geçilmez karede kaçış, `snapScreen4`/`dirOf`, `moveEnt`, RUN 4,2, adım sayacı, kamera, derinlik sırası, kırpma sınırları). JS `Math.round` için `jsRound` (yarım yukarı).
- **Pencereli oyun** `anrufen [--veri <klasör|paket.gdp>] [--sahne <no>] [--sinif …] [--irk …] [--cinsiyet …]`: ok tuşları/WASD, F12 ekran görüntüsü, Esc. Burada yalnız sahte ekran sürücüsüyle (`SDL_VIDEODRIVER=dummy`) çalıştırılabildi; gerçek pencere kullanıcının bilgisayarında.
- **Kapsam (sırada)**: canavarlar, savaş, efektler, arayüz pencereleri, görevler … (yol haritası 3. adım). Ayak gölgesi çiziliyor; adlar/yazı tipi henüz yok.

## Ekransız test modu (`anrufen_test <senaryo.txt|->`)
Satır başına bir komut: `veri <klasör|paket.gdp>` · `karakter <sınıf> <ırk> <cinsiyet>` · `sahne <no> [x y]` · `konum <x> <y>` (denetimsiz) · `yon <0-3>` ·
`saat0` (zaman ve animasyon sayaçları 0) · `bekle <sn>` · `yuru <sag|sol|yukari|asagi|sag+yukari…> <sn>` (1/60 sn adımlar, tuşlar HTML'deki gibi) ·
`ekran <g> <y>` · `golge <0|1>` · `goruntu <dosya.png>` · `durum <dosya.json|->`. Ben (Claude) C++ sürümünü bununla çalıştırıp görüntüsüne bakarak denetlerim.

## HTML ile karşılaştırma (`node tools/test/cpp_karsilastir.js`)
- Sunucu açıkken (docs/06). HTML'de oyunun kendi çizim parçalarıyla aynı kare (640×360, zaman 0, canavarsız, gölgesiz, adsız) çizilir; C++ aynı senaryoyu çizer; `tools/test/goruntu_fark.py` piksel piksel karşılaştırır (kanal farkı > 3 = farklı; sınır %0,1). Yan yana + kırmızı farklar: `OUT/<ad>_fark.png`.
- Sahneler: Guanlin (iki yer), elf acemi kampı, Altındalga Limanı, Bozbalta Şehri, Ruh Arafı; üç sınıf, iki ırk, iki cinsiyet, dört yön. 18.11: 0 / 0 / 1 / 0 / 41 / 11 piksel.
- Yürüme: aynı kareden 6 tuş birleşimiyle 0,5 sn; konum, yön ve adım sayacı iki sürümde aynı.
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
| `native/build/test_motor` (`ctest`) | JSON, PNG gidiş-dönüş, tuval (ayna, saydamlık, ışık), yön, Guanlin yükleme, yürüme, çizim (12 denetim) |
| `native/build/anrufen_test <senaryo>` | Ekransız test modu (yukarıda) |
| `node tools/test/cpp_karsilastir.js` | C++ ↔ HTML çizim ve yürüme karşılaştırması (yukarıda) |
| `python3 tools/test/godat_esitlik.py` | `kaynak/` altındaki 346 godat: C++ ile Python birebir aynı mı, paketleyip geri okuyunca içerik aynı mı. 18.11: 346/346 eşit, 24.427 kayıt; 29,5 MB → 29,2 MB |
