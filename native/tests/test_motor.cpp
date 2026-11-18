// Motor birim testleri: JSON, PNG gidiş-dönüş, tuval (aynalama, saydamlık, ışık), yön, sahne yükleme ve yürüme (oyun verisiyle).
//   test_motor <www/assets>
#include <cmath>
#include <cstdio>
#include <string>

#include "core/json.h"
#include "core/png.h"
#include "engine/assets.h"
#include "engine/balance.h"
#include "engine/canvas.h"
#include "engine/rng.h"
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
  {   // zar üreteci: JavaScript mulberry32 ile aynı dizi (tohum 12345; değerler node ile hesaplandı)
    engine::Rng r(12345); const double a = r.next(), b = r.next(), c2 = r.next();
    CHECK(a == 0.97972826776094735 && b == 0.30675226449966431 && c2 == 0.48420542152598500, "zar: JS mulberry32 ile aynı");
    CHECK(engine::jsRound(-2.5) == -2 && engine::jsRound(2.5) == 3 && engine::jsHypot(3, 4) == 5, "JS yuvarlama ve hypot");
  }
  CHECK(engine::dirOf(1, 0) == 1 && engine::dirOf(0, 1) == 2 && engine::dirOf(-1, 0) == 3 && engine::dirOf(0, -1) == 0, "yön: dört eksen");

  if (argc > 1) {
    engine::Vfs vfs; vfs.mountDir(argv[1]); engine::Assets as; as.load(vfs); engine::Balance bal; bal.load(vfs, as.D());
    engine::World w(as, bal); w.loadScene("120005");
    CHECK(w.sceneName == "观林镇" && w.map.w == 50 && !w.ents.empty() && !w.map.objs.empty(), "sahne: Guanlin yüklendi");
    CHECK(!w.map.blocked(w.player.x, w.player.y), "sahne: oyuncu geçilebilir karede");
    const double x0 = w.player.x;
    for (int k = 0; k < 30; k++) w.update(1.0 / 60, 21, 11 * 1.9);   // sağ-aşağı tuşları: +x ekseni
    CHECK(w.player.x > x0 + 1.5 && w.player.dir == 1 && w.player.state == "move", "yürüme: 0,5 sn sağ-aşağı ≈ 2 kare");
    engine::Canvas fr; fr.resize(640, 360); w.draw(fr);
    size_t lit = 0; for (size_t i = 0; i < fr.img.px.size(); i += 4) if (fr.img.px[i] | fr.img.px[i + 1] | fr.img.px[i + 2]) lit++;
    CHECK(lit > 640 * 360 / 2, "çizim: ekranın çoğu boyalı");
    // canavarlar: Güneşli Orman Kuzey'de örümcekler; en yakına saldır, 20 sn içinde en az biri ölür, deneyim ve altın gelir
    engine::rng().seed(5); w.P = engine::CharData(); w.setChar("战士", "人类", "male"); w.setLevel(20);
    const int at[2] = {40, 75}; w.loadScene("120018", at);
    int mobs = 0; for (const auto& e : w.ents) mobs += e.kind == engine::Ent::MOB;
    CHECK(mobs == 24, "canavar: 24 örümcek yerleşti");
    bool killed = false;
    for (int k = 0; k < 600 && !killed; k++) { if (w.target() < 0) { const int m = w.nearestMob(8); if (m >= 0) w.setTarget(m, true); } w.update(1.0 / 30); for (const auto& e : w.ents) killed |= e.dead; }
    CHECK(killed && w.P.gold > 0 && w.P.xp > 0, "savaş: canavar öldü, deneyim ve altın geldi");
    // beceriler: tablo, ağaç kuralları, edilgenler, kullanım (bekleme, mana), güçlendirme
    int act = 0, pas = 0; for (const char* c : {"战士", "法师", "牧师"}) for (const auto& sk : bal.skills.cls(c)) (sk.passive() ? pas : act)++;
    CHECK(act == 38 && pas == 34 && bal.skills.bySn(90082) && bal.skills.trees("法师").size() == 4, "beceri: 3 sınıf × 24 beceri (38 etkin), ırk becerileri, 4 ağaç");
    w.P = engine::CharData(); w.setChar("战士", "人类", "male"); w.setLevel(30); const engine::Stats s0 = w.stats();
    w.P.sk.clear(); w.P.sp = 0; w.skillAutoSpend(31, 0);
    CHECK(w.P.sk.count("w1") && !w.P.sk.count("w4") && !w.P.sk.count("90106"), "beceri: 40 altında yalnız acemi ağacı (sınıf ağacı kilitli)");
    CHECK(w.stats().atk > s0.atk && w.stats().hp > s0.hp, "beceri: edilgenler saldırı ve canı artırır");
    w.loadScene("120018", at); const engine::Stats s1 = w.stats(); w.player.mp = s1.mp;
    const int t = w.nearestMob(30); w.setTarget(t, true); w.player.x = w.ents[t].x - 1; w.player.y = w.ents[t].y;
    w.useSkill(1);   // Öç Bıçağı (w2): 25 mana, 1 sn bekleme
    CHECK(w.player.mp == s1.mp - 25 && w.player.cds["w2"] == 1.0 && w.player.state == "attack", "beceri: kullanınca mana düşer, bekleme başlar");
    const double hp0 = w.ents[t].hp; for (int k = 0; k < 12; k++) w.update(1.0 / 30);
    CHECK(w.ents[t].hp < hp0 || w.ents[t].dead, "beceri: 0,25 sn sonra vurur");
    w.P.sk["w5"] = 1; w.player.cds.clear(); w.useSkill(4); for (int k = 0; k < 10; k++) w.update(1.0 / 30);   // Hız Patlaması: güçlendirme
    CHECK(!w.player.buffs.empty() && w.player.buffs[0].id == "w5" && w.stats().spd > 0, "beceri: güçlendirme etkin (hız)");
  }
  std::printf("motor testleri: %d geçti, %d kaldı\n", passed, failed);
  return failed ? 1 : 0;
}
