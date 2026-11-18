// anrufen: pencereli oyun (SDL2). Tuval 360 piksel yüksekliğinde çizilir (HTML'deki gibi), pencereye büyütülür.
//   anrufen [--veri <klasör|paket.gdp>]… [--sahne <numara>] [--sinif 战士|法师|牧师] [--irk 人类|精灵] [--cinsiyet male|fema]
//           [--seviye <n>] [--uzmanlik 0|1] [--ad <ad>]   (seviye: puanlar oyuncu gibi dağıtılır; 40'ta sınıf, 80'de ikinci yükseltme)
// Dokunma / fare: oyun ekranı (HUD) düğmeleri, sol altta ejderha = yürüme kolu, dünyada canavara dokun (ikinci dokunuş saldırır),
// kişiye dokun (ikinci dokunuş ya da sağ alttaki konuşma düğmesi konuşur), sağ alt halka: saldırı, beceriler, iksirler.
// Tuşlar (HTML gibi): ok tuşları / WASD yürü, boşluk saldır, 1-6 beceri, Q can iksiri, E mana iksiri, Tab hedef değiştir,
// F12 ekran görüntüsü (anrufen_ekran.png), Esc çıkış. Pencereler (karakter, çanta, beceri, görev, harita, konuşma) sonraki adımda;
// o zamana dek kişiyle konuşmak görevleri kendiliğinden alıp teslim eder.
// Veri verilmezse sırayla: veri/oyun.gdp, ../veri/oyun.gdp, ../../www/assets, ../../../www/assets, ../www/assets, www/assets.
#include <SDL.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <string>
#include <vector>

#include "core/png.h"
#include "engine/assets.h"
#include "engine/balance.h"
#include "engine/vfs.h"
#include "engine/world.h"
#include "ui/font.h"
#include "ui/hud.h"

using namespace engine;

// kişiyle konuş (konuşma penceresi gelene dek): yakınsa dokun, teslim edilecekleri teslim et, yeni görevleri al
static void talk(World& w, int ei) {
  if (ei < 0 || ei >= int(w.ents.size())) return;
  const Ent& e = w.ents[size_t(ei)];
  if (jsHypot(e.x - w.player.x, e.y - w.player.y) >= 2) { w.toast("Kişiye yaklaş."); return; }
  const std::string cn = e.name; w.interact(ei);
  w.note(w.quests().name(cn) + ": " + w.quests().greet(cn));
  for (int qi : w.questsFor(cn)) {
    const Quest& q = w.quests().all()[size_t(qi)]; const std::string st = w.questState(qi);
    if (st == "ready" && q.to == cn) w.dialogComplete(qi);
    else if (st == "new" && q.giver == cn) { w.dialogAccept(qi, cn); if (q.hasTp) break; }
    else if (st == "active") w.note(q.tr.title + ": " + q.tr.goal);
  }
}

int main(int argc, char** argv) {
  std::vector<std::string> data; std::string scene = "120005", name = "Kahraman"; Look look; int level = 1, spec = 0;
  for (int i = 1; i + 1 < argc; i += 2) {
    std::string k = argv[i], v = argv[i + 1];
    if (k == "--veri") data.push_back(v); else if (k == "--sahne") scene = v;
    else if (k == "--sinif") look.cls = v; else if (k == "--irk") look.race = v; else if (k == "--cinsiyet") look.sex = v;
    else if (k == "--seviye") level = std::atoi(v.c_str()); else if (k == "--uzmanlik") spec = std::atoi(v.c_str()) ? 1 : 0;
    else if (k == "--ad") name = v;
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
  World world(assets, bal); world.setChar(look.cls, look.race, look.sex); world.P.name = name;
  world.P.face = std::to_string((look.race == "精灵" ? 2 : 0) + (look.sex == "fema" ? 2 : 1)) + "001";   // HTML: ırk/cinsiyet + 1. yüz
  if (level > 1) {   // GM "ağaçları doldur" gibi: yükseltmeler seviyeye göre, puanlar oyuncu gibi
    world.setLevel(level); world.P.adv = level >= 80 ? 2 : level >= 40 ? 1 : 0;
    world.P.sk.clear(); world.P.sp = 0; world.skillAutoSpend(world.P.lv + 1, spec);
  }
  world.addItem("hp1", 5, true); world.addItem("mp1", 3, true);   // yeni karakterin çantası (HTML newSave)
  try { world.loadScene(scene); } catch (const std::exception& e) { std::fprintf(stderr, "Sahne yüklenemedi: %s\n", e.what()); return 1; }
  ui::Hud hud(assets, fonts);

  SDL_SetHint(SDL_HINT_TOUCH_MOUSE_EVENTS, "0");   // dokunma ayrıca işlenir (fareye çevrilmesin)
  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) { std::fprintf(stderr, "SDL: %s\n", SDL_GetError()); return 1; }
  SDL_Window* win = SDL_CreateWindow("Anrufen Online", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
  SDL_Renderer* ren = win ? SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC) : nullptr;
  if (!ren && win) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
  if (!win || !ren) { std::fprintf(stderr, "Pencere açılamadı: %s\n", SDL_GetError()); return 1; }
  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");   // keskin pikseller (HTML imageSmoothingEnabled = false)

  Canvas canvas; SDL_Texture* tex = nullptr; int texW = 0, texH = 0;
  Uint64 last = SDL_GetPerformanceCounter(); bool run = true; size_t shown = 0;
  // pencere koordinatı → mantıksal tuval koordinatı
  auto logical = [&](float wx, float wy, float& x, float& y) { int ww, wh; SDL_GetWindowSize(win, &ww, &wh); x = wx * float(canvas.w()) / float(std::max(1, ww)); y = wy * float(VH) / float(std::max(1, wh)); };
  auto handleRequest = [&]() {
    if (hud.request.empty()) return;
    const std::string r = hud.request; hud.request.clear();
    if (r.rfind("talk:", 0) == 0) talk(world, std::atoi(r.c_str() + 5));
    else world.toast("Pencereler yakında (arayüz 2. parça).");
  };
  while (run) {
    SDL_Event ev;
    while (SDL_PollEvent(&ev)) {
      if (ev.type == SDL_QUIT) run = false;
      if (ev.type == SDL_KEYDOWN) {
        const SDL_Keycode k = ev.key.keysym.sym;
        if (k == SDLK_ESCAPE) run = false;
        if (k == SDLK_F12) godat::writeFile("anrufen_ekran.png", core::encodePNG(canvas.img));
        if (k == SDLK_SPACE) { int t = world.target(); if (t < 0 || world.ents[size_t(t)].kind != Ent::MOB || world.ents[size_t(t)].dead) t = world.nearestMob(9); if (t >= 0) world.setTarget(t, true); else world.note("Yakında hedef yok."); }
        if (k >= SDLK_1 && k <= SDLK_6) world.useSkill(int(k - SDLK_1));
        if (k == SDLK_q) world.useItem("hp1");
        if (k == SDLK_e) world.useItem("mp1");
        if (k == SDLK_TAB) world.cycleTarget();
      }
      float x, y;
      if (ev.type == SDL_MOUSEBUTTONDOWN && ev.button.button == SDL_BUTTON_LEFT) { logical(float(ev.button.x), float(ev.button.y), x, y); hud.press(world, -1, x, y); }
      if (ev.type == SDL_MOUSEMOTION && (ev.motion.state & SDL_BUTTON_LMASK)) { logical(float(ev.motion.x), float(ev.motion.y), x, y); hud.move(-1, x, y); }
      if (ev.type == SDL_MOUSEBUTTONUP && ev.button.button == SDL_BUTTON_LEFT) { logical(float(ev.button.x), float(ev.button.y), x, y); hud.release(world, -1, x, y); }
      if (ev.type == SDL_FINGERDOWN || ev.type == SDL_FINGERMOTION || ev.type == SDL_FINGERUP) {
        x = ev.tfinger.x * float(canvas.w()); y = ev.tfinger.y * float(VH); const int id = int(ev.tfinger.fingerId & 0x7fffffff);
        if (ev.type == SDL_FINGERDOWN) hud.press(world, id, x, y); else if (ev.type == SDL_FINGERMOTION) hud.move(id, x, y); else hud.release(world, id, x, y);
      }
    }
    handleRequest();
    const Uint8* k = SDL_GetKeyboardState(nullptr);
    double sx = 0, sy = 0; hud.joy(sx, sy);
    if (!sx && !sy) {   // klavye: ekran yönünde birim vektör (HTML Input.joy)
      double x = 0, y = 0;
      if (k[SDL_SCANCODE_LEFT] || k[SDL_SCANCODE_A]) x -= 1;
      if (k[SDL_SCANCODE_RIGHT] || k[SDL_SCANCODE_D]) x += 1;
      if (k[SDL_SCANCODE_UP] || k[SDL_SCANCODE_W]) y -= 1;
      if (k[SDL_SCANCODE_DOWN] || k[SDL_SCANCODE_S]) y += 1;
      sx = x * 21; sy = y * 11 * 1.9;
    }
    const Uint64 now = SDL_GetPerformanceCounter();
    const double dt = std::min(0.05, double(now - last) / SDL_GetPerformanceFrequency()); last = now;
    world.update(dt, sx, sy);
    // mantıksal tuval: yükseklik 360, genişlik pencerenin oranına göre
    int ww, wh; SDL_GetRendererOutputSize(ren, &ww, &wh);
    const int cw = std::max(1, ww * VH / std::max(1, wh));
    if (canvas.w() != cw || canvas.h() != VH) canvas.resize(cw, VH);
    world.draw(canvas);
    hud.now += dt; hud.draw(canvas, world);
    if (!tex || texW != cw || texH != VH) {
      if (tex) SDL_DestroyTexture(tex);
      tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, cw, VH); texW = cw; texH = VH;
    }
    SDL_UpdateTexture(tex, nullptr, canvas.img.px.data(), cw * 4);
    SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, nullptr, nullptr); SDL_RenderPresent(ren);
    for (size_t n = std::min(world.logTotal - shown, world.log.size()); n > 0; n--) std::printf("%s\n", world.log[world.log.size() - n].m.c_str());   // günlük konsolda da
    shown = world.logTotal;
    std::string title = "Anrufen Online · " + world.quests().name(world.sceneName); SDL_SetWindowTitle(win, title.c_str());
  }
  if (tex) SDL_DestroyTexture(tex);
  SDL_DestroyRenderer(ren); SDL_DestroyWindow(win); SDL_Quit();
  return 0;
}
