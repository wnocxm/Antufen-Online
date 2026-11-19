// Görevler (HTML QUESTS: tr.js elle yazılanlar + quests_gen.js; ödüller game.js). Veri: www/assets/quests.json ← tools/gorev_cikar.js.
// Sıra HTML'deki diziyle aynıdır: öldürme sayaçları ve toplama zarları bu sırayla işler.
// Açılma seviyesi (HTML questMinLv) orijinal veriden türetilir: hedefin yaşadığı haritanın seviyesi, zincirdeki önceki/sonraki görev,
// veren kişinin haritası (docs/04 › Seviye).
#pragma once
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

#include "core/json.h"
#include "engine/vfs.h"

namespace engine {

// çok hedefli görevin bir hedefi (HTML q.targets öğesi): [ad, adet] öldür · [ad, adet, şans, eşya] canavardan düşen eşya ·
// [nesne, adet, 'node', eşya] yerdeki nesneden al · [canavar, adet, 'use', eşya, eşyaNo] çantadaki görev eşyası o canavar hedefteyken kullanılır
struct QTarget {
  enum Kind { KILL, DROP, NODE, USE } kind = KILL;
  std::string name, item, itemId; int n = 0; double chance = 0;
  const std::string& key() const { return item.empty() ? name : item; }   // HTML tgKey: sayaç anahtarı
};

struct QText { std::string title, text, ok, wait, done, goal, item; std::vector<std::pair<std::string, std::string>> choice; std::vector<std::string> drops; };

struct Quest {
  int id = 0;
  std::string giver, to, type, target, sc, race, cls, node, flag;   // type: talk, kill, collect, pickup, deliver, special
  int count = 0, lv = 0, lv0 = 0, lvMin = 0, lvAt = 0, advMin = 0, adv = 0;
  bool reqAny = false, auto_ = false, use = false;                   // reqAny: req bir liste ("herhangi biri")
  std::vector<int> req;
  double chance = 0;
  std::vector<QTarget> targets;
  std::vector<std::pair<int, double>> drops;                         // çok eşyalı toplama: [adet, şans]
  std::vector<std::string> mobs, give;
  std::vector<std::pair<std::string, int>> accItems;                 // alınınca çantaya konan görev eşyası
  bool hasTp = false; std::string tpScene; bool tpHasXY = false; int tpX = 0, tpY = 0;   // ışınlanma (yeni "ev")
  struct RItem { std::string id; int n = 1; std::vector<std::string> cls; };
  long long xp = 0, gold = 0; std::vector<RItem> items;
  QText tr, en;
  int minLv = -1;                                                    // önbellek (HTML q._lv)
};

class Quests {
 public:
  void load(const Vfs& vfs, const core::Json& D);
  const std::vector<Quest>& all() const { return q_; }
  const Quest* byId(int id) const { auto it = idx_.find(id); return it == idx_.end() ? nullptr : &q_[it->second]; }
  int indexOf(int id) const { auto it = idx_.find(id); return it == idx_.end() ? -1 : int(it->second); }
  int minLv(int i);                                   // HTML questMinLv (önbellekli)
  void resetLv();                                     // önbellekleri sil (test: HTML ile aynı sırada yeniden hesap)
  const std::vector<std::string>& npcScenes(const std::string& cn) const;   // kişinin bulunduğu haritalar (sahne sırası)
  const std::vector<std::string>& monScenes(const std::string& name) const;
  const std::string& name(const std::string& cn, bool en) const;   // HTML trName (en: İngilizce ad)
  const std::string& greet(const std::string& cn, bool en) const;
  const std::string& name(const std::string& cn) const;            // seçili dilde (engine/lang)
  const std::string& greet(const std::string& cn) const;
  void addGreet(const std::string& cn, const std::string& tr, const std::string& en) { greet_[0][cn] = tr; greet_[1][cn] = en; }   // ek söz (zindan panoları)
  int sceneQLv(const std::string& sid) const;          // haritanın görev seviyesi (yoksa INT_MIN)

 private:
  const core::Json* D_ = nullptr;
  std::vector<Quest> q_;
  std::unordered_map<int, size_t> idx_;
  std::unordered_map<std::string, std::vector<std::string>> npcSc_, monSc_;
  std::unordered_map<int, std::vector<int>> next_;     // HTML QNEXT: önkoşulu bu olan görevler
  std::unordered_map<std::string, int> hubLv_; bool hubDone_ = false;
  std::unordered_map<std::string, std::string> name_[2], greet_[2];
  int ownLv(const Quest& q) const;
  int zoneMin(const std::vector<std::string>& sids) const;
  int hubLv(const std::string& giver);
};

}  // namespace engine
