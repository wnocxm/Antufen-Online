# Kaynak dosyalar

Orijinal oyun paketinin tamamı ve ondan çıkarılan her şey burada durur.

| Klasör | İçerik |
|---|---|
| `orijinal/` | Paketten çıkan ham dosyalar (`.godat` arşivleri, program dosyaları). Hiçbir şey değiştirilmedi. |
| `cikti/gorsel/` | Bütün görseller, kaynak dosyasına göre klasörlenmiş PNG olarak |
| `cikti/palet/` | Renk paletleri (canavar ve ekipman renk çeşitleri) |
| `cikti/muzik/`, `cikti/ses/` | Müzikler (MIDI) ve ses efektleri (WAV) |
| `cikti/form/`, `cikti/betik/` | Ekran tanımları ve Lua betikleri |
| `cikti/tablo/`, `cikti/metin/` | Oyun tabloları (kayıt numarası + metinler) ve metin dosyaları |
| `cikti/cozulmus/` | Çözülmüş oyun verisi: sahneler, haritalar, animasyonlar, görsel kayıt tablosu |
| `cikti/onizleme/` | Haritaların küçük resimleri |
| `index.html` | Katalog: her şeye tarayıcıdan göz at, müzikleri ve sesleri dinle |

Yeniden çıkarmak için depo kökünden:

```bash
python3 tools/extract_all.py
python3 tools/katalog.py
```

## Android sürümü (APK)

`apk/cikti/` klasöründe, deponun Releases bölümündeki APK'nın (`apk-test / 1028.apk`) içindeki oyun kaynaklarının çıkarılmış hali durur: yüksek çözünürlüklü arayüz ve harita resimleri, 12 müziğin tamamı, ek ses efektleri ve çözülmüş oyun tabloları (`metin/config/`: görevler, canavarlar, NPC'ler, geçit hedefleri, dünya haritası yerleşimi, dükkânlar). Yeniden çıkarmak için:

```bash
sh tools/apk_cikar.sh
```
