#include "win.h"

#include <algorithm>
#include <cmath>

namespace ui {

using engine::Ent;
using engine::Quest;
using engine::World;

static const char* R2 = "AnbufenUI_2_Resource";
static const char* R3 = "AnbufenUI_3_Resource";
static const int N2ROWS[5] = {50289, 50290, 50291, 50292, 50293};
static const int K2ROWS[5] = {50274, 50275, 50276, 50277, 50278};
static const int HUBB[7] = {50223, 50224, 50225, 50226, 50227, 50228, 50229};
static const int DS[5] = {50447, 50448, 50449, 50450, 50451};

// Ozan (吟游诗人): 40'ta sınıf yükseltmesi, 80 için anlattıkları (HTML game.js BARD80, TR.greet)
static const char* BARD_GREET = "Şarkılarım nice kahramanın hikâyesini anlatır. 40. seviyeye gelince bana uğra; gerçek bir savaşçı, büyücü ya da kutsal elçi olmanın yolunu anlatayım.";
static std::string bard80(const std::string& cls, int lv) {
  if (lv < 80) return "Daha büyük güç istiyorsan 80. seviyeye ulaşmalısın; ancak o zaman üst sınıfların sırlarına erişebilirsin.";
  if (cls == "战士") return "Silahındaki o korkunç öldürme hırsını çok uzaktan bile hissedebiliyorum, cesur savaşçım. 80. seviyeye ulaştığında gücün daha önce hiç görülmemiş bir doruğa varacak. O zaman Bozbalta Şehri'ndeki Kara Şövalye Komutanı'nı bul, Kara Şövalye olma sınavını kabul et ve daha büyük gücün peşine düş!";
  if (cls == "法师") return "Büyüdüğünü görüyorum, çocuğum; potansiyelin sıradan bir büyücünün sınırlarını aşıyor. 80. seviyeye ulaştığında Bozbalta Şehri'ne git; Büyük Büyü Üstadı Rehberi sana daha iyi yol gösterecek. Büyük Büyü Üstadı olmak, senin asıl yazgın.";
  return "Bir kutsal elçi olarak yaptıkların herkesçe takdir edildi; ama bir kutsal elçinin asıl aradığı, tanrının onayıdır. 80. seviyeye ulaştığında Dindar Seçilmiş seni tanrının yoluna götürebilir; Dindar Seçilmiş, tanrının elçilerini seçmek için Bozbalta Şehri'nde bekliyor.";
}

void Win::open(World& w, const std::string& name, int npc, const std::string& say, bool quiet) {
  if (cur.empty()) hub_.y = 0;   // HTML: if (!cur) HUB.y = 0
  cur = name; shop_.clear(); w_ = &w;
  if (name == "npc") { npc_ = npc; say_ = say; dq_ = -1; dtrv_ = -1; dkey_.clear(); if (!quiet) w.sfx("request", 0.6); }
  if (name == "task") ksel_ = 0;
  if (name == "shop") { H_.tab = 0; H_.sel.clear(); H_.off = 0; }
  if (name == "map") { WM_.mode = "world"; WM_.sel.clear(); }
  if (name == "pet") { auto L = w.petList(); for (size_t i = 0; i < L.size(); i++) if (L[i]->uid == w.P.petOn) PW_.i = int(i); }
  B_.sel.clear(); B_.page = 0;
  if (!quiet) w.sfx("menu_appear", 0.5);   // HTML: her pencere açılışında
  if (name == "bag") w.questFlag("openBag");
}
void Win::close() { cur.clear(); npc_ = -1; say_.clear(); modal_ = Modal(); shop_.clear(); wantText = false; }
void Win::ask(const std::string& text, std::function<void()> onYes) { modal_.on = true; modal_.text = text; modal_.yes = std::move(onYes); snd("menu_appear", 0.4); }

void Win::hit(const Xf& xf, const std::string& id, float x, float y, float w, float h, std::vector<Hit>* L) { (L ? *L : hits_).push_back({id, xf.X(x), xf.Y(y), w * xf.k, h * xf.k}); }
const std::vector<float> Win::rect(const std::string& form, int id) const {
  const core::Json* c = F_.ctrl(form, id); if (!c) return {0, 0, 0, 0};
  const core::Json& r = (*c)["s"][0]["r"]; return {float(r[0].num()), float(r[1].num()), float(r[2].num()), float(r[3].num())};
}
void Win::nDraw(engine::Canvas& c, const Xf& xf, const std::string& form, int id, bool st, const std::string* txt) {
  if (const core::Json* ctl = F_.ctrl(form, id)) F_.drawCtrl(c, xf, *ctl, st ? 1 : 0, 0, 0, txt);
}
// uzun parşömen zemini (R3 7033), h yüksekliğe sıkıştırılır
void Win::longBg(engine::Canvas& c, const Xf& xf, float h) {
  if (const core::Image* I = F_.img(7033, R3)) c.drawImage(*I, 0, 0, float(I->w), float(I->h), xf.X(0), xf.Y(0), 227 * xf.k, h * xf.k, 1, true);
  hit(xf, "frame", 0, 0, 227, h);
}
// seçenek satırı (HTML nRow)
void Win::row(engine::Canvas& c, const Xf& xf, const std::string& form, int id, bool sel, const std::string& label, const std::string& key, uint32_t col) {
  const auto r = rect(form, id); nDraw(c, xf, form, id, sel);
  F_.text(c, xf, label, r[0] + 14, r[1] + 19, sel ? 0x2a0c03 : (col ? col : 0x3a1c08), 12, LEFT, 190);
  hit(xf, key, r[0], r[1], r[2], 50);
}

// ---------------- konuşma seçenekleri (HTML npcOptions) ----------------
std::pair<std::string, std::vector<Win::Opt>> Win::npcOptions(World& w) {
  std::vector<Opt> o; const Ent& n = w.ents[size_t(npc_)]; const std::string& cn = n.name; auto& Q = w.quests();
  if (!say_.empty()) { Opt b; b.t = "Tamam"; b.a = "bye"; return {say_, {b}}; }
  std::string txt = cn == "吟游诗人" ? BARD_GREET : Q.greet(cn);
  if (dtrv_ >= 0) {   // arabacının listesi: sayfa başına 3 şehir + "Diğer yerler" + "Geri"
    std::vector<int> ar; if (const auto* L = w.travelOf(npc_)) for (size_t i = 0; i < L->size(); i++) if ((*L)[i].kind == "araba") ar.push_back(int(i));
    const int per = 3, pages = std::max(1, int((ar.size() + per - 1) / per)), pg = dtrv_ % pages;
    for (int i = pg * per; i < std::min(int(ar.size()), pg * per + per); i++) { Opt e; e.t = w.travelLabel(npc_, (*w.travelOf(npc_))[size_t(ar[size_t(i)])]); e.a = "tgo"; e.tv = ar[size_t(i)]; o.push_back(e); }
    if (pages > 1) { Opt e; e.t = "Diğer yerler…"; e.a = "tmore"; o.push_back(e); }
    Opt b; b.t = "Geri"; b.a = "tback"; o.push_back(b);
    return {txt, o};
  }
  if (dq_ >= 0) {
    const Quest& q = Q.all()[size_t(dq_)]; const std::string st = w.questState(dq_);
    if (st == "new") { txt = q.tr.text; Opt a; a.t = q.tr.ok.empty() ? "Kabul et" : q.tr.ok; a.a = "accept"; Opt b; b.t = "Daha sonra"; b.a = "back"; o = {a, b}; }
    else if (st == "ready" && q.to == cn) {
      txt = q.tr.done;
      if (!q.tr.choice.empty()) for (size_t i = 0; i < q.tr.choice.size(); i++) { Opt e; e.t = q.tr.choice[i].first; e.a = "complete"; e.ch = int(i); o.push_back(e); }
      else { Opt e; e.t = "Tamamla"; e.a = "complete"; o.push_back(e); }
    } else { txt = !q.tr.wait.empty() ? q.tr.wait : q.tr.goal; Opt b; b.t = "Tamam"; b.a = "back"; o = {b}; }
    return {txt, o};
  }
  if (w.balance().shops.count(cn)) { Opt e; e.t = "Alışveriş"; e.a = "shop"; e.c = 0xffe070; o.push_back(e); }
  if (cn == "魔法兽强化大师") {   // orijinal: 幻化 / 技能转移 düğmeleri
    Opt a; a.t = "✦ Dönüşüm"; a.a = "petf"; a.s = "tf"; Opt b; b.t = "✦ Beceri aktarma"; b.a = "petf"; b.s = "sk";
    Opt h; h.t = "Dönüşüm ve beceri aktarma nedir?"; h.a = "say";
    h.s = "Dönüşüm, bir evcil hayvanın özünü alıp başka birini evrimleştiren özel bir törendir. İki hayvan da dinleniyor olmalı. Evcil hayvan penceresinde Dönüşüm'ü seç, evrimleşecek hayvanı ana yuvaya, malzeme hayvanı yardımcı yuvaya koy. Başarılı olursa ana hayvanın dönüşüm düzeyi artar, gücü de artar; başarısız olursa düzeyi bir düşer. Yardımcı eşyalar başarı şansını artırır ya da düşüşü önler. Yardımcı hayvan her durumda kaybolur. Beceri aktarma da buna benzer: ana hayvan, yardımcı hayvanın bir becerisini öğrenir. Yalnız aynı türden (fiziksel, savunma, büyü, destek) hayvanlar beceri aktarabilir ve hangi becerinin geçeceği şansa bağlıdır.";
    o.push_back(a); o.push_back(b); o.push_back(h);
  }
  for (int qi : w.questsFor(cn)) {
    const Quest& q = Q.all()[size_t(qi)]; const std::string st = w.questState(qi);
    const bool cc = st == "new" && !q.reqAny && q.req.size() == 1 && q.req[0] == 80344;   // Ozan: "Sınıf değiştirmek istiyorum!" sınıfın giriş görevini verir
    Opt e; e.t = cc ? "✦ Sınıf değiştirmek istiyorum!" : std::string(st == "ready" ? "? " : st == "new" ? "! " : "… ") + q.tr.title; e.a = "q"; e.qi = qi; e.c = st == "active" ? 0xc8c0b0 : 0xffe070;
    o.push_back(e);
  }
  if (cn == "吟游诗人" && w.P.adv == 1) { Opt e; e.t = "✦ Sınıf değiştirmek istiyorum!"; e.a = "say"; e.s = bard80(w.P.cls, w.P.lv); o.push_back(e); }
  { const int tq = w.tpQuestOf(cn); if (tq >= 0) { Opt e; e.t = "✦ Işınlan: " + Q.name(w.assets().D()["scenes"][Q.all()[size_t(tq)].tpScene]["name"].str()); e.a = "tp"; e.qi = tq; o.push_back(e); } }
  if (const auto* tv = w.travelOf(npc_)) {   // yolculuk: otomatik yolun istediği hedef en üstte; ışınlanmalar tek tek; arabacının şehirleri bir listede
    int hint = -1; if (!w.travelHint.empty()) for (size_t i = 0; i < tv->size(); i++) if ((*tv)[i].sid == w.travelHint) { hint = int(i); break; }
    if (hint >= 0) { Opt e; e.t = "✦ " + w.travelLabel(npc_, (*tv)[size_t(hint)]); e.a = "tgo"; e.tv = hint; e.c = 0x8cf07a; o.insert(o.begin(), e); }
    bool car = false;
    for (size_t i = 0; i < tv->size(); i++) { if ((*tv)[i].kind == "araba") car = true; if ((*tv)[i].kind == "tp" && int(i) != hint) { Opt e; e.t = "✦ " + w.travelLabel(npc_, (*tv)[i]); e.a = "tgo"; e.tv = int(i); o.push_back(e); } }
    if (car) { Opt e; e.t = "✦ Yolculuk (" + std::to_string(w.balance().travelCar) + " altın)"; e.a = "trv"; o.push_back(e); }
  }
  for (const auto& d : w.dungeonTps(cn)) { Opt e; e.t = "✦ " + d.first; e.a = "dtp"; e.s = cn; o.push_back(e); }   // zindan merkezine/merkezden ışınlanma
  Opt b; b.t = "Hoşça kal"; b.a = "bye"; o.push_back(b);
  if (o.size() > 6) o.resize(6);
  return {txt, o};
}

// ---------------- ana menü (NEW_FORM_V5_MENU): sol sütunda kırmızı düğmeler ----------------
void Win::drawHub(engine::Canvas& c, World& w, float VH) {
  const Xf xf = begin(VH / 320, safeL, 0); const std::string f = "n_v5_menu";
  std::vector<std::pair<std::string, std::string>> L = {{"role", "Karakter"}, {"skill", "Beceri"}, {"bag", "Çanta"}, {"pet", "Evcil"}, {"task", "Görev"}, {"map", "Harita"}, {"sys", "Sistem"}};
  if (w.isGM()) L.push_back({"gm", "GM"});   // HTML hubItems: GM karakterde 8. düğme
  const float HUBS = 43, HUBT = 8, HUBA = 312, max = std::max(0.f, float(L.size() - 7) * HUBS);   // düğmeler 43 birim arayla; görünen bant 8..312
  hub_.y = std::max(0.f, std::min(hub_.y, max)); hub_.on = true; hub_.x = xf.x; hub_.top = xf.y; hub_.w = 126 * xf.k; hub_.h = 320 * xf.k; hub_.k = xf.k; hub_.max = max;
  nDraw(c, xf, f, 50222, false); hit(xf, "frame", 0, 0, 126, 320);
  c.clipRect(xf.X(0), xf.Y(HUBT), 126 * xf.k, (HUBA - HUBT) * xf.k);
  for (size_t i = 0; i < L.size(); i++) {
    const int j = std::min(int(i), 6); const float dy = float(int(i) - j) * HUBS - hub_.y;
    const core::Json* ctl = F_.ctrl(f, HUBB[j]); if (!ctl) continue;
    const auto r = rect(f, HUBB[j]); const std::string k = L[i].first, label = L[i].second;
    const float y0 = std::max(r[1] + dy, HUBT), y1 = std::min(r[1] + dy + r[3], HUBA); if (y1 - y0 < 2) continue;
    F_.drawCtrl(c, xf, *ctl, k == cur || on("hub:" + k) ? 1 : 0, 0, dy, &label);
    if (y1 - y0 > 10) hit(xf, "hub:" + k, r[0], y0, r[2], y1 - y0);
  }
  c.clearClip();
  // daha aşağıda / yukarıda düğme varsa küçük ok (HTML arrow: rgba(255,214,120,.9))
  auto arrow = [&](float y, bool up) { c.fillTriangle(xf.X(57), xf.Y(y), xf.X(69), xf.Y(y), xf.X(63), xf.Y(up ? y - 6 : y + 6), 0xffd678, 0.9f); };
  if (hub_.y < max) arrow(HUBA - 3, false);
  if (hub_.y > 0) arrow(HUBT + 9, true);
  const auto r = rect(f, 50230); nDraw(c, xf, f, 50230, on("close")); hit(xf, "close", r[0] - 4, r[1], r[2] + 4, r[3]);
}

// ---------------- konuşma (NEW_FORM_NPC_DIALOGUE): üstte söz (5 satırlık sayfalar), altta seçenek satırları ----------------
void Win::drawNpc(engine::Canvas& c, World& w, float VH) {
  if (npc_ < 0 || npc_ >= int(w.ents.size())) { close(); return; }
  const Xf xf = begin(VH / 373, safeL, 0); const std::string f = "n_npc_dialogue";
  auto opt = npcOptions(w); const std::string txt = opt.first; std::vector<Opt> o = opt.second; if (o.size() > 5) o.resize(5);
  const auto lines = F_.wrap(txt, 196, 11); const int per = 5, pages = std::max(1, int((lines.size() + per - 1) / per));
  if (dkey_ != txt) { dkey_ = txt; dpg_ = 0; dfocus_ = 0; }
  if (dpg_ < pages - 1) { Opt e; e.t = "Devam"; e.a = "next"; o = {e}; }
  if (dfocus_ >= int(o.size())) dfocus_ = 0;
  npcMap_.clear();
  longBg(c, xf); F_.text(c, xf, w.quests().name(w.ents[size_t(npc_)].name), 16, 20, 0x7a1c08, 12, LEFT, 180);
  for (int i = dpg_ * per; i < std::min(int(lines.size()), dpg_ * per + per); i++) F_.text(c, xf, lines[size_t(i)], 16, 38 + float(i - dpg_ * per) * 13.5f, 0x2a1a0a, 11, LEFT, 198);
  for (size_t i = 0; i < o.size(); i++) {
    const std::string id = std::to_string(N2ROWS[i]); npcMap_[id] = o[i];
    row(c, xf, f, N2ROWS[i], on(id) || int(i) == dfocus_, o[i].t, id, o[i].c == 0xc8c0b0 ? 0x6a5a40 : 0);
  }
  const auto r = rect(f, 50294); nDraw(c, xf, f, 50294, on("close")); hit(xf, "close", r[0] + 6, r[1], 36, 36);
}
void Win::tapNpc(World& w, const std::string& id) {
  auto it = npcMap_.find(id); if (it == npcMap_.end()) return;
  const Opt e = it->second; const int n = npc_;
  for (int i = 0; i < 5; i++) if (std::to_string(N2ROWS[i]) == id) dfocus_ = i;
  if (e.a == "next") { dpg_++; dfocus_ = 0; return; }
  if (e.a == "bye") { close(); return; }
  if (e.a == "q") { dq_ = e.qi; return; }
  if (e.a == "back") { dq_ = -1; return; }
  if (e.a == "say") { say_ = e.s; return; }
  if (e.a == "soon") { w.toast("Bu bölüm yakında."); return; }
  if (e.a == "petf") { openPetF(w, e.s); return; }
  if (e.a == "dtp") { close(); const auto L = w.dungeonTps(e.s); if (!L.empty()) w.dungeonTpGo(*L[0].second); return; }
  if (e.a == "shop") { const std::string cn = w.ents[size_t(n)].name; close(); openShop(w, cn); return; }
  if (e.a == "tp") { close(); w.questTeleport(e.qi); return; }
  if (e.a == "trv") { dtrv_ = 0; return; }
  if (e.a == "tmore") { dtrv_++; return; }
  if (e.a == "tback") { dtrv_ = -1; return; }
  if (e.a == "tgo") { const auto* L = w.travelOf(n); if (!L) return; const engine::TravelOpt x = (*L)[size_t(e.tv)]; const int c = w.travelCost(n, x); if (c && w.P.gold < c) { w.toast(std::to_string(c) + " altın gerekir."); return; } close(); w.travelGo(n, x); return; }
  if (e.a == "accept") { const int qi = dq_; dq_ = -1; const std::string cn = w.ents[size_t(n)].name; close(); w.dialogAccept(qi, cn); return; }   // görev alınınca pencere kapanır
  if (e.a == "complete") {
    const int qi = dq_; dq_ = -1; const Quest& q = w.quests().all()[size_t(qi)];
    w.completeQuest(qi); if (e.ch >= 0 && size_t(e.ch) < q.tr.choice.size()) say_ = q.tr.choice[size_t(e.ch)].second;
    return;
  }
}

// ---------------- görev listesi (NEW_FORM_TASK): solda satırlar, sağda seçili görevin bilgisi ----------------
std::vector<int> Win::taskList(World& w) {
  std::vector<int> L; const auto& Q = w.quests().all();
  if (kmode_ != "avail") { for (size_t i = 0; i < Q.size(); i++) if (w.P.quests.count(Q[i].id)) L.push_back(int(i)); return L; }
  for (size_t i = 0; i < Q.size(); i++) { const std::string st = w.questState(int(i)); if (st == "new" || (st == "soon" && w.quests().minLv(int(i)) <= w.P.lv + 5)) L.push_back(int(i)); }
  std::stable_sort(L.begin(), L.end(), [&](int a, int b) {
    const int sa = w.questState(a) == "new" ? 0 : 1, sb = w.questState(b) == "new" ? 0 : 1; if (sa != sb) return sa < sb;
    const int la = w.quests().minLv(a), lb = w.quests().minLv(b); if (la != lb) return la < lb;
    return Q[size_t(a)].id < Q[size_t(b)].id; });
  return L;
}
void Win::drawTask(engine::Canvas& c, World& w, float VH) {
  const Xf xf = begin(VH / 320, safeL, 0, 42); const std::string f = "n_task"; const auto list = taskList(w); const bool avail = kmode_ == "avail"; auto& Q = w.quests();
  auto idx = [&](int id) { for (int qi : list) if (Q.all()[size_t(qi)].id == id) return qi; return -1; };
  if (ksel_ && idx(ksel_) < 0) ksel_ = 0;
  if (!ksel_ && !list.empty()) ksel_ = Q.all()[size_t(list[0])].id;
  if (koff_ > std::max(0, int(list.size()) - 5)) koff_ = 0;
  const int selQ = ksel_ ? idx(ksel_) : -1;
  nDraw(c, xf, f, 50787, false); hit(xf, "frame", 0, 42, 227, 320);
  for (int i = 0; i < 5 && koff_ + i < int(list.size()); i++) {
    const int qi = list[size_t(koff_ + i)]; const Quest& q = Q.all()[size_t(qi)]; const std::string id = std::to_string(K2ROWS[i]);
    const auto r = rect(f, K2ROWS[i]); const bool sel = q.id == ksel_ || on(id); const std::string st = w.questState(qi);
    nDraw(c, xf, f, K2ROWS[i], sel);
    F_.text(c, xf, std::string(avail && st == "new" ? "! " : "") + q.tr.title, r[0] + 12, r[1] + 17, sel ? 0xffffff : st == "soon" ? 0x7a6a50 : 0x3a1c08, 12, LEFT, 190);
    std::string sub; uint32_t col = 0x6a4a14;
    if (avail) { sub = st == "soon" ? engine::tx("Sv") + " " + std::to_string(Q.minLv(qi)) : Q.name(q.giver); col = st == "soon" ? 0xa03010 : 0x3a2a14; }
    else { const auto& a = w.P.quests.at(q.id); sub = a.ready ? "Tamam" : q.count ? std::to_string(a.n) + "/" + std::to_string(q.count) : "…"; col = a.ready ? 0x1c6a12 : 0x6a4a14; }
    F_.text(c, xf, sub, r[0] + 204, r[1] + 35, col, 10, RIGHT, 150); hit(xf, id, r[0], r[1], r[2], 50);
  }
  if (list.empty()) { F_.text(c, xf, avail ? "Şu an alınabilecek görev yok." : "Aktif görev yok.", 113, 150, 0x5a4020, 12, CENTER, 200); if (!avail) F_.text(c, xf, "Alınabilir listesine bak.", 113, 168, 0x5a4020, 11, CENTER, 200); }
  // alt: liste seçimi (Aktif / Alınabilir) ve sayfa
  int nA = 0, nN = 0; for (size_t i = 0; i < Q.all().size(); i++) { if (w.P.quests.count(Q.all()[i].id)) nA++; if (w.questState(int(i)) == "new") nN++; }
  const std::pair<std::string, std::string> modes[2] = {{"act", engine::tx("Aktif") + " (" + std::to_string(nA) + ")"}, {"avail", engine::tx("Alınabilir") + " (" + std::to_string(nN) + ")"}};
  for (int m = 0; m < 2; m++) {
    const float x = m ? 116.f : 10.f; const bool sel = kmode_ == modes[m].first;
    if (const core::Image* I = F_.img(7019, R2)) c.drawImage(*I, 0, 0, 84, 24, xf.X(x), xf.Y(312), 100 * xf.k, 26 * xf.k, sel ? 1 : 0.6f, true);
    F_.label(c, xf, modes[m].second, x, 312, 100, 26, sel ? 0xffe070 : 0xd8d0c0, CENTER, 11); hit(xf, "mode:" + modes[m].first, x, 312, 100, 26);
  }
  if (list.size() > 5) { F_.text(c, xf, std::to_string(koff_ + 1) + "-" + std::to_string(std::min(int(list.size()), koff_ + 5)) + " / " + std::to_string(list.size()) + "  ▾", 113, 348, 0x5a4020, 10, CENTER); hit(xf, "more", 40, 340, 150, 20); }
  { const auto r = rect(f, 50280); nDraw(c, xf, f, 50280, on("close")); hit(xf, "close", r[0] + 6, r[1], 36, 36); }
  if (selQ >= 0) {   // sağ: seçili görevin bilgisi (n_item_info)
    const Xf s = xf.sub(232, 62); const std::string g = "n_item_info"; const Quest& q = Q.all()[size_t(selQ)]; const std::string st = w.questState(selQ);
    nDraw(c, s, g, 50419, false); hit(s, "frame", 0, 9, 227, 250);
    F_.text(c, s, q.tr.title, 18, 36, 0x6a0c00, 12.5f, LEFT, 192);
    std::vector<std::pair<std::string, uint32_t>> L;
    if (avail) {
      const std::string sid = w.npcSceneNear(q.giver);
      L.push_back({engine::tx("Veren") + ": " + Q.name(q.giver) + (sid.empty() ? "" : " · " + Q.name(w.assets().D()["scenes"][sid]["name"].str())), 0x2a1608});
      L.push_back({engine::tx("Seviye") + ": " + std::to_string(Q.minLv(selQ)) + (st == "soon" ? " · " + engine::tx("henüz açılmadı") : std::string()), st == "soon" ? 0xb01808 : 0x0c4208});
    } else L.push_back({engine::tx("Teslim") + ": " + Q.name(q.to), 0x2a1608});
    for (const auto& l : F_.wrap(q.tr.goal, 190, 10)) L.push_back({l, 0x0c4208});
    std::string rw = engine::tx("Ödül") + ": " + std::to_string(q.xp) + " " + engine::tx("TP") + " · " + std::to_string(q.gold) + " " + engine::tx("altın"); std::string items;
    for (const Quest::RItem& it : q.items) { if (!w.itemExists(it.id) || (!it.cls.empty() && std::find(it.cls.begin(), it.cls.end(), w.P.cls) == it.cls.end())) continue; items += (items.empty() ? "" : ", ") + w.itemName(it.id) + (it.n > 1 ? " ×" + std::to_string(it.n) : ""); }
    if (!items.empty()) rw += " · " + items;
    for (const auto& l : F_.wrap(rw, 190, 10)) L.push_back({l, 0x6a3a00});
    L.push_back({"", 0});
    for (const auto& l : F_.wrap(q.tr.text, 190, 10)) L.push_back({l, 0x1a0f05});
    for (size_t i = 0; i < L.size() && i < 12; i++) F_.text(c, s, L[i].first, 18, 54 + float(i) * 12.5f, L[i].second, 10, LEFT, 192);
    std::vector<std::pair<int, std::pair<std::string, std::string>>> B = {{50423, {"Yol Bul", "walk"}}};
    if (!avail) B.push_back({50424, {"Bırak", "drop"}});
    const std::string empty;
    for (const auto& b : B) { const auto r = rect(g, b.first); nDraw(c, s, g, b.first, on(b.second.second), &empty); F_.label(c, s, b.second.first, r[0], r[1], r[2], r[3], 0xf4ead0, CENTER, 11); hit(s, b.second.second, r[0], r[1], r[2], r[3]); }
  }
}
void Win::tapTask(World& w, const std::string& id) {
  const auto list = taskList(w); const auto& Q = w.quests().all();
  if (id.rfind("mode:", 0) == 0) { kmode_ = id.substr(5); ksel_ = 0; koff_ = 0; w.sfx("skill_pageflip"); return; }
  for (int i = 0; i < 5; i++) if (std::to_string(K2ROWS[i]) == id && koff_ + i < int(list.size())) { ksel_ = Q[size_t(list[size_t(koff_ + i)])].id; w.sfx("menusel", 0.6); return; }
  if (id == "more") { koff_ = koff_ + 5 >= int(list.size()) ? 0 : koff_ + 5; return; }
  const int qi = ksel_ ? w.quests().indexOf(ksel_) : -1; if (qi < 0) return;
  const Quest& q = Q[size_t(qi)];
  if (id == "walk") { const bool avail = kmode_ == "avail"; close(); if (avail) w.routeToNpc(q.giver); else w.questWalk(qi); return; }
  if (id == "drop") { const int qid = q.id; const std::string title = q.tr.title; ask(title + ": " + engine::tx("görev bırakılsın mı?"), [&w, this, qid, title] { w.P.quests.erase(qid); ksel_ = 0; w.note(engine::tx("Görev bırakıldı") + ": " + title); }); }
}

// ---------------- ölüm (NEW_FORM_DEADSELECT) ----------------
void Win::drawDead(engine::Canvas& c, World& w, float vw, float VH) {
  const float k = VH / 373; const Xf xf = begin(k, std::round((vw - 227 * k) / 2), 0); const std::string f = "n_deadselect";
  std::string where;
  if (w.P.hasHome) where = w.quests().name(w.assets().D()["scenes"][w.P.homeScene]["name"].str());
  else if (w.P.done.count(80003) || w.P.quests.count(80003)) where = w.quests().name(w.assets().D()["scenes"]["120005"]["name"].str());
  else where = w.quests().name(w.sceneName);
  longBg(c, xf, 170); F_.text(c, xf, "Öldün", 113, 26, 0xa81808, 15, CENTER);
  const auto L = F_.wrap(engine::tx("Savaşta yenildin. Canının ve mananın yarısıyla yeniden doğacaksın."), 196, 11);
  for (size_t i = 0; i < L.size(); i++) F_.text(c, xf, L[i], 113, 52 + float(i) * 14, 0x2a1a0a, 11, CENTER, 200);
  row(c, xf, f, DS[0], true, engine::tx("Yeniden doğ") + ": " + where, "revive");
}

// ---------------- onay kutusu (NEW_FORM_DIALOG_YESNO) ----------------
void Win::drawModal(engine::Canvas& c, float vw, float VH) {
  c.fillRect(0, 0, vw, VH, 0x000000, 0.45f); modal_.hits.clear();
  if (modal_.num) { drawNum(c, vw, VH); return; }
  const float k = 1.3f; const Xf xf = begin(k, std::round((vw - 227 * k) / 2), std::round((VH - 129 * k) / 2)); const std::string f = "n_dialog_yesno";
  nDraw(c, xf, f, 50042, false);
  auto L = F_.wrap(modal_.text, 196, 11); if (L.size() > 5) L.resize(5);
  for (size_t i = 0; i < L.size(); i++) F_.text(c, xf, L[i], 113, 46 - float(L.size()) * 7 + float(i) * 14 + 7, 0x2a1a0a, 11, CENTER, 200);
  const std::string empty;
  for (const auto& b : std::vector<std::pair<int, std::pair<std::string, std::string>>>{{50041, {"Tamam", "m52786"}}, {50040, {"İptal", "m52788"}}}) {
    const auto r = rect(f, b.first); nDraw(c, xf, f, b.first, on(b.second.second), &empty); F_.label(c, xf, b.second.first, r[0], r[1], r[2], r[3], 0xf4ead0, CENTER, 11);
    hit(xf, b.second.second, r[0], r[1], r[2], r[3], &modal_.hits);
  }
}

void Win::draw(engine::Canvas& c, World& w, float dt) {
  w_ = &w;
  clock_ += dt; hits_.clear();
  const float vw = float(c.w()), VH = float(engine::VH);
  if (cur == "bag") drawBag(c, w, VH);
  else if (cur == "role") drawRole(c, w, VH);
  else if (cur == "npc") drawNpc(c, w, VH);
  else if (cur == "task") drawTask(c, w, VH);
  else if (cur == "skill") drawSkill(c, w, VH);
  else if (cur == "shop") drawShop(c, w, vw, VH);
  else if (cur == "dead") drawDead(c, w, vw, VH);
  else if (cur == "list") drawList(c, w, VH);
  else if (cur == "petf") drawPetF(c, w, vw, VH);
  if (cur == "sys") { drawHub(c, w, VH); drawSys(c, w, VH); }
  else if (cur == "pet") { drawHub(c, w, VH); drawPet(c, w, VH); }
  else if (cur == "map") { drawMap(c, w, vw, VH); drawHub(c, w, VH); }
  if (cur == "hub") drawHub(c, w, VH);
  if (modal_.on) drawModal(c, vw, VH);
}

bool Win::tap(World& w, float x, float y) {
  w_ = &w;
  if (modal_.on) {
    for (const Hit& h : modal_.hits) if (x >= h.x && x < h.x + h.w && y >= h.y && y < h.y + h.h) {
      pressed_ = h.id; pressT_ = clock_; w.sfx("menusel", 0.6); Modal& m = modal_;
      if (h.id == "m52786") { auto yes = m.yes; modal_ = Modal(); if (yes) yes(); }
      else if (h.id == "m52788" || h.id == "m52792") { modal_ = Modal(); wantText = false; }
      else if (h.id == "m50758") { m.n = m.n > 1 ? m.n - 1 : m.max; m.typed.clear(); }
      else if (h.id == "m50759") { m.n = m.n < m.max ? m.n + 1 : 1; m.typed.clear(); }
      else if (h.id == "m50761") { wantText = true; m.typed.clear(); }   // sayıya dokun: klavyeyle adet yaz (telefonda ekran klavyesi)
      else if (h.id == "m52791") { auto ok = m.ok; const int n = m.n; modal_ = Modal(); wantText = false; if (ok) ok(n); }
      break;
    }
    return true;
  }
  if (cur.empty()) return false;
  const Hit* h = nullptr;   // en küçük isabet (çerçeve en son)
  for (const Hit& r : hits_) if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) { if (r.id == "frame") { if (!h) h = &r; } else if (!h || h->id == "frame" || r.w * r.h < h->w * h->h) h = &r; }
  if (!h) { if (cur != "dead") close(); return true; }
  const std::string id = h->id; pressed_ = id; pressT_ = clock_;
  if (id.rfind("hub:", 0) == 0) {
    const std::string k = id.substr(4); w.sfx("skill_pageflip");
    if (k == "gm") { gmReq = true; return true; }   // HTML: UI.open('gm')
    if (k == "task" || k == "role" || k == "bag" || k == "skill" || k == "map" || k == "sys" || k == "pet") { if (k != cur) { close(); open(w, k); } }
    else if (k != cur) w.toast("Bu pencere yakında.");
    return true;
  }
  if (id == "close") { close(); return true; }
  if (cur == "sys") { if (id.rfind("s:", 0) == 0) tapSys(w, id.substr(2)); return true; }
  if (cur == "pet") { tapPet(w, id); return true; }
  if (cur == "petf") { tapPetF(w, id); return true; }
  if (cur == "map") { tapMap(w, id); return true; }
  if (cur == "list") { tapList(w, id); return true; }
  if (cur == "bag") tapBag(w, id);
  else if (cur == "role") tapRole(w, id);
  else if (cur == "npc") tapNpc(w, id);
  else if (cur == "task") tapTask(w, id);
  else if (cur == "skill") tapSkill(w, id);
  else if (cur == "shop") tapShop(w, id);
  else if (cur == "dead" && id == "revive") { close(); w.revive(); }
  return true;
}

}  // namespace ui
