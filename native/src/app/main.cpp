// anrufen: pencereli oyun (SDL2). Tuval 360 piksel yüksekliğinde çizilir (HTML'deki gibi), pencereye büyütülür.
//   anrufen [--veri <klasör|paket.gdp>]… [--sahne <numara>] [--sinif 战士|法师|牧师] [--irk 人类|精灵] [--cinsiyet male|fema]
//           [--seviye <n>] [--uzmanlik 0|1]   (seviye: puanlar oyuncu gibi dağıtılır; 40'ta sınıf, 80'de ikinci yükseltme; uzmanlık: hangisi)
// Tuşlar: ok tuşları / WASD yürü, boşluk en yakın canavara saldır, 1-9 beceriler (sınıfın beceri sırası: acemi ve sınıf ağaçları,
// sonra uzmanlık), F12 ekran görüntüsü (anrufen_ekran.png), Esc çıkış.
// Veri verilmezse sırayla: veri/oyun.gdp, ../veri/oyun.gdp, ../../www/assets, ../../../www/assets, ../www/assets, www/assets.
#include <SDL.h>

#include <algorithm>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <string>
#include <vector>

#include "core/png.h"
#include "engine/assets.h"
#include "engine/balance.h"
#include "engine/vfs.h"
#include "engine/world.h"

using namespace engine;

int main(int argc, char** argv) {
  std::vector<std::string> data; std::string scene = "120005"; Look look; int level = 1, spec = 0;
  for (int i = 1; i + 1 < argc; i += 2) {
    std::string k = argv[i], v = argv[i + 1];
    if (k == "--veri") data.push_back(v); else if (k == "--sahne") scene = v;
    else if (k == "--sinif") look.cls = v; else if (k == "--irk") look.race = v; else if (k == "--cinsiyet") look.sex = v;
    else if (k == "--seviye") level = std::atoi(v.c_str()); else if (k == "--uzmanlik") spec = std::atoi(v.c_str()) ? 1 : 0;
  }
  // veri aranır: oyunun yanındaki paket (Visual Studio programı build/Release içine koyar), sonra geliştirme klasörü
  if (data.empty()) for (const char* p : {"veri/oyun.gdp", "../veri/oyun.gdp", "../../www/assets", "../../../www/assets", "../www/assets", "www/assets"})
    if (std::filesystem::exists(p)) { data.push_back(p); break; }
  Vfs vfs; Assets assets; Balance bal;
  try {
    for (const std::string& d : data) { if (d.size() > 4 && d.substr(d.size() - 4) == ".gdp") vfs.mountPack(d); else vfs.mountDir(d); }
    assets.load(vfs); bal.load(vfs, assets.D());
  } catch (const std::exception& e) { std::fprintf(stderr, "Veri yüklenemedi: %s\n", e.what()); return 1; }
  rng().seed(uint32_t(SDL_GetPerformanceCounter()));
  World world(assets, bal); world.setChar(look.cls, look.race, look.sex);
  if (level > 1) {   // GM "ağaçları doldur" gibi: yükseltmeler seviyeye göre, puanlar oyuncu gibi
    world.setLevel(level); world.P.adv = level >= 80 ? 2 : level >= 40 ? 1 : 0;
    world.P.sk.clear(); world.P.sp = 0; world.skillAutoSpend(world.P.lv + 1, spec);
  }
  try { world.loadScene(scene); } catch (const std::exception& e) { std::fprintf(stderr, "Sahne yüklenemedi: %s\n", e.what()); return 1; }

  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) { std::fprintf(stderr, "SDL: %s\n", SDL_GetError()); return 1; }
  SDL_Window* win = SDL_CreateWindow("Anrufen Online", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
  SDL_Renderer* ren = win ? SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC) : nullptr;
  if (!ren && win) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
  if (!win || !ren) { std::fprintf(stderr, "Pencere açılamadı: %s\n", SDL_GetError()); return 1; }
  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");   // keskin pikseller (HTML imageSmoothingEnabled = false)

  Canvas canvas; SDL_Texture* tex = nullptr; int texW = 0, texH = 0;
  Uint64 last = SDL_GetPerformanceCounter(); bool run = true;
  while (run) {
    SDL_Event ev;
    while (SDL_PollEvent(&ev)) {
      if (ev.type == SDL_QUIT) run = false;
      if (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_ESCAPE) run = false;
      if (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_F12) godat::writeFile("anrufen_ekran.png", core::encodePNG(canvas.img));
      if (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_SPACE) {   // saldırı: hedef yoksa en yakın canavar (HTML büyük saldırı düğmesi)
        int t = world.target(); if (t < 0 || world.ents[t].dead) t = world.nearestMob(8);
        if (t >= 0) world.setTarget(t, true);
      }
      if (ev.type == SDL_KEYDOWN && ev.key.keysym.sym >= SDLK_1 && ev.key.keysym.sym <= SDLK_9) world.useSkill(int(ev.key.keysym.sym - SDLK_1));
    }
    const Uint8* k = SDL_GetKeyboardState(nullptr);
    double x = 0, y = 0;
    if (k[SDL_SCANCODE_LEFT] || k[SDL_SCANCODE_A]) x -= 1;
    if (k[SDL_SCANCODE_RIGHT] || k[SDL_SCANCODE_D]) x += 1;
    if (k[SDL_SCANCODE_UP] || k[SDL_SCANCODE_W]) y -= 1;
    if (k[SDL_SCANCODE_DOWN] || k[SDL_SCANCODE_S]) y += 1;
    const Uint64 now = SDL_GetPerformanceCounter();
    const double dt = std::min(0.05, double(now - last) / SDL_GetPerformanceFrequency()); last = now;
    world.update(dt, x * 21, y * 11 * 1.9);
    // mantıksal tuval: yükseklik 360, genişlik pencerenin oranına göre
    int ww, wh; SDL_GetRendererOutputSize(ren, &ww, &wh);
    const int cw = std::max(1, ww * VH / std::max(1, wh));
    if (canvas.w() != cw || canvas.h() != VH) canvas.resize(cw, VH);
    world.draw(canvas);
    if (!tex || texW != cw || texH != VH) {
      if (tex) SDL_DestroyTexture(tex);
      tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STREAMING, cw, VH); texW = cw; texH = VH;
    }
    SDL_UpdateTexture(tex, nullptr, canvas.img.px.data(), cw * 4);
    SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, nullptr, nullptr); SDL_RenderPresent(ren);
    std::string title = "Anrufen Online · " + world.sceneName; SDL_SetWindowTitle(win, title.c_str());
  }
  if (tex) SDL_DestroyTexture(tex);
  SDL_DestroyRenderer(ren); SDL_DestroyWindow(win); SDL_Quit();
  return 0;
}
