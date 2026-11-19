#include "gm.h"

#include <algorithm>
#include <cmath>

#include "core/json.h"
#include "core/png.h"

namespace ui {

using engine::T;
using engine::World;
using engine::tx;

namespace {

// ---------------- tarayıcı yerleşiminin parçaları ----------------
double F64(double v) { return std::floor(v * 64 + 1e-7) / 64; }        // LayoutUnit'e çevirme (kesirli px → 1/64, aşağı)
double half(double v) { return std::trunc(v * 64 / 2) / 64; }           // LayoutUnit / 2 (tam sayı bölmesi)
int jr(double v) { return int(std::floor(v + 0.5)); }
struct IR { int x, y, w, h; };
IR snap(double x, double y, double w, double h) { const int X = jr(x), Y = jr(y); return {X, Y, jr(x + w) - X, jr(y + h) - Y}; }   // piksele oturtma
// Alegreya satır ölçüleri (tarayıcı: yükselme ve alçalma ayrı ayrı yuvarlanır; hhea 2081 / 707, em 2048 ölçeğinde)
int ascOf(double s) { return int(std::floor(2081.0 / 2048 * s + 0.5)); }
int lineOf(double s) { return ascOf(s) + int(std::floor(707.0 / 2048 * s + 0.5)); }

// HTML toLocaleLowerCase('tr'): I → ı, İ → i; Latin-1 ve Latin Genişletilmiş-A büyük harfleri
std::string lowerTr(const std::string& s) {
  std::string o; o.reserve(s.size());
  auto put = [&](uint32_t c) {
    if (c < 0x80) o += char(c);
    else if (c < 0x800) { o += char(0xC0 | (c >> 6)); o += char(0x80 | (c & 63)); }
    else if (c < 0x10000) { o += char(0xE0 | (c >> 12)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); }
    else { o += char(0xF0 | (c >> 18)); o += char(0x80 | ((c >> 12) & 63)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); }
  };
  for (uint32_t c : utf8(s)) {
    if (c == 'I') c = 0x131;
    else if (c == 0x130) c = 'i';
    else if (c >= 'A' && c <= 'Z') c += 32;
    else if (c >= 0xC0 && c <= 0xDE && c != 0xD7) c += 32;
    else if (c >= 0x100 && c <= 0x137 && !(c & 1)) c += 1;
    else if (c >= 0x139 && c <= 0x148 && (c & 1)) c += 1;
    else if (c >= 0x14A && c <= 0x177 && !(c & 1)) c += 1;
    else if (c == 0x178) c = 0xFF;
    else if (c >= 0x179 && c <= 0x17E && (c & 1)) c += 1;
    put(c);
  }
  return o;
}
std::string trim(const std::string& s) {
  size_t a = 0, b = s.size();
  while (a < b && (s[a] == ' ' || s[a] == '\t' || s[a] == '\n')) a++;
  while (b > a && (s[b - 1] == ' ' || s[b - 1] == '\t' || s[b - 1] == '\n')) b--;
  return s.substr(a, b - a);
}
std::vector<std::string> words(const std::string& s) {
  std::vector<std::string> v; std::string cur;
  for (char ch : s) { if (ch == ' ') { if (!cur.empty()) v.push_back(cur); cur.clear(); } else cur += ch; }
  if (!cur.empty()) v.push_back(cur);
  return v;
}
std::string q(const std::string& s) {   // JSON dizgisi
  std::string o = "\"";
  for (char ch : s) { if (ch == '"' || ch == '\\') o += '\\'; if (ch == '\n') { o += "\\n"; continue; } o += ch; }
  return o + "\"";
}

const uint32_t C_BOX = 0x0e0a06, C_GOLD = 0x8a6a30, C_HEAD = 0xffd870, C_STATE = 0xc8b890, C_CLOSE = 0x2a1a10, C_TOOLB = 0x6a5028, C_TOOLT = 0xf0e0b0,
               C_ITEM = 0x0e0806, C_ITEMB = 0x4a3820, C_ITEMT = 0xe8dcc0, C_B = 0xffe8a0, C_SMALL = 0xa89878, C_PH = 0x757575, C_ACTIVE = 0x3a2410;

}  // namespace

void GmPanel::open() {   // HTML openList('gm'): arama boş, yer tutucu her açılışta haritalarınki (sekme ve kaydırma kalır)
  on = true; query.clear(); editing = false; placeholder_ = "Harita ara: ad ya da numara…"; pressed_.clear(); num_.on = false;
}

std::string GmPanel::stateText(World& w) const {
  return tx("Seviye") + " " + std::to_string(w.P.lv) + " · " + std::to_string(w.P.gold) + " " + tx("altın") + (w.god ? " · " + tx("ölümsüz") : "") + (w.fast ? " · " + tx("hızlı") : "");
}

// HTML drawList / drawGmSys: listenin satırları (görünüme ve aramaya göre)
std::vector<GmPanel::Row> GmPanel::rows(World& w) {
  std::vector<Row> R; const std::string v = lowerTr(trim(query));
  auto has = [&](const std::string& s) { return v.empty() || lowerTr(s).find(v) != std::string::npos; };
  auto row = [&](const std::string& title, const std::string& sub, std::vector<Btn> b) { Row r; r.kind = 0; r.title = title; r.sub = sub; r.btns = std::move(b); R.push_back(std::move(r)); };
  const auto& Q = w.quests(); const core::Json& D = w.assets().D();
  if (view == "dg") {
    int copy = -1; const engine::DungeonDef* here = w.dungeonOf(w.sceneId, &copy);
    row(T("Bu harita", "This map"), here ? Q.name(here->cn) + " · " + T("koşu", "run") + ": " + (w.P.dun.on ? std::to_string(w.P.dun.cleared.size()) + T(" kesilen", " killed") : "-") : T("zindan dışı", "outside dungeons"),
        {{"dg:boss", T("Boss'u öldür", "Kill boss")}, {"dg:clear", T("Canavarları öldür", "Kill monsters")}, {"dg:last", T("Son kata / başa", "Last floor / first")}, {"dg:leave", T("Zindandan çık", "Leave")}, {"dg:reset", T("Günlük hakları sıfırla", "Reset daily entries")}});
    for (const engine::DungeonDef& d : w.balance().dungeons) {
      if (!has(Q.name(d.cn) + d.cn)) continue;
      for (size_t i = 0; i < d.copies.size(); i++) {
        const engine::DungeonCopy& c = d.copies[i];
        row(Q.name(d.cn) + (d.copies.size() > 1 ? (i ? T(" (elf)", " (elf)") : T(" (insan)", " (human)")) : ""),
            T("Sv", "Lv") + " " + std::to_string(d.lv) + "+ · " + (d.train ? T("sınav", "training") : T("günde ", "") + std::to_string(d.daily) + T("", "/day")) + " · " +
                Q.name(D["scenes"][c.doorScene]["name"].str()) + " " + T("kapı", "gate") + " " + std::to_string(c.doorRegion),
            {{"dg:door:" + d.id + ":" + std::to_string(i), T("Kapıya git", "Go to gate")}, {"dg:in:" + d.id + ":" + std::to_string(i), T("İçeri gir", "Enter")}});
      }
    }
  } else if (view == "cls") {
    auto& P = w.P; int spent = 0; for (const auto& kv : P.sk) spent += kv.second;
    row(T("Sınıf", "Class"), w.clsName() + " · " + T("yükseltme", "advancement") + " " + std::to_string(P.adv) + " · " + T("Sv", "Lv") + " " + std::to_string(P.lv),
        {{"cls:up", T("Sınıfı yükselt", "Advance class")}, {"cls:up2", T("İkinci yükseltme (80)", "Second advancement (80)")}, {"cls:reset", T("Acemiye döndür", "Back to trainee")}, {"cls:start", T("40 yap + ilk görev", "Set 40 + first quest")}});
    row(T("Beceri ağaçları", "Skill trees"), T("puan", "points") + " " + std::to_string(P.sp) + " · " + std::to_string(spent) + " " + T("harcanmış", "spent"),
        {{"cls:resetPts", T("Puanları sıfırla (bedava)", "Reset points (free)")}, {"cls:fill:0", T("Ağaçları doldur (1. uzmanlık)", "Fill trees (spec 1)")}, {"cls:fill:1", T("Ağaçları doldur (2. uzmanlık)", "Fill trees (spec 2)")}});
    row(T("Beceri efektleri", "Skill effects"), T("beklemesiz", "no cooldown") + ": " + (w.gmNoCd ? T("açık", "on") : T("kapalı", "off")),
        {{"cls:dummy", T("Kukla canavar", "Training dummy")}, {"cls:nocd", T("Beklemesiz beceri (aç/kapa)", "No cooldown (toggle)")}});
    row(T("80 yükseltmesi", "80 advancement"), T("Bozbalta Şehri: Kara Şövalye / Büyük Büyü Üstadı / Seçilmiş", "Greyaxe City: Black Knight / Grand Magister / The Chosen"),
        {{"cls:start80", T("80 yap + Bozbalta'ya git", "Set 80 + go to Greyaxe")}});
    for (int qi : w.gmClassChain()) {
      const engine::Quest& qq = Q.all()[size_t(qi)];
      if (!has(qq.tr.title + " " + std::to_string(qq.id))) continue;
      const std::string st = w.questState(qi);
      const std::string sn = st == "done" ? T("bitti", "done") : st == "ready" ? T("hazır", "ready") : st == "active" ? T("sürüyor", "active") : st == "new" ? T("alınabilir", "available") : st == "soon" ? T("seviye bekliyor", "level too low") : T("kilitli", "locked");
      const std::string id = std::to_string(qq.id);
      row(qq.tr.title + (qq.adv ? " ★" : ""), id + " · " + Q.name(qq.giver) + " → " + Q.name(qq.to) + " · " + sn,
          {{"cls:ready:" + id, T("Hazır yap", "Make ready")}, {"cls:done:" + id, T("Bitir", "Complete")}, {"cls:go:" + id, T("Git", "Go")}});
    }
  } else if (view == "pet") {
    const engine::PetData& PD = w.balance().pets;
    engine::PetRec* p = w.petActive(); auto L = w.petList();
    row(T("Evcil hayvan", "Pet"), p ? w.petName(*p) + " · " + T("Sv", "Lv") + " " + std::to_string(p->lv) + " · " + T("tokluk", "satiety") + " " + core::jsNumStr(p->sat) + " · " + std::to_string(L.size()) + "/" + std::to_string(w.petSlotsN()) : T("çağrılmış hayvan yok", "no pet summoned"),
        {{"pet:win", T("Pencereyi aç", "Open window")}, {"pet:level", T("Seviyeme çek", "To my level")}, {"pet:care", T("Dirilt + doyur + iyileştir", "Revive + feed + heal")}, {"pet:items", T("Evcil eşyaları ver", "Give pet items")}, {"pet:hungry", T("Acıktır", "Make hungry")}, {"pet:clear", T("Hepsini sil", "Remove all")}});
    engine::PetRec* qp = p ? p : (L.empty() ? nullptr : L[0]);
    std::string sk; if (qp) { const auto S = w.petSkills(*qp); for (size_t i = 0; i < S.size(); i++) sk += (i ? ", " : "") + w.petSkName(S[i]); }
    row(T("Dönüşüm ağacı", "Transform tree"), qp ? w.petName(*qp) + " · " + T("düzey", "level") + " " + std::to_string(qp->st) + "/7 · " + T("beceriler", "skills") + ": " + sk : T("hayvan yok", "no pet"),
        {{"pet:stage", T("Sonraki biçim", "Next form")}, {"pet:stage0", T("Temel biçim", "Base form")}, {"pet:skills", T("3 rastgele beceri", "3 random skills")}, {"pet:tf", T("Dönüşüm malzemesi", "Transform materials")}, {"pet:petf", T("Dönüşüm penceresi", "Transform window")}, {"pet:petfs", T("Beceri aktarma", "Skill transfer")}});
    for (const engine::PetSpecies& s : PD.species) {
      std::string f; for (const engine::PetForm& fm : s.forms) f += fm.tr + fm.en + fm.cn;
      if (!has(s.tr + s.en + s.cn + f)) continue;
      auto ti = PD.templates.find(s.tpl); const std::string tn = ti == PD.templates.end() ? "" : ti->second.tr;
      auto si = PD.skills.find(s.skill); const std::string skn = si == PD.skills.end() ? "" : si->second.tr;
      const std::string bx = s.box == "wood" ? T("tahta", "wood") : s.box == "metal" ? "metal" : s.box == "magic" ? T("büyülü", "magic") : "undefined";
      row(s.tr + (s.apk ? " · APK" : ""), tn + " · " + bx + " " + T("kutu", "box") + " · " + skn + " · 7: " + (s.forms.size() > 7 ? s.forms[7].tr : ""),
          {{"pet:give:" + s.cn, T("Hayvanı ver", "Give pet")}, {"pet:egg:" + s.cn, T("Yumurta + kutu", "Egg + box")}});
    }
  } else {   // haritalar: yolculuk ağı satırı (arama boşken) + harita düğmeleri (şehirler önce, seviyeye göre; en çok 200)
    const core::Json& S = D["scenes"];
    std::vector<std::string> ids;
    for (const auto& kv : S.obj()) if (has(kv.first + " " + Q.name(kv.second["name"].str()) + " " + kv.second["name"].str())) ids.push_back(kv.first);
    auto city = [&](const std::string& id) { return S[id]["kind"][0].i() == 1 ? 0 : 1; };
    std::sort(ids.begin(), ids.end(), [&](const std::string& a, const std::string& b) {
      if (city(a) != city(b)) return city(a) < city(b);
      const int la = S[a]["lv"].i(), lb = S[b]["lv"].i(); if (la != lb) return la < lb;
      return std::stod(a) < std::stod(b);
    });
    if (v.empty()) {
      int here = 0; for (const core::Json& e : S[w.sceneId]["ents"].arr()) { const std::string id = e[0].isStr() ? e[0].str() : core::jsNumStr(e[0].num()); if (w.balance().travel.count(id)) here++; }
      row(T("Yolculuk ağı", "Travel network"), std::to_string(w.balance().travel.size()) + " " + T("arabacı/ışınlayıcı", "coachmen/teleporters") + " · " + T("bu haritada", "on this map") + " " + std::to_string(here) + " · " + T("ücretsiz", "free") + ": " + (w.gmFreeTravel ? T("açık", "on") : T("kapalı", "off")),
          {{"tv:free", T("Ücretsiz yolculuk (aç/kapa)", "Free travel (toggle)")}, {"tv:near", T("Yolculuk NPC'sine yürü", "Walk to travel NPC")}, {"tv:axe", T("Bozbalta Şehri'ne git", "Go to Greyaxe City")}});
    }
    static const char* KIND[5] = {"Özel", "Şehir", "Kır", "Başlangıç", "Zindan"};
    for (size_t i = 0; i < ids.size() && i < 200; i++) {
      const core::Json& sc = S[ids[i]]; const int k = sc["kind"][0].i(), lv = sc["lv"].i();
      Row r; r.kind = 1; r.id = ids[i]; r.on = ids[i] == w.sceneId; r.title = Q.name(sc["name"].str());
      r.sub = tx(k >= 1 && k <= 4 ? KIND[k] : KIND[0]) + (lv ? " · " + tx("Sv") + " " + std::to_string(lv) : "") + " · " + ids[i];
      R.push_back(std::move(r));
    }
    if (ids.size() > 200) { Row r; r.kind = 2; r.title = std::to_string(ids.size() - 200) + " " + tx("harita daha var; aramayı daralt."); R.push_back(std::move(r)); }
  }
  return R;
}

// ---------------- çizim (yerleşim + boyama) ----------------
void GmPanel::draw(engine::Canvas& c, World& w) {
  if (!on) return;
  boxes.clear();
  if (!btnLoaded_) { btnLoaded_ = true; try { btnImg_ = core::decodePNG(as_.vfs().read("ui/AnbufenUI_Resource_7032.png")); } catch (...) { btnImg_ = core::Image(); } }
  static core::Image btnOn; static bool btnOnL = false;
  if (!btnOnL) { btnOnL = true; try { btnOn = core::decodePNG(as_.vfs().read("ui/AnbufenUI_Resource_7033.png")); } catch (...) { btnOn = core::Image(); } }
  const double vw = c.w(), vh = c.h();
  auto rect = [&](double x, double y, double w2, double h2, uint32_t bg, float bga, int bw, uint32_t bc) {   // arka plan + kenar (piksele oturmuş)
    const IR r = snap(x, y, w2, h2); if (r.w <= 0 || r.h <= 0) return r;
    if (bga > 0) c.fillRect(float(r.x), float(r.y), float(r.w), float(r.h), bg, bga);
    if (bw > 0) { c.fillRect(float(r.x), float(r.y), float(r.w), float(bw), bc); c.fillRect(float(r.x), float(r.y + r.h - bw), float(r.w), float(bw), bc);
      c.fillRect(float(r.x), float(r.y + bw), float(bw), float(r.h - 2 * bw), bc); c.fillRect(float(r.x + r.w - bw), float(r.y + bw), float(bw), float(r.h - 2 * bw), bc); }
    return r;
  };
  auto text = [&](const std::string& fam, double size, const std::string& s, double x, double top, uint32_t col, bool emoji = false) {   // DOM yazısı: satır kutusunun üstü + yükselme
    TextStyle st; st.color = col; st.emoji = emoji; font_.draw(c, fam, float(size), s, float(x), float(top + ascOf(size)), st);
  };
  auto box = [&](const std::string& id, const std::string& kind, const std::string& t, double x, double y, double w2, double h2) { boxes.push_back({id, kind, t, x, y, w2, h2}); };
  const std::string btnId = pressed_;

  // #gm: tam ekran yarı saydam karartma; .gbox ortada (ızgara place-items: center)
  c.fillRect(0, 0, float(vw), float(vh), 0x000000, 0.5f);
  const double padX = F64(0.02 * vw), padY = F64(0.02 * vh), gw = F64(std::min(640.0, 0.96 * vw)), gh = F64(0.94 * vh);
  const double gx = padX + half(vw - 2 * padX - gw), gy = padY + half(vh - 2 * padY - gh);
  box("", "panel", "", gx, gy, gw, gh);
  { const IR r = snap(gx, gy, gw, gh);   // box-shadow 0 0 0 2px #000 (yalnız kutunun dışında), arka plan, 2 px kenar
    c.fillRect(float(r.x - 2), float(r.y - 2), float(r.w + 4), 2, 0x000000); c.fillRect(float(r.x - 2), float(r.y + r.h), float(r.w + 4), 2, 0x000000);
    c.fillRect(float(r.x - 2), float(r.y), 2, float(r.h), 0x000000); c.fillRect(float(r.x + r.w), float(r.y), 2, float(r.h), 0x000000);
    rect(gx, gy, gw, gh, C_BOX, 0.96f, 2, C_GOLD); }
  const double cx = gx + 12, cy = gy + 10, cw = gw - 24, ch = gh - 20;

  // .ghead: başlık (kalın 13), durum (11, esner), ✕ (30 x 28); öğeler dikeyde ortada
  { const std::string title = tx("GM Paneli"), st = stateText(w);
    const double tw = font_.domWidth("Bb", 13, title), sw = cw - tw - 30 - 20;
    box("", "head", "", cx, cy, cw, 28);
    box("", "title", title, cx, cy + 5.5, tw, 17); text("Bb", 13, title, cx, cy + 5.5, C_HEAD);
    box("", "state", st, cx + tw + 10, cy + 6.5, sw, 15); text("B", 11, st, cx + tw + 10, cy + 6.5, C_STATE);
    const double bx = cx + cw - 30;
    box("close", "close", "✕", bx, cy, 30, 28); rect(bx, cy, 30, 28, btnId == "close" ? C_ACTIVE : C_CLOSE, 1, 1, C_GOLD);
    const double xw = font_.domWidth("B", 13, "✕"); text("B", 13, "✕", bx + 1 + half(28 - xw), cy + 1 + 4.5, C_HEAD); }

  // #gtools: araç düğmeleri (flex-wrap, aralık 4): 12 px yazı, 6/9 iç boşluk, 7032 görseli sığdırılmış
  double y = cy + 28 + 6;
  { static const char* G[13][2] = {{"lv1", "Seviye +1"}, {"lv10", "Seviye +10"}, {"lvset", "Seviye seç"}, {"gear", "Ekipman giydir"}, {"sp", "Beceri puanı +20"}, {"gold", "Altın +100.000"},
      {"heal", "Can doldur"}, {"god", "Ölümsüzlük"}, {"fast", "Hızlı koşu"}, {"v:maps", "🗺 Haritalar"}, {"v:dg", "⚔ Zindanlar"}, {"v:pet", "🐾 Evcil"}, {"v:cls", "🎓 Sınıf"}};
    double x = 0, rowsH = 30;
    for (const auto& g : G) {
      const std::string id = std::string("g:") + g[0], label = tx(g[1]); const double tw = font_.domWidth("B", 12, label, true), bw = tw + 20;
      if (x > 0 && x + 4 + bw > cw) { x = 0; y += 34; rowsH += 34; } else if (x > 0) x += 4;
      const bool act = btnId == id, sel = std::string(g[0]) == "v:" + tabOn_;
      box(id, "tool", label, cx + x, y, bw, 30);
      const IR r = snap(cx + x, y, bw, 30);
      const core::Image& im = act ? btnOn : btnImg_;
      if (!im.empty()) c.drawImage(im, 0, 0, float(im.w), float(im.h), float(r.x + 1), float(r.y + 1), float(r.w - 2), float(r.h - 2), 1, true);
      rect(cx + x, y, bw, 30, 0, 0, 1, sel ? 0xffd870 : C_TOOLB);
      text("B", 12, label, cx + x + 10, y + 7, act ? 0x000000 : sel ? 0xffffff : C_TOOLT, true);
      x += bw;
    }
    y += 30 + 6; (void)rowsH; }

  // #gq: arama kutusu (15 px, 7/8 iç boşluk)
  { box("gq", "input", query.empty() ? tx(placeholder_) : query, cx, y, cw, 36);
    rect(cx, y, cw, 36, 0x000000, 1, 1, C_TOOLB);
    const IR r = snap(cx, y, cw, 36); c.clipRect(float(r.x + 1), float(r.y + 1), float(r.w - 2), float(r.h - 2));
    if (query.empty()) text("B", 15, tx(placeholder_), cx + 9, y + 8, C_PH);
    else text("B", 15, query, cx + 9, y + 8, 0xffffff);
    if (editing && std::fmod(w.time, 1.0) < 0.5) { const double qx = cx + 9 + (query.empty() ? 0 : font_.domWidth("B", 15, query)); c.fillRect(float(jr(qx)), float(jr(y + 8)), 1, float(lineOf(15)), 0xffffff); }
    c.clearClip();
    y += 36 + 6; }

  // #glist: ızgara (auto-fill, minmax(180px, 1fr), aralık 4); satırlar (.grow) bütün sütunları kaplar
  const double LX = cx, LY = y, LW = cw, LH = std::max(0.0, cy + ch - y);
  listX_ = LX; listY_ = LY; listW_ = LW; listH_ = LH;
  box("", "list", "", LX, LY, LW, LH);
  const int ncol = std::max(1, int(std::floor((LW + 4) / 184)));
  // 1fr sütunlar (tarayıcı ExpandFlexibleTracks): pay tek duyarlıklı hesaplanır, her sütun 1/64'e aşağı yuvarlanır, artan sonrakine taşınır
  std::vector<double> colWs(static_cast<size_t>(ncol)), colXs(static_cast<size_t>(ncol));
  { const float fr = float(LW - 4.0 * (ncol - 1)) / float(ncol); float left = 0; double x = 0;
    for (int k = 0; k < ncol; k++) { const float share = fr + left; const double sz = std::floor(double(share) * 64) / 64; left = share - float(sz); colWs[size_t(k)] = sz; colXs[size_t(k)] = x; x += sz + 4; } }
  // tam satır (.grow) genişliği: sütunların toplamı; listede tek hücrelik öğe yoksa tarayıcı satırları liste genişliğine eşit verir (ölçüldü)
  bool cells = false;
  double gridW = colXs.back() + colWs.back();
  auto wrap = [&](const std::string& fam, double size, const std::string& s, double maxW) {   // satır kırma: boşluklarda; tek sözcük sığmazsa taşar
    std::vector<std::string> L; std::string cur;
    for (const std::string& wd : words(s)) { const std::string cand = cur.empty() ? wd : cur + " " + wd; if (!cur.empty() && font_.domWidth(fam, float(size), cand) > maxW + 1e-9) { L.push_back(cur); cur = wd; } else cur = cand; }
    if (!cur.empty() || L.empty()) L.push_back(cur);
    return L;
  };
  struct Item { int row; double x, y, w, h; };   // yerleşim (listenin üstüne göre)
  std::vector<Row> R = rows(w);
  for (const Row& r : R) cells = cells || r.kind != 0;
  if (!cells) gridW = LW;
  // satır (.grow) yerleşimi: b (kalın 13, en az 130), small (10,5, flex 1, en az 140), span (11 px düğmeler, flex-wrap); satır içi aralık 8, satırlar arası 4
  struct GL { double h = 0; struct P { double x, y, w, h; std::vector<std::string> lines; }; P b, s, sp; struct B { double x, y, w; std::string key, label; }; std::vector<B> btns; };
  auto growLayout = [&](const Row& r, double W) {
    GL o; const double iw = W - 18;
    const double bText = font_.domWidth("Bb", 13, r.title);
    std::vector<double> bw; double spanMax = 0, spanMin = 0;
    for (size_t i = 0; i < r.btns.size(); i++) {
      const double tw = font_.domWidth("B", 11, r.btns[i].label); bw.push_back(tw + 18); spanMax += (i ? 4 : 0) + tw + 18;
      double lw = 0; for (const std::string& wd : words(r.btns[i].label)) lw = std::max(lw, font_.domWidth("B", 11, wd)); spanMin = std::max(spanMin, lw + 18);
    }
    double hyp[3] = {std::max(130.0, bText), 140, spanMax};
    std::vector<std::vector<int>> lines; std::vector<int> cur; double used = 0;
    for (int i = 0; i < 3; i++) { if (!cur.empty() && used + 8 + hyp[i] > iw + 1e-9) { lines.push_back(cur); cur.clear(); used = 0; } used += (cur.empty() ? 0 : 8) + hyp[i]; cur.push_back(i); }
    lines.push_back(cur);
    double wv[3] = {hyp[0], hyp[1], hyp[2]};
    for (const auto& ln : lines) {
      double sum = 8.0 * (ln.size() - 1); for (int i : ln) sum += hyp[i];
      if (sum <= iw) { for (int i : ln) if (i == 1) { double others = 8.0 * (ln.size() - 1); for (int k : ln) if (k != 1) others += hyp[k]; wv[1] = std::max(140.0, iw - others); } }
      else if (ln.size() == 1) { const int i = ln[0]; wv[i] = i == 0 ? std::max(130.0, iw) : i == 2 ? std::max(spanMin, iw) : 140; }
    }
    o.b.lines = wrap("Bb", 13, r.title, wv[0]); o.s.lines = wrap("B", 10.5, r.sub, wv[1]);
    o.b.w = wv[0]; o.b.h = 17.0 * o.b.lines.size(); o.s.w = wv[1]; o.s.h = 15.0 * o.s.lines.size(); o.sp.w = wv[2];
    { double x = 0, yy = 0; int nrow = r.btns.empty() ? 0 : 1;   // span içi: düğmeler sarılır
      for (size_t i = 0; i < r.btns.size(); i++) { const double b = std::min(bw[i], o.sp.w); if (x > 0 && x + 4 + b > o.sp.w + 1e-9) { x = 0; yy += 29; nrow++; } else if (x > 0) x += 4; o.btns.push_back({x, yy, b, r.btns[i].key, r.btns[i].label}); x += b; }
      o.sp.h = nrow ? 25.0 * nrow + 4.0 * (nrow - 1) : 0; }
    GL::P* P3[3] = {&o.b, &o.s, &o.sp};
    double ly = 6;   // kenar 1 + iç boşluk 5
    for (size_t li = 0; li < lines.size(); li++) {
      double lh = 0; for (int i : lines[li]) lh = std::max(lh, P3[i]->h);
      double x = 9; for (int i : lines[li]) { P3[i]->x = x; P3[i]->y = ly + half(lh - P3[i]->h); x += P3[i]->w + 8; }
      ly += lh + (li + 1 < lines.size() ? 4 : 0);
    }
    o.h = ly + 6;
    return o;
  };
  // ızgara yerleşimi
  std::vector<Item> it(R.size()); std::vector<double> rowH; std::vector<GL> gl(R.size());
  { int row = 0, col = 0;
    for (size_t i = 0; i < R.size(); i++) {
      if (R[i].kind == 0) { if (col) { row++; col = 0; } gl[i] = growLayout(R[i], gridW); it[i] = {row, 0, 0, gridW, gl[i].h}; row++; continue; }
      double h;
      const double cwk = colWs[size_t(col)];
      if (R[i].kind == 1) h = 12 + 17.0 * wrap("Bb", 13, R[i].title, cwk - 18).size() + 17.0 * wrap("B", 10.5, R[i].sub, cwk - 18).size();
      else h = 8 + 16.0 * wrap("B", 11.5, R[i].title, cwk).size();
      it[i] = {row, colXs[size_t(col)], 0, colWs[size_t(col)], h};
      if (++col == ncol) { col = 0; row++; }
    }
    int nrows = 0; for (const Item& t : it) nrows = std::max(nrows, t.row + 1);
    rowH.assign(size_t(nrows), 0); for (const Item& t : it) rowH[size_t(t.row)] = std::max(rowH[size_t(t.row)], t.h);
    std::vector<double> rowY(size_t(nrows), 0); double yy = 0; for (int k = 0; k < nrows; k++) { rowY[size_t(k)] = yy; yy += rowH[size_t(k)] + (k + 1 < nrows ? 4 : 0); }
    for (Item& t : it) t.y = rowY[size_t(t.row)];
    maxScroll_ = std::max(0.0, yy - LH); }
  scroll = std::max(0.0, std::min(scroll, maxScroll_));
  { const IR lr = snap(LX, LY, LW, LH); c.clipRect(float(lr.x), float(lr.y), float(lr.w), float(lr.h)); }
  for (size_t i = 0; i < R.size(); i++) {
    const Row& r = R[i]; const double X = LX + it[i].x, Y = LY + it[i].y - scroll, H = rowH[size_t(it[i].row)];
    if (r.kind == 0) {
      const GL& g = gl[i]; box("", "row", r.title, X, Y, it[i].w, g.h);
      rect(X, Y, it[i].w, g.h, C_ITEM, 1, 1, C_ITEMB);
      box("", "b", r.title, X + g.b.x, Y + g.b.y, g.b.w, g.b.h);
      for (size_t k = 0; k < g.b.lines.size(); k++) text("Bb", 13, g.b.lines[k], X + g.b.x, Y + g.b.y + 17.0 * k, C_B);
      box("", "small", r.sub, X + g.s.x, Y + g.s.y, g.s.w, g.s.h);
      for (size_t k = 0; k < g.s.lines.size(); k++) text("B", 10.5, g.s.lines[k], X + g.s.x, Y + g.s.y + 15.0 * k, C_SMALL);
      for (const auto& b : g.btns) {
        const double bx = X + g.sp.x + b.x, by = Y + g.sp.y + b.y; const std::string id = "x:" + b.key;
        box(id, "btn", b.label, bx, by, b.w, 25); rect(bx, by, b.w, 25, btnId == id ? C_ACTIVE : C_ITEM, 1, 1, C_ITEMB);
        text("B", 11, b.label, bx + 9, by + 5, C_ITEMT);
      }
    } else if (r.kind == 1) {
      const std::string id = "s:" + r.id; box(id, "scene", r.title, X, Y, it[i].w, H);
      rect(X, Y, it[i].w, H, btnId == id ? C_ACTIVE : C_ITEM, 1, 1, r.on ? 0xffd870 : C_ITEMB);
      const auto bl = wrap("Bb", 13, r.title, it[i].w - 18), sl = wrap("B", 10.5, r.sub, it[i].w - 18);
      const double ch2 = 17.0 * (bl.size() + sl.size()), oy = Y + 6 + half(H - 12 - ch2);
      for (size_t k = 0; k < bl.size(); k++) text("Bb", 13, bl[k], X + 9, oy + 17.0 * k, C_B);
      for (size_t k = 0; k < sl.size(); k++) text("B", 10.5, sl[k], X + 9, oy + 17.0 * (bl.size() + k) + 2, C_SMALL);   // small: 13'lük satırda taban çizgisine oturur (2 px aşağı)
    } else {
      box("", "hint", r.title, X, Y + 8, it[i].w, H - 8);
      const auto hl = wrap("B", 11.5, r.title, it[i].w); for (size_t k = 0; k < hl.size(); k++) text("B", 11.5, hl[k], X, Y + 8 + 16.0 * k, C_SMALL);
    }
  }
  c.clearClip();

  // "Seviye seç" (HTML prompt): panelin ortasında küçük sayı kutusu
  if (num_.on) {
    const double bw = 220, bh = 96, bx = std::floor((vw - bw) / 2), by = std::floor((vh - bh) / 2);
    rect(bx, by, bw, bh, C_BOX, 1, 2, C_GOLD);
    text("B", 13, tx("Seviye (1-120):"), bx + 12, by + 10, C_HEAD);
    rect(bx + 12, by + 32, bw - 24, 26, 0x000000, 1, 1, C_TOOLB); text("B", 15, num_.typed, bx + 20, by + 35, 0xffffff);
    const std::string ok = tx("Tamam"), no = tx("İptal");
    box("n:ok", "btn", ok, bx + 12, by + 64, 90, 24); rect(bx + 12, by + 64, 90, 24, btnId == "n:ok" ? C_ACTIVE : C_ITEM, 1, 1, C_ITEMB); text("B", 12, ok, bx + 12 + half(90 - font_.domWidth("B", 12, ok)), by + 68, C_ITEMT);
    box("n:no", "btn", no, bx + bw - 102, by + 64, 90, 24); rect(bx + bw - 102, by + 64, 90, 24, btnId == "n:no" ? C_ACTIVE : C_ITEM, 1, 1, C_ITEMB); text("B", 12, no, bx + bw - 102 + half(90 - font_.domWidth("B", 12, no)), by + 68, C_ITEMT);
  }
}

// ---------------- dokunma ----------------
namespace {
const GmPanel::Box* hitBox(const std::vector<GmPanel::Box>& B, float x, float y, bool numOn, double lx, double ly, double lw, double lh) {
  const GmPanel::Box* h = nullptr;
  for (const auto& b : B) {
    if (b.id.empty()) continue;
    if (numOn && b.id.rfind("n:", 0) != 0) continue;   // sayı kutusu açıkken yalnız onun düğmeleri
    const bool inList = b.kind == "btn" || b.kind == "scene";
    if (inList && b.id.rfind("n:", 0) != 0 && !(x >= lx && x < lx + lw && y >= ly && y < ly + lh)) continue;   // liste dışında kalan (kaydırılmış) düğmeler
    if (x >= b.x && x < b.x + b.w && y >= b.y && y < b.y + b.h) h = &b;
  }
  return h;
}
}  // namespace

void GmPanel::press(float x, float y) {
  px_ = x; py_ = y; ly_ = y; moved_ = 0; dragging_ = false;
  const Box* b = hitBox(boxes, x, y, num_.on, listX_, listY_, listW_, listH_); pressed_ = b ? b->id : "";
}
void GmPanel::move(float x, float y) {
  moved_ += std::fabs(y - ly_) + std::fabs(x - px_) * 0;
  if (!dragging_ && std::fabs(y - py_) > 6 && px_ >= listX_ && px_ < listX_ + listW_ && py_ >= listY_ && py_ < listY_ + listH_) { dragging_ = true; pressed_.clear(); }   // listede sürükleme: kaydır (tıklama iptal)
  if (dragging_) scroll = std::max(0.0, std::min(maxScroll_, scroll - (y - ly_)));
  ly_ = y;
}
void GmPanel::release(World& w, float x, float y) {
  const std::string p = pressed_; pressed_.clear();
  if (dragging_) { dragging_ = false; return; }
  const Box* b = hitBox(boxes, x, y, num_.on, listX_, listY_, listW_, listH_);
  if (!b || b->id != p) { if (!num_.on) editing = false; return; }   // tıklama: basılan ve bırakılan aynı öğe
  tap(w, b->id);
}
void GmPanel::wheel(float dy) { scroll = std::max(0.0, std::min(maxScroll_, scroll + dy)); }
void GmPanel::typed(const std::string& s) {
  if (num_.on) { if (num_.fresh) { num_.typed.clear(); num_.fresh = false; } for (char ch : s) if (ch >= '0' && ch <= '9' && num_.typed.size() < 3) num_.typed += ch; return; }
  if (editing) query += s;
}
bool GmPanel::key(World& w, const std::string& k) {
  if (num_.on) {
    if (k == "Backspace") { num_.fresh = false; if (!num_.typed.empty()) num_.typed.pop_back(); }
    else if (k == "Enter") tap(w, "n:ok");
    else if (k == "Escape") num_.on = false;
    else if (k.size() == 1 && k[0] >= '0' && k[0] <= '9') typed(k);
    return true;
  }
  if (!editing) return false;
  if (k == "Backspace") { while (!query.empty() && (uint8_t(query.back()) & 0xC0) == 0x80) query.pop_back(); if (!query.empty()) query.pop_back(); }
  else if (k == "Enter" || k == "Escape") editing = false;
  return true;
}
bool GmPanel::act(World& w, const std::string& id) {
  for (const Box& b : boxes) if (b.id == id) { tap(w, id); return true; }
  return false;
}

// HTML #gtools / #glist tıklamaları (ui.js gtools dinleyicisi, gmX, data-s). Dünyaya dokunan kısım komut olur (gm <düğme>;
// World::gmAct, sunucuda yönetici denetimi); panelin kendi işi (sekme, kapanma, pencere açma) burada kalır.
void GmPanel::tap(World& w, const std::string& id) {
  editing = id == "gq";
  if (id == "gq") return;
  if (id == "close") { req = "close"; return; }
  if (id == "n:ok") { const int n = num_.typed.empty() ? 0 : std::atoi(num_.typed.c_str()); num_.on = false; if (n) w.cmd({"gm", {"n:" + std::to_string(n)}}); return; }   // HTML: +prompt(...) → if (n) gmLevel(n)
  if (id == "n:no") { num_.on = false; return; }
  if (id.rfind("g:", 0) == 0) {
    if (!w.isGM()) return;
    const std::string a = id.substr(2);
    if (a == "lvset") { num_.on = true; num_.fresh = true; num_.typed = std::to_string(w.P.lv); return; }   // HTML prompt(…, P.lv)
    if (a.rfind("v:", 0) == 0) {
      view = a.substr(2); query.clear(); tabOn_ = view; scroll = 0;
      placeholder_ = view == "maps" ? "Harita ara: ad ya da numara…" : view == "dg" ? "Zindan ara…" : view == "cls" ? "Görev ara…" : "Tür ara…";
      return;
    }
    w.cmd({"gm", {id}}); return;
  }
  if (id.rfind("s:", 0) == 0) { req = "close"; w.cmd({"gm", {id}}); return; }
  if (id.rfind("x:", 0) != 0) return;
  // pencere açanlar yalnız arayüz; paneli kapatanlar (HTML closeAll) önce kapanır
  if (id == "x:pet:win") { req = "pet"; return; }
  if (id == "x:pet:petf" || id == "x:pet:petfs") { req = id == "x:pet:petf" ? "petf:tf" : "petf:sk"; return; }
  static const char* CLOSE[] = {"x:dg:in:", "x:dg:door:", "x:dg:last", "x:dg:leave", "x:tv:axe", "x:tv:near", "x:cls:start80", "x:cls:go:"};
  for (const char* pre : CLOSE) if (id.rfind(pre, 0) == 0) { req = "close"; break; }
  w.cmd({"gm", {id}});
}

std::string GmPanel::dump() const {
  std::string o = "{\"acik\":" + std::string(on ? "true" : "false") + ",\"gorunum\":" + q(view) + ",\"kaydirma\":" + core::jsNumStr(scroll) + ",\"kutular\":[";
  for (size_t i = 0; i < boxes.size(); i++) {
    const Box& b = boxes[i];
    o += std::string(i ? "," : "") + "[" + q(b.kind) + "," + q(b.id) + "," + q(b.text) + "," + core::jsNumStr(b.x) + "," + core::jsNumStr(b.y) + "," + core::jsNumStr(b.w) + "," + core::jsNumStr(b.h) + "]";
  }
  return o + "]}";
}

}  // namespace ui
