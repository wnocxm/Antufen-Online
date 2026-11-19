// Yol bulma ve yürüme: HTML world.js findPath, game.js walkToEnt / talkTo / routeTo / routeStep / scenePath / questWalk /
// npcSceneNear / monSceneNear / routeToNpc, yolculuk (travelOf, travelCost, travelLabel, travelGo) ve revive.
#include <algorithm>
#include <cmath>
#include <set>

#include "world.h"

namespace engine {

// A* yalnızca 4 yönde (orijinaldeki gibi); hedef geçilmezse 4 kare içindeki en yakın boş kare. Açık listede en küçük f, eşitse ilk.
bool World::findPath(double sx0, double sy0, double tx0, double ty0, std::vector<std::pair<int, int>>& out, int maxIter) const {
  out.clear();
  const int sx = int(jsRound(sx0)), sy = int(jsRound(sy0)); int tx = int(jsRound(tx0)), ty = int(jsRound(ty0));
  if (!map.inside(tx, ty)) return false;
  if (blocked(tx, ty)) {
    bool f = false; int bx = 0, by = 0; double bd = 1e9;
    for (int r = 1; r < 5 && !f; r++) for (int dy = -r; dy <= r; dy++) for (int dx = -r; dx <= r; dx++) {
      const int x = tx + dx, y = ty + dy; if (map.inside(x, y) && !blocked(x, y)) { const double d = jsHypot(dx, dy); if (d < bd) { bd = d; bx = x; by = y; f = true; } }
    }
    if (!f) return false;
    tx = bx; ty = by;
  }
  const int W = map.w; auto key = [W](int x, int y) { return y * W + x; };
  struct Node { int x, y; double g, f; };
  std::vector<Node> open{{sx, sy, 0, 0}};
  std::unordered_map<int, double> g{{key(sx, sy), 0}}; std::unordered_map<int, int> came;
  int it = 0;
  while (!open.empty() && it++ < maxIter) {
    size_t bi = 0; for (size_t i = 1; i < open.size(); i++) if (open[i].f < open[bi].f) bi = i;
    const Node n = open[bi]; open.erase(open.begin() + long(bi));
    if (n.x == tx && n.y == ty) {
      int k = key(n.x, n.y);
      while (k != key(sx, sy)) { out.push_back({k % W, k / W}); auto c = came.find(k); if (c == came.end()) break; k = c->second; }
      std::reverse(out.begin(), out.end()); return true;
    }
    static const int D[4][2] = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}};
    for (const auto& d : D) {
      const int nx = n.x + d[0], ny = n.y + d[1]; if (!map.inside(nx, ny) || blocked(nx, ny)) continue;
      const double ng = g[key(n.x, n.y)] + 1; const int k = key(nx, ny);
      auto gi = g.find(k);
      if (ng < (gi == g.end() ? 1e9 : gi->second)) { g[k] = ng; came[k] = key(n.x, n.y); open.push_back({nx, ny, ng, ng + jsHypot(nx - tx, ny - ty)}); }
    }
  }
  return false;
}
bool World::findPathTo(double tx, double ty) { player.pathOn = findPath(player.x, player.y, tx, ty, player.path); return player.pathOn; }

// bu haritadaki bir kişiye yürü; varınca konuşur (yol bitince hedef 2,2 kare içindeyse interact)
void World::walkToEnt(int ei) {
  const Ent& t = ents[size_t(ei)];
  findPathTo(t.x, t.y + 1); goTarget = ei; setTarget(-1);
  if (!player.pathOn) toast("Oraya yol bulunamadı.");
}
void World::talkTo(int ei) {
  if (ei < 0 || ents[size_t(ei)].hidden) return;
  const Ent& n = ents[size_t(ei)];
  if (jsHypot(n.x - player.x, n.y - player.y) < 2) { interact(ei); return; }
  findPathTo(n.x, n.y + 1); goTarget = ei;
  if (!player.pathOn) toast("Oraya yol bulunamadı.");
}

// geçit bağlantıları üzerinde en kısa sahne zinciri; tv: arabacı/ışınlayıcı yolculukları da (sahne sırası JS gibi: numara artan)
std::vector<std::string> World::scenePath(const std::string& from, const std::string& to, bool tv) const {
  const core::Json& S = as_.D()["scenes"];
  std::unordered_map<std::string, std::string> prev{{from, ""}}; std::vector<std::string> q{from}; size_t qi = 0;
  // yolculuk kişileri sahnelere göre (HTML travelEdges)
  static std::unordered_map<std::string, std::vector<const std::vector<TravelOpt>*>> edges; static const void* edgesFor = nullptr;
  if (tv && edgesFor != &bal_) {
    edges.clear(); edgesFor = &bal_;
    for (const auto* kv : core::jsOrder(S)) for (const core::Json& e : kv->second["ents"].arr()) { auto it = bal_.travel.find(std::to_string(e[0].i())); if (it != bal_.travel.end()) edges[kv->first].push_back(&it->second); }
  }
  while (qi < q.size()) {
    const std::string c = q[qi++];
    if (c == to) { std::vector<std::string> out; for (std::string x = to; !x.empty(); x = prev[x]) out.insert(out.begin(), x); return out; }
    for (const core::Json& e : S[c]["exits"].arr()) { const std::string n = e[2].str(); if (!n.empty() && S[n].isObj() && !prev.count(n)) { prev[n] = c; q.push_back(n); } }
    if (tv) { auto it = edges.find(c); if (it != edges.end()) for (const auto* L : it->second) for (const TravelOpt& o : *L) if (S[o.sid].isObj() && !prev.count(o.sid)) { prev[o.sid] = c; q.push_back(o.sid); } }
  }
  return {};
}

void World::routeTo(const std::string& sid) {
  if (sid == sceneId) { toast("Zaten buradasın."); return; }
  if (routePath(sceneId, sid).empty()) { if (isGM()) { route.clear(); gotoScene(sid, ""); return; } toast("Buradan oraya yürüyerek gidilemiyor."); return; }   // GM: yolu olmayan haritaya ışınlanır
  route = sid; routeStep();
}
void World::routeStep() {
  const std::string to = route; if (to.empty()) return;
  if (to == sceneId) {
    route.clear(); const int rq = routeQuest; routeQuest = 0;
    if (rq) { const int qi = quests().indexOf(rq); if (qi >= 0 && P.quests.count(rq)) { questWalk(qi); return; } }
    const std::string cn = routeNpc; routeNpc.clear();
    if (!cn.empty()) for (size_t i = 0; i < ents.size(); i++) if (ents[i].kind == Ent::NPC && ents[i].name == cn) { walkToEnt(int(i)); return; }
    toast("Hedefe vardın."); return;
  }
  const auto path = routePath(sceneId, to);
  int exIdx = -1; if (path.size() > 1) for (const core::Json& e : (*scene_)["exits"].arr()) if (e[2].str() == path[1]) { exIdx = e[0].i(); break; }
  const std::vector<int>* r = nullptr; if (exIdx >= 0) for (const auto& g : map.regions) if (g.size() >= 6 && g[1] == 1 && g[0] == exIdx) { r = &g; break; }
  if (path.size() > 1 && exIdx < 0) {   // sıradaki adım yolculuk: o hedefe giden arabacıya/ışınlayıcıya yürü
    for (size_t i = 0; i < ents.size(); i++) {
      if (ents[i].kind != Ent::NPC) continue;
      const auto* L = travelOf(int(i)); if (!L) continue;
      for (const TravelOpt& x : *L) if (x.sid == path[1]) {
        travelHint = path[1]; { const std::string a = quests().name(ents[i].name), b = quests().name(as_.D()["scenes"][path[1]]["name"].str()); toast(T(a + " ile yolculuk: " + b, "Travel with " + a + ": " + b)); }
        walkToEnt(int(i)); return;
      }
    }
  }
  if (!r) { route.clear(); toast("Yol bulunamadı."); return; }
  bool f = false; int bx = 0, by = 0; double bd = 0;
  for (int y = (*r)[3]; y <= (*r)[5]; y++) for (int x = (*r)[2]; x <= (*r)[4]; x++) if (!map.blocked(x, y)) { const double d = jsHypot(x - player.x, y - player.y); if (!f || d < bd) { f = true; bx = x; by = y; bd = d; } }
  if (!f || !findPathTo(bx, by)) { player.pathOn = false; player.path.clear(); route.clear(); toast("Yol bulunamadı."); return; }
  goTarget = -1; setTarget(-1);
}

std::string World::npcSceneNear(const std::string& cn) const {
  const auto& L = bal_.quests.npcScenes(cn);
  if (std::find(L.begin(), L.end(), sceneId) != L.end()) return sceneId;
  std::string best; size_t bl = SIZE_MAX;
  for (const std::string& sid : L) { const auto p = scenePath(sceneId, sid); if (!p.empty() && p.size() < bl) { bl = p.size(); best = sid; } }
  return !best.empty() ? best : L.empty() ? std::string() : L[0];
}
std::string World::monSceneNear(const std::string& name, const std::string& scName) const {
  std::vector<std::string> L = bal_.quests.monScenes(name);
  if (!scName.empty()) { std::vector<std::string> F; for (const std::string& s : L) if (as_.D()["scenes"][s]["name"].str() == scName) F.push_back(s); if (!F.empty()) L = F; }
  if (std::find(L.begin(), L.end(), sceneId) != L.end()) return sceneId;
  std::string best; size_t bl = SIZE_MAX;
  for (const std::string& sid : L) { const auto p = scenePath(sceneId, sid); if (!p.empty() && p.size() < bl) { bl = p.size(); best = sid; } }
  return !best.empty() ? best : L.empty() ? std::string() : L[0];
}
void World::routeToNpc(const std::string& cn) {
  const std::string sid = npcSceneNear(cn); if (sid.empty()) { toast("Bu kişinin yeri bilinmiyor."); return; }
  if (sid == sceneId) { for (size_t i = 0; i < ents.size(); i++) if (ents[i].kind == Ent::NPC && ents[i].name == cn) { walkToEnt(int(i)); return; } return; }
  routeNpc = cn; routeQuest = 0; routeTo(sid);
}

// Görev yol bulma (orijinaldeki "寻路"): alınmamış → veren; hazır / konuş / teslim / özel → alan; öldür/topla → hedef canavar (bu haritada
// yaşayan varsa yanına yürüyüp seçer, saldırmaz; hepsi ölüyse doğdukları yere; yoksa canavarın haritasına); nesne toplama → nesne
void World::questWalk(int qi) {
  const Quest& q = quests().all()[size_t(qi)]; Player& p = player;
  auto near = [&](const std::function<bool(const Ent&)>& f) { int b = -1; double bd = 1e9; for (size_t i = 0; i < ents.size(); i++) if (f(ents[i])) { const double d = jsHypot(ents[i].x - p.x, ents[i].y - p.y); if (d < bd) { bd = d; b = int(i); } } return b; };
  auto goNpc = [&](const std::string& cn) { const int e = near([&](const Ent& e) { return e.kind == Ent::NPC && e.name == cn && !e.hidden; }); if (e >= 0) walkToEnt(e); else routeToNpc(cn); };
  auto away = [&](const std::string& sid) { routeNpc.clear(); routeQuest = q.id; routeTo(sid); };
  auto it = P.quests.find(q.id);
  if (it == P.quests.end()) { goNpc(q.giver); return; }
  const QuestSt& st = it->second;
  if (st.ready || (q.type != "kill" && q.type != "collect" && q.type != "pickup")) { goNpc(q.to); return; }
  if (q.type == "pickup") {
    int n = near([&](const Ent& e) { return e.kind == Ent::NPC && e.name == q.node && !e.hidden; });
    if (n < 0) n = near([&](const Ent& e) { return e.kind == Ent::NPC && e.name == q.node; });
    if (n >= 0) { walkToEnt(n); return; }
    const std::string sid = npcSceneNear(q.node); if (!sid.empty() && sid != sceneId) { away(sid); return; }
    toast("Toplanacak yer bilinmiyor."); goNpc(q.to); return;
  }
  std::vector<const QTarget*> rem; for (const QTarget& x : q.targets) { auto c = st.c.find(x.key()); if ((c == st.c.end() ? 0 : c->second) < x.n) rem.push_back(&x); }
  if (!rem.empty() && std::all_of(rem.begin(), rem.end(), [](const QTarget* x) { return x->kind == QTarget::NODE; })) {   // geriye yalnız yerdeki nesne (sandık)
    const int n = near([&](const Ent& e) { return e.kind == Ent::NPC && e.name == rem[0]->name && !e.hidden; }); if (n >= 0) { walkToEnt(n); return; }
    const std::string sid = npcSceneNear(rem[0]->name); if (!sid.empty() && sid != sceneId) { away(sid); return; }
  }
  std::vector<std::string> names;
  if (!q.targets.empty()) { for (const QTarget* x : rem) if (x->kind != QTarget::NODE && std::find(names.begin(), names.end(), x->name) == names.end()) names.push_back(x->name); }
  else if (!q.mobs.empty()) names = q.mobs; else names.push_back(q.target);
  auto has = [&](const std::string& n) { return std::find(names.begin(), names.end(), n) != names.end(); };
  const int t = near([&](const Ent& e) { return e.kind == Ent::MOB && !e.dead && has(e.name); });
  if (t >= 0) { findPathTo(ents[size_t(t)].x, ents[size_t(t)].y + 1); goTarget = -1; setTarget(t); return; }   // yanına yürür ve seçer; saldırmaz
  const int spot = near([&](const Ent& e) { return e.kind == Ent::MOB && has(e.name); });   // hepsi ölü: doğdukları yere
  if (spot >= 0) { findPathTo(ents[size_t(spot)].x, ents[size_t(spot)].y + 1); goTarget = -1; setTarget(-1); toast("Canavarlar yeniden doğuyor; doğdukları yere gidiliyor."); return; }
  std::string best; size_t bl = SIZE_MAX;
  for (const std::string& n : names) { const std::string sid = monSceneNear(n, q.sc); if (sid.empty()) continue; const auto L = scenePath(sceneId, sid); const size_t l = L.empty() ? size_t(1e8) : L.size(); if (l < bl) { bl = l; best = sid; } }
  if (!best.empty() && best != sceneId) { away(best); return; }
  toast("Hedef canavarın yeri bilinmiyor.");
}

// ---------------- yolculuk ----------------
const std::vector<TravelOpt>* World::travelOf(int ei) const {
  if (ei < 0 || ents[size_t(ei)].kind != Ent::NPC) return nullptr;
  auto it = bal_.travel.find(ents[size_t(ei)].id); return it == bal_.travel.end() ? nullptr : &it->second;
}
int World::travelCost(int ei, const TravelOpt& x) const {
  if (gmFreeTravel) return 0;
  if (x.kind == "araba") return bal_.travelCar;
  auto it = bal_.travelFee.find(ents[size_t(ei)].name); return it == bal_.travelFee.end() ? 0 : it->second;
}
std::string World::travelLabel(int ei, const TravelOpt& x) const {
  const int c = travelCost(ei, x);
  return (x.kind == "tp" ? T("Işınlan: ", "Teleport: ") : T("Yolculuk: ", "Travel: ")) + bal_.quests.name(x.name) + (c ? T(" (" + std::to_string(c) + " altın)", " (" + std::to_string(c) + " gold)") : std::string());
}
bool World::travelGo(int ei, const TravelOpt& x) {
  const int c = travelCost(ei, x);
  if (c && P.gold < c) { toast(T(std::to_string(c) + " altın gerekir.", "Requires " + std::to_string(c) + " gold.")); return false; }
  P.gold -= c; note(travelLabel(ei, x), LOG_Q); travelHint.clear(); sfx("menusel", 0.6);
  const TravelOpt to = x;   // loadScene varlıkları değiştirir
  if (to.hasXY) { const int a[2] = {to.x, to.y}; loadScene(to.sid, a); } else loadScene(to.sid);
  return true;
}

// ölünce: can ve mananın yarısıyla; ev (ışınlanma görevinin yeri; Guanlin'e gelmişse Guanlin) varsa orada, yoksa haritanın girişinde
void World::revive() {
  Player& p = player; const Stats s = stats();
  p.dead = false; p.state = "idle"; p.hp = jsRound(s.hp * 0.5); p.mp = jsRound(s.mp * 0.5);
  if (dungeonOnRevive()) return;   // zindanda öldüysen kapının dışında
  if (!P.hasHome && (P.done.count(80003) || P.quests.count(80003))) { P.hasHome = true; P.homeScene = "120005"; P.homeXY = true; P.homeX = 33; P.homeY = 20; }
  if (P.hasHome) {
    const double hp = p.hp, mp = p.mp;
    if (P.homeXY) { const int a[2] = {P.homeX, P.homeY}; loadScene(P.homeScene, a); } else loadScene(P.homeScene);
    player.hp = hp; player.mp = mp;
  } else for (const auto& r : map.regions) if (r.size() >= 6 && r[1] == 0) { p.x = r[2]; p.y = r[3]; break; }
}

}  // namespace engine
