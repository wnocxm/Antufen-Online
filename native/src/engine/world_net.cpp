// Ağ için dünya parçaları (docs/10-ag.md): dünya özeti (istemci ve sunucu aynı adımda karşılaştırır), komutlar (16.2).
#include <cstring>

#include "engine/world.h"

namespace engine {

namespace {
// FNV-1a 64 bit; kayan noktalılar bit örüntüsüyle (aynı benzetim → aynı bitler)
struct Fnv {
  uint64_t h = 1469598103934665603ull;
  void bytes(const void* p, size_t n) { const auto* b = static_cast<const uint8_t*>(p); for (size_t i = 0; i < n; i++) { h ^= b[i]; h *= 1099511628211ull; } }
  void d(double v) { uint64_t u; std::memcpy(&u, &v, 8); bytes(&u, 8); }
  void i(long long v) { bytes(&v, 8); }
  void s(const std::string& v) { i((long long)v.size()); bytes(v.data(), v.size()); }
};
}  // namespace

// ---------------- komutlar ----------------
void World::cmd(const Cmd& c) {
  if (onCmd) onCmd(c);
  exec(c);
}

// Komutu uygula. Her dal HTML'deki arayüz işinin dünyaya dokunan kısmı (pencereyi kapatma, ses gibi arayüz işleri arayüzde kalır).
// Sunucu da bunu çağırır: değerler istemciden gelir, denetimler (altın, seviye, uzaklık…) zaten oyun kodunun içinde.
bool World::exec(const Cmd& c) {
  const std::string& op = c.op;
  auto entOk = [this](int e) { return e >= 0 && e < int(ents.size()); };
  if (op == "target") { const int e = c.i(0); if (e != -1 && !entOk(e)) return false; setTarget(e, c.i(1) != 0); return true; }
  if (op == "cycle") { cycleTarget(); return true; }
  if (op == "talk") { if (!entOk(c.i(0))) return false; talkTo(c.i(0)); return true; }
  if (op == "walk") { if (!entOk(c.i(0))) return false; walkToEnt(c.i(0)); return true; }
  if (op == "skill") { const int i = c.i(0); if (i < 0 || i >= int(skills().size())) return false; useSkill(i); return true; }
  if (op == "item") { useItem(c.s(0)); return true; }
  if (op == "quick") { const int qi = c.i(1); if (qi < 0 || qi >= int(P.quick.size())) return false; assignQuick(c.s(0), qi); save(); return true; }
  if (op == "buy") { buyItem(c.s(0), std::max(1, std::min(999, c.i(1)))); return true; }
  if (op == "sell") { sellItem(c.s(0), std::max(1, c.i(1))); return true; }
  if (op == "unequip") { unequip(c.s(0)); return true; }
  if (op == "skillUp") { const SkillDef* sk = bal_.skills.bySn(c.i(0)); if (!sk) return false; skillUp(*sk); return true; }
  if (op == "skillReset") { skillReset(false); return true; }   // bedava sıfırlama yalnız GM'de
  if (op == "drop") { const std::string id = c.s(0); const int n = countItem(id); if (!n) return false; const std::string nm = itemName(id); removeItem(id, n); note(nm + " yok edildi."); return true; }
  if (op == "dropQuest") { const int qid = c.i(0); const Quest* q = quests().byId(qid); if (!q || !P.quests.count(qid)) return false; P.quests.erase(qid); note(tx("Görev bırakıldı") + ": " + q->tr.title); return true; }
  if (op == "accept") { const int qi = c.i(0); if (qi < 0 || qi >= int(quests().all().size())) return false; dialogAccept(qi, c.s(1)); return true; }
  if (op == "complete") { const int qi = c.i(0); if (qi < 0 || qi >= int(quests().all().size())) return false; completeQuest(qi); return true; }
  if (op == "questWalk") { const int qi = c.i(0); if (qi < 0 || qi >= int(quests().all().size())) return false; questWalk(qi); return true; }
  if (op == "qtp") { const int qi = c.i(0); if (qi < 0 || qi >= int(quests().all().size())) return false; questTeleport(qi); return true; }
  if (op == "routeNpc") { routeToNpc(c.s(0)); return true; }
  if (op == "routeTo") { if (!as_.D()["scenes"][c.s(0)].isObj()) return false; routeQuest = 0; routeNpc.clear(); routeTo(c.s(0)); return true; }
  if (op == "travel") {   // yolculuk kişisi + seçenek sırası; ücret yetmezse yapılmaz (arayüz de uyarır)
    const int n = c.i(0); if (!entOk(n)) return false; const auto* L = travelOf(n); const int k = c.i(1);
    if (!L || k < 0 || k >= int(L->size())) return false; const TravelOpt x = (*L)[size_t(k)]; const int cost = travelCost(n, x);
    if (cost && P.gold < cost) return false; travelGo(n, x); return true;
  }
  if (op == "dtp") { const auto L = dungeonTps(c.s(0)); if (L.empty()) return false; dungeonTpGo(*L[0].second); return true; }
  if (op == "revive") { if (!player.dead) return false; revive(); return true; }
  if (op == "flag") { questFlag(c.s(0)); return true; }
  if (op == "ask") { auto it = asks_.find(c.i(0)); if (it == asks_.end()) return false; auto fn = std::move(it->second); asks_.erase(it); if (fn) fn(); return true; }
  if (op == "petMode") { const std::string m = c.s(0); if (m != "attack" && m != "counter" && m != "support" && m != "free" && m != "idle") return false; petSetMode(m); return true; }
  if (op == "petOn") { PetRec* p = petByUid(c.s(0)); if (!p) return false; if (P.petOn == p->uid) petDismiss(); else petSummon(p->uid); return true; }
  if (op == "petRelease") { if (!petByUid(c.s(0))) return false; petRelease(c.s(0)); return true; }
  if (op == "petTf" || op == "petSk") {
    std::vector<std::string> aids(c.a.begin() + std::min<size_t>(2, c.a.size()), c.a.end());
    if (op == "petSk") petTransfer(c.s(0), c.s(1), aids); else petTransform(c.s(0), c.s(1), aids);
    return true;
  }
  if (op == "gm") { if (!isGM()) return false; gmAct(c.s(0)); return true; }
  return false;
}

// GM paneli düğmeleri (HTML ui.js gtools dinleyicisi ve gmX'in dünyaya dokunan kısmı; panelin kendi işi ui/gm.cpp'de)
void World::gmAct(const std::string& id) {
  if (id.rfind("n:", 0) == 0) { const int n = std::atoi(id.c_str() + 2); if (n) gmLevel(n); return; }   // Seviye seç (HTML prompt)
  if (id.rfind("g:", 0) == 0) {
    const std::string a = id.substr(2);
    if (a == "lv1") gmLevel(P.lv + 1); else if (a == "lv10") gmLevel(P.lv + 10);
    else if (a == "gold") { P.gold += 100000; save(); } else if (a == "heal") gmHeal(); else if (a == "god") god = !god; else if (a == "fast") fast = !fast;
    else if (a == "gear") gmGear(); else if (a == "sp") { P.sp += 20; save(); }
    return;
  }
  if (id.rfind("s:", 0) == 0) { const std::string sid = id.substr(2); if (!as_.D()["scenes"][sid].isObj()) return; player.pathOn = false; player.path.clear(); gotoScene(sid, ""); return; }
  if (id.rfind("x:", 0) != 0) return;
  std::vector<std::string> p; { std::string cur; for (char ch : id.substr(2)) { if (ch == ':') { p.push_back(cur); cur.clear(); } else cur += ch; } p.push_back(cur); }
  while (p.size() < 4) p.push_back("");
  const std::string &a = p[0], &b = p[1], &cc = p[2], &d = p[3];
  if (a == "dg") {
    if (b == "in" || b == "door") { const std::string dd = cc; const int k = std::atoi(d.c_str()); const bool in = b == "in"; later(0.2, [this, dd, k, in] { if (in) gmDungeonEnter(dd, k); else gmDungeonDoor(dd, k); }); return; }   // HTML setTimeout 200
    if (b == "last") gmDungeonLast(); else if (b == "leave") { if (dungeonOf(sceneId)) dungeonLeave(false); }
    else if (b == "boss") gmDungeonBoss(); else if (b == "clear") gmDungeonClear(); else if (b == "reset") gmDungeonReset();
  } else if (a == "tv") {
    if (b == "free") gmToggleFreeTravel();
    else if (b == "axe") later(0.2, [this] { gotoSceneAt("120156", 50, 39); });
    else if (b == "near") gmWalkTravelNpc();
  } else if (a == "cls") {
    if (b == "start80") { later(0.2, [this] { gmStart80(); }); return; }
    if (b == "go") { const int qi = quests().indexOf(std::atoi(cc.c_str())); if (qi >= 0) later(0.2, [this, qi] { questWalk(qi); }); return; }
    if (b == "ready") gmQuestReady(std::atoi(cc.c_str()));
    else if (b == "done") gmQuestDone(std::atoi(cc.c_str()));
    else if (b == "fill") gmClassFill(std::atoi(cc.c_str()));
    else if (b == "up") classUp(1);
    else if (b == "up2") { classUp(1); classUp(2); }
    else if (b == "reset") gmClassReset();
    else if (b == "resetPts") skillReset(true);
    else if (b == "start") gmClassStart();
    else if (b == "dummy") gmDummy();
    else if (b == "nocd") gmToggleNoCd();
  } else if (a == "pet") {
    if (b == "give") gmPetGive(cc); else if (b == "egg") gmPetEgg(cc);
    else if (b == "stage0") gmPetStage(0); else if (b == "stage") gmPetStage(-1);
    else if (b == "level") gmPetLevel(); else if (b == "care") gmPetCare(); else if (b == "items") gmPetItems();
    else if (b == "hungry") gmPetHungry(); else if (b == "clear") gmPetClear(); else if (b == "skills") gmPetSkills(); else if (b == "tf") gmPetTf();
  }
}

uint64_t World::digest() const {
  Fnv f;
  f.s(sceneId); f.i(rng().state());
  f.d(player.x); f.d(player.y); f.d(player.hp); f.d(player.mp); f.i(player.dead); f.i(target_); f.i(engage_);
  f.i(P.lv); f.i(P.xp); f.i(P.gold); f.i(P.sp); f.i(P.adv);
  for (const auto& b : P.bag) { f.s(b.first); f.i(b.second); }
  for (const auto& e : P.eq) { f.s(e.first); f.s(e.second); }
  for (const auto& s : P.sk) { f.s(s.first); f.i(s.second); }
  for (const auto& q : P.quests) { f.i(q.first); f.i(q.second.n); f.i(q.second.ready); }
  f.i((long long)P.done.size());
  for (const Ent& e : ents) if (e.kind == Ent::MOB) { f.d(e.x); f.d(e.y); f.d(e.hp); f.i(e.dead); }
  f.i(pet.on); if (pet.on) { f.d(pet.x); f.d(pet.y); }
  for (const PetRec& p : P.pets) { f.s(p.uid); f.i(p.lv); f.d(p.hp); f.d(p.xp); }
  if (P.dun.on) { f.s(P.dun.id); f.i((long long)P.dun.cleared.size()); }
  return f.h;
}

}  // namespace engine
