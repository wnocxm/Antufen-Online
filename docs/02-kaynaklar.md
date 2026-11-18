# 02 · Kaynaklar: orijinal dosyalar, biçimler, araçlar

## Klasörler
| Yol | İçerik |
|---|---|
| `kaynak/orijinal/` | Symbian paketinin ham dosyaları (`.godat` arşivleri). Dokunma. |
| `kaynak/cikti/` | Çıkarılmış her şey: `gorsel/` (2555 PNG), `palet/`, `ses/`, `muzik/`, `form/`, `betik/`, `tablo/` (her tablonun kayıtları JSON), `metin/`, `cozulmus/` (sahneler, haritalar, animasyonlar, `kayit.json` görsel kayıt tablosu, `tablolar/anireg.json`, `tablolar/tasks.json` = Symbian görev metinleri) |
| `kaynak/apk/cikti/` | APK (`apk-test / 1028.apk`, Releases) çıkarımı: 3518 görsel, `metin/config/1000-1029.txt` tabloları |
| `kaynak/apk/ek/` | APK'dan alınan **resmî** görsel ekleri: `monster39.godat` (Ateş Devi turuncu/mor paletleri 6001/6002), `monster78.godat` (Gölge Kraliçe), `kayit.json` (kayıt adları). `tools/pack_all.py` Symbian'da eksik kayıtları buradan tamamlar. APK ekibinin değişiklikleri (`*.bak_*` yedeği olanlar, ör. `pet_res` paletleri, `monster81`) alınmaz. |
| `kaynak/apk/seviyeler.json` | Sahne → gerçek seviye aralığı (APK dünya haritası adlarından "(27-29级)") |
| `kaynak/cikti/betik/clt_script/skill_const_2nd.lua` | Orijinal istemci betiği (GBK): her becerinin kademe sabitleri `TABLE_SKILL_CONST[sn] = {ad = tablo}` (sonraki tanım öncekini ezer). `tools/beceriler.py` okur |
| `www/assets/skills.json` | Üretilen beceri ağaçları (`tools/beceriler.py` ← all_skilltree + all_skill + Lua + `kaynak/ceviri/beceriler.json`) |
| `kaynak/seviye_tahmin.json` | Dünya haritasında olmayan sahneler için orijinal görev deneyiminden tahmin edilen aralık (harita dosyası adındaki sayı seviye değildir) |
| `kaynak/apk/gecitler.json` | `sahne:kapı` → hedef sahne (APK geçit tablosu) |
| `kaynak/apk/efekt_beceriler.json` | APK `effect_data.godat` içindeki `skills.json`: her becerinin kendi/uçan/hedef efektleri |
| `kaynak/ceviri/gorevler/` | Görev çevirileri ve bölge kaynak dökümleri (bkz. 04) |
| `kaynak/index.html` | Tarayıcıdan gezilen katalog (`tools/katalog.py`) |

## APK config tabloları (`kaynak/apk/cikti/metin/config/`)
1001 görsel kayıt tablosu (ad → dosya, bmp, ani, palet) · 1002 geçitler · 1007 sahne verisi · 1010 canavarlar · 1013 eşyalar ·
1014 ekipman · 1015 dükkânlar · 1017 nitelik şablonları · 1019 beceriler (efekt adlarıyla) · 1020 beceri ağaçları ·
1025 görevler (yapı: veren/teslim NPC id, olaylar, ödüller, `nextTaskId`) · 1026 zincirler · 1029 dünya haritası yerleşimi.
Uyarılar: 1025'teki `level` alanı aslında öldürme adedi; APK görev dosyasını APK ekibi elle değiştirmiş ("reach" olayları ve bazı türler yanlış). Görev türü için Symbian kaydı esas alınır.

## Biçimler (kısa)
- **godat**: sihirli sözcük `sy2dr2.6` / `GODAT2.5` / APK'da sıfırlanmış; dizin her zaman ofsete göre sıralı değil; kayıt sonu = sonraki ofset. `tools/godat.py` (`named()`).
- **8 bit görsel**: palet ofset 36; bayrak 0 ham satırlar (4'e hizalı), 2 span-RLE, 1/3 çok kareli (kare boyutu 24/28'de), isteğe bağlı 2 baytlık indeks+alfa. APK varyantında span ofsetleri 0 = ardışık piksel. `tools/extract_all.py` (`decode8`, `image8`, `image16`).
- **16 bit** RGB565 görseller; **RIFF** paletler; **BE** sprite/animasyon tanımları (modül, kare parçaları, eylem dizileri).
- **UIFORM** ekranları: v4 `tools/forms3.py` ile; APK formları `tools/formlar.py` → `www/assets/forms2.json`.
- APK `config.godat` içindeki tür-4 zlib metin blokları → config txt'leri.
- APK `effect_data.godat`: başlık `EFDT`, sayı, uzunluk önekli adlar, sonra (ofset, sıkıştırılmış boy, ham boy) üçlüleri; zlib.

## Araçlar (`tools/`, depo kökünden çalıştır)
| Araç | Ne yapar |
|---|---|
| `extract_all.py [src out]` | Bütün godat'ları çıkarır (Symbian veya APK) |
| `apk_cikar.sh` | APK'yı indirir, `extract_all.py` ile `kaynak/apk/cikti`'ya çıkarır |
| `pack_all.py` | Oyun paketi: `www/assets/data.json` (528 sahne, geçitler, seviye aralıkları, NPC/canavar), `ani.json`, `pal.bin`, `sheets/`, `maps/` |
| `ceviri.py` | Sahne ve varlık adları → `www/js/tr_scenes.js` (görev dosyalarındaki `adlar` da eklenir) |
| `gorev_aktar.py <hub> <ad>` | Bir bölgenin görevlerini çözer → `kaynak/ceviri/gorevler/<ad>_kaynak.json` |
| `gorevler.py` | Elle yazılı + bölge çevirileri → `www/js/quests_gen.js` |
| `dunya.py` | Dünya haritası görselleri (`www/assets/wm/`) |
| `formlar.py` | APK arayüz formları → `forms2.json`, `ui2/` |
| `esyalar.py` | Eşya aktarımı → `www/assets/items.json` |
| `gorev_ham.py` | Symbian `all_task.godat` ham görev kaydı → `cozulmus/tablolar/gorev_ham.json` (zincir, adetler, altın, deneyim, sınıfa göre ödül eşyaları; APK 1025 bunları yanlış okur) |
| `odul_esyalari.py` | Görev ödülü olup `items.json`'da olmayan eşyaları ekler (mevcut değer merdiveninden) |
| `katalog.py` | `kaynak/index.html` |
| `test/*.js` | Playwright test betikleri (bkz. 06) |

## Önemli adlandırma eşlemeleri
Sınıflar: 战士 Savaşçı, 法师 Büyücü, 牧师 Kutsal Elçi. Irklar: 人类 İnsan, 夜精灵 Gece Elfi.
侏儒 = cüce (gnome), 矮人 = dağ cücesi (dwarf). 浓雾镇 = Yoğunsis Kasabası, 奔马城 = Koşanat Şehri, 望日城 = Güneşgören Şehri,
望山城 = Dağgören Şehri, 帝都 = İmparatorluk Başkenti, 金波港 = Altın Dalga Limanı, 银鹰城 = Gümüşkartal Şehri.
Ad çevirilerinin tamamı: `tools/ceviri.py` (B: sahneler, N: varlıklar) + `www/js/tr.js` (`TR.name`) + görev dosyalarının `adlar` bölümleri.
