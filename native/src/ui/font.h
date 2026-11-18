// Yazı: tools/yazi_atlasi.py'nin ürettiği harf atlaslarından (www/assets/fonts/atlas.json + PNG) yazar. HTML'deki fillText/strokeText
// karşılığı: hizalama (sol, orta, sağ), taban çizgisi (alfabetik, orta, üst), dış çizgi (strokeText, yuvarlak köşe), sığdırma (maxWidth),
// dikey degrade dolgu (orijinal yuvarlak düğme harfleri). Yüzler: B gövde (Alegreya), Bb gövde kalın, H başlık (Metamorphous),
// S büyük duyurular (serif kalın), N/Nb sans-serif. İstenen boy yoksa en yakını.
#pragma once
#include <cstdint>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

#include "core/png.h"
#include "engine/canvas.h"
#include "engine/vfs.h"

namespace ui {

struct Glyph { int x = 0, y = 0, w = 0, h = 0, ox = 0, oy = 0; float adv = 0; };   // atlastaki yeri, taban çizgisine göre kayma, ilerleme

struct Face {
  std::string key, png; float size = 0; int asc = 0, desc = 0;
  std::unordered_map<uint32_t, Glyph> g;
  std::unordered_map<uint64_t, float> kern;   // (a << 32 | b) → aralık
  core::Image img; bool loaded = false;
};

enum Align { LEFT, CENTER, RIGHT };
enum Baseline { ALPHABETIC, MIDDLE, TOP };

struct TextStyle {
  uint32_t color = 0xffffff; float alpha = 1;
  Align align = LEFT; Baseline base = ALPHABETIC;
  float outline = 0; uint32_t outlineColor = 0x000000; float outlineAlpha = 1;   // dış çizgi kalınlığı (HTML lineWidth; 0 yok)
  float maxWidth = 0;                                                            // 0: sınırsız; aşarsa yatayda sıkıştırılır
  bool fakeBold = false;                                                         // yapay kalın (tarayıcı kalını olmayan yazı tipini böyle kalınlaştırır)
  bool gradient = false; uint32_t color2 = 0; float gy0 = 0, gy1 = 0;            // dikey degrade: gy0'da color, gy1'de color2
};

class Fonts {
 public:
  void load(const engine::Vfs& vfs);
  bool ok() const { return !faces_.empty(); }
  Face* face(const std::string& fam, float size);
  float width(Face* f, const std::string& s);
  void draw(engine::Canvas& c, Face* f, const std::string& s, float x, float y, const TextStyle& st);
  // kısa yol: aile + boy
  void draw(engine::Canvas& c, const std::string& fam, float size, const std::string& s, float x, float y, const TextStyle& st) { draw(c, face(fam, size), s, x, y, st); }
  float width(const std::string& fam, float size, const std::string& s) { return width(face(fam, size), s); }
  bool enabled = true;   // test: yazısız çizim (piksel karşılaştırmasında yazı tarayıcıyla birebir olamaz)

 private:
  const engine::Vfs* vfs_ = nullptr;
  std::map<std::string, Face> faces_;
  std::map<std::string, std::vector<std::pair<float, std::string>>> byFam_;
  void ensure(Face& f);
};

std::vector<uint32_t> utf8(const std::string& s);

}  // namespace ui
