#include "font.h"

#include <algorithm>
#include <cmath>

#include "core/json.h"

namespace ui {

std::vector<uint32_t> utf8(const std::string& s) {
  std::vector<uint32_t> o;
  for (size_t i = 0; i < s.size();) {
    const uint8_t c = uint8_t(s[i]); uint32_t cp; int n;
    if (c < 0x80) { cp = c; n = 1; } else if ((c >> 5) == 6) { cp = c & 31; n = 2; } else if ((c >> 4) == 14) { cp = c & 15; n = 3; } else if ((c >> 3) == 30) { cp = c & 7; n = 4; } else { i++; continue; }
    if (i + n > s.size()) break;
    for (int k = 1; k < n; k++) cp = (cp << 6) | (uint8_t(s[i + k]) & 63);
    o.push_back(cp); i += n;
  }
  return o;
}

void Fonts::load(const engine::Vfs& vfs) {
  vfs_ = &vfs; faces_.clear(); byFam_.clear();
  if (!vfs.exists("fonts/atlas.json")) return;
  const core::Json J = core::Json::parse(vfs.readText("fonts/atlas.json"));
  for (const auto& kv : J["yuzler"].obj()) {
    Face f; f.key = kv.first; const core::Json& m = kv.second;
    f.size = float(m["size"].num()); f.asc = m["asc"].i(); f.desc = m["desc"].i(); f.png = m["png"].str();
    for (const auto& g : m["g"].obj()) { const core::Json& a = g.second; Glyph G{a[0].i(), a[1].i(), a[2].i(), a[3].i(), a[4].i(), a[5].i(), float(a[6].num())}; f.g[uint32_t(std::stoul(g.first))] = G; }
    for (const auto& k : m["k"].obj()) { const auto cp = utf8(k.first); if (cp.size() == 2) f.kern[(uint64_t(cp[0]) << 32) | cp[1]] = float(k.second.num()); }
    const std::string fam = kv.first.substr(0, kv.first.find('_'));
    byFam_[fam].push_back({f.size, kv.first});
    faces_[kv.first] = std::move(f);
  }
}

void Fonts::ensure(Face& f) {
  if (f.loaded) return;
  f.loaded = true;
  try { f.img = core::decodePNG(vfs_->read(f.png)); } catch (...) { f.img = core::Image(); }
}

Face* Fonts::face(const std::string& fam, float size) {
  auto it = byFam_.find(fam); if (it == byFam_.end()) { it = byFam_.find("B"); if (it == byFam_.end()) return nullptr; }
  const std::string* best = nullptr; float bd = 1e9f;
  for (const auto& p : it->second) { const float d = std::fabs(p.first - size); if (d < bd) { bd = d; best = &p.second; } }
  Face& f = faces_[*best]; ensure(f); return &f;
}

float Fonts::width(Face* f, const std::string& s) {
  if (!f) return 0;
  const auto cps = utf8(s); float w = 0;
  for (size_t i = 0; i < cps.size(); i++) {
    auto it = f->g.find(cps[i]); if (it != f->g.end()) w += it->second.adv;
    if (i + 1 < cps.size()) { auto k = f->kern.find((uint64_t(cps[i]) << 32) | cps[i + 1]); if (k != f->kern.end()) w += k->second; }
  }
  return w;
}

// Metin önce geçici bir örtü tamponuna dizilir (harfler atlastan; sığdırmada yatayda sıkışır), sonra dış çizgi (örtünün yuvarlak
// genişletilmesi) ve dolgu tuvale karıştırılır.
void Fonts::draw(engine::Canvas& c, Face* f, const std::string& s, float x, float y, const TextStyle& st) {
  if (!enabled || !f || s.empty() || f->img.empty()) return;
  const auto cps = utf8(s);
  float w = width(f, s); if (w <= 0) return;
  float sx = 1; if (st.maxWidth > 0 && w > st.maxWidth) { sx = st.maxWidth / w; }
  const float W = w * sx;
  const float left = st.align == CENTER ? x - W / 2 : st.align == RIGHT ? x - W : x;
  const float base = st.base == MIDDLE ? y + (f->asc - f->desc) / 2.f : st.base == TOP ? y + f->asc : y;
  const int pad = int(std::ceil(st.outline / 2)) + 2;
  const int bx = int(std::floor(left)) - pad, by = int(std::floor(base)) - f->asc - pad;
  const int bw = int(std::ceil(W)) + 2 * pad + 2, bh = f->asc + f->desc + 2 * pad + 2;
  std::vector<float> m(size_t(bw) * bh, 0.f);
  float pen = left;
  for (size_t i = 0; i < cps.size(); i++) {
    auto it = f->g.find(cps[i]); if (it == f->g.end()) continue;
    const Glyph& g = it->second;
    if (g.w && g.h) {
      const float gx = pen + g.ox * sx;   // harfin sol üstü (kesirli; en yakın piksele)
      const int ox = int(std::floor(gx + 0.5f)) - bx, oy = int(std::floor(base + 0.5f)) + g.oy - by;
      const int gw = std::max(1, int(std::lround(g.w * sx)));
      for (int yy = 0; yy < g.h; yy++) for (int xx = 0; xx < gw; xx++) {
        const int srcx = sx == 1 ? xx : std::min(g.w - 1, int((xx + 0.5f) / sx));
        const int X = ox + xx, Y = oy + yy; if (X < 0 || Y < 0 || X >= bw || Y >= bh) continue;
        const float v = f->img.at(g.x + srcx, g.y + yy)[0] / 255.f;
        float& d = m[size_t(Y) * bw + X]; d = std::min(1.f, d + v);
      }
    }
    pen += g.adv * sx;
    if (i + 1 < cps.size()) { auto k = f->kern.find((uint64_t(cps[i]) << 32) | cps[i + 1]); if (k != f->kern.end()) pen += k->second * sx; }
  }
  // yapay kalın: harf sağa doğru ~0,75 px kalınlaşır (tarayıcı kalını olmayan yazı tipinin çizgisini genişletir)
  if (st.fakeBold) for (int yy = 0; yy < bh; yy++) for (int xx = bw - 1; xx > 0; xx--) { float& d = m[size_t(yy) * bw + xx]; d = std::max(d, 0.75f * m[size_t(yy) * bw + xx - 1]); }
  // dış çizgi: çizgi kalınlığının yarısı kadar dışarı (yuvarlak), kenarda yumuşak
  if (st.outline > 0) {
    const float r = st.outline / 2; const int R = int(std::ceil(r + 0.5f));
    std::vector<std::pair<int, std::pair<int, float>>> off;   // (dx, (dy, ağırlık))
    for (int dy = -R; dy <= R; dy++) for (int dx = -R; dx <= R; dx++) { const float d = std::sqrt(float(dx * dx + dy * dy)); const float wgt = std::max(0.f, std::min(1.f, r + 0.5f - d + 0.5f)); if (wgt > 0) off.push_back({dx, {dy, wgt}}); }
    for (int yy = 0; yy < bh; yy++) for (int xx = 0; xx < bw; xx++) {
      float o = 0;
      for (const auto& p : off) { const int X = xx + p.first, Y = yy + p.second.first; if (X < 0 || Y < 0 || X >= bw || Y >= bh) continue; o = std::max(o, m[size_t(Y) * bw + X] * p.second.second); if (o >= 1) break; }
      if (o > 0) c.blend(bx + xx, by + yy, st.outlineColor, o * st.outlineAlpha * st.alpha);
    }
  }
  for (int yy = 0; yy < bh; yy++) for (int xx = 0; xx < bw; xx++) {
    const float v = m[size_t(yy) * bw + xx]; if (v <= 0) continue;
    uint32_t col = st.color;
    if (st.gradient) {   // dikey degrade
      const float t = std::max(0.f, std::min(1.f, (by + yy + 0.5f - st.gy0) / std::max(1e-3f, st.gy1 - st.gy0)));
      auto ch = [&](int sh) { const float a = float((st.color >> sh) & 255), b = float((st.color2 >> sh) & 255); return uint32_t(a + (b - a) * t + 0.5f) << sh; };
      col = ch(16) | ch(8) | ch(0);
    }
    c.blend(bx + xx, by + yy, col, v * st.alpha);
  }
}

}  // namespace ui
