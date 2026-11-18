# Üçüncü taraf kaynaklar (native/)

| Klasör | Sürüm | Kaynak | Lisans |
|---|---|---|---|
| `zlib/` | 1.3.1 | https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz (sha256 `9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23`) | zlib (`zlib/LICENSE`) |
| `SDL2/` | 2.30.9 | https://github.com/libsdl-org/SDL/releases/download/release-2.30.9/SDL2-2.30.9.tar.gz (sha256 `24b574f71c87a763f50704bbb630cbe38298d544a1f890f099a4696b1d6beba4`) | zlib (`SDL2/LICENSE.txt`) |

SDL2'den yalnız derleme için gerekenler alındı: `CMakeLists.txt`, `cmake/`, `include/`, `src/`, `wayland-protocols/`, `android-project/`, `build-scripts/`, `docs/`.
Ayrıca kök dizindeki `*.in` şablonları (CMake ister). Alınmayanlar (51 MB test verisi, Visual Studio / Xcode proje dosyaları, autotools): `test/`, `visualtest/`, `VisualC*/`, `Xcode*/`, `configure*`, `acinclude/`.
Güncellerken aynı listeyi yeni sürümden kopyala ve bu tabloyu güncelle.

zlib'den yalnız kütüphanenin C dosyaları ve başlıkları alındı (örnekler, testler, diğer platform klasörleri yok). Sistemde zlib varsa (Linux) o kullanılır;
yoksa (Windows, Android, iOS) ya da `-DANRUFEN_YEREL_ZLIB=ON` verilirse bu kopya derlenir (`native/CMakeLists.txt`).
