// Evcil hayvan pencereleri (HTML win.js drawPet2/tapPet2, drawPetF/tapPetF; Android NEW_FORM petcomplex, newpetai, fantasize_pet).
// Evcil: portre (şimdiki biçim), ad, Çağır/Geri çağır, Besle / Taktik / Dönüşüm yuvaları, sıradaki hayvan; üç sekme: Bilgi (nitelikler,
// tokluk, dönüşüm, taktik, Bırak), Beceriler (simgeli liste, açıklama), Ağaç (8 biçim 4×2). Taktik: 5 orijinal mod. Dönüşüm penceresi:
// ana / yardımcı hayvan, 2 yardımcı eşya, sonuç, bedel; sağ balonda kip sekmeleri ve açıklama; sepet Usta'nın dükkânını açar.
#include <algorithm>
#include <cmath>
#include <cstdio>

#include "win.h"

namespace ui {

using engine::PetRec;
using engine::World;

static const char* MODES[5] = {"attack", "counter", "support", "free", "idle"};
static const char* MODEN[5][2] = {{"Saldırı", "Sahibinin saldırdığı hedefe saldırır."}, {"Karşı Saldırı", "Sahibine saldıran düşmana saldırır."},
                                  {"Destek", "Yalnız destek becerilerini kullanır."}, {"Serbest Saldırı", "Görüş alanına giren düşmana kendiliğinden saldırır."},
                                  {"Bekleme", "Sahibini izler, hiçbir şey yapmaz."}};
static int modeIx(const std::string& m) { for (int i = 0; i < 5; i++) if (m == MODES[i]) return i; return 0; }
static std::string I(long long v) { return std::to_string(v); }
static std::string jsNum(double v) { if (std::floor(v) == v && std::fabs(v) < 1e15) return I((long long)v); char b[40]; for (int p = 1; p <= 17; p++) { std::snprintf(b, sizeof b, "%.*g", p, v); if (std::strtod(b, nullptr) == v) break; } return b; }
static const std::vector<const char*> AIDS = {"30164", "30730", "31234", "30731", "30749", "30023", "30750", "30751", "30752", "30753"};

// hayvan görselini küçültüp kutuya sığdır (kırpılmış; alt kenardan 3 birim yukarıda, 2. hareket)
void Win::petSprite(engine::Canvas& c, World& w, const Xf& xf, const std::string& look, float x, float y, float ww, float hh, float sc, float alpha) {
  engine::Sprite* sp = w.map.sprite(look); if (!sp || !sp->ok()) return;
  c.clipRect(xf.X(x), xf.Y(y), ww * xf.k, hh * xf.k);
  sp->drawScaled(c, 2, w.time * engine::TICK, xf.X(x + ww / 2), xf.Y(y + hh - 3), xf.k * sc, alpha, true);
  c.clearClip();
}

void Win::drawPet(engine::Canvas& c, World& w, float VH) {
  const float k = VH / 290; const std::string f = "n_petcomplex"; auto L = w.petList(); if (PW_.i >= int(L.size())) PW_.i = 0;
  PetRec* p = L.empty() ? nullptr : L[size_t(PW_.i)];
  const Xf xf = begin(k, safeL + 126 * VH / 320, std::round((VH - 259 * k) / 2));
  nDraw(c, xf, f, 50123, false); hit(xf, "frame", 0, 9, 227, 250);
  { const auto r = rect(f, 50124); nDraw(c, xf, f, 50124, on("p:x")); hit(xf, "p:x", r[0], r[1], r[2], r[3]); }
  const auto box = rect(f, 50125); nDraw(c, xf, f, 50125, false);
  if (!p) {
    F_.text(c, xf, "Evcil hayvanın yok", 146, 43, 0x3a1c08, 12, CENTER, 120);
    auto W = F_.wrap("Şehirlerdeki Hayvan Terbiyecisi'nden bilgi al. Yumurtayı kuluçka kutusuyla çıkar; yumurtalar canavarlardan da düşer.", 196, 11);
    for (size_t i = 0; i < W.size() && i < 8; i++) F_.text(c, xf, W[i], 14, 140 + float(i) * 14, 0x2a1a0a, 10.5f, LEFT, 198);
    return;
  }
  const auto st = w.petStats(*p); const engine::PetSpecies& S = *w.balance().pets.by(p->sp); const engine::PetTemplate& tp = w.balance().pets.templates.at(S.tpl);
  const bool onNow = w.P.petOn == p->uid; const auto& D0 = w.balance().pets;
  // portre: hayvanın şimdiki biçimi
  if (engine::Sprite* sp = w.map.sprite(w.petForm(*p).look)) if (sp->ok()) {
    c.clipRect(xf.X(box[0] + 2), xf.Y(box[1] + 2), (box[2] - 4) * k, (box[3] - 4) * k);
    sp->drawScaled(c, 2, w.time * engine::TICK, xf.X(box[0] + box[2] / 2), xf.Y(box[1] + box[3] - 8), k, 1, true); c.clearClip();
  }
  { const auto r = rect(f, 50126); nDraw(c, xf, f, 50126, false); F_.text(c, xf, w.petName(*p) + "  Sv " + I(p->lv), r[0] + r[2] / 2, r[1] + r[3] / 2, p->dead ? 0xa02010 : 0xffe9a8, 11, CENTER, r[2] - 6); }
  { const auto r = rect(f, 50127); nDraw(c, xf, f, 50127, on("p:on")); F_.text(c, xf, p->dead ? "Ölü" : onNow ? "Geri çağır" : "Çağır", r[0] + r[2] / 2, r[1] + r[3] / 2, 0xf4ead0, 11, CENTER); hit(xf, "p:on", r[0], r[1], r[2], r[3]); }
  for (const auto& sl : std::vector<std::pair<int, std::pair<const char*, const char*>>>{{50756, {"feed", "Besle"}}, {50757, {"ai", "Taktik"}}, {50758, {"tf", "Dönüşüm"}}}) {
    const std::string key = std::string("p:") + sl.second.first; const auto r = rect(f, sl.first);
    nDraw(c, xf, f, sl.first, on(key) || (std::string(sl.second.first) == "ai" && PW_.ai)); F_.text(c, xf, sl.second.second, r[0] + r[2] / 2, r[1] + r[3] / 2, 0x2a1a0a, 9, CENTER, r[2] - 2); hit(xf, key, r[0], r[1], r[2], r[3]);
  }
  { const auto r = rect(f, 50128); nDraw(c, xf, f, 50128, on("p:next")); F_.text(c, xf, I(PW_.i + 1) + "/" + I((long long)L.size()), r[0] + r[2] / 2, r[1] + r[3] / 2, 0x2a1a0a, 9.5f, CENTER); if (L.size() > 1) hit(xf, "p:next", r[0], r[1], r[2], r[3]); }
  // sekmeler
  const char* TABS[3] = {"Bilgi", "Beceriler", "Ağaç"};
  for (int i = 0; i < 3; i++) { const float x = 14 + float(i) * 66; const bool a = PW_.tab == i; F_.text(c, xf, TABS[i], x + 31, 140, a ? 0x7a1c08 : 0x5a4a30, 11, CENTER); if (a) c.fillRect(xf.X(x + 8), xf.Y(147), 46 * k, 1.5f * k, 0x7a1c08); hit(xf, "p:tab:" + I(i), x, 131, 62, 18); }
  const float Y = 160, LH = 13;
  if (PW_.tab == 0) {
    const engine::PetStage* nx = p->st + 1 < int(D0.stages.size()) ? &D0.stages[size_t(p->st + 1)] : nullptr;
    const bool hungry = p->sat <= 0 || p->joy <= 20; char dg[16]; std::snprintf(dg, sizeof dg, "%.0f", st.dodge);
    const std::vector<std::pair<std::string, uint32_t>> lines = {
      {S.tr + " · " + tp.tr + " · Yetenek ×" + jsNum(p->tal), 0x7a1c08},
      {"Can " + I((long long)engine::jsRound(p->hp)) + "/" + jsNum(st.hp) + " · Mana " + I((long long)engine::jsRound(p->mp)) + "/" + jsNum(st.mp), 0x2a1a0a},
      {"Saldırı " + jsNum(st.mag ? st.matk : st.patk) + " · Savunma " + jsNum(st.def) + " · Kaçınma %" + dg, 0x2a1a0a},
      {"Deneyim " + jsNum(p->xp) + "/" + I(w.petNeedXp(p->lv)) + (p->lv >= w.P.lv ? " (sınır: senin seviyen)" : ""), 0x2a1a0a},
      {"Tokluk " + jsNum(p->sat) + " · Mutluluk " + jsNum(p->joy) + (hungry ? " · savaşmıyor!" : ""), hungry ? 0xa02010u : 0x2a1a0au},
      {"Dönüşüm " + I(p->st) + "/7" + (nx ? " · sonraki: Sv " + I(nx->lv) : std::string()), 0x2a1a0a},
      {std::string("Taktik: ") + MODEN[modeIx(w.P.petMode)][0], 0x2a1a0a}};
    for (size_t i = 0; i < lines.size(); i++) F_.text(c, xf, lines[i].first, 14, Y + float(i) * LH, lines[i].second, 10, LEFT, 198);
    F_.text(c, xf, "Bırak", 210, Y + 6 * LH, on("p:rel") ? 0xff4020 : 0xa02010, 10, RIGHT); hit(xf, "p:rel", 172, Y + 6 * LH - 8, 42, 16);
  } else if (PW_.tab == 1) {
    const auto ks = w.petSkills(*p); if (PW_.skd >= int(ks.size())) PW_.skd = 0;
    static const std::map<std::string, std::string> SKIND = {{"active", "Saldırı"}, {"support", "Destek"}, {"passive", "Kalıcı"}, {"aura", "Hale"}};
    for (size_t i = 0; i < ks.size(); i++) {
      auto it = D0.skills.find(ks[i]); if (it == D0.skills.end()) continue; const auto& d = it->second; const float y = 151 + float(i) * 19; const bool sel = PW_.skd == int(i);
      if (sel) c.fillRect(xf.X(12), xf.Y(y - 1), 202 * k, 19 * k, 0x7a1c08, 0.12f);
      if (d.icon) icon(c, xf, "skill", d.icon, 14, y, 17);
      F_.text(c, xf, d.tr, 36, y + 8.5f, sel ? 0x7a1c08 : 0x2a1a0a, 10.5f, LEFT, 110);
      auto kd = SKIND.find(d.kind);
      F_.text(c, xf, std::string(i ? "rastgele" : "doğuştan") + " · " + (kd == SKIND.end() ? "Saldırı" : kd->second), 212, y + 8.5f, 0x7a6a50, 8.5f, RIGHT, 64); hit(xf, "p:sk:" + I((long long)i), 12, y - 1, 202, 19);
    }
    if (ks.size() < 4) F_.text(c, xf, "Rastgele beceri yuvası: " + I((long long)ks.size() - 1) + "/3", 14, 151 + float(ks.size()) * 19 + 8, 0x5a4a30, 9, LEFT, 198);
    auto it = D0.skills.find(ks[size_t(PW_.skd)]);
    if (it != D0.skills.end()) { auto W = F_.wrap(it->second.desc, 198, 9); for (size_t i = 0; i < W.size() && i < 2; i++) F_.text(c, xf, W[i], 14, 232 + float(i) * 11, 0x3a2a10, 9, LEFT, 200); }
  } else {
    const float cw = 50, ch = 44;
    for (size_t i = 0; i < S.forms.size(); i++) {
      const float x = 13 + float(i % 4) * cw, y = 150 + float(i / 4) * (ch + 1); const bool got = int(i) <= p->st, cur0 = int(i) == p->st, sel = PW_.tree == int(i);
      c.fillRect(xf.X(x), xf.Y(y), (cw - 2) * k, ch * k, cur0 ? 0xffd040u : sel ? 0x7a1c08u : 0x000000u, cur0 ? 0.35f : sel ? 0.15f : 0.06f);
      if (cur0 || sel) c.strokeRect(xf.X(x + 0.5f), xf.Y(y + 0.5f), (cw - 3) * k, (ch - 1) * k, k, cur0 ? 0xc08a10 : 0x7a1c08);
      petSprite(c, w, xf, S.forms[i].look, x, y, cw - 2, ch, 0.36f, got ? 1 : 0.45f);
      F_.text(c, xf, I((long long)i), x + 3, y + 6, 0x7a1c08, 8, LEFT); if (i) F_.text(c, xf, "Sv" + I(D0.stages[i].lv), x + cw - 4, y + 6, 0x5a4a30, 7.5f, RIGHT);
      hit(xf, "p:tr:" + I((long long)i), x, y, cw - 2, ch);
    }
    const int si = PW_.tree >= 0 ? PW_.tree : p->st; const auto& fm = S.forms[size_t(si)];
    F_.text(c, xf, I(si) + ": " + fm.tr + (si ? " · Sv " + I(D0.stages[size_t(si)].lv) + " · " + I(D0.stages[size_t(si)].cost) + " altın" : std::string()), 113, 246, 0x3a2a10, 9, CENTER, 200);
  }
  if (PW_.ai) {   // taktik: 5 orijinal mod
    const std::string f2 = "n_newpetai"; const int rows[5] = {50145, 50146, 50147, 50148, 50149};
    const Xf x2 = begin(k * 0.9f, safeL + 126 * VH / 320 + 232 * k, std::round((VH - 300 * k * 0.9f) / 2));
    nDraw(c, x2, f2, 50143, false); hit(x2, "frame", 0, 20, 227, 250);
    for (int i = 0; i < 5; i++) {
      const std::string key = std::string("p:m:") + MODES[i]; const auto r = rect(f2, rows[i]);
      nDraw(c, x2, f2, rows[i], modeIx(w.P.petMode) == i || on(key));
      F_.text(c, x2, MODEN[i][0], r[0] + 12, r[1] + 15, 0x3a1c08, 12, LEFT, 170); F_.text(c, x2, MODEN[i][1], r[0] + 12, r[1] + 30, 0x5a3a18, 9, LEFT, 175); hit(x2, key, r[0], r[1], r[2], r[3]);
    }
    const auto r = rect(f2, 50144); nDraw(c, x2, f2, 50144, on("p:aix")); hit(x2, "p:aix", r[0], r[1], r[2], r[3]);
  }
}
void Win::tapPet(World& w, const std::string& id) {
  auto L = w.petList(); PetRec* p = PW_.i < int(L.size()) ? L[size_t(PW_.i)] : nullptr;
  if (id == "p:x") { close(); return; }
  if (id == "p:next") { if (!L.empty()) PW_.i = (PW_.i + 1) % int(L.size()); PW_.tree = -1; PW_.skd = 0; return; }
  if (id == "p:aix") { PW_.ai = false; return; }
  if (id.rfind("p:m:", 0) == 0) { w.petSetMode(id.substr(4)); PW_.ai = false; return; }
  if (id.rfind("p:tab:", 0) == 0) { PW_.tab = std::atoi(id.c_str() + 6); PW_.tree = -1; w.sfx("skill_pageflip", 0.5); return; }
  if (id.rfind("p:sk:", 0) == 0) { PW_.skd = std::atoi(id.c_str() + 5); return; }
  if (id.rfind("p:tr:", 0) == 0) { const int i = std::atoi(id.c_str() + 5); PW_.tree = PW_.tree == i ? -1 : i; return; }
  if (!p) return;
  if (id == "p:on") { if (w.P.petOn == p->uid) w.petDismiss(); else w.petSummon(p->uid); return; }
  if (id == "p:ai") { PW_.ai = !PW_.ai; return; }
  if (id == "p:tf") { openPetF(w, "tf", p->uid); return; }
  if (id == "p:feed") {
    if (!w.countItem("30022")) { w.toast("Biluo Meyven yok (Hayvan Terbiyecisi satar)."); return; }
    if (w.P.petOn != p->uid) { w.toast("Beslemek için önce çağır."); return; }
    w.useItem("30022"); return;
  }
  if (id == "p:rel") { const std::string uid = p->uid; ask(w.petName(*p) + " serbest bırakılsın mı? Geri dönmez.", [&w, this, uid] { w.petRelease(uid); PW_.i = 0; }); }
}

// ---------------- dönüşüm (幻化) / beceri aktarma (技能转移) ----------------
void Win::openPetF(World& w, const std::string& mode, const std::string& main) {
  open(w, "petf"); TF_.mode = mode; PetRec* m = main.empty() ? nullptr : w.petByUid(main);
  TF_.main = m && w.petResting(m) ? main : ""; TF_.mat.clear(); TF_.a[0].clear(); TF_.a[1].clear();
}
void Win::drawPetF(engine::Canvas& c, World& w, float vw, float VH) {
  const std::string f = "n_fantasize_pet"; const float k = std::min(VH / 330, vw / 495); const bool sk = TF_.mode == "sk";
  PetRec* m = TF_.main.empty() ? nullptr : w.petByUid(TF_.main); PetRec* s = TF_.mat.empty() ? nullptr : w.petByUid(TF_.mat);
  for (auto& a : TF_.a) if (!a.empty() && w.countItem(a) <= 0) a.clear();
  const Xf xf = begin(k, std::round((vw - 481 * k) / 2), std::round((VH - 320 * k) / 2));
  nDraw(c, xf, f, 50696, false); hit(xf, "frame", 0, 0, 481, 320); nDraw(c, xf, f, 50869, false); nDraw(c, xf, f, 50721, false);
  { const auto r = rect(f, 50720); nDraw(c, xf, f, 50720, on("f:x")); hit(xf, "f:x", r[0] + 10, r[1], 40, 40); }
  auto slot = [&](const std::string& key, int id, std::function<void(const std::vector<float>&)> fill) {
    const auto r = rect(f, id); nDraw(c, xf, f, id, on("f:" + key));
    if (fill) { c.fillRect(xf.X(r[0] + 5), xf.Y(r[1] + 5), (r[2] - 10) * k, (r[3] - 10) * k, 0xd9c59c); fill(r); }
    hit(xf, "f:" + key, r[0], r[1], r[2], r[3]);
  };
  slot("main", 50697, m ? std::function<void(const std::vector<float>&)>([&](const std::vector<float>& r) { petSprite(c, w, xf, w.petForm(*m).look, r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10, 0.34f); }) : nullptr);
  slot("mat", 50698, s ? std::function<void(const std::vector<float>&)>([&](const std::vector<float>& r) { petSprite(c, w, xf, w.petForm(*s).look, r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10, 0.34f); }) : nullptr);
  for (int i = 0; i < 2; i++) {
    const std::string a = TF_.a[i];
    slot(i ? "a1" : "a0", i ? 50699 : 50700, a.empty() ? nullptr : std::function<void(const std::vector<float>&)>([&, a](const std::vector<float>& r) { const engine::Item* it = w.balance().item(a); if (it) icon(c, xf, it->ik, it->icon, r[0] + 5, r[1] + 5, r[2] - 10); }));
  }
  std::vector<std::string> aids; for (const auto& a : TF_.a) if (!a.empty()) aids.push_back(a);
  const World::PetTf info = sk ? w.petSkInfo(m, s, aids) : w.petTfInfo(m, s, aids);
  { const auto r = rect(f, 50701); nDraw(c, xf, f, 50701, false);
    if (!sk && m && info.next) { c.fillRect(xf.X(r[0] + 5), xf.Y(r[1] + 5), (r[2] - 10) * k, (r[3] - 10) * k, 0xd9c59c); petSprite(c, w, xf, w.balance().pets.by(m->sp)->forms[size_t(info.next)].look, r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10, 0.3f); }
    else if (sk && info.ok && info.gs >= 0) { c.fillRect(xf.X(r[0] + 5), xf.Y(r[1] + 5), (r[2] - 10) * k, (r[3] - 10) * k, 0xd9c59c); auto it = w.balance().pets.skills.find(s->sk[size_t(info.gs)]); if (it != w.balance().pets.skills.end() && it->second.icon) icon(c, xf, "skill", it->second.icon, r[0] + 5, r[1] + 5, r[2] - 10); } }
  auto lab = [&](int id, const std::string& t, uint32_t col) { const auto r = rect(f, id); F_.text(c, xf, t, r[0], r[1] + r[3] / 2, col, 9.5f, LEFT, 110); };
  lab(50712, m ? w.petName(*m) + " Sv" + I(m->lv) + " · " + I(m->st) + "/7" : "Ana hayvan", 0x3a1c08);
  lab(50713, s ? w.petName(*s) + " Sv" + I(s->lv) + " · " + I(s->st) + "/7" : "Yardımcı hayvan", 0x3a1c08);
  lab(50715, TF_.a[0].empty() ? "Yardımcı eşya" : w.itemName(TF_.a[0]), 0x5a3a18);
  lab(50714, TF_.a[1].empty() ? "Yardımcı eşya" : w.itemName(TF_.a[1]), 0x5a3a18);
  if (!sk && info.next) { const auto r = rect(f, 50737); F_.text(c, xf, "Düzey " + I(m ? m->st : 0) + " → " + I(info.next), r[0] + 30, r[1] + 3, 0x7a1c08, 9.5f, CENTER, 90); }
  const bool hasCost = info.cost || (!sk && info.next) || (sk && info.ok);
  { const auto r = rect(f, 50716); nDraw(c, xf, f, 50716, false); F_.text(c, xf, hasCost ? I(info.cost) + " altın" : "-", r[0] + 22, r[1] + 9, w.P.gold >= info.cost ? 0xffe9a8 : 0xff6040, 10, LEFT, 92); }
  { const auto r = rect(f, 50719); nDraw(c, xf, f, 50719, on("f:go")); F_.text(c, xf, sk ? "Aktar" : "Dönüştür", r[0] + r[2] / 2, r[1] + r[3] / 2, info.ok ? 0xf4ead0 : 0xa09080, 11, CENTER); hit(xf, "f:go", r[0], r[1], r[2], r[3]); }
  { const auto r = rect(f, 50736); nDraw(c, xf, f, 50736, on("f:shop")); hit(xf, "f:shop", r[0], r[1], r[2], r[3]); }
  // sağ balon: kip sekmeleri + açıklama
  for (int i = 0; i < 2; i++) { const float x = 250 + float(i) * 104; const bool a = (i == 1) == sk; F_.text(c, xf, i ? "Beceri Aktarma" : "Dönüşüm", x + 50, 34, a ? 0x7a1c08 : 0x8a6a40, 11.5f, CENTER, 100); if (a) c.fillRect(xf.X(x + 12), xf.Y(42), 76 * k, 1.5f * k, 0x7a1c08); hit(xf, i ? "f:mode:sk" : "f:mode:tf", x, 24, 100, 22); }
  std::vector<std::string> T;
  if (!sk) {
    if (m && info.next) { const auto& fm = w.balance().pets.by(m->sp)->forms[size_t(info.next)]; T.push_back("Sonraki biçim: " + fm.tr + " (Sv " + I(info.need) + ")"); }
    T.push_back(info.ok ? "Başarı şansı: %" + jsNum(info.chance) + (info.keep ? " · başarısızlıkta düzey korunur" : "") : info.why);
    T.push_back("Başarıda düzey +1, görünüş ve nitelikler değişir; başarısızlıkta düzey −1. Yardımcı hayvan her durumda kaybolur.");
  } else {
    auto names = [&](const std::vector<std::string>& v) { std::string o; for (const auto& x : v) o += (o.empty() ? "" : ", ") + w.petSkName(x); return o; };
    if (m) { const std::string n = names(m->sk); T.push_back("Ana: " + (n.empty() ? std::string("rastgele becerisi yok") : n)); }
    if (s) { const std::string n = names(s->sk); T.push_back("Yardımcı: " + (n.empty() ? std::string("rastgele becerisi yok") : n)); }
    T.push_back(info.ok ? std::string("Yardımcının ") + (info.gs >= 0 ? "seçilen" : "rastgele bir") + " becerisi ana hayvanın " + (info.ls >= 0 ? "seçilen" : "rastgele bir") + " becerisinin yerine geçer." : info.why);
    T.push_back("Yalnız aynı türden hayvanlar. Yardımcı hayvan kaybolur.");
  }
  float y = 56;
  for (const auto& t : T) { auto W = F_.wrap(t, 206, 9.5f); for (size_t i = 0; i < W.size() && i < 4; i++) { if (y > 168) break; F_.text(c, xf, W[i], 252, y, 0x3a2a10, 9.5f, LEFT, 210); y += 12; } }
}
void Win::tapPetF(World& w, const std::string& id) {
  auto L = w.petList();
  auto cyc = [](const std::vector<std::string>& c, const std::string& cur) -> std::string { if (c.empty()) return ""; auto it = std::find(c.begin(), c.end(), cur); if (it == c.end()) return c[0]; ++it; return it == c.end() ? std::string() : *it; };
  if (id == "f:x") { close(); return; }
  if (id.rfind("f:mode:", 0) == 0) { TF_.mode = id.substr(7); TF_.a[0].clear(); TF_.a[1].clear(); w.sfx("skill_pageflip", 0.5); return; }
  if (id == "f:main") {
    std::vector<std::string> c; for (PetRec* x : L) if (w.petResting(x)) c.push_back(x->uid);
    if (c.empty()) { w.toast("Dinlenen hayvanın yok (çağrılmış hayvanı geri çağır)."); return; }
    std::string n = cyc(c, TF_.main); TF_.main = n.empty() ? c[0] : n; if (TF_.mat == TF_.main) TF_.mat.clear(); return;
  }
  if (id == "f:mat") {
    std::vector<std::string> c; for (PetRec* x : L) if (w.petResting(x) && x->uid != TF_.main) c.push_back(x->uid);
    if (c.empty()) { w.toast("Yardımcı olabilecek başka dinlenen hayvanın yok."); return; }
    TF_.mat = cyc(c, TF_.mat); return;
  }
  if (id == "f:a0" || id == "f:a1") {
    const int i = id == "f:a1" ? 1 : 0; std::vector<std::string> c;
    for (const char* a : AIDS) { const engine::Item* it = w.balance().item(a); if (!it || !it->pet) continue; const bool kind = TF_.mode == "tf" ? it->petJ["tf"].truthy() : it->petJ["sk"].truthy(); if (kind && w.countItem(a) > 0 && (a != TF_.a[1 - i] || w.countItem(a) > 1)) c.push_back(a); }
    if (c.empty()) { w.toast("Yardımcı eşyan yok (Büyülü Canavar Ustası satar)."); return; }
    TF_.a[i] = cyc(c, TF_.a[i]); return;
  }
  if (id == "f:shop") { close(); openShop(w, "魔法兽强化大师"); return; }
  if (id == "f:go") {
    PetRec* m = w.petByUid(TF_.main); PetRec* s = w.petByUid(TF_.mat); const bool sk = TF_.mode == "sk";
    std::vector<std::string> aids; for (const auto& a : TF_.a) if (!a.empty()) aids.push_back(a);
    const World::PetTf info = sk ? w.petSkInfo(m, s, aids) : w.petTfInfo(m, s, aids);
    if (!info.ok) { w.toast(info.why); return; }
    const std::string mn = w.petName(*m), sn = w.petName(*s), mu = TF_.main, su = TF_.mat;
    ask(sk ? sn + " kaybolacak ve becerisi " + mn + "'e geçecek. Emin misin?" : sn + " kaybolacak. Başarı şansı %" + jsNum(info.chance) + ". Dönüştürülsün mü?",
        [&w, this, sk, mu, su, aids] { if (sk) w.petTransfer(mu, su, aids); else w.petTransform(mu, su, aids); TF_.mat.clear(); });
  }
}

}  // namespace ui
