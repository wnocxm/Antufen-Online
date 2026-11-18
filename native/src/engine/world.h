// Dünya: sahne, varlıklar (NPC, canavar), oyuncu, efektler, zamanlayıcılar, savaş (HTML'de game.js loadScene/update/hitMob/
// hurtPlayer/killMob/gainXp/stats + ui.js drawWorld). Sıra ve hesaplar HTML ile birebir: iki sürüm aynı tohumla aynı sonucu verir
// (tools/test/cpp_savas.js). Henüz yok (sonraki adımlar): beceriler, güçlendirmeler, görevler, evcil hayvan, zindan, arayüz.
#pragma once
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "engine/assets.h"
#include "engine/balance.h"
#include "engine/map.h"
#include "engine/rng.h"

namespace engine {

const double RUN = 4.2, CELL_PX = 30, STRIDE = 66;   // koşu hızı (kare/sn), adım ölçüsü (HTML game.js)
const int VH = 360;                                   // mantıksal ekran yüksekliği (HTML ui.js)

// NPC ve canavarlar tek listede, oluşturulma sırasıyla (HTML Game.ents): zar atışları bu sırayla yapılır
struct Ent {
  enum Kind { NPC, MOB } kind = NPC;
  std::string id, name;            // NPC: Çince ad (cn); canavar: ad
  double x = 0, y = 0, t = 0;
  int dir = 2;
  Sprite* sp = nullptr;
  // NPC
  int anim = 0; bool pickup = false, hidden = false, dummy = false, node = false; double respawnT = 0;
  // canavar
  MonDef* d = nullptr;
  double hp = 0, maxHp = 0, atk = 0, def = 0, homeX = 0, homeY = 0;
  std::string state = "idle", deathFx;
  double atkT = 0, wanderT = 0, slowT = 0, animT = 0, stateT = 0, deadT = 0, rootT = 0, sealT = 0, stunT = 0, despairT = 0, tauntT = 0, weakT = 0, weakDef = 0;
  bool aggro = false, dead = false, hasW = false; double wx = 0, wy = 0; char ax = 0;
};

struct Player {
  double x = 0, y = 0, t = 0, animT = 0, hp = 0, mp = 0, atkT = 0, combatT = 0, stateT = 0, deadT = 0, chaseD = 0;
  bool hasChase = false, dead = false; char ax = 0;
  int dir = 2;   // 0 sağ-yukarı (-y), 1 sağ-aşağı (+x), 2 sol-aşağı (+y), 3 sol-yukarı (-x)
  std::string state = "idle";
  Look look;
  Paperdoll doll;
};

// Karakter kaydı (HTML Game.P'nin bu adımda kullanılan kısmı)
struct CharData {
  std::string cls = "战士", race = "人类", sex = "male";
  int lv = 1, sp = 0; long long xp = 0, gold = 0;
  std::map<std::string, std::string> eq;                 // yuva → eşya
  std::vector<std::pair<std::string, int>> bag;          // çanta (eklenme sırası)
};

struct Stats { double hp = 0, mp = 0, atk = 0, def = 0, crit = 0, dodge = 0, hpreg = 0, mpreg = 0, res = 0, dr = 0, spd = 0, goldUp = 0, lifeEl = 0; };

struct Fx {
  Sprite* sp = nullptr; double x = 0, y = 0, t = 0, z = 0, ox = 0, oy = 0, life = -1; int anim = 0, len = 0, follow = -1;   // follow: -2 oyuncu, ≥0 varlık
  bool loop = false, done = false, proj = false, vis = false; int to = -1; double speed = 9; std::function<void()> cb;
};

struct DrawOpts { bool shadows = true; };

class World {
 public:
  World(Assets& as, Balance& bal) : as_(as), bal_(bal) {}
  void loadScene(const std::string& sid, const int* arrive = nullptr);   // arrive: {x, y} ya da sahnenin girişi
  void gotoScene(const std::string& sid, const std::string& fromSid);  // geçitten geçiş: varış hedef sahnedeki karşı geçidin yanı
  void setLook(const Look& l) { player.look = l; player.doll.set(as_, l); }
  void setChar(const std::string& cls, const std::string& race, const std::string& sex);
  void setLevel(int lv);                                               // HTML gmLevel
  // sx, sy: ekran yönünde girdi (klavye: x*21, y*11*1.9; joystick: çubuk vektörü); ikisi de 0 ise durur
  void update(double dt, double sx = 0, double sy = 0);
  void draw(Canvas& c, const DrawOpts& o = {});
  void resetClock();   // test: zaman ve bütün animasyon sayaçları 0 (HTML karşılaştırması için)

  Stats stats() const;
  void setTarget(int ent, bool engage = false) { engage_ = engage && ent >= 0; target_ = ent; }
  int target() const { return target_; }
  bool engaged() const { return engage_; }
  int nearestMob(double r) const;
  int countItem(const std::string& id) const;

  std::string sceneId, sceneName;
  GameMap map;
  std::vector<Ent> ents;
  std::vector<Fx> fx;
  Player player;
  CharData P;
  double time = 0, camX = 0, camY = 0, arriveT = 0;

 private:
  Assets& as_;
  Balance& bal_;
  const core::Json* scene_ = nullptr;
  std::vector<uint8_t> extraBlock_;
  struct Timer { double t; std::function<void()> fn; };
  std::vector<Timer> timers_;
  int lastJoyDir_ = -1, target_ = -1;
  bool engage_ = false;

  bool blocked(double fx, double fy) const;
  void later(double s, std::function<void()> fn) { timers_.push_back({s, std::move(fn)}); }
  template <class E> void moveEnt(E& e, double dx, double dy);
  template <class E> bool stepTo(E& e, double tx, double ty, double sp, double dt);
  void spawnMob(const std::string& name, int x, int y);
  int pushFx(const std::string& name, double x, double y, int dir = -1);
  void shoot(const std::string& name, double fx, double fy, int to, std::function<void()> cb, bool vis);
  struct Dmg { int d; bool crit; };
  Dmg dmgCalc(double atk, double def, double mult, double critB = 0, double add = 0);
  int hitMob(int i, double mult);
  void killMob(int i);
  void hurtPlayer(int i);
  void gainXp(long long n);
  void addItem(const std::string& id, int n = 1);
  std::string randomGear(int lv);
  void checkExits();
  void drawMob(Canvas& c, Ent& e, int X, int Y);
  void drawPlayer(Canvas& c, int X, int Y);
};

int dirOf(double dx, double dy);
int fxAnim(const Sprite& sp, int dir);

}  // namespace engine
