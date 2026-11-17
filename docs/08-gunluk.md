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
