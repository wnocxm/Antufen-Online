# 09 · C++ istemcisi (`native/`)

## Karar (18.11, kullanıcı)
- Oyun C++ ile devam eder: güçlü (akıcı, az bellek/pil), içerik şifreli paketlerde, sonradan yamalarla genişletilebilir; kullanıcı C++'ta kendini geliştirmek istiyor.
- Aynı depoda, ayrı klasörde (`native/`), adım adım. HTML sürümü (`www/`) **usta kopya**: yalnız hata düzeltmesi alır; C++ sürümünün karşılaştırma testlerinde referanstır.
- İçerik iki kez yazılmaz: veri hattı (Python araçları, `kaynak/ceviri`, üretilen veri dosyaları) ortak; C++ aynı verileri okur.
- **Eksik haritalar ve zindanlar C++ sürümünde tamamlanacak** (HTML'de eksik kalanlar: yanlış seviyeli sahneler, kahraman modları, 60+ zindanlar; docs/01, docs/04).
- Orijinal godat biçimi sürdürülür: orijinal dosyalar dokunulmadan kaynak kalır; bizim içeriğimiz aynı yapıda, şifreli GODAT3.0 paketlerine yazılır.
- Grafik kütüphanesi: SDL2 (kullanıcı onayı; kaynağı depoya eklenerek derlenecek — 2. adım).
- Sunucu değişmez (Node + PostgreSQL); C++ yalnız istemci. Hileye karşı asıl koruma sunucu tarafı denetimdir (şifreleme içeriği korur, sunucu oyunu korur).

## Yol haritası
1. **godat kütüphanesi ✔ (18.11)**: orijinal okuma, GODAT3.0 şifreli paket, katmanlı yama, araçlar, testler.
2. Motor iskeleti + test modu: SDL2 (depoda), pencere/ekransız çalışma, komut dosyasıyla girdi, durum dökümü, ekran görüntüsü; bir sahne + nesneler + karakter + yürüme. Kontrol: aynı sahnenin HTML ve C++ görüntüleri piksel karşılaştırması.
3. Sistemler tek tek, her biri "aynı senaryo iki sürümde aynı sonuç" testiyle: savaş → beceri/efekt → görev → pencereler → eşya/dükkân → evcil → zindan → yolculuk → GM → ağ (mevcut sunucu).
4. Paketleme: Android (GitHub otomatik derleme), iOS (Mac gerekir).

## Klasör ve derleme
```
native/
  CMakeLists.txt          derleme (C++17, zlib)
  src/godat/              godat.h/.cpp (arşiv, paketleyici), chacha20.h/.cpp (şifre)
  src/tools/              godat_dump.cpp, godat_pack.cpp (komut satırı araçları)
  tests/test_godat.cpp    birim testleri
  build/                  derleme çıktısı (git dışı)
  anahtar.txt             yayın anahtarı (git dışı; yoksa geliştirme anahtarı)
```
```bash
cmake -S native -B native/build -G Ninja && cmake --build native/build && ctest --test-dir native/build
```
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
| `python3 tools/test/godat_esitlik.py` | `kaynak/` altındaki 346 godat: C++ ile Python birebir aynı mı, paketleyip geri okuyunca içerik aynı mı. 18.11: 346/346 eşit, 24.427 kayıt; 29,5 MB → 29,2 MB |
