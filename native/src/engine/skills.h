// Beceriler (HTML game.js CLS[...].skills, RACE_SK + skills.json). Ağaçlar, adlar, simgeler, en yüksek kademe, ön koşullar ve
// kademe sabitleri orijinal (www/assets/skills.json ← tools/beceriler.py); her becerinin oyundaki karşılığı (hasar çarpanı,
// güçlendirme, şifa, efektler) burada, HTML'deki tanımla birebir aynı sırada ve aynı sayılarla durur (skills.cpp).
//   f    etkin becerinin o kademedeki sayıları (SkF)      pas  edilgen beceri (Vals: stats()'a eklenir)
//   buff güçlendirme (Vals, dur sn)                       heal şifa
// Efekt alanları (orijinal efekt tablosundan; docs/03 › Beceri efektleri): self oyuncuda (selfN kez, selfR px saçılma), proj hedefe
// uçan (projN tane), hit hedefte (hitN/hitR), fx tek efekt, bfx güçlendirme süresince karakterde, totem yere konan çağrılmış nesne.
#pragma once
#include <functional>
#include <map>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include "core/json.h"
#include "engine/vfs.h"

namespace engine {

// JS nesnesi gibi sıralı sayı tablosu (güçlendirme değerleri, edilgen toplamları): ekleme sırası korunur, olmayan anahtar 0
struct Vals {
  std::vector<std::pair<std::string, double>> v;
  Vals() = default;
  Vals(std::initializer_list<std::pair<std::string, double>> l) : v(l) {}
  double get(const std::string& k) const { for (const auto& p : v) if (p.first == k) return p.second; return 0; }
  bool has(const std::string& k) const { for (const auto& p : v) if (p.first == k) return true; return false; }
  void set(const std::string& k, double x) { for (auto& p : v) if (p.first == k) { p.second = x; return; } v.push_back({k, x}); }
  void add(const std::string& k, double x) { for (auto& p : v) if (p.first == k) { p.second += x; return; } v.push_back({k, x}); }
  void del(const std::string& k) { for (size_t i = 0; i < v.size(); i++) if (v[i].first == k) { v.erase(v.begin() + long(i)); return; } }
};

class World;
struct Ent;
struct Stats;
struct SkillDef;

// beceri işlevlerine verilen bağlam (HTML f(K, s, p, t)): K("sabit") becerinin o kademedeki değeri, s oyuncu değerleri, t hedef
struct SkCtx {
  World& w; const SkillDef& sk; const Stats& s; int L; Ent* t; int R = -1;   // R: K() bu kademeden (beceri açıklaması; -1 şimdiki)
  double K(const char* key) const;
  int rank(int sn) const;                    // HTML skRankSn
  double C(int sn, const char* key) const;   // HTML skCSn
};

// etkin becerinin o anki sayıları (HTML f() dönüşü; yazılmayan alan 0 / boş)
struct SkF {
  double mult = 0, add = 0, crit = 0, slow = 0, freeze = 0, stun = 0, critDmg = 0, phantom = 0, life = 0, weakDef = 0, weakT = 0, taunt = 0, mult2 = 0;
  bool pure = false, bleed = false, burn = false, corrode = false, arcane = false, novaHeal = false, hasMult2 = false;
  std::string refresh;                       // bu güçlendirmenin süresini yenile
  std::function<void(Ent&)> onCrit;          // kritik vuruşta
};

struct SkillDef {
  std::string id; int sn = 0;
  double mp = 0, cd = 0, range = 0, dur = 0, splash = 0, slow = 0, aoe = 0;
  std::string self, hit, proj, fx, fx2, bfx, totem, snd, snd2;
  int selfN = 0, selfR = 0, hitN = 0, hitR = 0, projN = 0, hits = 0;
  bool toggle = false;
  std::function<SkF(SkCtx&)> f;
  std::function<Vals(SkCtx&)> pas, buff;
  std::function<double(SkCtx&)> heal, durF, mpPct;
  // skills.json
  const core::Json* d = nullptr; int mx = 10; std::string name, nameEn, cls, race;
  bool passive() const { return bool(pas); }
};

// beceri ağacı (HTML TREES): hücreler [beceri, sütun]
struct SkillTree { int id = 0; std::string name; std::vector<std::pair<SkillDef*, int>> cells; };

class Skills {
 public:
  void load(const Vfs& vfs);
  std::vector<SkillDef>& cls(const std::string& c) { return cls_[c]; }
  const std::vector<SkillDef>& cls(const std::string& c) const { static const std::vector<SkillDef> e; auto it = cls_.find(c); return it == cls_.end() ? e : it->second; }
  std::vector<SkillDef>& race(const std::string& r) { return race_[r]; }
  const std::vector<SkillDef>& race(const std::string& r) const { static const std::vector<SkillDef> e; auto it = race_.find(r); return it == race_.end() ? e : it->second; }
  const SkillDef* bySn(int sn) const { auto it = bySn_.find(sn); return it == bySn_.end() ? nullptr : it->second; }
  const std::vector<SkillTree>& trees(const std::string& c) const { static const std::vector<SkillTree> e; auto it = trees_.find(c); return it == trees_.end() ? e : it->second; }
  const SkillTree* tree(int id) const;
  bool loaded() const { return !bySn_.empty(); }
  const core::Json& json() const { return J_; }   // skills.json (ırk ağacı adları, yaşam meslekleri)

 private:
  core::Json J_;
  std::map<std::string, std::vector<SkillDef>> cls_, race_;
  std::map<std::string, std::vector<SkillTree>> trees_;
  std::unordered_map<int, SkillDef*> bySn_;
};

}  // namespace engine
