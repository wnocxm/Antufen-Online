// Giriş ekranı ve karakter oluşturma (HTML: index.html #title / #create, style.css .cover / .cpanel, ui.js titleOpen / renderCreate /
// drawCreate). HTML'de bu iki ekran sayfa öğeleri (DOM); C++ aynı yerleri, boyları ve görselleri tuvale çizer (yerler 640×360'ta
// tarayıcıdan ölçüldü; genişlik değişince HTML'deki gibi ortalanır). Karşılaştırma: tools/test/cpp_giris.js.
#pragma once
#include <functional>
#include <string>
#include <vector>

#include "engine/assets.h"
#include "engine/canvas.h"
#include "ui/font.h"
#include "ui/forms.h"

namespace ui {

// giriş ekranı: orijinal ana menü (kapak dokusu, logo, kitap, oklarla seçilen sözcük)
class Title {
 public:
  Title(engine::Assets& as, Fonts& f, Forms& forms) : as_(as), font_(f), forms_(forms) {}
  // hasSave: kayıt var (Devam Et); saveInfo: "Ad · Sınıf · Seviye n"
  void open(bool hasSave, const std::string& saveInfo);
  void update(double dt);              // kitap açılışı ve sayfa çevirme (HTML setTimeout süreleri)
  void settle();                       // bekleyen bütün adımlar hemen (test)
  void draw(engine::Canvas& c);
  // dokunma: basış ve bırakış (kaydırma 50 px: sayfa çevir); sonuç: "" ya da eylem (continue, new)
  void press(float x, float y);
  std::string release(float x, float y);
  std::string key(const std::string& k);   // ArrowLeft, ArrowRight, Enter
  std::string turn(int d);                 // önceki / sonraki sözcük
  std::string go();                        // seçili sözcüğü uygula
  std::string version;                     // sağ altta "Sürüm …"
  std::function<void(const std::string&, double)> sfx;   // ses efekti (HTML SFX.play)
  std::function<void(const std::string&)> music;         // müzik (HTML SFX.Music.play)
  std::string word() const { return word_; }
  std::string info() const { return info_; }
  bool busy() const { return busy_; }
  std::string frame() const { return frame_; }

 private:
  engine::Assets& as_; Fonts& font_; Forms& forms_;
  struct Item { std::string label, page, info, act; };
  std::vector<Item> items_;
  size_t idx_ = 0; bool busy_ = false, sure_ = false, hasSave_ = false;
  std::string frame_ = "closed", word_, info_;
  struct Step { double t; int kind; };   // kind: 0 yarı açık, 1 açık, 2 göster
  std::vector<Step> steps_;
  float W_ = 640, px_ = 0, py_ = 0; bool down_ = false;
  void show();
  void bookRect(float& x, float& y, float& w, float& h, int& sx, int& sy) const;
};

// karakter oluşturma: solda panel (ad, sınıf, ırk, cinsiyet, yüz, Oyuna başla), sağda karakterin büyük önizlemesi
class Create {
 public:
  Create(engine::Assets& as, Fonts& f, Forms& forms) : as_(as), font_(f), forms_(forms) {}
  void open();
  void draw(engine::Canvas& c, double nowMs);   // nowMs: önizleme animasyonu (HTML performance.now)
  std::string tap(float x, float y);            // "start": Oyuna başla
  void text(const std::string& utf8);           // yazılan harfler (ad kutusu odaktayken)
  bool key(const std::string& k);               // Backspace, Enter (odağı bırakır)
  std::string finalName() const;                // HTML: kırpılmış, boşsa "Kahraman", en çok 12 harf
  bool editing = false;                         // ad kutusu odakta (ekran klavyesi açık olmalı)
  std::string cls = "战士", race = "人类", sex = "male", name = "Kahraman", msg; int face = 1;
  std::function<void(const std::string&, double)> sfx;   // düğme sesi (HTML: sayfadaki her düğmeye tıklama "menusel")
  std::function<void(const std::string&)> music;

 private:
  engine::Assets& as_; Fonts& font_; Forms& forms_;
  engine::Paperdoll doll_; std::string dollKey_;
  struct Hit { float x, y, w, h; std::string id; };
  std::vector<Hit> hits_;
  double caretT_ = 0;
};

}  // namespace ui
