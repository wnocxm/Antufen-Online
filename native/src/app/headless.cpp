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
//   ust <0|1|2>                      sınıf yükseltmesi (1: 40. seviye, 2: 80. seviye)
//   beceriler <no=kademe,…|->        beceri kademeleri (- boş)
//   dagit <puan> <uzmanlık> [dosya]  kademeleri sıfırla, puanları oyuncu gibi dağıt (HTML skillAutoSpend); sonucu yaz
//   beceri <sıra>                    beceri kullan (sınıfın beceri listesindeki sıra)
//   zaman0                           oyun saati 0 (yalnız saat; animasyonlar kalır)
//   olumsuz <0|1>                    GM ölümsüzlük (canavarlar vuramaz)
//   otogorev                         seviyesi gelmiş kendiliğinden görevleri al (HTML autoQuests)
//   gmbitir <no,no,…> <dosya>        GM: görevleri sırayla bitir (öncekileriyle; ödül, sınıf yükseltmesi); her birinden sonra durum satırı
//   gorevseviye <dosya> [ters]       bütün görevlerin açılma seviyesi (liste sırasıyla ya da tersten hesaplanır): "numara:seviye" satırları
//   gorevbot <adım> <dt> <iz.json>   görev botu (tools/test/cpp_gorev.js ile aynı kurallar): konuş, al, teslim et; hedefin haritasına
//                                    geç, savaş ya da topla; her adımdan sonra iz satırı (sahne, seviye, deneyim, altın, çanta, görevler)
//   savas <dt> <sn> <iz.json> [oto|beceri]  sabit adımla ilerlet; her saniye iz satırı; oto: hedef ölünce en yakını yeniden hedef al;
//                                    beceri: oto + her adımda sıradaki hazır beceri (sırayla döner; bekleme bitmiş; menzil dışındaysa yürür)
//   canavarlar <dosya.json|->        bütün canavarlar: ad, yer, yön, can, seviye, durum
//   ekran <genişlik> <yükseklik>     tuval boyu (varsayılan 640×360)
//   golge <0|1>                      ayak gölgeleri
//   halka <0|1>                      hedef halkası (varsayılan 1; dünya karşılaştırmasında 0)
//   arayuz <0|1>                     görüntüde oyun ekranı (HUD, adlar, uçan sayılar) da çizilsin mi (varsayılan 0)
//   yazi <0|1>                       yazılar çizilsin mi (piksel karşılaştırmasında 0: tarayıcının yazı çizimi birebir olamaz)
//   ad <ad> · portre <kod>           karakterin adı ve portresi (ui/Portrait_<kod>.png)
//   hedefle <sıra>                   hedef seç, saldırmadan (HTML setTarget)
//   bekleme <beceri> <sn>            beceri bekleme süresi (kısayol karartması)
//   gorevver <no>                    görevi doğrudan alınmış say (yan etkisiz; test)
//   gorevhazir <no> [sayı]           görevi teslime hazır say (test)
//   pencere <hub|npc|task|dead|bag|role|skill|shop|kapat> [varlık]  pencere aç (npc, shop: kişinin varlık sırası) ya da kapat
//   ciz                              kareyi çiz (dosyaya yazmadan; dokunma bölgeleri için)
//   dokun <x> <y>                    ekrana dokun (pencere açıksa pencereye, değilse HUD'a ya da dünyaya)
//   konus <varlık>                   kişiye konuş (yakınsa konuşma penceresi, uzaksa yürür)
//   yol <sx> <sy> <tx> <ty> <dosya>  A* yolu (HTML findPath); dosyaya bir satır ekler: "x,y x,y …" ya da "yok"
//   kisiyeyuru <varlık> · gorevyuru <no>   kişiye yürü (varınca konuşur) · görevin "Yol Bul"u (haritalar arası)
//   ilerle <dt> <sn> <dosya>         sabit adımla ilerlet; harita değişince varış yeri, sonda son durum (JSON)
//   temizle                          arayüz olaylarını sil (günlük, uçan sayılar, duyurular)
//   can <oran> · mana <oran>         oyuncunun canı/manası (azami değerin oranı)
//   goruntu <dosya.png>              çiz ve PNG yaz
//   durum <dosya.json|->             oyuncu, sahne, zaman (JSON)
//   esya <al|sat|giy|cikar|kullan|ekle|sil> <eşya|yuva> [adet]   eşya işlemi (HTML buyItem, sellItem, equip, unequip, useItem, addItem, removeItem)
//   gmgear · altin <n>               GM: seviyeye uygun en iyi ekipman · altın
//   beceriyukselt <beceri no> · becerisifirla <0|1>   beceri penceresinin Yükselt'i · Puanları Sıfırla (1: bedava)
//   kisayol <yuva> <sıra>            kısayol halkasına yerleştir (s<n> beceri, i:<eşya>)
//   beceriyazilari <dosya>           her becerinin kilit iletisi, her kademedeki açıklaması ve sonraki kademe farkı
//   karakterdurum <dosya.json|->     altın, çanta, ekipman, beceriler, değerler, görünüm, son ileti ve bildirim (JSON)
#include <algorithm>
#include <climits>
#include <cstdio>
#include <map>
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
#include "ui/font.h"
#include "ui/forms.h"
#include "ui/hud.h"

using namespace engine;

static void out(const std::string& f, const std::string& text) {
  if (f == "-") std::fputs(text.c_str(), stdout); else godat::writeFile(f, godat::Bytes(text.begin(), text.end()));
}
static std::string num(double v) { char b[64]; std::snprintf(b, sizeof b, "%.17g", v); return b; }   // tam hassasiyet (karşılaştırma)

// görev durumu (iz satırı): seviye, deneyim, altın, yükseltme, çanta, sürmekte olan görevler (sayaçlarıyla), bitmiş görevler
static std::string questRec(World& w, const std::string& tag) {
  std::string bag; for (const auto& b : w.P.bag) bag += (bag.empty() ? "" : ",") + b.first + ":" + std::to_string(b.second);
  std::string qs; for (const auto& kv : w.P.quests) {
    qs += (qs.empty() ? "" : ",") + std::to_string(kv.first) + ":" + std::to_string(kv.second.n) + (kv.second.ready ? "r" : "");
    for (const auto& c : kv.second.c) if (c.second) qs += "/" + c.first + "=" + std::to_string(c.second);
  }
  std::string dn; for (int id : w.P.done) dn += (dn.empty() ? "" : ",") + std::to_string(id);
  return "{\"etiket\":\"" + tag + "\",\"lv\":" + std::to_string(w.P.lv) + ",\"xp\":" + std::to_string(w.P.xp) + ",\"altin\":" + std::to_string(w.P.gold) +
         ",\"ust\":" + std::to_string(w.P.adv) + ",\"canta\":\"" + bag + "\",\"gorev\":\"" + qs + "\",\"bitti\":\"" + dn + "\"}";
}

// ---------------- görev botu (tools/test/cpp_gorev.js'teki botla aynı kurallar; zarlar aynı sırada) ----------------
static std::string questState(World& w, int qi) { return w.questState(qi); }
static std::string questBot(World& w, const core::Json& D, int steps, double dt) {
  std::map<int, int> tries; std::string tr = "[\n";
  const auto& Q = w.quests().all();
  auto dun = [&](const std::string& sid) { const core::Json& k = D["scenes"][sid]["kind"]; return k.isArr() && k[0].i() == 4; };
  auto pickSc = [&](const std::vector<std::string>& L0, const std::string& scName) {
    std::vector<std::string> L; for (const std::string& s : L0) if (!dun(s)) L.push_back(s);
    if (!scName.empty()) { std::vector<std::string> F; for (const std::string& s : L) if (D["scenes"][s]["name"].str() == scName) F.push_back(s); if (!F.empty()) L = F; }
    for (const std::string& s : L) if (s == w.sceneId) return s;
    return L.empty() ? std::string() : L[0];
  };
  auto revive = [&]() { Player& p = w.player; if (p.dead) { p.dead = false; p.state = "idle"; p.deadT = 0; } const Stats s = w.stats(); p.hp = s.hp; p.mp = s.mp; };
  // 1) bu haritadaki herkesle konuş: konuşma görevleri, teslim, yeni görev (değişiklik kalmayana dek); ışınlanma görevinde dur
  auto talk = [&]() -> bool {
    for (int pass = 0; pass < 10; pass++) {
      bool ch = false;
      for (size_t i = 0; i < w.ents.size(); i++) {
        const Ent& e = w.ents[i]; if (e.kind != Ent::NPC || e.dummy || e.node || e.hidden || e.pickup) continue;
        const std::string cn = e.name; w.interact(int(i));
        for (int qi : w.questsFor(cn)) {
          const Quest& q = Q[size_t(qi)]; const std::string st = questState(w, qi);
          if (st == "ready" && q.to == cn) { const bool was = w.P.done.count(q.id); w.completeQuest(qi); if (!was && w.P.done.count(q.id)) ch = true; }
          else if (st == "new" && q.giver == cn) { ch = true; w.dialogAccept(qi, cn); if (q.hasTp) return true; }
        }
      }
      if (!ch) break;
    }
    return false;
  };
  for (int step = 0; step < steps; step++) {
    std::string act = "konus";
    if (!talk()) {
      // 2) karar: teslim edilecek görev → alan kişi; sürmekte olan görev → hedefin haritası (savaş / toplama); yeni görev → veren kişi
      const std::string cur = w.sceneId; std::string gs, gn, kind; int gid = 0; std::vector<std::string> names;
      auto go = [&](const std::string& s, const std::string& nm) { gs = s; gn = nm; kind = "git"; };
      for (size_t qi = 0; qi < Q.size(); qi++) { const Quest& q = Q[qi]; if (!w.P.quests.count(q.id) || questState(w, int(qi)) != "ready") continue; const std::string s = pickSc(w.quests().npcScenes(q.to), ""); if (!s.empty() && s != cur) { go(s, q.to); break; } }
      if (kind.empty()) for (const Quest& q : Q) {
        auto it = w.P.quests.find(q.id); if (it == w.P.quests.end() || it->second.ready || tries[q.id] >= 5) continue;
        if (q.type == "special" && !q.flag.empty()) { kind = "bayrak"; gid = q.id; gn = q.flag; break; }   // çantayı aç, hedef değiştir… (düğmeye basmış gibi)
        if (q.type == "deliver" && !q.give.empty() && w.giveCount(q) < q.count) { kind = "esya"; gid = q.id; gn = q.give[0]; break; }   // dükkândan almış gibi
        if (q.type == "kill" || q.type == "collect") {
          names.clear();
          if (!q.targets.empty()) { for (const QTarget& x : q.targets) if (x.kind == QTarget::KILL || x.kind == QTarget::DROP) names.push_back(x.name); }
          else if (!q.mobs.empty()) names = q.mobs; else names.push_back(q.target);
          if (names.empty() || names[0].empty()) continue;
          const std::string s = pickSc(w.quests().monScenes(names[0]), q.sc); if (s.empty()) continue;
          const int ql = w.quests().sceneQLv(s); if (ql != INT_MIN && ql > w.P.lv + 2) continue;   // çok yüksek seviyeli harita
          if (s != cur) go(s, names[0]); else { kind = "savas"; gid = q.id; }
          break;
        }
        if (q.type == "talk" || (q.type == "pickup" && q.use)) { const std::string s = pickSc(w.quests().npcScenes(q.type == "talk" ? q.to : q.node), ""); if (!s.empty() && s != cur) { go(s, q.type == "talk" ? q.to : q.node); break; } continue; }
        if (q.type == "pickup") { const std::string s = pickSc(w.quests().npcScenes(q.node), ""); if (s.empty()) continue; if (s != cur) go(s, q.node); else { kind = "topla"; gid = q.id; gn = q.node; } break; }
      }
      if (kind.empty()) for (size_t qi = 0; qi < Q.size(); qi++) if (questState(w, int(qi)) == "new") { const std::string s = pickSc(w.quests().npcScenes(Q[qi].giver), ""); if (!s.empty() && s != cur) { go(s, Q[qi].giver); break; } }
      // 3) yapacak görev yok: seviye kas — açılmayı bekleyen en düşük seviyeli savaş görevinin canavarlarının haritasında 60 sn
      if (kind.empty()) {
        int bq = -1, bl = INT_MAX;
        for (size_t qi = 0; qi < Q.size(); qi++) { const Quest& q = Q[qi]; if ((q.type != "kill" && q.type != "collect") || q.target.empty() || questState(w, int(qi)) != "soon") continue; const int l = w.quests().minLv(int(qi)); if (l < bl) { bl = l; bq = int(qi); } }
        if (bq >= 0) { const std::string s = pickSc(w.quests().monScenes(Q[size_t(bq)].target), Q[size_t(bq)].sc); if (!s.empty()) { if (s != cur) go(s, Q[size_t(bq)].target); else { kind = "kas"; names.clear(); } } }
      }
      act = kind.empty() ? "yok" : kind;
      if (kind == "git") {
        bool f = false; int xy[2] = {0, 0};
        for (const core::Json& e : D["scenes"][gs]["ents"].arr()) if (e[1].str() == gn) { xy[0] = e[2][0].i(); xy[1] = e[2][1].i(); f = true; break; }
        if (f) w.loadScene(gs, xy); else w.loadScene(gs);
        act += " " + gs;
      } else if (kind == "savas" || kind == "kas") {   // savaş: görev hazır olana dek (en çok 90 sn); kas: 60 sn, her canavar
        if (kind == "savas") tries[gid]++;
        revive(); Player& p = w.player;
        auto ok = [&](const std::string& nm) { return names.empty() || std::find(names.begin(), names.end(), nm) != names.end(); };
        const int n = int((kind == "kas" ? 60 : 90) / dt + 0.5);
        for (int k = 0; k < n; k++) {
          if (kind == "savas") { auto it = w.P.quests.find(gid); if (it == w.P.quests.end() || it->second.ready) break; }
          const int t = w.target();
          if (t < 0 || w.ents[t].dead || w.ents[t].kind != Ent::MOB || !ok(w.ents[t].name)) {
            int best = -1; double bd = 1e300;
            for (size_t i = 0; i < w.ents.size(); i++) { const Ent& e = w.ents[i]; if (e.kind != Ent::MOB || e.dead || !ok(e.name)) continue; const double d = jsHypot(e.x - p.x, e.y - p.y); if (d < bd) { bd = d; best = int(i); } }
            if (best >= 0) { w.setTarget(best, true); if (bd > 3) { p.x = w.ents[size_t(best)].x; p.y = w.ents[size_t(best)].y; } }   // uzaksa yanına (savaşta yol bulma yok)
          }
          w.update(dt);
          if (p.dead) revive();
        }
        if (kind == "savas") act += " " + std::to_string(gid);
      } else if (kind == "esya") {
        tries[gid]++; const Quest& q = *w.quests().byId(gid); w.addItem(gn, q.count - w.giveCount(q)); act += " " + gn;
      } else if (kind == "bayrak") {
        tries[gid]++; w.questFlag(gn); act += " " + gn;
      } else if (kind == "topla") {
        tries[gid]++;
        for (size_t i = 0; i < w.ents.size(); i++) {
          auto it = w.P.quests.find(gid); if (it == w.P.quests.end() || it->second.ready) break;
          const Ent& e = w.ents[i]; if (e.kind == Ent::NPC && e.name == gn && !e.hidden && e.pickup) w.interact(int(i));
        }
        auto it = w.P.quests.find(gid); if (it != w.P.quests.end() && !it->second.ready) for (int k = 0; k < int(21 / dt + 0.5); k++) w.update(dt);
        act += " " + std::to_string(gid);
      }
    }
    // iz satırı
    std::string bag; for (const auto& b : w.P.bag) bag += (bag.empty() ? "" : ",") + b.first + ":" + std::to_string(b.second);
    std::string qs; for (const auto& kv : w.P.quests) {
      qs += (qs.empty() ? "" : ",") + std::to_string(kv.first) + ":" + std::to_string(kv.second.n) + (kv.second.ready ? "r" : "");
      for (const auto& c : kv.second.c) if (c.second) qs += "/" + c.first + "=" + std::to_string(c.second);
    }
    std::string dn; for (int id : w.P.done) dn += (dn.empty() ? "" : ",") + std::to_string(id);
    tr += std::string(step ? ",\n" : "") + "{\"adim\":" + std::to_string(step) + ",\"eylem\":\"" + act + "\",\"sahne\":\"" + w.sceneId + "\",\"lv\":" + std::to_string(w.P.lv) +
          ",\"xp\":" + std::to_string(w.P.xp) + ",\"altin\":" + std::to_string(w.P.gold) + ",\"ust\":" + std::to_string(w.P.adv) + ",\"canta\":\"" + bag +
          "\",\"gorev\":\"" + qs + "\",\"bitti\":\"" + dn + "\",\"x\":" + num(w.player.x) + ",\"y\":" + num(w.player.y) + "}";
  }
  // son: bütün kişilerin baş işaretleri (ad sırasıyla)
  std::vector<std::string> cns; for (const auto* kv : core::jsOrder(D["scenes"])) for (const core::Json& e : kv->second["ents"].arr()) if (D["mon"][std::to_string(e[0].i())].isNull()) cns.push_back(e[1].str());
  std::sort(cns.begin(), cns.end()); cns.erase(std::unique(cns.begin(), cns.end()), cns.end());
  std::string marks; for (const std::string& cn : cns) { const char m = w.npcMark(cn); if (m) marks += cn + m + ","; }
  return tr + "\n,{\"isaretler\":\"" + marks + "\"}]\n";
}

int main(int argc, char** argv) {
  if (argc != 2) { std::fprintf(stderr, "kullanım: anrufen_test <senaryo.txt|->\n"); return 2; }
  std::ifstream fin; std::istream* in = &std::cin;
  if (std::string(argv[1]) != "-") { fin.open(argv[1]); if (!fin) { std::fprintf(stderr, "senaryo açılamadı: %s\n", argv[1]); return 2; } in = &fin; }
  Vfs vfs; Assets assets; Balance bal; std::unique_ptr<World> world; Canvas canvas; canvas.resize(640, VH);
  DrawOpts opts; std::string line; int ln = 0; bool hudOn = false;
  ui::Fonts fonts; std::unique_ptr<ui::Forms> forms; std::unique_ptr<ui::Hud> hud;
  auto W = [&]() -> World& { if (!world) throw godat::Error("önce veri"); return *world; };
  try {
    while (std::getline(*in, line)) {
      ln++; std::istringstream ss(line); std::string cmd; ss >> cmd;
      if (cmd.empty() || cmd[0] == '#') continue;
      if (cmd == "veri") {
        std::string p; ss >> p;
        if (p.size() > 4 && p.substr(p.size() - 4) == ".gdp") vfs.mountPack(p); else vfs.mountDir(p);
        assets = Assets(); assets.load(vfs); bal = Balance(); bal.load(vfs, assets.D()); world = std::make_unique<World>(assets, bal);
        fonts.load(vfs); forms = std::make_unique<ui::Forms>(assets, fonts); forms->load(vfs); hud = std::make_unique<ui::Hud>(assets, fonts, *forms);
        std::printf("veri: %s\n", vfs.describe().c_str());
      } else if (cmd == "tohum") { uint32_t sd; ss >> sd; rng().seed(sd); }
      else if (cmd == "karakter") { std::string c, r, s; ss >> c >> r >> s; W().P = CharData(); W().flags.clear(); W().setChar(c, r, s); }   // yeni karakter (Sv 1, altın 0, çanta boş)
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
      } else if (cmd == "ust") ss >> W().P.adv;
      else if (cmd == "beceriler") {
        std::string l; ss >> l; W().P.sk.clear();
        std::istringstream ls(l == "-" ? "" : l); std::string tok;
        while (std::getline(ls, tok, ',')) { const size_t e = tok.find('='); if (e != std::string::npos) W().P.sk[tok.substr(0, e)] = std::stoi(tok.substr(e + 1)); }
        W().clampVitals();
      } else if (cmd == "dagit") {
        int n, spec; std::string f; ss >> n >> spec >> f; World& w = W();
        w.P.sk.clear(); w.P.sp = 0; w.skillAutoSpend(n, spec);
        std::string o; for (const auto& kv : w.P.sk) o += (o.empty() ? "" : ",") + kv.first + "=" + std::to_string(kv.second);   // anahtar sırasıyla
        if (f.empty()) std::printf("beceriler %s · artan puan %d\n", o.c_str(), w.P.sp); else out(f, o + "\n");
      } else if (cmd == "beceri") { int i; ss >> i; W().useSkill(i); }
      else if (cmd == "zaman0") W().time = 0;
      else if (cmd == "olumsuz") { int g; ss >> g; W().god = g != 0; }
      else if (cmd == "otogorev") W().autoQuests();
      else if (cmd == "gmbitir") {
        std::string ids, f, o = "[\n"; ss >> ids >> f; World& w = W(); std::istringstream is(ids); std::string tok; int k = 0;
        while (std::getline(is, tok, ',')) { w.gmQuestDone(std::stoi(tok)); o += std::string(k++ ? ",\n" : "") + questRec(w, tok); }
        out(f, o + "\n]\n");
      }
      else if (cmd == "gorevseviye") {
        std::string f, ters; ss >> f >> ters; Quests& Q = W().quests(); Q.resetLv(); const int n = int(Q.all().size());
        if (ters == "ters") for (int i = n - 1; i >= 0; i--) Q.minLv(i); else for (int i = 0; i < n; i++) Q.minLv(i);
        std::string o; for (int i = 0; i < n; i++) o += std::to_string(Q.all()[size_t(i)].id) + ":" + std::to_string(Q.minLv(i)) + "\n";
        out(f, o);
      } else if (cmd == "gorevbot") { int n; double dt; std::string f; ss >> n >> dt >> f; out(f, questBot(W(), assets.D(), n, dt)); }
      else if (cmd == "savas") {
        double dt, sec; std::string f, oto; ss >> dt >> sec >> f >> oto; World& w = W();
        const int steps = int(sec / dt + 0.5), per = int(1 / dt + 0.5); std::string tr = "[\n"; size_t rot = 0;
        for (int k = 1; k <= steps; k++) {
          if ((oto == "oto" || oto == "beceri") && (w.target() < 0 || w.ents[w.target()].dead)) { const int m = w.nearestMob(8); if (m >= 0) w.setTarget(m, true); }
          Player& p = w.player;
          if (oto == "beceri" && !p.dead && p.pending < 0 && p.state != "attack" && p.state != "cast") {
            const auto& L = w.skills();
            for (size_t j = 0; j < L.size(); j++) {   // sırayla döner: bir önceki kullanılandan sonraki ilk hazır beceri
              const size_t i = (rot + j) % L.size(); const SkillDef& sk = L[i]; if (sk.passive() || !w.skRank(sk)) continue;
              auto c = p.cds.find(sk.id); if (c != p.cds.end() && c->second > 0) continue;
              w.useSkill(int(i)); c = p.cds.find(sk.id);
              if ((c != p.cds.end() && c->second > 0) || p.pending >= 0) { rot = i + 1; break; }
            }
          }
          w.update(dt);
          if (k % per == 0) {
            int alive = 0; double sx = 0, sy = 0; for (const Ent& e : w.ents) if (e.kind == Ent::MOB) { alive += !e.dead; sx += e.x; sy += e.y; }
            std::string bag; for (const auto& b : w.P.bag) bag += (bag.empty() ? "" : ",") + b.first + ":" + std::to_string(b.second);
            const int t = w.target(); double mh = 0; for (const Ent& e : w.ents) if (e.kind == Ent::MOB) mh += e.hp;
            std::string guc; for (const Buff& b : w.player.buffs) guc += (guc.empty() ? "" : ",") + b.id;
            tr += std::string(k > per ? ",\n" : "") + "{\"s\":" + num(k * dt) + ",\"hp\":" + num(w.player.hp) + ",\"mp\":" + num(w.player.mp) + ",\"lv\":" + std::to_string(w.P.lv) +
                  ",\"xp\":" + std::to_string(w.P.xp) + ",\"altin\":" + std::to_string(w.P.gold) + ",\"x\":" + num(w.player.x) + ",\"y\":" + num(w.player.y) +
                  ",\"hedef\":" + std::to_string(t) + ",\"hedefCan\":" + num(t >= 0 ? w.ents[t].hp : -1) + ",\"canli\":" + std::to_string(alive) +
                  ",\"canavarX\":" + num(sx) + ",\"canavarY\":" + num(sy) + ",\"olu\":" + (w.player.dead ? "true" : "false") + ",\"canta\":\"" + bag + "\",\"canavarCan\":" + num(mh) + ",\"guc\":\"" + guc + "\"}";
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
      else if (cmd == "zemin") { std::string f; ss >> f; godat::writeFile(f, core::encodePNG(W().map.ground)); std::printf("zemin OX %d\n", W().map.OX); }   // harita zemini (hata ayıklama)
      else if (cmd == "halka") { int g; ss >> g; opts.targetRing = g != 0; }
      else if (cmd == "arayuz") { int g; ss >> g; hudOn = g != 0; }
      else if (cmd == "yazi") { int g; ss >> g; fonts.enabled = g != 0; }
      else if (cmd == "ad") { std::string a; std::getline(ss >> std::ws, a); W().P.name = a; }
      else if (cmd == "portre") ss >> W().P.face;
      else if (cmd == "hedefle") { int i; ss >> i; W().setTarget(i); }
      else if (cmd == "bekleme") { std::string id; double t; ss >> id >> t; W().player.cds[id] = t; }
      else if (cmd == "gorevver") { int id; ss >> id; W().P.quests[id] = QuestSt(); }   // görevi doğrudan alınmış say (test)
      else if (cmd == "esya") {
        std::string op, id; int n = 1; ss >> op >> id >> n; if (!ss) n = 1; World& w = W();
        if (op == "al") w.buyItem(id, n); else if (op == "sat") w.sellItem(id, n); else if (op == "giy") w.equip(id); else if (op == "cikar") w.unequip(id);
        else if (op == "kullan") w.useItem(id); else if (op == "ekle") w.addItem(id, n, true); else if (op == "sil") w.removeItem(id, n);
        else throw godat::Error("esya: bilinmeyen işlem " + op);
      } else if (cmd == "gmgear") W().gmGear();
      else if (cmd == "altin") ss >> W().P.gold;
      else if (cmd == "beceriyukselt") { int sn; ss >> sn; const SkillDef* sk = W().balance().skills.bySn(sn); if (sk) W().skillUp(*sk); }
      else if (cmd == "becerisifirla") { int f; ss >> f; W().skillReset(f != 0); }
      else if (cmd == "kisayol") { std::string sl; int qi; ss >> sl >> qi; W().assignQuick(sl, qi); }
      else if (cmd == "beceriyazilari") {   // her beceri: kilit iletisi, her kademede açıklama ve sonraki kademe farkı (satır satır)
        std::string f; ss >> f; World& w = W(); std::string o;
        std::vector<const SkillDef*> L; for (const SkillDef& k : w.skills()) L.push_back(&k); for (const SkillDef& k : w.balance().skills.race(w.P.race)) L.push_back(&k);
        for (const SkillDef* k : L) {
          o += k->id + "\t" + k->name + "\t" + w.skLockMsg(*k) + "\n";
          for (int r = 1; r <= (k->mx ? k->mx : 10); r++) o += "  " + std::to_string(r) + "\t" + w.skDesc(*k, r) + "\t" + (r < (k->mx ? k->mx : 10) ? w.skNextDiff(*k, r) : std::string()) + "\n";
        }
        out(f, o);
      }
      else if (cmd == "karakterdurum") {
        std::string f; ss >> f; World& w = W(); const Stats s = w.stats(); auto q = [](const std::string& x) { return "\"" + x + "\""; };
        std::string o = "{\"altin\":" + std::to_string(w.P.gold) + ",\"canta\":[";
        for (size_t i = 0; i < w.P.bag.size(); i++) o += (i ? "," : "") + std::string("[") + q(w.P.bag[i].first) + "," + std::to_string(w.P.bag[i].second) + "]";
        o += "],\"eq\":{"; bool fst = true; for (const auto& kv : w.P.eq) if (!kv.second.empty()) { o += (fst ? "" : ",") + q(kv.first) + ":" + q(kv.second); fst = false; }
        o += "},\"sk\":{"; fst = true; for (const auto& kv : w.P.sk) { o += (fst ? "" : ",") + q(kv.first) + ":" + std::to_string(kv.second); fst = false; }
        o += "},\"sp\":" + std::to_string(w.P.sp) + ",\"can\":" + num(w.player.hp) + ",\"mana\":" + num(w.player.mp);
        o += ",\"st\":[" + num(s.hp) + "," + num(s.mp) + "," + num(s.atk) + "," + num(s.def) + "," + num(s.crit) + "," + num(s.dodge) + "," + num(s.res) + "," + num(s.hpreg) + "," + num(s.mpreg) + "]";
        o += ",\"gorunum\":[" + q(w.player.look.bodyG) + "," + q(w.player.look.headG) + "," + q(w.player.look.weapG) + "],\"kisayol\":[";
        for (size_t i = 0; i < w.P.quick.size(); i++) o += (i ? "," : "") + q(w.P.quick[i]);
        o += "],\"ileti\":" + q(w.log.empty() ? std::string() : w.log.back().m) + ",\"bildirim\":" + q(w.toastMsg) + "}\n";
        out(f, o);
      }
      else if (cmd == "gorevhazir") { int id, n = 0; ss >> id >> n; QuestSt q; q.n = n; q.ready = true; W().P.quests[id] = q; }   // görev teslime hazır (test)
      else if (cmd == "pencere") { std::string n; int e = -1; ss >> n >> e; hud->win.close(); if (n == "shop") hud->win.openShop(W(), W().ents.at(size_t(e)).name); else if (n != "kapat") hud->win.open(W(), n, e); }
      else if (cmd == "ciz") { W().draw(canvas, opts); hud->draw(canvas, W(), false); }
      else if (cmd == "dokun") { float x, y; ss >> x >> y; hud->press(W(), 1, x, y); hud->release(W(), 1, x, y); hud->win.clearPressed(); hud->draw(canvas, W(), false); }
      else if (cmd == "konus") { int e; ss >> e; W().talkTo(e); hud->draw(canvas, W(), false); }
      else if (cmd == "yol") {
        double a, b2, c2, d; std::string f; ss >> a >> b2 >> c2 >> d >> f; std::vector<std::pair<int, int>> P2; std::string o;
        if (W().findPath(a, b2, c2, d, P2)) { for (const auto& q : P2) o += (o.empty() ? "" : " ") + std::to_string(q.first) + "," + std::to_string(q.second); if (o.empty()) o = "-"; } else o = "yok";
        std::ofstream(f, std::ios::app) << o << "\n";
      } else if (cmd == "rotagecikme") ss >> W().routeDelay;   // varıştan sonra yola devam gecikmesi (HTML setTimeout 400; testte 0)
      else if (cmd == "kisiyeyuru") { int e; ss >> e; W().walkToEnt(e); }
      else if (cmd == "gorevyuru") { int id; ss >> id; W().questWalk(W().quests().indexOf(id)); }
      else if (cmd == "ilerle") {
        double dt, sec; std::string f; ss >> dt >> sec >> f; World& w = W(); std::string o = "{\"varis\":[", last = w.sceneId; int dialog = -1;
        const int n = int(sec / dt + 0.5); bool first = true;
        for (int k = 0; k < n; k++) {
          w.update(dt);
          if (w.dialogEnt >= 0) { dialog = w.dialogEnt; w.dialogEnt = -1; }
          if (w.sceneId != last) { last = w.sceneId; o += std::string(first ? "" : ",") + "[\"" + w.sceneId + "\"," + num(w.player.x) + "," + num(w.player.y) + "]"; first = false; }
        }
        o += "],\"sahne\":\"" + w.sceneId + "\",\"x\":" + num(w.player.x) + ",\"y\":" + num(w.player.y) + ",\"hedef\":" + std::to_string(w.target()) + ",\"konusma\":" + std::to_string(dialog) + "}\n";
        out(f, o);
      }
      else if (cmd == "temizle") { World& w = W(); w.log.clear(); w.floats.clear(); w.zoneT = w.toastT = w.lvlT = w.hurtT = 0; w.toastMsg.clear(); }
      else if (cmd == "can") { double k; ss >> k; W().player.hp = W().stats().hp * k; }
      else if (cmd == "mana") { double k; ss >> k; W().player.mp = W().stats().mp * k; }
      else if (cmd == "goruntu") {
        std::string f; ss >> f; W().draw(canvas, opts); if (hudOn) hud->draw(canvas, W(), false); godat::writeFile(f, core::encodePNG(canvas.img));
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
