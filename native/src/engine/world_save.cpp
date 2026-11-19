// Kayıt: HTML game.js newSave, save, load/fixSave, fixSkills ve ui.js start. Biçim HTML'deki kayıtla aynı JSON (localStorage
// 'anrufen_save_v1', sunucudaki karakter): iki sürüm birbirinin kaydını okur (tools/test/cpp_kayit.js).
// C++'ın tutmadığı alanlar (sunucu kimliği id, eski gear, qitems, flags …) okunan kayıttan (P.raw) aynen geri yazılır; HTML'de yalnız
// kullanılınca oluşan alanlar (adv, home, life, dun, dg, pets, petOn …) kayıtta varsa ya da değer boş değilse yazılır.
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "engine/world.h"

namespace engine {

using core::Json;

namespace {
const std::vector<std::string> QUICK0 = {"s0", "s1", "s2", "s3", "s4", "s5", "i:hp1", "i:mp1"};
// acemi başlığı ve ayakkabısı (HTML NEWBIE): çok eski kayıtta gear.head varsa giyilir
const std::map<std::string, std::pair<std::string, std::string>> NEWBIE = {{"战士", {"10002", "10439"}}, {"法师", {"10005", "10058"}}, {"牧师", {"10881", "10884"}}};

// JS'te metin ya da sayı olabilen kimlik (eşya, beceri): String(x)
std::string idOf(const Json& j) { return j.isStr() ? j.str() : j.isNum() ? core::jsNumStr(j.num()) : std::string(); }
// rakamlardan oluşan metin JSON'a sayı olarak (evcil hayvanın rastgele becerileri HTML'de sayı)
Json numOrText(const std::string& s) {
  if (!s.empty() && s.size() < 16 && s.find_first_not_of("0123456789") == std::string::npos && (s == "0" || s[0] != '0')) return Json::number(std::strtod(s.c_str(), nullptr));
  return Json::text(s);
}
Json N(double v) { return Json::number(v); }
Json T(const std::string& s) { return Json::text(s); }
}  // namespace

// HTML newSave(name, cls, race, sex) + P.face (ırk/cinsiyet + 00 + yüz)
void World::newChar(const std::string& name, const std::string& cls, const std::string& race, const std::string& sex, int face) {
  P = CharData(); flags.clear();
  P.name = name; P.lv = 1; P.xp = 0; P.gold = 30; P.hp = 1e9; P.mp = 1e9;
  P.bag = {{"hp1", 5}, {"mp1", 3}};
  P.scene = race == "精灵" ? "120205" : "120207"; P.x = 3; P.y = 13;   // haritanın kendi varış noktası (Rehber'in yanı)
  P.quick = QUICK0;
  setChar(cls, race, sex);
  if (!skills().empty()) P.sk[skills()[0].id] = 1;
  P.sp = 1;
  P.face = std::to_string((race == "人类" ? 0 : 2) + (sex == "male" ? 1 : 2)) + "00" + std::to_string(face);
  // HTML'deki alan sırası (yazılırken korunur): v, name, cls, race, sex, lv, xp, gold, hp, mp, gear, eq, bag, quests, done, qitems, scene, x, y, quick, sv, sk, sp, flags, face
  Json o = Json::object();
  o.set("v", N(1));
  for (const char* k : {"name", "cls", "race", "sex", "lv", "xp", "gold", "hp", "mp"}) o.set(k, Json());
  Json g = Json::object(); g.set("weap", N(0)); g.set("body", N(0)); g.set("head", N(0)); o.set("gear", g);
  for (const char* k : {"eq", "bag", "quests", "done"}) o.set(k, Json());
  o.set("qitems", Json::object());
  for (const char* k : {"scene", "x", "y", "quick"}) o.set(k, Json());
  o.set("sv", N(2));
  for (const char* k : {"sk", "sp"}) o.set(k, Json());
  o.set("flags", Json::object());
  P.raw = o;
}

// HTML save(): oyuncu varsa harita, yer, can ve mana kayda geçer
Json World::saveJson() {
  if (!sceneId.empty()) { P.scene = sceneId; P.x = player.x; P.y = player.y; P.hp = player.hp; P.mp = player.mp; }
  const Json& R = P.raw;
  Json o = R.isObj() ? R : Json::object();
  if (!o.has("v")) o.set("v", N(1));
  o.set("name", T(P.name)); o.set("cls", T(P.cls)); o.set("race", T(P.race)); o.set("sex", T(P.sex));
  o.set("lv", N(P.lv)); o.set("xp", N(double(P.xp))); o.set("gold", N(double(P.gold))); o.set("hp", N(P.hp)); o.set("mp", N(P.mp));
  if (!o["gear"].truthy()) { Json g = Json::object(); g.set("weap", N(0)); g.set("body", N(0)); g.set("head", N(0)); o.set("gear", g); }
  { // ekipman: çıkarılan yuva HTML'de null kalır
    Json e = Json::object();
    for (const auto& kv : R["eq"].obj()) { auto it = P.eq.find(kv.first); e.set(kv.first, it != P.eq.end() && !it->second.empty() ? T(it->second) : Json()); }
    for (const auto& kv : P.eq) if (!kv.second.empty() && !e.has(kv.first)) e.set(kv.first, T(kv.second));
    o.set("eq", e);
  }
  { Json b = Json::array(); for (const auto& x : P.bag) { Json it = Json::object(); it.set("id", T(x.first)); it.set("n", N(x.second)); b.push(it); } o.set("bag", b); }
  { // görevler: okunan kayıttaki görev nesnesi korunur (boş sayaç c: {} dahil)
    Json q = Json::object();
    for (const auto& kv : P.quests) {
      const std::string id = std::to_string(kv.first); const Json& r = R["quests"][id];
      Json st = r.isObj() ? r : Json::object(); st.set("n", N(kv.second.n)); st.set("ready", Json::boolean(kv.second.ready));
      if (!kv.second.c.empty() || st.has("c")) { Json c = Json::object(); for (const auto& x : kv.second.c) c.set(x.first, N(x.second)); st.set("c", c); }
      q.set(id, st);
    }
    o.set("quests", q);
  }
  { Json d = Json::object(); for (int id : P.done) d.set(std::to_string(id), Json::boolean(true)); o.set("done", d); }
  if (!o["qitems"].truthy()) o.set("qitems", Json::object());
  o.set("scene", T(P.scene)); o.set("x", N(P.x)); o.set("y", N(P.y));
  { Json q = Json::array(); for (const std::string& s : P.quick) q.push(s.empty() ? Json() : T(s)); o.set("quick", q); }
  o.set("sv", N(2));
  { Json s = Json::object(); for (const auto& kv : P.sk) s.set(kv.first, N(kv.second)); o.set("sk", s); }
  o.set("sp", N(P.sp));
  if (!o["flags"].truthy()) o.set("flags", Json::object());
  o.set("face", T(P.face));
  // yalnız kullanılınca oluşan alanlar
  if (P.adv || o.has("adv")) o.set("adv", N(P.adv));
  if (P.hasHome) { Json h = Json::array({T(P.homeScene)}); if (P.homeXY) { h.push(N(P.homeX)); h.push(N(P.homeY)); } o.set("home", h); }
  if (!P.life.empty() || o.has("life")) { Json l = Json::object(); for (const auto& kv : P.life) l.set(kv.first, N(kv.second)); o.set("life", l); }
  if (P.dun.on) {
    Json d = Json::object(); d.set("id", T(P.dun.id)); d.set("copy", N(P.dun.copy));
    Json c = Json::object(); for (const std::string& k : P.dun.cleared) c.set(k, N(1)); d.set("cleared", c);
    d.set("boss", Json::boolean(P.dun.boss)); d.set("t", N(P.dun.t)); o.set("dun", d);
  } else if (o.has("dun")) o.set("dun", Json());
  if (!P.dgDay.empty()) { Json d = Json::object(); d.set("day", T(P.dgDay)); Json n = Json::object(); for (const auto& kv : P.dgN) n.set(kv.first, N(kv.second)); d.set("n", n); o.set("dg", d); }
  else if (o.has("dg")) o.set("dg", Json());
  if (!P.pets.empty() || P.petsSeen || o.has("pets")) {
    Json L = Json::array();
    for (const PetRec& p : P.pets) {
      Json q = Json::object(); q.set("uid", T(p.uid)); q.set("sp", T(p.sp)); q.set("st", N(p.st));
      Json sk = Json::array(); for (const std::string& k : p.sk) sk.push(numOrText(k)); q.set("sk", sk);
      q.set("lv", N(p.lv)); q.set("xp", N(p.xp)); q.set("sat", N(p.sat)); q.set("joy", N(p.joy)); q.set("dead", Json::boolean(p.dead)); q.set("tal", N(p.tal));
      q.set("hp", N(p.hp)); q.set("mp", N(p.mp));
      if (p.deadAt) q.set("deadAt", N(p.deadAt));
      if (!p.name.empty()) q.set("name", T(p.name));
      if (!p.gift.empty()) { Json g = Json::object(); for (const auto& kv : p.gift) g.set(kv.first, N(kv.second)); q.set("gift", g); }
      L.push(q);
    }
    o.set("pets", L);
  }
  if (!P.petOn.empty()) o.set("petOn", T(P.petOn)); else if (o.has("petOn")) o.set("petOn", Json());
  if (o.has("petMode") && o["petMode"].isNull() && P.petMode == "attack") {} else if (P.petMode != "attack" || o.has("petMode")) o.set("petMode", T(P.petMode));
  if (o.has("petSlots") && o["petSlots"].isNull() && !P.petSlots) {} else if (P.petSlots || o.has("petSlots")) o.set("petSlots", N(P.petSlots));
  if (!P.petSel.empty()) o.set("petSel", T(P.petSel)); else if (o.has("petSel")) o.set("petSel", Json());
  P.raw = o;
  return o;
}

void World::save() { if (!saveFn || sceneId.empty()) return; saveFn(saveJson().dump()); }

// HTML load → fixSave: eksik alanları tamamla, eski kısayolları sıfırla, becerileri kurallarla denetle
bool World::loadSave(const Json& s) {
  if (!s.isObj() || !s["v"].isNum() || s["v"].num() != 1) return false;
  CharData c; c.raw = s;
  Json& R = c.raw;
  if (!R["quests"].truthy()) R.set("quests", Json::object());
  if (!R["done"].truthy()) R.set("done", Json::object());
  if (!R["qitems"].truthy()) R.set("qitems", Json::object());
  if (!R["flags"].truthy()) R.set("flags", Json::object());
  if (!R["gear"].truthy()) { Json g = Json::object(); g.set("weap", N(0)); g.set("body", N(0)); g.set("head", N(0)); R.set("gear", g); }
  c.name = s["name"].str(); c.cls = s["cls"].str(); c.race = s["race"].str(); c.sex = s["sex"].str();
  if (c.cls != "战士" && c.cls != "法师" && c.cls != "牧师") return false;   // HTML: CLS[s.cls] yoksa hata → kayıt yok
  c.lv = s["lv"].i(1); c.xp = (long long)s["xp"].num(); c.gold = (long long)s["gold"].num();
  c.hp = s["hp"].num(1e9); c.mp = s["mp"].num(1e9);
  c.face = s["face"].isStr() ? s["face"].str() : idOf(s["face"]);
  if (c.face.empty()) c.face = std::to_string((c.race == "精灵" ? 2 : 0) + (c.sex == "fema" ? 2 : 1)) + "001";
  if (s["eq"].truthy()) { for (const auto& kv : s["eq"].obj()) { const std::string id = idOf(kv.second); if (!id.empty()) c.eq[kv.first] = id; } }
  else {   // HTML: STARTER (boş) + çok eski kayıtta acemi başlığı ve ayakkabısı
    Json e = Json::object();
    if (R["gear"]["head"].truthy()) { auto it = NEWBIE.find(c.cls); if (it != NEWBIE.end()) { c.eq["head"] = it->second.first; c.eq["shoe"] = it->second.second; e.set("head", T(it->second.first)); e.set("shoe", T(it->second.second)); } }
    R.set("eq", e);
  }
  for (const Json& x : s["bag"].arr()) { const std::string id = idOf(x["id"]); if (!id.empty()) c.bag.push_back({id, x["n"].i(0)}); }
  for (const auto& kv : R["quests"].obj()) {
    if (!core::jsIntKey(kv.first) || !kv.second.isObj()) continue;
    QuestSt st; st.n = kv.second["n"].i(0); st.ready = kv.second["ready"].truthy();
    for (const auto& x : kv.second["c"].obj()) st.c[x.first] = x.second.i(0);
    c.quests[std::stoi(kv.first)] = st;
  }
  for (const auto& kv : R["done"].obj()) if (core::jsIntKey(kv.first) && kv.second.truthy()) c.done.insert(std::stoi(kv.first));
  c.scene = idOf(s["scene"]); c.x = s["x"].num(3); c.y = s["y"].num(13);
  if (!s["sv"].isNum() || s["sv"].num() != 2) { c.quick = QUICK0; R.set("sv", N(2)); }
  else { c.quick.clear(); for (const Json& x : s["quick"].arr()) c.quick.push_back(x.isStr() ? x.str() : std::string()); }
  c.adv = s["adv"].i(0);
  if (s["home"].isArr() && s["home"].size()) {
    c.hasHome = true; c.homeScene = idOf(s["home"][0]);
    if (s["home"].size() >= 3 && !s["home"][1].isNull()) { c.homeXY = true; c.homeX = s["home"][1].i(0); c.homeY = s["home"][2].i(0); }
  }
  for (const auto& kv : s["life"].obj()) c.life[kv.first] = kv.second.i(0);
  if (s["dun"].isObj()) {
    const Json& d = s["dun"]; c.dun.on = true; c.dun.id = d["id"].str(); c.dun.copy = d["copy"].i(0); c.dun.boss = d["boss"].truthy(); c.dun.t = d["t"].num(0);
    for (const auto& kv : d["cleared"].obj()) if (kv.second.truthy()) c.dun.cleared.insert(kv.first);
  }
  if (s["dg"].isObj()) { c.dgDay = s["dg"]["day"].str(); for (const auto& kv : s["dg"]["n"].obj()) c.dgN[kv.first] = kv.second.i(0); }
  for (const Json& q : s["pets"].arr()) {
    PetRec p; p.uid = idOf(q["uid"]); p.sp = q["sp"].str(); p.name = q["name"].str(); p.st = q["st"].i(0); p.lv = q["lv"].i(1);
    for (const Json& k : q["sk"].arr()) p.sk.push_back(idOf(k));
    p.xp = q["xp"].num(0); p.hp = q["hp"].num(0); p.mp = q["mp"].num(0); p.sat = q["sat"].num(100); p.joy = q["joy"].num(100);
    p.tal = q["tal"].num(1); p.deadAt = q["deadAt"].num(0); p.dead = q["dead"].truthy();
    for (const auto& kv : q["gift"].obj()) p.gift[kv.first] = kv.second.num(0);
    c.pets.push_back(p);
  }
  c.petOn = idOf(s["petOn"]); c.petSel = idOf(s["petSel"]);
  c.petMode = s["petMode"].isStr() && !s["petMode"].str().empty() ? s["petMode"].str() : "attack";
  c.petSlots = s["petSlots"].i(0);
  const bool noSk = !s["sk"].truthy();
  for (const auto& kv : s["sk"].obj()) c.sk[kv.first] = kv.second.i(0);
  c.sp = s["sp"].i(0);
  P = c; flags.clear();
  setChar(P.cls, P.race, P.sex); refreshLook();   // ekipmanın görünüşü
  if (noSk) { P.sk.clear(); if (!skills().empty()) P.sk[skills()[0].id] = 1; P.sp = 1; }
  fixSkills();
  return true;
}

// HTML fixSkills: şartı tutmayan (ön koşul, ağaç puanı, sınıf, dışlayan uzmanlık) ya da kademesi aşan becerinin puanı geri verilir
void World::fixSkills() {
  const std::vector<SkillDef>& L = skills(); if (L.empty()) return;
  for (int k = 0; k < 12; k++) {
    bool ch = false;
    for (const SkillDef& sk : L) {
      auto it = P.sk.find(sk.id); const int r = it == P.sk.end() ? 0 : it->second; if (!r) continue;
      const int over = std::max(0, r - (sk.mx ? sk.mx : 10)); if (over) { P.sk[sk.id] = r - over; P.sp += over; ch = true; }
      const std::string lk = skLock(sk);
      if (!lk.empty() && !(sk.id == L[0].id && lk == "pre")) { P.sp += P.sk[sk.id]; P.sk.erase(sk.id); ch = true; }
    }
    if (!ch) break;
  }
}

// HTML ui.js start(): kayıttaki harita (yoksa ırkın acemi kampı) ve yer, 40'a gelmiş karakterin görevi, ilk girişte ipuçları
void World::start() {
  startSet_ = true; startX_ = P.x; startY_ = P.y; startHp_ = P.hp; startMp_ = P.mp;
  loadScene(!P.scene.empty() ? P.scene : P.race == "精灵" ? "120205" : "120207");
  startSet_ = false;
  autoQuests();
  if (P.done.empty() && P.quests.empty()) {
    toast("Rehber seni bekliyor: başında ! olan kişiye dokun");
    note("Sol alttaki ejderhayı parmağınla kaydırarak yürü.", LOG_Q);
    note("Canavara dokunursan saldırırsın; sağ alttaki büyük düğme de en yakın canavara saldırır.", LOG_Q);
  }
}

}  // namespace engine
