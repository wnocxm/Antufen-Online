#include "map.h"

#include <cmath>

namespace engine {

static std::vector<int> ints(const core::Json& j) { std::vector<int> v; v.reserve(j.size()); for (const core::Json& x : j.arr()) v.push_back(x.i()); return v; }

bool GameMap::blocked(double fx, double fy) const {
  const int x = int(jsRound(fx)), y = int(jsRound(fy));
  if (!inside(x, y)) return true;
  return b[size_t(y) * w + x] == 1;
}

Sprite* GameMap::sprite(const std::string& name) {
  auto& s = sprites_[name];
  if (!s) s = std::make_unique<Sprite>(*as_, name);
  return s.get();
}

void GameMap::load(Assets& as, const std::string& mapName) {
  as_ = &as; sprites_.clear(); objs.clear();
  const core::Json J = core::Json::parse(as.vfs().readText("maps/" + mapName + ".json"));
  w = J["w"].i(); h = J["h"].i();
  names.clear(); for (const core::Json& n : J["names"].arr()) names.push_back(n.str());
  regions.clear(); for (const core::Json& r : J["regions"].arr()) regions.push_back(ints(r));
  c = ints(J["c"]); t = ints(J["t"]); o = ints(J["o"]); a = ints(J["a"]); b = ints(J["b"]);
  OX = h * HW; pw = (w + h) * HW; ph = (w + h) * HH + TH;
  // zemin: her karede iki katman (düşük bayt / yüksek bayt): karo takımı (names'teki GROUND sırası + 1) ve takımdaki karo numarası
  ground.w = pw; ground.h = ph; ground.px.assign(size_t(pw) * ph * 4, 0);
  struct Set { const core::Image* S; int cols; };
  std::vector<Set> sets;
  for (const std::string& n : names) {
    Set s{nullptr, 0};
    if (n.rfind("GROUND", 0) == 0) { const core::Json& r = as.reg(n); if (r.isArr()) { s.S = as.sheet(r[0].str(), r[1].i(), r[3].i()); if (s.S) s.cols = s.S->w / TW; } }
    sets.push_back(s);
  }
  Canvas g; g.img = std::move(ground);
  for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
    const size_t i = size_t(y) * w + x; const int cc = c[i], tt = t[i];
    const int X = int(px(x, y)) - HW, Y = (x + y) * HH;
    for (int layer = 0; layer < 2; layer++) {
      const int s = layer ? cc >> 8 : cc & 255, tile = layer ? tt >> 8 : tt & 255;
      if (!s || size_t(s - 1) >= sets.size()) continue;
      const Set& G = sets[s - 1]; if (!G.S || !G.cols) continue;
      g.blit(*G.S, (tile % G.cols) * TW, (tile / G.cols) * TH, TW, TH, X, Y);
    }
  }
  ground = std::move(g.img);
  // nesneler; düz olanlar (büyü çemberi, tabela, ok, halı) her şeyin altında çizilir
  for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
    const size_t i = size_t(y) * w + x; const int oi = o[i]; if (!oi) continue;
    if (size_t(oi - 1) >= names.size()) continue;
    const std::string& nm = names[oi - 1]; if (nm.rfind("GROUND", 0) == 0) continue;
    Sprite* sp = sprite(nm); if (!sp->ok()) continue;
    auto has = [&](const char* s) { return nm.find(s) != std::string::npos; };
    const bool flat = has("魔法阵") || has("地标") || has("箭头") || has("地毯") || (has("阵") && !has("传送门"));
    objs.push_back({x, y, sp, a[i], x + y, int(px(x, y)), int(py(x, y)), flat});
  }
}

}  // namespace engine
