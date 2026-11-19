#include "forms.h"
#include "engine/lang.h"

#include "core/jpeg.h"

#include <algorithm>
#include <cmath>

namespace ui {

std::string Forms::tr(const std::string& t) {
  static const std::map<std::string, std::string> T = {{"装备", "Ekipman"}, {"消耗", "Tüketim"}, {"普通", "Genel"}, {"任务", "Görev"}, {"任务 ", "Görev"}, {"快捷键", "Kısayol"}, {"存钱", "Sat"}, {"详细", "Ayrıntı"}, {"销毁", "Yok Et"}, {"自动回复", "Oto. İksir"}, {"扩容", "Genişlet"}, {"确定", "Tamam"}, {"取消", "İptal"}, {"返回", "Geri"}, {"关闭", "Kapat"}, {"属性", "Özellik"}, {"称号", "Unvan"}, {"信息", "Bilgi"}, {"角色属性", "Karakter Özellikleri"}, {"角色装备", "Karakter Ekipmanı"}, {"其它", "Diğer"}, {"资料", "Profil"}, {"成就", "Başarım"}, {"卸下", "Çıkar"}, {"更换", "Değiştir"}, {"修改称号", "Unvan"}, {"退出", "Çıkış"}, {"昵称", "Ad"}, {"种族", "Irk"}, {"等级", "Seviye"}, {"体力", "Can"}, {"物攻", "Fiz. Saldırı"}, {"防御", "Savunma"}, {"闪避", "Kaçınma"}, {"释放", "Büyü Hızı"}, {"圣抗", "Kutsal Dir."}, {"火抗", "Ateş Dir."}, {"职业", "Sınıf"}, {"经验", "Tecrübe"}, {"公会", "Lonca"}, {"法力", "Mana"}, {"魔攻", "Büyü Saldırı"}, {"命中", "İsabet"}, {"暴击", "Kritik"}, {"韧性", "Dayanıklılık"}, {"暗抗", "Gölge Dir."}, {"冰抗", "Buz Dir."}, {"升级", "Yükselt"}, {"洗点", "Sıfırla"}, {"技能点", "Beceri puanı"}, {"寻路", "Yol Bul"}, {"切换", "Değiştir"}, {"任务列表", "Görev Listesi"}, {"常用", "Sık Kullanılan"}, {"道具", "Eşya"}, {"系统", "Sistem"}, {"角色", "Karakter"}, {"技能", "Beceri"}, {"地域", "Harita"}, {"背包", "Çanta"}, {"设置", "Ayarlar"}, {"接受", "Kabul"}, {"放弃", "Bırak"}, {"完成", "Tamamla"}, {"可接任务", "Alınabilir"}, {"已接任务", "Alınmış"}, {"购买", "Satın Al"}, {"卖出", "Sat"}, {"修理", "Onar"}};
  auto it = T.find(t); if (it != T.end()) return it->second;
  std::string s = t; while (!s.empty() && s.back() == ' ') s.pop_back(); while (!s.empty() && s.front() == ' ') s.erase(s.begin());
  it = T.find(s); return it != T.end() ? it->second : t;
}

void Forms::load(const engine::Vfs& vfs) {
  F_ = core::Json::parse(vfs.readText("forms.json"));
  for (const auto& kv : F_.obj()) forms_[kv.first] = &kv.second;
  if (vfs.exists("forms2.json")) {
    F2_ = core::Json::parse(vfs.readText("forms2.json"));
    for (const auto& kv : F2_.obj()) { forms_["n_" + kv.first] = &kv.second; for (const core::Json& c : kv.second["c"].arr()) res_[&c] = kv.second["res"].str(); }
  }
}
const core::Json* Forms::form(const std::string& name) const { auto it = forms_.find(name); return it == forms_.end() ? nullptr : it->second; }
const core::Json* Forms::ctrl(const std::string& name, int id) const {
  const core::Json* f = form(name); if (!f) return nullptr;
  for (const core::Json& c : (*f)["c"].arr()) if (c["id"].i() == id) return &c;
  return nullptr;
}
const core::Image* Forms::image(const std::string& path) {
  auto it = img_.find(path);
  if (it == img_.end()) {
    std::unique_ptr<core::Image> im;
    try { if (as_.vfs().exists(path)) { const auto b = as_.vfs().read(path); im = std::make_unique<core::Image>(core::isJPEG(b) ? core::decodeJPEG(b) : core::decodePNG(b)); } } catch (...) { im.reset(); }
    it = img_.emplace(path, std::move(im)).first;
  }
  return it->second.get();
}
const core::Image* Forms::img(int id, const std::string& res) {
  return image(res.empty() ? "ui/AnbufenUI_Resource_" + std::to_string(id) + ".png" : "ui2/" + res + "_" + std::to_string(id) + ".png");
}

void Forms::drawCtrl(engine::Canvas& c, const Xf& xf, const core::Json& ctl, int st, float ox, float oy, const std::string* txt) {
  const core::Json& S = ctl["s"]; if (!S.size()) return;
  const core::Json& s = S[std::min<size_t>(size_t(std::max(0, st)), S.size() - 1)];
  std::string res; { auto r = res_.find(&ctl); if (r != res_.end()) res = r->second; }   // yeni pencerelerin görsel kaynağı
  const float cx = ox + float(s["r"][0].num()), cy = oy + float(s["r"][1].num());
  const auto& L = s["L"].arr();
  for (int i = int(L.size()) - 1; i >= 0; i--) {
    const core::Json& l = L[size_t(i)];
    const int k = l[0].i(); const float x = float(l[1].num()), y = float(l[2].num()), w = float(l[3].num()), h = float(l[4].num());
    const int a0 = l[5].i(), a1 = l[6].i(), a2 = l[7].i(); const uint32_t col = uint32_t(uint64_t(l[8].num()) & 0xffffff); const int al = l[9].i(), im = l[10].i();
    const float X = cx + x, Y = cy + y;
    if (k == 2 && im) {
      const core::Image* I = img(im, res); if (!I) continue;
      const float alpha = al < 0 ? 1 : al / 100.f;
      const float sw = std::min(w, float(I->w - a0)), sh = std::min(h, float(I->h - a1)); if (sw <= 0 || sh <= 0) continue;
      for (float yy = 0; yy < h; yy += sh) for (float xx = 0; xx < w; xx += sw) {
        const float tw = std::min(sw, w - xx), th = std::min(sh, h - yy);
        c.drawImage(*I, float(a0), float(a1), tw, th, xf.X(X + xx), xf.Y(Y + yy), tw * xf.k, th * xf.k, alpha, xf.smooth);
      }
    } else if (k == 0) c.fillRect(xf.X(X), xf.Y(Y), std::max(1.f, w) * xf.k, std::max(1.f, h) * xf.k, col);
    else if (k == 1) { if (a2 == 0 && al > 0) c.fillRect(xf.X(X), xf.Y(Y), w * xf.k, h * xf.k, col, al / 100.f); }
    else if (k == 3) { const std::string str = txt ? *txt : tr(l[11].str()); btnText(c, xf, str, X, Y, w, h, col, true); }
  }
}

// koyu zemin üstünde yazı: gövde yazı tipi (boy + 1), ince koyu dış çizgi, orta taban çizgisi, genişliğe sığdırılır
void Forms::label(engine::Canvas& c, const Xf& xf, const std::string& s0, float x, float y, float w, float h, uint32_t col, Align a, float size) {
  if (s0.empty()) return;
  const std::string s = engine::tx(s0);   // HTML: str = tx(String(str))
  const float lx = a == CENTER ? x + w / 2 : a == RIGHT ? x + w - 2 : x + 2, ly = y + h / 2 + 0.5f;
  TextStyle st; st.color = col; st.align = a; st.base = MIDDLE; st.outline = 2.4f * xf.k; st.outlineColor = 0x140802; st.outlineAlpha = 0.8f; st.maxWidth = w * xf.k;
  font_.draw(c, "B", (size + 1) * xf.k, s, xf.X(lx), xf.Y(ly), st);
}
// düğme / sekme yazısı: başlık yazı tipi kalın; koyu (siyah) katman rengi altın-parşömene çevrilir (HTML'de yazı rengi verilince de)
void Forms::btnText(engine::Canvas& c, const Xf& xf, const std::string& s0, float x, float y, float w, float h, uint32_t col, bool colIsLayer, float size) {
  if (s0.empty()) return;
  const std::string s = engine::tx(s0);
  const bool dark = !colIsLayer || ((col >> 16) & 255) + ((col >> 8) & 255) + (col & 255) < 200;   // HTML: yazı rengi (dize) verildiğinde de koyu sayılır
  const float sz = size > 0 ? size : std::max(9.f, std::min(14.f, std::round(h * 0.5f)));
  TextStyle st; st.color = dark ? 0xfbe6b0 : col; st.align = CENTER; st.base = MIDDLE; st.outline = 3 * xf.k; st.outlineColor = 0x2a0c03; st.maxWidth = (w - 4) * xf.k; st.fakeBold = true;
  font_.draw(c, "H", sz * xf.k, s, xf.X(x + w / 2), xf.Y(y + h / 2 + 1), st);
}
// parşömen üstünde gölgesiz yazı (HTML nText): 13 ve üstü başlık yazı tipi kalın, altı gövde (boy + 1)
void Forms::text(engine::Canvas& c, const Xf& xf, const std::string& s0, float x, float y, uint32_t col, float size, Align a, float w) {
  if (s0.empty()) return;
  const std::string s = engine::tx(s0);   // HTML nText: tx(String(s))
  TextStyle st; st.color = col; st.align = a; st.base = MIDDLE; st.maxWidth = w * xf.k;
  if (size >= 13) { st.fakeBold = true; font_.draw(c, "H", size * xf.k, s, xf.X(x), xf.Y(y), st); }
  else font_.draw(c, "B", (size + 1) * xf.k, s, xf.X(x), xf.Y(y), st);
}
std::vector<std::string> Forms::wrap(const std::string& s, float w, float size) {
  std::vector<std::string> out; size_t a = 0;
  while (true) {
    const size_t nl = s.find('\n', a); const std::string para = s.substr(a, nl == std::string::npos ? std::string::npos : nl - a);
    std::string line; size_t b = 0;
    while (true) {
      const size_t sp = para.find(' ', b); const std::string word = para.substr(b, sp == std::string::npos ? std::string::npos : sp - b);
      const std::string t = line.empty() ? word : line + " " + word;
      if (font_.width("B", size + 1, t) > w && !line.empty()) { out.push_back(line); line = word; } else line = t;
      if (sp == std::string::npos) break;
      b = sp + 1;
    }
    out.push_back(line);
    if (nl == std::string::npos) break;
    a = nl + 1;
  }
  return out;
}

}  // namespace ui
