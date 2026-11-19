// Eşyalar ve pencere yardımcıları: HTML game.js canEquip, equip, unequip, buyItem, sellItem, useItem (Gelişim Paketi), gmGear, look,
// skLock iletileri, skDesc, win.js skNextDiff, ui.js doAssign; sınıf/ırk adları (tr.js TR.cls, cls0, cls2, race).
#include <algorithm>
#include <cmath>
#include <set>

#include "engine/world.h"

namespace engine {

// yeni karakter ekipmansız doğar; acemi silahı, zırhı, başlığı ve ayakkabısı Gelişim Paketi'nden gelir (HTML STARTER_*, NEWBIE)
static std::string starterWeap(const std::string& c) { return c == "法师" ? "10006" : c == "牧师" ? "10882" : "10003"; }
static std::string starterBody(const std::string& c) { return c == "法师" ? "10007" : c == "牧师" ? "10883" : "10004"; }
static std::vector<std::string> newbie(const std::string& c) {
  if (c == "法师") return {"10005", "10058"};
  if (c == "牧师") return {"10881", "10884"};
  return {"10002", "10439"};
}
static const char* SLOTS[8] = {"weap", "head", "body", "belt", "shoe", "glove", "neck", "ring"};

std::string World::clsTr(const std::string& c) { return c == "法师" ? "Büyücü" : c == "牧师" ? "Kutsal Elçi" : c == "战士" ? "Savaşçı" : c; }
std::string World::raceTr(const std::string& r) { return r == "精灵" ? "Gece Elfi" : r == "人类" ? "İnsan" : r; }
std::string World::clsName() const {
  const std::string& c = P.cls;
  if (P.adv >= 2) return c == "法师" ? "Büyük Büyü Üstadı" : c == "牧师" ? "Seçilmiş" : "Kara Şövalye";
  if (P.adv >= 1) return clsTr(c);
  return c == "法师" ? "Çırak Büyücü" : c == "牧师" ? "Acemi Kutsal Elçi" : "Acemi Savaşçı";
}

std::string World::canEquip(const Item& it) const {
  if (!it.cls.empty() && it.cls != P.cls) return "Bu eşya " + clsTr(it.cls) + " içindir.";
  if (P.lv < it.lv) return std::to_string(it.lv) + ". seviye gerekir.";
  return "";
}
void World::equip(const std::string& id) {
  const Item* it = bal_.item(id); if (!it || it->slot.empty() || !countItem(id)) return;
  const std::string why = canEquip(*it); if (!why.empty()) { toast(why); return; }
  removeItem(id); const std::string old = eqOf(it->slot); P.eq[it->slot] = id; if (!old.empty()) addItem(old, 1, true);
  note(it->name + " kuşanıldı.", LOG_Q); clampVitals(); refreshLook();
}
void World::unequip(const std::string& slot) {
  const std::string id = eqOf(slot); if (id.empty()) return;
  P.eq.erase(slot); addItem(id, 1, true); note(itemName(id) + " çıkarıldı."); clampVitals(); refreshLook();
}
void World::buyItem(const std::string& id, int n) {
  const Item* it = bal_.item(id); if (!it) return;
  const long long cost = (long long)it->price * n; if (P.gold < cost) { toast("Yeterli altının yok."); return; }
  P.gold -= cost; addItem(id, n, true); note(it->name + " ×" + std::to_string(n) + " satın alındı (−" + std::to_string(cost) + " altın).", LOG_LOOT); save();
}
void World::sellItem(const std::string& id, int n) {
  const Item* it = bal_.item(id); n = std::min(n, countItem(id));
  if (!it || it->quest || n < 1 || !removeItem(id, n)) return;
  const long long g = (long long)(it->sell ? it->sell : std::max(1, it->price / 10)) * n; P.gold += g;
  note(it->name + (n > 1 ? " ×" + std::to_string(n) : std::string()) + " satıldı (+" + std::to_string(g) + " altın).", LOG_LOOT); save();
}
void World::openGrowthBox(const std::string& id) {
  removeItem(id);
  for (const std::string& g : newbie(P.cls)) { const Item* it = bal_.item(g); if (!it) continue; if (eqOf(it->slot).empty()) P.eq[it->slot] = g; else addItem(g, 1, true); }
  if (eqOf("body").empty()) P.eq["body"] = starterBody(P.cls); else addItem(starterBody(P.cls), 1, true);
  if (eqOf("weap").empty()) P.eq["weap"] = starterWeap(P.cls); else addItem(starterWeap(P.cls), 1, true);
  addItem("hp1", 10, true); addItem("mp1", 10, true);
  toast("Gelişim Paketi açıldı! Yeni ekipmanını kuşandın."); refreshLook();
}
void World::refreshLook() {
  Look l = player.look; l.cls = P.cls; l.race = P.race; l.sex = P.sex;
  auto G = [&](const char* sl) { const Item* it = bal_.item(eqOf(sl)); return it ? it->gfx : std::string(); };
  l.bodyG = G("body"); l.headG = G("head"); l.weapG = G("weap");
  setLook(l); save();
}
void World::gmGear() {
  for (const char* sl : SLOTS) {
    const Item* best = nullptr;
    for (const Item& it : bal_.items()) if (it.slot == sl && (it.cls.empty() || it.cls == P.cls) && it.lv <= P.lv && (!best || it.lv > best->lv)) best = &it;
    if (best) P.eq[sl] = best->id;
  }
  refreshLook(); const Stats s = stats(); player.hp = s.hp; player.mp = s.mp;
}
void World::assignQuick(const std::string& sl, int qi) {
  for (std::string& q : P.quick) if (q == sl) q.clear();
  if (qi >= 0 && qi < int(P.quick.size())) P.quick[size_t(qi)] = sl;
}

// ---------------- beceri penceresi yazıları ----------------
// JS: Number.isInteger(v) ? String(v) : String(+v.toFixed(1))
static std::string fmt1(double v) {
  if (std::floor(v) == v && std::fabs(v) < 1e15) return std::to_string((long long)v);
  const double a = std::fabs(v); long long n = (long long)std::floor(a * 10 + 0.5);   // toFixed: eşitlikte büyüğe
  std::string s = (v < 0 && n ? "-" : "") + std::to_string(n / 10);
  if (n % 10) s += "." + std::to_string(n % 10);
  return s;
}
std::string World::skLockMsg(const SkillDef& sk) const {
  const std::string L = skLock(sk); if (L.empty()) return "";
  const core::Json& d = *sk.d;
  if (L == "adv") { const int c = d["root"]["cls"].i(); return (c == 130004 || c == 130005 || c == 130011) ? "Sınıf yükseltme görevi gerekir (40. seviye)." : "İkinci sınıf yükseltmesi gerekir (80. seviye)."; }
  if (L == "pts") {
    const core::Json& rt = d["root"]; const SkillTree* T = bal_.skills.tree(rt["tree"].i());
    return (T ? T->name : std::string()) + " ağacına " + std::to_string(rt["pts"].i()) + " puan gerekir (şu an " + std::to_string(treePts(rt["tree"].i())) + ").";
  }
  if (L == "excl") { const SkillDef* o = bal_.skills.bySn(d["root"]["excl"].i()); return (o ? o->name : std::string()) + " seçildi; bu uzmanlık alınamaz."; }
  const SkillDef* pk = bal_.skills.bySn(d["pre"][0].i());
  return "Önce " + (pk ? pk->name : std::string()) + " " + std::to_string(d["pre"][1].i()) + ". kademe.";
}
std::string World::skDesc(const SkillDef& sk, int r) const {
  if (!sk.d) return "";
  const std::string t = (*sk.d)["tr"][1].str(); const int rr = std::max(1, r ? r : skRank(sk));
  std::string mpv;
  if (sk.mpPct) { const Stats s = stats(); SkCtx c{const_cast<World&>(*this), sk, s, P.lv, nullptr, rr}; mpv = std::to_string((long long)jsRound(sk.mpPct(c) * 100)) + "%"; }
  else mpv = fmt1(sk.mp);
  std::string out; size_t i = 0;
  while (i < t.size()) {
    if (t[i] == '{') {
      size_t j = i + 1; while (j < t.size() && (std::isalnum((unsigned char)t[j]) || t[j] == '_')) j++;
      if (j < t.size() && t[j] == '}' && j > i + 1) {
        const std::string k = t.substr(i + 1, j - i - 1);
        out += k == "cd" ? fmt1(sk.cd) : k == "mp" ? mpv : fmt1(skC(sk, k, rr)); i = j + 1; continue;
      }
    }
    out += t[i++];
  }
  return out;
}
std::string World::skNextDiff(const SkillDef& sk, int r) const {
  if (!sk.d) return "";
  const std::string t = (*sk.d)["tr"][1].str(); std::vector<std::string> keys; std::set<std::string> seen;
  for (size_t i = 0; i < t.size(); i++) if (t[i] == '{') {
    size_t j = i + 1; while (j < t.size() && (std::isalnum((unsigned char)t[j]) || t[j] == '_')) j++;
    if (j < t.size() && t[j] == '}' && j > i + 1) { const std::string k = t.substr(i + 1, j - i - 1); if ((*sk.d)["c"][k].truthy() && seen.insert(k).second) keys.push_back(k); }
  }
  std::string out;
  for (const std::string& k : keys) { const double a = skC(sk, k, r), b = skC(sk, k, r + 1); if (a != b) out += (out.empty() ? "" : ", ") + fmt1(a) + "→" + fmt1(b); }
  return out;
}

}  // namespace engine
