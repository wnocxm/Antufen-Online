// Denge: canavar tanımları, deneyim tabloları, sınıf taban değerleri, eşyalar, evcil yumurtaları.
// Veri: denge.json (tools/denge_cikar.js ← www/js/game.js), items.json, pets.json, data.json (sahneler, canavar kayıtları).
#pragma once
#include <map>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

#include "core/json.h"
#include "engine/quests.h"
#include "engine/skills.h"
#include "engine/vfs.h"

namespace engine {

// Canavar tanımı (HTML MON[ad]): elle yazılmışsa denge.json'dan, değilse sahnenin seviyesinden (monDef kuralı)
struct MonDef {
  int lv = 1, rank = 0, n = 0, wide = 0;   // n/wide 0: varsayılan (5)
  long long xp = 0;
  bool passive = false, dummy = false, skip = false, solo = false, autoDef = false, fit = false;
};

struct ClassBase { double hp = 0, mp = 0, atk = 0, def = 0, ghp = 0, gmp = 0, gatk = 0, gdef = 0, dmgK = 1, range = 1.4; bool melee = false; std::string bolt, boltHit, snd; };

// eşya (items.json + oyunun kendi iksirleri/paketi): ik/icon simge dosyası (icon_res_<ik>_<icon>); use: kullanılınca can/mana, yiyecek
// (hot: [kaynak, miktar, sn]; hot2 ikinci kaynak), qt görev eşyası; growth Gelişim Paketi
struct Item {
  std::string id, slot, cls, name, en; int lv = 0, icon = 0; std::string ik; std::map<std::string, double> st;
  bool use = false, qt = false, growth = false; double useHp = 0, useMp = 0;
  struct Hot { std::string res; double amt = 0, sec = 0; } hot, hot2;
};

class Balance {
 public:
  void load(const Vfs& vfs, const core::Json& D);
  MonDef& monDef(const std::string& name, const core::Json& scene);   // önbellekli (HTML gibi: ilk hesaplandığı sahne belirler)
  long long mobXp(int lv, int rank) const;
  long long xpNeed(int lv) const;
  const ClassBase& cls(const std::string& c) const;
  const std::vector<Item>& items() const { return items_; }   // JS nesne sırası: sayısal numaralar artan
  const Item* item(const std::string& id) const;
  // data.json canavar kaydı [ad, görünüm, ölüm efekti …]; HTML fixMonData düzeltmesi uygulanmış (bir kayıtta görünüm/ölüm efekti ters)
  struct MobRec { std::string name, look, deathFx; };
  const MobRec* mobById(const std::string& id) const;
  const MobRec* mobInfo(const std::string& name) const;       // adı eşleşen ilk kayıt (numara sırası; HTML Game.mobInfo)
  const std::string* eggFor(const std::string& look) const;    // canavarın görünüş ailesine uyan evcil türün yumurtası
  Skills skills;                                               // beceriler (skills.json + skills.cpp)
  Quests quests;                                               // görevler (quests.json)

 private:
  const core::Json* D_ = nullptr;
  std::unordered_map<std::string, std::unique_ptr<MonDef>> mon_;
  std::vector<long long> xpt_, mxpt_;
  std::map<std::string, ClassBase> cls_;
  std::vector<Item> items_;
  std::unordered_map<std::string, size_t> itemIdx_;
  std::unordered_map<std::string, MobRec> mobById_;
  std::unordered_map<std::string, std::string> mobByName_;   // ad → ilk numara
  std::vector<std::pair<std::string, std::string>> eggFam_;   // (aile, yumurta)
};

std::string lookFamily(const std::string& look);   // "怪物-狼-白" → "怪物-狼" (HTML pet.js fam)

}  // namespace engine
