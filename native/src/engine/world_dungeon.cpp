// Zindanlar (副本): HTML www/js/dungeon.js (docs/03-istemci.md › Zindanlar). Veri zindan.json (tools/zindan_cikar.js).
// Kapılar: alan haritalarında geçit tablosuna bağlanmamış geçit bölgeleri. Her girişte oyuncuya kendi kopyası açılır: normal zindanda
// kesilen canavar bu koşuda yeniden doğmaz, son boss ölünce sandık; çıkınca ya da ölünce koşu kapanır. Sınav (练级) zindanı: zayıf
// canavarlar yeniden doğar, giriş sınırı yok. Şimdilik tek kişi (grup girişi çevrimiçi grup sistemiyle).
#include <cmath>
#include <ctime>
#include <limits>

#include "engine/world.h"

namespace engine {

const DungeonDef* World::dungeonOf(const std::string& sid, int* copy) const {
  for (const DungeonDef& d : bal_.dungeons) for (size_t c = 0; c < d.copies.size(); c++) for (const std::string& s : d.copies[c].scenes) if (s == sid) { if (copy) *copy = int(c); return &d; }
  return nullptr;
}
static std::string utcDay() { std::time_t t = std::time(nullptr); char b[16]; std::strftime(b, sizeof b, "%Y-%m-%d", std::gmtime(&t)); return b; }
int World::dungeonUsedToday(const DungeonDef& d) const {
  const std::string day = today.empty() ? utcDay() : today;
  if (P.dgDay != day) return 0;
  auto it = P.dgN.find(d.id); return it == P.dgN.end() ? 0 : it->second;
}

// kapının dışındaki varış noktası: kapı bölgesinin yanındaki giriş bölgesi (arrivalNear)
std::pair<int, int> World::dungeonOutside(const DungeonCopy& c) {
  GameMap tmp; tmp.load(as_, as_.D()["scenes"][c.doorScene]["map"].str());
  const std::vector<int>* r = arrivalNear(tmp.regions, c.doorRegion);
  if (!r) return {-1, -1};
  return {int(jsRound(((*r)[2] + (*r)[4]) / 2.0)), int(jsRound(((*r)[3] + (*r)[5]) / 2.0))};
}

// alan haritasındaki kapıya basınca: seviye, ön görev, günlük hak; onay kutusu
bool World::dungeonDoor(int region) {
  const DungeonDef* d = nullptr; int copy = 0;
  for (const DungeonDef& x : bal_.dungeons) for (size_t c = 0; c < x.copies.size(); c++) if (x.copies[c].doorScene == sceneId && x.copies[c].doorRegion == region) { d = &x; copy = int(c); }
  if (!d) return false;
  if (warnT > 0) return true;
  warnT = 3;
  const std::string nm = quests().name(d->cn);
  if (P.lv < d->lv) { toast(nm + ": " + std::to_string(d->lv) + ". seviyede girilir."); return true; }
  if (d->req && !P.done.count(d->req)) { const Quest* q = quests().byId(d->req); toast(nm + ": önce \"" + (q ? q->tr.title : std::to_string(d->req)) + "\" görevini bitir."); return true; }
  const int left = d->daily ? d->daily - dungeonUsedToday(*d) : std::numeric_limits<int>::max();
  if (left <= 0) { toast(nm + ": bugünkü giriş hakkın bitti."); return true; }
  const std::string info = d->train ? "Sınav zindanı: canavarlar zayıf ama çok, yeniden doğar." : "Bugün kalan giriş: " + std::to_string(left) + "/" + std::to_string(d->daily) + ".";
  ask(nm + " (Sv " + std::to_string(d->lv) + "+) · " + info + " Girilsin mi?", [this, d, copy] { dungeonEnter(*d, copy); });
  return true;
}
void World::dungeonEnter(const DungeonDef& d, int copy) {
  if (d.daily) { const std::string day = today.empty() ? utcDay() : today; if (P.dgDay != day) { P.dgDay = day; P.dgN.clear(); } P.dgN[d.id]++; }
  P.dun = CharData::Run(); P.dun.on = true; P.dun.id = d.id; P.dun.copy = copy;
  note("Zindana girdin: " + quests().name(d.cn), LOG_Q);
  const std::string from = sceneId; gotoScene(d.copies[size_t(copy)].scenes[0], from);
}
// kapının dışına çık (zindandan çıkış geçidi, sandıktan sonra, ölüm); koşu kapanır
void World::dungeonLeave(bool dead) {
  int c = -1; const DungeonDef* d = dungeonOf(sceneId, &c);
  if (!d && P.dun.on) for (const DungeonDef& x : bal_.dungeons) if (x.id == P.dun.id) { d = &x; c = P.dun.copy; }
  if (!d) return;
  const DungeonCopy& k = d->copies[size_t(std::max(0, std::min(int(d->copies.size()) - 1, c)))];
  P.dun = CharData::Run();
  if (!dead) note("Zindandan çıktın: " + quests().name(d->cn), LOG_Q);
  const auto at = dungeonOutside(k);
  if (at.first >= 0) { const int a[2] = {at.first, at.second}; loadScene(k.doorScene, a); } else loadScene(k.doorScene);
}
// harita yüklenince: zindanın içindeysek koşu kaydı olsun (yeniden açılan oyun, GM ışınlanması); dışarıdaysak kapanır
void World::dungeonOnLoad(const std::string& sid) {
  int c = -1; const DungeonDef* d = dungeonOf(sid, &c);
  if (d) { if (!P.dun.on || P.dun.id != d->id) { P.dun = CharData::Run(); P.dun.on = true; P.dun.id = d->id; P.dun.copy = c; } }
  else if (P.dun.on) P.dun = CharData::Run();
}
// canavar değerleri: sınav zindanında zayıf; zindan boss'u tek kişiyle yenilebilir (alan boss'unun ×18 canı yerine ×8, ×1,8 saldırısı yerine ×1,2)
void World::dungeonTune(Ent& m) {
  const DungeonDef* d = dungeonOf(sceneId); if (!d) return;
  if (d->train) { m.maxHp = m.hp = jsRound(m.hp * 0.7); m.atk = jsRound(m.atk * 0.6); m.def = jsRound(m.def * 0.5); }
  if (const Balance::MobRec* info = bal_.mobInfo(m.name)) if (info->prog) m.prog = true;   // orijinal zindan ilerleme boss'u
  if (m.d->rank == 2 || m.prog) { m.maxHp = m.hp = jsRound(m.hp * 8 / 18 * (d->bossX && m.name == d->boss ? d->bossX : 1)); m.atk = jsRound(m.atk * 1.2 / 1.8); m.boss = true; }
}
void World::dungeonOnKill(Ent& m) {
  const DungeonDef* d = dungeonOf(sceneId); if (!d || !P.dun.on) return;
  if (!d->train) { m.respawnT = std::numeric_limits<double>::infinity(); if (!m.key.empty()) P.dun.cleared.insert(m.key); }
  // son boss (d.boss; yoksa herhangi bir boss) zindanı tamamlar: sandık (altın, seviyeye uygun ekipman, iksir), sonra "çıkılsın mı?"
  if (m.boss && (d->boss.empty() || m.name == d->boss) && !P.dun.boss) {
    P.dun.boss = true;
    const int L = m.d->lv; const long long gold = 40LL * L; P.gold += gold;
    std::string got;
    for (int k = 0; k < 2; k++) {
      if (k && random() < 0.5) continue;
      const std::string g = randomGear(std::max(1, L + 2)); if (!g.empty()) { addItem(g, 1, true); got += ", " + itemName(g); }
    }
    addItem(P.lv > 10 ? "hp2" : "hp1", 3);
    pushFx("LEVELUP", player.x, player.y);
    const std::string nm = quests().name(d->cn);
    toast(nm + ": zindan tamamlandı!");
    note("Zindan sandığı: " + std::to_string(gold) + " altın" + got, LOG_Q);
    later(1.5, [this, nm] { ask(nm + ": zindan tamamlandı! Zindandan çıkılsın mı?", [this] { dungeonLeave(false); }); });
  }
}
// ölünce: kapının dışında dirilir, koşu kapanır
bool World::dungeonOnRevive() {
  if (!dungeonOf(sceneId)) return false;
  note("Zindanda öldün; kapının dışında dirildin.", LOG_Q); dungeonLeave(true); return true;
}
// kişinin zindan ışınlanmaları (merkeze / merkezden; konuşmada "✦" seçeneği)
std::vector<std::pair<std::string, const DungeonTp*>> World::dungeonTps(const std::string& cn) const {
  auto it = bal_.dungeonTp.find(cn); if (it == bal_.dungeonTp.end()) return {};
  return {{it->second.label, &it->second}};
}
void World::dungeonTpGo(const DungeonTp& t) {
  if (t.lv && P.lv < t.lv) { toast(std::to_string(t.lv) + ". seviye gerekir."); return; }
  if (t.hasXY) { const int a[2] = {t.x, t.y}; loadScene(t.sid, a); } else gotoScene(t.sid, "");
}

// ---------------- GM (HTML Dungeon.GM) ----------------
void World::gmDungeonEnter(const std::string& id, int copy) {   // seviye/ön görev/günlük sınır olmadan doğrudan içeri (sayaç artmaz)
  for (const DungeonDef& d : bal_.dungeons) if (d.id == id) {
    const int c = std::min(copy, int(d.copies.size()) - 1);
    P.dun = CharData::Run(); P.dun.on = true; P.dun.id = d.id; P.dun.copy = c; gotoScene(d.copies[size_t(c)].scenes[0], ""); return;
  }
}
void World::gmDungeonDoor(const std::string& id, int copy) {
  for (const DungeonDef& d : bal_.dungeons) if (d.id == id) {
    const DungeonCopy& k = d.copies[size_t(std::min(copy, int(d.copies.size()) - 1))]; const auto at = dungeonOutside(k);
    if (at.first >= 0) { const int a[2] = {at.first, at.second}; loadScene(k.doorScene, a); } else gotoScene(k.doorScene, "");
    return;
  }
}
void World::gmDungeonBoss() {
  for (size_t i = 0; i < ents.size(); i++) if (ents[i].kind == Ent::MOB && !ents[i].dead && ents[i].boss) { killMob(int(i)); return; }
  toast("Bu haritada boss yok.");
}
void World::gmDungeonClear() {
  std::vector<int> L; for (size_t i = 0; i < ents.size(); i++) if (ents[i].kind == Ent::MOB && !ents[i].dead && !ents[i].boss) L.push_back(int(i));
  for (int i : L) killMob(i);
}
void World::gmDungeonLast() {
  int c = -1; const DungeonDef* d = dungeonOf(sceneId, &c); if (!d) { toast("Zindanda değilsin."); return; }
  const auto& L = d->copies[size_t(c)].scenes; int here = -1; for (size_t i = 0; i < L.size(); i++) if (L[i] == sceneId) here = int(i);
  gotoScene(L[size_t(int(L.size()) - 1 == here ? 0 : int(L.size()) - 1)], "");
}

}  // namespace engine
