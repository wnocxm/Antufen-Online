// anrufen_test: ekransız test modu. Pencere açmadan oyunu bir senaryo dosyasına göre çalıştırır; ekran görüntüsü ve durum yazar.
//   anrufen_test senaryo.txt        (ya da "-": komutlar standart girdiden)
// Komutlar (satır başına bir tane; # açıklama):
//   veri <klasör|paket.gdp>          veri kaynağı bağla (sonraki öncekinin üstünde; yama)
//   karakter <sınıf> <ırk> <cinsiyet> örn. 战士 人类 male
//   sahne <numara> [x y]             sahneyi yükle (yer verilmezse giriş bölgesi)
//   konum <x> <y>                    sahne içinde oyuncuyu doğrudan oraya koy (denetimsiz; test)
//   yon <0-3>                        oyuncunun yönü (0 sağ-yukarı, 1 sağ-aşağı, 2 sol-aşağı, 3 sol-yukarı)
//   saat0                            zaman ve bütün animasyon sayaçları 0 (HTML karşılaştırması)
//   bekle <sn>                       girdisiz ilerlet (1/60 sn adımlarla)
//   yuru <sag|sol|yukari|asagi> <sn> o yönün tuşu basılıyken ilerlet (sag+yukari gibi birleşik de olur)
//   ekran <genişlik> <yükseklik>     tuval boyu (varsayılan 640×360)
//   golge <0|1>                      ayak gölgeleri
//   goruntu <dosya.png>              çiz ve PNG yaz
//   durum <dosya.json|->             oyuncu, sahne, zaman (JSON)
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

#include "core/png.h"
#include "engine/assets.h"
#include "engine/canvas.h"
#include "engine/vfs.h"
#include "engine/world.h"

using namespace engine;

int main(int argc, char** argv) {
  if (argc != 2) { std::fprintf(stderr, "kullanım: anrufen_test <senaryo.txt|->\n"); return 2; }
  std::ifstream fin; std::istream* in = &std::cin;
  if (std::string(argv[1]) != "-") { fin.open(argv[1]); if (!fin) { std::fprintf(stderr, "senaryo açılamadı: %s\n", argv[1]); return 2; } in = &fin; }
  Vfs vfs; Assets assets; std::unique_ptr<World> world; Canvas canvas; canvas.resize(640, VH);
  DrawOpts opts; bool loaded = false; std::string line; int ln = 0;
  auto need = [&](bool ok, const char* what) { if (!ok) throw godat::Error(what); };
  try {
    while (std::getline(*in, line)) {
      ln++; std::istringstream ss(line); std::string cmd; ss >> cmd;
      if (cmd.empty() || cmd[0] == '#') continue;
      if (cmd == "veri") {
        std::string p; ss >> p;
        if (p.size() > 4 && p.substr(p.size() - 4) == ".gdp") vfs.mountPack(p); else vfs.mountDir(p);
        assets = Assets(); assets.load(vfs); world = std::make_unique<World>(assets); loaded = true;
        std::printf("veri: %s\n", vfs.describe().c_str());
      } else if (cmd == "karakter") {
        need(loaded, "önce veri"); Look l; ss >> l.cls >> l.race >> l.sex; world->setLook(l);
      } else if (cmd == "sahne") {
        need(loaded, "önce veri"); std::string sid; int xy[2]; ss >> sid;
        if (ss >> xy[0] >> xy[1]) world->loadScene(sid, xy); else world->loadScene(sid);
        std::printf("sahne %s %s · harita %dx%d · nesne %zu · NPC %zu · oyuncu (%g, %g)\n", sid.c_str(), world->sceneName.c_str(), world->map.w, world->map.h,
                    world->map.objs.size(), world->npcs.size(), world->player.x, world->player.y);
      } else if (cmd == "konum") {   // sahne içinde doğrudan yer (denetimsiz; test)
        need(world != nullptr, "önce veri"); ss >> world->player.x >> world->player.y; world->update(0);
      } else if (cmd == "yon") { need(world != nullptr, "önce veri"); ss >> world->player.dir; }
      else if (cmd == "saat0") { need(world != nullptr, "önce veri"); world->resetClock(); world->update(0); }
      else if (cmd == "bekle") { double s; ss >> s; for (int k = 0; k < int(s * 60 + 0.5); k++) world->update(1.0 / 60); }
      else if (cmd == "yuru") {
        std::string d; double s; ss >> d >> s; double x = 0, y = 0;
        std::istringstream ds(d); std::string tok;   // "+" ile ayrılmış tuşlar ("asagi" içinde "sag" geçtiği için tam eşleşme)
        while (std::getline(ds, tok, '+')) {
          if (tok == "sag") x += 1; else if (tok == "sol") x -= 1; else if (tok == "yukari") y -= 1; else if (tok == "asagi") y += 1;
          else throw godat::Error("bilinmeyen yön: " + tok);
        }
        for (int k = 0; k < int(s * 60 + 0.5); k++) world->update(1.0 / 60, x * 21, y * 11 * 1.9);
        world->update(0);   // tuş bırakıldı
      } else if (cmd == "ekran") { int w, h; ss >> w >> h; canvas.resize(w, h); }
      else if (cmd == "golge") { int g; ss >> g; opts.shadows = g != 0; }
      else if (cmd == "goruntu") {
        std::string f; ss >> f; world->draw(canvas, opts); godat::writeFile(f, core::encodePNG(canvas.img));
        std::printf("görüntü %s (%dx%d)\n", f.c_str(), canvas.w(), canvas.h());
      } else if (cmd == "durum") {
        std::string f; ss >> f; const Player& p = world->player; char buf[512];
        std::snprintf(buf, sizeof buf, "{\"sahne\":\"%s\",\"x\":%.4f,\"y\":%.4f,\"yon\":%d,\"yuruyor\":%s,\"t\":%.4f,\"zaman\":%.4f,\"kamera\":[%.2f,%.2f],\"npc\":%zu}\n",
                      world->sceneId.c_str(), p.x, p.y, p.dir, p.moving ? "true" : "false", p.t, world->time, world->camX, world->camY, world->npcs.size());
        if (f == "-") std::fputs(buf, stdout); else godat::writeFile(f, godat::Bytes(buf, buf + std::strlen(buf)));
      } else throw godat::Error("bilinmeyen komut: " + cmd);
    }
  } catch (const std::exception& e) {
    std::fprintf(stderr, "HATA (satır %d): %s\n", ln, e.what());
    return 1;
  }
  return 0;
}
