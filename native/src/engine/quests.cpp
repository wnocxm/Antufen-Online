#include "quests.h"
#include "engine/lang.h"

#include <algorithm>
#include <climits>
#include <set>

namespace engine {

static const int NIL = INT_MIN;   // JS null (seviye yok)

static QText readText(const core::Json& t) {
  QText x; x.title = t["title"].str(); x.text = t["text"].str(); x.ok = t["ok"].str(); x.wait = t["wait"].str(); x.done = t["done"].str(); x.goal = t["goal"].str(); x.item = t["item"].str();
  for (const core::Json& c : t["choice"].arr()) x.choice.push_back({c[0].str(), c[1].str()});
  for (const core::Json& d : t["drops"].arr()) x.drops.push_back(d.str());
  return x;
}

void Quests::load(const Vfs& vfs, const core::Json& D) {
  D_ = &D; q_.clear(); idx_.clear(); npcSc_.clear(); monSc_.clear(); next_.clear(); hubLv_.clear(); hubDone_ = false;
  const core::Json J = core::Json::parse(vfs.readText("quests.json"));
  for (const core::Json& j : J["quests"].arr()) {
    Quest q; q.id = j["id"].i(); q.giver = j["giver"].str(); q.to = j["to"].str(); q.type = j["type"].str(); q.target = j["target"].str(); q.sc = j["sc"].str();
    q.race = j["race"].str(); q.cls = j["cls"].str(); q.node = j["node"].str(); q.flag = j["flag"].str();
    q.count = j["count"].i(); q.lv = j["lv"].i(); q.lv0 = j["lv0"].i(); q.lvMin = j["lvMin"].i(); q.lvAt = j["lvAt"].i(); q.advMin = j["advMin"].i(); q.adv = j["adv"].i();
    q.auto_ = j["auto"].truthy(); q.use = j["use"].truthy(); q.chance = j["chance"].num();
    if (j["req"].isArr()) { q.reqAny = true; for (const core::Json& r : j["req"].arr()) q.req.push_back(r.i()); }
    else if (j["req"].isNum()) q.req.push_back(j["req"].i());
    for (const core::Json& x : j["targets"].arr()) {
      QTarget t; t.name = x[0].str(); t.n = x[1].i(); t.item = x[3].str(); t.itemId = x[4].isNum() ? std::to_string(x[4].i()) : x[4].str();
      if (x[2].isNum()) { t.kind = QTarget::DROP; t.chance = x[2].num(); }
      else if (x[2].str() == "node") t.kind = QTarget::NODE; else if (x[2].str() == "use") t.kind = QTarget::USE;
      q.targets.push_back(t);
    }
    for (const core::Json& d : j["drops"].arr()) q.drops.push_back({d[0].i(), d[1].num()});
    for (const core::Json& m : j["mobs"].arr()) q.mobs.push_back(m.str());
    for (const core::Json& g : j["give"].arr()) q.give.push_back(g.str());
    for (const core::Json& a : j["accItems"].arr()) q.accItems.push_back({a[0].str(), a[1].i()});
    if (j["tp"].isArr()) { q.hasTp = true; q.tpScene = j["tp"][0].str(); q.tpHasXY = j["tp"][1].isNum(); q.tpX = j["tp"][1].i(); q.tpY = j["tp"][2].i(); }
    const core::Json& r = j["reward"]; q.xp = (long long)r["xp"].num(); q.gold = (long long)r["gold"].num();
    for (const core::Json& it : r["items"].arr()) {
      Quest::RItem x; x.id = it[0].str(); x.n = it[1].i(1);
      if (it[2].isArr()) for (const core::Json& c : it[2].arr()) x.cls.push_back(c.str()); else if (it[2].isStr()) x.cls.push_back(it[2].str());
      q.items.push_back(x);
    }
    q.tr = readText(j["tr"]); q.en = readText(j["en"]);
    if (lang().en) q.tr = q.en;   // HTML: İngilizcede görev metinleri EN_Q / quests_gen'in İngilizcesiyle değişir (q.tr = seçili dil)
    idx_[q.id] = q_.size();   // aynı numara iki kez varsa sonraki geçerli (HTML QBY gibi)
    q_.push_back(std::move(q));
  }
  for (size_t i = 0; i < q_.size(); i++) for (int r : q_[i].req) next_[r].push_back(int(i));
  // HTML sceneIndex: sahneler JS sırasıyla (numara artan); canavar kaydı olan varlık canavar, öteki kişi
  for (const auto* kv : core::jsOrder(D["scenes"])) for (const core::Json& e : kv->second["ents"].arr()) {
    const bool mon = !D["mon"][std::to_string(e[0].i())].isNull();
    (mon ? monSc_ : npcSc_)[e[1].str()].push_back(kv->first);
  }
  for (int l = 0; l < 2; l++) {
    const core::Json& A = J["ad"][l ? "en" : "tr"];
    for (const char* part : {"scene", "name"}) for (const auto& kv : A[part].obj()) name_[l][kv.first] = kv.second.str();   // ad önce (TR.name || TR.scene)
    for (const auto& kv : A["greet"].obj()) greet_[l][kv.first] = kv.second.str();
  }
}

const std::vector<std::string>& Quests::npcScenes(const std::string& cn) const { static const std::vector<std::string> e; auto it = npcSc_.find(cn); return it == npcSc_.end() ? e : it->second; }
const std::vector<std::string>& Quests::monScenes(const std::string& n) const { static const std::vector<std::string> e; auto it = monSc_.find(n); return it == monSc_.end() ? e : it->second; }
const std::string& Quests::name(const std::string& cn) const { return name(cn, lang().en); }
const std::string& Quests::greet(const std::string& cn) const { return greet(cn, lang().en); }
const std::string& Quests::name(const std::string& cn, bool en) const { auto it = name_[en].find(cn); return it == name_[en].end() ? cn : it->second; }
const std::string& Quests::greet(const std::string& cn, bool en) const { static const std::string dots = "..."; auto it = greet_[en].find(cn); return it == greet_[en].end() ? dots : it->second; }

// ---------------- açılma seviyesi (HTML questMinLv ve yardımcıları) ----------------
int Quests::zoneMin(const std::vector<std::string>& sids) const {
  int m = NIL;
  for (const std::string& sid : sids) { const core::Json& r = (*D_)["scenes"][sid]["lvr"]; if (r.isArr() && (m == NIL || r[0].i() < m)) m = r[0].i(); }
  return m;
}
// bir haritanın görev seviyesi: aralığın alt sınırı - 1; başlangıç kampları (aralıksız) 1
int Quests::sceneQLv(const std::string& sid) const {
  const core::Json& s = (*D_)["scenes"][sid]; if (!s.isObj()) return NIL;
  if (s["lvr"].isArr()) return std::max(1, s["lvr"][0].i() - 1);
  if (s["kind"].isArr() && s["kind"][0].i() == 3) return 1;
  return s["lv"].i() ? std::max(1, s["lv"].i() - 1) : NIL;
}
// hedefin, görevi verenin haritasında ya da ona komşu haritalarda yaşadığı yer önce gelir
int Quests::ownLv(const Quest& q) const {
  if (q.target.empty() && q.node.empty()) return NIL;
  const std::vector<std::string>& T = !q.target.empty() ? monScenes(q.target) : (!npcScenes(q.node).empty() ? npcScenes(q.node) : monScenes(q.node));
  const std::vector<std::string>& G = npcScenes(q.giver);
  std::set<std::string> near(G.begin(), G.end());
  for (const std::string& g : G) for (const core::Json& e : (*D_)["scenes"][g]["exits"].arr()) if (!e[2].str().empty()) near.insert(e[2].str());
  auto pick = [&](bool onlyNear) { int m = NIL; for (const std::string& sid : T) { if (onlyNear && !near.count(sid)) continue; const int v = sceneQLv(sid); if (v != NIL && (m == NIL || v < m)) m = v; } return m; };
  const int a = pick(true); return a != NIL ? a : pick(false);
}
// şehirde (seviye aralığı olmayan harita) duran kişinin görev seviyesi: aynı şehirde verilen savaş görevlerinin en düşüğü
int Quests::hubLv(const std::string& giver) {
  if (!hubDone_) {
    hubDone_ = true;
    for (const Quest& x : q_) { const int o = ownLv(x); if (o == NIL) continue; for (const std::string& sid : npcScenes(x.giver)) { auto it = hubLv_.find(sid); if (it == hubLv_.end() || o < it->second) hubLv_[sid] = o; } }
  }
  int m = NIL; for (const std::string& sid : npcScenes(giver)) { auto it = hubLv_.find(sid); if (it != hubLv_.end() && (m == NIL || it->second < m)) m = it->second; }
  return m != NIL ? m : 1;
}
int Quests::minLv(int i) {
  Quest& q = q_[size_t(i)];
  if (q.minLv != -1) return q.minLv;
  if (q.lvAt) return q.minLv = q.lvAt;   // kesin açılma seviyesi (sınıf görevleri)
  q.minLv = 1;   // döngü koruması
  int lv = ownLv(q);
  int preLv = NIL; for (int r : q.req) { const int k = indexOf(r); if (k < 0) continue; const int v = minLv(k); if (preLv == NIL || v < preLv) preLv = v; }
  if (lv == NIL && preLv != NIL) lv = preLv;   // hedefsiz ara adım: önceki görev biter bitmez açılır
  if (lv == NIL) {   // ileriye bak: zincirdeki ilk savaş görevi
    std::set<int> seen; std::vector<int> front{i};
    for (int d = 0; d < 6 && lv == NIL && !front.empty(); d++) {
      std::vector<int> nx;
      for (int x : front) { auto it = next_.find(q_[size_t(x)].id); if (it == next_.end()) continue;
        for (int y : it->second) if (seen.insert(q_[size_t(y)].id).second) { const int o = ownLv(q_[size_t(y)]); if (o != NIL) lv = lv == NIL ? o : std::min(lv, o); nx.push_back(y); } }
      front = nx;
    }
  }
  if (lv == NIL) { const int z = zoneMin(npcScenes(q.giver)); lv = q.lv0 ? q.lv0 : (z != NIL ? std::max(1, z - 1) : hubLv(q.giver)); }
  if (preLv != NIL) lv = std::max(lv, preLv);
  if (q.lvMin) lv = std::max(lv, q.lvMin);   // bölge dosyasında elle verilen en düşük seviye
  return q.minLv = lv;
}
void Quests::resetLv() { for (Quest& q : q_) q.minLv = -1; hubLv_.clear(); hubDone_ = false; }

}  // namespace engine
