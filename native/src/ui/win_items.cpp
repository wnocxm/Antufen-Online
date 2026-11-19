// Pencereler 2 (HTML win.js drawBag2, drawRole2, drawSkill2, drawShop2, drawModal2 adet kutusu; Android NEW_FORM_BAG_2, PLAYER,
// SKILLTREE, SHOP + SHOPINFO, SELNUM): solda kırmızı sekme sütunu (126), ortada parşömen (227), sağda yalnız bir şey seçiliyken açılan
// işlem paneli (135). Ekranlar 320 birim yüksekliğinde, ekrana ölçeklenir.
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "win.h"

namespace ui {

using engine::Item;
using engine::SkillDef;
using engine::World;

static const char* R3 = "AnbufenUI_3_Resource";
static const std::vector<int> B2TABS = {50003, 50004, 50005, 50006, 50049}, B2ACT = {50035, 50036, 50037, 50038, 50039, 50040, 50041};
static const std::vector<int> R2TABS = {50084, 50085, 50913, 50087, 50912};
static const std::vector<std::pair<int, const char*>> R2SLOT = {{50093, "head"}, {50094, "weap"}, {50095, "body"}, {50096, "neck"}, {50097, "glove"}, {50098, "ring"}, {50099, "shoe"}, {50100, "belt"}};   // JS nesne sırası (numara artan)
static const std::vector<int> S2TABS = {50396, 50397, 50398, 50399, 50400, 50872}, S2SLOT = {50402, 50403, 50404, 50405, 50406, 50407};
static const std::vector<int> H2TABS = {50899, 50900, 50901, 50902, 50903}, H2ROWS = {50334, 50335, 50336, 50337, 50338};
static const std::vector<std::pair<const char*, const char*>> SLOTN = {{"weap", "Silah"}, {"head", "Başlık"}, {"body", "Zırh"}, {"belt", "Kemer"}, {"shoe", "Ayakkabı"}, {"glove", "Eldiven"}, {"neck", "Kolye"}, {"ring", "Yüzük"}};
static std::string slotName(const std::string& sl) { for (const auto& s : SLOTN) if (sl == s.first) return engine::tx(s.second); return sl; }   // HTML: SLOTS yüklemede çevrilir
static std::string statName(const std::string& k) {
  static const std::map<std::string, std::string> N = {{"atk", "Saldırı"}, {"def", "Savunma"}, {"hp", "Can"}, {"mp", "Mana"}, {"crit", "Kritik %"}, {"dodge", "Kaçınma %"}, {"hpreg", "Can yenileme"}, {"mpreg", "Mana yenileme"}, {"res", "Büyü direnci"}};
  auto it = N.find(k); return it == N.end() ? k : engine::tx(it->second);   // HTML: STATN yüklemede çevrilir
}
// görev eşyalarının simgeleri (HTML Q_ICONS)
static int questIcon(const std::string& n) {
  static const std::map<std::string, int> Q = {{"Tavuk Kanı", 1125}, {"Domuz Bacak Kemiği", 1196}, {"Enfiye Kutusu", 1056}, {"Orman Kurdu Eti", 1225}, {"Yabani Sebze", 1229}, {"Peri Tozu", 1171}};
  auto it = Q.find(n); return it == Q.end() ? 1125 : it->second;
}
// JS String(sayı): en kısa geri dönen yazım
static std::string js(double v) {
  if (std::floor(v) == v && std::fabs(v) < 1e15) return std::to_string((long long)v);
  char b[40]; for (int p = 1; p <= 17; p++) { std::snprintf(b, sizeof b, "%.*g", p, v); if (std::strtod(b, nullptr) == v) break; }
  return b;
}
static std::string I(long long v) { return std::to_string(v); }

// ---------------- ortak parçalar (HTML nTabs, nActions, drawIcon, itemLines) ----------------
// sol sütun: arka plan + sekmeler (seçili olan sarı); bazı ekranlarda sekmenin kendi yazı katmanı yok: yazı aynı yere elle çizilir
void Win::tabs(engine::Canvas& c, const Xf& xf, const std::string& f, int bgId, const std::vector<int>& ids, const std::vector<std::string>& labels, int active) {
  nDraw(c, xf, f, bgId, false);
  for (size_t i = 0; i < ids.size() && i < labels.size(); i++) {
    const core::Json* ctl = F_.ctrl(f, ids[i]); if (!ctl) continue;
    const std::string id = I(ids[i]); const bool sel = int(i) == active || on(id); const auto r = rect(f, ids[i]);
    F_.drawCtrl(c, xf, *ctl, sel ? 1 : 0, 0, 0, &labels[i]);
    bool hasText = false; for (const core::Json& L : (*ctl)["s"][0]["L"].arr()) if (L[0].i() == 3) hasText = true;
    if (!hasText) F_.btnText(c, xf, labels[i], r[0], r[1], 108, 31, 0, true, 13);
    hit(xf, id, r[0], r[1], r[2], r[3]);
  }
  hit(xf, "frame", 0, 0, 126, 320);
}
// sağ işlem paneli: [etiket, anahtar] listesi
void Win::actions(engine::Canvas& c, const Xf& xf, const std::string& f, int bgId, const std::vector<int>& ids, const std::vector<std::pair<std::string, std::string>>& acts) {
  nDraw(c, xf, f, bgId, false); hit(xf, "frame", 353, 0, 135, 320);
  const std::string empty;
  for (size_t i = 0; i < acts.size() && i < ids.size(); i++) {
    const auto r = rect(f, ids[i]); nDraw(c, xf, f, ids[i], on(acts[i].second), &empty);
    F_.btnText(c, xf, acts[i].first, r[0], r[1], r[2], r[3], 0xf4ead0, false, 12); hit(xf, acts[i].second, r[0], r[1], r[2], r[3]);
  }
}
// simge: orijinal pikselleriyle net (yumuşatmasız)
void Win::icon(engine::Canvas& c, const Xf& xf, const std::string& ik, int ic, float x, float y, float s, float alpha) {
  if (const core::Image* im = F_.image("ui/icon_res_" + (ik.empty() ? std::string("item") : ik) + "_" + I(ic) + ".png"))
    c.drawImage(*im, 0, 0, float(im->w), float(im->h), xf.X(x), xf.Y(y), s * xf.k, s * xf.k, alpha, false);
}
std::vector<Win::Line> Win::itemLines(World& w, const Item& it) {
  std::vector<Line> L = {{it.name, 0x7a1c08, 12}};
  if (!it.slot.empty()) {
    L.push_back({slotName(it.slot) + " · " + (it.cls.empty() ? engine::tx("Tüm sınıflar") : World::clsTr(it.cls)) + " · " + engine::tx("Sv") + " " + I(it.lv), w.P.lv < it.lv ? 0xc02010u : 0x3a2a14u, 10});
    std::string st; for (const std::string& k : it.stOrder) st += (st.empty() ? "" : "  ") + statName(k) + " +" + js(it.st.at(k));
    L.push_back({st, 0x1c5a12, 10});
  } else if (!it.desc.empty()) L.push_back({it.desc, 0x3a2a14, 10});
  L.push_back({engine::tx("Satış") + ": " + I(it.sell ? it.sell : 1) + " " + engine::tx("altın"), 0x6a4a14, 10});   // HTML: parçalar ayrı çevrilir
  return L;
}
bool Win::doubleTap(const std::string& id) {   // aynı şeye 450 ms içinde ikinci dokunuş
  const bool d = lastTapId_ == id && clock_ - lastTapT_ < 0.45;
  if (d) lastTapId_.clear(); else { lastTapId_ = id; lastTapT_ = clock_; }
  return d;
}

// ---------------- adet kutusu (NEW_FORM_SELNUM) ----------------
void Win::askNum(const std::string& title, int max, std::function<void(int)> onOk, int unit) {
  modal_ = Modal(); modal_.on = true; modal_.num = true; modal_.title = title; modal_.max = std::max(1, max); modal_.n = 1; modal_.ok = std::move(onOk); modal_.unit = unit; snd("menu_appear", 0.4);
}
void Win::drawNum(engine::Canvas& c, float vw, float VH) {
  const float k = 1.3f; const Xf xf = begin(k, std::round((vw - 227 * k) / 2), std::round((VH - 129 * k) / 2)); const std::string f = "n_selnum";
  nDraw(c, xf, f, 50253, false);
  F_.text(c, xf, modal_.title, 113, 13, 0x7a1c08, 11, CENTER, 120);
  { const auto r = rect(f, 50259); nDraw(c, xf, f, 50259, false);
    if (const core::Image* im = F_.img(7036, R3)) c.drawImage(*im, 0, 0, 53, 26, xf.X(r[0] + 54), xf.Y(r[1]), 54 * k, 26 * k, 1, true);
    F_.text(c, xf, I(modal_.n), 112, 43, 0xffffff, 14, CENTER); hit(xf, "m50761", r[0], r[1], r[2], r[3], &modal_.hits); }
  for (const auto& b : std::vector<std::pair<int, const char*>>{{50254, "m50758"}, {50255, "m50759"}}) { const auto r = rect(f, b.first); nDraw(c, xf, f, b.first, on(b.second)); hit(xf, b.second, r[0] - 3, r[1] - 3, r[2] + 6, r[3] + 6, &modal_.hits); }
  if (modal_.unit) F_.text(c, xf, engine::tx("Toplam") + ": " + I((long long)modal_.n * modal_.unit) + " " + engine::tx("altın") + " · " + engine::tx("En fazla") + ": " + I(modal_.max), 113, 68, 0x2a1a0a, 9.5f, CENTER, 200);
  for (const auto& b : std::vector<std::pair<int, std::pair<const char*, const char*>>>{{50263, {"Tamam", "m52791"}}, {50264, {"İptal", "m52792"}}}) {
    const auto r = rect(f, b.first);
    if (const core::Image* im = F_.img(7017, R3)) c.drawImage(*im, 0, 0, 84, 24, xf.X(r[0]), xf.Y(r[1]), 84 * k, 24 * k, 1, true);
    F_.label(c, xf, b.second.first, r[0], r[1], r[2], r[3], 0xf4ead0, CENTER, 11); hit(xf, b.second.second, r[0], r[1], r[2], r[3], &modal_.hits);
  }
}
// bilgisayar: adet kutusu açıkken rakamlar sayıyı yazar, Enter onaylar, Esc kapatır (oyun kısayollarına gitmez)
bool Win::key(const std::string& k) {
  if (!modal_.on) return false;
  Modal& m = modal_;
  if (m.num) {
    auto setTyped = [&] { const int v = m.typed.empty() ? 1 : std::atoi(m.typed.c_str()); m.n = std::max(1, std::min(m.max, v)); };
    if (k.size() == 1 && k[0] >= '0' && k[0] <= '9') { m.typed += k; while (!m.typed.empty() && m.typed[0] == '0') m.typed.erase(0, 1); if (m.typed.size() > 4) m.typed.resize(4); setTyped(); return true; }
    if (k == "Backspace") { if (m.typed.empty()) m.typed = I(m.n); m.typed.pop_back(); setTyped(); return true; }
    if (k == "Enter") { auto ok = m.ok; const int n = m.n; modal_ = Modal(); wantText = false; if (ok) ok(n); return true; }
    if (k == "ArrowUp" || k == "+") { m.n = std::min(m.max, m.n + 1); m.typed.clear(); return true; }
    if (k == "ArrowDown" || k == "-") { m.n = std::max(1, m.n - 1); m.typed.clear(); return true; }
  }
  if (k == "Escape") { modal_ = Modal(); wantText = false; return true; }
  if (!m.num && k == "Enter") { auto yes = m.yes; modal_ = Modal(); if (yes) yes(); return true; }
  return true;
}
void Win::buyAsk(World& w, const std::string& id) {
  const Item* it = w.balance().item(id); if (!it || !it->price) return;
  const long long can = w.P.gold / it->price;
  if (can < 1) { w.toast("Yeterli altının yok."); return; }
  if (!it->slot.empty()) { ask(it->name + ": " + I(it->price) + " altın. Satın alınsın mı?", [&w, id] { w.cmd({"buy", {id, "1"}}); }); return; }   // ekipman tek tek
  askNum(it->name, int(std::min<long long>(999, can)), [&w, id](int n) { w.cmd({"buy", {id, std::to_string(n)}}); }, it->price);   // yığılabilen her eşya: adet sorulur
}
void Win::sellAsk(World& w, const std::string& id) {   // birden çok varsa satarken de adet sorulur
  const Item* it = w.balance().item(id); const int n = w.countItem(id); if (!it) return;
  if (n <= 1 || !it->slot.empty()) { w.cmd({"sell", {id, "1"}}); return; }
  askNum(it->name, n, [&w, id](int k) { w.cmd({"sell", {id, std::to_string(k)}}); }, it->sell ? it->sell : std::max(1, it->price / 10));
}

// ---------------- çanta (NEW_FORM_BAG_2): 5 sekme, 20 yuva, sayfa okları, altta bilgi kutusu ya da doluluk + altın ----------------
std::vector<std::pair<std::string, int>> Win::bagItems(World& w) {
  std::vector<std::pair<std::string, int>> L;
  if (B_.cat == 3) { for (const engine::Quest& q : w.quests().all()) { auto st = w.P.quests.find(q.id); if (st != w.P.quests.end() && !q.tr.item.empty() && st->second.n) L.push_back({"q:" + q.tr.item, st->second.n}); } return L; }
  if (B_.cat == 4) return L;
  for (const auto& b : w.P.bag) {
    const Item* it = w.balance().item(b.first); if (!it) continue;
    const int cat = !it->slot.empty() ? 0 : (it->use || it->growth || it->pet) ? 1 : 2;
    if (cat == B_.cat) L.push_back(b);
  }
  return L;
}
void Win::drawBag(engine::Canvas& c, World& w, float VH) {
  const Xf xf = begin(VH / 320, safeL, 0); nk_ = xf.k; const std::string f = "n_bag_2";
  const auto items = bagItems(w); const int per = 20, pages = std::max(1, int((items.size() + per - 1) / per));
  if (B_.page >= pages) B_.page = pages - 1;
  const Item* selIt = !B_.sel.empty() && w.countItem(B_.sel) ? w.balance().item(B_.sel) : nullptr; if (!selIt) B_.sel.clear();
  nDraw(c, xf, f, 50042, false); hit(xf, "frame", 126, 0, 227, 320);
  tabs(c, xf, f, 50000, B2TABS, {"Ekipman", "Tüketim", "Genel", "Görev", "Binek"}, B_.cat);
  for (int i = 0; i < 20; i++) {
    const int id = 50007 + i; const size_t k = size_t(B_.page * per + i); const bool has = k < items.size();
    const bool quest = has && items[k].first.rfind("q:", 0) == 0;
    const auto r = rect(f, id); nDraw(c, xf, f, id, has && !quest && items[k].first == B_.sel); hit(xf, I(id), r[0] + 3, r[1] + 3, 40, 40);
    if (!has) continue;
    if (quest) { if (const core::Image* im = F_.image("ui/icon_res_item_" + I(questIcon(items[k].first.substr(2))) + ".png")) c.drawImage(*im, 0, 0, float(im->w), float(im->h), xf.X(r[0] + 7), xf.Y(r[1] + 7), 32 * xf.k, 32 * xf.k, 1, true); }
    else { const Item* it = w.balance().item(items[k].first); icon(c, xf, it->ik, it->icon, r[0] + 7, r[1] + 7, 32, !it->slot.empty() && !w.canEquip(*it).empty() ? 0.45f : 1); }
    if (items[k].second > 1) F_.label(c, xf, I(items[k].second), r[0] + 6, r[1] + 5, 30, 12, 0xffffff, LEFT, 10);
  }
  for (const int id : {50027, 50028}) { const bool off = id == 50027 ? B_.page == 0 : B_.page >= pages - 1; const auto r = rect(f, id); nDraw(c, xf, f, id, off); hit(xf, I(id), r[0] - 8, r[1] - 4, r[2] + 16, r[3] + 8); }   // gri: gidilecek sayfa yok
  F_.text(c, xf, I(B_.page + 1) + "/" + I(pages), 239, 219, 0x3a2a14, 11, CENTER);
  if (selIt) {   // seçili eşyanın bilgisi: alt kutu (koyu deri zemin: açık renkler)
    nDraw(c, xf, f, 50029, false);
    const auto L = itemLines(w, *selIt);
    for (size_t i = 0; i < L.size(); i++) {
      uint32_t col = L[i].c;
      switch (col) { case 0x7a1c08: col = 0xffd870; break; case 0x3a2a14: col = 0xf0e4c8; break; case 0xc02010: col = 0xff8a70; break; case 0x1c5a12: col = 0xa8f090; break; case 0x6a4a14: col = 0xe0c080; break; default: break; }
      F_.text(c, xf, L[i].t, 140, 250 + float(i) * 15, col, L[i].s, LEFT, 198);
    }
  } else {
    F_.text(c, xf, I((long long)w.P.bag.size()) + "/100", 170, 298, 0xe8dcc0, 11, CENTER); nDraw(c, xf, f, 50045, false); F_.text(c, xf, I(w.P.gold), 228, 298, 0xffe070, 11, LEFT); nDraw(c, xf, f, 50043, false);
  }
  if (selIt) {
    std::vector<std::pair<std::string, std::string>> A = {{!selIt->slot.empty() ? "Giy" : selIt->growth ? "Aç" : selIt->use ? "Kullan" : "—", "use"}};
    if (selIt->use) A.push_back({"Kısayol", "quick"});
    if (!shop_.empty()) A.push_back({"Sat (+" + I(selIt->sell ? selIt->sell : 1) + ")", "sell"});
    A.push_back({"Yok Et", "del"});
    actions(c, xf, f, 50032, B2ACT, A);
  }
  { const auto r = rect(f, 50030); nDraw(c, xf, f, 50030, on("50030")); hit(xf, "50030", r[0] - 4, r[1], r[2] + 4, r[3]); }
}
void Win::tapBag(World& w, const std::string& id) {
  const auto items = bagItems(w); const int per = 20, n = std::atoi(id.c_str());
  if (id == "50030") { close(); open(w, "hub"); return; }
  for (size_t i = 0; i < B2TABS.size(); i++) if (n == B2TABS[i]) { B_.cat = int(i); B_.page = 0; B_.sel.clear(); w.sfx("skill_pageflip"); return; }
  if (id == "50027") { B_.page = std::max(0, B_.page - 1); return; }
  if (id == "50028") { B_.page = std::min(std::max(0, int((items.size() + per - 1) / per) - 1), B_.page + 1); return; }
  if (n >= 50007 && n < 50027) {
    const size_t k = size_t(B_.page * per + n - 50007); w.sfx("menusel", 0.6);
    if (k >= items.size() || items[k].first.rfind("q:", 0) == 0) { B_.sel.clear(); return; }
    const std::string e = items[k].first;
    if (B_.sel == e && doubleTap(e)) { w.cmd({"item", {e}}); return; }   // çift dokunuş: kullan / giy
    B_.sel = e; lastTapId_ = e; lastTapT_ = clock_; return;
  }
  if (B_.sel.empty()) return;
  const Item* it = w.balance().item(B_.sel); if (!it) return;
  if (id == "use") { w.cmd({"item", {B_.sel}}); return; }
  if (id == "sell" && !shop_.empty()) { sellAsk(w, B_.sel); return; }
  if (id == "quick") { if (it->use) { assignReq = "i:" + B_.sel; assignName = it->name; close(); } return; }
  if (id == "del") { const std::string sid = B_.sel, nm = it->name; ask(nm + ": yok edilsin mi?", [&w, this, sid] { w.cmd({"drop", {sid}}); B_.sel.clear(); }); }
}

// ---------------- karakter (NEW_FORM_PLAYER): Özellik ve Ekipman sayfaları ----------------
void Win::drawRole(engine::Canvas& c, World& w, float VH) {
  const Xf xf = begin(VH / 320, safeL, 0); nk_ = xf.k; const std::string f = "n_player"; auto& P = w.P; const engine::Player& p = w.player; const engine::Stats s = w.stats();
  const std::string selId = R_.sel.empty() ? std::string() : w.eqOf(R_.sel); const Item* selIt = selId.empty() ? nullptr : w.balance().item(selId);
  nDraw(c, xf, f, R_.page == 1 ? 50092 : 50083, false);
  hit(xf, "frame", 126, 0, 227, 320);
  tabs(c, xf, f, 50082, R2TABS, {"Özellik", "Ekipman", "Potansiyel", "Başarım", "Diğer"}, R_.page);
  if (R_.page == 0) {
    const auto r = rect(f, 50122); nDraw(c, xf, f, 50122, false);
    if (const core::Image* im = F_.image("ui/Portrait_" + P.face + ".png")) c.drawImage(*im, 0, 0, float(im->w), float(im->h), xf.X(r[0] + 5), xf.Y(r[1] + 5), 59 * xf.k, 59 * xf.k, 1, true);
    F_.text(c, xf, P.name, 280, 22, 0x2a1a0a, 13, CENTER, 118); F_.text(c, xf, World::raceTr(P.race) + " · " + w.clsName(), 280, 42, 0x5a4020, 11, CENTER, 118);
    F_.text(c, xf, "Seviye " + I(P.lv), 280, 62, 0x7a1c08, 12, CENTER, 118);
    const bool melee = w.balance().cls(P.cls).melee;
    const std::vector<std::pair<std::string, std::string>> rows = {{"Tecrübe", I(P.xp) + "/" + I(w.balance().xpNeed(P.lv))}, {"Can", js(std::ceil(p.hp)) + "/" + js(s.hp)}, {"Mana", js(std::floor(p.mp)) + "/" + js(s.mp)},
      {melee ? "Fiz. Saldırı" : "Büyü Saldırı", js(s.atk)}, {"Savunma", js(s.def)}, {"Kritik", js(8 + s.crit) + "%"}, {"Kaçınma", js(s.dodge) + "%"}, {"Büyü direnci", js(s.res)},
      {"Can yenileme", js(s.hpreg)}, {"Mana yenileme", js(s.mpreg)}, {"Altın", I(P.gold)}};
    for (size_t i = 0; i < rows.size(); i++) { const float y = 96 + float(i) * 19.5f; F_.text(c, xf, engine::tx(rows[i].first) + ":", 142, y, 0xa83018, 12, LEFT); F_.text(c, xf, rows[i].second, 240, y, 0x2a1a0a, 12, LEFT, 104); }
  } else if (R_.page == 1) {
    for (const auto& e : R2SLOT) {
      const auto r = rect(f, e.first); nDraw(c, xf, f, e.first, R_.sel == e.second); hit(xf, I(e.first), r[0] + 3, r[1] + 3, 40, 40);
      if (const Item* it = w.balance().item(w.eqOf(e.second))) icon(c, xf, it->ik, it->icon, r[0] + 8, r[1] + 8, 32);
    }
    const std::string sn = R_.sel.empty() ? std::string() : slotName(R_.sel);
    if (selIt) { auto L = itemLines(w, *selIt); for (size_t i = 0; i < L.size() && i < 4; i++) F_.text(c, xf, i == 0 ? sn + ": " + L[i].t : L[i].t, 142, 256 + float(i) * 14.5f, L[i].c, L[i].s, LEFT, 196); }
    else F_.text(c, xf, !R_.sel.empty() ? sn + ": Boş yuva" : "Bir ekipman yuvasına dokun.", 142, 272, 0x5a4020, 11, LEFT, 196);
  } else F_.text(c, xf, "Yakında", 239, 150, 0x5a4020, 13, CENTER);
  if (R_.page == 1 && !R_.sel.empty()) actions(c, xf, f, 50105, {50106, 50107}, selIt ? std::vector<std::pair<std::string, std::string>>{{"Çıkar", "uneq"}, {"Değiştir", "swap"}} : std::vector<std::pair<std::string, std::string>>{{"Değiştir", "swap"}});
  { const auto r = rect(f, 50104); nDraw(c, xf, f, 50104, on("50104")); hit(xf, "50104", r[0] - 4, r[1], r[2] + 4, r[3]); }
}
void Win::tapRole(World& w, const std::string& id) {
  const int n = std::atoi(id.c_str());
  if (id == "50104") { close(); open(w, "hub"); return; }
  for (size_t i = 0; i < R2TABS.size(); i++) if (n == R2TABS[i]) { R_.page = int(i); R_.sel.clear(); w.sfx("skill_pageflip"); return; }
  for (const auto& e : R2SLOT) if (n == e.first) { R_.sel = e.second; w.sfx("menusel", 0.6); return; }
  if (id == "uneq" && !R_.sel.empty() && !w.eqOf(R_.sel).empty()) { w.cmd({"unequip", {R_.sel}}); return; }
  if (id == "swap") { close(); openBag(w, 0, ""); }
}

// ---------------- beceri ağacı (NEW_FORM_SKILLTREE): 6 sekme (acemi, sınıf, iki uzmanlık, ırk, yaşam), 6 yuva + ön koşul çizgileri ----------------
void Win::drawSkill(engine::Canvas& c, World& w, float VH) {
  const Xf xf = begin(VH / 320, safeL, 0); nk_ = xf.k; const std::string f = "n_skilltree"; auto& P = w.P;
  const auto& T = w.balance().skills.trees(P.cls); const core::Json& J = w.balance().skills.json();
  const int nT = int(T.size()) + 2; if (S_.tree >= nT) S_.tree = 0;
  const bool race = S_.tree == int(T.size()), life = S_.tree == int(T.size()) + 1;
  skCells_.clear();
  nDraw(c, xf, f, 50408, false); hit(xf, "frame", 126, 0, 227, 320);
  std::vector<std::string> labels; for (const auto& t : T) labels.push_back(t.name); const std::string LC = engine::lang().code(); labels.push_back(J["race"][P.race][LC].str()); labels.push_back(J["life"][LC].str());
  tabs(c, xf, f, 50394, S2TABS, labels, S_.tree);
  std::vector<SkCell> cells;
  if (race) { const auto& L = w.balance().skills.race(P.race); for (size_t i = 0; i < L.size(); i++) cells.push_back({&L[i], nullptr, int(i)}); }
  else if (life) { const auto& L = J["life"]["jobs"].arr(); for (size_t i = 0; i < L.size(); i++) cells.push_back({nullptr, &L[i], int(i)}); }
  else { const auto& L = T[size_t(S_.tree)].cells; for (size_t i = 0; i < L.size(); i++) cells.push_back({L[i].first, nullptr, int(i)}); }
  auto R = [&](int i) { return rect(f, S2SLOT[size_t(i)]); };
  // bağlantı çizgileri (APK'daki sabit desen: 1→3, 1→4, 3→5, 4→6; turuncu, koyu kenarlı); köşeler sivri (miter), uçlar düz
  if (!race && !life) for (const auto& pr : std::vector<std::pair<int, int>>{{0, 2}, {0, 3}, {2, 4}, {3, 5}}) {
    const auto a = R(pr.first), b = R(pr.second); const float ax = a[0] + 23, ay = a[1] + 46, by = b[1] + 23;
    for (const auto& lw : std::vector<std::pair<float, uint32_t>>{{8, 0x7a4a08}, {5, 0xffa400}}) {
      const float h = lw.first / 2;
      if (std::fabs(ax - (b[0] + 23)) < 3) c.fillRect(xf.X(ax - h), xf.Y(ay), lw.first * xf.k, (b[1] - ay) * xf.k, lw.second);
      else {
        const float ex = b[0] < a[0] ? b[0] + 46 : b[0];
        c.fillRect(xf.X(ax - h), xf.Y(ay), lw.first * xf.k, (by + h - ay) * xf.k, lw.second);
        c.fillRect(xf.X(std::min(ax, ex)), xf.Y(by - h), std::fabs(ex - ax) * xf.k, lw.first * xf.k, lw.second);
      }
    }
  }
  for (const SkCell& ce : cells) {
    if (ce.i >= int(S2SLOT.size())) continue;
    const auto r0 = R(ce.i); const float x = r0[0], y = r0[1]; const std::string key = "sk:" + I(ce.i); skCells_[key] = ce;
    nDraw(c, xf, f, S2SLOT[size_t(ce.i)], S_.sel == key);
    std::string ik; int ic = 0, rank = 0;
    if (ce.job) { const int t = P.life.count((*ce.job)["cn"].str()) ? P.life.at((*ce.job)["cn"].str()) : 0; const core::Json& tier = (*ce.job)["tiers"][size_t(std::max(0, t - 1))]; ic = tier["icon"].i(); ik = tier["ik"].isStr() ? tier["ik"].str() : ""; rank = t; }
    else { ic = (*ce.sk->d)["icon"].i(); ik = (*ce.sk->d)["ik"].isStr() ? (*ce.sk->d)["ik"].str() : ""; rank = w.skRank(*ce.sk); }
    const bool lock = !rank;
    icon(c, xf, ik.empty() ? "skill" : ik, ic, x + 7, y + 7, 32);
    if (lock) c.fillRect(xf.X(x + 7), xf.Y(y + 7), 32 * xf.k, 32 * xf.k, 0x000000, 0.45f);
    TextStyle st; st.base = TOP;
    if (lock) { st.color = 0xff5a5a; F_.fonts().draw(c, "Bb", 8.5f * xf.k, engine::T("Öğrenil-", "Not"), xf.X(x + 6), xf.Y(y + 9), st); F_.fonts().draw(c, "Bb", 8.5f * xf.k, engine::T("medi", "Learned"), xf.X(x + 6), xf.Y(y + 19), st); }
    else { st.color = 0x000000; F_.fonts().draw(c, "Bb", 8.5f * xf.k, engine::T("Sv", "Lv") + I(rank), xf.X(x + 9), xf.Y(y + 9), st); st.color = 0xffffff; F_.fonts().draw(c, "Bb", 8.5f * xf.k, engine::T("Sv", "Lv") + I(rank), xf.X(x + 8), xf.Y(y + 8), st); }
    hit(xf, key, x, y, 46, 46);
  }
  // ağacın kök şartı tutmuyorsa (sınıf yükseltmesi, önceki ağaca puan, seçilmiş öbür uzmanlık) yazılır
  if (!cells.empty() && cells[0].sk && !race) { const std::string L = w.skLock(*cells[0].sk); if (!L.empty() && L != "pre") F_.text(c, xf, w.skLockMsg(*cells[0].sk), 240, 266, 0xa02010, 9, CENTER, 200); }
  if (life) F_.text(c, xf, engine::T("Meslekler eğitmenlerden öğrenilir.", "Professions are learned from trainers."), 240, 266, 0x5a4020, 9, CENTER, 200);
  F_.text(c, xf, engine::tx("Beceri puanı") + ": " + I(P.sp), 205, 299, P.sp > 0 ? 0xffe070 : 0xe8dcc0, 12, CENTER);
  { const std::string t = engine::T("Puanları Sıfırla", "Reset Points"); const auto r = rect(f, 50430); nDraw(c, xf, f, 50430, on("50430"), &t); hit(xf, "50430", r[0], r[1], r[2], r[3]); }
  auto sel = skCells_.find(S_.sel);
  if (sel != skCells_.end()) {
    const SkCell& ce = sel->second; std::vector<Line> L;
    if (ce.job) {
      const core::Json& job = *ce.job; const int t = P.life.count(job["cn"].str()) ? P.life.at(job["cn"].str()) : 0; const core::Json& tier = job["tiers"][size_t(std::max(0, t - 1))];
      nDraw(c, xf, f, 50401, false); hit(xf, "frame", 353, 0, 135, 320);
      const std::string LC = engine::lang().code(); L.push_back({job[LC].str(), 0x7a1c08, 11}); L.push_back({t ? tier[LC][0].str() : engine::T("Öğrenilmedi", "Not learned"), 0x5a4020, 9.5f});
      for (const auto& l : F_.wrap(tier[LC][1].str(), 92, 9.5f)) L.push_back({l, 0x2a1a0a, 9.5f});
      if (t < 5) { L.push_back({engine::T("Sonraki kademe:", "Next tier:"), 0x5a4020, 9.5f}); for (const auto& l : F_.wrap(job["tiers"][size_t(t)][LC][1].str(), 92, 9.5f)) L.push_back({l, 0x5a4020, 9.5f}); }
      for (size_t i = 0; i < L.size() && i < 20; i++) F_.text(c, xf, L[i].t, 362, 30 + float(i) * 12.5f, L[i].c, L[i].s, LEFT, 94);
    } else {
      const SkillDef& sk = *ce.sk; const int r = w.skRank(sk), mx = sk.mx ? sk.mx : 10;
      if (sk.race.empty()) actions(c, xf, f, 50401, {50410, 50411}, {{"Yükselt", "up"}, {"Kısayol", "quick"}}); else { nDraw(c, xf, f, 50401, false); hit(xf, "frame", 353, 0, 135, 320); }
      L.push_back({sk.name, 0x7a1c08, 11}); L.push_back({engine::tx("Kademe") + " " + I(r) + "/" + I(mx) + (sk.passive() ? " · " + engine::tx("edilgen") : std::string()), 0x5a4020, 9.5f});
      for (const auto& l : F_.wrap(w.skDesc(sk, r), 92, 9.5f)) L.push_back({l, 0x2a1a0a, 9.5f});
      if (r && r < mx) { const std::string nx = w.skNextDiff(sk, r); if (!nx.empty()) L.push_back({engine::T("Sonraki", "Next") + ": " + nx, 0x1a3a7a, 9.5f}); }
      const std::string lk = w.skLockMsg(sk); if (!lk.empty()) for (const auto& l : F_.wrap(lk, 92, 9.5f)) L.push_back({l, 0xc02010, 9.5f});
      for (size_t i = 0; i < L.size() && i < 15; i++) F_.text(c, xf, L[i].t, 362, (sk.race.empty() ? 118 : 30) + float(i) * 12.5f, L[i].c, L[i].s, LEFT, 94);
    }
  }
  { const auto r = rect(f, 50413); nDraw(c, xf, f, 50413, on("50413")); hit(xf, "50413", r[0] - 4, r[1], r[2] + 4, r[3]); }
}
void Win::tapSkill(World& w, const std::string& id) {
  const int n = std::atoi(id.c_str());
  if (id == "50413") { close(); open(w, "hub"); return; }
  for (size_t i = 0; i < S2TABS.size(); i++) if (n == S2TABS[i]) { S_.tree = int(i); S_.sel.clear(); w.sfx("skill_pageflip"); return; }
  if (id == "50430") { ask(engine::T("Bütün beceri puanları geri alınsın mı? (Eğitim Kitabı harcanır)", "Reset all skill points? (uses a Training Book)"), [&w] { w.cmd({"skillReset", {}}); }); return; }
  if (skCells_.count(id)) { S_.sel = id; w.sfx("menusel", 0.6); return; }
  auto it = skCells_.find(S_.sel); if (it == skCells_.end() || !it->second.sk) return;
  const SkillDef& sk = *it->second.sk;
  if (id == "up") { w.cmd({"skillUp", {std::to_string(sk.sn)}}); return; }
  if (id == "quick") {
    int i = -1; const auto& L = w.skills(); for (size_t k = 0; k < L.size(); k++) if (&L[k] == &sk) i = int(k);
    if (sk.passive() || i < 0) w.toast("Edilgen beceriler kısayola konmaz."); else if (!w.skRank(sk)) w.toast("Önce beceriyi öğren.");
    else { assignReq = "s" + I(i); assignName = sk.name; close(); }
  }
}

// ---------------- dükkân (NEW_FORM_SHOP): solda sekmeler, ortada liste (kaydırılır), altta altın ve Sat; seçilince sağda bilgi ve Satın Al ----------------
std::vector<std::string> Win::shopItems(World& w) {
  auto T = w.balance().shopTabs.find(shop_); if (T == w.balance().shopTabs.end() || H_.tab >= int(T->second.size())) return {};
  std::vector<std::string> L = T->second[size_t(H_.tab)].ids;
  auto bad = [&](const Item* it) { return it && !it->cls.empty() && it->cls != w.P.cls ? 1 : 0; };
  std::stable_sort(L.begin(), L.end(), [&](const std::string& a, const std::string& b) {
    const Item *A = w.balance().item(a), *B = w.balance().item(b);
    if (bad(A) != bad(B)) return bad(A) < bad(B);
    const int la = A ? A->lv : 0, lb = B ? B->lv : 0; if (la != lb) return la < lb;
    return std::atof(a.c_str()) < std::atof(b.c_str()); });
  return L;
}
void Win::drawShop(engine::Canvas& c, World& w, float vw, float VH) {
  const Xf xf = begin(VH / 320, safeL, 0, 41); nk_ = xf.k; const std::string f = "n_shop"; const auto items = shopItems(w);
  auto T = w.balance().shopTabs.find(shop_);
  H_.off = std::max(0, std::min(H_.off, int(items.size()) - int(H2ROWS.size())));
  const Item* selIt = H_.sel.empty() ? nullptr : w.balance().item(H_.sel);
  nDraw(c, xf, f, 50332, false); hit(xf, "frame", 126, 41, 227, 320);
  std::vector<std::string> labels; if (T != w.balance().shopTabs.end()) for (const auto& t : T->second) labels.push_back(t.name);
  tabs(c, xf, f, 50327, H2TABS, labels, H_.tab);
  for (size_t i = 0; i < H2ROWS.size(); i++) {
    const size_t k = size_t(H_.off) + i; if (k >= items.size()) break;
    const Item* it = w.balance().item(items[k]); if (!it) continue;
    const core::Json* ctl = F_.ctrl(f, H2ROWS[i]); if (!ctl) continue;
    const auto r = rect(f, H2ROWS[i]); const float x = r[0], y = 49 + float(i) * 53; const std::string id = I(H2ROWS[i]);
    const bool sel = items[k] == H_.sel || on(id), bad = !it->slot.empty() && !w.canEquip(*it).empty();
    F_.drawCtrl(c, xf, *ctl, sel ? 1 : 0, 0, y - r[1]);
    icon(c, xf, it->ik, it->icon, x + 8, y + 9, 32, bad ? 0.45f : 1);
    F_.text(c, xf, it->name, x + 49, y + 17, bad ? 0x8a7a60 : sel ? 0xffffff : 0x3a1c08, 11, LEFT, 152);
    if (it->lv) F_.text(c, xf, engine::tx("Sv") + " " + I(it->lv), x + 49, y + 34, 0x6a5a40, 9.5f, LEFT);
    F_.text(c, xf, I(it->price), x + 200, y + 34, w.P.gold < it->price ? 0xc02010 : 0x6a4a14, 11, RIGHT);
    hit(xf, id, x, y, 209, 52);
  }
  if (items.size() > H2ROWS.size()) { const float th = 265.f * H2ROWS.size() / items.size(), ty = 49 + (265 - th) * H_.off / float(items.size() - H2ROWS.size()); c.fillRect(xf.X(345), xf.Y(ty), 3 * xf.k, th * xf.k, 0x5a3c14, 0.6f); }
  nDraw(c, xf, f, 50333, false); F_.text(c, xf, I(w.P.gold), 163, 340, 0xffe070, 12, LEFT);
  const std::string empty;
  { const auto r = rect(f, 50393); nDraw(c, xf, f, 50393, on("sellmode"), &empty); F_.label(c, xf, "Sat", r[0], r[1], r[2], r[3], 0xf4ead0, CENTER, 11); hit(xf, "sellmode", r[0], r[1], r[2], r[3]); }
  { const auto r = rect(f, 50356); nDraw(c, xf, f, 50356, on("close")); hit(xf, "close", r[0] - 4, r[1], r[2] + 4, r[3]); }
  if (selIt) {
    const Xf s = xf.sub(std::min(358.f, (vw - xf.x) / xf.k - 229), 70); const std::string g = "n_shopinfo";
    nDraw(c, s, g, 50365, false); hit(s, "frame", 0, 9, 227, 250); icon(c, s, selIt->ik, selIt->icon, 19, 29, 32);
    F_.text(c, s, selIt->name, 62, 38, 0x6a0c00, 12.5f, LEFT, 150); F_.text(c, s, I(selIt->price) + " altın", 62, 54, w.P.gold < selIt->price ? 0xb01808 : 0x2a1608, 10.5f, LEFT);
    auto L = itemLines(w, *selIt); L.erase(L.begin());
    const std::string why = selIt->slot.empty() ? std::string() : w.canEquip(*selIt); if (!why.empty()) L.push_back({why, 0xc02010, 10});
    L.push_back({engine::tx("Çantada") + ": " + I(w.countItem(H_.sel)), 0x5a4020, 10});
    float y = 80;
    for (const Line& l : L) {
      uint32_t col = l.c;
      switch (col) { case 0x3a2a14: col = 0x1a0f05; break; case 0x6a4a14: case 0x5a4020: col = 0x2a1608; break; case 0x1c5a12: col = 0x0c4208; break; case 0xc02010: col = 0xb01808; break; default: break; }
      for (const auto& t : F_.wrap(l.t, 190, l.s)) { F_.text(c, s, t, 18, y, col, l.s, LEFT, 192); y += 13.5f; }
    }
    const auto r = rect(g, 50369); nDraw(c, s, g, 50369, on("buy"), &empty); F_.label(c, s, "Satın Al", r[0], r[1], r[2], r[3], 0xf4ead0, CENTER, 11); hit(s, "buy", r[0], r[1], r[2], r[3]);
  }
}
void Win::tapShop(World& w, const std::string& id) {
  const int n = std::atoi(id.c_str());
  for (size_t i = 0; i < H2TABS.size(); i++) if (n == H2TABS[i]) { H_.tab = int(i); H_.sel.clear(); H_.off = 0; w.sfx("skill_pageflip"); return; }
  for (size_t i = 0; i < H2ROWS.size(); i++) if (n == H2ROWS[i]) {
    const auto items = shopItems(w); const size_t k = size_t(H_.off) + i; if (k >= items.size()) return;
    const std::string it = items[k];
    if (H_.sel == it && doubleTap(it)) { buyAsk(w, it); return; }
    H_.sel = it; lastTapId_ = it; lastTapT_ = clock_; w.sfx("menusel", 0.6); return;
  }
  if (id == "sellmode") { const std::string sh = shop_; close(); openBag(w, B_.cat, sh); return; }
  if (id == "buy" && !H_.sel.empty()) buyAsk(w, H_.sel);
}
void Win::drag(float dy, float x, float y) {
  const bool hubShown = cur == "sys" || cur == "pet" || cur == "map" || cur == "hub";   // sol menü (HTML HUB.r)
  if (hub_.on && hubShown && x >= hub_.x && x < hub_.x + hub_.w && y >= hub_.top && y < hub_.top + hub_.h) { hub_.y = std::max(0.f, std::min(hub_.max, hub_.y - dy / hub_.k)); return; }
  if (cur != "shop") return;
  const float RH = 53 * nk_; H_.acc += dy;
  while (H_.acc <= -RH) { H_.off++; H_.acc += RH; }
  while (H_.acc >= RH) { H_.off--; H_.acc -= RH; }
  if (H_.off < 0) H_.off = 0;
}

}  // namespace ui
