// Motor birim testleri: JSON, PNG gidiş-dönüş, tuval (aynalama, saydamlık, ışık), yön, sahne yükleme ve yürüme (oyun verisiyle).
//   test_motor <www/assets>
#include <cmath>
#include <cstdio>
#include <string>

#include "core/json.h"
#include "core/png.h"
#include "engine/assets.h"
#include "engine/canvas.h"
#include "engine/vfs.h"
#include "engine/world.h"

static int failed = 0, passed = 0;
#define CHECK(cond, what) do { if (cond) { passed++; } else { failed++; std::printf("KALDI: %s (%s:%d)\n", what, __FILE__, __LINE__); } } while (0)

int main(int argc, char** argv) {
  using core::Json;
  Json j = Json::parse(R"({"a":[1,2.5,-3e2],"b":{"c":"çğ😀"},"t":true,"n":null})");
  CHECK(j["a"].size() == 3 && j["a"][1].num() == 2.5 && j["a"][2].i() == -300, "JSON: sayılar");
  CHECK(j["b"]["c"].str() == "çğ😀", "JSON: UTF-8 ve kaçışlar");
  CHECK(j["t"].b() && j["n"].isNull() && j["yok"].isNull() && j["a"][9].isNull(), "JSON: olmayan değer null");
  bool threw = false; try { Json::parse("{\"a\":}"); } catch (const std::exception&) { threw = true; }
  CHECK(threw, "JSON: bozuk metin hata verir");

  core::Image im; im.w = 3; im.h = 2; im.px = {255,0,0,255, 0,255,0,128, 0,0,255,0, 1,2,3,4, 5,6,7,8, 9,10,11,12};
  core::Image back = core::decodePNG(core::encodePNG(im));
  CHECK(back.w == 3 && back.h == 2 && back.px == im.px, "PNG: gidiş-dönüş");

  engine::Canvas c; c.resize(4, 1); c.fill(10, 10, 10);
  core::Image s; s.w = 2; s.h = 1; s.px = {100,0,0,255, 0,100,0,255};
  c.blit(s, 0, 0, 2, 1, 0, 0, true);
  CHECK(c.img.px[0] == 0 && c.img.px[1] == 100 && c.img.px[4] == 100, "tuval: yatay ayna");
  c.blit(s, 0, 0, 1, 1, 2, 0, false, false, 0.5f);
  CHECK(std::abs(int(c.img.px[8]) - 55) <= 1, "tuval: yarı saydam");
  c.blit(s, 0, 0, 1, 1, 3, 0, false, false, 1.f, true);
  CHECK(c.img.px[12] == 110, "tuval: ışık olarak ekleme");
  CHECK(engine::dirOf(1, 0) == 1 && engine::dirOf(0, 1) == 2 && engine::dirOf(-1, 0) == 3 && engine::dirOf(0, -1) == 0, "yön: dört eksen");

  if (argc > 1) {
    engine::Vfs vfs; vfs.mountDir(argv[1]); engine::Assets as; as.load(vfs);
    engine::World w(as); w.loadScene("120005");
    CHECK(w.sceneName == "观林镇" && w.map.w == 50 && !w.npcs.empty() && !w.map.objs.empty(), "sahne: Guanlin yüklendi");
    CHECK(!w.map.blocked(w.player.x, w.player.y), "sahne: oyuncu geçilebilir karede");
    const double x0 = w.player.x;
    for (int k = 0; k < 30; k++) w.update(1.0 / 60, 21, 11 * 1.9);   // sağ-aşağı tuşları: +x ekseni
    CHECK(w.player.x > x0 + 1.5 && w.player.dir == 1 && w.player.moving, "yürüme: 0,5 sn sağ-aşağı ≈ 2 kare");
    engine::Canvas fr; fr.resize(640, 360); w.draw(fr);
    size_t lit = 0; for (size_t i = 0; i < fr.img.px.size(); i += 4) if (fr.img.px[i] | fr.img.px[i + 1] | fr.img.px[i + 2]) lit++;
    CHECK(lit > 640 * 360 / 2, "çizim: ekranın çoğu boyalı");
  }
  std::printf("motor testleri: %d geçti, %d kaldı\n", passed, failed);
  return failed ? 1 : 0;
}
