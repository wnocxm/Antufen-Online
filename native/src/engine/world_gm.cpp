// GM (oyun yöneticisi): HTML game.js isGM / gmLevel / gmHeal / ClassGM ve ui.js gmX'in yolculuk düğmeleri (docs/03-istemci.md › GM).
// Zindan GM'i world_dungeon.cpp'de (HTML Dungeon.GM), evcil GM'i world_pet.cpp'de (HTML Pet.GM); panel ui/gm.cpp.
#include <algorithm>

#include "engine/world.h"

namespace engine {

// HTML isGM: çevrimdışı adı "GM" ile başlayan karakter (büyük/küçük harf fark etmez); çevrimiçi sunucudaki yönetici (ağ adımında)
bool World::isGM() const {
  const std::string& n = P.name;
  return n.size() >= 2 && (n[0] == 'G' || n[0] == 'g') && (n[1] == 'M' || n[1] == 'm');
}

void World::gmLevel(int lv) { setLevel(lv); lvlN = P.lv; lvlT = 2.5f; save(); }   // HTML gmLevel: UI.levelUp(n), save()

void World::gmHeal() {
  const Stats s = stats(); player.hp = s.hp; player.mp = s.mp;
  if (player.dead) { player.dead = false; player.state = "idle"; }
}

void World::runTimers(double dt) {
  for (int i = int(timers_.size()) - 1; i >= 0; i--) {
    if (size_t(i) >= timers_.size()) continue;
    timers_[size_t(i)].t -= dt;
    if (timers_[size_t(i)].t <= 0) { auto fn = std::move(timers_[size_t(i)].fn); timers_.erase(timers_.begin() + i); fn(); }
  }
}

void World::gotoSceneAt(const std::string& sid, int x, int y) { save(); const int a[2] = {x, y}; loadScene(sid, a); }

// HTML ClassGM.chain: oyuncunun sınıf (ve ırk) zincirinde 40 ve üstü görevler + 80344 (Acemilikten Çıkış);
// sıra: 80344 başta, sonra açılma seviyesi, sonra zincir derinliği (Array.sort kararlı)
std::vector<int> World::gmClassChain() {
  const auto& Q = quests().all(); std::vector<int> L;
  for (size_t i = 0; i < Q.size(); i++) { const Quest& q = Q[i]; if ((q.cls == P.cls && (q.race.empty() || q.race == P.race) && q.lvMin >= 40) || q.id == 80344) L.push_back(int(i)); }
  // HTML chainDepth: q.req zinciri (en çok 20); "herhangi biri" listesi tek elemanlıysa izlenir (JS QBY[[x]] = QBY[x]), çok elemanlıysa durur
  auto depth = [&](const Quest& q0) { int d = 0; const Quest* q = &q0; while (q && !q->req.empty() && d < 20) { d++; if (q->req.size() != 1) break; q = quests().byId(q->req[0]); } return d; };
  std::stable_sort(L.begin(), L.end(), [&](int a, int b) {
    const Quest& A = Q[size_t(a)]; const Quest& B = Q[size_t(b)];
    const int s = A.id == 80344 ? -1 : B.id == 80344 ? 1 : 0; if (s) return s < 0;
    if (A.lvMin != B.lvMin) return A.lvMin < B.lvMin;
    return depth(A) < depth(B);
  });
  return L;
}

void World::gmClassReset() {   // HTML ClassGM.reset
  P.adv = 0; fixSkills();
  for (int qi : gmClassChain()) { const int id = quests().all()[size_t(qi)].id; P.quests.erase(id); P.done.erase(id); }
  save();
}
void World::gmClassFill(int spec) {   // HTML ClassGM.fill
  if (P.lv < 80) gmLevel(80);
  classUp(1); classUp(2); P.sk.clear(); P.sp = 0; skillAutoSpend(P.lv + 1, spec); save();
}
void World::gmClassStart() { if (P.lv < 40) gmLevel(40); autoQuests(); }   // HTML ClassGM.start
void World::gmStart80() { if (P.lv < 80) gmLevel(80); classUp(1); gotoSceneAt("120156", 50, 39); }   // HTML ClassGM.start80

// HTML ClassGM.dummy: eski kukla diziden çıkar (C++'ta yerinde "kaldırıldı" olur), yanına yeni ☆水仙子 (can 1e9), hedef + saldır
void World::gmDummy() {
  for (Ent& e : ents) if (e.gmDummy) { e.kind = Ent::GONE; e.gmDummy = false; e.dead = true; e.hidden = true; }
  const double x = player.x + 1.5, y = player.y;
  spawnMob("☆水仙子", 0, 0, "");
  Ent& m = ents.back(); m.x = x; m.y = y; m.homeX = x; m.homeY = y; m.hp = m.maxHp = 1e9; m.gmDummy = true;
  setTarget(int(ents.size()) - 1, true);
}
void World::gmToggleNoCd() { gmNoCd = !gmNoCd; toast(gmNoCd ? T("Beklemesiz beceri: açık", "No cooldown: on") : T("Beklemesiz beceri: kapalı", "No cooldown: off")); }
void World::gmToggleFreeTravel() { gmFreeTravel = !gmFreeTravel; toast(gmFreeTravel ? T("Ücretsiz yolculuk: açık", "Free travel: on") : T("Ücretsiz yolculuk: kapalı", "Free travel: off")); }

// HTML gmX 'tv:near': bu haritadaki yolculuk NPC'leri yakınlığa göre (kararlı sıralama), en yakınına yürü
void World::gmWalkTravelNpc() {
  std::vector<int> L; for (size_t i = 0; i < ents.size(); i++) if (ents[i].kind == Ent::NPC && travelOf(int(i))) L.push_back(int(i));
  const Player& p = player;
  std::stable_sort(L.begin(), L.end(), [&](int a, int b) { return jsHypot(ents[size_t(a)].x - p.x, ents[size_t(a)].y - p.y) < jsHypot(ents[size_t(b)].x - p.x, ents[size_t(b)].y - p.y); });
  if (!L.empty()) walkToEnt(L[0]); else toast(T("Bu haritada yolculuk NPC'si yok.", "No travel NPC on this map."));
}

}  // namespace engine
