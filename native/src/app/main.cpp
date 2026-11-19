// anrufen: pencereli oyun (SDL2). Tuval 360 piksel yüksekliğinde çizilir (HTML'deki gibi), pencereye büyütülür.
// Akış (HTML ui.js boot): giriş ekranı (kayıt varsa Devam Et) → Yeni Karakter → karakter oluşturma → oyun. Kayıt HTML'dekiyle aynı JSON,
// kullanıcının uygulama klasöründe (SDL_GetPrefPath: Windows %APPDATA%/Anrufen/AnrufenOnline, Android uygulama verisi) "kayit.json";
// 8 sn'de bir, olaylarda (görev, alışveriş, harita …) ve çıkışta/arka plana geçerken yazılır. Ayarlar › Giriş ekranına dön / Yeni karakter.
//   anrufen [--veri <klasör|paket.gdp>]… [--kayit <dosya>]
// Geliştirme kısa yolu (giriş ekranı atlanır, kayıt yazılmaz): [--sahne <numara>] [--sinif 战士|法师|牧师] [--irk 人类|精灵]
//   [--cinsiyet male|fema] [--seviye <n>] [--uzmanlik 0|1] [--ad <ad>]   (seviye: puanlar oyuncu gibi dağıtılır; 40'ta sınıf, 80'de ikincisi)
// Dokunma / fare: oyun ekranı (HUD) düğmeleri, sol altta ejderha = yürüme kolu, dünyada canavara dokun (ikinci dokunuş saldırır),
// kişiye dokun (ikinci dokunuş ya da sağ alttaki konuşma düğmesi konuşur), sağ alt halka: saldırı, beceriler, iksirler.
// Tuşlar (HTML gibi): ok tuşları / WASD yürü, boşluk saldır, 1-6 beceri, Q can iksiri, E mana iksiri, Tab hedef değiştir,
// F12 ekran görüntüsü (anrufen_ekran.png), Esc pencereyi kapatır / çıkış. Giriş ekranında ←/→ sözcük, Enter seç; oluşturmada ad kutusu.
// Veri verilmezse sırayla: veri/oyun.gdp, ../veri/oyun.gdp, ../../www/assets, ../../../www/assets, ../www/assets, www/assets.
#include <SDL.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <memory>
#include <string>
#include <vector>

#include "core/json.h"
#include "core/png.h"
#include "engine/assets.h"
#include "engine/balance.h"
#include "engine/vfs.h"
#include "engine/world.h"
#include "godat/godat.h"
#include "ui/font.h"
#include "ui/forms.h"
#include "ui/hud.h"
#include "ui/title.h"

using namespace engine;

namespace {
// derleme saatinden sürüm: AAGGSSDD (HTML ?v= gibi)
std::string buildVersion() {
  static const char* M = "JanFebMarAprMayJunJulAugSepOctNovDec"; const char* d = __DATE__; const char* t = __TIME__;
  const int mon = int((std::strstr(M, std::string(d, 3).c_str()) - M) / 3) + 1, day = std::atoi(d + 4);
  char b[32]; std::snprintf(b, sizeof b, "Sürüm %02d%02d%c%c%c%c", mon, day, t[0], t[1], t[3], t[4]); return b;
}
std::string readText(const std::string& f) {
  try { const godat::Bytes b = godat::readFile(f); return std::string(b.begin(), b.end()); } catch (...) { return ""; }
}
// kayıt: önce geçici dosyaya, sonra yerine (yazarken kapanırsa eski kayıt bozulmaz)
void writeSave(const std::string& f, const std::string& text) {
  try { godat::writeFile(f + ".yeni", godat::Bytes(text.begin(), text.end())); std::error_code ec; std::filesystem::rename(f + ".yeni", f, ec);
    if (ec) godat::writeFile(f, godat::Bytes(text.begin(), text.end())); } catch (const std::exception& e) { std::fprintf(stderr, "Kayıt yazılamadı: %s\n", e.what()); }
}
}  // namespace

int main(int argc, char** argv) {
  std::vector<std::string> data; std::string scene, name = "Kahraman", savePath; Look look; int level = 1, spec = 0; bool dev = false;
  for (int i = 1; i + 1 < argc; i += 2) {
    std::string k = argv[i], v = argv[i + 1];
    if (k == "--veri") data.push_back(v); else if (k == "--kayit") savePath = v;
    else { dev = true;
      if (k == "--sahne") scene = v;
      else if (k == "--sinif") look.cls = v; else if (k == "--irk") look.race = v; else if (k == "--cinsiyet") look.sex = v;
      else if (k == "--seviye") level = std::atoi(v.c_str()); else if (k == "--uzmanlik") spec = std::atoi(v.c_str()) ? 1 : 0;
      else if (k == "--ad") name = v; }
  }
  // veri aranır: oyunun yanındaki paket (Visual Studio programı build/Release içine koyar), sonra geliştirme klasörü
  if (data.empty()) for (const char* p : {"veri/oyun.gdp", "../veri/oyun.gdp", "../../www/assets", "../../../www/assets", "../www/assets", "www/assets"})
    if (std::filesystem::exists(p)) { data.push_back(p); break; }
  Vfs vfs; Assets assets; Balance bal; ui::Fonts fonts;
  try {
    for (const std::string& d : data) { if (d.size() > 4 && d.substr(d.size() - 4) == ".gdp") vfs.mountPack(d); else vfs.mountDir(d); }
    assets.load(vfs); bal.load(vfs, assets.D()); fonts.load(vfs);
  } catch (const std::exception& e) { std::fprintf(stderr, "Veri yüklenemedi: %s\n", e.what()); return 1; }
  rng().seed(uint32_t(SDL_GetPerformanceCounter()));
  ui::Forms forms(assets, fonts);
  try { forms.load(vfs); } catch (const std::exception& e) { std::fprintf(stderr, "Ekran tanımları yüklenemedi: %s\n", e.what()); return 1; }

  SDL_SetHint(SDL_HINT_TOUCH_MOUSE_EVENTS, "0");   // dokunma ayrıca işlenir (fareye çevrilmesin)
  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) { std::fprintf(stderr, "SDL: %s\n", SDL_GetError()); return 1; }
  if (savePath.empty()) { if (char* pp = SDL_GetPrefPath("Anrufen", "AnrufenOnline")) { savePath = std::string(pp) + "kayit.json"; SDL_free(pp); } else savePath = "kayit.json"; }

  // oyun durumu: dünya ve arayüzü her "sayfa yenilemede" (giriş ekranına dönüş) baştan kurulur (HTML location.reload)
  std::unique_ptr<World> world; std::unique_ptr<ui::Hud> hud;
  ui::Title title(assets, fonts, forms); ui::Create create(assets, fonts, forms); title.version = buildVersion();
  enum Mode { TITLE, CREATE, PLAY } mode = TITLE;
  auto fresh = [&]() {
    world = std::make_unique<World>(assets, bal); hud = std::make_unique<ui::Hud>(assets, fonts, forms);
    if (!dev) world->saveFn = [&savePath](const std::string& t) { writeSave(savePath, t); };
  };
  // giriş ekranı: kayıt varsa okunur (HTML load → fixSave) ve Devam Et'te gösterilir
  auto toTitle = [&]() {
    fresh(); bool has = false; std::string info;
    const std::string t = readText(savePath);
    if (!t.empty()) { try { has = world->loadSave(core::Json::parse(t)); } catch (...) { has = false; } }
    if (has) info = world->P.name + " · " + world->clsName() + " · Seviye " + std::to_string(world->P.lv);
    title.open(has, info); mode = TITLE;
  };
  auto play = [&]() {
    try { world->start(); } catch (const std::exception& e) { std::fprintf(stderr, "Sahne yüklenemedi: %s\n", e.what()); return false; }
    mode = PLAY; return true;
  };
  if (dev) {   // geliştirme kısa yolu: verilen karakter doğrudan oyunda
    fresh(); World& w = *world;
    w.newChar(name, look.cls, look.race, look.sex, 1);
    if (level > 1) { w.setLevel(level); w.P.adv = level >= 80 ? 2 : level >= 40 ? 1 : 0; w.P.sk.clear(); w.P.sp = 0; w.skillAutoSpend(w.P.lv + 1, spec); w.P.hp = w.P.mp = 1e9; }
    if (scene.empty()) { if (!play()) return 1; }
    else { try { w.loadScene(scene); } catch (const std::exception& e) { std::fprintf(stderr, "Sahne yüklenemedi: %s\n", e.what()); return 1; } w.autoQuests(); mode = PLAY; }   // sahnenin girişi
  } else toTitle();

  SDL_Window* win = SDL_CreateWindow("Anrufen Online", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
  SDL_Renderer* ren = win ? SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC) : nullptr;
  if (!ren && win) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
  if (!win || !ren) { std::fprintf(stderr, "Pencere açılamadı: %s\n", SDL_GetError()); return 1; }
  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");   // keskin pikseller (HTML imageSmoothingEnabled = false)

  Canvas canvas; SDL_Texture* tex = nullptr; int texW = 0, texH = 0;
  Uint64 last = SDL_GetPerformanceCounter(); const Uint64 t0 = last; bool run = true; size_t shown = 0;
  // pencere koordinatı → mantıksal tuval koordinatı
  auto logical = [&](float wx, float wy, float& x, float& y) { int ww, wh; SDL_GetWindowSize(win, &ww, &wh); x = wx * float(canvas.w()) / float(std::max(1, ww)); y = wy * float(VH) / float(std::max(1, wh)); };
  auto keyName = [](SDL_Keycode k) -> std::string {
    return k >= SDLK_0 && k <= SDLK_9 ? std::string(1, char('0' + (k - SDLK_0))) : k >= SDLK_KP_1 && k <= SDLK_KP_9 ? std::string(1, char('1' + (k - SDLK_KP_1))) : k == SDLK_KP_0 ? "0"
      : k == SDLK_BACKSPACE ? "Backspace" : (k == SDLK_RETURN || k == SDLK_KP_ENTER) ? "Enter" : k == SDLK_UP ? "ArrowUp" : k == SDLK_DOWN ? "ArrowDown" : k == SDLK_LEFT ? "ArrowLeft" : k == SDLK_RIGHT ? "ArrowRight"
      : (k == SDLK_PLUS || k == SDLK_KP_PLUS) ? "+" : (k == SDLK_MINUS || k == SDLK_KP_MINUS) ? "-" : k == SDLK_ESCAPE ? "Escape" : "";
  };
  auto startNew = [&]() {   // oluşturmadaki "Oyuna başla" (HTML newSave + face; start)
    world->newChar(create.finalName(), create.cls, create.race, create.sex, create.face); create.editing = false;
    if (!play()) toTitle();
  };
  auto titleAct = [&](const std::string& a) {
    if (a == "continue") { if (!play()) toTitle(); }
    else if (a == "new") { std::error_code ec; std::filesystem::remove(savePath, ec); fresh(); create.open(); mode = CREATE; }   // HTML: localStorage.removeItem
  };
  while (run) {
    SDL_Event ev;
    while (SDL_PollEvent(&ev)) {
      if (ev.type == SDL_QUIT) run = false;
      if (ev.type == SDL_APP_WILLENTERBACKGROUND || ev.type == SDL_APP_TERMINATING) { if (mode == PLAY) world->save(); }   // telefon: arka plana geçerken kaydet
      float x, y;
      if (mode != PLAY) {   // giriş ekranı / oluşturma: fare, dokunma, tuşlar, yazı
        bool down = false, up = false;
        if (ev.type == SDL_MOUSEBUTTONDOWN && ev.button.button == SDL_BUTTON_LEFT) { logical(float(ev.button.x), float(ev.button.y), x, y); down = true; }
        if (ev.type == SDL_MOUSEBUTTONUP && ev.button.button == SDL_BUTTON_LEFT) { logical(float(ev.button.x), float(ev.button.y), x, y); up = true; }
        if (ev.type == SDL_FINGERDOWN || ev.type == SDL_FINGERUP) { x = ev.tfinger.x * float(canvas.w()); y = ev.tfinger.y * float(VH); (ev.type == SDL_FINGERDOWN ? down : up) = true; }
        if (mode == TITLE) {
          if (down) title.press(x, y);
          if (up) titleAct(title.release(x, y));
          if (ev.type == SDL_KEYDOWN) { const std::string kn = keyName(ev.key.keysym.sym); if (ev.key.keysym.sym == SDLK_ESCAPE) run = false; else if (!kn.empty()) titleAct(title.key(kn)); }
        } else {
          if (up && create.tap(x, y) == "start") startNew();
          if (ev.type == SDL_TEXTINPUT) create.text(ev.text.text);
          if (ev.type == SDL_KEYDOWN) { const std::string kn = keyName(ev.key.keysym.sym); if (!create.key(kn) && ev.key.keysym.sym == SDLK_ESCAPE) toTitle(); }
        }
        continue;
      }
      if (ev.type == SDL_TEXTINPUT && hud->win.isOpen()) { for (const char* ch = ev.text.text; *ch; ch++) if (*ch >= '0' && *ch <= '9') hud->win.key(std::string(1, *ch)); continue; }   // ekran klavyesi: adet
      if (ev.type == SDL_KEYDOWN) {
        const SDL_Keycode k = ev.key.keysym.sym;
        if (hud->win.isOpen()) {   // açık onay/adet kutusu tuşları alır (oyun kısayollarına gitmez)
          std::string kn = keyName(k); if (kn == "ArrowLeft" || kn == "ArrowRight") kn.clear();
          if (!kn.empty() && SDL_IsTextInputActive() && kn.size() == 1 && kn[0] >= '0' && kn[0] <= '9') kn.clear();   // rakam metin olayından gelir
          if (!kn.empty() && hud->win.key(kn)) continue;
        }
        if (k == SDLK_ESCAPE) { if (hud->win.isOpen()) hud->closeAll(); else run = false; }
        if (k == SDLK_F12) godat::writeFile("anrufen_ekran.png", core::encodePNG(canvas.img));
        World& w = *world;
        if (k == SDLK_SPACE) { int t = w.target(); if (t < 0 || w.ents[size_t(t)].kind != Ent::MOB || w.ents[size_t(t)].dead) t = w.nearestMob(9); if (t >= 0) w.setTarget(t, true); else w.note("Yakında hedef yok."); }
        if (k >= SDLK_1 && k <= SDLK_6) w.useSkill(int(k - SDLK_1));
        if (k == SDLK_q) w.useItem("hp1");
        if (k == SDLK_e) w.useItem("mp1");
        if (k == SDLK_TAB) w.cycleTarget();
      }
      if (ev.type == SDL_MOUSEBUTTONDOWN && ev.button.button == SDL_BUTTON_LEFT) { logical(float(ev.button.x), float(ev.button.y), x, y); hud->press(*world, -1, x, y); }
      if (ev.type == SDL_MOUSEMOTION && (ev.motion.state & SDL_BUTTON_LMASK)) { logical(float(ev.motion.x), float(ev.motion.y), x, y); hud->move(-1, x, y); }
      if (ev.type == SDL_MOUSEBUTTONUP && ev.button.button == SDL_BUTTON_LEFT) { logical(float(ev.button.x), float(ev.button.y), x, y); hud->release(*world, -1, x, y); }
      if (ev.type == SDL_FINGERDOWN || ev.type == SDL_FINGERMOTION || ev.type == SDL_FINGERUP) {
        x = ev.tfinger.x * float(canvas.w()); y = ev.tfinger.y * float(VH); const int id = int(ev.tfinger.fingerId & 0x7fffffff);
        if (ev.type == SDL_FINGERDOWN) hud->press(*world, id, x, y); else if (ev.type == SDL_FINGERMOTION) hud->move(id, x, y); else hud->release(*world, id, x, y);
      }
    }
    const Uint64 now = SDL_GetPerformanceCounter();
    const double dt = std::min(0.05, double(now - last) / SDL_GetPerformanceFrequency()); last = now;
    // mantıksal tuval: yükseklik 360, genişlik pencerenin oranına göre
    int ww, wh; SDL_GetRendererOutputSize(ren, &ww, &wh);
    const int cw = std::max(1, ww * VH / std::max(1, wh));
    if (canvas.w() != cw || canvas.h() != VH) canvas.resize(cw, VH);
    bool wantText = false;
    if (mode == TITLE) { title.update(dt); title.draw(canvas); }
    else if (mode == CREATE) { create.draw(canvas, double(now - t0) * 1000.0 / SDL_GetPerformanceFrequency()); wantText = create.editing; }
    else {
      World& w = *world;
      const Uint8* k = SDL_GetKeyboardState(nullptr);
      double sx = 0, sy = 0; hud->joy(sx, sy);
      if (!sx && !sy) {   // klavye: ekran yönünde birim vektör (HTML Input.joy)
        double x = 0, y = 0;
        if (k[SDL_SCANCODE_LEFT] || k[SDL_SCANCODE_A]) x -= 1;
        if (k[SDL_SCANCODE_RIGHT] || k[SDL_SCANCODE_D]) x += 1;
        if (k[SDL_SCANCODE_UP] || k[SDL_SCANCODE_W]) y -= 1;
        if (k[SDL_SCANCODE_DOWN] || k[SDL_SCANCODE_S]) y += 1;
        sx = x * 21; sy = y * 11 * 1.9;
      }
      w.update(dt, sx, sy);
      w.draw(canvas);
      hud->now += dt; hud->draw(canvas, w);
      wantText = hud->win.wantText;
      for (size_t n = std::min(w.logTotal - shown, w.log.size()); n > 0; n--) std::printf("%s\n", w.log[w.log.size() - n].m.c_str());   // günlük konsolda da
      shown = w.logTotal;
      std::string tt = "Anrufen Online · " + w.quests().name(w.sceneName); SDL_SetWindowTitle(win, tt.c_str());
      // ayarlardan istek: giriş ekranına dön (kaydedilmiş) ya da kaydı silip giriş ekranı (HTML location.reload)
      if (!w.appReq.empty()) { const std::string r = w.appReq; w.appReq.clear(); if (r == "newchar") { std::error_code ec; std::filesystem::remove(savePath, ec); } shown = 0; toTitle(); }
    }
    if (wantText != bool(SDL_IsTextInputActive())) { if (wantText) SDL_StartTextInput(); else SDL_StopTextInput(); }   // ekran klavyesi: adet, ad
    if (!tex || texW != cw || texH != VH) {
      if (tex) SDL_DestroyTexture(tex);
      tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, cw, VH); texW = cw; texH = VH;
    }
    SDL_UpdateTexture(tex, nullptr, canvas.img.px.data(), cw * 4);
    SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, nullptr, nullptr); SDL_RenderPresent(ren);
  }
  if (mode == PLAY && world) world->save();
  if (tex) SDL_DestroyTexture(tex);
  SDL_DestroyRenderer(ren); SDL_DestroyWindow(win); SDL_Quit();
  return 0;
}
