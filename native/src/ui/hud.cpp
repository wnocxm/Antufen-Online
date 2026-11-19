#include "hud.h"

#include <algorithm>
#include <cctype>
#include <cmath>

namespace ui {

using engine::Ent;
using engine::World;

const core::Image* Hud::image(const std::string& path) {
  auto it = img_.find(path);
  if (it == img_.end()) {
    std::unique_ptr<core::Image> im;
    try { if (as_.vfs().exists(path)) im = std::make_unique<core::Image>(core::decodePNG(as_.vfs().read(path))); } catch (...) { im.reset(); }
    it = img_.emplace(path, std::move(im)).first;
  }
  return it->second.get();
}

// HTML text(): siyah dış çizgi (lineWidth 2,5, yuvarlak) üstüne dolgu
void Hud::text(engine::Canvas& c, const std::string& fam, float size, const std::string& s, float x, float y, uint32_t col, Align a, float alpha, float lw) {
  TextStyle st; st.color = col; st.align = a; st.outline = lw; st.alpha = alpha; st.fakeBold = fam == "H";   // HUD'daki başlık yazıları hep kalın (bold FH)
  font_.draw(c, fam, size, engine::tx(s), x, y, st);   // HTML ui.js text(): s = tx(s)
}

static float clamp01(float v) { return v < 0 ? 0 : v > 1 ? 1 : v; }
static std::string cut(const std::string& s, size_t n) {   // JS slice(0, n) (kod noktası)
  const auto cp = utf8(s); if (cp.size() <= n) return s;
  std::string o; for (size_t i = 0; i < n; i++) { const uint32_t c = cp[i];
    if (c < 0x80) o += char(c); else if (c < 0x800) { o += char(0xC0 | (c >> 6)); o += char(0x80 | (c & 63)); }
    else if (c < 0x10000) { o += char(0xE0 | (c >> 12)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); }
    else { o += char(0xF0 | (c >> 18)); o += char(0x80 | ((c >> 12) & 63)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); } }
  return o;
}

// ---------------- dünya üstü: adlar, görev işaretleri, can çubukları, uçan sayılar (HTML drawWorld sonu) ----------------
void Hud::drawNames(engine::Canvas& c, World& w, bool advance) {
  const double ox = engine::jsRound(w.camX - vw_ / 2), oy = engine::jsRound(w.camY - engine::VH / 2);
  const auto& Q = w.quests();
  for (size_t i = 0; i < w.ents.size(); i++) {
    Ent& e = w.ents[i];
    const float X = float(w.map.px(e.x, e.y) - ox), Y = float(w.map.py(e.x, e.y) - oy);
    if (X < -60 || X > vw_ + 60 || Y < -20 || Y > engine::VH + 100) continue;
    if (e.kind == Ent::NPC && !e.hidden && (!e.dummy || e.node)) {
      const char mk = w.npcMark(e.name);
      if (!e.pickup) text(c, "B", 10, Q.name(e.name), X, Y - 62, 0x9cf58a, CENTER);
      if (mk) text(c, "S", 18, std::string(1, mk), X, Y - 74 + float(std::sin(w.time * 4) * 2), 0xffd23a, CENTER);
      if (e.pickup) {   // toplama görevinin noktası: parlayan yıldız
        bool on = false; for (const engine::Quest& q : Q.all()) { if (q.type != "pickup" || q.node != e.name) continue; auto it = w.P.quests.find(q.id); if (it != w.P.quests.end() && !it->second.ready) { on = true; break; } }
        if (on) text(c, "S", 14, "✦", X, Y - 30 + float(std::sin(w.time * 5) * 2), 0xffe060, CENTER);
      }
    } else if (e.kind == Ent::MOB && !e.dead) {
      const bool show = int(i) == w.target() || e.aggro || e.d->rank || e.hp < e.maxHp;
      if (show) {
        const uint32_t col = e.d->rank == 2 ? 0xe890ff : e.d->rank ? 0xffb050 : e.d->lv > w.P.lv + 3 ? 0xff6040 : 0xf0e0d0;
        text(c, "B", 10, Q.name(e.name) + " Sv" + std::to_string(e.d->lv), X, Y - 58, col, CENTER);
        c.fillRect(X - 16, Y - 54, 32, 3, 0x000000); c.fillRect(X - 16, Y - 54, 32 * float(std::max(0.0, e.hp / e.maxHp)), 3, 0xd02010);
      }
    }
  }
  { const float X = float(w.map.px(w.player.x, w.player.y) - ox), Y = float(w.map.py(w.player.x, w.player.y) - oy);
    if (!(X < -60 || X > vw_ + 60 || Y < -20 || Y > engine::VH + 100)) text(c, "B", 10, w.P.name, X, Y - 64, 0xffe48a, CENTER); }
  if (w.pet.on) if (engine::PetRec* p = w.petActive()) {   // evcil hayvan: ad + seviye, can çubuğu, konuşma balonu
    const float X = float(w.map.px(w.pet.x, w.pet.y) - ox), Y = float(w.map.py(w.pet.x, w.pet.y) - oy);
    if (!(X < -60 || X > vw_ + 60 || Y < -20 || Y > engine::VH + 100)) {
      const auto st = w.petStats(*p);
      text(c, "B", 10, w.petName(*p) + " Sv" + std::to_string(p->lv), X, Y - 52, 0x8fe3ff, CENTER);
      c.fillRect(X - 14, Y - 48, 28, 3, 0x000000); c.fillRect(X - 14, Y - 48, 28 * float(std::max(0.0, p->hp / st.hp)), 3, 0x30c040);
      if (w.pet.sayT > 0) bubble(c, w.pet.say, X, Y - 62, float(w.pet.sayT));
    }
  }
  // uçan sayılar: 1,1 sn yükselir, son 0,3 sn'de solar
  for (int i = int(w.floats.size()) - 1; i >= 0; i--) {
    World::FloatText& f = w.floats[size_t(i)];
    if (advance) f.t += 1.f / 60;
    if (f.t > 1.1f) { w.floats.erase(w.floats.begin() + i); continue; }
    const double ex = f.ent == -2 ? w.player.x : f.ent == -3 ? w.pet.x : w.ents[size_t(f.ent)].x, ey = f.ent == -2 ? w.player.y : f.ent == -3 ? w.pet.y : w.ents[size_t(f.ent)].y;
    const float X = float(w.map.px(ex, ey) - ox), Y = float(w.map.py(ex, ey) - oy - 50 - f.t * 26);
    text(c, "Bb", std::round(12 * f.s), f.txt, X, Y, f.c, CENTER, f.t < 0.8f ? 1 : (1.1f - f.t) / 0.3f);
  }
}

// konuşma balonu (HTML ui.js bubble): 130 px'e sarılır, en çok 4 satır; açık parşömen kutu, koyu kenar, alta küçük üçgen
void Hud::bubble(engine::Canvas& c, const std::string& s, float x, float y, float t) {
  const float a = std::min(1.f, t); std::vector<std::string> lines; std::string ln; size_t b = 0;
  while (true) { const size_t sp = s.find(' ', b); const std::string w = s.substr(b, sp == std::string::npos ? std::string::npos : sp - b); const std::string n = ln.empty() ? w : ln + " " + w;
    if (font_.width("B", 10, n) > 130 && !ln.empty()) { lines.push_back(ln); ln = w; } else ln = n; if (sp == std::string::npos) break; b = sp + 1; }
  if (!ln.empty()) lines.push_back(ln);
  if (lines.size() > 4) lines.resize(4);
  float mw = 0; for (const auto& l : lines) mw = std::max(mw, font_.width("B", 10, l));
  const float w = std::min(140.f, mw) + 10, h = float(lines.size()) * 12 + 6, bx = std::round(x - w / 2), by = std::round(y - h);
  c.fillRect(bx, by, w, h, 0xfaf4e2, 0.92f * a); c.strokeRect(bx + 0.5f, by + 0.5f, w - 1, h - 1, 1, 0x6a5030, a);
  for (int py = int(by + h); py < int(by + h + 5) + 1; py++) for (int px = int(x - 5); px <= int(x + 5); px++) {   // üçgen (4×4 alt örnek)
    int n = 0; for (int sy = 0; sy < 4; sy++) for (int sx = 0; sx < 4; sx++) { const float X = px + (sx + 0.5f) / 4, Y = py + (sy + 0.5f) / 4 - (by + h); n += Y >= 0 && Y <= 5 && std::fabs(X - x) <= 4 * (1 - Y / 5); }
    if (n) c.blend(px, py, 0xfaf4e2, 0.92f * a * n / 16.f);
  }
  for (size_t i = 0; i < lines.size(); i++) text(c, "B", 10, lines[i], x, by + 13 + float(i) * 12, 0x2a1a0a, CENTER, a, 0);
}

// ---------------- küçük harita (HTML drawMinimap): zemin 0,18 ölçekte, kişiler/canavarlar nokta, geçitler mor ----------------
void Hud::drawMinimap(engine::Canvas& c, World& w, float x, float y, float W, float H) {
  const float k = 0.18f;
  if (mmGen_ != w.sceneGen || mm_.empty()) {   // önbellek (sahne başına): zemin yumuşatılarak küçültülür (tarayıcıdaki gibi)
    mmGen_ = w.sceneGen; engine::Canvas t; t.resize(std::max(1, int(w.map.pw * k)), std::max(1, int(w.map.ph * k)));
    t.drawImage(w.map.ground, 0, 0, float(w.map.ground.w), float(w.map.ground.h), 0, 0, float(t.w()), float(t.h()), 1, true);
    mm_ = t.img;
  }
  c.fillRect(x, y, W, H, 0x000000); c.clipRect(x, y, W, H);
  const float cx = float(w.map.px(w.player.x, w.player.y)) * k, cy = float(w.map.py(w.player.x, w.player.y)) * k;
  c.drawImage(mm_, 0, 0, float(mm_.w), float(mm_.h), x + W / 2 - cx, y + H / 2 - cy, float(mm_.w), float(mm_.h));
  auto dot = [&](double ex0, double ey0, uint32_t col, float s) { const float ex = x + W / 2 + (float(w.map.px(ex0, ey0)) * k - cx), ey = y + H / 2 + (float(w.map.py(ex0, ey0)) * k - cy); c.fillRect(ex - 1, ey - 1, s, s, col); };
  for (const Ent& e : w.ents) { if (e.dead || e.hidden || e.kind == Ent::GONE) continue; dot(e.x, e.y, e.kind == Ent::NPC ? (w.npcMark(e.name) ? 0xffd23a : 0x60e070) : 0xff4030, 2); }
  dot(w.player.x, w.player.y, 0xffffff, 3);
  for (const auto& r : w.map.regions) {
    if (r.size() < 6 || r[1] != 1) continue;
    const float X = float(w.map.px((r[2] + r[4]) / 2.0, (r[3] + r[5]) / 2.0)) * k, Y = float(w.map.py((r[2] + r[4]) / 2.0, (r[3] + r[5]) / 2.0)) * k;
    c.fillRect(x + W / 2 + X - cx - 2, y + H / 2 + Y - cy - 2, 4, 4, 0xb080ff);
  }
  c.clearClip();
}

// ---------------- görev takibi (HTML drawTracker): ilk 3 görev ve ilerlemesi; görev yoksa sıradaki görevi veren ----------------
void Hud::drawTracker(engine::Canvas& c, World& w) {
  const auto& Q = w.quests().all(); float y = 86; int n = 0;
  for (size_t qi = 0; qi < Q.size() && n < 3; qi++) {
    const engine::Quest& q = Q[qi]; auto it = w.P.quests.find(q.id); if (it == w.P.quests.end()) continue; n++;
    const engine::QuestSt& st = it->second;
    text(c, "Bb", 9, q.tr.title, 6, y, 0xffd23a); y += 10;
    std::string prog;
    if (w.questState(int(qi)) == "ready") prog = "Tamam: " + w.quests().name(q.to) + " ile konuş";
    else if (q.type == "deliver") prog = q.tr.item + ": " + std::to_string(w.giveCount(q)) + "/" + std::to_string(q.count);
    else if (q.type == "kill") {
      if (!q.targets.empty()) { for (size_t k = 0; k < q.targets.size(); k++) { const auto& x = q.targets[k]; auto cc = st.c.find(x.key()); prog += (k ? " · " : "") + w.quests().name(x.key()) + " " + std::to_string(cc == st.c.end() ? 0 : cc->second) + "/" + std::to_string(x.n); } }
      else prog = w.quests().name(q.target) + ": " + std::to_string(st.n) + "/" + std::to_string(q.count);
    } else if (q.type == "collect" || q.type == "pickup") prog = q.tr.item + ": " + std::to_string(st.n) + "/" + std::to_string(q.count);
    else prog = q.tr.goal;
    if (utf8(prog).size() > 44) prog = cut(prog, 43) + "…";
    text(c, "B", 8.5f, prog, 8, y, st.ready ? 0x9cf58a : 0xe8e0d0); y += 12;
  }
  if (!n) for (size_t qi = 0; qi < Q.size(); qi++) if (w.questState(int(qi)) == "new") { text(c, "B", 8.5f, "! " + w.quests().name(Q[qi].giver) + " sana görev verecek", 6, y, 0xffd23a); break; }
  hud_.push_back({0, 76, 180, std::max(20.f, y - 76), [this] { request = "quest"; }});
}

// kısayol yuvasının içi (HTML drawSlot): beceri simgesi (öğrenilmemişse kilit, beklemede dolan karartma, mana yetmezse mavi) ya da eşya
// (adet). k: ölçek (yuva 32 birim)
void Hud::drawSlot(engine::Canvas& c, World& w, const std::string& sl, float x, float y, float k) {
  if (sl.empty()) return;
  auto R = [&](float a, float b, float W, float H, uint32_t col, float al) { c.fillRect(x + a * k, y + b * k, W * k, H * k, col, al); };
  if (sl[0] == 's') {
    const auto& L = w.skills(); const int i = std::atoi(sl.c_str() + 1); if (i < 0 || i >= int(L.size())) return;
    const engine::SkillDef& sk = L[size_t(i)];
    const std::string ik = (*sk.d)["ik"].isStr() ? (*sk.d)["ik"].str() : "skill";
    if (const core::Image* im = image("ui/icon_res_" + ik + "_" + std::to_string((*sk.d)["icon"].i()) + ".png")) c.drawImage(*im, 0, 0, float(im->w), float(im->h), x, y, 32 * k, 32 * k);
    if (!w.skRank(sk)) {
      R(0, 0, 32, 32, 0x000000, 0.7f);
      const std::string L2 = w.skLock(sk);
      if (!L2.empty()) text(c, "N", 8 * k, L2 == "adv" ? "40 ★" : "🔒", x + 16 * k, y + 20 * k, 0xcccccc, CENTER, 1, 2.5f * k);
      return;
    }
    auto cd = w.player.cds.find(sk.id);
    if (cd != w.player.cds.end() && cd->second > 0) { const float f = float(cd->second / sk.cd); R(0, 32 * (1 - f), 32, 32 * f, 0x000000, 0.65f); text(c, "Nb", 11 * k, std::to_string(int(std::ceil(cd->second))), x + 16 * k, y + 21 * k, 0xffffff, CENTER, 1, 2.5f * k); }
    if (w.player.mp < sk.mp) R(0, 0, 32, 32, 0x001e78, 0.45f);
  } else {
    const std::string id = sl.substr(2); const engine::Item* it = w.balance().item(id); if (!it) return;
    if (const core::Image* im = image("ui/icon_res_item_" + std::to_string(it->icon) + ".png")) c.drawImage(*im, 0, 0, float(im->w), float(im->h), x, y, 32 * k, 32 * k);
    text(c, "Bb", 9 * k, std::to_string(w.countItem(id)), x + 31 * k, y + 31 * k, 0xffffff, RIGHT, 1, 2.5f * k);
  }
}

void Hud::attack(World& w) {
  int t = w.target();
  if (!(t >= 0 && w.ents[size_t(t)].kind == Ent::MOB && !w.ents[size_t(t)].dead)) t = w.nearestMob(9);
  if (t >= 0) w.setTarget(t, true); else w.note("Yakında hedef yok.");
}
void Hud::quick(World& w, int i) {
  if (i < 0 || i >= int(w.P.quick.size())) return;
  const std::string& sl = w.P.quick[size_t(i)]; if (sl.empty()) return;
  if (sl[0] == 's') w.useSkill(std::atoi(sl.c_str() + 1)); else w.useItem(sl.substr(2));
}

// ---------------- HUD (HTML drawHud) ----------------
// HUD isteği ve dünyadan gelenler: pencere aç, kişiye yürü/konuş, ölüm penceresi
void Hud::handle(World& w) {
  if (!request.empty()) {
    const std::string r = request; request.clear();
    if (r.rfind("talk:", 0) == 0) w.talkTo(std::atoi(r.c_str() + 5));
    else if (r == "hub") win.open(w, "hub");
    else if (r == "quest") { win.close(); win.open(w, "task"); }
    else if (r == "char") { win.close(); win.open(w, "role"); }
    else if (r == "bag") { win.close(); win.open(w, "bag"); }
    else if (r == "skill") { win.close(); win.open(w, "skill"); }
    else if (r == "map") { win.close(); win.open(w, "map"); }
    else if (r == "sys") { win.close(); win.open(w, "sys"); }
    else w.toast("Bu pencere yakında.");
  }
  if (win.gmReq) { win.gmReq = false; if (w.isGM()) { closeAll(); gm.open(); } }   // ana menünün GM düğmesi (HTML UI.open('gm'))
  if (!gm.req.empty()) {   // GM paneli: hepsini kapat, gerekirse pencere aç (HTML closeAll + Win.open)
    const std::string r = gm.req; gm.req.clear(); closeAll();
    if (r == "pet") win.open(w, "pet"); else if (r == "petf:tf") win.openPetF(w, "tf"); else if (r == "petf:sk") win.openPetF(w, "sk");
  }
  if (!w.askText.empty()) { win.ask(w.askText, w.askYes); w.askText.clear(); w.askYes = nullptr; }   // oyun kodunun onay isteği (zindan kapısı, sandık)
  if (!win.assignReq.empty()) { assign_ = win.assignReq; w.toastMsg = engine::tx("Bir yuvaya dokun") + ": " + win.assignName; w.toastT = 3; win.assignReq.clear(); win.close(); }
  if (w.dialogEnt >= 0) { win.close(); win.open(w, "npc", w.dialogEnt, w.dialogSay, true); w.dialogEnt = -1; w.dialogSay.clear(); }
  if (w.died) { w.died = false; win.close(); deathAt = now + 1.2; }
  if (deathAt >= 0 && now >= deathAt) { deathAt = -1; if (w.player.dead) win.open(w, "dead"); }
}

void Hud::draw(engine::Canvas& c, World& w, bool advance) {
  vw_ = float(c.w()); hud_.clear(); win.safeL = safeL;
  handle(w);
  const float VH = float(engine::VH);
  // yeni günlük satırları zaman damgasıyla
  { const size_t nw = std::min(w.logTotal - seen_, w.log.size()); for (size_t k = w.log.size() - nw; k < w.log.size(); k++) logs_.push_back({w.log[k].m, w.log[k].c, now}); seen_ = w.logTotal; if (logs_.size() > 30) logs_.erase(logs_.begin(), logs_.end() - 30); }
  drawNames(c, w, advance);
  const engine::Stats s = w.stats(); engine::CharData& P = w.P; engine::Player& p = w.player;
  // sol üst: portre (orijinal FORM_HEADIMG: 7143 çerçevesi, 32x32 portre; 1,25 büyütülmüş), ad ve ince can/mana/tecrübe çizgileri
  { const float hk = 1.25f, hx = 3, hy = 3;
    if (const core::Image* hf = image("ui/AnbufenUI_Resource_7143.png")) c.drawImage(*hf, 0, 0, float(hf->w), float(hf->h), hx + 2 * hk, hy + 2 * hk, 40 * hk, 38 * hk);
    if (const core::Image* po = image("ui/Portrait_" + P.face + ".png")) c.drawImage(*po, 0, 0, float(po->w), float(po->h), hx + 6 * hk, hy + 6 * hk, 32 * hk, 30 * hk);
    c.fillRect(hx + 26 * hk, hy + 29 * hk, 14 * hk, 10 * hk, 0x000000, 0.75f);
    text(c, "Bb", 8 * hk, std::to_string(P.lv), hx + 33 * hk, hy + 37 * hk, 0xffe48a, CENTER, 1, 2.5f * hk);
    const float bx0 = hx + 44 * hk + 2;
    text(c, "Bb", 10, P.name, bx0, 14, 0xffe48a);
    auto thin = [&](float yy, float v, uint32_t col) { c.fillRect(bx0, yy, 92, 5, 0x000000, 0.7f); c.fillRect(bx0 + 1, yy + 1, 90 * clamp01(v), 3, col); };
    thin(18, float(p.hp / s.hp), 0xe02818); thin(25, float(p.mp / s.mp), 0x2a58e8); thin(32, float(double(P.xp) / double(w.balance().xpNeed(P.lv))), 0xd8b030);
    text(c, "B", 8, std::to_string(int(std::ceil(p.hp))) + "/" + std::to_string(int(s.hp)), bx0 + 96, 23, 0xffb0a0);
    text(c, "B", 8, std::to_string(int(std::floor(p.mp))) + "/" + std::to_string(int(s.mp)), bx0 + 96, 31, 0xa8c0ff);
    // "Karakter" düğmesi (soldaki sekmeli menüyü açar)
    const float kx = 3, ky = 56, kw = 54, kh = 15;
    c.fillRect(kx, ky, kw, kh, 0x000000, 0.7f); c.strokeRect(kx + 0.5f, ky + 0.5f, kw - 1, kh - 1, 1, 0x8a6a30);
    text(c, "H", 9, "Karakter ▸", kx + kw / 2, ky + 11, 0xffe48a, CENTER);
    hud_.push_back({kx - 2, ky - 2, kw + 4, kh + 6, [this] { request = "hub"; }});
    hud_.push_back({2, 2, 56, 52, [this] { request = "hub"; }}); }
  // hedef
  { const int ti = w.target();
    if (ti >= 0) {
      const Ent& t = w.ents[size_t(ti)];
      if (t.kind == Ent::NPC && !t.hidden) {
        const float W = 150, x = float(engine::jsRound(vw_ / 2 - W / 2)), y = 4;
        c.fillRect(x, y, W, 20, 0x000000, 0.72f); c.strokeRect(x + 0.5f, y + 0.5f, W - 1, 19, 1, 0x4a8a3a);
        text(c, "Bb", 10, w.quests().name(t.name), vw_ / 2, y + 14, 0x9cf58a, CENTER);
      } else if (t.kind == Ent::MOB && !t.dead) {
        const float W = 170, x = float(engine::jsRound(vw_ / 2 - W / 2)), y = 4;
        const uint32_t col = t.d->rank == 2 ? 0xe890ff : t.d->rank ? 0xffb050 : t.d->lv > P.lv + 3 ? 0xff6040 : 0xf0e0d0;
        c.fillRect(x, y, W, 30, 0x000000, 0.72f);
        c.fillRect(x, y, W, 1, 0x9f998f); c.fillRect(x, y + 29, W, 1, 0x9f998f); c.fillRect(x, y + 1, 1, 28, 0x4b4547); c.fillRect(x + W - 1, y + 1, 1, 28, 0x4b4547);
        text(c, "Bb", 10, w.quests().name(t.name), x + 6, y + 12, col);
        text(c, "Bb", 9, "Sv" + std::to_string(t.d->lv), x + W - 6, y + 12, 0xffe48a, RIGHT);
        c.fillRect(x + 6, y + 17, W - 12, 7, 0x000000, 0.8f); c.fillRect(x + 7, y + 18, (W - 14) * clamp01(float(t.hp / t.maxHp)), 5, 0xe02818);
        text(c, "B", 7, std::to_string(int(std::max(0.0, std::ceil(t.hp)))) + "/" + std::to_string(int(t.maxHp)), vw_ / 2, y + 24, 0xffffff, CENTER);
      }
    } }
  // sağ üst: küçük harita (çerçeve ve yuvarlak düğmeler Android sürümünün görselleri)
  { const float mw = 92, mh = 86, mx = vw_ - mw - 3, my = 3;
    drawMinimap(c, w, mx + 5, my + 5, mw - 10, mh - 10);
    if (const core::Image* fr = image("ui2/hud_frame.png")) c.drawImage(*fr, 0, 0, float(fr->w), float(fr->h), mx, my, mw, mh, 1, true);
    text(c, "H", 9.5f, w.quests().name(w.sceneName), mx + mw / 2, my + 17, 0xff9a30, CENTER);
    text(c, "B", 8.5f, "(" + std::to_string(int(engine::jsRound(p.x))) + ", " + std::to_string(int(engine::jsRound(p.y))) + ")", mx + mw / 2, my + mh - 9, 0xffb060, CENTER);
    hud_.push_back({mx, my, mw, mh, [this] { request = "map"; }});
    static const char* B[6][2] = {{"Karakter", "char"}, {"Çanta", "bag"}, {"Beceri", "skill"}, {"Görev", "quest"}, {"Harita", "map"}, {"Ayarlar", "sys"}};
    // HTML: tx(ad)[0] büyük harf (Türkçede K Ç B G H A, İngilizcede C B S Q M S)
    auto initial = [](const std::string& s) { std::string t = engine::tx(s); size_t n = 1; while (n < t.size() && (uint8_t(t[n]) & 0xC0) == 0x80) n++; std::string a = t.substr(0, n); if (a.size() == 1) a[0] = char(std::toupper((unsigned char)a[0])); return a; };
    const core::Image* bi = image("ui2/hud_btn.png"); const float d = 34;
    for (int i = 0; i < 6; i++) {
      const float cx = mx - 22 - (1 - i % 2) * 38, cy = 20 + float(i / 2) * 37;
      if (bi) c.drawImage(*bi, 48, 0, 48, 48, cx - d / 2, cy - d / 2, d, d, 1, true);
      TextStyle st; st.align = CENTER; st.outline = 3; st.outlineColor = 0x5a1c00; st.gradient = true; st.color = 0xfff6c0; st.color2 = 0xf0b040; st.gy0 = cy - 8; st.gy1 = cy + 7;
      font_.draw(c, "S", 17, initial(B[i][0]), cx, cy + 6, st);
      const std::string req = B[i][1]; hud_.push_back({cx - d / 2 - 1, cy - d / 2 - 1, d + 2, d + 2, [this, req] { request = req; }});
    } }
  drawTracker(c, w);
  // sol alt: ejderha madalyonu = yürüme kolu (orijinal FORM_ROCKER), turuncu küre (7005) ışık olarak
  { const double Rx = rockerX(), Ry = rockerY();
    if (const core::Image* dm = image("ui/AnbufenUI_Resource_7002.png")) c.drawImage(*dm, 0, 0, float(dm->w), float(dm->h), Rx - 66 * HS, Ry - 67 * HS, 132 * HS, 134 * HS);
    const double kx = Rx + (joy_.on ? joy_.dx : 0), ky = Ry + (joy_.on ? joy_.dy : 0);
    if (const core::Image* kn = image("ui/AnbufenUI_Resource_7005.png")) c.drawImage(*kn, 0, 0, float(kn->w), float(kn->h), kx - 19.5 * HS, ky - 19.5 * HS, 39 * HS, 39 * HS, joy_.on ? 1 : 0.8f, false, true); }
  // sağ alt: büyük saldırı düğmesi, çevresinde yay biçiminde beceri ve iksir yuvaları (orijinal halka 7078)
  { const core::Image* ring = image("ui/AnbufenUI_Resource_7078.png");
    const double ax = double(vw_) - 50 * HS - safeR, ay = VH - 50 * HS;
    const float pulse = assign_.empty() ? 0 : 0.5f + 0.5f * std::sin(float(now) * 1000 / 160);
    auto slotAt = [&](double cx, double cy, double r, int qi, std::function<void()> fn) {
      if (!assign_.empty()) c.fillEllipse(cx, cy, r + 5, r + 5, 0xffd250, 0.25f + 0.35f * pulse);
      if (!assign_.empty()) fn = [this, &w, qi] { w.assignQuick(assign_, qi); assign_.clear(); w.sfx("repair", 0.5); w.save(); w.toastMsg = "Kısayola yerleşti."; w.toastT = 1.5f; };
      if (ring) { const double ww = r * 2 + 8; c.drawImage(*ring, 0, 0, float(ring->w), float(ring->h), cx - ww / 2, cy - ww / 2, ww, ww); }
      const double ir = r * 0.66; c.clipCircle(cx, cy, ir); c.fillRect(cx - ir, cy - ir, ir * 2, ir * 2, 0x0c0805);
      drawSlot(c, w, qi < int(P.quick.size()) ? P.quick[size_t(qi)] : "", cx - ir, cy - ir, ir * 2 / 32); c.clearClip();
      hud_.push_back({float(cx - r - 2), float(cy - r - 2), float(r * 2 + 4), float(r * 2 + 4), std::move(fn)});
    };
    const int ti = w.target(); const bool npc = ti >= 0 && w.ents[size_t(ti)].kind == Ent::NPC && !w.ents[size_t(ti)].hidden;
    if (npc && assign_.empty()) {   // hedef bir kişi: büyük düğme konuşma düğmesi (Android sürümünün turuncu düğmesi)
      const double r = 32 * HS;
      if (const core::Image* im = image("ui2/talk_7004.png")) c.drawImage(*im, 0, 0, float(im->w), float(im->h), ax - r - 4, ay - r - 4, r * 2 + 8, r * 2 + 8, 1, true);
      hud_.push_back({float(ax - r - 2), float(ay - r - 2), float(r * 2 + 4), float(r * 2 + 4), [this, &w, ti] { request = "talk:" + std::to_string(ti); }});
    } else slotAt(ax, ay, 32 * HS, 0, [this, &w] { attack(w); });
    auto arc = [&](double R, int n, double from, double to, double r, int base) {
      for (int i = 0; i < n; i++) { const double a = (from + (to - from) * (n == 1 ? 0 : double(i) / (n - 1))) * M_PI / 180; const int qi = base + i;
        slotAt(ax + std::cos(a) * R * HS, ay + std::sin(a) * R * HS, r * HS, qi, [this, &w, qi] { quick(w, qi); }); }
    };
    arc(66, 3, 180, 270, 19, 1);    // iç yay: 3 beceri
    arc(112, 4, 180, 270, 18, 4);   // dış yay: 2 beceri + 2 iksir
    // hedef değiştir: yayın dışında küçük düğme
    const float tx0 = float(ax - 142 * HS), ty0 = float(ay + 22 * HS);
    c.fillEllipse(tx0, ty0, 14, 14, 0x0c0805, 0.8f); c.strokeEllipse(tx0, ty0, 14, 14, 1.5f, 0xb89a50);
    text(c, "S", 13, "◎", tx0, ty0 + 5, 0xffe48a, CENTER);
    hud_.push_back({tx0 - 18, ty0 - 18, 36, 36, [&w] { w.cycleTarget(); }}); }
  // orta alt: yarı saydam mesaj kutusu (son 10 sn, en çok 5 satır)
  { std::vector<const Log*> L; for (const Log& l : logs_) if (now - l.t < 10) L.push_back(&l);
    if (L.size() > 5) L.erase(L.begin(), L.end() - 5);
    if (!L.empty()) {
      const float bx = float(rockerX() + 76 * HS), bw = std::max(110.f, std::min(360.f, float(vw_ - bx - 215 * HS))), bh = float(L.size()) * 11 + 6, by = VH - 6 - bh;
      c.fillRect(bx, by, bw, bh, 0x000000, 0.5f);
      for (size_t i = 0; i < L.size(); i++) text(c, "B", 9, L[i]->m, bx + 5, by + 12 + float(i) * 11, L[i]->c, LEFT, std::min(1.f, float((10 - (now - L[i]->t)) / 1)));
    } }
  // duyurular: bölge adı, kısa bildirim, seviye
  const float step = advance ? 1.f / 60 : 0;
  if (w.zoneT > 0) { w.zoneT -= step; text(c, "S", 20, w.zoneMsg, vw_ / 2, 92, 0xffe48a, CENTER, std::min(1.f, w.zoneT)); }
  if (w.toastT > 0) { w.toastT -= step; text(c, "H", 13, w.toastMsg, vw_ / 2, 130, 0xffd23a, CENTER, std::min(1.f, w.toastT * 2)); }
  if (w.lvlT > 0) { w.lvlT -= step; text(c, "S", 28, "Seviye " + std::to_string(w.lvlN), vw_ / 2, 160, 0xffe080, CENTER, std::min(1.f, w.lvlT)); }
  if (w.hurtT > 0) { w.hurtT -= step; c.fillRadial(vw_ / 2, VH / 2, VH * 0.3f, vw_ * 0.6f, 0xa00000, 0, std::max(0.f, w.hurtT)); }
  if (p.dead) c.fillRect(0, 0, vw_, VH, 0x280000, 0.45f);
  win.draw(c, w, advance ? 1.f / 60 : 0);
  gm.draw(c, w);   // GM paneli en üstte (HTML'de sayfa üstü katman)
}

// ---------------- dokunma ----------------
bool Hud::press(World& w, int id, float x, float y) {
  if (gm.on) { if (gmPtr_ < 0) { gmPtr_ = id; gm.press(x, y); } return true; }   // GM paneli bütün ekranı kaplar
  if (win.isOpen()) { wp_ = {true, id, x, y, 0, x, y}; return true; }   // pencere açıkken: bırakınca dokunuş sayılır (kaydırma değilse)
  for (int i = int(hud_.size()) - 1; i >= 0; i--) { const Hit& h = hud_[size_t(i)]; if (x >= h.x && x <= h.x + h.w && y >= h.y && y <= h.y + h.h) { auto fn = h.fn; fn(); return true; } }
  if (x < std::max(vw_ * 0.33f, 240.f) && y > engine::VH * 0.4f && !joy_.on) {   // yürüme kolu: sol alt bölgede herhangi bir yerden başlar
    float dx = x - rockerX(), dy = y - rockerY(); const float l = std::hypot(dx, dy); if (l > 48) { dx = dx / l * 48; dy = dy / l * 48; }
    joy_ = {true, id, float(rockerX()), float(rockerY()), dx, dy}; return true;
  }
  taps_.push_back({id, x, y}); (void)w;
  return false;
}
void Hud::move(int id, float x, float y) {
  if (gm.on && id == gmPtr_) { gm.move(x, y); return; }
  if (wp_.on && id == wp_.id) { wp_.moved += std::fabs(y - wp_.ly) + std::fabs(x - wp_.lx); if (wp_.moved > 6) win.drag(y - wp_.ly, wp_.x, wp_.y); wp_.lx = x; wp_.ly = y; return; }
  if (joy_.on && id == joy_.id) { float dx = x - joy_.ox, dy = y - joy_.oy; const float l = std::hypot(dx, dy); if (l > 48) { dx = dx / l * 48; dy = dy / l * 48; } joy_.dx = dx; joy_.dy = dy; }
}
void Hud::release(World& w, int id, float x, float y) {
  if (id == gmPtr_) { gmPtr_ = -1; if (gm.on) { gm.release(w, x, y); handle(w); } return; }
  if (wp_.on && id == wp_.id) { const WinPtr p = wp_; wp_.on = false; if (p.moved <= 6) win.tap(w, p.x, p.y); return; }
  if (joy_.on && id == joy_.id) joy_.on = false;
  for (size_t i = 0; i < taps_.size(); i++) if (taps_[i].id == id) { const Tap t = taps_[i]; taps_.erase(taps_.begin() + long(i)); if (!assign_.empty()) { assign_.clear(); w.toastT = 0; } if (std::hypot(x - t.x, y - t.y) < 12) tapWorld(w, x, y); break; }
}
void Hud::wheel(float dy, float x, float y) {
  if (gm.on) { gm.wheel(dy); return; }
  if (win.isOpen()) win.drag(-dy * 0.6f, x, y);   // HTML: Win.drag(-e.deltaY * 0.6, x, y)
}
bool Hud::key(World& w, const std::string& k) {
  if (gm.on && gm.key(w, k)) { handle(w); return true; }
  if (k == "Escape" && (gm.on || win.isOpen())) { closeAll(); return true; }   // HTML: Escape → UI.closeAll
  return false;
}
void Hud::joy(double& sx, double& sy) const {
  sx = sy = 0; if (joy_.on && std::hypot(joy_.dx, joy_.dy) > 6) { sx = joy_.dx; sy = joy_.dy; }
}
// dünyaya dokunma (HTML tapWorld): ekranda en yakın varlık; canavara ilk dokunuş seçer, ikincisi saldırır; kişiye ilk dokunuş seçer, ikincisi konuşur
void Hud::tapWorld(World& w, float sx, float sy) {
  if (w.player.dead) return;
  const double ox = engine::jsRound(w.camX - vw_ / 2), oy = engine::jsRound(w.camY - engine::VH / 2);
  const double Wx = sx + ox, Wy = sy + oy; int best = -1; double bd = 34;
  for (size_t i = 0; i < w.ents.size(); i++) {
    const Ent& e = w.ents[i]; if (e.dead || e.hidden || e.kind == Ent::GONE) continue;
    const double d = std::hypot(w.map.px(e.x, e.y) - Wx, (w.map.py(e.x, e.y) - 22) - Wy); if (d < bd) { bd = d; best = int(i); }
  }
  if (best < 0) return;
  if (w.ents[size_t(best)].kind == Ent::MOB) { w.setTarget(best, w.target() == best); return; }
  if (w.target() != best) { w.setTarget(best); w.sfx("menusel", 0.5); return; }
  request = "talk:" + std::to_string(best);
}

}  // namespace ui
