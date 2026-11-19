// Evcil hayvanlar (魔法兽): HTML www/js/pet.js (docs/07-evcil.md). Sıra ve zarlar HTML ile aynı (tools/test/cpp_evcil.js).
// Kuluçka (kutu, yetenek, 1-3 rastgele beceri), çağırma, dünyada varlık (izleme, taktik modları, saldırı, beceriler, haleler, tokluk,
// mutluluk, konuşma), canavarın hedefi olma, ölme/diriltme, deneyim payı, eşyalar, dönüşüm (幻化), beceri aktarma (技能转移), GM.
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>

#include "engine/world.h"

namespace engine {

namespace {
// beceri etkileri (HTML pet.js SK): orijinal açıklamalardaki etki türü, sayılar bizim ölçeğimiz
struct PSk {
  double mult = 0, aoe = 0, nova = 0, addHp = 0, addLv = 0, addTLv = 0, addMp = 0, taunt = 0, slow = 0, weak = 0, selfDef = 0;
  bool mag = false, both = false, self = false, sup = false, hot = false, hasMp = false;
  double mp = 0, heal = 0, healPct = 0, dur = 0, cd = 0, dream = 0, field = 0;
  Vals buff, pas, aura; std::string fx, proj;
};
const std::map<std::string, PSk>& SK() {
  static const std::map<std::string, PSk> M = [] {
    std::map<std::string, PSk> m;
    auto A = [&](const char* k, double mult, const char* fx) -> PSk& { PSk& d = m[k]; d.mult = mult; d.fx = fx; return d; };
    A("90146", 1.3, "特效-刀光"); A("90145", 1.2, "BLOOD").addHp = 0.02; A("90307", 1.5, "特效-大喷血");
    A("90147", 1.2, "BLOOD").addLv = 4; A("90148", 1.2, "BLOOD").addTLv = 5;
    A("90181", 1.15, "特效-刀光-红").aoe = 2.2; A("90302", 1.15, "特效-刀光-红").aoe = 3.2;
    A("90590", 1.5, "特效-火爆炸").both = true; A("90150", 1.2, "BLOOD").taunt = 8;
    { PSk& d = A("90149", 1.2, "特效-火爆炸"); d.mag = true; d.taunt = 8; d.proj = "特效-火球"; }
    { PSk& d = A("90151", 1.3, "特效-冰块碎裂"); d.mag = true; d.self = true; d.selfDef = 0.15; d.proj = "特效-冰球"; }
    { PSk& d = A("90152", 1.2, "BLOOD"); d.self = true; d.selfDef = 0.2; }
    { PSk& d = A("90305", 1.15, "特效-火爆炸"); d.mag = true; d.addMp = 0.05; d.aoe = 3.2; }
    { PSk& d = A("90597", 1.8, "特效-火爆炸"); d.mag = true; d.cd = 10; }
    { PSk& d = A("90039", 1.8, "特效-火爆炸"); d.mag = true; d.cd = 10; }
    { PSk& d = A("90153", 1.4, "特效-火爆炸"); d.mag = true; d.proj = "特效-火球"; }
    { PSk& d = A("90154", 1.3, "特效-冰块碎裂"); d.mag = true; d.addMp = 0.02; d.proj = "特效-冰球"; }
    { PSk& d = A("90260", 1.3, "特效-蓝火球"); d.mag = true; d.weak = 5; d.cd = 12; d.proj = "特效-蓝火球"; }
    A("90157", 1.0, "LIGHT_ATTACK").mag = true;
    auto S = [&](const char* k) -> PSk& { PSk& d = m[k]; d.sup = true; return d; };
    { PSk& d = S("90155"); d.buff = Vals{{"atk", 0.1}}; d.dur = 30; d.cd = 30; }
    { PSk& d = S("90156"); d.buff = Vals{{"atk", 0.1}}; d.dur = 30; d.cd = 30; }
    { PSk& d = S("90299"); d.heal = 5; d.buff = Vals{{"atk", 0.05}}; d.dur = 6; d.cd = 15; }
    { PSk& d = S("90308"); d.heal = 5; d.buff = Vals{{"atk", 0.05}}; d.dur = 6; d.cd = 15; }
    { PSk& d = S("90298"); d.hot = true; d.cd = 35; }
    // şablon becerileri
    { PSk& d = A("90014", 1.6, "BLOOD"); d.hasMp = true; d.mp = 0; d.cd = 5; }
    A("90024", 1.8, "特效-大喷血"); A("90025", 1.5, "特效-火爆炸").both = true;
    { PSk& d = A("90035", 1.5, "特效-冰块碎裂"); d.both = true; d.slow = 2; }
    { PSk& d = A("90036", 1.5, "特效-火爆炸"); d.mag = true; d.proj = "特效-火球"; }
    { PSk& d = A("90038", 1.4, "特效-冰块碎裂"); d.mag = true; d.slow = 2; d.proj = "特效-冰球"; }
    { PSk& d = S("90041"); d.healPct = 0.08; d.cd = 12; } { PSk& d = S("90049"); d.healPct = 0.12; d.cd = 12; } { PSk& d = S("90057"); d.healPct = 0.16; d.cd = 12; }
    m["90023"].pas = Vals{{"patk", 0.05}, {"crit", 2}}; m["90053"].pas = Vals{{"patk", 0.1}, {"crit", 4}}; m["90054"].pas = Vals{{"patk", 0.15}, {"crit", 6}};
    m["90037"].pas = Vals{{"matk", 0.05}, {"crit", 2}}; m["90051"].pas = Vals{{"matk", 0.1}, {"crit", 4}}; m["90052"].pas = Vals{{"matk", 0.15}, {"crit", 6}};
    m["90027"].pas = Vals{{"hp", 0.05}}; m["90055"].pas = Vals{{"hp", 0.1}}; m["90056"].pas = Vals{{"hp", 0.15}};
    const std::pair<const char*, std::pair<const char*, double>> AU[] = {{"90058", {"atk", 0.03}}, {"90059", {"atk", 0.04}}, {"90060", {"atk", 0.05}}, {"90061", {"def", 0.03}}, {"90062", {"def", 0.04}}, {"90063", {"def", 0.05}},
      {"90064", {"hpP", 0.03}}, {"90065", {"hpP", 0.04}}, {"90066", {"hpP", 0.05}}, {"90068", {"res", 4}}, {"90069", {"res", 6}}, {"90070", {"res", 8}}, {"90071", {"res", 4}}, {"90072", {"res", 6}}, {"90073", {"res", 8}},
      {"90074", {"dodge", 1}}, {"90075", {"dodge", 2}}, {"90076", {"dodge", 3}}, {"90077", {"crit", 1}}, {"90078", {"crit", 2}}, {"90079", {"crit", 3}}};
    for (const auto& a : AU) m[a.first].aura = Vals{{a.second.first, a.second.second}};
    // sonraki sürümün türleri (APK 1019 açıklamaları)
    { PSk& d = m["a90910"]; d.field = 6; d.hasMp = true; d.mp = 200; d.cd = 10; d.fx = "特效-大喷血"; }
    { PSk& d = A("a90908", 1.4, "特效-冰块碎裂"); d.mag = true; d.weak = 5; d.hasMp = true; d.mp = 100; d.cd = 4; d.proj = "特效-蓝火球"; }
    { PSk& d = A("a91035", 1.3, "特效-刀光"); d.nova = 3; d.hasMp = true; d.mp = 30; d.cd = 3; }
    { PSk& d = S("a90080"); d.dream = 6; d.hasMp = true; d.mp = 200; d.cd = 12; }
    return m;
  }();
  return M;
}
const PSk* sk(const std::string& k) { auto it = SK().find(k); return it == SK().end() ? nullptr : &it->second; }
const Vals DREAM[5] = {Vals{{"atk", 0.15}}, Vals{{"def", 0.2}}, Vals{{"spd", 0.25}}, Vals{{"crit", 10}}, Vals{{"dr", 0.15}}};
int boxRank(const std::string& b) { return b == "magic" ? 2 : b == "metal" ? 1 : 0; }
std::string base36(long long v) { const char* D = "0123456789abcdefghijklmnopqrstuvwxyz"; std::string s; if (v <= 0) return "0"; while (v) { s.insert(s.begin(), D[v % 36]); v /= 36; } return s; }
}  // namespace

double World::nowMillis() const {
  if (nowMs >= 0) return nowMs;
  if (clockMs >= 0) return std::floor(clockMs);   // oyun saati (JS Date.now gibi tam milisaniye)
  return double(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count());
}

// ---------------- kayıt ve nitelikler ----------------
std::vector<PetRec*> World::petList() { P.petsSeen = true; std::vector<PetRec*> L; for (PetRec& p : P.pets) if (bal_.pets.by(p.sp)) L.push_back(&p); return L; }
PetRec* World::petActive() { for (PetRec* p : petList()) if (p->uid == P.petOn) return p; return nullptr; }
PetRec* World::petByUid(const std::string& uid) { for (PetRec* p : petList()) if (p->uid == uid) return p; return nullptr; }
const PetForm& World::petForm(const PetRec& p) const {
  const PetSpecies& s = *bal_.pets.by(p.sp); const size_t i = size_t(std::max(0, p.st));
  return i < s.forms.size() ? s.forms[i] : s.forms[0];
}
std::string World::petName(const PetRec& p) const { if (!p.name.empty()) return p.name; return bal_.pets.by(p.sp) ? petForm(p).tr : p.sp; }
std::vector<std::string> World::petSkills(const PetRec& p) const { std::vector<std::string> L = {bal_.pets.by(p.sp)->skill}; L.insert(L.end(), p.sk.begin(), p.sk.end()); return L; }
std::string World::petSkName(const std::string& k) const { auto it = bal_.pets.skills.find(k); return it == bal_.pets.skills.end() ? k : it->second.tr; }
World::PetStats World::petStats(const PetRec& p) const {
  const PetTemplate& t = bal_.pets.templates.at(bal_.pets.by(p.sp)->tpl); const double L = p.lv;
  const double k = (p.tal ? p.tal : 1) * bal_.pets.stages[size_t(std::max(0, p.st))].mult;
  // kalıcı beceriler ve haleler (hale hayvanın kendisine de işler); yetenek meyveleri binde
  Vals b{{"patk", 0}, {"matk", 0}, {"hp", 0}, {"crit", 0}, {"atk", 0}, {"def", 0}, {"hpP", 0}, {"dodge", 0}};
  for (const std::string& id : petSkills(p)) if (const PSk* d = sk(id)) { const Vals& o = d->pas.v.empty() ? d->aura : d->pas; for (const auto& kv : o.v) b.add(kv.first, kv.second); }
  auto g = [&](const char* x) { auto it = p.gift.find(x); return it == p.gift.end() ? 0.0 : it->second; };
  b.add("patk", g("patk") / 1000); b.add("matk", g("matk") / 1000); b.add("hp", g("hp") / 1000);
  PetStats s;
  s.hp = jsRound((400 + 170 * L) * t.hpG / 6400 * k * (1 + b.get("hp") + b.get("hpP")));
  s.mp = jsRound((200 + 60 * L) * t.mpG / 6400 * k);
  s.patk = jsRound((22 + 9 * L) * t.patk / 1040 * k * (1 + b.get("patk") + b.get("atk")));
  s.matk = jsRound((22 + 9 * L) * t.matk / 1040 * k * (1 + b.get("matk") + b.get("atk")));
  s.def = jsRound((20 + 10 * L) * t.def / 550 * k * (1 + b.get("def")));
  s.dodge = (t.dodge ? t.dodge : 120) / 40 + b.get("dodge"); s.crit = b.get("crit"); s.mag = t.mag; s.range = t.mag ? 5 : 1.9;
  return s;
}

// ---------------- kuluçka ----------------
std::vector<std::string> World::petRollSkills(const PetSpecies& s, const std::string& box) {
  static const int RSK[3][4] = {{0, 65, 30, 5}, {0, 45, 40, 15}, {0, 25, 45, 30}};
  const int* w = RSK[box == "magic" ? 2 : box == "metal" ? 1 : 0]; const double r = random() * 100; int n = 0, acc = 0;
  for (int i = 0; i < 4; i++) { acc += w[i]; if (r < acc) { n = i; break; } }
  // havuz: şablonun becerileri; I. kademe daha sık (I 6, II 3, III 1, kademesiz 4); aynı becerinin iki kademesi birlikte gelmez
  auto nameOf = [&](const std::string& k) { return bal_.pets.skills.at(k).tr; };
  auto base = [&](const std::string& k) { std::string n0 = nameOf(k); size_t e = n0.size(); while (e > 0 && n0[e - 1] == 'I') e--; if (e < n0.size() && e > 0 && n0[e - 1] == ' ') return n0.substr(0, e - 1); return n0; };
  auto wt = [&](const std::string& k) { const std::string n0 = nameOf(k); auto ends = [&](const char* x) { const std::string t = x; return n0.size() >= t.size() && n0.compare(n0.size() - t.size(), t.size(), t) == 0; };
    return ends(" III") ? 1 : ends(" II") ? 3 : ends(" I") ? 6 : 4; };
  std::vector<std::string> pool; for (const std::string& k : bal_.pets.templates.at(s.tpl).pool) if (bal_.pets.skills.count(k)) pool.push_back(k);   // (JS: doğuştan beceri metin, havuz sayı → hiç elenmez)
  std::vector<std::string> out;
  while (int(out.size()) < n) {
    std::vector<std::string> c; for (const std::string& k : pool) { bool dup = false; for (const std::string& o : out) if (base(o) == base(k)) dup = true; if (!dup) c.push_back(k); }
    if (c.empty()) break;
    double sum = 0; for (const std::string& k : c) sum += wt(k);
    double t = random() * sum; for (const std::string& k : c) { t -= wt(k); if (t <= 0) { out.push_back(k); break; } }
  }
  return out;
}
PetRec World::petMake(const PetSpecies& s, const std::string& box) {
  const double a = box == "magic" ? 1.05 : box == "metal" ? 0.95 : 0.85, b = box == "magic" ? 1.25 : box == "metal" ? 1.1 : 1.0;
  PetRec p; p.uid = base36((long long)nowMillis()) + std::to_string((long long)std::floor(random() * 1e6)); p.sp = s.cn; p.st = 0;
  p.sk = petRollSkills(s, box); p.lv = 1; p.xp = 0; p.sat = 100; p.joy = 100; p.dead = false;
  char buf[32]; std::snprintf(buf, sizeof buf, "%.3f", a + random() * (b - a)); p.tal = std::strtod(buf, nullptr);   // JS +x.toFixed(3)
  const PetStats S = petStats(p); p.hp = S.hp; p.mp = S.mp; return p;
}
void World::petHatch(const std::string& eggId) {
  const Item* it = bal_.item(eggId); if (!it) return; const PetSpecies* s = bal_.pets.by(it->petJ["egg"].str()); if (!s) return;
  if (int(petList().size()) >= petSlotsN()) { toast(T("En fazla " + std::to_string(petSlotsN()) + " evcil hayvan besleyebilirsin (Sözleşme Taşı hakkı artırır).", "You can keep at most " + std::to_string(petSlotsN()) + " pets (a Contract Stone adds one).")); return; }
  const int need = boxRank(it->petJ["box"].str()); std::string box;
  for (const char* b : {"31149", "31147", "30166"}) { const Item* bi = bal_.item(b); if (bi && countItem(b) && boxRank(bi->petJ["box"].str()) >= need) { box = b; break; } }
  const std::string want = it->petJ["box"].str(); const Item* bn = bal_.item(want == "magic" ? "31149" : want == "metal" ? "31147" : "30166");
  if (box.empty()) { { const std::string b = bn ? bn->name : std::string(); toast(T(it->name + ": " + b + " gerekir.", it->name + ": requires a " + b + ".")); } return; }
  removeItem(eggId, 1); removeItem(box, 1);
  P.pets.push_back(petMake(*s, bal_.item(box)->petJ["box"].str())); PetRec& p = P.pets.back(); const std::string uid = p.uid;
  std::string skl; for (const std::string& k : p.sk) skl += (skl.empty() ? "" : ", ") + petSkName(k); if (skl.empty()) skl = T("yok", "none");
  char tal[32]; std::snprintf(tal, sizeof tal, "%g", p.tal);
  sfx("finish_task"); toast(petName(p) + T(" yumurtadan çıktı!", " hatched!")); note(T("Yeni evcil hayvan: " + petName(p) + " (yetenek ×" + tal + "; rastgele beceriler: " + skl + ")", "New pet: " + petName(p) + " (talent ×" + tal + "; random skills: " + skl + ")"), LOG_Q);
  questFlag("hatch"); if (P.petOn.empty()) petSummon(uid);
  save();
}

// ---------------- çağırma ----------------
void World::petSummon(const std::string& uid) {
  PetRec* p = petByUid(uid); if (!p) return;
  if (p->dead && nowMillis() - p->deadAt > 600000) { p->dead = false; p->hp = jsRound(petStats(*p).hp * 0.1); }   // 10 dakika sonra kendiliğinden
  if (p->dead) { toast(petName(*p) + T(" ölü; Ejderin Kurtuluşu ile dirilt ya da biraz bekle.", " is dead; revive it with Dragon's Redemption or wait a while.")); return; }
  P.petOn = uid; petSpawn(); save();
}
void World::petDismiss() { P.petOn.clear(); petDespawn(); save(); }
void World::petDespawn() {
  pet.on = false; pet.tg = -1;
  player.buffs.erase(std::remove_if(player.buffs.begin(), player.buffs.end(), [](const Buff& b) { return b.id == "petaura"; }), player.buffs.end());
}
void World::petSpawn() {
  petDespawn(); PetRec* p = petActive(); if (!p || p->dead || !scene_) return;
  const int gen = pet.gen + 1; pet = PetEnt(); pet.gen = gen; pet.on = true; pet.uid = p->uid;
  pet.x = player.x - 1; pet.y = player.y + 1; pet.t = random() * 20; pet.dir = 2;   // HTML Ent: t = Math.random() * 20
  pet.atkT = 1; pet.skT = 3; pet.chatT = rnd(20, 50); pet.state = "idle"; pet.dir = 2; pet.animT = 0; pet.auraT = 0;
  pet.lk = petForm(*p).look; pet.sp = map.sprite(pet.lk);
}

// ---------------- dövüş ----------------
// hasar: oyuncunun formülü (dmgCalc), hayvanın kendi saldırısıyla
void World::petHit(int mi, double mult, bool mag, bool both, double add, double taunt, double slow, double weak, bool side) {
  if (mi < 0 || mi >= int(ents.size()) || ents[size_t(mi)].dead || !pet.on) return;
  PetRec* p = petActive(); if (!p) return; const PetStats s = petStats(*p); Ent& m = ents[size_t(mi)];
  const double atk = both ? (s.patk + s.matk) * 0.6 : mag ? s.matk : s.patk;
  const Dmg r = dmgCalc(atk, m.def * (m.weakT > 0 ? 0.4 : 1), mult, s.crit, add);
  m.hp -= r.d; m.aggro = true; m.state = "hurt"; m.stateT = 0.15;
  // hayvan öfkeyi yalnız kendi başlattığı dövüşte ya da öfke çeken beceriyle alır
  if (taunt) { m.foe = pet.gen; m.tauntT = taunt; }
  else if (!side && (m.foe == 0 || (m.foe == -1 && player.dead))) m.foe = pet.gen;
  if (slow) m.slowT = slow;
  if (weak) m.weakT = weak;
  ufloat(mi, (r.crit ? "!" : "") + std::to_string(r.d), 0x9fe0ff, r.crit ? 1.1f : 0.9f);
  if (m.hp <= 0) killMob(mi);
}
void World::petHurt(int mi) {
  if (!pet.on) return;
  PetRec* p = petActive(); if (!p) return;
  const PetStats s = petStats(*p); const Ent& m = ents[size_t(mi)];
  if (random() < s.dodge / 100) { ufloat(-3, T("Iska", "Miss"), 0xcfcfcf); return; }
  const double def = s.def * (1 + (pet.buffOn ? pet.buffDef : 0)); const Dmg r = dmgCalc(m.atk, def, 1);
  p->hp -= r.d; pet.combatT = 5; ufloat(-3, "-" + std::to_string(r.d), 0xff8060, 0.9f);
  if (p->hp <= 0) petDie();
}
void World::petDie() {
  PetRec* p = petActive(); if (!p) return;
  p->hp = 0; p->dead = true; p->deadAt = nowMillis(); p->joy = std::max(0.0, p->joy - 10);
  pushFx("特效-血爆死亡", pet.x, pet.y); toast(petName(*p) + T(" öldü!", " died!"));
  note(petName(*p) + T(" öldü. Ejderin Kurtuluşu ile diriltebilirsin; 10 dakika sonra kendiliğinden dirilir.", " died. Revive it with Dragon's Redemption, or it recovers by itself in 10 minutes."), LOG_Q);
  for (Ent& e : ents) if (e.foe == pet.gen) e.foe = 0;
  P.petOn.clear(); petDespawn(); save();
}
// hedef seçimi (taktik modu)
int World::petPickTarget() {
  const std::string md = P.petMode.empty() ? "attack" : P.petMode;
  auto near = [&](auto f, double r) { int b = -1; double bd = r; for (size_t i = 0; i < ents.size(); i++) { const Ent& e = ents[i]; if (e.kind == Ent::MOB && !e.dead && f(e)) { const double d = jsHypot(e.x - pet.x, e.y - pet.y); if (d < bd) { bd = d; b = int(i); } } } return b; };
  if (md == "idle" || md == "support") return -1;
  if (md == "attack") {
    const int t = target_;
    if (t >= 0 && ents[size_t(t)].kind == Ent::MOB && !ents[size_t(t)].dead && (player.combatT > 0 || ents[size_t(t)].aggro)) return t;
    return pet.tg >= 0 && !ents[size_t(pet.tg)].dead && ents[size_t(pet.tg)].foe == pet.gen ? pet.tg : -1;
  }
  if (md == "counter") return near([&](const Ent& e) { return e.aggro && (e.foe == -1 || e.foe == 0 || e.foe == pet.gen); }, 7);
  return near([&](const Ent& e) { return !e.d->passive; }, 6);   // serbest
}
// tek beceriyi dene; kullanıldıysa true
bool World::petSkill(const std::string& k, int t) {
  PetRec* pp = petActive(); const PSk* d = sk(k); if (!pp || !d || !d->pas.v.empty() || !d->aura.v.empty()) return false;
  PetRec& p = *pp; const PetStats s = petStats(p);
  const double cost = d->hasMp ? d->mp : 20 + p.lv * 2; if (p.mp < cost) return false;
  const Stats ps = stats(); const bool low = player.hp < ps.hp * 0.7;
  auto hasBuff = [&](const char* id) { for (const Buff& b : player.buffs) if (b.id == id) return true; return false; };
  auto setBuff = [&](const char* id, Vals v, double tt) { player.buffs.erase(std::remove_if(player.buffs.begin(), player.buffs.end(), [&](const Buff& b) { return b.id == id; }), player.buffs.end()); Buff b; b.id = id; b.buff = std::move(v); b.t = tt; b.uid = ++fxUid_; player.buffs.push_back(std::move(b)); };
  if (d->sup) {   // destek: sahibinin canı azaldıysa ya da dövüşte güçlendirme yoksa
    if ((d->heal || d->hot || d->healPct) && !low) return false;
    if ((!d->buff.v.empty() || d->dream) && !d->heal && (hasBuff("petbuff") || !(player.combatT > 0))) return false;
    p.mp -= cost;
    if (d->heal || d->healPct) { const double hp = d->heal ? s.matk * d->heal : ps.hp * d->healPct; player.hp = std::min(ps.hp, player.hp + hp); p.hp = std::min(s.hp, p.hp + (d->heal ? hp : s.hp * d->healPct)); ufloat(-2, "+" + std::to_string((long long)jsRound(hp)), 0x7bff8a); }
    if (d->hot) setBuff("pethot", Vals{{"hotT", s.matk / 5}}, 30);
    if (!d->buff.v.empty()) setBuff("petbuff", d->buff, d->dur ? d->dur : 30);
    if (d->dream) setBuff("petbuff", DREAM[irnd(0, 4)], d->dream);
    pushFx("特效-治疗buff", player.x, player.y); ufloat(-3, petSkName(k), 0xffe070, 0.8f); return true;
  }
  if (d->field) {   // Kan Yakan Kalkan: çevredeki dövüşen düşmanlar her saniye can kaybeder, sahibi can kazanır
    bool any = false; for (const Ent& m : ents) if (m.kind == Ent::MOB && !m.dead && m.aggro && jsHypot(m.x - pet.x, m.y - pet.y) < 3.5) any = true;
    if (!any) return false;
    p.mp -= cost; pet.fieldOn = true; pet.fieldT = d->field; pet.fieldTick = 0; pushFx(d->fx, pet.x, pet.y); ufloat(-3, petSkName(k), 0xffe070, 0.8f); return true;
  }
  if (d->nova) {   // Kılıç Fırtınası: kendi çevresine, uzaklık arttıkça az
    std::vector<int> tg; for (size_t i = 0; i < ents.size(); i++) { const Ent& m = ents[i]; if (m.kind == Ent::MOB && !m.dead && (int(i) == t || m.aggro) && jsHypot(m.x - pet.x, m.y - pet.y) <= d->nova) tg.push_back(int(i)); }
    if (tg.empty()) return false;
    p.mp -= cost;
    for (int i : tg) { const double dist = jsHypot(ents[size_t(i)].x - pet.x, ents[size_t(i)].y - pet.y); petHit(i, d->mult * (1 - 0.5 * dist / d->nova), false, false, 0, 0, 0, 0, i != t); }
    pushFx(d->fx, pet.x, pet.y); ufloat(-3, petSkName(k), 0xffe070, 0.8f); return true;
  }
  if (t < 0 || jsHypot(ents[size_t(t)].x - pet.x, ents[size_t(t)].y - pet.y) > (d->mag || !d->proj.empty() ? 5.5 : 2)) return false;
  p.mp -= cost;
  const Ent& tm = ents[size_t(t)];
  const double add = (d->addHp ? s.hp * d->addHp : 0) + (d->addLv ? p.lv * d->addLv : 0) + (d->addTLv ? tm.d->lv * d->addTLv : 0) + (d->addMp ? s.mp * d->addMp : 0);
  const PSk dd = *d;
  // alan becerisi yalnız zaten dövüşen canavarlara vurur ve öfkeyi yalnız asıl hedef çeker
  auto land = [this, dd, t, add]() {
    if (dd.aoe) { const double tx = ents[size_t(t)].x, ty = ents[size_t(t)].y;
      for (size_t i = 0; i < ents.size(); i++) { const Ent& m = ents[i]; if (m.kind == Ent::MOB && !m.dead && (int(i) == t || m.aggro) && jsHypot(m.x - tx, m.y - ty) <= dd.aoe) petHit(int(i), dd.mult, dd.mag, dd.both, add, dd.taunt, dd.slow, dd.weak, int(i) != t); } }
    else petHit(t, dd.mult, dd.mag, dd.both, add, dd.taunt, dd.slow, dd.weak, false);
    if (!dd.fx.empty()) pushFx(dd.fx, ents[size_t(t)].x, ents[size_t(t)].y);
  };
  if (d->self) { pet.buffOn = true; pet.buffDef = d->selfDef; pet.buffT = 10; }
  pet.dir = dirOf(tm.x - pet.x, tm.y - pet.y);
  if (!d->proj.empty()) shoot(d->proj, pet.x, pet.y, t, land, true); else land();
  ufloat(-3, petSkName(k), 0xffe070, 0.8f); return true;
}

void World::petUpdate(double dt) {
  if (!P.pets.empty() && !petList().empty() && !flags.count("hatch")) flags.insert("hatch");   // kuluçka görevi: hayvanı olan oyuncu için hazır
  PetRec* pp = petActive();
  if (!pp) { if (pet.on) petDespawn(); return; }
  if (!pet.on && !pp->dead) petSpawn();
  if (!pet.on) return;
  PetRec& p = *pp; Player& pl = player; const PetStats st = petStats(p);
  pet.t += dt * TICK; pet.animT += dt * TICK; pet.atkT -= dt; pet.skT -= dt; pet.combatT -= dt; pet.chatT -= dt;
  if (pet.buffOn && (pet.buffT -= dt) <= 0) pet.buffOn = false;
  if (pet.stateT > 0 && (pet.stateT -= dt) <= 0) pet.state = "idle";
  // hale: sahibine sürekli yenilenen güçlendirme
  if ((pet.auraT -= dt) <= 0) {
    pet.auraT = 1; Vals a; for (const std::string& k : petSkills(p)) if (const PSk* d = sk(k)) for (const auto& kv : d->aura.v) a.add(kv.first, kv.second);
    pl.buffs.erase(std::remove_if(pl.buffs.begin(), pl.buffs.end(), [](const Buff& b) { return b.id == "petaura"; }), pl.buffs.end());
    if (!a.v.empty()) { Buff b; b.id = "petaura"; b.buff = a; b.t = 1.6; b.uid = ++fxUid_; pl.buffs.push_back(std::move(b)); }
  }
  // Kan Yakan Kalkan
  if (pet.fieldOn) {
    if ((pet.fieldT -= dt) <= 0) pet.fieldOn = false;
    else if ((pet.fieldTick -= dt) <= 0) {
      pet.fieldTick = 1; int n = 0;
      for (size_t i = 0; i < ents.size(); i++) { const Ent& m = ents[i]; if (m.kind == Ent::MOB && !m.dead && m.aggro && jsHypot(m.x - pet.x, m.y - pet.y) < 3.5) { petHit(int(i), 0.35, true, false, 0, 0, 0, 0, true); n++; } }
      if (n) { const Stats ps = stats(); const double h = jsRound(st.matk * 0.3); pl.hp = std::min(ps.hp, pl.hp + h); ufloat(-2, "+" + std::to_string((long long)h), 0x7bff8a, 0.7f); }
    }
  }
  if (!pet.on) return;
  // yenilenme, tokluk, mutluluk
  const double rg = pet.combatT > 0 ? 0.003 : 0.015; p.hp = std::min(st.hp, p.hp + st.hp * rg * dt); p.mp = std::min(st.mp, p.mp + st.mp * rg * 1.3 * dt);
  if ((petSatT_ += dt) >= 120) { petSatT_ = 0; p.sat = std::max(0.0, p.sat - 1); }
  if ((petJoyT_ += dt) >= 60) { petJoyT_ = 0; if (p.sat < 20) p.joy = std::max(0.0, p.joy - 1); }
  if (pet.chatT <= 0) {   // konuşma: türün satırları + bu biçime özgü satırlar
    pet.chatT = rnd(45, 100); std::vector<std::string> L = bal_.pets.by(p.sp)->chatTr; const PetForm& f = petForm(p); L.insert(L.end(), f.sayTr.begin(), f.sayTr.end());
    if (!L.empty()) { pet.say = L[size_t(irnd(0, int(L.size()) - 1))]; pet.sayT = 4; }
  }
  if (pet.sayT > 0) pet.sayT -= dt;
  if (pl.dead) { pet.state = "idle"; return; }
  // çok uzaklaşınca sahibinin yanına ışınlanır
  const double dp = jsHypot(pl.x - pet.x, pl.y - pet.y); if (dp > 14) { pet.x = pl.x - 1; pet.y = pl.y + 1; }
  const bool hungry = p.sat <= 0 || p.joy <= 20;
  int t = hungry ? -1 : petPickTarget(); if (t >= 0 && jsHypot(ents[size_t(t)].x - pl.x, ents[size_t(t)].y - pl.y) > 12) t = -1;
  pet.tg = t;
  if (pet.state == "attack" || pet.state == "cast") return;
  const std::string md = P.petMode.empty() ? "attack" : P.petMode;
  if (!hungry && pet.skT <= 0 && md != "idle") {   // beceriler sırayla: doğuştan önce, sonra rastgeleler; her birinin kendi beklemesi
    pet.skT = 1; const double now = time;
    for (const std::string& k : petSkills(p)) {
      const PSk* d = sk(k); if (!d || !d->pas.v.empty() || !d->aura.v.empty()) continue;
      auto c = pet.cd.find(k); if (c != pet.cd.end() && c->second > now) continue;
      if (md == "support" && !d->sup) continue;
      if (petSkill(k, t)) { pet.cd[k] = now + (d->cd ? d->cd : 8); pet.state = "cast"; pet.stateT = 0.4; pet.skT = 2; return; }
      if (!pet.on) return;
    }
  }
  if (t >= 0) {
    const Ent& tm = ents[size_t(t)]; const double d = jsHypot(tm.x - pet.x, tm.y - pet.y);
    if (d > st.range) { stepTo(pet, tm.x, tm.y, RUN * 0.95, dt); pet.state = "move"; }
    else if (pet.atkT <= 0) {
      pet.atkT = 1.5; pet.state = "attack"; pet.animT = 0; pet.stateT = 0.45; pet.dir = dirOf(tm.x - pet.x, tm.y - pet.y); pet.combatT = 5;
      const bool mag = st.mag;
      later(0.25, [this, t, mag]() {
        if (!pet.on || ents[size_t(t)].dead) return;
        if (mag) shoot("特效-火球", pet.x, pet.y, t, [this, t]() { petHit(t, 1, true, false, 0, 0, 0, 0, false); }, true);
        else petHit(t, 1, false, false, 0, 0, 0, 0, false);
      });
    } else pet.state = "idle";
  } else if (dp > 2.2) { stepTo(pet, pl.x - 0.8, pl.y + 0.8, RUN * (dp > 5 ? 1.3 : 1), dt); pet.state = "move"; }
  else pet.state = "idle";
}
// öldürmeden deneyim payı (sahibinin seviyesini geçemez; 5'ten fazla gerideyse ×3)
void World::petOnKill(const Ent& m, long long xp) {
  (void)m; PetRec* p = petActive(); if (!p || p->dead) return; if (p->lv >= P.lv) return;
  p->xp += jsRound(xp * 0.5 * (p->lv < P.lv - 5 ? 3 : 1)); petGainLv(*p);
}
void World::petGainLv(PetRec& p) {
  bool up = false; while (p.xp >= petNeedXp(p.lv) && p.lv < P.lv) { p.xp -= petNeedXp(p.lv); p.lv++; up = true; }
  if (up) { const PetStats s = petStats(p); p.hp = s.hp; p.mp = s.mp; if (pet.on && pet.uid == p.uid) { pushFx("LEVELUP", pet.x, pet.y); ufloat(-3, T("Seviye ", "Level ") + std::to_string(p.lv) + "!", 0xffe070, 1.2f); } note(T(petName(p) + " " + std::to_string(p.lv) + ". seviyeye ulaştı.", petName(p) + " reached level " + std::to_string(p.lv) + "."), LOG_Q); }
  if (p.lv >= P.lv) p.xp = std::min(p.xp, double(petNeedXp(p.lv) - 1));
}

// ---------------- dönüşüm (幻化) ----------------
static const int TFBASE[8] = {0, 80, 70, 60, 50, 40, 30, 20};
World::PetTf World::petTfInfo(const PetRec* main, const PetRec* mat, const std::vector<std::string>& aids) {
  PetTf r; if (!main) { r.why = T("Ana hayvanı seç.", "Choose the main pet."); return r; }
  if (main->st >= 7) { r.why = T("En yüksek dönüşüm düzeyinde.", "Already at the highest transformation level."); return r; }
  const int nx = main->st + 1; const PetStage& S = bal_.pets.stages[size_t(nx)]; r.next = nx; r.need = S.lv; r.cost = S.cost;
  if (!petResting(main)) { r.why = T("Ana hayvan dinleniyor olmalı (geri çağır; ölüyse dirilt).", "The main pet must be resting (dismiss it; revive it if dead)."); return r; }
  if (main->lv < S.lv) { r.why = T("Gereken seviye: ", "Required level: ") + std::to_string(S.lv); return r; }
  if (!mat) { r.why = T("Yardımcı hayvanı seç.", "Choose the helper pet."); return r; }
  if (mat->uid == main->uid) { r.why = T("Yardımcı hayvan başka olmalı.", "The helper must be another pet."); return r; }
  if (!petResting(mat)) { r.why = T("Yardımcı hayvan dinleniyor olmalı.", "The helper pet must be resting."); return r; }
  double c = TFBASE[nx] + (mat->sp == main->sp ? 10 : 0) + 5 * mat->st;
  for (const std::string& id : aids) {
    const Item* it = bal_.item(id); if (!it || !it->pet) continue; const core::Json& u = it->petJ;
    if (u["tf"].str() == "luck") c += u["add"].num();
    if (u["tf"].str() == "sure" && main->st < u["below"].num()) c = 100;
    if (u["tf"].str() == "keep") r.keep = true;
  }
  r.ok = true; r.chance = std::min(100.0, c); return r;
}
int World::petTransform(const std::string& mainUid, const std::string& matUid, const std::vector<std::string>& aids) {
  PetRec* main = petByUid(mainUid); PetRec* mat = petByUid(matUid);
  std::vector<std::string> aid; for (const std::string& id : aids) if (!id.empty() && countItem(id) > 0) aid.push_back(id);
  const PetTf r = petTfInfo(main, mat, aid);
  if (!r.ok) { toast(r.why); return -1; }
  if (P.gold < r.cost) { toast(T("Yeterli altının yok (", "Not enough gold (") + std::to_string(r.cost) + ")."); return -1; }
  P.gold -= r.cost; for (const std::string& id : aid) removeItem(id, 1);
  const std::string mu = mat->uid; P.pets.erase(std::remove_if(P.pets.begin(), P.pets.end(), [&](const PetRec& x) { return x.uid == mu; }), P.pets.end());
  main = petByUid(mainUid);
  const bool okk = random() * 100 < r.chance; const std::string n0 = petName(*main);
  if (okk) {
    main->st = r.next; const PetStats s = petStats(*main); main->hp = s.hp; main->mp = s.mp; sfx("finish_task");
    toast(T("Dönüşüm başarılı! " + n0 + " → " + petName(*main) + " (düzey " + std::to_string(main->st) + ")", "Transformation succeeded! " + n0 + " → " + petName(*main) + " (level " + std::to_string(main->st) + ")"));
    note(T(n0 + " dönüşüm düzeyi " + std::to_string(main->st) + "'e ulaştı!", n0 + " reached transformation level " + std::to_string(main->st) + "!"), LOG_Q);
  } else {
    if (!r.keep && main->st > 0) main->st--;
    toast(T(std::string("Dönüşüm başarısız. ") + (r.keep ? "Soy Rünü düzeyi korudu." : "Düzey: " + std::to_string(main->st)), std::string("Transformation failed. ") + (r.keep ? "The Bloodline Rune kept its level." : "Level: " + std::to_string(main->st))));
    note(n0 + T(": dönüşüm başarısız.", ": transformation failed."), LOG_Q);
  }
  save(); return okk ? 1 : 0;
}
// ---------------- beceri aktarma (技能转移) ----------------
World::PetTf World::petSkInfo(const PetRec* main, const PetRec* mat, const std::vector<std::string>& runes) {
  PetTf r; if (!main) { r.why = T("Ana hayvanı seç.", "Choose the main pet."); return r; }
  if (!mat) { r.why = T("Yardımcı hayvanı seç.", "Choose the helper pet."); return r; }
  if (mat->uid == main->uid) { r.why = T("Yardımcı hayvan başka olmalı.", "The helper must be another pet."); return r; }
  if (!petResting(main) || !petResting(mat)) { r.why = T("İki hayvan da dinleniyor olmalı.", "Both pets must be resting."); return r; }
  if (bal_.pets.by(main->sp)->tpl != bal_.pets.by(mat->sp)->tpl) { r.why = T("Yalnız aynı türden (fiziksel, büyü, savunma, destek) hayvanlar beceri aktarabilir.", "Only pets of the same type (physical, magic, defense, support) can transfer skills."); return r; }
  for (const std::string& k : mat->sk) if (std::find(main->sk.begin(), main->sk.end(), k) == main->sk.end()) r.give.push_back(k);   // (doğuştan beceri metin: hiç eşit sayılmaz)
  if (r.give.empty()) { r.why = T("Yardımcının, ana hayvanda olmayan rastgele becerisi yok.", "The helper has no random skill the main pet lacks."); return r; }
  for (const std::string& id : runes) {
    const Item* it = bal_.item(id); if (!it || !it->pet || !it->petJ["sk"].isStr()) continue; const core::Json& u = it->petJ; const int sl = u["slot"].i();
    if (u["sk"].str() == "give" && sl >= 0 && sl < int(mat->sk.size()) && std::find(r.give.begin(), r.give.end(), mat->sk[size_t(sl)]) != r.give.end()) r.gs = sl;
    if (u["sk"].str() == "learn" && sl >= 0 && sl < int(main->sk.size())) r.ls = sl;
  }
  r.ok = true; r.cost = 100 + 10 * main->lv; return r;
}
std::string World::petTransfer(const std::string& mainUid, const std::string& matUid, const std::vector<std::string>& runes) {
  PetRec* main = petByUid(mainUid); PetRec* mat = petByUid(matUid);
  std::vector<std::string> rn; for (const std::string& id : runes) if (!id.empty() && countItem(id) > 0) rn.push_back(id);
  const PetTf r = petSkInfo(main, mat, rn);
  if (!r.ok) { toast(r.why); return ""; }
  if (P.gold < r.cost) { toast(T("Yeterli altının yok (", "Not enough gold (") + std::to_string(r.cost) + ")."); return ""; }
  P.gold -= r.cost; for (const std::string& id : rn) removeItem(id, 1);
  const std::string k = r.gs >= 0 ? mat->sk[size_t(r.gs)] : r.give[size_t(irnd(0, int(r.give.size()) - 1))];
  // yuva: rün yoksa rastgele; 3'ten az rastgele becerisi olan hayvan bazen yeni yuva açar
  const int slot = r.ls >= 0 ? r.ls : int(main->sk.size()) < 3 && (main->sk.empty() || random() < 0.25) ? int(main->sk.size()) : irnd(0, int(main->sk.size()) - 1);
  const std::string old = slot < int(main->sk.size()) ? main->sk[size_t(slot)] : std::string();
  if (slot < int(main->sk.size())) main->sk[size_t(slot)] = k; else main->sk.push_back(k);
  const std::string mu = mat->uid; P.pets.erase(std::remove_if(P.pets.begin(), P.pets.end(), [&](const PetRec& x) { return x.uid == mu; }), P.pets.end());
  main = petByUid(mainUid);
  sfx("finish_task"); toast(T(petName(*main) + " yeni beceri öğrendi: " + petSkName(k) + (old.empty() ? std::string() : " (" + petSkName(old) + " yerine)"), petName(*main) + " learned " + petSkName(k) + (old.empty() ? std::string() : " (replacing " + petSkName(old) + ")")));
  note(T("Beceri aktarma: ", "Skill transfer: ") + petName(*main) + " ← " + petSkName(k), LOG_Q);
  save(); return k;
}

// ---------------- eşyalar: kuluçka, mama, iksir, diriltme, sözleşme taşı, yetenek meyvesi, deneyim ----------------
bool World::petUseItem(const std::string& id) {
  const Item* it = bal_.item(id); if (!it || !it->pet) return false; const core::Json& u = it->petJ;
  if (u["egg"].truthy()) { petHatch(id); return true; }
  if (u["box"].truthy()) { toast(T("Kuluçka kutusu: çantadaki bir yumurtayı kullanınca kendiliğinden kullanılır.", "Incubator: used automatically when you use an egg from your bag.")); return true; }
  if (u["tf"].truthy() || u["sk"].truthy()) { toast(T("Dönüşüm/beceri aktarma eşyası: Evcil hayvan penceresinin Dönüşüm bölümünde ya da Büyülü Canavar Ustası'nda kullanılır.", "Transformation/skill transfer aid: used in the pet window's Transform panel or at the Magic Beast Master.")); return true; }
  if (u["petSlot"].truthy()) { P.petSlots = petSlotsN() + 1; removeItem(id, 1); toast(T("Evcil hayvan hakkın: ", "Pet slots: ") + std::to_string(petSlotsN())); save(); return true; }
  PetRec* p = nullptr;
  if (u["petRevive"].truthy()) { for (PetRec* x : petList()) if (x->uid == P.petSel && x->dead) { p = x; break; } if (!p) for (PetRec* x : petList()) if (x->dead) { p = x; break; } }
  else p = petActive();
  if (!p) { toast(u["petRevive"].truthy() ? T("Ölü evcil hayvanın yok.", "You have no dead pet.") : T("Önce bir evcil hayvan çağır.", "Summon a pet first.")); return true; }
  const PetStats st = petStats(*p);
  if (u["petRevive"].truthy()) { p->dead = false; p->hp = jsRound(st.hp * u["petRevive"].num()); toast(petName(*p) + T(" dirildi.", " was revived.")); }
  else if (u["food"].truthy()) { if (p->sat >= 100) { toast(petName(*p) + T(" tok.", " is full.")); return true; } p->sat = std::min(100.0, p->sat + u["food"].num()); p->joy = std::min(100.0, p->joy + 10); if (pet.on) ufloat(-3, T("Hım hım!", "Yum!"), 0x7bff8a); }
  else if (u["petHp"].truthy()) { if (p->hp >= st.hp) { toast(T("Canı dolu.", "HP is full.")); return true; } p->hp = std::min(st.hp, p->hp + u["petHp"].num()); if (pet.on) ufloat(-3, "+" + std::to_string(u["petHp"].i()), 0x7bff8a); }
  else if (u["petMp"].truthy()) p->mp = std::min(st.mp, p->mp + u["petMp"].num());
  else if (u["petGift"].isArr()) { const std::string k = u["petGift"][0].str(); const double v = u["petGift"][1].num(); p->gift[k] += v; toast(petName(*p) + T(": yetenek +", ": talent +") + std::to_string((long long)v)); }
  else if (u["petXp"].truthy()) { if (p->lv >= P.lv) { toast(T("Evcil hayvanın seviyesi senin seviyeni geçemez.", "Your pet's level can't exceed yours.")); return true; } p->xp += u["petXp"].num(); petGainLv(*p); }
  removeItem(id, 1); save(); return true;
}
void World::petRelease(const std::string& uid) {
  auto it = std::find_if(P.pets.begin(), P.pets.end(), [&](const PetRec& x) { return x.uid == uid; }); if (it == P.pets.end()) return;
  if (P.petOn == uid) petDismiss();
  P.pets.erase(std::find_if(P.pets.begin(), P.pets.end(), [&](const PetRec& x) { return x.uid == uid; })); save();
}

// ---------------- GM (HTML Pet.GM) ----------------
static const char* BOXI(const std::string& b) { return b == "magic" ? "31149" : b == "metal" ? "31147" : "30166"; }
void World::gmPetEgg(const std::string& cn) { const PetSpecies* s = bal_.pets.by(cn); if (!s) return; addItem(s->egg, 1, true); addItem(BOXI(s->box), 1, true); toast(itemName(s->egg) + T(" + kutu verildi; çantadan kullan.", " + incubator given; use it from your bag.")); }
void World::gmPetGive(const std::string& cn) {
  const PetSpecies* s = bal_.pets.by(cn); if (!s) return;
  if (int(petList().size()) >= petSlotsN()) P.petSlots = int(petList().size()) + 1;
  addItem(s->egg, 1, true); addItem("31149", 1, true); petHatch(s->egg);
}
static PetRec* gmCur(World& w) { if (PetRec* p = w.petActive()) return p; auto L = w.petList(); return L.empty() ? nullptr : L[0]; }
void World::gmPetLevel() { PetRec* p = gmCur(*this); if (!p) { toast(T("Evcil hayvanın yok.", "No pet.")); return; } p->lv = P.lv; p->xp = 0; const PetStats s = petStats(*p); p->hp = s.hp; p->mp = s.mp; p->dead = false; toast(petName(*p) + " " + T("Sv", "Lv") + " " + std::to_string(p->lv)); }
void World::gmPetCare() {
  for (PetRec* p : petList()) { const PetStats s = petStats(*p); p->dead = false; p->hp = s.hp; p->mp = s.mp; p->sat = 100; p->joy = 100; }
  if (!petActive()) { auto L = petList(); if (!L.empty()) petSummon(L[0]->uid); }
  toast(T("Bütün hayvanlar dirildi, doydu, iyileşti.", "All pets revived, fed and healed."));
}
void World::gmPetItems() { for (const auto& x : std::vector<std::pair<const char*, int>>{{"30022", 20}, {"30021", 10}, {"30755", 10}, {"30025", 5}, {"30595", 2}, {"30006", 3}, {"30166", 3}, {"31147", 3}, {"31149", 3}}) addItem(x.first, x.second, true); toast(T("Evcil hayvan eşyaları verildi.", "Pet items given.")); }
void World::gmPetHungry() { if (PetRec* p = petActive()) { p->sat = 0; p->joy = 15; toast(T("Hayvan acıktı (savaşmaz).", "Pet is hungry (won't fight).")); } }
void World::gmPetClear() { P.pets.clear(); P.petOn.clear(); petDespawn(); toast(T("Bütün hayvanlar silindi.", "All pets removed.")); }
void World::gmPetStage(int n) {
  PetRec* p = gmCur(*this); if (!p) { toast(T("Evcil hayvanın yok.", "No pet.")); return; }
  p->st = n >= 0 ? std::max(0, std::min(7, n)) : (p->st + 1) % 8; const PetStats s = petStats(*p); p->hp = s.hp; p->mp = s.mp;
  toast(petName(*p) + " · " + T("dönüşüm", "transform") + " " + std::to_string(p->st) + "/7");
}
void World::gmPetSkills() {
  PetRec* p = gmCur(*this); if (!p) { toast(T("Evcil hayvanın yok.", "No pet.")); return; }
  p->sk.clear(); const PetSpecies& s = *bal_.pets.by(p->sp);
  for (int i = 0; i < 6 && p->sk.size() < 3; i++) for (const std::string& k : petRollSkills(s, "magic")) if (p->sk.size() < 3 && std::find(p->sk.begin(), p->sk.end(), k) == p->sk.end()) p->sk.push_back(k);
  std::string L; for (const std::string& k : p->sk) L += (L.empty() ? "" : ", ") + petSkName(k);
  toast(T("Rastgele beceriler: ", "Random skills: ") + (L.empty() ? std::string("-") : L));
}
void World::gmPetTf() {
  PetRec* p = gmCur(*this); if (!p) { toast(T("Evcil hayvanın yok.", "No pet.")); return; }
  for (const char* id : {"30164", "30730", "31234", "30731", "30749", "30023", "30750", "30751", "30752", "30753"}) addItem(id, 3, true);
  P.gold += 20000;
  if (int(P.pets.size()) + 2 > petSlotsN()) P.petSlots = int(P.pets.size()) + 2;
  const std::string sp = p->sp; const int lv = p->lv;
  for (int i = 0; i < 2; i++) { PetRec q = petMake(*bal_.pets.by(sp), "magic"); q.lv = lv; const PetStats s = petStats(q); q.hp = s.hp; q.mp = s.mp; P.pets.push_back(q); }
  toast(T("Dönüşüm eşyaları, 2 yardımcı hayvan ve 20000 altın verildi.", "Transformation aids, 2 helper pets and 20000 gold given."));
}

}  // namespace engine
