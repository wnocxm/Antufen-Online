// Giriş ekranı ve karakter oluşturma: HTML index.html #title / #create, style.css (.cover, .cv, #tword, .carr, #tbook, .cinfo, .ver,
// .cpanel), ui.js (titleOpen, titleTurn, titleGo, bookFrame, renderCreate, drawCreate). Ayrıntı title.h.
#include "ui/title.h"

#include <algorithm>
#include <cmath>

namespace ui {

using engine::Canvas;

namespace {
// kitap kareleri (UIData_2033 içindeki yerleri; HTML BOOK)
struct BookFrame { const char* k; int x, y, w, h; };
const BookFrame BOOK[] = {{"closed", 0, 0, 147, 122}, {"half", 147, 0, 148, 172}, {"open", 0, 342, 236, 130}, {"flipL", 0, 172, 236, 168}, {"flipR", 236, 160, 234, 180},
                          {"p1", 236, 342, 234, 130}, {"p2", 0, 472, 236, 135}, {"p3", 236, 472, 234, 135}, {"p4", 0, 607, 236, 138}, {"p5", 236, 607, 234, 138}};
const BookFrame& bookOf(const std::string& k) { for (const BookFrame& b : BOOK) if (k == b.k) return b; return BOOK[0]; }
float jsRoundF(float v) { return std::floor(v + 0.5f); }   // tarayıcı kutu kenarlarını piksele oturtur

// CSS text-shadow bulanıklığı (0 2px 3px #000): yazının örtüsü Gauss ile yayılır (σ = yarıçap / 2), siyah olarak altına
void blurShadow(Canvas& c, Fonts& F, Face* f, const std::string& s, float x, float y, Align al, float sigma, float dy) {
  if (!F.enabled || s.empty()) return;
  const float w = F.width(f, s); const int pad = int(std::ceil(sigma * 3)) + 2;
  const float left = al == CENTER ? x - w / 2 : al == RIGHT ? x - w : x;
  const int X0 = int(std::floor(left)) - pad, Y0 = int(std::floor(y + dy - f->size * 1.2f)) - pad, BW = int(std::ceil(w)) + 2 * pad + 2, BH = int(std::ceil(f->size * 1.6f)) + 2 * pad;
  Canvas t; t.resize(BW, BH); t.fill(255, 255, 255);
  TextStyle st; st.color = 0x000000; st.align = al; F.draw(t, f, s, x - X0, y + dy - Y0, st);
  std::vector<float> a(size_t(BW) * BH), b(a.size());
  for (int i = 0; i < BW * BH; i++) a[size_t(i)] = (255 - t.img.px[size_t(i) * 4]) / 255.f;
  const int R = int(std::ceil(sigma * 3)); std::vector<float> k(size_t(2 * R + 1)); float ks = 0;
  for (int i = -R; i <= R; i++) { k[size_t(i + R)] = std::exp(-(i * i) / (2 * sigma * sigma)); ks += k[size_t(i + R)]; }
  for (float& v : k) v /= ks;
  for (int yy = 0; yy < BH; yy++) for (int xx = 0; xx < BW; xx++) { float v = 0; for (int i = -R; i <= R; i++) { const int q = std::clamp(xx + i, 0, BW - 1); v += a[size_t(yy * BW + q)] * k[size_t(i + R)]; } b[size_t(yy * BW + xx)] = v; }
  for (int yy = 0; yy < BH; yy++) for (int xx = 0; xx < BW; xx++) { float v = 0; for (int i = -R; i <= R; i++) { const int q = std::clamp(yy + i, 0, BH - 1); v += b[size_t(q * BW + xx)] * k[size_t(i + R)]; } a[size_t(yy * BW + xx)] = v; }
  for (int yy = 0; yy < BH; yy++) for (int xx = 0; xx < BW; xx++) if (a[size_t(yy * BW + xx)] > 0.002f) c.blend(X0 + xx, Y0 + yy, 0x000000, a[size_t(yy * BW + xx)]);
}
// DOM yazısı: taban çizgisi = satır kutusunun üstü + boy (Alegreya: yükselme 1 em, satır yüksekliği 1,31 em)
void domText(Canvas& c, Fonts& F, const std::string& fam, float size, const std::string& s, float x, float base, uint32_t col, Align al, int shadow = 0) {
  Face* f = F.face(fam, size); TextStyle st; st.align = al;
  if (shadow) { st.color = 0x000000; F.draw(c, f, s, x + 1, base + 1, st); }   // text-shadow: 1px 1px 0 #000
  st.color = col; F.draw(c, f, s, x, base, st);
}
}  // namespace

// ---------------- giriş ekranı ----------------
void Title::open(bool hasSave, const std::string& saveInfo) {
  hasSave_ = hasSave; items_.clear();
  if (hasSave) items_.push_back({"Devam Et", "p1", saveInfo, "continue"});
  items_.push_back({"Yeni Karakter", "p2", "Bu telefona kaydedilir", "new"});
  items_.push_back({"Çevrimiçi", "p3", "Sunucuda diğer oyuncularla", "online"});
  items_.push_back({"Dil", "p4", "Türkçe → English", "lang"});
  idx_ = 0; sure_ = false; busy_ = true; word_.clear(); info_.clear(); frame_ = "closed";
  if (music) music("cover.mid");
  // kitap açılır: kapalı → yarı açık (350 ms) → açık (520 ms) → ilk sayfa (700 ms)
  steps_ = {{0.35, 0}, {0.52, 1}, {0.70, 2}};
}
void Title::show() { const Item& it = items_[idx_]; word_ = it.label; frame_ = it.page; info_ = it.info; busy_ = false; }
void Title::update(double dt) {
  for (Step& s : steps_) s.t -= dt;
  while (!steps_.empty()) {
    auto it = std::min_element(steps_.begin(), steps_.end(), [](const Step& a, const Step& b) { return a.t < b.t; });
    if (it->t > 1e-9) break;   // (kayan nokta: 0,35 + 0,17 = 0,52)
    const int k = it->kind; steps_.erase(it);
    if (k == 0) frame_ = "half"; else if (k == 1) frame_ = "open"; else show();
  }
}
void Title::settle() { for (Step& s : steps_) s.t = 0; update(0); }
std::string Title::turn(int d) {
  if (busy_ || items_.empty()) return "";
  busy_ = true; sure_ = false; if (sfx) sfx("skill_pageflip", 1);
  idx_ = (idx_ + items_.size() + size_t(d + int(items_.size()))) % items_.size();
  word_ = items_[idx_].label; info_.clear(); frame_ = d > 0 ? "flipR" : "flipL";
  steps_.push_back({0.17, 2});
  return "";
}
std::string Title::go() {
  if (busy_ || items_.empty()) return "";
  const Item& it = items_[idx_];
  if (it.act == "new" && hasSave_ && !sure_) { sure_ = true; info_ = "Eski karakter silinecek. Onaylamak için tekrar dokun."; return ""; }
  if (it.act == "online") { info_ = "Çevrimiçi oyun sonraki adımlarda (sunucu)."; return ""; }
  if (it.act == "lang") { info_ = "İngilizce sonraki adımlarda."; return ""; }
  return it.act;
}
std::string Title::key(const std::string& k) {
  if (k == "ArrowLeft") return turn(-1);
  if (k == "ArrowRight") return turn(1);
  if (k == "Enter") return go();
  return "";
}
void Title::bookRect(float& x, float& y, float& w, float& h, int& sx, int& sy) const {
  const BookFrame& b = bookOf(frame_); w = float(b.w); h = float(b.h); x = jsRoundF(W_ / 2 - w / 2); y = float(352 - b.h); sx = b.x; sy = b.y;
}
void Title::press(float x, float y) { px_ = x; py_ = y; down_ = true; }
std::string Title::release(float x, float y) {
  if (!down_) return "";
  down_ = false;
  const float dx = x - px_; std::string act;
  if (std::fabs(dx) > 50) act = turn(dx < 0 ? 1 : -1);   // HTML: kaydırma (pointerup'ta, tıklamadan önce)
  // tıklama: basılan ve bırakılan öğe aynıysa (HTML click); oklar ve kitap düğme (sayfadaki her düğme "menusel" çalar), sözcük değil
  float bx, by, bw, bh; int sx, sy; bookRect(bx, by, bw, bh, sx, sy);
  auto which = [&](float X, float Y) {
    auto in = [&](float rx, float ry, float rw, float rh) { return X >= rx && X < rx + rw && Y >= ry && Y < ry + rh; };
    if (in(W_ / 2 - 128, 156, 30, 30)) return 1;
    if (in(W_ / 2 + 98, 156, 30, 30)) return 2;
    if (in(bx, by, bw, bh)) return 3;
    if (in(W_ / 2 - 95, 150, 190, 40)) return 4;
    return 0;
  };
  const int a = which(px_, py_);
  if (!a || a != which(x, y)) return act;
  if (a != 4 && sfx) sfx("menusel", 0.6);
  const std::string r = a == 1 ? turn(-1) : a == 2 ? turn(1) : go();
  return r.empty() ? act : r;
}
void Title::draw(Canvas& c) {
  const float W = float(c.w()), H = 360; W_ = W;
  // .cover: koyu zemin + kapak dokusu (center/cover, yumuşak büyütme)
  c.fill(0x0a, 0x04, 0x03);
  if (const core::Image* cv = forms_.image("ui/AnrufenCoverUI_Resource_7000.png")) {
    const float k = std::max(W / float(cv->w), H / float(cv->h)), dw = cv->w * k, dh = cv->h * k;
    c.drawImage(*cv, 0, 0, float(cv->w), float(cv->h), (W - dw) / 2, (H - dh) / 2, dw, dh, 1, true);
  }
  // .cover::before: ortada .15, köşelerde .7 karartma (elips, en uzak köşeye; CSS radial-gradient)
  { const float rx = W / 2 * std::sqrt(2.f), ry = H / 2 * std::sqrt(2.f);
    for (int y = 0; y < c.h(); y++) for (int x = 0; x < c.w(); x++) {
      const float u = (x + 0.5f - W / 2) / rx, v = (y + 0.5f - H / 2) / ry, t = std::min(1.f, std::sqrt(u * u + v * v));
      c.blend(x, y, 0x000000, 0.15f + 0.55f * t);
    } }
  // .cv içeriği (DOM sırasıyla): logo, sol ok, sözcük, sağ ok, kitap, bilgi, sürüm
  if (const core::Image* lg = forms_.image("ui/UIData_2067.png")) c.drawImage(*lg, 0, 0, float(lg->w), float(lg->h), W / 2 - 104, 14, 208, 78, 1, false);
  const core::Image* ui = forms_.image("ui/UIData_2033.png");
  // oklar: UIData_2033 iki kat (1030×1490) en yakın komşuyla; sol okun sağ 8 px'i, sağ okun sol 8 px'i kırpılı (clip-path)
  auto arrow = [&](float bx, int ox, int x0, int x1) {
    if (!ui) return;
    const int X = int(jsRoundF(bx));
    for (int dy = 0; dy < 30; dy++) for (int dx = x0; dx < x1; dx++) {
      const int gx = dx - ox;
      if (gx < 0) continue;
      const int sx = gx >> 1, sy = (dy + 248) >> 1;
      if (sx >= ui->w || sy >= ui->h) continue;
      const uint8_t* q = ui->at(sx, sy);
      if (!q[3]) continue;
      c.blend(X + dx, 156 + dy, (uint32_t(q[0]) << 16) | (uint32_t(q[1]) << 8) | q[2], q[3] / 255.f);
    }
  };
  arrow(W / 2 - 128, 7, 0, 22);
  if (!word_.empty()) {
    Face* f = font_.face("Bb", 24); const float base = 178;
    blurShadow(c, font_, f, word_, W / 2, base, CENTER, 1.5f, 2);
    TextStyle st; st.align = CENTER; st.color = 0x3a0a00;
    for (const auto& o : {std::pair<int, int>{1, 1}, {-1, 1}, {1, -1}, {-1, -1}}) font_.draw(c, f, word_, W / 2 + o.first, base + o.second, st);
    st.color = 0xff8a2a; font_.draw(c, f, word_, W / 2, base, st);
  }
  arrow(W / 2 + 98, -9, 8, 30);
  if (ui) { float bx, by, bw, bh; int sx, sy; bookRect(bx, by, bw, bh, sx, sy); c.blit(*ui, sx, sy, int(bw), int(bh), int(bx), int(by)); }
  if (!info_.empty()) domText(c, font_, "B", 11, info_, W / 2, 137, 0xe8d8b0, CENTER, 1);
  if (!version.empty()) domText(c, font_, "B", 9, version, W - 6, 354, 0x8a7a6a, RIGHT);
}

// ---------------- karakter oluşturma ----------------
void Create::open() { cls = "战士"; race = "人类"; sex = "male"; face = 1; name = "Kahraman"; msg.clear(); editing = false; if (music) music("cover.mid"); }
std::string Create::finalName() const {
  std::string s = name; const char* ws = " \t\n\r";
  s.erase(0, s.find_first_not_of(ws) == std::string::npos ? s.size() : s.find_first_not_of(ws)); s.erase(s.find_last_not_of(ws) + 1);
  if (s.empty()) s = "Kahraman";
  const std::vector<uint32_t> u = utf8(s); if (u.size() <= 12) return s;   // HTML slice(0, 12)
  std::string o; for (size_t i = 0; i < 12; i++) { const uint32_t c = u[i];
    if (c < 0x80) o += char(c); else if (c < 0x800) { o += char(0xC0 | (c >> 6)); o += char(0x80 | (c & 63)); }
    else if (c < 0x10000) { o += char(0xE0 | (c >> 12)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); }
    else { o += char(0xF0 | (c >> 18)); o += char(0x80 | ((c >> 12) & 63)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); } }
  return o;
}
void Create::text(const std::string& s) {
  if (!editing) return;
  for (uint32_t ch : utf8(s)) {
    if (ch < 32 || utf8(name).size() >= 12) continue;   // HTML maxlength 12
    std::string one; const uint32_t c = ch;
    if (c < 0x80) one += char(c); else if (c < 0x800) { one += char(0xC0 | (c >> 6)); one += char(0x80 | (c & 63)); }
    else if (c < 0x10000) { one += char(0xE0 | (c >> 12)); one += char(0x80 | ((c >> 6) & 63)); one += char(0x80 | (c & 63)); }
    else continue;
    name += one;
  }
}
bool Create::key(const std::string& k) {
  if (!editing) return false;
  if (k == "Backspace") { if (!name.empty()) { size_t i = name.size() - 1; while (i > 0 && (uint8_t(name[i]) & 0xC0) == 0x80) i--; name.erase(i); } return true; }
  if (k == "Enter" || k == "Escape") { editing = false; return true; }
  return false;
}
std::string Create::tap(float x, float y) {
  for (const Hit& h : hits_) if (x >= h.x && x < h.x + h.w && y >= h.y && y < h.y + h.h) {
    editing = h.id == "name"; caretT_ = 0;
    if (!editing && sfx) sfx("menusel", 0.6);   // sayfadaki düğmeler (ad kutusu düğme değil)
    if (h.id.rfind("cls:", 0) == 0) cls = h.id.substr(4);
    else if (h.id.rfind("race:", 0) == 0) race = h.id.substr(5);
    else if (h.id.rfind("sex:", 0) == 0) sex = h.id.substr(4);
    else if (h.id.rfind("face:", 0) == 0) face = std::atoi(h.id.c_str() + 5);
    else if (h.id == "start") return "start";
    return "";
  }
  editing = false; return "";
}
void Create::draw(Canvas& c, double nowMs) {
  const float W = float(c.w());
  // tuval: koyu zemin, sol üstte logo, sağda büyük önizleme (HTML drawCreate)
  c.fill(0x0c, 0x08, 0x06);
  if (const core::Image* lg = forms_.image("ui/UIData_2067.png")) c.drawImage(*lg, 0, 0, float(lg->w), float(lg->h), 16, 8, 192 * 0.8f, 72 * 0.8f, 1, false);
  const std::string dk = cls + race + sex;
  if (dk != dollKey_) { engine::Look l; l.cls = cls; l.race = race; l.sex = sex; doll_.set(as_, l); dollKey_ = dk; }
  doll_.drawScaled(c, "comm", 2 + int(std::floor(nowMs / 2500)) % 2, nowMs / 120, W * 0.73f, 250, 2.2f, false);
  // panel (.cpanel): x 14, üstü 56, genişlik min(380, %56), en çok 300 yüksek; kenar 2 px, iç boşluk 10/12, satırlar 7 px aralıklı
  hits_.clear();
  const float PW = std::min(380.f, W * 0.56f), PX = 14, PY = 56, PH = 300;
  const float L = jsRoundF(PX), R = jsRoundF(PX + PW);
  c.fillRect(L, PY, R - L, PH, 0x0e0a06, 0.9f);
  c.fillRect(L, PY, R - L, 2, 0x8a6a30); c.fillRect(L, PY + PH - 2, R - L, 2, 0x8a6a30); c.fillRect(L, PY, 2, PH, 0x8a6a30); c.fillRect(R - 2, PY, 2, PH, 0x8a6a30);
  c.clipRect(L + 2, PY + 2, R - L - 4, PH - 4);
  const float CX = PX + 2 + 12, CW = PW - 4 - 24;   // içerik: x 28, genişlik 330,39 (640'ta)
  const core::Image* bOff = forms_.image("ui/AnbufenUI_Resource_7032.png"); const core::Image* bOn = forms_.image("ui/AnbufenUI_Resource_7033.png");
  // düğme (.cpanel button): görsel kutuya gerilir (yumuşak), 1 px kenar; seçili: 7033, siyah kalın yazı, sarı kenar
  auto button = [&](float x, float y, float w, float h, const std::string& label, bool on, const std::string& id, float fs = 13, bool bold = false) {
    const float X0 = jsRoundF(x), X1 = jsRoundF(x + w), Y0 = jsRoundF(y), Y1 = jsRoundF(y + h);
    if (const core::Image* im = on ? bOn : bOff) c.drawImage(*im, 0, 0, float(im->w), float(im->h), X0 + 1, Y0 + 1, X1 - X0 - 2, Y1 - Y0 - 2, 1, true);
    c.strokeRect(X0 + 0.5f, Y0 + 0.5f, X1 - X0 - 1, Y1 - Y0 - 1, 1, on ? 0xffd870 : 0x5a4424);
    domText(c, font_, on || bold ? "Bb" : "B", fs, label, x + w / 2, y + h / 2 - (fs == 13 ? 17.f : 20.f) / 2 + fs, on ? 0x000000 : 0xe8dcc0, CENTER);
    hits_.push_back({x, y, w, h, id});
  };
  auto bw = [&](const std::string& s, bool on) { return font_.width(on ? "Bb" : "B", 13, s) + 22; };
  float y = PY + 2 + 10;   // 68
  // Ad: etiket metni + giriş kutusu (siyah, 1 px kenar #6a5028, beyaz yazı, iç boşluk 5/8)
  { const float lw = font_.width("B", 13, "Ad"); domText(c, font_, "B", 13, "Ad", CX, y + 6 + 13, 0xe8dcc0, LEFT);
    const float ix = CX + lw + 5, iw = CW - lw - 5; const float X0 = jsRoundF(ix), X1 = jsRoundF(ix + iw);
    c.fillRect(X0, y, X1 - X0, 29, 0x000000); c.strokeRect(X0 + 0.5f, y + 0.5f, X1 - X0 - 1, 28, 1, 0x6a5028);
    c.clipRect(X0 + 1, y + 1, std::min(X1 - 1, R - 2) - X0 - 1, 27);
    domText(c, font_, "B", 13, name, ix + 9, y + 6 + 13, 0xffffff, LEFT);
    if (editing && std::fmod(caretT_ += 1 / 60.0, 1.0) < 0.5) c.fillRect(ix + 9 + font_.width("B", 13, name) + 0.5f, y + 6, 1, 17, 0xffffff);
    c.clearClip(); c.clipRect(L + 2, PY + 2, R - L - 4, PH - 4);   // kırpma iç içe daralır: önce kaldır
    hits_.push_back({ix, y, iw, 29, "name"}); y += 29 + 7; }
  // Sınıf, Irk, Cinsiyet: etiket (62 px) + düğmeler (5 px aralık)
  const std::vector<std::pair<std::string, std::vector<std::pair<std::string, std::string>>>> rows = {
      {"Sınıf", {{"cls:战士", "Savaşçı"}, {"cls:法师", "Büyücü"}, {"cls:牧师", "Kutsal Elçi"}}},
      {"Irk", {{"race:人类", "İnsan"}, {"race:精灵", "Gece Elfi"}}},
      {"Cinsiyet", {{"sex:male", "Erkek"}, {"sex:fema", "Kadın"}}}};
  for (const auto& row : rows) {
    domText(c, font_, "B", 13, row.first, CX, y + 6 + 13, 0xd8b870, LEFT);
    float x = CX + 62 + 5;
    for (const auto& b : row.second) {
      const std::string v = b.first.substr(b.first.find(':') + 1);
      const bool on = (b.first[0] == 'c' && cls == v) || (b.first[0] == 'r' && race == v) || (b.first[0] == 's' && sex == v);
      const float w = bw(b.second, on); button(x, y, w, 29, b.second, on, b.first); x += w + 5;
    }
    y += 29 + 7;
  }
  // Yüz: 8 portre (38×38, 3 px aralık, sığmayan alt satıra); seçili sarı kenarlı
  { const float fx0 = CX + 62 + 5, avail = CW - 67; const int per = std::max(1, int((avail + 3) / 41)); const int rowsN = (8 + per - 1) / per;
    const float rh = rowsN * 38 + (rowsN - 1) * 3;
    domText(c, font_, "B", 13, "Yüz", CX, y + (rh - 17) / 2 + 13, 0xd8b870, LEFT);
    const int g = (race == "人类" ? 0 : 2) + (sex == "male" ? 1 : 2);
    for (int i = 0; i < 8; i++) {
      const float x = fx0 + (i % per) * 41, yy = y + (i / per) * 41; const bool on = face == i + 1;
      c.fillRect(x, yy, 38, 38, 0x000000);
      if (on && bOn) c.drawImage(*bOn, 0, 0, float(bOn->w), float(bOn->h), x + 1, yy + 1, 36, 36, 1, true);
      if (const core::Image* im = forms_.image("ui/Portrait_" + std::to_string(g) + "00" + std::to_string(i + 1) + ".png")) c.drawImage(*im, 0, 0, float(im->w), float(im->h), x + 1, yy + 1, 36, 36, 1, true);
      c.strokeRect(x + 0.5f, yy + 0.5f, 37, 37, 1, on ? 0xffd870 : 0x5a4424);
      hits_.push_back({x, yy, 38, 38, "face:" + std::to_string(i + 1)});
    }
    y += rh + 7; }
  // Oyuna başla: 15 px kalın, siyah yazı, 7033, sarı kenar; 4 px fazladan üst boşluk
  y += 4; button(CX, y, CW, 40, "Oyuna başla", true, "start", 15, true); y += 40 + 7;
  if (!msg.empty()) domText(c, font_, "B", 11.5f, msg, CX, y + 8 + 11.5f, 0xa89878, LEFT);   // #cmsg (.hint)
  c.clearClip();
}

}  // namespace ui
