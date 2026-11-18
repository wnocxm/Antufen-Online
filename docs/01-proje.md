# 01 · Proje: hedefler, kararlar, durum

## Hedef
Symbian (S60v5 / Symbian^3) MMORPG'si Anrufen Online'ı (契约OL) telefonlar için yeniden yapmak.
Web istemcisi (`www/`, Canvas2D) + Capacitor ile Android/iOS; Node + PostgreSQL sunucusu (`server/`).
Kullanıcı ileride Unity'ye taşımayı düşünüyor; bunu kendi bilgisayarında ayrıca yapacak. Burada web sürümüyle devam ediliyor.

## Kullanıcının verdiği kararlar (değiştirmeden önce sor)
- Dil: Türkçe ve İngilizce. Kullanıcıyla Türkçe konuşulur.
- Yatay ekran. Arayüz APK'daki (Symbian^3 tarzı) modern arayüz gibi: solda kırmızı düğme sütunu, parşömen pencereler.
- Hareket yalnızca **4 yön** (izometrik eksenler). **Ekrana dokununca yürüme yok**; yürüme yalnızca sol alttaki ejderha joystick'le. NPC/canavara dokunmak hedef alır.
- Hedef alınan NPC varken sağ alttaki büyük saldırı düğmesi **konuşma** düğmesine döner (orijinal görsel `ui2/talk_7004/7005.png`).
- Bir pencere (çanta vb.) açıkken oyun **durmaz**.
- Karakter ekipmansız başlar; silahsız karakter orijinal varsayılan silah görünümünü korur.
- Görev penceresi kabulden sonra kapanır. Görevler sırayla ve seviyeye göre açılır (bkz. `04-gorevler.md`).
- Sağ tarafta yay biçiminde beceri düğmeleri + büyük saldırı düğmesi; düğme ölçeği `HS = 1.1`. Koşu hızı artırılmış hâli korunur.
- GM hesabı: haritaları hızlı gezmek için (bkz. `03-istemci.md` › GM).
- Beceri görselleri orijinal efekt tablosuyla birebir: oyuncu/mermi/çarpma efektleri, sayı ve saçılma, süren güçlendirme/zayıflatma görselleri, çağrılan totemler (bkz. `03-istemci.md` › Beceriler ve efektler; test `tools/test/efekt.js`).
- **Çevrimdışı mod** sunucu kurulana kadar test için kalır; oyun çıkınca kaldırılacak (yalnızca hesapla giriş; bir ayar bayrağıyla).
- Kapsam: önce **55. seviyeye kadar** kusursuz; 70-80-90 sonra.
- **Görevler ırka göre ayrı** (orijinaldeki gibi). Taraf orijinal veriden: APK 1009 muhafız tablosundaki `camp` (1 = insan, 2 = gece elfi),
  muhafızsız şehirler komşu alanlardan; zindan ve savaş alanları ortak (`tools/taraf.py` → `kaynak/apk/taraflar.json`). Görevin ırkı = veren NPC'nin haritası.
  Sonuç: İnsan = Guanlin, Koşanat, Karakol, Başkent, Dağgören, Büyü Akademisi, Trol Ormanı; Gece Elfi = Kâhin Tapınağı, Gözcü, Güneşgören (+ lonca terasları, Dinlenme Bölgesi), Yoğunsis, Sanatçılar Loncası;
  ortak = Altındalga Limanı, Adalet Meydanı, lağım, zindanlar ve zindan merkezleri (ör. Ruhyiyen Sefer Karakolu, 40). Zindanlar eklenince görevleri kendiliğinden ortak olur.
- **Sınıf ağacı orijinal gibi** (17.11): 40'taki sınıf yükseltme görevinden önce açılmaz.
- **55 sınırı içerik içindir, sistemler için değil** (18.11): bütün çekirdek sistemler (beceri ağaçları, uzmanlıklar, meslekler…) eksiksiz olacak; yüksek seviyeli olanlar da görünür ve GM'den denenebilir. 55 sınırı görevleri, hataları ve oyun yönetimini ölçmek içindir; içerik açıldıkça test edilir.
- **Orijinal gibi bol kasma**: ilk ~16 seviye görevlerle; sonra deneyimin çoğu canavar kesmekten (1-55 ≈ 7-9 bin öldürme, ~20-25 saat).
- Müzik: APK'daki 12 kaydedilmiş parça kullanılıyor (Symbian MIDI'leri yanlış geldi).
- **C++'a geçiş (18.11):** oyun C++ ile sürer (güçlü, şifreli içerik, yamalarla genişleme; kullanıcı C++ öğreniyor). Aynı depoda `native/`, adım adım; HTML sürümü usta kopya (yalnız hata düzeltmesi, karşılaştırma testlerinin referansı). Orijinal godat biçimi sürdürülür (bizim içerik şifreli GODAT3.0 paketlerinde). Grafik: SDL2, kaynağı depoya eklenir. **Eksik haritalar ve zindanlar C++ sürümünde tamamlanacak.** Ayrıntı ve yol haritası: `docs/09-cpp.md`. C++ durumu (18.11): 1. godat ✔, 2. motor + test modu ✔, 3. canavarlar + savaş ✔, 4. beceriler + efektler ✔, 5. görevler ✔, 6. arayüz 1 (yazı + oyun ekranı + dokunma) ✔, 7. pencereler 1 (konuşma, görev listesi, ana menü, ölüm, onay) + yol bulma ve haritalar arası rota ✔, 8. pencereler 2 (karakter, çanta, beceri ağacı, dükkân, adet kutusu) + eşyalar ✔, 9. dünya haritası + ayarlar + NPC listesi ✔ — hepsi HTML ile karşılaştırmalı test edildi. Kullanıcı (18.11): bütün haritalar ve içerikleri (görevler, zindanlar) C++'ta tam gelecek, güzelleştirme sonra; 528 sahne ve 945 görev zaten ortak veriden yükleniyor. Sırada: zindanlar, evcil hayvanlar, kayıt + giriş ekranı + karakter oluşturma, ses, İngilizce, GM paneli, ağ, Android. Kullanıcı kararı (18.11): önce bütün C++ taşımaları bitecek, sunucu (VPS, alan adı, HTTPS) en son.

## Durum (son güncelleme: görevler 1. tur)
Tamam:
- Bütün orijinal dosyalar ve APK çıkarıldı; 528 sahne yükleniyor; geçit hedefleri APK tablosuyla düzeltildi.
- Motor, savaş, 3 sınıf (Savaşçı 战士, Büyücü 法师, Kutsal Elçi 牧师) becerileri ve orijinal efektleri.
- Yeni arayüz (karakter, çanta, beceri, görev, dükkân, sistem, dünya haritası), NPC hedefleme, konuşma düğmesi.
- 169 eşya, dükkânlar; GM araçları; otomatik yol (görev hedefine yürüme).
- Sunucu: hesap, karakter, kayıt, WebSocket'te aynı haritadaki oyuncular ve sohbet; görevler de SQL'de.
- Görevler (oyunda 801, SQL'de 832 satır): Acemi kampları, Guanlin, Koşanat Şehri, Kâhin Tapınağı, Gözcü Kampı, Güneşgören Şehri (+Dinlenme Bölgesi, lonca terasları), İstihbarat Karakolu, İmparatorluk Başkenti çevresi, Dağgören Şehri, Yoğunsis Kasabası, Sanatçılar Loncası, Altındalga Limanı, Büyü Akademisi. **55'e kadar bütün bölgelerin hikâye görevleri alındı.**

**Görev denetimi (16.11):** ödül, zincir ve adet orijinale çekildi (docs/04 › Orijinal kaynak).
- **Deneyim (kullanıcı kararı):** görev deneyimi orijinal. Seviye tablosu ve canavar deneyimi buna göre kuruldu; görevler ~%40, canavarlar ~%60 (docs/03 › Deneyim sistemi).
- Görevlerin açılma seviyesi orijinal veride yok; tahmin olarak kalıyor.

Sırada (kullanıcı onayladı):
0. **Zindan sistemi** ✔ (tek kişi; grup girişi çevrimiçi grup sistemiyle sonra): 20 Sınav Ormanı, 30 Mehtap Korusu, 40 Ruhyiyen'in 4 zindanı, 50 dört Kule + Akankum Limanı; 28 zindan görevi. Kalan: kahraman (zor) modları, Tozçamur Madeni (60 bölgesiyle). Ajan Hans (代理人汉斯, 831xx) görevleri APK eklemesi, alınmaz.
0b. **Evcil hayvanlar (魔法兽)** (bkz. `docs/07-evcil.md`):
  - 1. aşama ✔.
  - 2. aşama ✔ (16.11): kaynak denetimi, 8 biçimli dönüşüm ağacı, doğru beceriler, rastgele beceriler, dönüşüm, beceri aktarma, Kan Meleği / Gölge Kraliçe / Şan-Yemin Kılıcı / Ölü Feneri / mor Ateş Devi.
  - Sırada: yetenek-kişilik-ömür; Usta'nın görevleri (80070/80071, 80259/80408/80414); çevrimiçi çiftleştirme ve pazar.
1. Denge 1. tur yapıldı (bkz. 03 › Denge). Kalan: insan yolunda 40-48 arası görev yok (yalnız kasma; büyük olasılıkla orijinalde 40. seviye ortak zindanlarla doluyordu); eşyalar (bölgelere göre), elle oynanış testi. (Harita adları ve sahnelerdeki 1519 NPC/canavar/nesne adı çevrildi.)

Ertelenenler / bilinenler:
- **40. seviye sınıf yükseltmesi ✔ (17.11)**: orijinal görevlerle; sınıf ağacı yalnız bununla açılır (kullanıcı kararı: orijinal gibi).
- **Bütün beceri ağaçları ✔ (18.11)**: acemi, sınıf, iki uzmanlık, ırk, Yaşam sekmesi; orijinal kurallar, sayılar ve açıklamalar (docs/03 › Beceri ağaçları). Uzmanlıklar 80'deki ikinci yükseltmeyle: **Bozbalta Şehri görevleri ✔ (18.11, kullanıcı: "talent görevleri tamam, bir daha dönmeyelim")** — Kara Şövalye / Büyük Büyü Üstadı / Seçilmiş; yolculuk ağı (arabacılar, ışınlayıcılar) ile ulaşılır.
- Sırada: **yaşam becerileri sistemi** (madencilik, arkeoloji, mücevher arıtma, parçalama: eğitmenden öğrenme, 120 toplama noktası, malzemeler); unvan, mücevher/tarif.
- Harita seviyeleri: dosya adındaki sayı seviye değil; dünya haritasında olmayan bazı sahneler yanlış seviyede (docs/04 › Sınıf yükseltme › Seviye bulgusu). Sırada önerilen: bu sahneleri düzeltip 55 altına düşen görevlerini almak.
- Zindan, binek ve çok hedefli görevler alınmadı.
- Sunucu için VPS + alan adı + HTTPS gerekiyor (kullanıcı hazır olunca).
