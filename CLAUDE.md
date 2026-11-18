# Anrufen Online (契约OL) yeniden yapımı — çalışma rehberi

Symbian MMORPG'si **Anrufen Online / 契约OL**'un Android/iOS için web (Canvas2D + Capacitor) yeniden yapımı.
Kullanıcı hakların kendisinde olduğunu söyledi. **Kullanıcıyla Türkçe, sade dille konuş.**
Hedef: orijinale olabildiğince sadık (orijinal görseller, arayüz, mekanikler, metinler), yatay ekran, Türkçe + İngilizce.

Bu dosya ve `docs/` klasörü, konuşmanın tamamını okumadan işe devam edebilmek içindir.
Bir konuya girmeden önce ilgili belgeyi oku; bir sistemi değiştirince belgesini de güncelle.

| Belge | İçerik |
|---|---|
| `docs/01-proje.md` | Hedefler, kullanıcının verdiği kararlar, şu anki durum, sıradaki işler |
| `docs/02-kaynaklar.md` | Orijinal dosya biçimleri, çıkarma araçları, nerede ne var (Symbian + APK) |
| `docs/03-istemci.md` | Oyun istemcisi: dosyalar, motor, savaş, beceri/efekt, eşya, arayüz, GM, ses, dil, kayıt |
| `docs/04-gorevler.md` | Görev sistemi ve bölge bölge görev ekleme yöntemi (adım adım) |
| `docs/05-sunucu.md` | Node + PostgreSQL sunucusu, tablolar, API, çevrimiçi oyun |
| `docs/07-evcil.md` | Evcil hayvanlar: kaynaklar, aşamalar, nasıl çalışıyor |
| `docs/08-gunluk.md` | **Değişiklik günlüğü**: tarih tarih kısa özet (her commit'te bir satır) |
| `docs/06-test.md` | Yerel çalıştırma, Playwright test betikleri (`tools/test/`), sık hatalar |
| `docs/09-cpp.md` | **C++ istemcisi** (`native/`): karar, yol haritası, derleme, godat biçimleri, şifreli paket, anahtar, araçlar |

## Her işte uyulacak kurallar

- **Yayınlama:** GitHub Pages depo kökünü sunar; `index.html` → `www/`. Her değişiklikten sonra sürümü artır, commit et, `main`'e push et (PR açma, kullanıcı istemedikçe).
  ```bash
  V=$(date -u +%m%d%H%M); sed -i -E "s/\?v=[0-9]{8}/?v=$V/g; s/(Sürüm[^0-9]*)[0-9]{8}/\1$V/" www/index.html www/js/ui.js
  git add -A && git commit -q -F - <<EOF … EOF && git push -q origin main
  ```
  Commit mesajı Türkçe; sonunda sistemin verdiği `Co-Authored-By` ve `Claude-Session` satırları.
  Durdurma kancası commit edilmemiş/izlenmeyen dosya varsa uyarır: her işi commit + push ile bitir.
- **Her yeni sistem GM komutuyla gelir** (kullanıcı isteği): modülde `GM` nesnesi, GM panelinde sekme/düğme, `tools/test/gm.js`'e adım; `docs/03-istemci.md` › GM'ye yazılır.
- **Belgeler her işte güncellenir**: değişen sistemin belgesi + `docs/08-gunluk.md`'ye (bugünün tarihi altında) bir satır + gerekirse `docs/01-proje.md` durum/sırada.
- **Üretilen dosyaları elle düzenleme:** `www/js/quests_gen.js` (`tools/gorevler.py`), `www/js/tr_scenes.js` (`tools/ceviri.py`), `www/assets/data.json` (`tools/pack_all.py`), `www/assets/skills.json` (`tools/beceriler.py`; çeviri `kaynak/ceviri/beceriler.json`), `www/assets/travel.json` (`tools/seyahat.py`).
- **Çeviriler** `kaynak/ceviri/gorevler/<bölge>.json` içindedir (görev metinleri + o bölgenin yeni NPC/canavar adları).
- **Kapsam:** Şu an 55. seviyeye kadar her şey "kusursuz" olacak. 70-80-90 sonra. 55 üstü görevler `atla` ile dışarıda bırakılır.
- **APK kullanımı:** APK'dan orijinal görsel ve veri alınır; APK ekibinin Unity kodu, sunucu adresi, yönetici araçları alınmaz.
- Yerel testten önce: `service postgresql start`, sunucu `cd server && PORT=8099 DATABASE_URL=postgres://anrufen:anrufen_dev@localhost:5432/anrufen node server.js` (arka planda). Ayrıntı `docs/06-test.md`.
- `rm` ile göreli joker kullanma (güvenlik denetimi engeller).
- **C++ geçişi (18.11):** yeni iş `native/` (C++17) içinde yapılır; `www/` HTML sürümü usta kopyadır, yalnız hata düzeltmesi alır. Eksik haritalar/zindanlar C++ sürümünde tamamlanır.
  Derleme ve test: `cmake -S native -B native/build -G Ninja && cmake --build native/build && ctest --test-dir native/build`; `python3 tools/test/godat_esitlik.py`;
  ekransız test modu `native/build/anrufen_test <senaryo>`; HTML ile karşılaştırma `node tools/test/cpp_karsilastir.js` (sunucu açıkken). Her taşınan sistem bu karşılaştırmayla doğrulanır.
  `native/anahtar.txt` (yayın anahtarı) asla commit edilmez.
