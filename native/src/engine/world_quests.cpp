// Görevler: HTML game.js › Görevler (questState, acceptQuest, questKill, tgAdd, questUseItem, questFlag, readyQuest, completeQuest,
// classUp, autoQuests, questsFor, npcMark, pickupNode, interact, ClassGM.ready/done) ve win.js konuşma düğmeleri (Kabul, Tamamla).
// Zarlar HTML'deki sırayla atılır (görev listesi sırası; toplama şansı yalnız hedef uyunca).
#include <algorithm>

#include "world.h"

namespace engine {

bool World::itemExists(const std::string& id) const { return bal_.item(id) != nullptr; }

// HTML questState: done · ready (teslim bekliyor) · active · locked (ırk, sınıf, önkoşul, yükseltme) · soon (seviye yetmiyor) · new
std::string World::questState(int qi) {
  const Quest& q = quests().all()[size_t(qi)];
  if (P.done.count(q.id)) return "done";
  auto it = P.quests.find(q.id);
  if (it != P.quests.end()) return it->second.ready || (q.type == "deliver" && giveCount(q) >= q.count) ? "ready" : "active";
  if ((!q.race.empty() && q.race != P.race) || (!q.cls.empty() && q.cls != P.cls)) return "locked";
  if (!q.req.empty()) {
    bool ok = !q.reqAny;   // tek önkoşul: o bitmiş olmalı; liste: herhangi biri
    if (q.reqAny) { for (int r : q.req) if (P.done.count(r)) ok = true; } else ok = P.done.count(q.req[0]) > 0;
    if (!ok) return "locked";
  }
  if (q.advMin && P.adv != q.advMin) return "locked";
  if (P.lv < quests().minLv(qi)) return "soon";
  return "new";
}

// teslim görevi: çantadaki eşyalar (q.give numaraları) sayılır, tamamlanınca alınır
int World::giveCount(const Quest& q) const { int n = 0; for (const std::string& id : q.give) n += countItem(id); return n; }
void World::takeGive(const Quest& q) {
  int n = q.count;
  for (const std::string& id : q.give) { const int k = std::min(n, countItem(id)); if (k) { removeItem(id, k); n -= k; } }
}

// görev alınınca: accItems görev eşyası çantaya konur (ör. Büyü Emici Küre); özel görevin bayrağı zaten varsa hemen hazır
void World::acceptQuest(int qi) {
  const Quest& q = quests().all()[size_t(qi)];
  QuestSt st; st.ready = q.type == "talk"; P.quests[q.id] = st;
  for (const auto& a : q.accItems) if (!countItem(a.first)) addItem(a.first, a.second);
  if (q.type == "special" && flags.count(q.flag)) P.quests[q.id].ready = true;
  note("Görev alındı: " + q.tr.title, LOG_Q);
}

void World::readyQuest(int qi) {
  const Quest& q = quests().all()[size_t(qi)];
  P.quests[q.id].ready = true;
  toast("Görev tamamlandı: " + q.tr.title); note(q.tr.title + " tamam. " + quests().name(q.to) + " ile konuş.", LOG_Q);
}

// çok hedefli görevin bir sayacını artır; hepsi dolunca görev hazır
bool World::tgAdd(int qi, QuestSt& st, const QTarget& x) {
  const Quest& q = quests().all()[size_t(qi)];
  int& c = st.c[x.key()];
  if (c >= x.n) return false;
  c++; st.n++;
  bool all = true; for (const QTarget& y : q.targets) { auto it = st.c.find(y.key()); if ((it == st.c.end() ? 0 : it->second) < y.n) all = false; }
  if (all) readyQuest(qi);
  return true;
}

// canavar öldürülünce (HTML questKill; killMob'da ganimetten sonra, evcil yumurtasından önce)
void World::questKill(const std::string& name) {
  const auto& Q = quests().all();
  for (size_t qi = 0; qi < Q.size(); qi++) {
    const Quest& q = Q[qi];
    auto it = P.quests.find(q.id); if (it == P.quests.end() || it->second.ready) continue;
    QuestSt& st = it->second;
    if (q.type == "kill" && !q.targets.empty()) {   // çok hedefli: her hedefin kendi sayacı, toplam st.n
      for (const QTarget& x : q.targets) {
        if (x.name != name || x.kind == QTarget::NODE || x.kind == QTarget::USE) continue;
        if (x.kind == QTarget::DROP) { if (random() < x.chance) tgAdd(int(qi), st, x); continue; }   // canavardan düşen eşya
        // önce görev eşyası kullanılmalıysa (Büyü Emici Küre) kullanılmadan öldürmek sayılmaz
        bool useFirst = false;
        for (const QTarget& y : q.targets) if (y.name == name && y.kind == QTarget::USE) { auto c = st.c.find(y.key()); if ((c == st.c.end() ? 0 : c->second) < y.n) { useFirst = true; break; } }
        if (useFirst) { note("Önce " + quests().name(x.item) + " kullanılmalıydı."); continue; }
        tgAdd(int(qi), st, x);
      }
      continue;
    }
    if (q.type == "collect" && !q.drops.empty()) {   // çok eşyalı toplama: q.mobs'tan biri her öldürmede eksik eşyaların her biri için şans
      const bool mine = q.mobs.empty() ? q.target == name : std::find(q.mobs.begin(), q.mobs.end(), name) != q.mobs.end();
      if (!mine) continue;
      for (size_t i = 0; i < q.drops.size(); i++) {
        const std::string k = "d" + std::to_string(i); int& c = st.c[k];
        if (c < q.drops[i].first && random() < q.drops[i].second) { c++; st.n++; }
      }
      bool all = true; for (size_t i = 0; i < q.drops.size(); i++) if (st.c["d" + std::to_string(i)] < q.drops[i].first) all = false;
      if (all) readyQuest(int(qi));
      continue;
    }
    if (q.type == "kill" && q.target == name) { st.n++; if (st.n >= q.count) readyQuest(int(qi)); }
    if (q.type == "collect" && q.target == name && random() < q.chance) { st.n++; if (st.n >= q.count) readyQuest(int(qi)); }
  }
}

// görev eşyasını kullan (Büyü Emici Küre): hedefteki canavar görevin 'use' hedefi olmalı ve yakında
bool World::questUseItem(const std::string& id) {
  const auto& Q = quests().all();
  for (size_t qi = 0; qi < Q.size(); qi++) {
    const Quest& q = Q[qi]; auto it = P.quests.find(q.id); if (it == P.quests.end() || it->second.ready || q.targets.empty()) continue;
    const QTarget* x = nullptr; for (const QTarget& y : q.targets) if (y.kind == QTarget::USE && y.itemId == id) { x = &y; break; }
    if (!x) continue;
    { auto c = it->second.c.find(x->key()); if ((c == it->second.c.end() ? 0 : c->second) >= x->n) continue; }
    const int t = target_;
    if (t < 0 || ents[t].dead || ents[t].name != x->name) { toast("Önce " + quests().name(x->name) + " hedef al."); return false; }
    if (jsHypot(ents[t].x - player.x, ents[t].y - player.y) > 6) { toast("Çok uzak."); return false; }
    const int f = pushFx("特效-治疗buff", ents[t].x, ents[t].y); fx[f].follow = t;
    removeItem(id); tgAdd(int(qi), it->second, *x); return true;
  }
  toast("Bunu şimdi kullanamazsın.");
  return false;
}

void World::questFlag(const std::string& f) {
  flags.insert(f);
  const auto& Q = quests().all();
  for (size_t qi = 0; qi < Q.size(); qi++) { auto it = P.quests.find(Q[qi].id); if (it != P.quests.end() && !it->second.ready && Q[qi].type == "special" && Q[qi].flag == f) readyQuest(int(qi)); }
}

// görevi teslim et: altın (ırk becerisiyle artar), eşyalar (sınıfa göre), deneyim, sınıf yükseltmesi
bool World::completeQuest(int qi) {
  const Quest& q = quests().all()[size_t(qi)];
  if (q.type == "deliver") { if (giveCount(q) < q.count) { toast(q.tr.item + ": " + std::to_string(giveCount(q)) + "/" + std::to_string(q.count)); return false; } takeGive(q); }
  P.quests.erase(q.id); P.done.insert(q.id);
  if (q.gold) P.gold += (long long)jsRound(q.gold * (1 + stats().goldUp / 100));
  for (const Quest::RItem& it : q.items) {
    if (!itemExists(it.id) || (!it.cls.empty() && std::find(it.cls.begin(), it.cls.end(), P.cls) == it.cls.end())) continue;
    addItem(it.id, it.n);
  }
  gainXp(q.xp);
  if (q.xp || q.gold) note("Ödül: " + std::to_string(q.xp) + " TP" + (q.gold ? ", " + std::to_string(q.gold) + " altın" : ""), LOG_Q);
  if (q.adv) classUp(q.adv);
  return true;
}

// sınıf yükseltmesi (40: sınıf ağacı, 80: uzmanlık ağaçları)
void World::classUp(int n) {
  if (P.adv >= n) return;
  P.adv = n; pushFx("LEVELUP", player.x, player.y);
  toast("Sınıf yükseltildi"); note(n >= 2 ? "Sınıf yükseltildi · uzmanlık ağaçları açıldı" : "Sınıf yükseltildi · sınıf beceri ağacı açıldı", LOG_Q);
}

// seviyesi gelince kendiliğinden alınan görevler (orijinalde verensiz "gönderilen" görev: 80344 Acemilikten Çıkış)
void World::autoQuests() {
  const auto& Q = quests().all();
  for (size_t qi = 0; qi < Q.size(); qi++) if (Q[qi].auto_ && questState(int(qi)) == "new") { acceptQuest(int(qi)); toast("Yeni görev: " + Q[qi].tr.title); }
}

std::vector<int> World::questsFor(const std::string& cn) {
  std::vector<int> out; const auto& Q = quests().all();
  for (size_t i = 0; i < Q.size(); i++) {
    const Quest& q = Q[i]; const int qi = int(i);
    if ((q.giver == cn && questState(qi) == "new") || (q.to == cn && questState(qi) == "ready") || ((q.to == cn || q.giver == cn) && questState(qi) == "active")) out.push_back(qi);
  }
  return out;
}
char World::npcMark(const std::string& cn) {
  const auto& Q = quests().all();
  for (size_t i = 0; i < Q.size(); i++) if (Q[i].to == cn && questState(int(i)) == "ready") return '?';
  for (size_t i = 0; i < Q.size(); i++) if (Q[i].giver == cn && questState(int(i)) == "new") return '!';
  return 0;
}
int World::tpQuestOf(const std::string& cn) {
  const auto& Q = quests().all();
  for (size_t i = 0; i < Q.size(); i++) if (Q[i].hasTp && Q[i].giver == cn && (P.quests.count(Q[i].id) || P.done.count(Q[i].id))) return int(i);
  return -1;
}
// ışınlanma görevi: gidilen yer "ev" olur (ölünce orada doğulur)
void World::questTeleport(int qi) {
  const Quest& q = quests().all()[size_t(qi)];
  P.hasHome = true; P.homeScene = q.tpScene; P.homeXY = q.tpHasXY; P.homeX = q.tpX; P.homeY = q.tpY;
  if (q.tpHasXY) { const int a[2] = {q.tpX, q.tpY}; loadScene(q.tpScene, a); } else loadScene(q.tpScene);
}

// toplama noktası (görev nesnesi): çok hedefli görevin sandığı ya da toplama görevi; alınınca 20 sn kaybolur
void World::pickupNode(int ei) {
  Ent& n = ents[size_t(ei)]; const auto& Q = quests().all();
  for (size_t qi = 0; qi < Q.size(); qi++) {
    const Quest& q = Q[qi]; auto it = P.quests.find(q.id); if (it == P.quests.end() || it->second.ready || q.targets.empty()) continue;
    const QTarget* x = nullptr; for (const QTarget& y : q.targets) if (y.kind == QTarget::NODE && y.name == n.name) { x = &y; break; }
    if (!x) continue;
    { auto c = it->second.c.find(x->key()); if ((c == it->second.c.end() ? 0 : c->second) >= x->n) continue; }
    tgAdd(int(qi), it->second, *x); n.hidden = true; n.respawnT = 20; return;
  }
  for (size_t qi = 0; qi < Q.size(); qi++) {
    const Quest& q = Q[qi]; if (q.type != "pickup" || q.node != n.name) continue;
    auto it = P.quests.find(q.id); if (it == P.quests.end() || it->second.ready) continue;
    it->second.n++; n.hidden = true; n.respawnT = 20;
    if (it->second.n >= q.count) readyQuest(int(qi));
    return;
  }
}

// kişiye dokun (HTML interact): toplama noktası, görev nesnesi; "kullan/ver" ve konuşma görevleri tamamlanır; sonra konuşma penceresi
void World::interact(int ei) {
  Ent& e = ents[size_t(ei)]; if (e.kind != Ent::NPC) return;
  player.dir = dirOf(e.x - player.x, e.y - player.y);
  if (e.node || e.dummy) return;   // maden/kalıntı ve sergi (yaşam becerileri sonra)
  if (e.pickup) { pickupNode(ei); return; }
  const auto& Q = quests().all();
  for (size_t qi = 0; qi < Q.size(); qi++) {   // hedefi bir kişi olan "kullan/ver" görevleri (iksiri Gary'ye içir)
    auto it = P.quests.find(Q[qi].id);
    if (it != P.quests.end() && !it->second.ready && Q[qi].type == "pickup" && Q[qi].node == e.name) { it->second.n = Q[qi].count; readyQuest(int(qi)); }
  }
  for (size_t qi = 0; qi < Q.size(); qi++) {   // konuşma görevleri
    auto it = P.quests.find(Q[qi].id);
    if (it != P.quests.end() && !it->second.ready && Q[qi].type == "talk" && Q[qi].to == e.name) it->second.ready = true;
  }
}

// konuşmada "Kabul": ışınlanma görevinde oraya gidilir; görevi veren aynı zamanda alansa konuşma görevi hemen hazır
void World::dialogAccept(int qi, const std::string& cn) {
  const Quest& q = quests().all()[size_t(qi)];
  acceptQuest(qi);
  if (q.hasTp) { questTeleport(qi); return; }
  if (q.type == "talk" && q.to == cn) P.quests[q.id].ready = true;
}
bool World::dialogComplete(int qi) { return completeQuest(qi); }

// sıradaki yakın canavarı hedef al (9 kare içinde, yakından uzağa); saldırı başlatmaz
void World::cycleTarget() {
  std::vector<std::pair<double, int>> L;
  for (size_t i = 0; i < ents.size(); i++) { const Ent& e = ents[i]; if (e.kind != Ent::MOB || e.dead) continue; const double d = jsHypot(e.x - player.x, e.y - player.y); if (d < 9) L.push_back({d, int(i)}); }
  if (L.empty()) { note("Yakında hedef yok."); return; }
  std::stable_sort(L.begin(), L.end(), [](const auto& a, const auto& b) { return a.first < b.first; });
  int k = -1; for (size_t i = 0; i < L.size(); i++) if (L[i].second == target_) k = int(i);
  setTarget(L[size_t(k + 1) % L.size()].second);
  questFlag("cycleTarget");
}

// GM (HTML ClassGM.ready / done): görevi öncekileriyle birlikte tamamlanmış say; done ödülü de verir
void World::gmQuestReady(int id) {
  const int qi = quests().indexOf(id); if (qi < 0 || P.done.count(id)) return;
  const Quest* q = &quests().all()[size_t(qi)];
  if (!q->reqAny) for (int r = q->req.empty() ? 0 : q->req[0]; r && !P.done.count(r);) {
    P.done.insert(r); P.quests.erase(r);
    const Quest* pq = quests().byId(r); r = pq && !pq->reqAny && !pq->req.empty() ? pq->req[0] : 0;
  }
  if (!P.quests.count(id)) acceptQuest(qi);
  readyQuest(qi);
}
void World::gmQuestDone(int id) {
  const int qi = quests().indexOf(id); if (qi < 0 || P.done.count(id)) return;
  gmQuestReady(id);
  if (quests().all()[size_t(qi)].type == "deliver") return;
  completeQuest(qi);
}

}  // namespace engine
