// Pencereler (HTML win.js; Android sürümünün NEW_FORM_* ekranları): ana menü (v5_menu), konuşma (npc_dialogue), görev listesi (task +
// item_info), ölüm (deadselect), onay kutusu (dialog_yesno). Pencereler 320 (konuşma ve ölüm 373) birim yüksekliğe göre tasarlanmış,
// ekran yüksekliğine ölçeklenir; görseller yumuşatılarak büyütülür. 8. adım (win_items.cpp): çanta (bag_2), karakter (player), beceri
// ağacı (skilltree), dükkân (shop + shopinfo), adet kutusu (selnum). 9. adım (win_map.cpp): dünya haritası, ayarlar, NPC listesi.
// 11. adım (win_pet.cpp): evcil hayvan, taktik, dönüşüm / beceri aktarma.
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
  void open(engine::World& w, const std::string& name, int npc = -1, const std::string& say = "", bool quiet = false);   // quiet: sesler çalındı (World::openDialog)
  void openShop(engine::World& w, const std::string& cn) { open(w, "shop"); shop_ = cn; }               // dükkân (kişinin adı)
  void openBag(engine::World& w, int cat, const std::string& shop) { open(w, "bag"); B_.cat = cat; shop_ = shop; }   // çanta (dükkândan: Sat)
  void close();
  bool isOpen() const { return !cur.empty() || modal_.on; }
  void draw(engine::Canvas& c, engine::World& w, float dt);
  bool tap(engine::World& w, float x, float y);   // pencere yoksa false
  void drag(float dy, float x, float y);          // kaydırma (dükkân listesi)
  bool key(const std::string& k);                 // tuş (adet kutusu: rakamlar, Backspace, Enter, ArrowUp/Down, +, -, Escape); true: pencere aldı
  void ask(const std::string& text, std::function<void()> onYes);   // onay kutusu
  void askNum(const std::string& title, int max, std::function<void(int)> onOk, int unit = 0);   // adet kutusu (unit: tane fiyatı)
  void clearPressed() { pressed_.clear(); lastTapId_.clear(); }   // test: basılı vurgusu sönmüş, çift dokunuş yok say
  std::string cur;                                  // açık pencere: hub, npc, task, dead, bag, role, skill, shop
  float safeL = 0;
  bool wantText = false;                            // adet kutusunun sayısına dokunuldu: ekran klavyesi açılsın (SDL_StartTextInput)
  std::string assignReq, assignName;                // kısayola yerleştirme isteği (HUD yuvaya dokunulmasını bekler)
  bool optSfx = true, optMusic = true;              // ayarlar: ses efektleri, müzik (uygulama karıştırıcıya uygular ve kaydeder)
  bool optChanged = false;                          // ayar değişti (uygulama okuyup sıfırlar)
  void openNpcList(engine::World& w);               // bu haritadaki kişiler (dokununca yürür)
  void openPetF(engine::World& w, const std::string& mode, const std::string& main = "");   // dönüşüm / beceri aktarma
  bool gmReq = false;                               // ana menünün GM düğmesine dokunuldu (arayüz GM panelini açar)

 private:
  engine::World* w_ = nullptr;   // son dokunulan/çizilen dünya (sesler; onay kutusu oyun kodundan da açılır)
  void snd(const std::string& n, double v = 1) { if (w_) w_->sfx(n, v); }
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
  // onay kutusu (yesno) ve adet kutusu (num)
  struct Modal { bool on = false; bool num = false; std::string text, title, typed; int max = 1, n = 1, unit = 0; std::function<void()> yes; std::function<void(int)> ok; std::vector<Hit> hits; } modal_;
  // çanta, karakter, beceri, dükkân
  struct { int cat = 0, page = 0; std::string sel; } B_;
  std::string shop_;
  struct { int page = 0; std::string sel; } R_;
  struct SkCell { const engine::SkillDef* sk = nullptr; const core::Json* job = nullptr; int i = 0; };
  struct { int tree = 0; std::string sel; } S_;
  std::map<std::string, SkCell> skCells_;
  struct { int tab = 0, off = 0; std::string sel; float acc = 0; } H_;
  std::string lastTapId_; double lastTapT_ = -1;   // çift dokunuş (kullan / satın al)
  float nk_ = 1;                                   // açık pencerenin ölçeği (kaydırma)
  struct Line { std::string t; uint32_t c; float s; };
  // dünya haritası (wm/wm.json): kıta → bölge → bulunduğun harita
  struct { std::string mode = "world"; int area = -1; std::string sel; } WM_;
  core::Json wm_; bool wmLoaded_ = false;
  // evcil hayvan penceresi (petcomplex + taktik newpetai) ve dönüşüm / beceri aktarma (fantasize_pet)
  struct { int i = 0, tab = 0, skd = 0, tree = -1; bool ai = false; } PW_;
  struct { std::string mode = "tf", main, mat, a[2]; } TF_;
  // ana menü kaydırması (HTML HUB: 7 düğmeden uzunsa — GM — sayfa gibi kayar): y form birimi, r ekrandaki alan
  struct { float y = 0, x = 0, top = 0, w = 0, h = 0, k = 1, max = 0; bool on = false; } hub_;
  // liste penceresi (NPC listesi)
  struct ListRow { std::string label, sub; int ent = -1; };
  std::vector<ListRow> list_; std::string listTitle_; int listOff_ = 0;

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
  // win_items.cpp
  void tabs(engine::Canvas& c, const Xf& xf, const std::string& f, int bgId, const std::vector<int>& ids, const std::vector<std::string>& labels, int active);
  void actions(engine::Canvas& c, const Xf& xf, const std::string& f, int bgId, const std::vector<int>& ids, const std::vector<std::pair<std::string, std::string>>& acts);
  void icon(engine::Canvas& c, const Xf& xf, const std::string& ik, int ic, float x, float y, float s, float alpha = 1);
  std::vector<Line> itemLines(engine::World& w, const engine::Item& it);
  std::vector<std::pair<std::string, int>> bagItems(engine::World& w);   // (eşya, adet); görev eşyası: ("q:<ad>", adet)
  std::vector<std::string> shopItems(engine::World& w);
  bool doubleTap(const std::string& id);
  void drawBag(engine::Canvas& c, engine::World& w, float VH);
  void tapBag(engine::World& w, const std::string& id);
  void drawRole(engine::Canvas& c, engine::World& w, float VH);
  void tapRole(engine::World& w, const std::string& id);
  void drawSkill(engine::Canvas& c, engine::World& w, float VH);
  void tapSkill(engine::World& w, const std::string& id);
  void drawShop(engine::Canvas& c, engine::World& w, float vw, float VH);
  void tapShop(engine::World& w, const std::string& id);
  void drawNum(engine::Canvas& c, float vw, float VH);
  void buyAsk(engine::World& w, const std::string& id);
  void sellAsk(engine::World& w, const std::string& id);
  // win_pet.cpp
  void petSprite(engine::Canvas& c, engine::World& w, const Xf& xf, const std::string& look, float x, float y, float ww, float hh, float sc, float alpha = 1);
  void drawPet(engine::Canvas& c, engine::World& w, float VH);
  void tapPet(engine::World& w, const std::string& id);
  void drawPetF(engine::Canvas& c, engine::World& w, float vw, float VH);
  void tapPetF(engine::World& w, const std::string& id);
  // win_map.cpp
  const core::Json& wm(engine::World& w);
  void drawMap(engine::Canvas& c, engine::World& w, float vw, float VH);
  void tapMap(engine::World& w, const std::string& id);
  void drawSys(engine::Canvas& c, engine::World& w, float VH);
  void tapSys(engine::World& w, const std::string& id);
  void drawList(engine::Canvas& c, engine::World& w, float VH);
  void tapList(engine::World& w, const std::string& id);
};

}  // namespace ui
