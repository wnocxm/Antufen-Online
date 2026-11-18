# 08 · Değişiklik günlüğü (kısa)

Her commit'te buraya bir satır eklenir (tarih başlığı altında). Ayrıntı ilgili belgede; tam liste `git log`.

## 2026-11-09 · Temel
- Web istemcisi + Android/iOS (Capacitor) ayarları; Guanlin dükkânları ve orijinal ekipman; oyun ekranı orijinal düzende.
- Orijinal sesler, müzikler, beceri ağaçları; giriş ekranı; dosyalara sürüm numarası (önbellek).
- Orijinal ekran tanımları (UIFORM) çözüldü; çanta orijinal pencereyle.

## 2026-11-10 · Arayüz ve dil
- Türkçe + İngilizce. Karakter, NPC konuşması, görev listesi, ana menü, beceri ağacı, dükkân orijinal pencerelerle; göreve otomatik yürüme.

## 2026-11-13 · Savaş ve hareket
- Irka göre başlangıç, 4 yönlü hareket; savaş animasyonları ve efekt çözümü düzeltildi.
- Becerilerde orijinal değerler (10 kademe, bekleme süreleri); orijinal sayı ölçeğinde ilk denge; ölüm penceresi, karakter menüsü, dünya haritası.

## 2026-11-14 · Sunucu ve görevler
- Sağ altta yay biçimli beceri düzeni (HS = 1.1).
- Orijinal görev tablosundan ilk 50 görev; 3 elf haritası.
- Sunucu: PostgreSQL, hesap/karakter API, WebSocket ile haritadaki oyuncular ve sohbet, yönetim paneli; orijinal kapak ekranı.

## 2026-11-15 · Bütün dünya
- Orijinal paketin tamamı çıkarıldı (2555 görsel, 528 sahne…); bütün haritalar oyunda, geçitler bağlı.
- GM paneli (ışınlanma, seviye, ekipman, ölümsüzlük, hızlı koşu). APK kaynakları (3518 görsel, 12 müzik).
- Yeni arayüz (Android ekranları): kırmızı düğmeli menü, parşömen pencereler, HUD.
- Guanlin görev zinciri; görevlerin seviye şartı; NPC hedefleme ve konuşma düğmesi; eşyalar (70-90 silah/zırh, yiyecekler).

## 2026-11-16 · Efektler, görevler, denge, zindanlar, evcil hayvanlar
- Beceri efektleri APK efekt tablosuna göre (ışık olarak çizim); büyücü/rahip normal saldırısı orijinal.
- Ekrana dokunarak yürüme kaldırıldı; görevler SQL'e aktarılıyor.
- Görevler bölge bölge: Koşanat, Guanlin, Kâhin, Gözcü, Güneşgören, Karakol, Başkent, Dağgören, Yoğunsis, Sanatçılar, Liman, Akademi → 55'e kadar bölgeler tamam (801 görev).
- Belgeler: CLAUDE.md + docs/; test betikleri repoda.
- Haritalardaki bütün adlar çevrildi (1519).
- Denge 1. tur: bol kasma (kullanıcı kararı), seçkin canavar ve sınıf ayarları; görevler ırka göre (APK muhafız tablosundan harita tarafları).
- Zindan sistemi: 20 Sınav Ormanı, 30 Mehtap Korusu, 40 Ruhyiyen'in 4 zindanı, 50 dört Kule + Akankum; çok hedefli görevler; 28 zindan görevi.
- Evcil hayvanlar 1. aşama: 26 tür, kuluçka, savaş ve taktikler, bakım, Terbiyeci görevleri (14).
- GM paneline Zindanlar ve Evcil sekmeleri; kural: her yeni sistem GM komutuyla gelir; bu günlük açıldı.
- Evcil hayvanlar kaynak denetimi (ham kayıttan): 8 biçimli dönüşüm ağacı (renkler aslında 幻化 aşamaları), doğru doğuştan beceriler ve şablonlar, 1-3 rastgele beceri (kalıcı/hale/destek), dönüşüm ve beceri aktarma (orijinal `n_fantasize_pet` penceresi, Büyülü Canavar Ustası), sonraki resmî sürümün türleri (Kan Meleği, Gölge Kraliçe, Şan/Yemin Kılıcı, Ölü Feneri), mor Kıyıcı Ateş Tanrısı, Yeti görselleri düzeltildi; evcil yakın dövüş menzili 1,9.
- Hedef alma saldırıdan ayrıldı: ilk dokunuş seçer, ikinci dokunuş / saldırı düğmesi / beceri saldırır, yön tuşu saldırıyı bırakır; engelli karede takılan oyuncu yakınsa olduğu yerden vurur.
- Görev yol bulma akıllandı: alınan görevde hedef canavarın/nesnenin haritasına gider ve varınca saldırır, hazır görevde ödülü veren kişiye gider (önceden hep görevi veren NPC'ye dönüyordu).
- Görev yol bulma canavarın yanına götürür ve seçer, kendiliğinden saldırmaz.
- Görev denetimi (orijinal ham kayıt): APK görev tablosunun seviye/deneyim/zincir verisinin yanlış okunduğu bulundu; zincir 67 görevde, adet ve çok hedef 5 görevde düzeltildi; bütün görevlerde orijinal altın ve sınıfa göre ödül eşyası (77 eşya eklendi); görev penceresinde ödül satırı; denetim araçları (gorev_ham.py, gorev_denetim.js, gorev_seviye.js, odul.js).
- Deneyim sistemi (kullanıcı kararı "orijinal + %40 görev"): görevler orijinal deneyimi verir; seviye tablosu ve canavar deneyimi buna göre kuruldu (deneyim_tablosu.py). Görevler ~%40; seviye başına ~100 öldürme; 55'e kadar ~5.000 öldürme (eski ~7.400, çoğu 40 sonrası).

## 2026-11-17 · Hata düzeltmeleri
- Satın alırken adet girilebiliyor (her yığılabilen eşyada; sayı klavyesi / bilgisayarda rakamlar); satarken de adet. NPC'lerin içinden geçilebiliyor.
- Beceri ağaçları kaynak denetimi: her sınıfta acemi + sınıf + 2 uzmanlık ağacı (6'şar beceri), 40 ve 80'de sınıf yükseltme görevleri bulundu (henüz uygulanmadı).
- GM paneli İngilizcede tamamen İngilizce (sekme adları Maps/Dungeons/Pets, arama kutuları); sol menüde "Evcil" → "Pets", dükkân sekmesi "Dönüşüm" çevrildi.
- Sol menü sayfa gibi kayıyor (sürükleme / fare tekerleği); GM düğmesi Sistem penceresinden menünün en altına taşındı.
- 40. seviye sınıf yükseltmesi orijinal görevlerle (kullanıcı kararı: sınıf ağacı orijinal gibi yalnız bununla açılır): Acemilikten Çıkış (40'ta kendiliğinden), Ozan'da "Sınıf değiştirmek istiyorum!", her sınıf × ırk için orijinal zincir (iki eşyalı toplama, perinin iki seçenekli bitişi dahil), 40. seviye sınıf takımları ödül; Acemi Savaşçı/Çırak Büyücü/Acemi Kutsal Elçi adları; eski kayıtlarda sınıf ağacı puanı iade; GM paneline Sınıf sekmesi; sunucu listesinde sınıf.
- Harita seviyesi bulgusu: dosya adındaki sayı seviye değil; Gümüşkartal Avlusu (91-97 → 41-43), Kışla/Depo, Sınav Odası orijinal görev deneyiminden düzeltildi (kaynak/seviye_tahmin.json). Diğer yanlış seviyeli sahneler listelendi.
- Denge: sınıf ağacı 40'a çekilince rahip tabanı biraz güçlendirildi (seçkinde en çok ~%84 can); deneyim tablosu yeni görevlerle yeniden üretildi (görev payı %38,7).

## 2026-11-18 · Bütün beceri ağaçları
- Beceri penceresi APK'daki gibi: 6 sekme (acemi, sınıf, iki uzmanlık, ırk, Yaşam), kademeli 6 yuva, turuncu çizgiler, "Öğrenilmedi / Sv n", Puanları Sıfırla. Yüksek seviyeli ağaçlar da görünür (kullanıcı kararı: 55 sınırı içerik için, sistemler eksiksiz).
- Orijinal beceri verisi bulundu ve kullanıldı: kademe sabitleri (skill_const_2nd.lua), ön koşullar (5. kademe), ağaç puan şartları (sınıf ağacı: acemiye 35, uzmanlık: sınıfa 40), uzmanlıkların birbirini dışlaması; 76 beceri, Türkçe/İngilizce açıklamalar kademe değerleriyle.
- 24 uzmanlık becerisi ve 4 ırk becerisi çalışıyor (can emme, yansıtma, kanama, dönüşümler, totem, mana kalkanı…); 80'de ikinci sınıf yükseltmesi (Kara Şövalye / Başbüyücü / Seçilmiş).
- Eğitim Kitabı (puan sıfırlama) beceri eğitmenlerinde; Yaşam Elementi (elf ırk becerisi).
- Denge: orijinal sayılarla büyücü/rahip zayıfladı; sınıf vuruş çarpanları (1,25 / 1,7 / 1,75) ile 10-80 yeniden ölçüldü. GM Sınıf sekmesine ikinci yükseltme, bedava sıfırlama, ağaçları doldur.
- Beceri simgeleri kaynakla denetlendi: Symbian yolları ve APK tablosuyla 75/76 aynı, APK görüntüleriyle savaşçının 24 simgesi birebir; simgeler artık net (yumuşatmasız).
- Yazı tipleri: başlık/düğme/sol menü Metamorphous, gövde Alegreya (Türkçe harfli, oyunla birlikte gelir); sol menüdeki çift yazı (kaydırılmış gölge kopyası) kaldırıldı, tek kalem + dış çizgi; NPC konuşmasında seçili satır yazısı koyu.
- Beceri efektleri kaynakla birebir: kılıç izi her yönde kılıcın üstünde (dikey çevrik parçaların konumu + 8 yönlü efektlerde yön eşlemesi; iz saldırı hareketinin inişine denk); aynı düzeltmeyle Kan Büyü Çemberi, halılar ve Yargıç Kılıcı canavarları artık tam çiziliyor.
- Her becerinin efekti orijinal tabloya göre (APK efekt tablosu + Symbian beceri/buff kayıtları): efekt sayısı ve saçılması, güçlendirme süresince karakterde dönen görseller, canavarda yavaşlama/gözdağı/donma görselleri (buz kalıbı ilk kez görünüyor), İlahi Gözdağı totemi, yerde duran Şifa Pınarı, Büyü Hayali totemi; Alev Yakışı orijinaldeki gibi yakın menzilli tek hedef. GM Sınıf sekmesine "Kukla canavar" ve "Beklemesiz beceri"; test `tools/test/efekt.js`.
- 80. seviye ikinci sınıf yükseltmesi orijinal Bozbalta Şehri görevleriyle ("talent" görevleri tamam): Kara Şövalye, Büyük Büyü Üstadı (eski adı Başbüyücü), Seçilmiş; Ozan 80'de nereye gidileceğini söyler; düşen eşya, yerdeki sandık ve görev eşyası kullanma (Büyü Emici Küre) görev türleri; ödül 80 takımları + Eğitim Kitabı; Andecano tek kişilik boss. Eski taslak zincir (çılgın savaşçı, gölge büyücüsü) alınmadı.
- Yolculuk ağı: orijinal arabacılar (100 altın) ve ışınlayıcılar, 54 NPC 273 hedef (tools/seyahat.py); otomatik yol yürüyerek gidilemeyen yerlere yolculukla gider. GM: ücretsiz yolculuk, Bozbalta'ya git, 80 yap.
- **C++'a geçiş başladı** (kullanıcı kararı; docs/09-cpp.md): `native/` klasörü, CMake. 1. adım godat kütüphanesi: orijinal godat okuma (346 dosya, 24.427 kayıt Python'la birebir), şifreli GODAT3.0 paket (zlib + ChaCha20 + CRC32, şifreli dizin), katmanlı yama, `godat_dump` / `godat_pack` araçları, 22 birim testi, eşitlik testi. Eksik haritalar/zindanlar C++ sürümünde tamamlanacak.
- C++ 2. adım: SDL2 kaynağı depoda (2.30.9, ayıklanmış 23 MB); motor (PNG/JSON, veri paketi 56 → 33 MB şifreli, yazılımla çizim, palet, sprite, karakter katmanları, harita, sahne, NPC, kamera, 4 yönlü yürüme), pencereli oyun `anrufen`, ekransız test modu `anrufen_test`. HTML ile karşılaştırma: 6 sahne çizimi birebir (en kötü %0,018), 6 yönde yürüme aynı. Bulgu: HTML'de yarı saydam görseller (alev, geçit) tarayıcı yuvarlaması yüzünden benekli; C++'ta düzgün.
- C++ 3. adım (ilk parça): canavarlar ve temel savaş — ortak tohumlu zar (mulberry32), denge verisi (`denge.json` ← `tools/denge_cikar.js`), canavar tanımı/yerleşimi/yapay zekâsı, hasar, ıska, ölüm, deneyim, altın, iksir, ganimet, evcil yumurtası, efektler, haritalar arası geçiş; pencerede boşlukla saldırı. HTML ile karşılaştırma (`cpp_savas.js`): 8 senaryo, 8 dakika, her saniye birebir aynı; canavarlı çizim de aynı. HTML hatası düzeltildi: harita değişince bekleyen canavar darbeleri yeni haritada vuruyordu.
- C++ derleme: oyun derlenirken veri paketi de (www/assets'te bir dosya değişince ya da eklenince) kendiliğinden yeniden üretilir; eski paket "veri dosyası yok" hatası vermez.
- C++ 4. adım: beceriler ve efektler — 76 beceri (38 etkin, edilgenler, ırk) HTML ile aynı sırada ve sayılarla, güçlendirmeler, süren etkiler (kanama, yanma, çürüme), Büyü Hayali, saçılan efektler, haleler, totemler, ağaç kuralları ve puan dağıtma; pencerede 1-9 beceri tuşları, `--seviye/--uzmanlik`. HTML ile karşılaştırma: 26 savaş senaryosu (18'i becerili, altı uzmanlığın hepsi) her saniye birebir aynı; 8 efekt karesi görüntüde aynı (en kötü %0,09).
- HTML hataları düzeltildi: hız güçlendirmeleri (Hız Patlaması %25, Büyü Kalkanı'nın hız şansı) yuvarlamada 0'a iniyordu, artık hızlandırıyor; Büyü Hayali harita değişince eski haritanın canavarını hedeflemiyor.
- C++ 5. adım: görevler — `quests.json` (`tools/gorev_cikar.js`, 945 görev, iki dil), açılma seviyesi, görev durumu, alma, öldürme/toplama sayaçları, konuşma, toplama noktası, teslim ve ödüller, sınıf yükseltmesi, kendiliğinden görevler, ışınlanma, GM görev bitirme; pencerede E (konuş) ve Tab (hedef değiştir). HTML ile karşılaştırma (`cpp_gorev.js`): 945 açılma seviyesi, 4 görev botu × 80 adım ve 6 sınıf zinciri birebir aynı. C++'ta evcil yumurtası hatası bulundu ve düzeltildi (APK'ya özel türler listeye giriyordu).
- C++ 6. adım (arayüz 1. parça): yazı atlası (`tools/yazi_atlasi.py`, oyunun yazı tipleri), tuvale arayüz çizimi, oyun ekranı (adlar, işaretler, uçan sayılar, portre ve çubuklar, hedef, küçük harita, yuvarlak düğmeler, görev takibi, yürüme kolu, saldırı + beceri/iksir halkası, mesajlar, duyurular), fare/dokunma, iksir kullanma. HTML ile karşılaştırma (`cpp_arayuz.js`): yazısız %0,9-1,2 fark; yazılar yan yana aynı. HTML hatası düzeltildi: öldürme sesi ve "altın alındı" mesajı bir yorumun arkasında kalıp çalışmıyordu.
