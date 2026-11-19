// Ağ (aşama 1) sınaması: kayıttan yeniden oynatma (docs/10-ag.md). Rastgele oynayan bir bot yalnız karo yönü ve komut göndererek oynar
// (savaş, beceri, iksir, kişiyle konuşma, görev alma/teslim, görev yürüyüşüyle harita değişimi, ölüm ve diriliş, onay kutuları);
// her adımın yönü ve her komut adım numarasıyla kaydedilir. Yeniden oynatma, sunucunun yapacağı gibi aynı başlangıçtan (kayıt JSON'u
// + tohum + oyun saati → start) kayıttaki girdileri uygular; belirli adımlarda iki dünyanın özeti karşılaştırılır.
#include "app/agtest.h"

#include <cstdio>
#include <map>

#include "engine/rng.h"

namespace agtest {

using engine::Cmd;
using engine::World;

namespace {
const double STEP = 1.0 / 60;
const int DIGEST_EVERY = 30;
std::string hex(uint64_t v) { char b[20]; std::snprintf(b, sizeof b, "%016llx", (unsigned long long)v); return b; }

// sunucunun "start"ı: kayıttan dünyayı kur (HTML start), tohum ve oyun saati sunucudan
void begin(World& w, const core::Json& save, uint32_t seed, double clock0) {
  w.online = true; w.clockMs = clock0; w.loadSave(save); engine::rng().seed(seed); w.start(); w.tick = 0;
}
}  // namespace

std::string botRun(engine::Assets& as, engine::Balance& bal, const core::Json& save, uint32_t seed, double clock0, double seconds, uint32_t botSeed, uint64_t* finalDigest) {
  World w(as, bal); begin(w, save, seed, clock0);
  engine::Rng bot(botSeed);   // botun kendi zarı (oyunun zarına dokunmaz)
  auto br = [&](int a, int b) { return a + int(bot.next() * (b - a + 1)); };
  std::vector<int> dirs; std::vector<std::pair<long long, Cmd>> cmds; std::vector<std::pair<long long, uint64_t>> dig;
  w.onCmd = [&](const Cmd& c) { cmds.push_back({w.tick, c}); };
  const long long N = (long long)(seconds * 60);
  int walkDir = -1, walkLeft = 0, think = 0;
  for (long long k = 0; k < N; k++) {
    if (--think <= 0) {   // ~0,25 sn'de bir karar
      think = 15;
      if (!w.askText.empty()) { auto yes = w.askYes; w.askText.clear(); w.askYes = nullptr; if (bot.next() < 0.7 && yes) yes(); }   // onay kutusu (zindan kapısı…)
      else if (w.player.dead) w.cmd({"revive", {}});
      else if (walkLeft <= 0) {
        const double r = bot.next(); const auto s = w.stats();
        if (w.player.hp < s.hp * 0.4 && w.countItem("hp1")) w.cmd({"item", {"hp1"}});
        else if (r < 0.25) { walkDir = br(0, 3); walkLeft = br(20, 120); }
        else if (r < 0.55) { const int t = w.nearestMob(9); if (t >= 0) w.cmd({"target", {std::to_string(t), "1"}}); }
        else if (r < 0.70) { if (w.target() >= 0) w.cmd({"skill", {std::to_string(br(0, int(w.skills().size()) - 1))}}); }
        else if (r < 0.82) {   // en yakın kişiyle konuş; alınabilir görevi al, hazır olanı teslim et
          int best = -1; double bd = 1e9;
          for (size_t i = 0; i < w.ents.size(); i++) { const auto& e = w.ents[i]; if (e.kind != engine::Ent::NPC || e.hidden || e.dummy || e.pickup) continue; const double d = engine::jsHypot(e.x - w.player.x, e.y - w.player.y); if (d < bd) { bd = d; best = int(i); } }
          if (best >= 0) {
            w.cmd({"talk", {std::to_string(best)}});
            const std::string cn = w.ents[size_t(best)].name;
            for (int qi : w.questsFor(cn)) { const std::string st = w.questState(qi); if (st == "new") { w.cmd({"accept", {std::to_string(qi), cn}}); break; } if (st == "ready") { w.cmd({"complete", {std::to_string(qi)}}); break; } }
          }
        } else if (r < 0.90) {   // sürmekte olan bir görevin yolunu bul (haritalar arası yürüyüş)
          std::vector<int> act; const auto& Q = w.quests().all(); for (size_t i = 0; i < Q.size(); i++) if (w.P.quests.count(Q[i].id)) act.push_back(int(i));
          if (!act.empty()) w.cmd({"questWalk", {std::to_string(act[size_t(br(0, int(act.size()) - 1))])}});
        } else if (r < 0.93) w.cmd({"item", {"mp1"}});
        else if (r < 0.95) w.cmd({"cycle", {}});
      }
    }
    int dir = -1; if (walkLeft > 0) { dir = walkDir; walkLeft--; }
    dirs.push_back(dir);
    w.step(STEP, dir);
    if (w.tick % DIGEST_EVERY == 0) dig.push_back({w.tick, w.digest()});
  }
  if (finalDigest) *finalDigest = w.digest();
  // kayıt: başlangıç + yönler (aynı yön art arda: [yön, sayı]) + komutlar + özetler
  core::Json o = core::Json::object(); o.set("save", save); o.set("seed", core::Json::number(double(seed))); o.set("clock", core::Json::number(clock0)); o.set("n", core::Json::number(double(N)));
  core::Json D = core::Json::array(); for (size_t i = 0; i < dirs.size();) { size_t j = i; while (j < dirs.size() && dirs[j] == dirs[i]) j++; core::Json p = core::Json::array(); p.push(core::Json::number(double(dirs[i]))); p.push(core::Json::number(double(j - i))); D.push(p); i = j; }
  o.set("d", D);
  core::Json C = core::Json::array(); for (const auto& c : cmds) { core::Json p = core::Json::array(); p.push(core::Json::number(double(c.first))); p.push(core::Json::text(c.second.op)); for (const auto& a : c.second.a) p.push(core::Json::text(a)); C.push(p); }
  o.set("c", C);
  core::Json H = core::Json::array(); for (const auto& h : dig) { core::Json p = core::Json::array(); p.push(core::Json::number(double(h.first))); p.push(core::Json::text(hex(h.second))); H.push(p); }
  o.set("h", H);
  o.set("son", core::Json::text(std::string("Sv ") + std::to_string(w.P.lv) + " · " + w.sceneId + " · altın " + std::to_string(w.P.gold) + " · görev " + std::to_string(w.P.quests.size()) + "/" + std::to_string(w.P.done.size())));
  return o.dump();
}

std::string replay(engine::Assets& as, engine::Balance& bal, const core::Json& rec, uint64_t* finalDigest) {
  World w(as, bal); begin(w, rec["save"], uint32_t(rec["seed"].num()), rec["clock"].num());
  std::vector<int> dirs; for (const core::Json& p : rec["d"].arr()) for (int k = 0; k < p[1].i(); k++) dirs.push_back(p[0].i());
  std::multimap<long long, Cmd> cmds; for (const core::Json& p : rec["c"].arr()) { Cmd c; c.op = p[1].str(); for (size_t k = 2; k < p.arr().size(); k++) c.a.push_back(p[k].str()); cmds.insert({(long long)p[0].num(), c}); }
  std::map<long long, std::string> want; for (const core::Json& p : rec["h"].arr()) want[(long long)p[0].num()] = p[1].str();
  int ok = 0, bad = 0, rejected = 0; long long firstBad = -1;
  for (size_t k = 0; k < dirs.size(); k++) {
    auto r = cmds.equal_range(w.tick); for (auto it = r.first; it != r.second; ++it) if (!w.exec(it->second)) rejected++;
    w.step(STEP, dirs[k]);
    auto h = want.find(w.tick);
    if (h != want.end()) { if (hex(w.digest()) == h->second) ok++; else { bad++; if (firstBad < 0) firstBad = w.tick; } }
  }
  if (finalDigest) *finalDigest = w.digest();
  return "{\"adim\":" + std::to_string(dirs.size()) + ",\"komut\":" + std::to_string(cmds.size()) + ",\"reddedilen\":" + std::to_string(rejected) +
         ",\"ozetAyni\":" + std::to_string(ok) + ",\"ozetFarkli\":" + std::to_string(bad) + ",\"ilkFark\":" + std::to_string(firstBad) + "}";
}

}  // namespace agtest
