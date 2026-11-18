// Dünya haritası, ayarlar, NPC listesi (HTML win.js drawMap, drawSys2; ui.js NPC listesi). Dünya haritası Android sürümünün
// resimleriyle (wm/: world.jpg, r1..r7.jpg, simgeler; yerleşim wm.json ← tools/dunya.py): kıta (bölge noktaları) → bölge (şehir,
// kamp, kır, zindan simgeleri; seçilene Otomatik Yol) → bulunduğun harita (zemin küçültülmüş, geçitler, kişiler, sen). Ana menü
// harita ve ayarlarda solda açık kalır. NPC listesi HTML'de sayfa üstü panelken burada konuşma parşömeniyle çizilir.
#include <algorithm>
#include <cmath>
#include <ctime>

#include "win.h"

namespace ui {

using engine::Ent;
using engine::World;

static const int N2ROWS[5] = {50289, 50290, 50291, 50292, 50293};
static const int DS[5] = {50447, 50448, 50449, 50450, 50451};

const core::Json& Win::wm(World& w) {
  if (!wmLoaded_) { wmLoaded_ = true; try { wm_ = core::Json::parse(w.assets().vfs().readText("wm/wm.json")); } catch (...) { wm_ = core::Json(); } }
  return wm_;
}

// ---------------- dünya haritası ----------------
void Win::drawMap(engine::Canvas& c, World& w, float vw, float VH) {
  const core::Json& D = wm(w); Xf X1; X1.k = 1;
  const float W = std::min(560.f, std::round(vw - 96)), H = std::min(344.f, VH - 12), ox = std::max(80.f, std::round((vw - W) / 2) + 34), oy = std::round((VH - H) / 2);
  const float top = 4, bh = 36, vh = H - top - bh, vx = ox + 4, vy = oy + top, vwid = W - 8;
  // çerçeve: HTML çizgi kalınlığını ayarlamaz; oyun ekranı yazılarının dış çizgisinden kalan 2,5 geçerli olur (görüntü ona göre)
  c.fillRect(ox, oy, W, H, 0x000000); c.strokeRect(ox + 0.5f, oy + 0.5f, W - 1, H - 1, 2.5f, 0x9f998f); c.strokeRect(ox + 1.5f, oy + 1.5f, W - 3, H - 3, 2.5f, 0x4b4547);
  hit(X1, "frame", ox, oy, W, H);
  c.clipRect(vx, vy, vwid, vh);
  const float pulse = 0.5f + 0.5f * float(std::sin(w.time * 5));
  int here = -1; const auto& A = D["areas"].arr();
  for (size_t i = 0; i < A.size() && here < 0; i++) for (const core::Json& s : A[i]["scenes"].arr()) if (s["sid"].str() == w.sceneId) { here = int(i); break; }
  auto img = [&](const std::string& k) { return F_.image("wm/" + k); };
  auto draw = [&](const core::Image* im, float x, float y, float ww, float hh) { if (im) c.drawImage(*im, 0, 0, float(im->w), float(im->h), x, y, ww, hh, 1, true); };
  if (WM_.mode == "world") {
    draw(img("world.jpg"), vx, vy, vwid, vh);
    for (size_t i = 0; i < A.size(); i++) {
      const float x = vx + float(A[i]["cx"].num()) / 100 * vwid, y = vy + float(A[i]["cy"].num()) / 100 * vh;
      c.fillEllipse(x + 1, y + 2, 11, 11, 0x000000, 0.45f);
      c.fillCircleGrad(x, y, 10, x - 3, y - 3, 1, x, y, 11, 0xff7a3a, 0xc8300e);
      if (int(i) == here) { c.strokeEllipse(x, y, 13 + pulse * 2, 13 + pulse * 2, 2, 0xffffff, 0.5f + 0.5f * pulse); c.fillEllipse(x, y - 1, 3.2f, 3.2f, 0xffffff); }
      hit(X1, "area:" + std::to_string(A[i]["i"].i()), x - 16, y - 16, 32, 32);
    }
  } else if (WM_.mode == "area" && WM_.area >= 0 && WM_.area < int(A.size())) {
    const core::Json& a = A[size_t(WM_.area)]; draw(img(a["img"].str()), vx, vy, vwid, vh);
    for (const core::Json& s : a["scenes"].arr()) {
      const float x = vx + float(s["x"].num()) / 100 * vwid, y = vy + float(s["y"].num()) / 100 * vh, sz = 22; const std::string sid = s["sid"].str();
      if (sid == w.sceneId || sid == WM_.sel) { const float k = sid == WM_.sel ? 34 : 30 + pulse * 4; draw(img("ring.png"), x - k / 2, y - k / 2, k, k); }
      draw(img(s["icon"].str() + ".png"), x - sz / 2, y - sz / 2, sz, sz);
      hit(X1, "sc:" + sid, x - 15, y - 15, 30, 30);
    }
  } else {   // bulunduğun harita: zemin sığacak kadar küçültülür
    const auto& M = w.map; const float pw = float(M.pw), ph = float(M.ph), k = std::min((vwid - 8) / pw, (vh - 4) / ph), gw = pw * k, gh = ph * k, gx = vx + (vwid - gw) / 2, gy = vy + (vh - gh) / 2;
    if (!M.ground.empty()) c.drawImage(M.ground, 0, 0, pw, ph, gx, gy, gw, gh, 1, true);
    auto dot = [&](double ex, double ey, uint32_t col, float r) { c.fillEllipse(gx + float(M.px(ex, ey)) * k, gy + float(M.py(ex, ey)) * k, r, r, col); };
    for (const auto& r : M.regions) if (r.size() >= 6 && r[1] == 1) dot((r[2] + r[4]) / 2.0, (r[3] + r[5]) / 2.0, 0x4aa8ff, 3.5f);
    for (const Ent& e : w.ents) if (e.kind == Ent::NPC && !e.dummy && !e.hidden) dot(e.x, e.y, 0x7cf06a, 2);
    if (int(std::floor(w.time * 3)) % 2 == 0) { dot(w.player.x, w.player.y, 0x000000, 4); dot(w.player.x, w.player.y, 0xffe048, 3); }
  }
  c.clearClip();
  // kapatma düğmesi (orijinal çanta penceresinin düğmesi) ve alt satır: Değiştir / Geri, Otomatik Yol, NPC Listesi, bilgi
  if (const core::Json* cl = F_.ctrl("bag", 52696)) F_.drawCtrl(c, X1, *cl, on("close") ? 1 : 0, ox + W - 306, oy - 6);
  hit(X1, "close", ox + W - 34, oy - 6, 34, 34);
  const float by = oy + H - bh + 3; const std::string empty;
  auto btn = [&](const std::string& id, const std::string& label, float x) {
    if (const core::Json* b = F_.ctrl("worldmap", 52801)) F_.drawCtrl(c, X1, *b, on(id) ? 1 : 0, x - 1, by - 1, &empty);
    F_.label(c, X1, label, x, by, 70, 30, 0xffffff, CENTER, 10); hit(X1, id, x, by, 70, 30);
  };
  const bool area = WM_.mode == "area";
  btn("sw", area ? "Geri" : "Değiştir", ox + 8);
  if (area) btn("go", "Otomatik Yol", ox + W - 156);
  btn("npcs", "NPC Listesi", ox + W - 78);
  const core::Json& S = w.assets().D()["scenes"];
  std::string info = "Şimdi: " + w.quests().name(w.sceneName); uint32_t col = 0xe6cf89;
  if (area && !WM_.sel.empty() && WM_.area >= 0) {
    info = w.quests().name(S[WM_.sel]["name"].str());
    for (const core::Json& s : A[size_t(WM_.area)]["scenes"].arr()) if (s["sid"].str() == WM_.sel && s["lv"].isArr()) {
      const int a0 = s["lv"][0].i(), a1 = s["lv"][1].i(); if (a0) info += "  ·  Sv " + std::to_string(a0) + (a1 != a0 ? "-" + std::to_string(a1) : "");
    }
    col = 0xffffff;
  }
  F_.label(c, X1, info, ox + 84, by, W - (area ? 246 : 168), 30, col, CENTER, 11);
}
void Win::tapMap(World& w, const std::string& id) {
  if (id == "npcs") { close(); openNpcList(w); return; }
  if (id == "sw") { WM_.sel.clear(); WM_.mode = WM_.mode == "area" ? "world" : WM_.mode == "world" ? "local" : "world"; return; }
  if (id == "go") { if (WM_.sel.empty()) { w.toast("Önce haritadan bir yer seç."); return; } const std::string t = WM_.sel; close(); w.routeQuest = 0; w.routeNpc.clear(); w.routeTo(t); return; }
  if (id.rfind("area:", 0) == 0) {
    const int n = std::atoi(id.c_str() + 5); const auto& A = wm(w)["areas"].arr();
    for (size_t i = 0; i < A.size(); i++) if (A[i]["i"].i() == n) { WM_.area = int(i); WM_.mode = "area"; WM_.sel.clear(); }
    return;
  }
  if (id.rfind("sc:", 0) == 0) WM_.sel = id.substr(3);
}

// ---------------- ayarlar (NEW_FORM_DEADSELECT parşömeni + satırlar); ana menü solda açık ----------------
void Win::drawSys(engine::Canvas& c, World& w, float VH) {
  (void)w;
  const float k = VH / 373; const Xf xf = begin(k, safeL + 126 * VH / 320, 0); const std::string f = "n_deadselect";
  longBg(c, xf); F_.text(c, xf, "Ayarlar", 113, 24, 0x7a1c08, 14, CENTER);
  F_.text(c, xf, "Kayıt sistemi sonraki adımlarda.", 113, 52, 0x2a1a0a, 11, CENTER, 200);
  F_.text(c, xf, std::string("C++ sürümü · ") + __DATE__, 113, 70, 0x5a4020, 10, CENTER);
  const std::string on1 = "Açık", off1 = "Kapalı";
  const std::pair<const char*, std::string> rows[5] = {{"sfx", "Ses efektleri: " + (optSfx ? on1 : off1)}, {"mus", "Müzik: " + (optMusic ? on1 : off1)}, {"lang", "Dil / Language: Türkçe"},
                                                      {"title", "Giriş ekranına dön"}, {"newc", "Yeni karakter oluştur"}};
  for (int i = 0; i < 5; i++) { const std::string key = std::string("s:") + rows[i].first; row(c, xf, f, DS[i], on(key), rows[i].second, key); }
}
void Win::tapSys(World& w, const std::string& id) {
  if (id == "sfx") optSfx = !optSfx;
  else if (id == "mus") optMusic = !optMusic;
  else if (id == "lang") w.toast("İngilizce sonraki adımlarda.");
  else if (id == "title" || id == "newc") w.toast("Giriş ekranı ve karakter oluşturma sonraki adımlarda.");
}

// ---------------- NPC listesi: konuşma parşömeni, 4'erli sayfa; dokununca kişiye yürür ----------------
void Win::openNpcList(World& w) {
  open(w, "list"); listTitle_ = "NPC Listesi"; list_.clear(); listOff_ = 0;
  for (size_t i = 0; i < w.ents.size(); i++) {
    const Ent& e = w.ents[i]; if (e.kind != Ent::NPC || e.hidden || e.pickup || (e.dummy && !e.node)) continue;
    list_.push_back({w.quests().name(e.name), "(" + std::to_string(int(engine::jsRound(e.x))) + ", " + std::to_string(int(engine::jsRound(e.y))) + ")", int(i)});
  }
}
void Win::drawList(engine::Canvas& c, World& w, float VH) {
  (void)w;
  const Xf xf = begin(VH / 373, safeL, 0); const std::string f = "n_npc_dialogue";
  longBg(c, xf); F_.text(c, xf, listTitle_, 16, 20, 0x7a1c08, 12, LEFT, 180);
  if (list_.empty()) F_.text(c, xf, "Bu haritada NPC yok.", 16, 44, 0x2a1a0a, 11, LEFT, 198);
  else F_.text(c, xf, std::to_string(list_.size()) + " kişi · dokun: yanına yürü", 16, 44, 0x5a4020, 10, LEFT, 198);
  const int per = list_.size() > 5 ? 4 : 5;
  if (listOff_ >= int(list_.size())) listOff_ = 0;
  for (int i = 0; i < per && listOff_ + i < int(list_.size()); i++) {
    const ListRow& r = list_[size_t(listOff_ + i)]; const std::string id = std::to_string(N2ROWS[i]);
    row(c, xf, f, N2ROWS[i], on(id), r.label + "  " + r.sub, id);
  }
  if (per == 4) row(c, xf, f, N2ROWS[4], on("more"), "Diğerleri ▾ (" + std::to_string(listOff_ / 4 + 1) + "/" + std::to_string((list_.size() + 3) / 4) + ")", "more", 0x5a4020);
  const auto r = rect(f, 50294); nDraw(c, xf, f, 50294, on("close")); hit(xf, "close", r[0] + 6, r[1], 36, 36);
}
void Win::tapList(World& w, const std::string& id) {
  if (id == "more") { listOff_ += 4; if (listOff_ >= int(list_.size())) listOff_ = 0; return; }
  for (int i = 0; i < 5; i++) if (std::to_string(N2ROWS[i]) == id && listOff_ + i < int(list_.size())) { const int e = list_[size_t(listOff_ + i)].ent; close(); if (e >= 0) w.walkToEnt(e); return; }
}

}  // namespace ui
