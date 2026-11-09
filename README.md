# Anrufen Online (yeniden yapım)

Eski Symbian sürümünün (QY_V5_full.sisx) dosyalarından çıkarılan **orijinal haritalar, karakterler,
canavarlar, efektler ve arayüz parçalarıyla** yapılmış, telefonda **yatay** oynanan sürüm.
Telif hakkı sahibi olduğunuzu belirttiniz; App Store ve Google Play'e gönderirken lisans belgelerinizi hazır tutun.

## Bilgisayarda denemek
```
npm run serve
```
Tarayıcıda http://localhost:8080 adresini açın (pencereyi yatay tutun).

Klavye: WASD/ok tuşları yürü, Boşluk saldır, 1-4 beceriler, Q/E iksirler, Tab hedef değiştir,
B çanta, C karakter, J görevler, M harita, Esc menüyü kapat.
Telefonda: sol altta parmağını kaydır (yürüme), sağ alttaki ejderha düğmesi saldırı, alt çubuk beceriler.

## Telefona kurmak
Gerekenler: Node.js; Android için Android Studio; iOS için Mac + Xcode.
```
npm install
npx cap add android
npm run android
```
```
npx cap add ios
npm run ios
```
Uygulamayı yalnızca yatay açmak için: Android'de `AndroidManifest.xml` içindeki ana aktiviteye
`android:screenOrientation="sensorLandscape"`, iOS'ta Xcode > General > Device Orientation'da yalnızca
Landscape Left/Right işaretli olsun.

## İçerik (şu an oynanabilir)
- Karakter oluşturma: Savaşçı / Büyücü / Kutsal Elçi, İnsan / Gece Elfi, kadın / erkek (orijinal yüzler ve giysiler)
- Acemi Kampı, Guanlin Kasabası, Güneşli Orman, Güneşli Orman Kuzey ve diğer çıkarılan haritalar; geçiş noktaları orijinal
- Orijinal NPC'ler ve yerleri, orijinal görev zinciri (Türkçeye çevrilmiş), canavarlar ve 4 yönlü animasyonlar
- Savaş, beceriler ve efektler, iksirler, seviye atlama, çanta, görev günlüğü, harita, otomatik kayıt

## Dosyalar
| Dosya | İçerik |
|---|---|
| `www/assets/` | Orijinal dosyalardan çıkarılan görseller (palet indeksli PNG), animasyon tanımları, haritalar |
| `www/js/assets.js` | Görsel yükleme, palet uygulama, sprite ve katmanlı karakter (gövde/kafa/silah) çizimi |
| `www/js/world.js` | İzometrik harita çizimi (42x22 karolar), engeller, yol bulma |
| `www/js/game.js` | Oyun mantığı: savaş, canavarlar, NPC'ler, görevler, eşyalar, kayıt |
| `www/js/tr.js` | Türkçe çeviriler: NPC adları, konuşmalar, görevler |
| `www/js/ui.js` | Arayüz, dokunmatik kontroller, menüler, ana döngü |
