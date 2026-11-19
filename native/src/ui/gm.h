// GM paneli (HTML index.html #gm, style.css #gm / .gbox / #gtools / #gq / #glist, ui.js openList / drawList / drawGmSys / gmX).
// HTML'de sayfa üstü bir DOM paneli; C++ aynı görünümü tuvale çizer. Yerleşim tarayıcınınkiyle aynı hesaplanır: esnek kutu (flex-wrap,
// flex: 1, en az genişlik), ızgara (auto-fill minmax(180px, 1fr)), uzunluklar LayoutUnit (1/64 px), yazı genişlikleri dosya parçası
// başına yukarı yuvarlanır (Fonts::domWidth), kutular piksele oturtulur (round). Düğmeler HTML'deki kimlikleriyle: g:<data-g>,
// x:<data-x>, s:<sahne>. Sekme simgeleri renkli emoji (Android'deki gibi Noto Color Emoji). docs/09-cpp.md › GM paneli.
#pragma once
#include <string>
#include <vector>

#include "engine/assets.h"
#include "engine/canvas.h"
#include "engine/world.h"
#include "ui/font.h"

namespace ui {

class GmPanel {
 public:
  GmPanel(engine::Assets& as, Fonts& f) : as_(as), font_(f) {}
  bool on = false;
  std::string view = "maps";        // HTML gmView: maps, dg, pet, cls (açılışlar arasında kalır)
  std::string query;                // arama kutusu (#gq)
  bool editing = false;             // arama kutusu odakta (ekran klavyesi açık)
  double scroll = 0;                // listenin kaydırması (px; HTML #glist scrollTop)
  std::string req;                  // arayüze istek: close (hepsini kapat), pet, petf:tf, petf:sk
  void open();                      // HTML openList('gm')
  void close() { on = false; editing = false; pressed_.clear(); num_.on = false; }
  void draw(engine::Canvas& c, engine::World& w);
  void press(float x, float y);
  void move(float x, float y);
  void release(engine::World& w, float x, float y);
  void wheel(float dy);              // fare tekerleği (px; artı: aşağı)
  void typed(const std::string& s);  // yazılan harfler (arama kutusu ya da seviye kutusu)
  bool key(engine::World& w, const std::string& k);   // Backspace, Enter, Escape; true: panel aldı
  bool act(engine::World& w, const std::string& id);   // kimlikle düğmeye bas (test; dokunmayla aynı yol)
  bool numOpen() const { return num_.on; }
  void clearTab() { tabOn_.clear(); }   // test
  struct Box { std::string id, kind, text; double x, y, w, h; };
  std::vector<Box> boxes;           // son çizimin kutuları (dokunma ve test): kind panel, head, title, state, close, tool, input, list, row, b, small, btn, scene, hint
  std::string dump() const;         // test: kutular JSON

 private:
  engine::Assets& as_;
  Fonts& font_;
  core::Image btnImg_; bool btnLoaded_ = false;
  std::string tabOn_;               // HTML: .gv.on yalnız sekmeye dokununca değişir (ilk açılışta hiçbiri)
  std::string placeholder_ = "Harita ara: ad ya da numara…";
  std::string pressed_; bool dragging_ = false; float px_ = 0, py_ = 0, ly_ = 0, moved_ = 0;
  double listX_ = 0, listY_ = 0, listW_ = 0, listH_ = 0, maxScroll_ = 0;
  struct { bool on = false, fresh = true; std::string typed; } num_;   // "Seviye seç" (HTML prompt): küçük sayı kutusu (ilk yazış seçili değerin yerine geçer)
  struct Btn { std::string key, label; };
  struct Row { int kind = 0; std::string id, title, sub; std::vector<Btn> btns; bool on = false; };   // kind: 0 satır (.grow), 1 harita düğmesi, 2 not (.hint)
  std::vector<Row> rows(engine::World& w);
  std::string stateText(engine::World& w) const;
  void tap(engine::World& w, const std::string& id);
};

}  // namespace ui
