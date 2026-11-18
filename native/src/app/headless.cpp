// anrufen_test: ekransız test modu. Pencere açmadan oyunu bir senaryo dosyasına göre çalıştırır; ekran görüntüsü, durum ve iz yazar.
//   anrufen_test senaryo.txt        (ya da "-": komutlar standart girdiden)
// Komutlar (satır başına bir tane; # açıklama):
//   veri <klasör|paket.gdp>          veri kaynağı bağla (sonraki öncekinin üstünde; yama)
//   tohum <sayı>                     zar üretecinin tohumu (HTML karşılaştırmasında Math.random da aynı üreteçle)
//   karakter <sınıf> <ırk> <cinsiyet> örn. 战士 人类 male
//   seviye <n>                       seviye (can/mana dolar; HTML gmLevel)
//   doldur                           can ve mana dolu
//   sahne <numara> [x y]             sahneyi yükle (yer verilmezse giriş bölgesi)
//   konum <x> <y>                    sahne içinde oyuncuyu doğrudan oraya koy (denetimsiz; test)
//   yon <0-3>                        oyuncunun yönü (0 sağ-yukarı, 1 sağ-aşağı, 2 sol-aşağı, 3 sol-yukarı)
//   saat0                            zaman ve bütün animasyon sayaçları 0 (HTML karşılaştırması)
//   bekle <sn>                       girdisiz ilerlet (1/60 sn adımlarla)
//   yuru <sag|sol|yukari|asagi> <sn> o tuşlar basılıyken ilerlet (sag+yukari gibi birleşik de olur)
//   hedef <yakın|sıra>               en yakın canavarı (8 kare) ya da varlık sırasındakini hedef al ve saldır
//   savas <dt> <sn> <iz.json> [oto]  sabit adımla ilerlet; her saniye iz satırı; oto: hedef ölünce en yakını yeniden hedef al
//   canavarlar <dosya.json|->        bütün canavarlar: ad, yer, yön, can, seviye, durum
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
#include "engine/balance.h"
#include "engine/canvas.h"
#include "engine/vfs.h"
#include "engine/world.h"

using namespace engine;

static void out(const std::string& f, const std::string& text) {
  if (f == "-") std::fputs(text.c_str(), stdout); else godat::writeFile(f, godat::Bytes(text.begin(), text.end()));
}
static std::string num(double v) { char b[64]; std::snprintf(b, sizeof b, "%.17g", v); return b; }   // tam hassasiyet (karşılaştırma)

int main(int argc, char** argv) {
  if (argc != 2) { std::fprintf(stderr, "kullanım: anrufen_test <senaryo.txt|->\n"); return 2; }
  std::ifstream fin; std::istream* in = &std::cin;
  if (std::string(argv[1]) != "-") { fin.open(argv[1]); if (!fin) { std::fprintf(stderr, "senaryo açılamadı: %s\n", argv[1]); return 2; } in = &fin; }
  Vfs vfs; Assets assets; Balance bal; std::unique_ptr<World> world; Canvas canvas; canvas.resize(640, VH);
  DrawOpts opts; std::string line; int ln = 0;
  auto W = [&]() -> World& { if (!world) throw godat::Error("önce veri"); return *world; };
  try {
    while (std::getline(*in, line)) {
      ln++; std::istringstream ss(line); std::string cmd; ss >> cmd;
      if (cmd.empty() || cmd[0] == '#') continue;
      if (cmd == "veri") {
        std::string p; ss >> p;
        if (p.size() > 4 && p.substr(p.size() - 4) == ".gdp") vfs.mountPack(p); else vfs.mountDir(p);
        assets = Assets(); assets.load(vfs); bal = Balance(); bal.load(vfs, assets.D()); world = std::make_unique<World>(assets, bal);
        std::printf("veri: %s\n", vfs.describe().c_str());
      } else if (cmd == "tohum") { uint32_t sd; ss >> sd; rng().seed(sd); }
      else if (cmd == "karakter") { std::string c, r, s; ss >> c >> r >> s; W().P = CharData(); W().setChar(c, r, s); }   // yeni karakter (Sv 1, altın 0, çanta boş)
      else if (cmd == "seviye") { int lv; ss >> lv; W().setLevel(lv); }
      else if (cmd == "doldur") { const Stats s = W().stats(); W().player.hp = s.hp; W().player.mp = s.mp; }
      else if (cmd == "sahne") {
        std::string sid; int xy[2]; ss >> sid;
        if (ss >> xy[0] >> xy[1]) W().loadScene(sid, xy); else W().loadScene(sid);
        int mobs = 0; for (const Ent& e : W().ents) mobs += e.kind == Ent::MOB;
        std::printf("sahne %s %s · harita %dx%d · nesne %zu · varlık %zu (canavar %d) · oyuncu (%g, %g)\n", sid.c_str(), W().sceneName.c_str(), W().map.w, W().map.h,
                    W().map.objs.size(), W().ents.size(), mobs, W().player.x, W().player.y);
      } else if (cmd == "konum") { ss >> W().player.x >> W().player.y; W().update(0); }
      else if (cmd == "yon") ss >> W().player.dir;
      else if (cmd == "saat0") { W().resetClock(); W().update(0); }
      else if (cmd == "bekle") { double s; ss >> s; for (int k = 0; k < int(s * 60 + 0.5); k++) W().update(1.0 / 60); }
      else if (cmd == "yuru") {
        std::string d; double s; ss >> d >> s; double x = 0, y = 0;
        std::istringstream ds(d); std::string tok;   // "+" ile ayrılmış tuşlar ("asagi" içinde "sag" geçtiği için tam eşleşme)
        while (std::getline(ds, tok, '+')) {
          if (tok == "sag") x += 1; else if (tok == "sol") x -= 1; else if (tok == "yukari") y -= 1; else if (tok == "asagi") y += 1;
          else throw godat::Error("bilinmeyen yön: " + tok);
        }
        for (int k = 0; k < int(s * 60 + 0.5); k++) W().update(1.0 / 60, x * 21, y * 11 * 1.9);
        W().update(0);   // tuş bırakıldı
      } else if (cmd == "hedef") {
        std::string h; ss >> h; const int i = h == "yakın" || h == "yakin" ? W().nearestMob(8) : std::stoi(h);
        W().setTarget(i, true); std::printf("hedef %d %s\n", i, i >= 0 ? W().ents[i].name.c_str() : "(yok)");
      } else if (cmd == "savas") {
        double dt, sec; std::string f, oto; ss >> dt >> sec >> f >> oto; World& w = W();
        const int steps = int(sec / dt + 0.5), per = int(1 / dt + 0.5); std::string tr = "[\n";
        for (int k = 1; k <= steps; k++) {
          if (oto == "oto" && (w.target() < 0 || w.ents[w.target()].dead)) { const int m = w.nearestMob(8); if (m >= 0) w.setTarget(m, true); }
          w.update(dt);
          if (k % per == 0) {
            int alive = 0; double sx = 0, sy = 0; for (const Ent& e : w.ents) if (e.kind == Ent::MOB) { alive += !e.dead; sx += e.x; sy += e.y; }
            std::string bag; for (const auto& b : w.P.bag) bag += (bag.empty() ? "" : ",") + b.first + ":" + std::to_string(b.second);
            const int t = w.target();
            tr += std::string(k > per ? ",\n" : "") + "{\"s\":" + num(k * dt) + ",\"hp\":" + num(w.player.hp) + ",\"mp\":" + num(w.player.mp) + ",\"lv\":" + std::to_string(w.P.lv) +
                  ",\"xp\":" + std::to_string(w.P.xp) + ",\"altin\":" + std::to_string(w.P.gold) + ",\"x\":" + num(w.player.x) + ",\"y\":" + num(w.player.y) +
                  ",\"hedef\":" + std::to_string(t) + ",\"hedefCan\":" + num(t >= 0 ? w.ents[t].hp : -1) + ",\"canli\":" + std::to_string(alive) +
                  ",\"canavarX\":" + num(sx) + ",\"canavarY\":" + num(sy) + ",\"olu\":" + (w.player.dead ? "true" : "false") + ",\"canta\":\"" + bag + "\"}";
          }
        }
        out(f, tr + "\n]\n");
      } else if (cmd == "canavarlar") {
        std::string f; ss >> f; std::string o = "[";
        for (size_t i = 0; i < W().ents.size(); i++) { const Ent& e = W().ents[i]; if (e.kind != Ent::MOB) continue;
          o += std::string(o.size() > 1 ? ",\n" : "\n") + "{\"i\":" + std::to_string(i) + ",\"ad\":\"" + e.name + "\",\"x\":" + num(e.x) + ",\"y\":" + num(e.y) + ",\"yon\":" + std::to_string(e.dir) +
               ",\"can\":" + num(e.hp) + ",\"sv\":" + std::to_string(e.d->lv) + ",\"saldiri\":" + num(e.atk) + ",\"savunma\":" + num(e.def) + ",\"gezinme\":" + num(e.wanderT) + ",\"durum\":\"" + e.state + "\"}"; }
        out(f, o + "\n]\n");
      } else if (cmd == "ekran") { int w, h; ss >> w >> h; canvas.resize(w, h); }
      else if (cmd == "golge") { int g; ss >> g; opts.shadows = g != 0; }
      else if (cmd == "goruntu") {
        std::string f; ss >> f; W().draw(canvas, opts); godat::writeFile(f, core::encodePNG(canvas.img));
        std::printf("görüntü %s (%dx%d)\n", f.c_str(), canvas.w(), canvas.h());
      } else if (cmd == "durum") {
        std::string f; ss >> f; const Player& p = W().player; const Stats s = W().stats();
        out(f, "{\"sahne\":\"" + W().sceneId + "\",\"x\":" + num(p.x) + ",\"y\":" + num(p.y) + ",\"yon\":" + std::to_string(p.dir) + ",\"yuruyor\":" + (p.state == "move" ? "true" : "false") +
               ",\"t\":" + num(p.t) + ",\"zaman\":" + num(W().time) + ",\"can\":" + num(p.hp) + ",\"mana\":" + num(p.mp) + ",\"sv\":" + std::to_string(W().P.lv) +
               ",\"maxCan\":" + num(s.hp) + ",\"saldiri\":" + num(s.atk) + ",\"savunma\":" + num(s.def) + ",\"varlik\":" + std::to_string(W().ents.size()) + "}\n");
      } else throw godat::Error("bilinmeyen komut: " + cmd);
    }
  } catch (const std::exception& e) {
    std::fprintf(stderr, "HATA (satır %d): %s\n", ln, e.what());
    return 1;
  }
  return 0;
}
