// Oyun varlıkları (HTML'de www/js/assets.js): data.json (kayıt tablosu, sahneler, NPC/canavar), ani.json (kare tanımları),
// pal.bin (paletler). Görsel sayfaları palet numaralı gri+alfa PNG'dir; palet burada uygulanır (aynı görselin renk çeşitleri).
#pragma once
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

#include "core/json.h"
#include "core/png.h"
#include "engine/canvas.h"
#include "engine/vfs.h"

namespace engine {

const int TICK = 14;   // animasyon karesi / saniye (HTML game.js TICK)

class Assets {
 public:
  void load(const Vfs& vfs);
  const core::Json& D() const { return D_; }
  const core::Json& reg(const std::string& name) const { return D_["reg"][name]; }
  const core::Json* ani(const std::string& key) const;   // ani.json["dosya_numara"]
  // paleti uygulanmış görsel sayfası (önbellekli); yoksa nullptr
  const core::Image* sheet(const std::string& file, int bmp, int palId);
  const Vfs& vfs() const { return *vfs_; }

 private:
  const Vfs* vfs_ = nullptr;
  core::Json D_, ANI_;
  std::vector<uint8_t> pal_;
  std::unordered_map<std::string, std::unique_ptr<core::Image>> sheets_;
  const uint8_t* pal(const std::string& key) const;
};

// Bir kareyi çiz: A = ani kaydı ({m: parçalar, f: kareler, a: animasyonlar}); her parça [modül, bayrak (1 yatay, 2 dikey ayna), x, y].
// Aynalı parçada x sağ kenarı, dikey çevrilmiş parçada y alt kenarı gösterir. Birden çok sayfa varsa modülün 5. değeri sayfa sırasıdır.
void drawParts(Canvas& c, const core::Json& A, int frame, const std::vector<const core::Image*>& sheets, int x, int y,
               bool mirror = false, float alpha = 1.f, bool additive = false);

// Kayıt adına göre sprite (NPC, canavar, nesne, efekt)
class Sprite {
 public:
  Sprite(Assets& as, const std::string& name);
  bool ok() const { return ok_; }
  bool glow = false;   // beceri efektleri: ışık olarak eklenir
  int animCount() const { return ok_ ? int((*A_)["a"].size()) : 0; }
  int frameOf(int anim, double t) const;   // -1: yok
  int animLen(int anim) const;
  void draw(Canvas& c, int anim, double t, int x, int y, bool mirror = false, float alpha = 1.f);
  const core::Json& A() const { return *A_; }

 private:
  Assets* as_; const core::Json* r_ = nullptr; const core::Json* A_ = nullptr; bool ok_ = false;
};

// Oyuncu görünümü (HTML look()): sınıf, ırk, cinsiyet ve ekipman görünümleri (boşsa varsayılan parça)
struct Look { std::string cls = "战士", race = "人类", sex = "male", bodyG, headG, weapG; };

// Oyuncu karakteri: gövde, kafa, silah (ve süs) katmanları ortak kare tanımıyla çizilir. Hareketler: comm, town, figh, hors.
class Paperdoll {
 public:
  void set(Assets& as, const Look& look);
  int animLen(const std::string& act, int anim) const;
  void draw(Canvas& c, const std::string& act, int anim, double t, int x, int y, float alpha = 1.f) const;

 private:
  struct Layer { const core::Json* A = nullptr; std::vector<const core::Json*> L; };
  Assets* as_ = nullptr;
  std::unordered_map<std::string, Layer> layers_;
};

}  // namespace engine
