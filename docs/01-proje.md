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
- Beceri görselleri orijinal efekt tablosuyla birebir (bkz. `03-istemci.md` › Efektler).
- **Çevrimdışı mod** sunucu kurulana kadar test için kalır; oyun çıkınca kaldırılacak (yalnızca hesapla giriş; bir ayar bayrağıyla).
- Kapsam: önce **55. seviyeye kadar** kusursuz; 70-80-90 sonra.
- **Görevler ırka göre ayrı** (orijinaldeki gibi): İnsan = Guanlin, Koşanat, Karakol, Başkent, Dağgören (+ Trol Ormanı, Karanlık Gözcü Kulesi);
  Gece Elfi = Kâhin Tapınağı, Gözcü Kampı, Güneşgören, Yoğunsis, Sanatçılar Loncası; ortak = Altındalga Limanı, Büyü Akademisi.
- **Orijinal gibi bol kasma**: ilk ~16 seviye görevlerle; sonra deneyimin çoğu canavar kesmekten (1-55 ≈ 7-9 bin öldürme, ~20-25 saat).
- Müzik: APK'daki 12 kaydedilmiş parça kullanılıyor (Symbian MIDI'leri yanlış geldi).

## Durum (son güncelleme: görevler 1. tur)
Tamam:
- Bütün orijinal dosyalar ve APK çıkarıldı; 528 sahne yükleniyor; geçit hedefleri APK tablosuyla düzeltildi.
- Motor, savaş, 3 sınıf (Savaşçı 战士, Büyücü 法师, Kutsal Elçi 牧师) becerileri ve orijinal efektleri.
- Yeni arayüz (karakter, çanta, beceri, görev, dükkân, sistem, dünya haritası), NPC hedefleme, konuşma düğmesi.
- 169 eşya, dükkânlar; GM araçları; otomatik yol (görev hedefine yürüme).
- Sunucu: hesap, karakter, kayıt, WebSocket'te aynı haritadaki oyuncular ve sohbet; görevler de SQL'de.
- Görevler (oyunda 801, SQL'de 832 satır): Acemi kampları, Guanlin, Koşanat Şehri, Kâhin Tapınağı, Gözcü Kampı, Güneşgören Şehri (+Dinlenme Bölgesi, lonca terasları), İstihbarat Karakolu, İmparatorluk Başkenti çevresi, Dağgören Şehri, Yoğunsis Kasabası, Sanatçılar Loncası, Altındalga Limanı, Büyü Akademisi. **55'e kadar bütün bölgelerin hikâye görevleri alındı.**

Sırada (bölge sırası seviyeye göre):
1. Denge 1. tur yapıldı (bkz. 03 › Denge). Kalan: insan yolunda 40-48 arası görev yok (yalnız kasma); eşyalar (bölgelere göre), elle oynanış testi. (Harita adları ve sahnelerdeki 1519 NPC/canavar/nesne adı çevrildi.)

Ertelenenler / bilinenler:
- 6 ileri beceri ağacı, ırk becerileri, 40. seviye sınıf yükselmesi, mücevher/tarif/unvan/evcil hayvan yok.
- Zindan, binek ve çok hedefli görevler alınmadı.
- Sunucu için VPS + alan adı + HTTPS gerekiyor (kullanıcı hazır olunca).
