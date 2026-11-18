// Orijinal ekran tanımları (HTML forms.js): www/assets/forms.json (Symbian, AnbufenUI.godat) ve forms2.json (Android NEW_FORM_*; adları
// "n_" ile başlar, görselleri ui2/<kaynak>_<no>.png). Her denetim: durumlar (0 normal, 1 basılı/seçili), her durumda konum ve katmanlar
// [tür (0 çizgi, 1 dolgu, 2 görsel, 3 yazı), x, y, w, h, a0, a1, a2, renk, saydamlık, görsel, yazı]. Çizim bir dönüşümle (Xf: ölçek +
// kaydırma) yapılır: yeni pencereler 320 (ya da 373) birim yüksekliğe göre tasarlanmış, ekrana ölçeklenir.
#pragma once
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "core/json.h"
#include "engine/assets.h"
#include "engine/canvas.h"
#include "ui/font.h"

namespace ui {

// form biriminden ekrana: X = x + fx·k, Y = y + fy·k; smooth: görseller yumuşatılarak ölçeklenir (yeni pencerelerde açık)
struct Xf {
  float k = 1, x = 0, y = 0; bool smooth = false;
  float X(float fx) const { return x + fx * k; }
  float Y(float fy) const { return y + fy * k; }
  Xf sub(float dx, float dy) const { Xf o = *this; o.x += dx * k; o.y += dy * k; return o; }
};

class Forms {
 public:
  Forms(engine::Assets& as, Fonts& f) : as_(as), font_(f) {}
  void load(const engine::Vfs& vfs);
  const core::Json* form(const std::string& name) const;
  const core::Json* ctrl(const std::string& form, int id) const;
  const core::Image* img(int id, const std::string& res = "");
  const core::Image* image(const std::string& path);
  // denetimi çiz (HTML Forms.drawCtrl): (ox, oy) form birimi kaydırma; txt verilirse yazı katmanının yazısı yerine
  void drawCtrl(engine::Canvas& c, const Xf& xf, const core::Json& ctl, int st, float ox, float oy, const std::string* txt = nullptr);
  // yazılar (HTML Forms.label / btnText / win.js nText); renkler 0xRRGGBB
  void label(engine::Canvas& c, const Xf& xf, const std::string& s, float x, float y, float w, float h, uint32_t col, Align a = CENTER, float size = 11);
  void btnText(engine::Canvas& c, const Xf& xf, const std::string& s, float x, float y, float w, float h, uint32_t col, bool colIsLayer, float size = 0);
  void text(engine::Canvas& c, const Xf& xf, const std::string& s, float x, float y, uint32_t col, float size = 11, Align a = LEFT, float w = 0);
  // satırlara böl (HTML win.js wrap): genişlik form birimi, ölçü (size + 1) px gövde yazısıyla
  std::vector<std::string> wrap(const std::string& s, float w, float size = 11);
  static std::string tr(const std::string& t);   // orijinal arayüz yazısının Türkçesi (forms.js T)
  Fonts& fonts() { return font_; }

 private:
  engine::Assets& as_;
  Fonts& font_;
  core::Json F_, F2_;
  std::map<std::string, const core::Json*> forms_;
  std::map<const core::Json*, std::string> res_;   // denetim → görsel kaynağı (yeni pencereler)
  std::map<std::string, std::unique_ptr<core::Image>> img_;
};

}  // namespace ui
