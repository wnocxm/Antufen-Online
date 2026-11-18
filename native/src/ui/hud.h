// Oyun ekranı (HTML ui.js drawWorld'ün yazı/işaret kısmı + drawHud): adlar, görev işaretleri, canavar can çubukları, uçan sayılar;
// sol üstte portre ve can/mana/tecrübe, ortada hedef, sağ üstte küçük harita ve yuvarlak düğmeler, solda görev takibi, sol altta
// yürüme kolu (ejderha madalyonu), sağ altta saldırı düğmesi ve beceri/iksir halkası, ortada mesaj kutusu, duyurular.
// Dokunma: HUD düğmeleri, yürüme kolu, dünyaya dokunma (hedef seç / saldır / konuş). Pencereler (karakter, çanta…) sonraki adımda.
#pragma once
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "engine/canvas.h"
#include "engine/world.h"
#include "ui/font.h"
#include "ui/forms.h"
#include "ui/win.h"

namespace ui {

class Hud {
 public:
  Hud(engine::Assets& as, Fonts& f, Forms& forms) : win(forms), as_(as), font_(f) {}
  // dünya çizildikten sonra: adlar, işaretler, uçan sayılar, sonra HUD. advance: arayüz sayaçları (HTML'de kare başına 1/60) ilerlesin mi
  void draw(engine::Canvas& c, engine::World& w, bool advance = true);
  double now = 0;   // arayüz saati (sn): mesajların kaybolması

  // dokunma / fare (mantıksal koordinat): true dönerse arayüz aldı
  bool press(engine::World& w, int id, float x, float y);
  void move(int id, float x, float y);
  void release(engine::World& w, int id, float x, float y);
  // yürüme kolunun ekrandaki yön vektörü (World::update'e); yoksa 0, 0
  void joy(double& sx, double& sy) const;
  std::string request;   // HUD düğmesinin isteği (hub, quest, char, bag, skill, map, sys, talk:<varlık>); çizimde işlenir
  float safeL = 0, safeR = 0;
  Win win;               // pencereler (konuşma, görev listesi, ana menü, ölüm, onay)
  void closeAll() { win.close(); }

 private:
  engine::Assets& as_;
  Fonts& font_;
  std::map<std::string, std::unique_ptr<core::Image>> img_;
  struct Hit { float x, y, w, h; std::function<void()> fn; };
  std::vector<Hit> hud_;
  struct Joy { bool on = false; int id = -1; float ox = 0, oy = 0, dx = 0, dy = 0; } joy_;
  struct Tap { int id; float x, y; };
  std::vector<Tap> taps_;
  struct WinPtr { bool on = false; int id = -1; float x = 0, y = 0, moved = 0, lx = 0, ly = 0; } wp_;   // pencere açıkken dokunuş
  double deathAt = -1;   // ölüm penceresi bu saatte açılır (HTML UI.death: 1,2 sn sonra)
  std::string assign_;   // kısayola yerleştirilecek (s<n> / i:<eşya>): yuvalar parlar, dokunulan yuvaya yerleşir (HTML UI.startAssign)
  void handle(engine::World& w);
  struct Log { std::string m; uint32_t c; double t; };
  std::vector<Log> logs_; size_t seen_ = 0;
  int mmGen_ = -1; core::Image mm_;
  float vw_ = 640;

  const core::Image* image(const std::string& path);
  void text(engine::Canvas& c, const std::string& fam, float size, const std::string& s, float x, float y, uint32_t col, Align a = LEFT, float alpha = 1, float lw = 2.5f);
  void drawNames(engine::Canvas& c, engine::World& w, bool advance);
  void drawMinimap(engine::Canvas& c, engine::World& w, float x, float y, float W, float H);
  void drawTracker(engine::Canvas& c, engine::World& w);
  void drawSlot(engine::Canvas& c, engine::World& w, const std::string& sl, float x, float y, float k);
  void attack(engine::World& w);
  void quick(engine::World& w, int i);
  void tapWorld(engine::World& w, float x, float y);
  // konumlar çift duyarlıklı hesaplanır, çizime tek duyarlıklı geçer (HTML'deki gibi: JS sayısı → tarayıcının float'ı; en yakın komşu
  // örneklemede sınıra düşen satırlar böyle aynı kaynak pikseline gider)
  double rockerX() const { return 104 * HS + safeL; }
  double rockerY() const { return engine::VH - 74 * HS; }
  static constexpr double HS = 1.1;   // dokunmatik düğmelerin ölçeği
};

}  // namespace ui
