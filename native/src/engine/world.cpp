#include "world.h"

#include <algorithm>
#include <cmath>

namespace engine {

static const int DIR4[4][2] = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};

int dirOf(double dx, double dy) {
  const double ax = std::fabs(dx), ay = std::fabs(dy);
  if (ax > 0 && ay > 0 && std::fabs(ax - ay) < 0.2 * std::max(ax, ay)) {
    if (dx > 0 && dy < 0) return 1;   // ekranda sağa
    if (dx < 0 && dy > 0) return 3;   // ekranda sola
    return dy > 0 ? 2 : 0;            // ekranda aşağı / yukarı
  }
  if (ax > ay) return dx > 0 ? 1 : 3;
  return dy > 0 ? 2 : 0;
}

void World::loadScene(const std::string& sid, const int* arrive) {
  const core::Json& D = as_.D(), &sc = D["scenes"][sid];
  if (!sc.isObj()) throw godat::Error("sahne yok: " + sid);
  sceneId = sid; sceneName = sc["name"].str();
  map.load(as_, sc["map"].str());
  // giriş: verilen yer, yoksa giriş bölgesinin (tür 0) ortası (HTML gotoScene)
  int px = 0, py = 0; bool have = false;
  if (arrive) { px = arrive[0]; py = arrive[1]; have = true; }
  else for (const auto& r : map.regions) if (r.size() >= 6 && r[1] == 0) { px = int(jsRound((r[2] + r[4]) / 2.0)); py = int(jsRound((r[3] + r[5]) / 2.0)); have = true; break; }
  if (!have || map.blocked(px, py)) {
    for (const auto& r : map.regions) if (r.size() >= 6 && r[1] == 0) { px = r[2]; py = r[3]; break; }
  }
  if (map.blocked(px, py)) {
    for (int R = 1; R < 30; R++) { bool f = false;
      for (int dy = -R; dy <= R && !f; dy++) for (int dx = -R; dx <= R && !f; dx++) if (!map.blocked(px + dx, py + dy)) { px += dx; py += dy; f = true; }
      if (f) break; }
  }
  // NPC'ler (canavarlar sonraki adımda)
  npcs.clear();
  for (const core::Json& e : sc["ents"].arr()) {
    const std::string id = std::to_string(e[0].i());
    const core::Json& info = D["cit"][id]; if (!info.isArr()) continue;
    Npc n; n.id = id; n.cn = info[0].str(); n.x = e[2][0].num(); n.y = e[2][1].num(); n.sp = map.sprite(info[1].str());
    for (const core::Json& s : info.arr()) if (s.str().find("npc_pickup") != std::string::npos) n.pickup = true;
    npcs.push_back(n);
  }
  player.x = px; player.y = py; player.moving = false;
  if (player.look.cls.empty()) setLook(Look{});
  else player.doll.set(as_, player.look);
  camX = map.px(player.x, player.y); camY = map.py(player.x, player.y);
}

void World::resetClock() { time = 0; player.t = 0; player.animT = 0; for (Npc& n : npcs) n.t = 0; }

void World::moveEnt(double dx, double dy) {
  Player& e = player;
  if (!map.blocked(e.x + dx, e.y)) e.x += dx; else if (!map.blocked(e.x + dx, jsRound(e.y))) e.x += dx;
  if (!map.blocked(e.x, e.y + dy)) e.y += dy;
}

void World::update(double dt, double sx, double sy) {
  time += dt;
  Player& p = player; const double x0 = p.x, y0 = p.y;
  p.moving = false;
  if (sx || sy) {
    // ekrandaki yöne en yakın karo ekseni (açılar 27,6° / 152,4° / 207,6° / 332,4°); sınırda titremesin diye son yöne küçük öncelik
    const double ang = std::atan2(sy, sx); int best = 0; double bd = 9;
    for (int i = 0; i < 4; i++) {
      const double aa = std::atan2(DIR4[i][0] * HH + DIR4[i][1] * HH, DIR4[i][0] * HW - DIR4[i][1] * HW);
      double d = std::fabs(std::atan2(std::sin(ang - aa), std::cos(ang - aa))); if (i == lastJoyDir_) d -= 0.25;
      if (d < bd) { bd = d; best = i; }
    }
    lastJoyDir_ = best;
    const double sp = RUN * dt;
    moveEnt(DIR4[best][0] * sp, DIR4[best][1] * sp); p.dir = dirOf(DIR4[best][0], DIR4[best][1]); p.moving = true;
  } else lastJoyDir_ = -1;
  const double went = std::hypot(p.x - x0, p.y - y0) * CELL_PX;
  if (p.moving) p.t += went * 8 / STRIDE; else p.t += dt * TICK;
  for (Npc& n : npcs) n.t += dt * TICK * 0.8;
  camX = map.px(p.x, p.y); camY = map.py(p.x, p.y) - 40;   // kamera karaktere kilitli
}

void World::draw(Canvas& c, const DrawOpts& o) {
  const int vw = c.w(), vh = c.h();
  const double ox = jsRound(camX - vw / 2.0), oy = jsRound(camY - vh / 2.0);
  c.fill(0, 0, 0);
  // zemin
  const int sx = int(std::max(0.0, ox)), sy = int(std::max(0.0, oy)), ex = int(std::min<double>(map.pw, ox + vw)), ey = int(std::min<double>(map.ph, oy + vh));
  if (ex > sx && ey > sy) c.blit(map.ground, sx, sy, ex - sx, ey - sy, int(sx - ox), int(sy - oy));
  // nesneler ve varlıklar derinliğe göre (eşit derinlikte ekleme sırası korunur)
  struct Item { double depth; int kind; size_t i; };   // kind 0 nesne, 1 NPC, 2 oyuncu
  std::vector<Item> list;
  const double tt = time * TICK;
  for (size_t i = 0; i < map.objs.size(); i++) {
    const MapObj& ob = map.objs[i];
    if (ob.X < ox - 350 || ob.X > ox + vw + 350 || ob.Y < oy - 40 || ob.Y > oy + vh + 450) continue;
    if (ob.flat) { ob.sp->draw(c, ob.anim, tt, int(ob.X - ox), int(ob.Y - oy)); continue; }
    list.push_back({double(ob.depth), 0, i});
  }
  auto visible = [&](double X, double Y) { return !(X < ox - 100 || X > ox + vw + 100 || Y < oy - 20 || Y > oy + vh + 150); };
  for (size_t i = 0; i < npcs.size(); i++) if (visible(map.px(npcs[i].x, npcs[i].y), map.py(npcs[i].x, npcs[i].y))) list.push_back({npcs[i].x + npcs[i].y + 0.01, 1, i});
  if (visible(map.px(player.x, player.y), map.py(player.x, player.y))) list.push_back({player.x + player.y + 0.01, 2, 0});
  std::stable_sort(list.begin(), list.end(), [](const Item& a, const Item& b) { return a.depth < b.depth; });
  for (const Item& it : list) {
    if (it.kind == 0) { const MapObj& ob = map.objs[it.i]; ob.sp->draw(c, ob.anim, tt, int(ob.X - ox), int(ob.Y - oy)); continue; }
    const double ex2 = it.kind == 1 ? npcs[it.i].x : player.x, ey2 = it.kind == 1 ? npcs[it.i].y : player.y;
    const int X = int(jsRound(map.px(ex2, ey2) - ox)), Y = int(jsRound(map.py(ex2, ey2) - oy));
    if (it.kind == 1) {
      Npc& n = npcs[it.i];
      if (o.shadows && !n.hidden) c.shadow(X, Y, 11, 5, 0.35f);
      if (!n.hidden && n.sp->ok()) n.sp->draw(c, std::min(n.anim, n.sp->animCount() - 1), n.t, X, Y);
    } else {
      if (o.shadows) c.shadow(X, Y, 11, 5, 0.35f);
      // HTML Player.draw: duruş comm/yön, yürüme comm 4 + yön
      player.doll.draw(c, "comm", player.moving ? 4 + player.dir : player.dir, player.t, X, Y);
    }
  }
}

}  // namespace engine
