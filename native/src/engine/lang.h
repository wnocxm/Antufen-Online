// Dil (HTML www/js/i18n.js): Türkçe asıl, İngilizce çeviri. tx(metin): Türkçe metnin İngilizcesi — önce sözlük (EN_UI), sonra
// kalıplar (EN_RULES; düzenli ifade, "$t1" = 1. grubun da çevirisi), " · " ile ayrılmış parçalar tek tek; bulunamazsa metin aynen.
// Veri: www/assets/dil_en.json (tools/dil_cikar.js). T(tr, en): koda gömülü iki dilli metin (HTML'deki T / T2 / T_ / GT).
// Dil değişince HTML sayfayı yeniler; C++ da veriyi o dille baştan yükler (World, pencereler).
#pragma once
#include <map>
#include <regex>
#include <string>
#include <unordered_map>
#include <vector>

#include "engine/vfs.h"

namespace engine {

class Lang {
 public:
  void load(const Vfs& vfs);              // dil_en.json (yoksa çeviri yok)
  bool en = false;                         // İngilizce mi
  std::string code() const { return en ? "en" : "tr"; }
  std::string tx(const std::string& s);    // HTML tx
  const std::string& item(const std::string& trName) const;   // HTML EN_ITEM (yoksa boş)
  std::string cls(const std::string& cn) const;               // TR.cls / EN.cls
  std::string race(const std::string& cn) const;
  std::vector<std::string> missing;        // çevirisi bulunamayan Türkçe metinler (HTML TX_MISS; denetim)

 private:
  std::unordered_map<std::string, std::string> ui_, item_, cls_, race_;
  struct Rule { std::regex re; std::string rep; bool tpl = false; };
  std::vector<Rule> rules_;
  std::unordered_map<std::string, std::string> cache_;   // çizimde her kare aynı yazılar çevrilir
  std::string apply(const Rule& r, const std::string& k, const std::smatch& m);
};

Lang& lang();                                                       // oyunun tek dil nesnesi
inline std::string tx(const std::string& s) { return lang().tx(s); }
inline std::string T(const std::string& tr, const std::string& en) { return lang().en ? en : tr; }

}  // namespace engine
