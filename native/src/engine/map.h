// Orijinal haritalar (HTML'de www/js/world.js): 42×22 piksellik baklava karolar. Zemin tek görsele önceden çizilir;
// nesneler ayrı listede derinliğe (x + y) göre çizilir. Harita dosyası maps/<ad>.json: w, h, names, regions, c, t, o, a, b.
#pragma once
#include <cmath>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

#include "core/png.h"
#include "engine/assets.h"

namespace engine {

const int TW = 42, TH = 22, HW = 21, HH = 11;

struct MapObj { int x, y; Sprite* sp; int anim; int depth; int X, Y; bool flat; };

class GameMap {
 public:
  void load(Assets& as, const std::string& mapName);
  int w = 0, h = 0, OX = 0, pw = 0, ph = 0;
  std::vector<std::string> names;
  std::vector<std::vector<int>> regions;   // [numara, tür, x0, y0, x1, y1] (tür 0 giriş, 1 geçit …)
  std::vector<int> c, t, o, a, b;
  core::Image ground;
  std::vector<MapObj> objs;

  double px(double x, double y) const { return OX + (x - y) * HW; }
  double py(double x, double y) const { return (x + y) * HH + HH; }
  bool inside(int x, int y) const { return x >= 0 && y >= 0 && x < w && y < h; }
  bool blocked(double fx, double fy) const;
  Sprite* sprite(const std::string& name);

 private:
  Assets* as_ = nullptr;
  std::unordered_map<std::string, std::unique_ptr<Sprite>> sprites_;
};

// JavaScript Math.round (yarım yukarı): C++ std::round eksi yarımda farklı yuvarlar
inline double jsRound(double v) { return std::floor(v + 0.5); }

}  // namespace engine
