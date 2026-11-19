#include "world.h"

#include <algorithm>
#include <cmath>

namespace engine {

Rng& rng() { static Rng r; return r; }

static const int DIR4[4][2] = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};

int dirOf(double dx, double dy) {
  const double ax = std::fabs(dx), ay = std::fabs(dy);
  if (ax > 0 && ay > 0 && std::fabs(ax - ay) < 0.2 * std::max(ax, ay)) {
    if (dx > 0 && dy < 0) return 1;   // ekranda sağa
    if (dx < 0 && dy > 0) return 3;   // ekranda sola
    return dy > 0 ? 2 : 0;            // ekranda aşağı / yukarı
  }
  if (ax > ay) return dx > 0 ? 1 : 3;
  return dy > 0 ? 2 : 0;
}

// efektin hangi animasyonu (HTML fxAnim): 8 yuvalı yönlü efektlerde yön → yuva [1,3,7,5]; değilse çok kareli animasyonlardan yöne göre
int fxAnim(const Sprite& sp, int dir) {
  if (!sp.ok()) return 0;
  std::vector<int> L; for (const core::Json& a : sp.A()["a"].arr()) L.push_back(int(a.size()));
  static const int FX8[4] = {1, 3, 7, 5};
  if (L.size() == 8 && L[1] > 1 && L[3] > 1 && L[5] > 1 && L[7] > 1) return FX8[((dir % 4) + 4) % 4];
  std::vector<int> cand; for (size_t i = 0; i < L.size(); i++) if (L[i] > 1) cand.push_back(int(i));
  if (cand.empty()) { for (size_t k = 0; k < L.size(); k++) if (L[k] > 0 && (k > 0 || L.size() == 1)) return int(k); return 0; }
  const int n = int(cand.size());
  return n == 1 ? cand[0] : cand[((dir % n) + n) % n];
}

// ---------------- karakter ----------------
void World::setChar(const std::string& cls, const std::string& race, const std::string& sex) {
  P.cls = cls; P.race = race; P.sex = sex;
  Look l; l.cls = cls; l.race = race; l.sex = sex;   // ekipman görünümü (eşyanın gfx alanı) arayüz adımında
  setLook(l);
}

void World::setLevel(int lv) {   // HTML gmLevel
  const int n = int(clampd(jsRound(lv), 1, 120)), d = n - P.lv; P.lv = n; P.xp = 0; if (d > 0) P.sp += d;
  const Stats s = stats(); player.hp = s.hp; player.mp = s.mp;
}

// HTML stats(): sınıf tabanı + seviye artışı + ekipman + edilgen beceriler ve ırk becerileri + güçlendirmeler + dönüşümler; hepsi yuvarlanır
Stats World::stats() const {
  const ClassBase& C = bal_.cls(P.cls); const int L = P.lv - 1;
  Stats s; s.hp = C.hp + C.ghp * L; s.mp = C.mp + C.gmp * L; s.atk = C.atk + C.gatk * L; s.def = C.def + C.gdef * L;
  for (const auto& kv : P.eq) {
    const Item* it = bal_.item(kv.second); if (!it) continue;
    for (const auto& st : it->st) {
      const std::string& k = st.first; const double v = st.second;
      if (k == "hp") s.hp += v; else if (k == "mp") s.mp += v; else if (k == "atk") s.atk += v; else if (k == "def") s.def += v;
      else if (k == "crit") s.crit += v; else if (k == "dodge") s.dodge += v; else if (k == "hpreg") s.hpreg += v; else if (k == "mpreg") s.mpreg += v; else if (k == "res") s.res += v;
    }
  }
  s.dr = 0; s.spd = 0;
  // edilgen beceriler (orijinal kademe sabitleri) ve ırk becerileri; yüzdeler ve dönüşümler en sonda
  Vals X;
  auto pasOf = [&](const SkillDef& sk) {
    if (!skRank(sk) || !sk.pas) return;
    SkCtx c{const_cast<World&>(*this), sk, s, P.lv, nullptr};
    for (const auto& kv : sk.pas(c).v) X.add(kv.first, kv.second);
  };
  for (const SkillDef& sk : skills()) pasOf(sk);
  for (const SkillDef& sk : bal_.skills.race(P.race)) pasOf(sk);
  const std::pair<const char*, double*> adds[] = {{"atk", &s.atk}, {"def", &s.def}, {"res", &s.res}, {"hp", &s.hp}, {"mp", &s.mp}, {"dodge", &s.dodge},
                                                  {"crit", &s.crit}, {"hpreg", &s.hpreg}, {"mpreg", &s.mpreg}, {"dr", &s.dr}};
  for (const auto& a : adds) { const double x = X.get(a.first); if (x) *a.second += x; }
  s.hp *= 1 + X.get("hpPct") / 100; s.mp *= 1 + X.get("mpPct") / 100;
  s.acc = X.get("acc"); s.healUp = X.get("healUp"); s.ccDmg = X.get("ccDmg"); s.despair = X.get("despair"); s.cheatDeath = X.get("cheatDeath");
  s.seal = X.get("seal"); s.veil = X.get("veil"); s.goldUp = X.get("goldUp"); s.lifeEl = X.get("lifeEl");
  // İlahi Işık Dökümü (90320): can/mana sınırının yüzdesi (sınırlar hesaplandıktan sonra)
  for (const SkillDef& sk : skills()) if (sk.sn == 90320) { if (skRank(sk)) { const double v = skC(sk, "add_hp_resume_rate") / 100; s.hpreg += s.hp * v; s.mpreg += s.mp * v; } break; }
  for (const Buff& b : player.buffs) {
    const Vals& B = b.buff; double a;
    if ((a = B.get("atk"))) s.atk *= 1 + a;
    if ((a = B.get("def"))) { s.def *= 1 + a; if (a < 0) s.res *= 1 + a; }
    if ((a = B.get("spd"))) s.spd += a;
    if ((a = B.get("crit"))) s.crit += a;
    if ((a = B.get("dr"))) s.dr += a;
    if ((a = B.get("hpP"))) s.hp *= 1 + a;     // hpP/dodge/res: evcil hayvan haleleri de
    if ((a = B.get("dodge"))) s.dodge += a;
    if ((a = B.get("res"))) s.res += a;
    if ((a = B.get("atkAdd"))) s.atk += a;
    if ((a = B.get("defAdd"))) { s.def += a; s.res += a; }
    if ((a = B.get("mpAdd"))) s.mp += a;
  }
  // dönüşümler: Kan Ruhu (savunma → saldırı), Çelik İrade (saldırı → savunma/direnç), Büyü Yankısı (mana → büyü saldırısı)
  if (const double v = X.get("defToAtk")) s.atk += s.def / 100 * v;
  if (const double v = X.get("atkToDef")) { s.def += s.atk / 100 * v; s.res += s.atk / 100 * v; }
  if (const double v = X.get("mpToAtk")) s.atk += s.mp / 500 * v;
  // hız oranı (0,25 gibi) yuvarlanmaz (HTML'de de; önceden yuvarlanıp hız güçlendirmeleri 0'a iniyordu)
  for (double* v : {&s.hp, &s.mp, &s.atk, &s.def, &s.crit, &s.dodge, &s.hpreg, &s.mpreg, &s.res, &s.dr, &s.goldUp, &s.lifeEl,
                    &s.acc, &s.healUp, &s.ccDmg, &s.despair, &s.cheatDeath, &s.seal, &s.veil}) *v = jsRound(*v);
  return s;
}

void World::clampVitals() { const Stats s = stats(); player.hp = std::min(player.hp, s.hp); player.mp = std::min(player.mp, s.mp); }

// ---------------- beceri kademeleri ve ağaç kuralları (HTML skRank, skC, skLock, treePts, skillUp, skillAutoSpend, skillReset) ----------------
int World::skRank(const SkillDef& sk) const {
  if (!sk.race.empty()) return sk.race == P.race ? 1 : 0;
  auto it = P.sk.find(sk.id); return it == P.sk.end() ? 0 : it->second;
}
// kademe sabiti: becerinin kademesindeki değer (öğrenilmemişse 1. kademe); r verilirse o kademe
double World::skC(const SkillDef& sk, const std::string& key, int r) const {
  if (!sk.d) return 0;
  const core::Json& t = (*sk.d)["c"][key];
  if (!t.isArr() || !t.size()) return 0;
  const int k = int(clampd(r >= 0 ? r : std::max(1, skRank(sk)), 1, double(t.size())));
  return t[k - 1].num();
}
int World::skRankSn(int sn) const { const SkillDef* sk = bal_.skills.bySn(sn); return sk ? skRank(*sk) : 0; }
double World::skCSn(int sn, const std::string& key) const { const SkillDef* sk = bal_.skills.bySn(sn); return sk ? skC(*sk, key) : 0; }
int World::treePts(int treeId) const {
  const SkillTree* T = bal_.skills.tree(treeId); if (!T) return 0;
  int n = 0; for (const auto& c : T->cells) { auto it = P.sk.find(c.first->id); if (it != P.sk.end()) n += it->second; } return n;
}
// sınıf yükseltmesi gereken kökler (orijinal sınıf numaraları): 1 = 40. seviye, 2 = 80. seviye
static int advNeed(int cls) { switch (cls) { case 130004: case 130005: case 130011: return 1; case 130006: case 130008: case 130012: return 2; default: return 0; } }
std::string World::skLock(const SkillDef& sk) const {
  if (!sk.d || !sk.race.empty()) return "";
  const core::Json& rt = (*sk.d)["root"];
  if (rt.isObj()) {
    const int need = advNeed(rt["cls"].i()); if (need && P.adv < need) return "adv";
    if (treePts(rt["tree"].i()) < rt["pts"].i()) return "pts";
    if (rt["excl"].i() && skRankSn(rt["excl"].i())) return "excl";
  }
  const core::Json& pre = (*sk.d)["pre"];
  if (pre.isArr()) { const SkillDef* pk = bal_.skills.bySn(pre[0].i()); if (pk && skRank(*pk) < pre[1].i()) return "pre"; }
  return "";
}
bool World::skillUp(const SkillDef& sk) {
  const int r = skRank(sk);
  if (!sk.race.empty()) return false;
  if (r >= (sk.mx ? sk.mx : 10)) { toast("Bu beceri en yüksek kademede."); return false; }
  if (!skLock(sk).empty()) { toast(skLockMsg(sk)); return false; }
  if (P.sp < 1) { toast("Beceri puanın yok. Seviye atlayınca puan kazanırsın."); return false; }
  P.sp--; P.sk[sk.id] = r + 1; sfx("skill_levelup"); note(sk.name + ": kademe " + std::to_string(r + 1), LOG_Q); clampVitals(); save(); return true;
}
// her puan, öğrenilebilir beceriler arasında kademesi en düşük olana (eşitse önceki ağaç / önceki yuva); oyuncu gibi önce bir sonraki
// ağacı açacak kadar (acemi 35, sınıf 40), sonra en üstteki açık ağaç. spec: hangi uzmanlık (öbürü alınmaz)
void World::skillAutoSpend(int points, int spec) {
  const auto& T = bal_.skills.trees(P.cls); if (T.size() < size_t(3 + spec)) return;
  std::vector<const SkillDef*> tr[3];
  const SkillTree* src[3] = {&T[0], &T[1], &T[2 + spec]};
  for (int k = 0; k < 3; k++) for (const auto& c : src[k]->cells) tr[k].push_back(c.first);
  auto pick = [&](const std::vector<const SkillDef*>& L) -> const SkillDef* {
    const SkillDef* best = nullptr;
    for (const SkillDef* sk : L) { const int r = skRank(*sk); if (r >= (sk->mx ? sk->mx : 10) || !skLock(*sk).empty()) continue; if (!best || r < skRank(*best)) best = sk; }
    return best;
  };
  auto rootPts = [](const SkillTree& t) { if (t.cells.empty()) return 0; const core::Json& r = (*t.cells[0].first->d)["root"]; return r.isObj() ? r["pts"].i() : 0; };
  const int need0 = rootPts(T[1]), need1 = rootPts(T[2 + spec]);
  for (int n = 0; n < points; n++) {
    const SkillDef* best = nullptr;
    if (P.adv >= 1 && treePts(T[0].id) < need0) best = pick(tr[0]);
    else if (P.adv >= 2 && treePts(T[1].id) < need1) { best = pick(tr[1]); if (!best) best = pick(tr[0]); }
    if (!best) best = pick(tr[2]);
    if (!best) best = pick(tr[1]);
    if (!best) best = pick(tr[0]);
    if (!best) { P.sp += points - n; break; }
    P.sk[best->id] = skRank(*best) + 1;
  }
}
// puanları sıfırla: Eğitim Kitabı (30092 ya da 30788) harcanır; GM'de bedava
bool World::skillReset(bool free) {
  int spent = 0; for (const auto& kv : P.sk) spent += kv.second;
  if (!spent) { toast("Harcanmış beceri puanı yok."); return false; }
  if (!free && !removeItem("30092") && !removeItem("30788")) { toast("Eğitim Kitabı gerekir (beceri eğitmeninde satılır)."); return false; }
  P.sp += spent; P.sk.clear(); player.buffs.clear(); sfx("skill_levelup");
  note("Beceri puanları sıfırlandı: " + std::to_string(spent) + " puan geri geldi.", LOG_Q); clampVitals(); save(); return true;
}

int World::countItem(const std::string& id) const { for (const auto& b : P.bag) if (b.first == id) return b.second; return 0; }
// eşya adı (HTML ITEMS[id].name): eşya tablosu, ya da oyunun kendi iksirleri ve paketi
std::string World::itemName(const std::string& id) const { const Item* it = bal_.item(id); return it ? it->name : id; }

// eşya kullan (HTML useItem): ekipman kuşanılır, iksir, yiyecek (süre boyunca yeniler), görev eşyası, Gelişim Paketi; evcil eşyaları evcil adımında
void World::useItem(const std::string& id) {
  const Item* it = bal_.item(id); Player& p = player; const Stats s = stats();
  if (!it || !countItem(id) || p.dead) return;
  if (it->pet) { petUseItem(id); return; }   // evcil hayvan eşyaları
  if (!it->slot.empty()) { equip(id); return; }
  if (!it->use) { if (it->growth) openGrowthBox(id); return; }
  if (it->qt) { questUseItem(id); return; }
  if (it->useHp) { if (p.hp >= s.hp) { note("Canın dolu."); return; } p.hp = std::min(s.hp, p.hp + it->useHp); ufloat(-2, "+" + std::to_string(int(it->useHp)), 0x7bff8a); }
  if (it->useMp) { if (p.mp >= s.mp) { note("Manan dolu."); return; } p.mp = std::min(s.mp, p.mp + it->useMp); ufloat(-2, "+" + std::to_string(int(it->useMp)), 0x6fb7ff); }
  for (const Item::Hot* h : {&it->hot, &it->hot2}) if (!h->res.empty()) {   // aynı türden yenisi eskisinin yerine geçer
    const std::string k = h->res == "hp" ? "hotT" : "motT";
    p.buffs.erase(std::remove_if(p.buffs.begin(), p.buffs.end(), [&](const Buff& b) { return b.buff.get(k) != 0; }), p.buffs.end());
    Buff b; b.id = "food_" + h->res; b.buff = Vals{{k, h->amt / h->sec}}; b.t = h->sec; b.uid = ++fxUid_; p.buffs.push_back(std::move(b));
    ufloat(-2, it->name, h->res == "hp" ? 0x7bff8a : 0x6fb7ff, 0.8f);
  }
  removeItem(id);
}
void World::addItem(const std::string& id, int n, bool quiet) {
  bool f = false; for (auto& b : P.bag) if (b.first == id) { b.second += n; f = true; break; }
  if (!f) P.bag.push_back({id, n});
  if (!quiet) note(itemName(id) + " ×" + std::to_string(n), LOG_LOOT);
}
bool World::removeItem(const std::string& id, int n) {
  for (size_t i = 0; i < P.bag.size(); i++) if (P.bag[i].first == id) {
    if (P.bag[i].second < n) return false;
    P.bag[i].second -= n; if (P.bag[i].second <= 0) P.bag.erase(P.bag.begin() + long(i));
    return true;
  }
  return false;
}
std::string World::randomGear(int lv) {
  std::vector<const Item*> pool;
  for (const Item& it : bal_.items()) if (!it.slot.empty() && (it.cls.empty() || it.cls == P.cls) && it.lv <= lv && it.lv >= lv - 12) pool.push_back(&it);
  return pool.empty() ? std::string() : pool[size_t(irnd(0, int(pool.size()) - 1))]->id;
}

// ---------------- sahne ----------------
bool World::blocked(double fx, double fy) const {
  if (map.blocked(fx, fy)) return true;
  const int x = int(jsRound(fx)), y = int(jsRound(fy));
  return extraBlock_[size_t(y) * map.w + x] == 1;
}

void World::spawnMob(const std::string& nm, int px, int py, const std::string& key) {
  Ent e; e.kind = Ent::MOB; e.name = nm; e.x = px; e.y = py; e.key = key;
  e.t = random() * 20;   // HTML Ent: t = Math.random() * 20
  MonDef& d = bal_.monDef(nm, *scene_); e.d = &d;
  // canavar değerleri orijinalde sunucudaydı: seviyeden hesaplanır (seçkin ×3 can ×1,15 saldırı; boss ×18 / ×1,8)
  const int L = d.lv ? d.lv : 1, rk = d.rank; const double soft = d.passive ? 0.55 : 1;
  const double mhp = jsRound((250 + 260.0 * L) * soft * (rk == 2 ? 18 : rk ? 3 : 1));
  e.atk = jsRound((48 + 27.0 * L + 0.15 * L * L) * soft * (rk == 2 ? 1.8 : rk ? 1.15 : 1)); e.def = 8.0 * L * (rk ? 1.5 : 1);
  e.hp = e.maxHp = mhp; e.homeX = px; e.homeY = py; e.state = "idle"; e.atkT = 0;
  e.wanderT = rnd(1, 4); e.aggro = false; e.slowT = 0;
  dungeonTune(e);   // zindan: sınav canavarı zayıf, boss tek kişilik
  if (d.solo && rk == 2) { e.maxHp = e.hp = jsRound(e.hp * 8 / 18); e.atk = jsRound(e.atk / 1.8); }   // görev boss'u tek kişilik
  if (const Balance::MobRec* info = bal_.mobInfo(nm)) { e.sp = map.sprite(info->look); e.deathFx = info->deathFx; }
  e.dir = irnd(0, 3);
  ents.push_back(std::move(e));
}

void World::loadScene(const std::string& sid, const int* arrive) {
  const core::Json& D = as_.D(), &sc = D["scenes"][sid];
  if (!sc.isObj()) throw godat::Error("sahne yok: " + sid);
  scene_ = &sc; sceneId = sid; sceneName = sc["name"].str();
  map.load(as_, sc["map"].str());
  extraBlock_.assign(size_t(map.w) * map.h, 0);
  ents.clear(); fx.clear(); timers_.clear(); target_ = -1;   // HTML: Game.target = null (engage kalır)
  phantom.tg = -1;   // Büyü Hayali sürer, eski haritanın canavarını hedeflemez
  floats.clear(); zoneMsg = quests().name(sceneName); zoneT = 3; sceneGen++;
  goTarget = -1; dialogEnt = -1; if (!route.empty()) routeT = routeDelay;   // uçan sayılar eski haritanın varlıklarına bağlıydı; bölge adı duyurusu
  dungeonOnLoad(sid);
  int ei = -1;
  for (const core::Json& e : sc["ents"].arr()) {
    ei++;
    const std::string id = std::to_string(e[0].i()), nm = e[1].str(); const int x = e[2][0].i(), y = e[2][1].i();
    const core::Json& info = D["cit"][id];
    if (info.isArr()) {
      Ent n; n.kind = Ent::NPC; n.id = id; n.name = info[0].str(); n.x = x; n.y = y; n.t = random() * 20; n.sp = map.sprite(info[1].str());
      for (const core::Json& s : info.arr()) if (s.str().find("npc_pickup") != std::string::npos) n.pickup = true;
      ents.push_back(std::move(n)); continue;
    }
    const Balance::MobRec* mr = bal_.mobById(id); if (!mr) continue;
    MonDef& d = bal_.monDef(nm, sc);
    Sprite* msp = map.sprite(mr->look); bool still = msp->ok();
    if (still) for (int a = 0; a < std::min(12, msp->animCount()); a++) if (msp->A()["a"][a].size() > 1) { still = false; break; }
    if (d.skip) continue;
    if (d.dummy || still) {   // sabit "canavarlar": maden kayası, kalıntı (toplama noktası) ya da sergi
      Ent n; n.kind = Ent::NPC; n.id = id; n.name = nm; n.x = x; n.y = y; n.t = random() * 20; n.sp = msp; n.dummy = true; n.node = still;
      ents.push_back(std::move(n)); if (still && !d.dummy) extraBlock_[size_t(y) * map.w + x] = 1; continue;
    }
    const int cnt = d.n ? d.n : 5, wide = d.wide ? d.wide : 5;
    for (int i = 0; i < cnt; i++) {
      const std::string key = sid + ":" + std::to_string(ei) + ":" + std::to_string(i);
      if (P.dun.on && P.dun.cleared.count(key)) { int c = -1; const DungeonDef* dd = dungeonOf(sid, &c); if (dd && !dd->train) continue; }   // normal zindanda bu koşuda kesilmiş
      int px = x, py = y;
      for (int k = 0; k < 30; k++) { const double a = rnd(-wide, wide), b = rnd(-wide, wide); if (!blocked(x + a, y + b)) { px = int(jsRound(x + a)); py = int(jsRound(y + b)); break; } }
      spawnMob(nm, px, py, key);
    }
  }
  // oyuncu: verilen yer, yoksa giriş bölgesinin (tür 0) ortası; geçilmezse giriş bölgesinin köşesi, o da olmazsa en yakın boş kare
  // kayıttan başlarken (HTML start → loadScene(P.scene)): kayıttaki yer (kesirli), can ve mana
  double px = int(player.x), py = int(player.y); bool have = false;
  if (startSet_) { px = startX_; py = startY_; have = true; }
  else if (arrive) { px = arrive[0]; py = arrive[1]; have = true; }
  else for (const auto& r : map.regions) if (r.size() >= 6 && r[1] == 0) { px = int(jsRound((r[2] + r[4]) / 2.0)); py = int(jsRound((r[3] + r[5]) / 2.0)); have = true; break; }
  (void)have;
  if (blocked(px, py)) {
    bool f = false; for (const auto& r : map.regions) if (r.size() >= 6 && r[1] == 0) { px = r[2]; py = r[3]; f = true; break; }
    if (!f) { px = map.w / 2; py = map.h / 2; }
  }
  if (blocked(px, py)) {
    for (int R = 1; R < 30; R++) { bool f = false;
      for (int dy = -R; dy <= R && !f; dy++) for (int dx = -R; dx <= R && !f; dx++) if (!blocked(px + dx, py + dy)) { px += dx; py += dy; f = true; }
      if (f) break; }
  }
  Look keep = player.look; const double hp = player.hp, mp = player.mp;
  player = Player(); player.x = px; player.y = py; player.t = random() * 20;   // HTML new Player (Ent: t = Math.random() * 20)
  player.look = keep.cls.empty() ? Look{} : keep; player.doll.set(as_, player.look);
  const Stats s = stats(); player.hp = hp > 0 ? std::min(hp, s.hp) : s.hp; player.mp = mp > 0 ? std::min(mp, s.mp) : s.mp;
  if (startSet_) { player.hp = std::min(startHp_, s.hp); player.mp = std::min(startMp_, s.mp); startSet_ = false; }   // HTML Math.min(P.hp, s.hp)
  petSpawn();   // çağrılmış evcil hayvan sahibinin yanında (HTML Pet.spawn: oyuncudan hemen sonra)
  camX = map.px(player.x, player.y); camY = map.py(player.x, player.y);
  arriveT = 1.5;
  music(sc["music"].str());   // HTML SFX.Music.play(sc.music)
  save();
}

const std::vector<int>* arrivalNear(const std::vector<std::vector<int>>& regs, int idx) {
  const std::vector<int>* ex = nullptr, *nx = nullptr, *r = nullptr;
  for (const auto& g : regs) if (g[0] == idx && g[1] == 1) { ex = &g; break; }
  if (!ex) for (const auto& g : regs) if (g[0] == idx) { ex = &g; break; }
  for (const auto& g : regs) if (g[0] == idx + 1 && g[1] == 0) { nx = &g; break; }
  if (nx || !ex) return nx ? nx : ex;
  const double ax = (ex->at(2) + ex->at(4)) / 2.0, ay = (ex->at(3) + ex->at(5)) / 2.0; double bd = 1e9;
  for (const auto& g : regs) if (g[1] == 0) { const double d = jsHypot((g[2] + g[4]) / 2.0 - ax, (g[3] + g[5]) / 2.0 - ay); if (d < bd) { bd = d; r = &g; } }
  return r ? r : ex;
}

// geçitten geçiş (HTML gotoScene + arrivalNear): hedef sahnede bizim sahneye dönen geçidin yanındaki giriş bölgesi
void World::gotoScene(const std::string& sid, const std::string& fromSid) {
  save();   // HTML: Game.transit = true; save()
  const core::Json& sc = as_.D()["scenes"][sid];
  GameMap tmp; tmp.load(as_, sc["map"].str());
  const auto& regs = tmp.regions; int backIdx = -1;
  for (const core::Json& e : sc["exits"].arr()) if (!fromSid.empty() && (std::to_string(e[2].i()) == fromSid || e[2].str() == fromSid)) { backIdx = e[0].i(); break; }
  const std::vector<int>* r = nullptr;
  if (backIdx >= 0) r = arrivalNear(regs, backIdx);
  else for (const auto& g : regs) if (g[1] == 0) { r = &g; break; }
  if (r) { const int a[2] = {int(jsRound(((*r)[2] + (*r)[4]) / 2.0)), int(jsRound(((*r)[3] + (*r)[5]) / 2.0))}; loadScene(sid, a); }
  else loadScene(sid);
}

// HTML checkExits (zindan kapıları ve çıkışları, yanlış bağlı geçit). Geçiş kare sonunda yapılır: HTML'de gotoScene eşzamansızdır, kare eski haritada
// biter (canavarlar o karede de güncellenir, zar atar), yeni harita sonra yüklenir.
void World::checkExits() {
  if (arriveT > 0 || goPending_) return;
  const int cx = int(jsRound(player.x)), cy = int(jsRound(player.y));
  for (const auto& r : map.regions) {
    if (r.size() < 6 || r[1] != 1) continue;
    if (cx >= r[2] && cx <= r[4] && cy >= r[3] && cy <= r[5]) {
      auto fx = bal_.dungeonExit.find(sceneId + ":" + std::to_string(r[0]));   // yanlış bağlı geçit (zindan merkezinin çıkışı)
      if (fx != bal_.dungeonExit.end()) { const std::string sid = fx->second.first; const int a[2] = {fx->second.second.first, fx->second.second.second}; goPending_ = true; goFn_ = [this, sid, a] { loadScene(sid, a); }; return; }
      const core::Json* ex = nullptr; for (const core::Json& e : (*scene_)["exits"].arr()) if (e[0].i() == r[0]) { ex = &e; break; }
      if (!ex) { if (dungeonDoor(r[0])) return; continue; }   // bağlanmamış geçit: zindan kapısı olabilir
      std::string sid = (*ex)[2].isStr() ? (*ex)[2].str() : (*ex)[2].isNum() ? std::to_string((*ex)[2].i()) : "";
      if (sid.empty() || !as_.D()["scenes"][sid].isObj()) {
        std::string target = (*ex)[1].str(); const size_t k = target.find("(入口)"); if (k != std::string::npos) target.erase(k, std::string("(入口)").size());
        if (warnT <= 0) { toast(quests().name(target) + ": bu bölge henüz açılmadı"); warnT = 3; }
        return;
      }
      if (dungeonOf(sceneId) && !dungeonOf(sid)) { goPending_ = true; goFn_ = [this] { dungeonLeave(false); }; return; }   // zindandan alana: kapının dışına
      const std::string from = sceneId; goPending_ = true; goFn_ = [this, sid, from] { gotoScene(sid, from); }; return;
    }
  }
}

void World::resetClock() { time = 0; player.t = 0; player.animT = 0; for (Ent& e : ents) e.t = 0; }

int World::nearestMob(double r) const {
  int best = -1; double bd = r;
  for (size_t i = 0; i < ents.size(); i++) { const Ent& e = ents[i]; if (e.kind != Ent::MOB || e.dead) continue; const double d = jsHypot(e.x - player.x, e.y - player.y); if (d < bd) { bd = d; best = int(i); } }
  return best;
}

// ---------------- hareket ----------------
template <class E> void World::moveEnt(E& e, double dx, double dy) {
  if (!blocked(e.x + dx, e.y)) e.x += dx; else if (!blocked(e.x + dx, jsRound(e.y))) e.x += dx;
  if (!blocked(e.x, e.y + dy)) e.y += dy;
}
// hedefe yalnız 4 yönde: önce bir eksen, sonra öbürü (L biçiminde)
template <class E> bool World::stepTo(E& e, double tx, double ty, double sp, double dt) {
  const double dx = tx - e.x, dy = ty - e.y, eps = 0.04;
  if (std::fabs(dx) <= eps && std::fabs(dy) <= eps) { if (!blocked(tx, ty)) { e.x = tx; e.y = ty; } return true; }
  if (e.ax == 'x' && std::fabs(dx) <= eps) e.ax = 0;
  if (e.ax == 'y' && std::fabs(dy) <= eps) e.ax = 0;
  if (!e.ax) e.ax = std::fabs(dx) >= std::fabs(dy) ? 'x' : 'y';
  const double st = sp * dt, ox = e.x, oy = e.y;
  if (e.ax == 'x') { moveEnt(e, jsSign(dx) * std::min(st, std::fabs(dx)), 0); e.dir = dirOf(dx, 0); if (std::fabs(e.x - ox) < 1e-4) e.ax = std::fabs(dy) > eps ? 'y' : 0; }
  else { moveEnt(e, 0, jsSign(dy) * std::min(st, std::fabs(dy))); e.dir = dirOf(0, dy); if (std::fabs(e.y - oy) < 1e-4) e.ax = std::fabs(dx) > eps ? 'x' : 0; }
  return std::fabs(tx - e.x) <= eps && std::fabs(ty - e.y) <= eps;
}
template bool World::stepTo<PetEnt>(PetEnt&, double, double, double, double);   // evcil hayvan (world_pet.cpp)

// ---------------- efektler ----------------
int World::pushFx(const std::string& name, double x, double y, int dir, bool glow) {
  Fx f; f.sp = map.sprite(name); f.sp->glow = glow; f.x = x; f.y = y; f.name = name; f.uid = ++fxUid_;
  f.anim = fxAnim(*f.sp, dir >= 0 ? dir : player.dir);
  f.len = f.sp->ok() ? f.sp->animLen(f.anim) : 0; f.done = !f.sp->ok() || !f.len;
  fx.push_back(std::move(f)); return int(fx.size()) - 1;
}
void World::shoot(const std::string& name, double sx, double sy, int to, std::function<void()> cb, bool vis) {
  const int i = pushFx(name, sx, sy); Fx& f = fx[i]; f.z = 30; f.proj = true; f.to = to; f.cb = std::move(cb); f.vis = vis; f.loop = true;
}
// Orijinal efekt tablosundaki "sayı + yarıçap" (HTML fxBurst): efekt n kez, ilki tam ortada, ötekiler r piksellik daire içinde rastgele
// (yer düzlemi: dikeyde yarı) ve kısa aralıklarla (toplam en çok ~0,6 sn) oynar
void World::fxBurst(const std::string& name, double x, double y, int n, double r, int dir, double delay) {
  if (name.empty()) return;
  if (!n) n = 1;
  const double gap = std::min(0.06, 0.6 / n);
  for (int k = 0; k < n; k++) {
    auto go = [this, name, x, y, k, r, dir]() {
      const double a = random() * 6.283, d = k && r ? std::sqrt(random()) * r : 0;
      const int i = pushFx(name, x, y, dir); fx[i].ox = std::cos(a) * d; fx[i].oy = std::sin(a) * d * 0.5;
    };
    const double dl = delay + k * gap;
    if (dl > 0) later(dl, go); else go();
  }
}
// çağrılan nesne (Gözdağı Totemi, Şifa Pınarı): yere konur, süresi boyunca durur
void World::totemAt(const std::string& name, double x, double y, double life) { const int i = pushFx(name, x, y); fx[i].loop = true; fx[i].life = life; }
// Büyü Hayali: "hayal totemi" oyuncunun yanına dikilir (canavar görseli, ışık değil: 0-3 duruş, 8-11 saldırı)
int World::phantomFx() {
  const int i = pushFx("怪物-魔法幻象", player.x - 1, player.y + 0.3, -1, false); Fx& f = fx[i];
  f.loop = true; f.anim = player.dir; f.len = f.sp->ok() ? f.sp->animLen(f.anim) : 0; f.done = !f.sp->ok() || !f.len;
  return f.uid;
}
using core::jsIntKey;
// süren etkinin görseli (HTML auraSync): etki sürdükçe efekt varlığın üstünde döner, bitince kalkar. want: anahtar → efekt adı
void World::auraSync(int follow, Aura& A, const std::vector<std::pair<std::string, std::string>>& want0) {
  std::vector<std::pair<std::string, std::string>> want;
  for (const auto& w : want0) { bool f = false; for (auto& x : want) if (x.first == w.first) { x.second = w.second; f = true; } if (!f) want.push_back(w); }
  std::stable_sort(want.begin(), want.end(), [](const auto& a, const auto& b) {
    const bool ia = jsIntKey(a.first), ib = jsIntKey(b.first);
    if (ia != ib) return ia;
    return ia && std::stoll(a.first) < std::stoll(b.first); });
  const double ex = follow == -2 ? player.x : ents[follow].x, ey = follow == -2 ? player.y : ents[follow].y;
  for (const auto& w : want) {
    int* slot = nullptr; for (auto& a : A) if (a.first == w.first) slot = &a.second;
    Fx* f = slot ? fxByUid(*slot) : nullptr;
    if (!f || f->done || f->name != w.second) {
      if (f) f->done = true;
      const int i = pushFx(w.second, ex, ey); fx[i].follow = follow; fx[i].loop = true;
      if (slot) *slot = fx[i].uid; else A.push_back({w.first, fx[i].uid});
    }
  }
  for (size_t k = 0; k < A.size();) {
    bool keep = false; for (const auto& w : want) if (w.first == A[k].first) keep = true;
    if (keep) { k++; continue; }
    if (Fx* f = fxByUid(A[k].second)) f->done = true;
    A.erase(A.begin() + long(k));
  }
}

// ---------------- savaş ----------------
World::Dmg World::dmgCalc(double atk, double def, double mult, double critB, double add) {
  const double base = (atk * mult + add) * rnd(0.92, 1.08);
  const int d = int(std::max(1.0, jsRound(base * 1000 / (1000 + def * 3))));
  const bool crit = random() < 0.08 + critB / 100;
  return {crit ? int(jsRound(d * 1.8)) : d, crit};
}

static double buffSum(const std::vector<Buff>& L, const char* k) { double v = 0; for (const Buff& b : L) v += b.buff.get(k); return v; }
static bool anyBuff(const std::vector<Buff>& L, const char* k) { for (const Buff& b : L) if (b.buff.get(k)) return true; return false; }

// HTML hitMob: savunma, kritik, güçlendirmeler, tetiklenen etkiler (kanama, yanma, donma, sersemletme, mühür, umutsuzluk)
int World::hitMob(int i, double mult, const HitOpt& o) {
  Ent& m = ents[i]; if (m.dead) return 0;
  const Stats s = stats(); Player& p = player;
  const double nextCrit = buffSum(p.buffs, "nextCrit"), leech = buffSum(p.buffs, "leech"), dmgUp = buffSum(p.buffs, "dmgUp"), dmgOut = buffSum(p.buffs, "dmgOut");
  // İlahi Gözdağı: savunma, büyü saldırısının yüzdesi kadar düşer; eski genel zayıflatma (evcil) savunmayı %60 düşürür
  const double def = m.weakT > 0 ? (m.weakDef ? std::max(0.0, m.def - m.weakDef) : m.def * 0.4) : m.def;
  double critB = s.crit + o.crit;
  if (!o.tick && nextCrit) { if (random() * 100 < nextCrit) critB = 1000; for (Buff& b : p.buffs) b.buff.del("nextCrit"); }   // Hız Patlaması: sonraki saldırı
  const double K0 = bal_.cls(P.cls).dmgK;   // büyü gücü: sınıf vuruş çarpanı (bizim denge)
  const Dmg r = dmgCalc(s.atk, o.pure ? 0 : def, mult * K0 * (m.weakT > 0 && !m.weakDef ? 1.15 : 1), critB, o.add * K0);
  double d = r.d;
  if (r.crit && o.critDmg) d = jsRound(d * (1 + o.critDmg / 100));
  if (s.ccDmg && (m.slowT > 0 || m.rootT > 0 || m.burn.on)) d = jsRound(d * (1 + s.ccDmg / 100));   // Element Ustalığı
  if (dmgUp) d = jsRound(d * (1 + dmgUp / 100));                  // Büyü Darbesi katları
  if (dmgOut) d = jsRound(d * std::min(1.0, dmgOut));             // Element Bağışı sırasında hasar düşer
  const int dd = int(std::max(1.0, d));
  m.hp -= dd; m.aggro = true; m.state = "hurt"; m.animT = 0; m.stateT = 0.3; if (!(m.tauntT > 0)) m.foe = -1;   // son vuran: oyuncu
  if (o.slow) m.slowT = o.slow;
  ufloat(i, (r.crit ? "!" : "") + std::to_string(dd), r.crit ? 0xffd040 : o.tick ? 0xd8b0ff : 0xffffff, r.crit ? 1.3f : 1);
  if (!o.tick) {
    if (leech) healPlayer(dd * leech);   // Kan Damgası
    if (o.bleed) { const int n = std::min(5, (m.bleed.on ? m.bleed.n : 0) + 1); m.bleed.on = true; m.bleed.n = n; m.bleed.t = 10; m.bleed.tick = 2; }   // Testere Bıçak: en çok 5 kat
    if (o.burn) { m.burn.on = true; m.burn.t = 6; m.burn.tick = 2; }   // Alev Darbesi: yanma (yığılmaz)
    if (o.freeze && random() * 100 < o.freeze) m.rootT = 2;
    const double now = time;
    if (o.stun && random() * 100 < o.stun && !(p.stunCd > now)) { m.stunT = 3; p.stunCd = now + 15; ufloat(i, "Sersem", 0xffe070); }
    if (s.seal && random() * 100 < s.seal && !(p.sealCd > now)) { m.sealT = 3; p.sealCd = now + 10; ufloat(i, "Mühür", 0xc080ff); }
    if (s.despair && random() * 100 < s.despair && !(p.despCd > now)) { m.despairT = 6; p.despCd = now + 15; }
    if (r.crit && o.onCrit) o.onCrit(m);
  }
  if (m.hp <= 0) killMob(i);
  return dd;
}

// şifa: Kana Hasret ile artar (alınan şifa); Gölge Hükümdarı sırasında şifa yok
int World::healPlayer(double h, const std::string& fxName) {
  Player& p = player; const Stats s = stats(); if (anyBuff(p.buffs, "noHeal")) return 0;
  const int v = int(jsRound(h * (1 + s.healUp / 100))); p.hp = std::min(s.hp, p.hp + v); ufloat(-2, "+" + std::to_string(v), 0x7bff8a);
  if (!fxName.empty()) { const int i = pushFx(fxName, p.x, p.y); fx[i].follow = -2; }
  return v;
}
// Çürüme (90314): 10 saniye, 2 saniyede bir; Can Sömürüsü (90316) payı ve can emme
void World::applyCorrosion(Ent& m) {
  const double er = skRankSn(90316) ? skCSn(90316, "add_erosion_damage_rate") / 100 : 0;
  m.dot.on = true; m.dot.n = 5; m.dot.t = 2; m.dot.mult = 0.1 * (1 + er); m.dot.add = skCSn(90314, "dur_dmg"); m.dot.corr = true;
  m.dot.suck = skRankSn(90316) ? skCSn(90316, "suck_rate") / 100 : 0;
}

// HTML useSkill: i, sınıfın beceri listesindeki sıra (kısayol). Menzil dışındaysa hedefe yürür (pending), oraya varınca kullanır.
void World::useSkill(int i) {
  const auto& SL = skills(); if (i < 0 || i >= int(SL.size())) return;
  const SkillDef* sk = &SL[size_t(i)]; Player& p = player;
  if (sk->passive() || p.dead || !skRank(*sk)) return;
  const Stats s = stats();
  if (gmNoCd) { p.cds.clear(); p.mp = s.mp; }
  { auto c = p.cds.find(sk->id); if (c != p.cds.end() && c->second > 0) return; }
  // Gölge Hükümdarı: şifa ve destek becerileri çalışmaz (orijinal)
  if ((sk->heal || (sk->buff && sk->sn != 90613)) && anyBuff(p.buffs, "noHeal")) return;
  // aç/kapa beceri (Kutsal Akış): etkinse kapanır
  if (sk->toggle) {
    bool on = false; for (const Buff& b : p.buffs) if (b.id == sk->id) on = true;
    if (on) { p.buffs.erase(std::remove_if(p.buffs.begin(), p.buffs.end(), [&](const Buff& b) { return b.id == sk->id; }), p.buffs.end()); p.cds[sk->id] = sk->cd; return; }
  }
  int arcUid = -1, arcN = 0; for (const Buff& b : p.buffs) if (b.id == "arcane") { arcUid = b.uid; arcN = b.n; break; }
  SkCtx c0{*this, *sk, s, P.lv, nullptr};
  const double mpCost = sk->mpPct ? std::max(1.0, jsRound(p.mp * sk->mpPct(c0) * (1 + arcN))) : sk->mp;   // Büyü Darbesi: mananın yüzdesi, her katta artar
  if (p.mp < mpCost) return;
  int t = target_ >= 0 && !ents[target_].dead && ents[target_].kind == Ent::MOB ? target_ : -1;
  const bool needT = sk->f && !sk->aoe;
  if (needT && t < 0) { t = nearestMob(8); if (t >= 0) setTarget(t, true); } else if (t >= 0) engage_ = true;   // beceri kullanınca o hedefle dövüş sürer
  if (needT && t < 0) return;
  if (t >= 0 && sk->range && jsHypot(ents[t].x - p.x, ents[t].y - p.y) > sk->range + 0.3) { p.pending = i; return; }
  p.pending = -1; p.mp -= mpCost; p.cds[sk->id] = sk->cd; p.combatT = 5; if (i == 0) p.atkT = std::max(p.atkT, 0.9);
  if (t >= 0) p.dir = dirOf(ents[t].x - p.x, ents[t].y - p.y);
  p.state = bal_.cls(P.cls).melee && sk->f && (sk->range ? sk->range : 9) < 3 ? "attack" : "cast"; p.animT = 0; p.stateT = 0.5;
  sfx(sk->snd);
  SkCtx c1{*this, *sk, s, P.lv, t >= 0 ? &ents[size_t(t)] : nullptr};
  const auto F = std::make_shared<SkF>(sk->f ? sk->f(c1) : SkF());
  HitOpt o; o.crit = F->crit; o.add = F->add; o.slow = F->slow ? F->slow : sk->slow; o.pure = F->pure; o.bleed = F->bleed; o.burn = F->burn;
  o.freeze = F->freeze; o.stun = F->stun; o.critDmg = F->critDmg; o.onCrit = F->onCrit;
  const double MUL = F->mult;
  // vuruşun ardından: Çürüme bırakma, hayal totemi, Kan Damgası'nı yenileme, Büyü Darbesi katı; başka bir saldırı becerisi Büyü Darbesi etkisini tüketir
  auto after = [this, sk, F, MUL, o, arcUid, arcN](int tg) {
    Player& p = player;
    if (F->corrode && tg >= 0 && !ents[tg].dead) applyCorrosion(ents[tg]);
    if (F->phantom && tg >= 0) {
      if (phantom.on) if (Fx* f = fxByUid(phantom.fx)) f->done = true;
      phantom.on = true; phantom.t = F->life; phantom.tick = 0; phantom.mult = F->phantom; phantom.tg = tg; phantom.fx = phantomFx();
    }
    if (!F->refresh.empty()) for (Buff& b : p.buffs) if (b.id == F->refresh) { const SkillDef* r = bal_.skills.bySn(90106); b.t = std::max(b.t, r && r->dur ? r->dur : 10); break; }
    if (F->arcane) {
      const int n = std::min(3, arcN + 1);
      p.buffs.erase(std::remove_if(p.buffs.begin(), p.buffs.end(), [](const Buff& b) { return b.id == "arcane"; }), p.buffs.end());
      Buff b; b.id = "arcane"; b.n = n; b.buff = Vals{{"dmgUp", n * skC(*sk, "count_up_damage_rate")}}; b.t = 3; b.uid = ++fxUid_; p.buffs.push_back(std::move(b));
    } else if (arcUid >= 0 && sk->f && (MUL || o.add)) {
      p.buffs.erase(std::remove_if(p.buffs.begin(), p.buffs.end(), [arcUid](const Buff& b) { return b.uid == arcUid; }), p.buffs.end());
    }
  };
  // vuruş efekti: hitN kez hitR px içinde; birden çok mermide (projN) her mermi kendi payını patlatır
  const int PN = sk->projN ? sk->projN : 1, hitN = sk->hitN ? sk->hitN : 1, per = (hitN + PN - 1) / PN;
  auto hitFx = [this, sk, t](int n) { fxBurst(!sk->hit.empty() ? sk->hit : sk->fx, ents[t].x, ents[t].y, n, sk->hitR); };
  auto mobsNear = [this](double x, double y, double r) { std::vector<int> v; for (size_t k = 0; k < ents.size(); k++) { const Ent& m = ents[k]; if (m.kind == Ent::MOB && !m.dead && jsHypot(m.x - x, m.y - y) <= r) v.push_back(int(k)); } return v; };
  auto land = [this, sk, F, MUL, o, t, per, hitFx, mobsNear, after]() {
    sfx(sk->snd2);
    hitFx(per);
    if (sk->splash) { for (int m : mobsNear(ents[t].x, ents[t].y, sk->splash)) hitMob(m, MUL, o); }
    else if (MUL || o.add) hitMob(t, MUL, o);
    if (!sk->fx2.empty()) pushFx(sk->fx2, ents[t].x, ents[t].y);
    if (sk->hits == 2) later(0.28, [this, sk, F, MUL, o, t]() { if (!ents[t].dead) { HitOpt o2 = o; o2.add = F->hasMult2 ? 0 : o.add; hitMob(t, F->hasMult2 ? F->mult2 : MUL, o2); sfx(sk->snd); } });
    after(t);
  };
  // oyuncudaki efekt; yakın dövüşte kılıç izi saldırı hareketinin inişine denk gelsin diye 2 kare sonra
  if (!sk->self.empty()) fxBurst(sk->self, p.x, p.y, sk->selfN, sk->selfR, p.dir, p.state == "attack" ? 2.0 / TICK : 0);
  later(0.25, [this, sk, F, MUL, o, t, s, PN, per, hitN, hitFx, mobsNear, after, land]() {
    Player& p = player;
    if (!sk->proj.empty() && t >= 0) {
      shoot(sk->proj, p.x, p.y, t, land, false);
      for (int k = 1; k < PN; k++) later(k * 0.12, [this, sk, t, k, per, hitN, hitFx]() { shoot(sk->proj, player.x, player.y, t, [hitFx, k, per, hitN]() { hitFx(std::min(per, hitN - k * per)); }, true); });
    } else if (sk->aoe) {
      const std::vector<int> near = mobsNear(p.x, p.y, sk->aoe);
      if (!sk->fx.empty()) pushFx(sk->fx, p.x, p.y);
      sfx(sk->snd2);
      if (!sk->totem.empty()) totemAt(sk->totem, p.x, p.y, F->weakT ? F->weakT : 10);
      int dealt = 0;
      for (int m : near) {
        if (MUL || o.add) dealt += hitMob(m, MUL, o);
        if (F->weakDef) { ents[m].weakT = F->weakT; ents[m].weakDef = F->weakDef; }
      }
      if (F->novaHeal && dealt) healPlayer(dealt);   // Kutsal Nova: verilen hasar kadar can
      after(near.empty() ? -1 : near[0]);
    } else if (sk->f) land();
    else if (sk->heal) { SkCtx c{*this, *sk, s, P.lv, nullptr}; healPlayer(jsRound(sk->heal(c)), sk->fx); }
    else if (sk->buff) {
      SkCtx c{*this, *sk, s, P.lv, nullptr};
      const double dur = sk->durF ? sk->durF(c) : sk->dur;
      Buff b; b.id = sk->id; b.buff = sk->buff(c); b.t = dur; b.fx = sk->bfx; b.uid = ++fxUid_;
      // Şifa Pınarı: pınar yere konur, yalnızca yanındayken iyileştirir
      if (!sk->totem.empty()) { b.hasAt = true; b.atX = p.x; b.atY = p.y; b.atR = 3; totemAt(sk->totem, p.x, p.y, dur); }
      p.buffs.erase(std::remove_if(p.buffs.begin(), p.buffs.end(), [sk](const Buff& x) { return x.id == sk->id; }), p.buffs.end());
      p.buffs.push_back(std::move(b));
      if (!sk->fx.empty()) { const int k = pushFx(sk->fx, p.x, p.y); fx[k].follow = -2; }
      clampVitals();
    }
  });
}

void World::killMob(int i) {
  Ent& m = ents[i];
  m.dead = true; m.deadT = 0; m.state = "die"; m.respawnT = m.d->rank == 2 ? 90 : m.d->rank ? 40 : 15;
  if (target_ == i) setTarget(-1);
  const double diff = m.d->lv - P.lv;
  const long long xp = (long long)std::max(1.0, jsRound(bal_.mobXp(m.d->lv, m.d->rank) * clampd(1 + diff * 0.1, 0.2, 1.5)));
  gainXp(xp); ufloat(i, "+" + std::to_string(xp) + " TP", 0x9fe060);
  const Stats st = stats();
  const long long gold = (long long)jsRound((irnd(m.d->lv, m.d->lv * 3) + m.d->rank * 20) * (1 + st.goldUp / 100)); P.gold += gold;
  sfx("kill", 0.7); later(0.35, [this] { sfx("coin", 0.5); });
  note(std::to_string(gold) + " altın alındı", LOG_LOOT);
  if (st.lifeEl && bal_.item("30127") && random() * 100 < st.lifeEl) addItem("30127");   // gece elfi: Yaşam Elementi
  if (random() < 0.1) addItem(P.lv > 10 ? "hp2" : "hp1");
  if (random() < 0.06) addItem(P.lv > 10 ? "mp2" : "mp1");
  if (m.d->rank && random() < 0.6) { const std::string g = randomGear(std::max(1, m.d->lv + 2)); if (!g.empty()) { addItem(g, 1, true); note("Ganimet: " + itemName(g) + "!", LOG_Q); toast("Ganimet: " + itemName(g)); } }
  else if (!m.d->passive && random() < 0.025) { const std::string g = randomGear(std::max(1, m.d->lv)); if (!g.empty()) { addItem(g, 1, true); note("Ganimet: " + itemName(g), LOG_LOOT); } }
  questKill(m.name);   // görev sayaçları ve toplama zarları (HTML'deki yerinde: ganimetten sonra, evcil yumurtasından önce)
  dungeonOnKill(m);    // zindan: kesilen canavar bu koşuda doğmaz, son boss sandığı
  petOnKill(m, xp);    // evcil hayvanın deneyim payı
  // evcil yumurtası: görünüş ailesi uyan tür varsa küçük olasılıkla (HTML Pet.dropEgg)
  if (const Balance::MobRec* info = bal_.mobInfo(m.name)) if (const std::string* egg = bal_.eggFor(info->look)) {
    const double ch = m.d->rank == 2 ? 0.25 : m.d->rank ? 0.03 : 0.004; if (random() < ch) { addItem(*egg, 1, true); toast("Ganimet: " + itemName(*egg) + "!"); note("Ganimet: " + itemName(*egg), LOG_Q); }
  }
  if (!m.deathFx.empty()) pushFx(m.deathFx, m.x, m.y);
}

void World::hurtPlayer(int i) {
  if (god) return;   // GM: ölümsüzlük
  Player& p = player; if (p.dead) return;
  Ent& m = ents[i];
  const Stats s = stats(); if (random() < s.dodge / 100) { ufloat(-2, "Iska", 0xcfcfcf); return; }   // ıska
  Dmg r = dmgCalc(m.atk, s.def, 1); r.d = int(std::max(1.0, jsRound(r.d * (1 - std::min(80.0, s.dr) / 100))));
  const double mp2hp = buffSum(p.buffs, "mp2hp"), manaShield = buffSum(p.buffs, "manaShield"), mpPerDmg = buffSum(p.buffs, "mpPerDmg"), reflect = buffSum(p.buffs, "reflect");
  const double now = time;
  // Büyücü Bedeni (90611): Karanlık Ahit sırasında %10 hasarı savuştur, hasar kadar mana
  if (mp2hp && skRankSn(90611) && random() < 0.1) { p.mp = std::min(s.mp, p.mp + r.d); ufloat(-2, "Savuşturuldu", 0x9fd0ff); return; }
  // Zifiri Perde (90612): Karanlık Ahit dışında, 15 saniyede bir, savunma ve dirençler 6 saniye artar (güçlendirme 210192)
  if (s.veil && !mp2hp && !(p.veilCd > now) && random() * 100 < s.veil) {
    p.veilCd = now + 15; Buff b; b.id = "veil"; b.buff = Vals{{"def", 0.5}, {"res", jsRound(s.res * 0.5)}}; b.t = 6; b.fx = "特效-漆黑之幕"; b.uid = ++fxUid_; p.buffs.push_back(std::move(b));
  }
  // Büyü Kalkanı (90129): hasarın bir kısmı manadan düşer
  if (manaShield) { const double per = mpPerDmg ? mpPerDmg : 1, want = jsRound(r.d * std::min(1.0, manaShield)), can = std::min(want, std::floor(p.mp / per)); p.mp -= can * per; r.d -= int(can); }
  // Karşı Saldırı Fırtınası (90598): fiziksel saldırının %10'u ile alınan hasardan küçük olanı yansır
  if (reflect && r.d > 0 && !m.dead) { const double back = jsRound(std::min(s.atk * reflect, double(r.d))); if (back > 0) { HitOpt o; o.add = back; o.pure = true; o.tick = true; hitMob(i, 0, o); } }
  if (r.d <= 0) return;
  p.hp -= r.d; p.combatT = 5; ufloat(-2, "-" + std::to_string(r.d), 0xff5040); hurtT = 0.4f;
  // Kutsanmış Beden (90603): ölümcül darbeyi olasılıkla savuştur, biraz can
  if (p.hp <= 0 && s.cheatDeath && random() * 100 < s.cheatDeath) { p.hp = jsRound(s.hp * 0.2); ufloat(-2, "Kutsandı", 0xffe070); return; }
  if (p.hp <= 0) { p.hp = 0; p.dead = true; p.deadT = 0; p.state = "dead"; sfx("kill", 0.5); setTarget(-1); died = true; }   // arayüz 1,2 sn sonra ölüm penceresini açar
}

void World::gainXp(long long n) {
  P.xp += n;
  while (P.xp >= bal_.xpNeed(P.lv)) {
    P.xp -= bal_.xpNeed(P.lv); P.lv++; const Stats s = stats(); player.hp = s.hp; player.mp = s.mp;
    pushFx("LEVELUP", player.x, player.y); lvlN = P.lv; lvlT = 2.5f; sfx("levelup"); P.sp++;
    note("Beceri puanı kazandın! Beceriler ekranından harca.", LOG_Q);
    autoQuests();
    // açılan görevler (HTML questsUnlockedAt: bütün görevlerin açılma seviyesi liste sırasıyla hesaplanır)
    int nq = 0;
    for (size_t qi = 0; qi < quests().all().size(); qi++) if (quests().minLv(int(qi)) == P.lv && questState(int(qi)) == "new") { note("Yeni görev: " + quests().all()[qi].tr.title + " · " + quests().name(quests().all()[qi].giver), LOG_Q); nq++; }
    if (nq) toast(std::to_string(nq) + " yeni görev açıldı");
    save();
  }
}

// ---------------- güncelleme (HTML update) ----------------
void World::update(double dt, double sx, double sy) {
  time += dt; if (arriveT > 0) arriveT -= dt; if (warnT > 0) warnT -= dt;
  for (int i = int(timers_.size()) - 1; i >= 0; i--) {   // zamanlayıcılar: sondan başa (HTML gibi; yeni eklenenler bu karede çalışmaz)
    if (size_t(i) >= timers_.size()) continue;
    timers_[i].t -= dt;
    if (timers_[i].t <= 0) { auto fn = std::move(timers_[i].fn); timers_.erase(timers_.begin() + i); fn(); }
  }
  if (routeT >= 0 && (routeT -= dt) <= 0) { routeT = -1; routeStep(); }   // varışta otomatik yola devam (HTML setTimeout(routeStep, 400))
  Player& p = player; const Stats s = stats(); const ClassBase& C = bal_.cls(P.cls);
  const double px0 = p.x, py0 = p.y; p.animT += dt * TICK; p.combatT -= dt; p.atkT -= dt;
  for (auto& c : p.cds) c.second = std::max(0.0, c.second - dt);
  for (Buff& b : p.buffs) b.t -= dt;
  p.buffs.erase(std::remove_if(p.buffs.begin(), p.buffs.end(), [](const Buff& b) { return !(b.t > 0); }), p.buffs.end());
  { std::vector<std::pair<std::string, std::string>> w; if (!p.dead) for (const Buff& b : p.buffs) if (!b.fx.empty()) w.push_back({b.id, b.fx}); auraSync(-2, p.aura, w); }   // güçlendirme görselleri
  if (p.stateT > 0) { p.stateT -= dt; if (p.stateT <= 0) p.state = "idle"; }
  if (p.dead) p.deadT += dt;
  if (!p.dead) {
    const double regen = sceneName == "观林镇" ? 0.03 : p.combatT > 0 ? 0.003 : 0.012;
    p.hp = std::min(s.hp, p.hp + (s.hp * regen + s.hpreg * 0.1) * dt); p.mp = std::min(s.mp, p.mp + (s.mp * regen * 1.3 + s.mpreg * 0.1) * dt);
    const bool noHeal = anyBuff(p.buffs, "noHeal"); const double hu = 1 + s.healUp / 100;
    for (size_t bi = 0; bi < p.buffs.size(); bi++) {
      Buff& b = p.buffs[bi]; const Vals& B = b.buff;
      if (b.hasAt && jsHypot(p.x - b.atX, p.y - b.atY) > b.atR) continue;   // yere konmuş etki (Şifa Pınarı): uzaktayken işlemez
      double v;
      if ((v = B.get("hot")) && !noHeal) p.hp = std::min(s.hp, p.hp + s.hp * v * hu * dt);
      if ((v = B.get("hotT")) && !noHeal) p.hp = std::min(s.hp, p.hp + v * hu * dt);
      if ((v = B.get("motT"))) p.mp = std::min(s.mp, p.mp + v * dt);
      if ((v = B.get("mpTick"))) { const double g = s.mp * v * dt; p.mp = std::min(s.mp, p.mp + g); if (B.get("hpTick") && !noHeal) p.hp = std::min(s.hp, p.hp + g); }   // Element Bağışı (+ Ruh Uyumu)
      if ((v = B.get("mp2hp"))) { const double g = std::min(p.mp, p.mp * v * dt); p.mp -= g; if (!noHeal) p.hp = std::min(s.hp, p.hp + g * hu); }   // Karanlık Ahit
      if ((v = B.get("drain")) && (b.acc += dt) >= 1) {   // Gölge Hükümdarı
        b.acc -= 1; const double drain = v;
        for (size_t k = 0; k < ents.size(); k++) { Ent& m = ents[k]; if (m.kind == Ent::MOB && !m.dead && jsHypot(m.x - p.x, m.y - p.y) <= 3) { HitOpt o; o.add = m.maxHp * drain; o.pure = true; o.tick = true; hitMob(int(k), 0, o); } }
      }
    }
    if (phantom.on) {   // Büyü Hayali: saniyede bir, savunma tanımayan hasar
      Phantom& ph = phantom; ph.t -= dt; ph.tick -= dt;
      const int tg = target_ >= 0 && !ents[target_].dead && ents[target_].kind == Ent::MOB ? target_ : ph.tg >= 0 && !ents[ph.tg].dead ? ph.tg : -1;
      if (!fxByUid(ph.fx)) ph.fx = phantomFx();   // harita değişince yeniden
      Fx* f = fxByUid(ph.fx); const double fxX = f->x, fxY = f->y;
      f->anim = (tg >= 0 ? dirOf(ents[tg].x - fxX, ents[tg].y - fxY) : p.dir) + (ph.tick < 0.4 && tg >= 0 ? 8 : 0);   // hedefe bakar; atarken saldırı hareketi
      if (ph.tick <= 0 && tg >= 0) { ph.tick = 1; const double mult = ph.mult; shoot("特效-蓝火球", fxX, fxY, tg, [this, tg, mult]() { HitOpt o; o.pure = true; o.tick = true; hitMob(tg, mult, o); }, false); }
      if (ph.t <= 0) { if (Fx* g = fxByUid(ph.fx)) g->done = true; ph.on = false; }
    }
    bool moving = false;
    const double run = RUN * (1 + s.spd) * (fast ? 2.6 : 1);   // koşu hızı (GM hızlı: ×2,6)
    if (sx || sy) {   // yön kolu: yolu, bekleyen beceriyi, kişiye/haritaya yürüyüşü ve saldırıyı bırakır
      engage_ = false; p.pending = -1; p.pathOn = false; p.path.clear(); goTarget = -1; route.clear(); routeNpc.clear(); routeQuest = 0;
      // ekrandaki yöne en yakın karo ekseni (açılar 27,6° / 152,4° / 207,6° / 332,4°); sınırda titremesin diye son yöne küçük öncelik
      const double ang = std::atan2(sy, sx); int best = 0; double bd = 9;
      for (int i = 0; i < 4; i++) {
        const double aa = std::atan2(DIR4[i][0] * HH + DIR4[i][1] * HH, DIR4[i][0] * HW - DIR4[i][1] * HW);
        double d = std::fabs(std::atan2(std::sin(ang - aa), std::cos(ang - aa))); if (i == lastJoyDir_) d -= 0.25;
        if (d < bd) { bd = d; best = i; }
      }
      lastJoyDir_ = best;
      const double sp = run * dt;
      moveEnt(p, DIR4[best][0] * sp, DIR4[best][1] * sp); p.dir = dirOf(DIR4[best][0], DIR4[best][1]); moving = true;
    } else {
      lastJoyDir_ = -1;
      if (p.state != "attack" && p.state != "cast") {
        const int ti = target_;
        if (p.pending >= 0 && ti >= 0 && !ents[ti].dead) {   // menzil dışında kalan beceri: yaklaş, menzile girince kullan
          const SkillDef& sk = skills()[size_t(p.pending)]; Ent& t = ents[ti];
          if (jsHypot(t.x - p.x, t.y - p.y) <= sk.range) useSkill(p.pending); else { stepTo(p, t.x, t.y, run, dt); moving = true; }
        } else if (engage_ && ti >= 0 && ents[ti].kind == Ent::MOB && !ents[ti].dead && !p.pathOn) {
          Ent& t = ents[ti]; const double d = jsHypot(t.x - p.x, t.y - p.y);
          // 4 yönlü yürüyüşte engelli karede takılırsa ve yeterince yakınsa olduğu yerden vurur
          const bool stuck = p.hasChase && p.chaseD - d < 0.005 && d <= C.range + 0.6; p.chaseD = d; p.hasChase = true;
          if (d > C.range && !stuck) { stepTo(p, t.x, t.y, run, dt); moving = true; }
          else if (p.atkT <= 0) {
            p.atkT = 1.1; p.combatT = 5; p.dir = dirOf(t.x - p.x, t.y - p.y);
            if (C.melee) {
              p.state = "attack"; p.animT = 0; p.stateT = 0.45;
              later(0.25, [this, ti, &C]() { Ent& m = ents[ti]; if (!m.dead && jsHypot(m.x - player.x, m.y - player.y) < C.range + 0.6) { hitMob(ti, 1); sfx(C.snd); pushFx("BLOOD", m.x, m.y); } });
            } else {
              p.state = "cast"; p.animT = 0; p.stateT = 0.45; sfx(C.snd, 0.6);
              later(0.2, [this, ti, &C]() { shoot(C.bolt, player.x, player.y, ti, [this, ti, &C]() { hitMob(ti, 0.9); if (!C.boltHit.empty()) pushFx(C.boltHit, ents[ti].x, ents[ti].y); sfx("skill_bomb", 0.4); }, true); });
            }
          }
        }
        if (p.pathOn && !p.path.empty()) {   // yol boyunca yürü; bitince hedef kişi 2,2 kare içindeyse konuş
          if (stepTo(p, p.path[0].first, p.path[0].second, run, dt)) p.path.erase(p.path.begin());
          moving = true;
          if (p.path.empty()) {
            p.pathOn = false;
            if (goTarget >= 0) { const int n = goTarget; goTarget = -1; if (jsHypot(ents[size_t(n)].x - p.x, ents[size_t(n)].y - p.y) < 2.2) interact(n); }
          }
        }
      }
    }
    if (p.state == "idle" || p.state == "move") p.state = moving ? "move" : "idle";
    const double went = jsHypot(p.x - px0, p.y - py0) * CELL_PX;
    if (p.state == "move") p.t += went * 8 / STRIDE; else p.t += dt * TICK;
    checkExits();
  }
  petUpdate(dt);   // evcil hayvan (HTML Pet.update: oyuncudan sonra, canavarlardan önce)
  // NPC'ler ve canavarlar (oluşturulma sırasıyla)
  for (size_t i = 0; i < ents.size(); i++) {
    Ent& e = ents[i];
    if (e.kind == Ent::NPC) { e.t += dt * TICK * 0.8; if (e.hidden && (e.respawnT -= dt) <= 0) e.hidden = false; continue; }
    e.t += dt * TICK; e.animT += dt * TICK;
    if (e.dead) {
      if (!e.aura.empty()) auraSync(int(i), e.aura, {});
      e.deadT += dt; if ((e.respawnT -= dt) <= 0) { e.dead = false; e.hp = e.maxHp; e.x = e.homeX; e.y = e.homeY; e.aggro = false; e.state = "idle"; } continue;
    }
    e.atkT -= dt; e.slowT -= dt; if (e.weakT > 0) e.weakT -= dt; else if (e.weakDef) e.weakDef = 0;
    // zayıflatma görselleri (orijinal all_buff): yavaşlama 特效-缓缓加蓝, Tanrı Gözdağı 特效-抗性衰减buff, donma 特效-冻结
    { std::vector<std::pair<std::string, std::string>> w;
      if (e.slowT > 0) w.push_back({"slow", "特效-缓缓加蓝"});
      if (e.weakT > 0 && e.weakDef) w.push_back({"weak", "特效-抗性衰减buff"});
      if (e.rootT > 0) w.push_back({"root", "特效-冻结"});
      if (!e.aura.empty() || !w.empty()) auraSync(int(i), e.aura, w); }
    if (e.bleed.on && (e.bleed.tick -= dt) <= 0) {   // Testere Bıçak kanaması
      e.bleed.tick = 2; e.bleed.t -= 2; HitOpt o; o.tick = true; hitMob(int(i), 0.08 * e.bleed.n, o);
      if (e.bleed.on && e.bleed.t <= 0) e.bleed.on = false;
      if (e.dead) continue;
    }
    if (e.burn.on && (e.burn.tick -= dt) <= 0) {     // Alev Darbesi yanması
      e.burn.tick = 2; e.burn.t -= 2; HitOpt o; o.tick = true; hitMob(int(i), 0.15, o);
      if (e.burn.on && e.burn.t <= 0) e.burn.on = false;
      if (e.dead) continue;
    }
    if (e.rootT > 0) e.rootT -= dt;
    if (e.sealT > 0) e.sealT -= dt;
    if (e.despairT > 0) e.despairT -= dt;
    if (e.stunT > 0) { e.stunT -= dt; continue; }   // Kutsal Ceza: sersem (kıpırdamaz, saldırmaz)
    if (e.dot.on && (e.dot.t -= dt) <= 0) {          // Çürüme
      e.dot.t = 2; const double mult = e.dot.mult, add = e.dot.add, suck = e.dot.suck; if (--e.dot.n <= 0) e.dot.on = false;
      HitOpt o; o.add = add; o.tick = true; const int dd = hitMob(int(i), mult, o);
      if (suck && dd) healPlayer(dd * suck);
      if (e.dead) continue;
    }
    if (e.stateT > 0) { e.stateT -= dt; if (e.stateT <= 0) e.state = "idle"; }
    const double dp = jsHypot(p.x - e.x, p.y - e.y), dh = jsHypot(e.x - e.homeX, e.y - e.homeY);
    const double sp = (e.slowT > 0 ? 1 : 2) * (e.d->rank ? 1.1 : 1);
    if (!e.aggro && !e.d->passive && !p.dead && dp < 3.5 && e.d->lv >= P.lv - 5) e.aggro = true;
    if (e.aggro && (dh > 12 || p.dead)) { e.aggro = false; e.hp = e.maxHp; }
    if (e.state == "hurt" || e.state == "attack") continue;
    if (e.tauntT > 0) e.tauntT -= dt;
    // hedef: son vuran (evcil hayvan da olabilir); hayvan yoksa oyuncu
    const bool toPet = e.foe > 0 && pet.on && e.foe == pet.gen;
    const double fx0 = toPet ? pet.x : p.x, fy0 = toPet ? pet.y : p.y, df = jsHypot(fx0 - e.x, fy0 - e.y);
    if (e.aggro && !p.dead) {
      if (df > 1.3) { if (!(e.rootT > 0)) { stepTo(e, fx0, fy0, sp, dt); e.state = "move"; } }
      else {
        e.dir = dirOf(fx0 - e.x, fy0 - e.y);
        if (e.atkT <= 0 && !(e.sealT > 0)) {
          e.atkT = 1.6; e.state = "attack"; e.animT = 0; e.stateT = 0.5;
          const int gen = toPet ? pet.gen : 0;
          later(0.3, [this, i, gen]() {
            Ent& m = ents[i];
            if (!gen) { if (m.dead || jsHypot(player.x - m.x, player.y - m.y) >= 1.9) return; hurtPlayer(int(i)); return; }
            if (!pet.on || pet.gen != gen) return;   // vurulacak hayvan geri çağrıldı / öldü
            if (m.dead || jsHypot(pet.x - m.x, pet.y - m.y) >= 1.9) return;
            petHurt(int(i));
          });
        } else e.state = "idle";
      }
    } else {
      e.wanderT -= dt;
      if (e.wanderT <= 0) { e.wanderT = rnd(2, 6); e.wx = e.homeX + rnd(-3, 3); e.wy = e.homeY + rnd(-3, 3); e.hasW = !blocked(e.wx, e.wy); }
      if (e.hasW && jsHypot(e.wx - e.x, e.wy - e.y) > 0.2) { stepTo(e, e.wx, e.wy, 0.8, dt); e.state = "move"; } else e.state = "idle";
    }
  }
  // efektler (oynarken eklenenler de bu karede işlenir: JS for…of gibi)
  for (size_t i = 0; i < fx.size(); i++) {
    if (fx[i].done) continue;
    fx[i].t += dt * TICK;
    if (fx[i].follow == -2) { fx[i].x = p.x; fx[i].y = p.y; } else if (fx[i].follow >= 0) { fx[i].x = ents[fx[i].follow].x; fx[i].y = ents[fx[i].follow].y; }
    if (fx[i].life >= 0 && (fx[i].life -= dt) <= 0) { fx[i].done = true; continue; }
    if (fx[i].proj) {
      const int to = fx[i].to; if (to < 0 || (ents[to].dead && !fx[i].vis)) { fx[i].done = true; continue; }
      const double dx = ents[to].x - fx[i].x, dy = ents[to].y - fx[i].y, d = jsHypot(dx, dy), st = fx[i].speed * dt;
      if (d <= st + 0.2) { fx[i].done = true; auto cb = fx[i].cb; if (cb) cb(); }
      else { fx[i].x += dx / d * st; fx[i].y += dy / d * st; }
    } else if (!fx[i].loop && fx[i].t >= fx[i].len) fx[i].done = true;
  }
  fx.erase(std::remove_if(fx.begin(), fx.end(), [](const Fx& f) { return f.done; }), fx.end());
  camX = map.px(p.x, p.y); camY = map.py(p.x, p.y) - 40;   // kamera karaktere kilitli
  saveT += dt; if (saveT > 8) { saveT = 0; save(); }   // HTML Game.saveT
  if (goPending_) { goPending_ = false; auto fn = std::move(goFn_); goFn_ = nullptr; if (fn) fn(); }   // geçit: kare bitti, yeni harita
}

// ---------------- çizim (HTML drawWorld) ----------------
void World::drawMob(Canvas& c, Ent& e, int X, int Y) {
  if (!e.sp || !e.sp->ok()) return;
  if (e.dead && e.deadT > 0.2) return;   // ölüm efekti oynarken gövde kaybolur
  const int actIdx = e.state == "attack" ? 2 : e.state == "move" ? 1 : 0;
  int anim = actIdx * 4 + e.dir;
  if (anim >= e.sp->animCount() || !e.sp->A()["a"][anim].size()) anim = e.dir;
  const double t = e.state == "attack" ? std::min(e.animT, double(e.sp->animLen(anim) - 1)) : e.t;
  const bool hit = e.state == "hurt" && !e.dead;   // vurulunca kısa bir an titrer
  e.sp->draw(c, anim, t, X + (hit ? int(jsRound(std::sin(e.animT * 3) * 1.5)) : 0), Y, false, e.dead ? float(std::max(0.0, 1 - e.deadT * 5)) : 1.f);
}

void World::drawPlayer(Canvas& c, int X, int Y) {   // HTML Player.draw
  Player& p = player; Paperdoll& d = p.doll;
  if (p.dead) { const int anim = 16 + p.dir; d.draw(c, "figh", anim, std::min(p.deadT * TICK * 0.7, double(d.animLen("figh", anim) - 1)), X, Y); return; }
  if (p.state == "move") { d.draw(c, "comm", 4 + p.dir, p.t, X, Y); return; }
  if (p.state == "attack") { const int anim = 4 + p.dir; d.draw(c, "figh", anim, std::min(p.animT, double(d.animLen("figh", anim) - 1)), X, Y); return; }
  if (p.state == "cast") { const int anim = 8 + p.dir; d.draw(c, "figh", anim, std::min(p.animT, double(d.animLen("figh", anim) - 1)), X, Y); return; }
  d.draw(c, p.combatT > 0 ? "figh" : "comm", p.dir, p.t, X, Y);
}

void World::draw(Canvas& c, const DrawOpts& o) {
  const int vw = c.w(), vh = c.h();
  const double ox = jsRound(camX - vw / 2.0), oy = jsRound(camY - vh / 2.0);
  c.fill(0, 0, 0);
  const int sx = int(std::max(0.0, ox)), sy = int(std::max(0.0, oy)), ex = int(std::min<double>(map.pw, ox + vw)), ey = int(std::min<double>(map.ph, oy + vh));
  if (ex > sx && ey > sy) c.blit(map.ground, sx, sy, ex - sx, ey - sy, int(sx - ox), int(sy - oy));
  struct Item { double depth; int kind; size_t i; };   // kind 0 nesne, 1 varlık, 2 oyuncu
  std::vector<Item> list;
  const double tt = time * TICK;
  for (size_t i = 0; i < map.objs.size(); i++) {
    const MapObj& ob = map.objs[i];
    if (ob.X < ox - 350 || ob.X > ox + vw + 350 || ob.Y < oy - 40 || ob.Y > oy + vh + 450) continue;
    if (ob.flat) { ob.sp->draw(c, ob.anim, tt, int(ob.X - ox), int(ob.Y - oy)); continue; }
    list.push_back({double(ob.depth), 0, i});
  }
  auto visible = [&](double X, double Y) { return !(X < ox - 100 || X > ox + vw + 100 || Y < oy - 20 || Y > oy + vh + 150); };
  for (size_t i = 0; i < ents.size(); i++) if (visible(map.px(ents[i].x, ents[i].y), map.py(ents[i].x, ents[i].y))) list.push_back({ents[i].x + ents[i].y + 0.01, 1, i});
  if (visible(map.px(player.x, player.y), map.py(player.x, player.y))) list.push_back({player.x + player.y + 0.01, 2, 0});
  if (pet.on && visible(map.px(pet.x, pet.y), map.py(pet.x, pet.y))) list.push_back({pet.x + pet.y + 0.01, 3, 0});   // evcil hayvan (HTML'de oyuncudan sonra)
  std::stable_sort(list.begin(), list.end(), [](const Item& a, const Item& b) { return a.depth < b.depth; });
  for (const Item& it : list) {
    if (it.kind == 0) { const MapObj& ob = map.objs[it.i]; ob.sp->draw(c, ob.anim, tt, int(ob.X - ox), int(ob.Y - oy)); continue; }
    const double ex2 = it.kind == 1 ? ents[it.i].x : it.kind == 3 ? pet.x : player.x, ey2 = it.kind == 1 ? ents[it.i].y : it.kind == 3 ? pet.y : player.y;
    const int X = int(jsRound(map.px(ex2, ey2) - ox)), Y = int(jsRound(map.py(ex2, ey2) - oy));
    // hedef halkası (canavar kırmızı, kişi yeşil) ve ayak gölgesi kesirli konumda, kenarı yumuşak (HTML ctx.ellipse)
    const double Xf = map.px(ex2, ey2) - ox, Yf = map.py(ex2, ey2) - oy;
    if (o.targetRing && it.kind == 1 && int(it.i) == target_) c.strokeEllipse(float(Xf), float(Yf), 15, 7, 1.5f, ents[it.i].kind == Ent::NPC ? 0x58e048 : 0xe03020);
    if (it.kind == 1) {
      Ent& e = ents[it.i];
      if (o.shadows && !(e.kind == Ent::NPC && e.hidden)) c.fillEllipse(float(Xf), float(Yf), 11, 5, 0x000000, 0.35f);
      if (e.kind == Ent::MOB) drawMob(c, e, X, Y);
      else if (!e.hidden && e.sp && e.sp->ok()) e.sp->draw(c, std::min(e.anim, e.sp->animCount() - 1), e.t, X, Y);
    } else if (it.kind == 3) {   // HTML PetEnt.draw: saldırı / yürüme / durma kareleri, yön
      if (o.shadows) c.fillEllipse(float(Xf), float(Yf), 11, 5, 0x000000, 0.35f);
      if (pet.sp && pet.sp->ok()) {
        const int a = pet.state == "attack" ? 2 : pet.state == "move" ? 1 : 0; int anim = a * 4 + pet.dir;
        if (anim >= pet.sp->animCount() || !pet.sp->A()["a"][anim].size()) anim = pet.dir;
        const double t = pet.state == "attack" ? std::min(pet.animT, double(pet.sp->animLen(anim) - 1)) : pet.t;
        pet.sp->draw(c, anim, t, X, Y);
      }
    } else {
      if (o.shadows) c.fillEllipse(float(Xf), float(Yf), 11, 5, 0x000000, 0.35f);
      drawPlayer(c, X, Y);
    }
  }
  for (Fx& f : fx) if (f.sp && f.sp->ok()) f.sp->draw(c, f.anim, f.t, int(jsRound(map.px(f.x, f.y) - ox + f.ox)), int(jsRound(map.py(f.x, f.y) - oy + f.oy - f.z)));
}

}  // namespace engine
