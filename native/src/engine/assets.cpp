#include "assets.h"

#include <algorithm>
#include <cmath>
#include <cstdlib>

namespace engine {

void Assets::load(const Vfs& vfs) {
  vfs_ = &vfs;
  D_ = core::Json::parse(vfs.readText("data.json"));
  ANI_ = core::Json::parse(vfs.readText("ani.json"));
  pal_ = vfs.read("pal.bin");
}

const core::Json* Assets::ani(const std::string& key) const {
  const core::Json& a = ANI_[key];
  return a.isObj() ? &a : nullptr;
}

const uint8_t* Assets::pal(const std::string& key) const {
  const core::Json& i = D_["palidx"][key];
  if (!i.isNum()) return nullptr;
  size_t off = size_t(i.i()) * 768;
  return off + 768 <= pal_.size() ? &pal_[off] : nullptr;
}

const core::Image* Assets::sheet(const std::string& file, int bmp, int palId) {
  const std::string sk = file + "_" + std::to_string(bmp), pk = palId ? file + "_" + std::to_string(palId) : sk, ck = sk + "|" + pk;
  auto it = sheets_.find(ck);
  if (it != sheets_.end()) return it->second.get();
  std::unique_ptr<core::Image> img;
  const std::string path = "sheets/" + sk + ".png";
  if (vfs_->exists(path)) {
    img = std::make_unique<core::Image>(core::decodePNG(vfs_->read(path))); img->canvas = true;   // HTML'de paletle boyanmış tuval
    // ANRUFEN_TARAYICI_ALFA=1: tarayıcının yarı saydam piksellerdeki yuvarlamasını taklit et (yalnız HTML karşılaştırma testi; docs/09)
    static const bool browserAlpha = std::getenv("ANRUFEN_TARAYICI_ALFA") != nullptr;
    if (browserAlpha) for (size_t i = 0; i < img->px.size(); i += 4) {
      uint8_t* d = &img->px[i]; const int A = d[3]; if (!A || A == 255) continue;
      const int p = (d[0] * A + 127) / 255; d[0] = uint8_t(std::min(255, (p * 255 + A / 2) / A));
    }
    const uint8_t* P = pal(pk); if (!P) P = pal(sk);
    if (P) for (size_t i = 0; i < img->px.size(); i += 4) {   // gri değer = palet numarası; palette macenta (255,0,255) saydam
      uint8_t* d = &img->px[i]; if (!d[3]) continue;
      const uint8_t* c = P + d[0] * 3; d[0] = c[0]; d[1] = c[1]; d[2] = c[2];
      if (d[0] == 255 && d[1] == 0 && d[2] == 255) d[3] = 0;
    }
  }
  const core::Image* raw = img.get();
  sheets_[ck] = std::move(img);   // olmayan sayfa da (nullptr) önbelleğe girer: her karede yeniden aranmaz
  return raw;
}

void drawParts(Canvas& c, const core::Json& A, int frame, const std::vector<const core::Image*>& sheets, int x, int y, bool mirror, float alpha, bool additive) {
  const core::Json& parts = A["f"][frame];
  for (const core::Json& p : parts.arr()) {
    const core::Json& m = A["m"][p[0].i()]; if (!m.isArr()) continue;
    const core::Image* S = sheets.size() > 1 ? (size_t(m[4].i()) < sheets.size() ? sheets[m[4].i()] : nullptr) : (sheets.empty() ? nullptr : sheets[0]);
    if (!S) continue;
    const int flags = p[1].i(), w = m[2].i(), h = m[3].i();
    bool flipX = flags & 1; const bool fv = flags & 2; int px = p[2].i(); const int py = p[3].i();
    if (mirror) { px = -px; flipX = !flipX; }
    const int left = flipX ? px - w : px, top = fv ? py - h : py;
    c.blit(*S, m[0].i(), m[1].i(), w, h, x + left, y + top, flipX, fv, alpha, additive);
  }
}

// ---------------- Sprite ----------------
Sprite::Sprite(Assets& as, const std::string& name) : as_(&as) {
  const core::Json& r = as.reg(name);
  if (!r.isArr()) return;
  r_ = &r; A_ = as.ani(r[0].str() + "_" + std::to_string(r[2].i()));
  ok_ = A_ != nullptr;
}

int Sprite::frameOf(int anim, double t) const {
  const core::Json& seq = (*A_)["a"][anim]; if (!seq.size()) return -1;
  int tot = 0; for (const core::Json& s : seq.arr()) tot += std::max(1, s[1].i());
  int k = int(std::floor(t)) % tot; if (k < 0) k += tot;
  for (const core::Json& s : seq.arr()) { k -= std::max(1, s[1].i()); if (k < 0) return s[0].i(); }
  return seq[0][0].i();
}

int Sprite::animLen(int anim) const {
  int n = 0; for (const core::Json& s : (*A_)["a"][anim].arr()) n += std::max(1, s[1].i());
  return n;
}

void Sprite::draw(Canvas& c, int anim, double t, int x, int y, bool mirror, float alpha) {
  if (!ok_) return;
  const core::Json& r = *r_;
  const core::Image* S = as_->sheet(r[0].str(), r[1].i(), r[3].i()); if (!S) return;
  const int f = frameOf(anim, t); if (f < 0) return;
  drawParts(c, *A_, f, {S}, x, y, mirror, alpha, glow);
}

void Sprite::drawScaled(Canvas& c, int anim, double t, float x, float y, float k, float alpha, bool smooth) {
  if (!ok_) return;
  const core::Json& r = *r_;
  const core::Image* S = as_->sheet(r[0].str(), r[1].i(), r[3].i()); if (!S) return;
  const int f = frameOf(anim, t); if (f < 0) return;
  for (const core::Json& p : (*A_)["f"][f].arr()) {
    const core::Json& m = (*A_)["m"][p[0].i()]; if (!m.isArr()) continue;
    const int flags = p[1].i(), w = m[2].i(), h = m[3].i(), px = p[2].i(), py = p[3].i(); const bool fx = flags & 1, fv = flags & 2;
    const int left = fx ? px - w : px, top = fv ? py - h : py;
    if (!fx && !fv) { c.drawImage(*S, float(m[0].i()), float(m[1].i()), float(w), float(h), x + left * k, y + top * k, w * k, h * k, alpha, smooth); continue; }
    core::Image part; part.w = w; part.h = h; part.px.resize(size_t(w) * h * 4); part.canvas = S->canvas;   // aynalı parça: aynalanmış kopyadan
    for (int yy = 0; yy < h; yy++) for (int xx = 0; xx < w; xx++) {
      const int sx = m[0].i() + (fx ? w - 1 - xx : xx), sy = m[1].i() + (fv ? h - 1 - yy : yy);
      if (sx < 0 || sy < 0 || sx >= S->w || sy >= S->h) continue;
      const uint8_t* q = S->at(sx, sy); uint8_t* d = part.at(xx, yy); for (int i = 0; i < 4; i++) d[i] = q[i];
    }
    c.drawImage(part, 0, 0, float(w), float(h), x + left * k, y + top * k, w * k, h * k, alpha, smooth);
  }
}

// ---------------- Paperdoll ----------------
void Paperdoll::set(Assets& as, const Look& look) {
  as_ = &as; layers_.clear();
  const core::Json& D = as.D();
  for (const char* act : {"comm", "town", "figh", "hors"}) {
    const std::string suf = std::string("_") + act + "_" + look.sex + "_" + look.race + "_" + look.cls;
    Layer lay;
    const core::Json& fr = D["frames"]["frame" + suf];
    if (fr.isNum()) lay.A = as.ani("frame_ani_" + std::to_string(fr.i()));
    auto pick = [&](const char* part, const std::string& gear) -> const core::Json* {
      if (!gear.empty()) { const core::Json& r = D["reg"][gear + "_" + part + suf]; if (r.isArr()) return &r; }
      const core::Json& r = D["reg"][std::string("default_") + part + suf];
      return r.isArr() ? &r : nullptr;
    };
    lay.L = {pick("body", look.bodyG), pick("head", look.headG), pick("weap", look.weapG), nullptr};   // 4. katman: kanat süsü (özel ekipmanla)
    layers_[act] = lay;
  }
}

int Paperdoll::animLen(const std::string& act, int anim) const {
  auto it = layers_.find(act); if (it == layers_.end() || !it->second.A) return 1;
  int n = 0; for (const core::Json& s : (*it->second.A)["a"][anim].arr()) n += std::max(1, s[1].i());
  return n;
}

void Paperdoll::draw(Canvas& c, const std::string& act, int anim, double t, int x, int y, float alpha) const {
  auto it = layers_.find(act); if (it == layers_.end() || !it->second.A) return;
  const Layer& lay = it->second; const core::Json& seq = (*lay.A)["a"][anim]; if (!seq.size()) return;
  int tot = 0; for (const core::Json& s : seq.arr()) tot += std::max(1, s[1].i());
  int k = int(std::floor(t)) % tot, f = seq[0][0].i();
  for (const core::Json& s : seq.arr()) { k -= std::max(1, s[1].i()); if (k < 0) { f = s[0].i(); break; } }
  std::vector<const core::Image*> sheets;
  for (const core::Json* r : lay.L) sheets.push_back(r ? as_->sheet((*r)[0].str(), (*r)[1].i(), (*r)[3].i()) : nullptr);
  drawParts(c, *lay.A, f, sheets, x, y, false, alpha);
}
void Paperdoll::drawScaled(Canvas& c, const std::string& act, int anim, double t, float x, float y, float k, bool smooth) const {
  auto it = layers_.find(act); if (it == layers_.end() || !it->second.A) return;
  const Layer& lay = it->second; const core::Json& A = *lay.A; const core::Json& seq = A["a"][anim]; if (!seq.size()) return;
  int tot = 0; for (const core::Json& s : seq.arr()) tot += std::max(1, s[1].i());
  int kk = int(std::floor(t)) % tot, f = seq[0][0].i();
  for (const core::Json& s : seq.arr()) { kk -= std::max(1, s[1].i()); if (kk < 0) { f = s[0].i(); break; } }
  std::vector<const core::Image*> sheets;
  for (const core::Json* r : lay.L) sheets.push_back(r ? as_->sheet((*r)[0].str(), (*r)[1].i(), (*r)[3].i()) : nullptr);
  for (const core::Json& p : A["f"][f].arr()) {
    const core::Json& m = A["m"][p[0].i()]; if (!m.isArr()) continue;
    const core::Image* S = sheets.size() > 1 ? (size_t(m[4].i()) < sheets.size() ? sheets[m[4].i()] : nullptr) : (sheets.empty() ? nullptr : sheets[0]);
    if (!S) continue;
    const int flags = p[1].i(), w = m[2].i(), h = m[3].i(), px = p[2].i(), py = p[3].i(); const bool fx = flags & 1, fv = flags & 2;
    const int left = fx ? px - w : px, top = fv ? py - h : py;
    if (!fx && !fv) { c.drawImage(*S, float(m[0].i()), float(m[1].i()), float(w), float(h), x + left * k, y + top * k, w * k, h * k, 1, smooth); continue; }
    core::Image part; part.w = w; part.h = h; part.px.resize(size_t(w) * h * 4); part.canvas = S->canvas;   // aynalı parça: aynalanmış kopyadan
    for (int yy = 0; yy < h; yy++) for (int xx = 0; xx < w; xx++) {
      const int sx = m[0].i() + (fx ? w - 1 - xx : xx), sy = m[1].i() + (fv ? h - 1 - yy : yy);
      if (sx < 0 || sy < 0 || sx >= S->w || sy >= S->h) continue;
      const uint8_t* q = S->at(sx, sy); uint8_t* d = part.at(xx, yy); for (int i = 0; i < 4; i++) d[i] = q[i];
    }
    c.drawImage(part, 0, 0, float(w), float(h), x + left * k, y + top * k, w * k, h * k, 1, smooth);
  }
}

}  // namespace engine
