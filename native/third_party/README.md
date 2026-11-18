# Üçüncü taraf kaynaklar (native/)

| Klasör | Sürüm | Kaynak | Lisans |
|---|---|---|---|
| `SDL2/` | 2.30.9 | https://github.com/libsdl-org/SDL/releases/download/release-2.30.9/SDL2-2.30.9.tar.gz (sha256 `24b574f71c87a763f50704bbb630cbe38298d544a1f890f099a4696b1d6beba4`) | zlib (`SDL2/LICENSE.txt`) |

SDL2'den yalnız derleme için gerekenler alındı: `CMakeLists.txt`, `cmake/`, `include/`, `src/`, `wayland-protocols/`, `android-project/`, `build-scripts/`, `docs/`.
Ayrıca kök dizindeki `*.in` şablonları (CMake ister). Alınmayanlar (51 MB test verisi, Visual Studio / Xcode proje dosyaları, autotools): `test/`, `visualtest/`, `VisualC*/`, `Xcode*/`, `configure*`, `acinclude/`.
Güncellerken aynı listeyi yeni sürümden kopyala ve bu tabloyu güncelle.
