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

// HTML stats(): sınıf tabanı + seviye artışı + ekipman + ırk becerileri (beceri ağaçları ve güçlendirmeler sonraki adımda)
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
  // ırk becerileri (kademe 1, kendiliğinden): insan savunma 2×Sv, mana 5×Sv, altın %10; gece elfi direnç 2×Sv, can 8×Sv, Yaşam Elementi %5
  if (P.race == "人类") { s.def += 2 * P.lv; s.mp += 5 * P.lv; s.goldUp = 10; }
  else if (P.race == "精灵") { s.res += 2 * P.lv; s.hp += 8 * P.lv; s.lifeEl = 5; }
  for (double* v : {&s.hp, &s.mp, &s.atk, &s.def, &s.crit, &s.dodge, &s.hpreg, &s.mpreg, &s.res, &s.dr, &s.spd, &s.goldUp, &s.lifeEl}) *v = jsRound(*v);
  return s;
}

int World::countItem(const std::string& id) const { for (const auto& b : P.bag) if (b.first == id) return b.second; return 0; }
void World::addItem(const std::string& id, int n) {
  for (auto& b : P.bag) if (b.first == id) { b.second += n; return; }
  P.bag.push_back({id, n});
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

void World::spawnMob(const std::string& nm, int px, int py) {
  Ent e; e.kind = Ent::MOB; e.name = nm; e.x = px; e.y = py;
  e.t = random() * 20;   // HTML Ent: t = Math.random() * 20
  MonDef& d = bal_.monDef(nm, *scene_); e.d = &d;
  // canavar değerleri orijinalde sunucudaydı: seviyeden hesaplanır (seçkin ×3 can ×1,15 saldırı; boss ×18 / ×1,8)
  const int L = d.lv ? d.lv : 1, rk = d.rank; const double soft = d.passive ? 0.55 : 1;
  const double mhp = jsRound((250 + 260.0 * L) * soft * (rk == 2 ? 18 : rk ? 3 : 1));
  e.atk = jsRound((48 + 27.0 * L + 0.15 * L * L) * soft * (rk == 2 ? 1.8 : rk ? 1.15 : 1)); e.def = 8.0 * L * (rk ? 1.5 : 1);
  e.hp = e.maxHp = mhp; e.homeX = px; e.homeY = py; e.state = "idle"; e.atkT = 0;
  e.wanderT = rnd(1, 4); e.aggro = false; e.slowT = 0;
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
  for (const core::Json& e : sc["ents"].arr()) {
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
      int px = x, py = y;
      for (int k = 0; k < 30; k++) { const double a = rnd(-wide, wide), b = rnd(-wide, wide); if (!blocked(x + a, y + b)) { px = int(jsRound(x + a)); py = int(jsRound(y + b)); break; } }
      spawnMob(nm, px, py);
    }
  }
  // oyuncu: verilen yer, yoksa giriş bölgesinin (tür 0) ortası; geçilmezse giriş bölgesinin köşesi, o da olmazsa en yakın boş kare
  int px = int(player.x), py = int(player.y); bool have = false;
  if (arrive) { px = arrive[0]; py = arrive[1]; have = true; }
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
  camX = map.px(player.x, player.y); camY = map.py(player.x, player.y);
  arriveT = 1.5;
}

// geçitten geçiş (HTML gotoScene + arrivalNear): hedef sahnede bizim sahneye dönen geçidin yanındaki giriş bölgesi
void World::gotoScene(const std::string& sid, const std::string& fromSid) {
  const core::Json& sc = as_.D()["scenes"][sid];
  GameMap tmp; tmp.load(as_, sc["map"].str());
  const auto& regs = tmp.regions; int backIdx = -1;
  for (const core::Json& e : sc["exits"].arr()) if (std::to_string(e[2].i()) == fromSid || e[2].str() == fromSid) { backIdx = e[0].i(); break; }
  const std::vector<int>* r = nullptr;
  if (backIdx >= 0) {
    const std::vector<int>* ex = nullptr, *nx = nullptr;
    for (const auto& g : regs) if (g[0] == backIdx && g[1] == 1) { ex = &g; break; }
    if (!ex) for (const auto& g : regs) if (g[0] == backIdx) { ex = &g; break; }
    for (const auto& g : regs) if (g[0] == backIdx + 1 && g[1] == 0) { nx = &g; break; }
    if (nx || !ex) r = nx ? nx : ex;
    else {
      const double ax = (ex->at(2) + ex->at(4)) / 2.0, ay = (ex->at(3) + ex->at(5)) / 2.0; double bd = 1e9;
      for (const auto& g : regs) if (g[1] == 0) { const double d = jsHypot((g[2] + g[4]) / 2.0 - ax, (g[3] + g[5]) / 2.0 - ay); if (d < bd) { bd = d; r = &g; } }
      if (!r) r = ex;
    }
  } else for (const auto& g : regs) if (g[1] == 0) { r = &g; break; }
  if (r) { const int a[2] = {int(jsRound(((*r)[2] + (*r)[4]) / 2.0)), int(jsRound(((*r)[3] + (*r)[5]) / 2.0))}; loadScene(sid, a); }
  else loadScene(sid);
}

void World::checkExits() {   // HTML checkExits (zindan kapıları sonraki adımda)
  if (arriveT > 0) return;
  const int cx = int(jsRound(player.x)), cy = int(jsRound(player.y));
  for (const auto& r : map.regions) {
    if (r.size() < 6 || r[1] != 1) continue;
    if (cx >= r[2] && cx <= r[4] && cy >= r[3] && cy <= r[5]) {
      for (const core::Json& e : (*scene_)["exits"].arr()) if (e[0].i() == r[0]) {
        std::string sid = e[2].isStr() ? e[2].str() : e[2].isNum() ? std::to_string(e[2].i()) : "";
        if (sid.empty() || !as_.D()["scenes"][sid].isObj()) return;
        const std::string from = sceneId; gotoScene(sid, from); return;
      }
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

// ---------------- efektler ----------------
int World::pushFx(const std::string& name, double x, double y, int dir) {
  Fx f; f.sp = map.sprite(name); f.sp->glow = true; f.x = x; f.y = y;
  f.anim = fxAnim(*f.sp, dir >= 0 ? dir : player.dir);
  f.len = f.sp->ok() ? f.sp->animLen(f.anim) : 0; f.done = !f.sp->ok() || !f.len;
  fx.push_back(std::move(f)); return int(fx.size()) - 1;
}
void World::shoot(const std::string& name, double sx, double sy, int to, std::function<void()> cb, bool vis) {
  const int i = pushFx(name, sx, sy); Fx& f = fx[i]; f.z = 30; f.proj = true; f.to = to; f.cb = std::move(cb); f.vis = vis; f.loop = true;
}

// ---------------- savaş ----------------
World::Dmg World::dmgCalc(double atk, double def, double mult, double critB, double add) {
  const double base = (atk * mult + add) * rnd(0.92, 1.08);
  const int d = int(std::max(1.0, jsRound(base * 1000 / (1000 + def * 3))));
  const bool crit = random() < 0.08 + critB / 100;
  return {crit ? int(jsRound(d * 1.8)) : d, crit};
}

int World::hitMob(int i, double mult) {   // HTML hitMob (normal saldırı; beceri seçenekleri sonraki adımda)
  Ent& m = ents[i]; if (m.dead) return 0;
  const Stats s = stats(); const double K0 = bal_.cls(P.cls).dmgK;
  const double def = m.weakT > 0 ? (m.weakDef ? std::max(0.0, m.def - m.weakDef) : m.def * 0.4) : m.def;
  const Dmg r = dmgCalc(s.atk, def, mult * K0 * (m.weakT > 0 && !m.weakDef ? 1.15 : 1), s.crit, 0);
  const int d = std::max(1, r.d);
  m.hp -= d; m.aggro = true; m.state = "hurt"; m.animT = 0; m.stateT = 0.3;
  if (m.hp <= 0) killMob(i);
  return d;
}

void World::killMob(int i) {
  Ent& m = ents[i];
  m.dead = true; m.deadT = 0; m.state = "die"; m.respawnT = m.d->rank == 2 ? 90 : m.d->rank ? 40 : 15;
  if (target_ == i) setTarget(-1);
  const double diff = m.d->lv - P.lv;
  const long long xp = (long long)std::max(1.0, jsRound(bal_.mobXp(m.d->lv, m.d->rank) * clampd(1 + diff * 0.1, 0.2, 1.5)));
  gainXp(xp);
  const Stats st = stats();
  P.gold += (long long)jsRound((irnd(m.d->lv, m.d->lv * 3) + m.d->rank * 20) * (1 + st.goldUp / 100));
  if (st.lifeEl && bal_.item("30127") && random() * 100 < st.lifeEl) addItem("30127");   // gece elfi: Yaşam Elementi
  if (random() < 0.1) addItem(P.lv > 10 ? "hp2" : "hp1");
  if (random() < 0.06) addItem(P.lv > 10 ? "mp2" : "mp1");
  if (m.d->rank && random() < 0.6) { const std::string g = randomGear(std::max(1, m.d->lv + 2)); if (!g.empty()) addItem(g); }
  else if (!m.d->passive && random() < 0.025) { const std::string g = randomGear(std::max(1, m.d->lv)); if (!g.empty()) addItem(g); }
  // evcil yumurtası: görünüş ailesi uyan tür varsa küçük olasılıkla (HTML Pet.dropEgg)
  if (const Balance::MobRec* info = bal_.mobInfo(m.name)) if (const std::string* egg = bal_.eggFor(info->look)) {
    const double ch = m.d->rank == 2 ? 0.25 : m.d->rank ? 0.03 : 0.004; if (random() < ch) addItem(*egg);
  }
  if (!m.deathFx.empty()) pushFx(m.deathFx, m.x, m.y);
}

void World::hurtPlayer(int i) {
  Player& p = player; if (p.dead) return;
  const Stats s = stats(); if (random() < s.dodge / 100) return;   // ıska
  Dmg r = dmgCalc(ents[i].atk, s.def, 1); r.d = int(std::max(1.0, jsRound(r.d * (1 - std::min(80.0, s.dr) / 100))));
  if (r.d <= 0) return;
  p.hp -= r.d; p.combatT = 5;
  if (p.hp <= 0) { p.hp = 0; p.dead = true; p.deadT = 0; p.state = "dead"; setTarget(-1); }
}

void World::gainXp(long long n) {
  P.xp += n;
  while (P.xp >= bal_.xpNeed(P.lv)) {
    P.xp -= bal_.xpNeed(P.lv); P.lv++; const Stats s = stats(); player.hp = s.hp; player.mp = s.mp;
    pushFx("LEVELUP", player.x, player.y); P.sp++;
  }
}

// ---------------- güncelleme (HTML update) ----------------
void World::update(double dt, double sx, double sy) {
  time += dt; if (arriveT > 0) arriveT -= dt;
  for (int i = int(timers_.size()) - 1; i >= 0; i--) {   // zamanlayıcılar: sondan başa (HTML gibi; yeni eklenenler bu karede çalışmaz)
    if (size_t(i) >= timers_.size()) continue;
    timers_[i].t -= dt;
    if (timers_[i].t <= 0) { auto fn = std::move(timers_[i].fn); timers_.erase(timers_.begin() + i); fn(); }
  }
  Player& p = player; const Stats s = stats(); const ClassBase& C = bal_.cls(P.cls);
  const double px0 = p.x, py0 = p.y; p.animT += dt * TICK; p.combatT -= dt; p.atkT -= dt;
  if (p.stateT > 0) { p.stateT -= dt; if (p.stateT <= 0) p.state = "idle"; }
  if (p.dead) p.deadT += dt;
  if (!p.dead) {
    const double regen = sceneName == "观林镇" ? 0.03 : p.combatT > 0 ? 0.003 : 0.012;
    p.hp = std::min(s.hp, p.hp + (s.hp * regen + s.hpreg * 0.1) * dt); p.mp = std::min(s.mp, p.mp + (s.mp * regen * 1.3 + s.mpreg * 0.1) * dt);
    bool moving = false;
    if (sx || sy) {
      engage_ = false;
      // ekrandaki yöne en yakın karo ekseni (açılar 27,6° / 152,4° / 207,6° / 332,4°); sınırda titremesin diye son yöne küçük öncelik
      const double ang = std::atan2(sy, sx); int best = 0; double bd = 9;
      for (int i = 0; i < 4; i++) {
        const double aa = std::atan2(DIR4[i][0] * HH + DIR4[i][1] * HH, DIR4[i][0] * HW - DIR4[i][1] * HW);
        double d = std::fabs(std::atan2(std::sin(ang - aa), std::cos(ang - aa))); if (i == lastJoyDir_) d -= 0.25;
        if (d < bd) { bd = d; best = i; }
      }
      lastJoyDir_ = best;
      const double sp = RUN * (1 + s.spd) * dt;
      moveEnt(p, DIR4[best][0] * sp, DIR4[best][1] * sp); p.dir = dirOf(DIR4[best][0], DIR4[best][1]); moving = true;
    } else {
      lastJoyDir_ = -1;
      if (p.state != "attack" && p.state != "cast") {
        const int ti = target_;
        if (engage_ && ti >= 0 && ents[ti].kind == Ent::MOB && !ents[ti].dead) {
          Ent& t = ents[ti]; const double d = jsHypot(t.x - p.x, t.y - p.y);
          // 4 yönlü yürüyüşte engelli karede takılırsa ve yeterince yakınsa olduğu yerden vurur
          const bool stuck = p.hasChase && p.chaseD - d < 0.005 && d <= C.range + 0.6; p.chaseD = d; p.hasChase = true;
          if (d > C.range && !stuck) { stepTo(p, t.x, t.y, RUN * (1 + s.spd), dt); moving = true; }
          else if (p.atkT <= 0) {
            p.atkT = 1.1; p.combatT = 5; p.dir = dirOf(t.x - p.x, t.y - p.y);
            if (C.melee) {
              p.state = "attack"; p.animT = 0; p.stateT = 0.45;
              later(0.25, [this, ti, &C]() { Ent& m = ents[ti]; if (!m.dead && jsHypot(m.x - player.x, m.y - player.y) < C.range + 0.6) { hitMob(ti, 1); pushFx("BLOOD", m.x, m.y); } });
            } else {
              p.state = "cast"; p.animT = 0; p.stateT = 0.45;
              later(0.2, [this, ti, &C]() { shoot(C.bolt, player.x, player.y, ti, [this, ti, &C]() { hitMob(ti, 0.9); if (!C.boltHit.empty()) pushFx(C.boltHit, ents[ti].x, ents[ti].y); }, true); });
            }
          }
        }
      }
    }
    if (p.state == "idle" || p.state == "move") p.state = moving ? "move" : "idle";
    const double went = jsHypot(p.x - px0, p.y - py0) * CELL_PX;
    if (p.state == "move") p.t += went * 8 / STRIDE; else p.t += dt * TICK;
    const std::string before = sceneId; checkExits();
    if (sceneId != before) return;   // sahne değişti: bu karenin geri kalanı yeni sahnede işlemez
  }
  // NPC'ler ve canavarlar (oluşturulma sırasıyla)
  for (size_t i = 0; i < ents.size(); i++) {
    Ent& e = ents[i];
    if (e.kind == Ent::NPC) { e.t += dt * TICK * 0.8; if (e.hidden && (e.respawnT -= dt) <= 0) e.hidden = false; continue; }
    e.t += dt * TICK; e.animT += dt * TICK;
    if (e.dead) { e.deadT += dt; if ((e.respawnT -= dt) <= 0) { e.dead = false; e.hp = e.maxHp; e.x = e.homeX; e.y = e.homeY; e.aggro = false; e.state = "idle"; } continue; }
    e.atkT -= dt; e.slowT -= dt; if (e.weakT > 0) e.weakT -= dt; else if (e.weakDef) e.weakDef = 0;
    if (e.rootT > 0) e.rootT -= dt;
    if (e.sealT > 0) e.sealT -= dt;
    if (e.despairT > 0) e.despairT -= dt;
    if (e.stunT > 0) { e.stunT -= dt; continue; }
    if (e.stateT > 0) { e.stateT -= dt; if (e.stateT <= 0) e.state = "idle"; }
    const double dp = jsHypot(p.x - e.x, p.y - e.y), dh = jsHypot(e.x - e.homeX, e.y - e.homeY);
    const double sp = (e.slowT > 0 ? 1 : 2) * (e.d->rank ? 1.1 : 1);
    if (!e.aggro && !e.d->passive && !p.dead && dp < 3.5 && e.d->lv >= P.lv - 5) e.aggro = true;
    if (e.aggro && (dh > 12 || p.dead)) { e.aggro = false; e.hp = e.maxHp; }
    if (e.state == "hurt" || e.state == "attack") continue;
    if (e.tauntT > 0) e.tauntT -= dt;
    const double df = dp;   // hedef: oyuncu (evcil hayvan sonraki adımda)
    if (e.aggro && !p.dead) {
      if (df > 1.3) { if (!(e.rootT > 0)) { stepTo(e, p.x, p.y, sp, dt); e.state = "move"; } }
      else {
        e.dir = dirOf(p.x - e.x, p.y - e.y);
        if (e.atkT <= 0 && !(e.sealT > 0)) {
          e.atkT = 1.6; e.state = "attack"; e.animT = 0; e.stateT = 0.5;
          later(0.3, [this, i]() { Ent& m = ents[i]; if (m.dead || jsHypot(player.x - m.x, player.y - m.y) >= 1.9) return; hurtPlayer(int(i)); });
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
  std::stable_sort(list.begin(), list.end(), [](const Item& a, const Item& b) { return a.depth < b.depth; });
  for (const Item& it : list) {
    if (it.kind == 0) { const MapObj& ob = map.objs[it.i]; ob.sp->draw(c, ob.anim, tt, int(ob.X - ox), int(ob.Y - oy)); continue; }
    const double ex2 = it.kind == 1 ? ents[it.i].x : player.x, ey2 = it.kind == 1 ? ents[it.i].y : player.y;
    const int X = int(jsRound(map.px(ex2, ey2) - ox)), Y = int(jsRound(map.py(ex2, ey2) - oy));
    if (it.kind == 1) {
      Ent& e = ents[it.i];
      if (o.shadows && !(e.kind == Ent::NPC && e.hidden)) c.shadow(X, Y, 11, 5, 0.35f);
      if (e.kind == Ent::MOB) drawMob(c, e, X, Y);
      else if (!e.hidden && e.sp && e.sp->ok()) e.sp->draw(c, std::min(e.anim, e.sp->animCount() - 1), e.t, X, Y);
    } else {
      if (o.shadows) c.shadow(X, Y, 11, 5, 0.35f);
      drawPlayer(c, X, Y);
    }
  }
  for (Fx& f : fx) if (f.sp && f.sp->ok()) f.sp->draw(c, f.anim, f.t, int(jsRound(map.px(f.x, f.y) - ox + f.ox)), int(jsRound(map.py(f.x, f.y) - oy + f.oy - f.z)));
}

}  // namespace engine
