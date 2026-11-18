// Dünya: sahne, varlıklar (NPC, canavar), oyuncu, efektler, zamanlayıcılar, savaş (HTML'de game.js loadScene/update/hitMob/
// hurtPlayer/killMob/gainXp/stats + ui.js drawWorld). Sıra ve hesaplar HTML ile birebir: iki sürüm aynı tohumla aynı sonucu verir
// (tools/test/cpp_savas.js). Beceriler (useSkill), güçlendirmeler, süren etkiler (kanama, yanma, çürüme), Büyü Hayali burada;
// beceri tanımları skills.cpp; görevler world_quests.cpp (veri quests.cpp). Henüz yok (sonraki adımlar): arayüz, eşya/dükkân, evcil hayvan, zindan.
#pragma once
#include <functional>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <vector>

#include "engine/assets.h"
#include "engine/balance.h"
#include "engine/map.h"
#include "engine/quests.h"
#include "engine/rng.h"
#include "engine/skills.h"

namespace engine {

const double RUN = 4.2, CELL_PX = 30, STRIDE = 66;   // koşu hızı (kare/sn), adım ölçüsü (HTML game.js)
const int VH = 360;                                   // mantıksal ekran yüksekliği (HTML ui.js)

using Aura = std::vector<std::pair<std::string, int>>;   // süren etkinin görseli: anahtar → efekt numarası (Fx::uid)

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
  struct { bool on = false; int n = 0; double t = 0, tick = 0; } bleed;                    // Testere Bıçak kanaması (en çok 5 kat)
  struct { bool on = false; double t = 0, tick = 0; } burn;                                // Alev Darbesi yanması
  struct { bool on = false; int n = 0; double t = 0, mult = 0, add = 0, suck = 0; bool corr = false; } dot;   // Çürüme
  Aura aura;
};

// güçlendirme / süren etki (HTML p.buffs öğesi): at varsa yalnız o yerin yakınında işler (Şifa Pınarı)
struct Buff { std::string id; Vals buff; double t = 0; std::string fx; bool hasAt = false; double atX = 0, atY = 0, atR = 0; int n = 0, uid = 0; double acc = 0; };   // uid: aynı öğe mi (JS nesne kimliği)

struct Player {
  double x = 0, y = 0, t = 0, animT = 0, hp = 0, mp = 0, atkT = 0, combatT = 0, stateT = 0, deadT = 0, chaseD = 0;
  bool hasChase = false, dead = false; char ax = 0;
  int dir = 2;   // 0 sağ-yukarı (-y), 1 sağ-aşağı (+x), 2 sol-aşağı (+y), 3 sol-yukarı (-x)
  std::string state = "idle";
  Look look;
  Paperdoll doll;
  std::vector<Buff> buffs;
  std::map<std::string, double> cds;   // beceri bekleme süreleri
  int pending = -1;                    // menzile girince kullanılacak beceri
  bool pathOn = false; std::vector<std::pair<int, int>> path;   // yürünecek yol (HTML p.path; pathOn false = null)
  double stunCd = -1e300, sealCd = -1e300, despCd = -1e300, veilCd = -1e300;   // tetiklenen etkilerin bekleme sonu (oyun saati)
  Aura aura;
};

// görev ilerlemesi (HTML P.quests[id]): n sayaç, ready tamamlandı (teslim bekliyor), c çok hedefli/çok eşyalı sayaçlar
struct QuestSt { int n = 0; bool ready = false; std::map<std::string, int> c; };

// Karakter kaydı (HTML Game.P'nin bu adımda kullanılan kısmı)
struct CharData {
  std::string cls = "战士", race = "人类", sex = "male";
  std::string name = "Kahraman", face = "1001";            // ad, portre (ui/Portrait_<face>.png; ırk/cinsiyet + 001-008)
  int lv = 1, sp = 0, adv = 0; long long xp = 0, gold = 0;   // adv: sınıf yükseltmesi (1: 40, 2: 80)
  std::vector<std::string> quick = {"s0", "s1", "s2", "s3", "s4", "s5", "i:hp1", "i:mp1"};   // kısayol halkası: [0] büyük düğme, s<n> beceri, i:<eşya>
  std::map<std::string, int> sk;                         // beceri kademeleri (beceri numarası → kademe)
  std::map<std::string, std::string> eq;                 // yuva → eşya
  std::vector<std::pair<std::string, int>> bag;          // çanta (eklenme sırası)
  std::map<int, QuestSt> quests;                         // alınmış görevler
  std::set<int> done;                                    // bitmiş görevler
  bool hasHome = false; std::string homeScene; bool homeXY = false; int homeX = 0, homeY = 0;   // ölünce doğulan yer (ışınlanma görevi)
};

struct Stats { double hp = 0, mp = 0, atk = 0, def = 0, crit = 0, dodge = 0, hpreg = 0, mpreg = 0, res = 0, dr = 0, spd = 0, goldUp = 0, lifeEl = 0,
                acc = 0, healUp = 0, ccDmg = 0, despair = 0, cheatDeath = 0, seal = 0, veil = 0; };

struct Fx {
  Sprite* sp = nullptr; double x = 0, y = 0, t = 0, z = 0, ox = 0, oy = 0, life = -1; int anim = 0, len = 0, follow = -1, uid = 0;   // follow: -2 oyuncu, ≥0 varlık
  std::string name;
  bool loop = false, done = false, proj = false, vis = false; int to = -1; double speed = 9; std::function<void()> cb;
};

struct DrawOpts { bool shadows = true, targetRing = true; };

// HTML hitMob seçenekleri: pure savunma tanımaz, tick sürekli hasar (tetikleyiciler yok)
struct HitOpt { double crit = 0, add = 0, slow = 0, freeze = 0, stun = 0, critDmg = 0; bool pure = false, bleed = false, burn = false, tick = false; std::function<void(Ent&)> onCrit; };

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
  void addItem(const std::string& id, int n = 1, bool quiet = false);   // quiet değilse günlüğe "Ad ×n"
  bool removeItem(const std::string& id, int n = 1);
  bool itemExists(const std::string& id) const;        // HTML ITEMS[id] (eşya tablosu + iksirler, Gelişim Paketi, görev eşyası)

  // beceriler (HTML useSkill, skRank, skC, skLock, skillAutoSpend, skillReset)
  const std::vector<SkillDef>& skills() const { return bal_.skills.cls(P.cls); }
  void useSkill(int i);
  int skRank(const SkillDef& sk) const;
  double skC(const SkillDef& sk, const std::string& key, int r = -1) const;
  int skRankSn(int sn) const;
  double skCSn(int sn, const std::string& key) const;
  int treePts(int treeId) const;
  std::string skLock(const SkillDef& sk) const;   // boş: öğrenilebilir; değilse tür: adv, pts, excl, pre
  bool skillUp(const SkillDef& sk);
  void skillAutoSpend(int points, int spec = 0);  // puanları oyuncu gibi dağıt (GM "ağaçları doldur")
  bool skillReset(bool free);
  void clampVitals();
  int healPlayer(double h, const std::string& fx = "");
  bool god = false, gmNoCd = false, fast = false, gmFreeTravel = false;   // GM: ölümsüzlük, beklemesiz + manasız beceri, hızlı koşu, ücretsiz yolculuk

  // yol bulma ve yürüme (HTML findPath, walkToEnt, talkTo, routeTo/routeStep, questWalk; world_nav.cpp)
  bool findPath(double sx, double sy, double tx, double ty, std::vector<std::pair<int, int>>& out, int maxIter = 5000) const;   // false: yol yok (HTML null)
  bool findPathTo(double tx, double ty);           // oyuncu için: yol varsa yürü (path), yoksa false
  void walkToEnt(int ent);                         // kişiye yürü, varınca konuş
  void talkTo(int ent);                            // yakınsa konuş, uzaksa yürü
  void routeTo(const std::string& sid);            // haritalar arası: geçitlerden (gerekirse yolculuk kişisiyle) hedef haritaya
  void routeStep();
  void routeToNpc(const std::string& cn);
  void questWalk(int qi);                          // görev "Yol Bul"
  std::vector<std::string> scenePath(const std::string& from, const std::string& to, bool tv = false) const;
  std::vector<std::string> routePath(const std::string& from, const std::string& to) const { auto p = scenePath(from, to); return p.empty() ? scenePath(from, to, true) : p; }
  std::string npcSceneNear(const std::string& cn) const;
  std::string monSceneNear(const std::string& name, const std::string& scName) const;
  int goTarget = -1, routeQuest = 0; std::string route, routeNpc, travelHint; double routeT = -1, routeDelay = 0.4;   // routeT: varışta yola devam (HTML setTimeout 400; testte 0)
  // yolculuk (arabacı, ışınlayıcı)
  const std::vector<TravelOpt>* travelOf(int ent) const;
  int travelCost(int ent, const TravelOpt& x) const;
  std::string travelLabel(int ent, const TravelOpt& x) const;
  bool travelGo(int ent, const TravelOpt& x);
  void revive();                                   // ölünce: can/mananın yarısıyla evde (ya da haritanın girişinde) doğ
  // arayüze istekler: konuşma penceresi (kişi; say doluysa yalnız söz), ölüm penceresi
  int dialogEnt = -1; std::string dialogSay; bool died = false;

  // görevler (HTML game.js › Görevler; world_quests.cpp). qi: görev listesindeki sıra (Quests::all)
  Quests& quests() { return bal_.quests; }
  std::string questState(int qi);                 // done, ready, active, locked, soon, new
  void acceptQuest(int qi);
  bool completeQuest(int qi);                     // teslim görevinde eşya eksikse false
  void questKill(const std::string& name);
  void questFlag(const std::string& f);           // özel görevlerin bayrağı (çantayı aç, hedef değiştir, yumurta çıkar)
  bool questUseItem(const std::string& id);       // görev eşyasını hedefteki canavara kullan
  void classUp(int n);
  void autoQuests();
  std::vector<int> questsFor(const std::string& cn);   // kişinin konuşmasındaki görevler (HTML questsFor)
  char npcMark(const std::string& cn);                 // başındaki işaret: '?' teslim, '!' yeni, 0 yok
  int tpQuestOf(const std::string& cn);                // ışınlanma görevi (kişi oraya yeniden ışınlar)
  void questTeleport(int qi);
  void interact(int ent);                              // kişiye dokun (HTML interact): toplama, konuşma görevleri; arayüz konuşmayı açar
  void dialogAccept(int qi, const std::string& cn);    // konuşmada "Kabul" (HTML win.js)
  bool dialogComplete(int qi);                         // konuşmada "Tamamla"
  void cycleTarget();                                  // sıradaki yakın canavarı hedef al
  int giveCount(const Quest& q) const;
  void gmQuestReady(int id);                           // GM: görevi (öncekileriyle) tamamlanmış say
  void gmQuestDone(int id);                            // GM: görevi bitir, ödülünü al
  std::set<std::string> flags;                         // HTML Game.flags (kayda girmez)
  // arayüz olayları (HTML UI.log / toast / float / zone / levelUp / hurt): dünya yazar, arayüz (ui/hud.cpp) çizer ve süreleri işler
  struct LogLine { std::string m; uint32_t c; };
  static const uint32_t LOG = 0xe8e0d0, LOG_Q = 0xffd23a, LOG_LOOT = 0xe8e0c8;
  std::vector<LogLine> log;                            // olay günlüğü (son 200)
  size_t logTotal = 0;                                 // bugüne dek yazılan olay sayısı (yeni olanları bulmak için)
  void note(const std::string& s, uint32_t c = LOG) { log.push_back({s, c}); logTotal++; if (log.size() > 200) log.erase(log.begin()); }
  struct FloatText { int ent; std::string txt; uint32_t c; float s, t; };   // ent: -2 oyuncu
  std::vector<FloatText> floats;                       // uçan sayılar (hasar, şifa, deneyim)
  void ufloat(int ent, const std::string& txt, uint32_t c, float s = 1) { floats.push_back({ent, txt, c, s, 0}); }
  std::string toastMsg, zoneMsg; float toastT = 0, zoneT = 0, lvlT = 0, hurtT = 0; int lvlN = 0;
  void toast(const std::string& m) { toastMsg = m; toastT = 2.5f; }
  std::string itemName(const std::string& id) const;
  void useItem(const std::string& id);
  const Balance& balance() const { return bal_; }
  Assets& assets() { return as_; }

  struct Phantom { bool on = false; double t = 0, tick = 0, mult = 0; int tg = -1, fx = 0; } phantom;   // Büyü Hayali (90140)

  std::string sceneId, sceneName;
  GameMap map;
  std::vector<Ent> ents;
  std::vector<Fx> fx;
  Player player;
  CharData P;
  double time = 0, camX = 0, camY = 0, arriveT = 0;
  int sceneGen = 0;   // her sahne yüklemesinde artar (arayüz önbellekleri: küçük harita)

 private:
  Assets& as_;
  Balance& bal_;
  const core::Json* scene_ = nullptr;
  std::vector<uint8_t> extraBlock_;
  struct Timer { double t; std::function<void()> fn; };
  std::vector<Timer> timers_;
  int lastJoyDir_ = -1, target_ = -1, fxUid_ = 0;
  bool goPending_ = false; std::string goSid_, goFrom_;   // geçitten geçiş (kare sonunda)
  bool engage_ = false;

  bool blocked(double fx, double fy) const;
  void later(double s, std::function<void()> fn) { timers_.push_back({s, std::move(fn)}); }
  template <class E> void moveEnt(E& e, double dx, double dy);
  template <class E> bool stepTo(E& e, double tx, double ty, double sp, double dt);
  void spawnMob(const std::string& name, int x, int y);
  int pushFx(const std::string& name, double x, double y, int dir = -1, bool glow = true);
  Fx* fxByUid(int uid) { for (Fx& f : fx) if (f.uid == uid) return &f; return nullptr; }
  void shoot(const std::string& name, double fx, double fy, int to, std::function<void()> cb, bool vis);
  void fxBurst(const std::string& name, double x, double y, int n, double r, int dir = -1, double delay = 0);
  void totemAt(const std::string& name, double x, double y, double life);
  int phantomFx();
  void auraSync(int follow, Aura& A, const std::vector<std::pair<std::string, std::string>>& want);
  void applyCorrosion(Ent& m);
  struct Dmg { int d; bool crit; };
  Dmg dmgCalc(double atk, double def, double mult, double critB = 0, double add = 0);
  int hitMob(int i, double mult, const HitOpt& o = HitOpt());
  void killMob(int i);
  void hurtPlayer(int i);
  void gainXp(long long n);
  void pickupNode(int ent);
  void readyQuest(int qi);
  bool tgAdd(int qi, QuestSt& st, const QTarget& x);
  void takeGive(const Quest& q);
  std::string randomGear(int lv);
  void checkExits();
  void drawMob(Canvas& c, Ent& e, int X, int Y);
  void drawPlayer(Canvas& c, int X, int Y);
};

int dirOf(double dx, double dy);
int fxAnim(const Sprite& sp, int dir);

}  // namespace engine
