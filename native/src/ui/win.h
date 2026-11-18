// Pencereler (HTML win.js; Android sürümünün NEW_FORM_* ekranları): ana menü (v5_menu), konuşma (npc_dialogue), görev listesi (task +
// item_info), ölüm (deadselect), onay kutusu (dialog_yesno). Pencereler 320 (konuşma ve ölüm 373) birim yüksekliğe göre tasarlanmış,
// ekran yüksekliğine ölçeklenir; görseller yumuşatılarak büyütülür. Henüz yok (sonraki adım): karakter, çanta, beceri, evcil, harita,
// ayarlar, dükkân — menüden seçilince "yakında" bildirimi.
#pragma once
#include <functional>
#include <map>
#include <string>
#include <vector>

#include "engine/world.h"
#include "ui/forms.h"

namespace ui {

class Win {
 public:
  explicit Win(Forms& f) : F_(f) {}
  void open(engine::World& w, const std::string& name, int npc = -1, const std::string& say = "");
  void close();
  bool isOpen() const { return !cur.empty() || modal_.on; }
  void draw(engine::Canvas& c, engine::World& w, float dt);
  bool tap(engine::World& w, float x, float y);   // pencere yoksa false
  void ask(const std::string& text, std::function<void()> onYes);   // onay kutusu
  void clearPressed() { pressed_.clear(); }   // test: basılı vurgusu sönmüş say
  std::string cur;                                  // açık pencere: hub, npc, task, dead
  float safeL = 0;

 private:
  Forms& F_;
  struct Hit { std::string id; float x, y, w, h; };
  std::vector<Hit> hits_;
  std::string pressed_; double clock_ = 0, pressT_ = -1;
  // konuşma
  struct Opt { std::string t, a, s; int qi = -1, ch = -1, tv = -1; uint32_t c = 0; };
  int npc_ = -1; std::string say_;
  int dq_ = -1, dtrv_ = -1, dpg_ = 0, dfocus_ = 0; std::string dkey_;
  std::map<std::string, Opt> npcMap_;
  // görev listesi
  std::string kmode_ = "act"; int ksel_ = 0, koff_ = 0;
  // onay kutusu
  struct Modal { bool on = false; std::string text; std::function<void()> yes; std::vector<Hit> hits; } modal_;

  Xf begin(float k, float x, float y, float oy = 0) const { Xf f; f.k = k; f.x = x; f.y = y - oy * k; f.smooth = true; return f; }
  void hit(const Xf& xf, const std::string& id, float x, float y, float w, float h, std::vector<Hit>* L = nullptr);
  const std::vector<float> rect(const std::string& form, int id) const;
  void nDraw(engine::Canvas& c, const Xf& xf, const std::string& form, int id, bool st, const std::string* txt = nullptr);
  void longBg(engine::Canvas& c, const Xf& xf, float h = 373);
  void row(engine::Canvas& c, const Xf& xf, const std::string& form, int id, bool on, const std::string& label, const std::string& key, uint32_t col = 0);
  bool on(const std::string& id) const { return pressed_ == id && clock_ - pressT_ < 0.16; }
  std::pair<std::string, std::vector<Opt>> npcOptions(engine::World& w);
  std::vector<int> taskList(engine::World& w);
  void drawHub(engine::Canvas& c, engine::World& w, float VH);
  void drawNpc(engine::Canvas& c, engine::World& w, float VH);
  void drawTask(engine::Canvas& c, engine::World& w, float VH);
  void drawDead(engine::Canvas& c, engine::World& w, float vw, float VH);
  void drawModal(engine::Canvas& c, float vw, float VH);
  void tapNpc(engine::World& w, const std::string& id);
  void tapTask(engine::World& w, const std::string& id);
};

}  // namespace ui
