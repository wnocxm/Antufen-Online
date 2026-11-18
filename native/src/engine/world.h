// Dünya: sahne yükleme, NPC'ler, oyuncu, kamera, yürüme ve çizim (HTML'de game.js loadScene/update + ui.js drawWorld).
// 2. adım kapsamı: zemin, nesneler, NPC'ler, oyuncu; 4 yönlü yürüme. Canavarlar, savaş, görev … sonraki adımlarda.
#pragma once
#include <memory>
#include <string>
#include <vector>

#include "engine/assets.h"
#include "engine/map.h"

namespace engine {

const double RUN = 4.2, CELL_PX = 30, STRIDE = 66;   // koşu hızı (kare/sn), adım ölçüsü (HTML game.js)
const int VH = 360;                                   // mantıksal ekran yüksekliği (HTML ui.js)

struct Npc { std::string id, cn; double x = 0, y = 0, t = 0; Sprite* sp = nullptr; int anim = 0; bool pickup = false, hidden = false; };

struct Player {
  double x = 0, y = 0, t = 0, animT = 0;
  int dir = 2;   // 0 sağ-yukarı (-y), 1 sağ-aşağı (+x), 2 sol-aşağı (+y), 3 sol-yukarı (-x)
  bool moving = false;
  Look look;
  Paperdoll doll;
};

struct DrawOpts { bool shadows = true; };

class World {
 public:
  explicit World(Assets& as) : as_(as) {}
  void loadScene(const std::string& sid, const int* arrive = nullptr);   // arrive: {x, y} ya da sahnenin girişi
  void setLook(const Look& l) { player.look = l; player.doll.set(as_, l); }
  // sx, sy: ekran yönünde girdi (klavye: x*21, y*11*1.9; joystick: çubuk vektörü); ikisi de 0 ise durur
  void update(double dt, double sx = 0, double sy = 0);
  void draw(Canvas& c, const DrawOpts& o = {});
  void resetClock();   // test: zaman ve bütün animasyon sayaçları 0 (HTML karşılaştırması için)

  std::string sceneId, sceneName;
  GameMap map;
  std::vector<Npc> npcs;
  Player player;
  double time = 0, camX = 0, camY = 0;

 private:
  Assets& as_;
  int lastJoyDir_ = -1;
  void moveEnt(double dx, double dy);
};

int dirOf(double dx, double dy);

}  // namespace engine
