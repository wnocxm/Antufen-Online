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
#include "ui/font.h"
#include "ui/forms.h"
#include "ui/hud.h"

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
  { // JSON yazma = JS JSON.stringify (sayılar Number#toString, anahtar sırası: tam sayı anahtarlar önce)
    bool ok = true; const std::pair<double, const char*> N[] = {{30, "30"}, {0.1, "0.1"}, {1e21, "1e+21"}, {1e-7, "1e-7"}, {123.456, "123.456"}, {-0.000001, "-0.000001"},
      {1.0 / 3, "0.3333333333333333"}, {9007199254740994.0, "9007199254740994"}, {1e9, "1000000000"}, {5e-324, "5e-324"}, {1.7976931348623157e308, "1.7976931348623157e+308"}};
    for (const auto& x : N) if (core::jsNumStr(x.first) != x.second) { ok = false; std::printf("  %s ≠ %s\n", core::jsNumStr(x.first).c_str(), x.second); }
    CHECK(ok, "JSON: sayı yazımı JS ile aynı");
    Json o = Json::parse(R"({"b":1,"10":[true,null,"a\"\n"],"2":{"x":-0.5},"a":"ç"})");
    CHECK(o.dump() == R"({"2":{"x":-0.5},"10":[true,null,"a\"\n"],"b":1,"a":"ç"})", "JSON: yazma (anahtar sırası, kaçış)");
  }

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
    // görevler: veri, durum, alma, konuşma görevi, öldürme sayacı, teslim ve ödül, sınıf yükseltmesi
    engine::Quests& Q = w.quests();
    CHECK(Q.all().size() > 900 && Q.byId(80292) && Q.byId(80292)->giver == "点点我", "görev: veri yüklendi (Kayıt görevi)");
    w.P = engine::CharData(); w.setChar("战士", "人类", "male"); w.flags.clear();
    const int q1 = Q.indexOf(80292), q2 = Q.indexOf(80294);
    CHECK(w.questState(q1) == "new" && w.questState(q2) == "locked", "görev: ilk görev yeni, sonraki kilitli");
    w.setChar("战士", "精灵", "male"); CHECK(w.questState(q1) == "locked", "görev: ırk görevi öteki ırka kapalı"); w.setChar("战士", "人类", "male");
    w.dialogAccept(q1, "点点我"); CHECK(w.questState(q1) == "ready", "görev: konuşma görevi alınınca hazır");
    const long long g0 = w.P.gold; w.completeQuest(q1);
    CHECK(w.P.done.count(80292) && w.P.gold > g0 && w.countItem("10002") == 1 && w.countItem("10005") == 0, "görev: teslim, altın ve sınıfa göre ödül eşyası");
    w.acceptQuest(q2); w.questKill("鸭子");
    CHECK(w.questState(q2) == "ready", "görev: öldürme sayacı (1 ördek)");
    w.P.lv = 40; w.autoQuests(); CHECK(w.P.quests.count(80344), "görev: 40'ta kendiliğinden görev (Acemilikten Çıkış)");
    for (const engine::Quest& q : Q.all()) if (q.adv == 1 && q.cls == "战士" && (q.race.empty() || q.race == "人类")) { w.gmQuestDone(q.id); break; }
    CHECK(w.P.adv == 1, "görev: sınıf yükseltme görevi biter, sınıf ağacı açılır");
    // arayüz: yazı atlası, oyun ekranı, saldırı düğmesi, yürüme kolu
    ui::Fonts fonts; fonts.load(vfs); ui::Forms forms(as, fonts); forms.load(vfs); ui::Hud hud(as, fonts, forms);
    CHECK(fonts.ok() && fonts.width("B", 10, "Kahraman") > 30 && fonts.width("B", 10, "ğüşİıöç") > 20, "yazı: atlas yüklendi, Türkçe harflerin genişliği var");
    w.P = engine::CharData(); w.setChar("战士", "人类", "male"); w.loadScene("120018", at);
    engine::Canvas hc; hc.resize(640, 360); w.draw(hc); hud.draw(hc, w, false);
    hud.press(w, 1, 640 - 55, 305); hud.release(w, 1, 640 - 55, 305);
    CHECK(w.target() >= 0 && w.engaged(), "arayüz: saldırı düğmesi en yakın canavarı hedef alır");
    hud.press(w, 2, 114, 309); double jx, jy; hud.joy(jx, jy); hud.release(w, 2, 114, 309);
    CHECK(jy > 6 && std::fabs(jx) < 1, "arayüz: yürüme kolu aşağı");
    hud.press(w, 3, 640 - 95 + 40, 40); CHECK(hud.request == "map", "arayüz: küçük haritaya dokununca harita penceresi istenir");
    // eşyalar: Gelişim Paketi, başka sınıfın eşyası, satın alma, satma, çıkarma
    w.P = engine::CharData(); w.setChar("战士", "人类", "male"); w.setLevel(12);
    w.addItem("growthBox", 1, true); w.useItem("growthBox");
    CHECK(w.eqOf("weap") == "10003" && w.eqOf("body") == "10004" && w.eqOf("head") == "10002" && w.countItem("hp1") == 10 && !w.player.look.weapG.empty(), "eşya: Gelişim Paketi acemi ekipmanını kuşatır, görünüş değişir");
    w.addItem("10006", 1, true); w.equip("10006"); CHECK(w.eqOf("weap") == "10003" && w.toastMsg == "Bu eşya Büyücü içindir.", "eşya: başka sınıfın silahı kuşanılmaz");
    w.P.gold = 100; w.buyItem("30016", 3); CHECK(w.P.gold == 40 && w.countItem("30016") == 3, "eşya: satın alma (3 × 20 altın)");
    w.sellItem("30016", 2); CHECK(w.P.gold == 44 && w.countItem("30016") == 1, "eşya: satma (satış fiyatı 2)");
    w.unequip("weap"); CHECK(w.eqOf("weap").empty() && w.countItem("10003") == 1, "eşya: çıkarılan çantaya döner");
    // en yakın komşu ölçekleme: 32 → 36 px'te tam sınıra düşen sütun küçük olan kaynak pikseline gider (tarayıcı/Skia)
    { core::Image s2; s2.w = 32; s2.h = 1; s2.px.assign(32 * 4, 255); for (int x = 0; x < 32; x++) s2.px[size_t(x) * 4] = uint8_t(x);
      engine::Canvas cc; cc.resize(200, 4); cc.drawImage(s2, 0, 0, 32, 1, 154.125f - 100, 0, 36, 4);
      CHECK(cc.img.px[size_t(57) * 4] == 2 && cc.img.px[size_t(58) * 4] == 3, "tuval: en yakın komşu sınır örneği (Skia)"); }
  }
  std::printf("motor testleri: %d geçti, %d kaldı\n", passed, failed);
  return failed ? 1 : 0;
}
