// Denge: canavar tanımları, deneyim tabloları, sınıf taban değerleri, eşyalar, evcil yumurtaları.
// Veri: denge.json (tools/denge_cikar.js ← www/js/game.js), items.json, pets.json, data.json (sahneler, canavar kayıtları).
#pragma once
#include <map>
#include <memory>
#include <set>
#include <string>
#include <unordered_map>
#include <vector>

#include "core/json.h"
#include "engine/pet.h"
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
// (hot: [kaynak, miktar, sn]; hot2 ikinci kaynak), qt görev eşyası; growth Gelişim Paketi; pet evcil eşyası; gfx kuşanınca görünüm;
// price alış, sell satış (0: alışın onda biri, en az 1)
struct Item {
  std::string id, slot, cls, name, en, desc, gfx; int lv = 0, icon = 0, price = 0, sell = 0; std::string ik; std::map<std::string, double> st;
  std::vector<std::string> stOrder;   // st anahtarları dosyadaki sırayla (bilgi satırı)
  bool use = false, qt = false, growth = false, pet = false, quest = false; double useHp = 0, useMp = 0;
  core::Json petJ;   // evcil eşyası alanları (egg, box, food, petHp, petMp, petRevive, petSlot, petGift, petXp, tf, add, below, sk, slot)
  struct Hot { std::string res; double amt = 0, sec = 0; } hot, hot2;
};

// zindan (zindan.json ← tools/zindan_cikar.js ← www/js/dungeon.js): kopyalar ırk başına ayrı girişli olabilir; kapı = alan haritasında
// geçit tablosuna bağlanmamış geçit bölgesi; train: sınav zindanı (zayıf canavar, yeniden doğar, sınırsız); daily: günlük giriş hakkı
struct DungeonCopy { std::string doorScene; int doorRegion = 0; std::vector<std::string> scenes; };
struct DungeonDef { std::string id, cn, board, boss; int lv = 0, lvr0 = 0, lvr1 = 0, daily = 0, req = 0; bool train = false; double bossX = 0; std::vector<DungeonCopy> copies; };
struct DungeonTp { std::string sid, label; bool hasXY = false; int x = 0, y = 0, lv = 0; };   // NPC ışınlanması (zindan merkezleri)

// yolculuk seçeneği (travel.json ← tools/seyahat.py): arabacı / ışınlayıcı → şehir adı, hedef sahne, varış yeri
struct TravelOpt { std::string kind, name, sid; bool hasXY = false; int x = 0, y = 0; };

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
  struct MobRec { std::string name, look, deathFx; bool prog = false; };   // prog: orijinal zindan ilerleme boss'u (instance_progress)
  const MobRec* mobById(const std::string& id) const;
  const MobRec* mobInfo(const std::string& name) const;       // adı eşleşen ilk kayıt (numara sırası; HTML Game.mobInfo)
  const std::string* eggFor(const std::string& look) const;    // canavarın görünüş ailesine uyan evcil türün yumurtası
  Skills skills;                                               // beceriler (skills.json + skills.cpp)
  Quests quests;                                               // görevler (quests.json)
  std::unordered_map<std::string, std::vector<TravelOpt>> travel;   // kişi kaydı numarası → yolculuk seçenekleri
  std::set<std::string> shops;   // dükkânı olan kişiler (items.json shops; gece elfi tüccarları insan eşlerinin listesiyle)
  struct ShopTab { std::string name; std::vector<std::string> ids; };
  std::map<std::string, std::vector<ShopTab>> shopTabs;   // kişi → sekmeler (sekme adı, eşyalar)
  int travelCar = 100; std::unordered_map<std::string, int> travelFee;   // arabacı ücreti; kişiye özel ücret (ad → altın)
  std::vector<DungeonDef> dungeons;
  std::map<std::string, std::pair<std::string, std::pair<int, int>>> dungeonExit;   // "sahne:bölge" → yanlış bağlı geçidin gerçek hedefi (sahne, x, y)
  std::map<std::string, DungeonTp> dungeonTp;                                        // kişi adı → ışınlanma
  PetData pets;                                                                      // evcil hayvanlar (pets.json)

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
