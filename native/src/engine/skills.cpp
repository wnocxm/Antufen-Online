#include "skills.h"

#include <cmath>

#include "engine/rng.h"
#include "engine/world.h"

namespace engine {

double SkCtx::K(const char* key) const { return w.skC(sk, key); }
int SkCtx::rank(int sn) const { return w.skRankSn(sn); }
double SkCtx::C(int sn, const char* key) const { return w.skCSn(sn, key); }

static double R100(double v) { return v / 100; }

// Tanımlar HTML game.js CLS[...].skills ile aynı sırada (kısayol numarası = sıradaki yeri): önce acemi + sınıf ağaçlarının etkinleri,
// sonra edilgenleri, sonra iki uzmanlık. Değiştirirken HTML'yi de değiştir; tools/test/cpp_savas.js iki sürümü karşılaştırır.
static SkillDef& add(std::vector<SkillDef>& L, const char* id, int sn) { L.emplace_back(); SkillDef& d = L.back(); d.id = id; d.sn = sn; return d; }
static Vals none(SkCtx&) { return {}; }

static void warrior(std::vector<SkillDef>& L) {
  // acemi (见习 150008) ve sınıf (战士 150009) ağaçları
  { auto& k = add(L, "w1", 90020); k.cd = 0.8; k.range = 1.6; k.fx = "BLOOD"; k.snd = "skill_sword";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1; F.add = c.K("add_phy"); return F; }; }
  { auto& k = add(L, "w2", 90095); k.mp = 25; k.cd = 1.0; k.range = 1.6; k.self = "特效-刀光-红"; k.hit = "BLOOD"; k.hitN = 2; k.hitR = 5; k.snd = "skill_daoguang";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1; F.add = c.K("add_phy"); F.crit = c.K("add_fatal"); return F; }; }
  { auto& k = add(L, "w3", 90021); k.mp = 35; k.cd = 1.5; k.range = 6; k.proj = "特效-飞刀"; k.hit = "特效-细碎爆炸"; k.splash = 1.8; k.snd = "skill_nife"; k.snd2 = "skill_pilipala";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("phy_basic")); F.add = c.K("add_phy"); F.taunt = 1; return F; }; }
  { auto& k = add(L, "w4", 90044); k.mp = 45; k.cd = 5; k.hits = 2; k.range = 1.6; k.self = "特效-刀光"; k.hit = "特效-大喷血"; k.fx2 = "BLOOD"; k.snd = "skill_daoguang";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1 + R100(c.K("add_phy_rate")); F.mult2 = R100(c.K("add_holy_rate")); F.hasMult2 = true; return F; }; }
  { auto& k = add(L, "w5", 90084); k.mp = 30; k.cd = 20; k.dur = 5; k.self = "特性-聚气"; k.bfx = "特效-加速"; k.snd = "skill_juqi";
    k.buff = [](SkCtx& c) { return Vals{{"spd", 0.25}, {"nextCrit", c.K("next_attack_is_fatal_rate")}, {"noSlow", 1}}; }; }
  { auto& k = add(L, "w6", 90105); k.mp = 60; k.cd = 15; k.range = 5; k.self = "特效-刀光"; k.hit = "特效-死亡标记"; k.snd = "skill_deathtag";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("add_phy_rate")); F.crit = c.K("add_fatal"); return F; }; }
  add(L, "wp1", 90022).pas = [](SkCtx& c) { return Vals{{"atk", c.K("add_phy")}}; };
  add(L, "wp2", 90042).pas = [](SkCtx& c) { return Vals{{"hpPct", c.K("add_hp_max_rate")}}; };
  add(L, "wp3", 90043).pas = [](SkCtx& c) { return Vals{{"dodge", c.K("add_raw_jook_rate")}}; };
  add(L, "wp4", 90040).pas = [](SkCtx& c) { return Vals{{"def", c.K("add_def")}, {"res", c.K("add_def")}}; };
  add(L, "wp5", 90096).pas = [](SkCtx& c) { return Vals{{"hpreg", c.K("hp_grow")}}; };
  add(L, "wp6", 90104).pas = [](SkCtx& c) { return Vals{{"dr", c.K("add_sorbdamage_rate")}}; };
  // uzmanlık: Kana Susamış (嗜血 150010)
  { auto& k = add(L, "90106", 90106); k.mp = 300; k.cd = 15; k.dur = 10; k.self = "特性-聚气"; k.bfx = "特效-鲜血印记"; k.snd = "skill_juqi";
    k.buff = [](SkCtx& c) { return Vals{{"leech", R100(c.K("add_hp_rate"))}}; }; }
  { auto& k = add(L, "90113", 90113); k.mp = 150; k.cd = 2; k.range = 1.6; k.self = "特效-刀光-红"; k.selfN = 5; k.selfR = 5; k.hit = "RELIVE"; k.snd = "skill_daoguang"; k.snd2 = "skill_relive";
    k.f = [](SkCtx& c) { SkF F; F.mult = 0; F.add = c.w.player.hp * R100(c.K("dec_hp_rate")) * (c.rank(90115) ? 1.05 : 1); F.pure = true; F.refresh = "90106"; return F; }; }
  { auto& k = add(L, "90598", 90598); k.mp = 200; k.cd = 10; k.dur = 6; k.self = "特性-聚气"; k.bfx = "特效-反击风暴"; k.snd = "skill_juqi";
    k.buff = [](SkCtx&) { return Vals{{"reflect", 0.1}}; }; }
  add(L, "90107", 90107).pas = [](SkCtx& c) { return Vals{{"healUp", c.K("add_resume_effect_rate")}}; };
  add(L, "90119", 90119).pas = [](SkCtx& c) { return Vals{{"defToAtk", c.K("add_physical_attack_value")}}; };
  add(L, "90115", 90115).pas = none;
  // uzmanlık: Öfke (狂暴 150011)
  { auto& k = add(L, "90117", 90117); k.mp = 120; k.cd = 1.5; k.range = 1.6; k.self = "特效-刀光-红"; k.selfN = 3; k.selfR = 5; k.hit = "BLOOD"; k.hitN = 5; k.hitR = 5; k.snd = "skill_daoguang"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("phy_attack_factor")); F.add = c.K("add_phy_attack_value"); F.bleed = true; return F; }; }
  // Ağır Yarık (90116): Ölüm Kırımı (90120) can kaybıyla güçlendirir; kanamayı yutup kat başına ek hasar (HTML tearHit)
  { auto& k = add(L, "90116", 90116); k.mp = 200; k.cd = 4; k.range = 5; k.hit = "特效-狂暴BUFF"; k.snd = "skill_deathtag";
    k.f = [](SkCtx& c) {
      double mult = R100(c.K("phy_attack_factor"));
      if (c.rank(90120)) mult *= 1 + R100(c.C(90120, "add_tisi_damage_rate")) * std::floor((1 - c.w.player.hp / c.s.hp) * 10);
      if (c.t && c.t->bleed.on) { mult += 0.25 * c.t->bleed.n; if (!(c.rank(90120) && random() * 100 < c.C(90120, "not_del_bloodshed_buff_rate"))) c.t->bleed.on = false; }
      SkF F; F.mult = mult; F.add = c.K("add_phy_attack_value"); return F; }; }
  { auto& k = add(L, "90599", 90599); k.mp = 150; k.cd = 10; k.dur = 6; k.self = "特性-聚气"; k.bfx = "特效-狂暴之怒"; k.snd = "skill_juqi";
    k.buff = [](SkCtx&) { return Vals{{"atk", 0.05}, {"def", -0.05}, {"noSlow", 1}}; }; }
  add(L, "90118", 90118).pas = [](SkCtx& c) { return Vals{{"despair", c.K("trigger_effect_rate")}}; };
  add(L, "90121", 90121).pas = [](SkCtx& c) { return Vals{{"atkToDef", c.K("add_physical_defence_and_resist_value")}}; };
  add(L, "90120", 90120).pas = none;
}

static void mage(std::vector<SkillDef>& L) {
  // acemi (学徒 150014) ve sınıf (法师 150015) ağaçları
  { auto& k = add(L, "m1", 90122); k.mp = 20; k.cd = 1.2; k.range = 7; k.proj = "特效-火球"; k.hit = "特效-火爆炸"; k.snd = "skill_fireball"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1; F.add = c.K("add_fire"); return F; }; }
  { auto& k = add(L, "m2", 90123); k.mp = 30; k.cd = 0.9; k.range = 7; k.proj = "特效-冰球"; k.hit = "WATER_ATTACK"; k.slow = 2; k.snd = "skill_wind"; k.snd2 = "skill_bubble";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1; F.add = c.K("add_water"); F.crit = c.K("add_fatal"); return F; }; }
  { auto& k = add(L, "m3", 90126); k.mp = 60; k.cd = 20; k.fx = "LIGHT_ATTACK"; k.snd = "skill_light";
    k.heal = [](SkCtx& c) { return c.K("add_hp"); }; }
  { auto& k = add(L, "m4", 90127); k.mp = 70; k.cd = 8; k.range = 3; k.proj = "FIRE_ATTACK"; k.projN = 3; k.hit = "特效-火爆炸"; k.hitN = 3; k.hitR = 2; k.snd = "skill_fireball2"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1 + R100(c.K("add_fire_rate")); F.add = c.K("add_fire_val"); return F; }; }
  { auto& k = add(L, "m5", 90129); k.mp = 80; k.cd = 30; k.dur = 10; k.bfx = "特效-弱化术"; k.snd = "skill_juqi";
    k.buff = [](SkCtx& c) { return Vals{{"manaShield", R100(c.K("work_rate"))}, {"mpPerDmg", c.K("mp_trans_hp")}}; }; }
  { auto& k = add(L, "m6", 90128); k.mp = 90; k.cd = 12; k.range = 7; k.proj = "特效-冰球"; k.hit = "特效-冰块碎裂"; k.hitN = 10; k.hitR = 50; k.splash = 2.6; k.slow = 2; k.snd = "skill_wind"; k.snd2 = "skill_ice";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("basic_attack_rate")); F.add = c.K("add_water"); return F; }; }
  add(L, "mp1", 90124).pas = [](SkCtx& c) { return Vals{{"atk", c.K("add_mag")}}; };
  add(L, "mp2", 90125).pas = [](SkCtx& c) { return Vals{{"mpPct", c.K("add_mp_max_rate")}}; };
  add(L, "mp3", 90097).pas = [](SkCtx& c) { return Vals{{"acc", c.K("add_raw_shoot_rate")}}; };
  add(L, "mp4", 90130).pas = [](SkCtx& c) { return Vals{{"res", c.K("add_resist")}}; };
  add(L, "mp5", 90098).pas = [](SkCtx& c) { return Vals{{"mpreg", c.K("mp_grow")}}; };
  { auto& k = add(L, "mp6", 90131); k.mp = 60; k.cd = 1; k.snd = "skill_light";   // orijinalde etkin (eskiden edilgendi)
    k.durF = [](SkCtx& c) { return c.K("buff_duration") * 60; };
    k.buff = [](SkCtx& c) { return Vals{{"mpAdd", c.K("add_mp_max")}}; }; }
  // uzmanlık: Element (元素 150016)
  { auto& k = add(L, "90132", 90132); k.mp = 300; k.cd = 4; k.range = 7; k.proj = "FIRE_ATTACK2"; k.projN = 3; k.hit = "FIRE_ATTACK2"; k.hitN = 10; k.hitR = 30; k.splash = 2.2; k.snd = "skill_fireball2"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("fire_attack_factor")); F.add = c.K("add_fire_attack_value"); F.burn = true; return F; }; }
  { auto& k = add(L, "90134", 90134); k.mp = 300; k.cd = 4; k.aoe = 3; k.fx = "特效-冰霜新星"; k.snd = "skill_ice";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("ice_attack_factor")) * (c.rank(90135) ? 1.02 : 1); F.add = c.K("add_ice_attack_value"); F.slow = 2; F.freeze = c.rank(90135) ? 10 : 0; return F; }; }
  { auto& k = add(L, "90136", 90136); k.mp = 0; k.cd = 15; k.dur = 6; k.self = "特性-聚气"; k.bfx = "特效-元素赐生"; k.snd = "skill_light";
    k.buff = [](SkCtx& c) { const bool r = c.rank(90600); return Vals{{"mpTick", R100(c.K("add_mp_rate")) / 2}, {"dmgOut", r ? R100(c.C(90600, "magic_attack_dec_to_rate")) : 0.5}, {"atk", r ? 0.05 : 0}, {"hpTick", r ? 1 : 0}}; }; }
  add(L, "90133", 90133).pas = [](SkCtx& c) { return Vals{{"ccDmg", c.K("add_damage_rate")}}; };
  add(L, "90135", 90135).pas = none;
  add(L, "90600", 90600).pas = none;
  // uzmanlık: Gizem (奥术 150017)
  { auto& k = add(L, "90137", 90137); k.mp = 0; k.cd = 1.5; k.range = 7; k.proj = "特效-黑暗火球"; k.hit = "特效-火爆炸"; k.snd = "skill_wind"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx&) { SkF F; F.mult = 1.2; F.arcane = true; return F; };
    k.mpPct = [](SkCtx& c) { return R100(c.K("count_up_dec_mp_rate")); }; }
  { auto& k = add(L, "90140", 90140); k.mp = 250; k.cd = 7.5; k.range = 7; k.snd = "skill_wind";
    k.f = [](SkCtx& c) { SkF F; F.phantom = R100(c.K("copy_factor")); F.life = 5 + (c.rank(90138) ? c.C(90138, "extra_lifetime") : 0); return F; }; }
  { auto& k = add(L, "90139", 90139); k.mp = 200; k.cd = 15; k.dur = 6; k.self = "特性-聚气"; k.bfx = "特效-神圣之盾"; k.snd = "skill_juqi";
    k.buff = [](SkCtx& c) { Vals v{{"dodge", c.K("add_jook_rate")}}; if (c.rank(90601) && random() < 0.1) { v.set("spd", 0.3); v.set("noSlow", 1); } return v; }; }
  add(L, "90141", 90141).pas = [](SkCtx& c) { return Vals{{"mpToAtk", c.K("add_magic_attack_value")}}; };
  add(L, "90138", 90138).pas = none;
  add(L, "90601", 90601).pas = none;
}

static void priest(std::vector<SkillDef>& L) {
  // acemi (初级 150022) ve sınıf (神使 150023) ağaçları
  { auto& k = add(L, "p1", 90312); k.mp = 18; k.cd = 1.0; k.range = 7; k.proj = "特效-暗影冲击_红"; k.hit = "特效-冲击爆炸"; k.snd = "skill_wind"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx& c) { SkF F; F.mult = 1 + (c.t && c.t->dot.on && c.t->dot.corr ? R100(c.C(90314, "arrow_buff")) : 0); F.add = c.K("add_dark"); return F; }; }
  { auto& k = add(L, "p2", 90314); k.mp = 30; k.cd = 1; k.range = 7; k.fx = "特效-死亡标记"; k.snd = "skill_deathtag";
    k.f = [](SkCtx&) { SkF F; F.mult = 0; F.corrode = true; return F; }; }
  { auto& k = add(L, "p3", 90317); k.mp = 50; k.cd = 15; k.aoe = 3; k.totem = "特效-神之威慑"; k.snd = "skill_juqi";
    k.f = [](SkCtx& c) { SkF F; F.mult = 0; F.weakDef = c.s.atk * R100(c.K("def_reduce_rate")); F.weakT = 10; return F; }; }
  { auto& k = add(L, "p4", 90319); k.mp = 60; k.cd = 15; k.dur = 10; k.totem = "特效-治疗之泉"; k.snd = "skill_light";
    k.buff = [](SkCtx& c) { return Vals{{"hotT", c.s.atk * 0.1 + c.K("hp_resume")}}; }; }
  // Gölge Yakışı (90318): İlahi Ceza (90323) çürümüş hedefe kritik şansı ve hasarı artırır, kritik çürümeyi yutar (HTML burnHit)
  { auto& k = add(L, "p5", 90318); k.mp = 45; k.cd = 6; k.range = 7; k.hit = "特效-暗影灼烧_红"; k.snd = "skill_fire2"; k.snd2 = "skill_bomb";
    k.f = [](SkCtx& c) {
      SkF F; F.mult = 1; F.add = c.K("add_dark");
      if (c.t && c.t->dot.on && c.t->dot.corr && c.rank(90323)) { F.crit = c.C(90323, "fatal_rate"); F.critDmg = c.C(90323, "fatal_damage"); F.onCrit = [](Ent& m) { if (m.dot.on && m.dot.corr) m.dot.on = false; }; }
      return F; }; }
  { auto& k = add(L, "p6", 90321); k.mp = 70; k.cd = 3; k.self = "特效-缓缓加红"; k.selfN = 40; k.selfR = 180; k.snd = "skill_light";
    k.heal = [](SkCtx& c) { return c.s.atk + c.K("heal_hp"); }; }
  { auto& k = add(L, "p7", 90322); k.mp = 90; k.cd = 40; k.self = "特效-狂暴BUFF"; k.selfN = 40; k.selfR = 180; k.bfx = "特效-神努buff"; k.snd = "skill_relive";
    k.durF = [](SkCtx& c) { return c.K("buff_duration"); };
    k.buff = [](SkCtx& c) { return Vals{{"atkAdd", c.s.atk * R100(c.K("add_attack_rate"))}, {"defAdd", c.s.atk * R100(c.K("add_defence_rate"))}}; }; }
  add(L, "pp1", 90313).pas = [](SkCtx& c) { return Vals{{"atk", c.K("add_magic_attack")}}; };
  add(L, "pp2", 90315).pas = [](SkCtx& c) { return Vals{{"crit", c.K("add_cruel_rate")}}; };
  add(L, "pp3", 90316).pas = none;
  add(L, "pp4", 90320).pas = none;   // stats() can/mana sınırı bilindikten sonra ekler
  add(L, "pp5", 90323).pas = none;
  // uzmanlık: Kutsal (神圣 150024)
  { auto& k = add(L, "90602", 90602); k.mp = 100; k.cd = 1; k.dur = 60; k.self = "特性-聚气"; k.snd = "skill_juqi"; k.toggle = true;
    k.buff = [](SkCtx& c) { return Vals{{"convert", c.K("convert_factor")}}; }; }
  { auto& k = add(L, "90604", 90604); k.mp = 300; k.cd = 5; k.aoe = 3; k.self = "特效-细碎爆炸"; k.selfN = 5; k.selfR = 80; k.snd = "skill_light";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("holy_damage_factor")); F.add = c.K("add_holy_damage_value"); F.novaHeal = true; F.stun = c.rank(90605) ? 10 : 0; return F; }; }
  { auto& k = add(L, "90606", 90606); k.mp = 200; k.cd = 20; k.dur = 3; k.bfx = "特效-圣光壁垒"; k.snd = "skill_relive";
    k.buff = [](SkCtx& c) { return Vals{{"dr", c.K("add_sorbdamage_rate")}}; }; }
  add(L, "90603", 90603).pas = [](SkCtx& c) { return Vals{{"cheatDeath", c.K("trigger_effect_rate")}}; };
  add(L, "90605", 90605).pas = none;
  add(L, "90607", 90607).pas = none;
  // uzmanlık: Gölge (暗影 150025)
  { auto& k = add(L, "90608", 90608); k.mp = 250; k.cd = 4; k.range = 7; k.proj = "特效-暗影冲击_红"; k.hit = "特性-冰火爆炸"; k.snd = "skill_wind"; k.snd2 = "skill_deathtag";
    k.f = [](SkCtx& c) { SkF F; F.mult = R100(c.K("dark_damage_factor")); F.add = c.K("add_dark_damage_value"); F.corrode = true; return F; }; }
  { auto& k = add(L, "90610", 90610); k.mp = 0; k.cd = 10; k.dur = 6; k.self = "特性-聚气"; k.bfx = "特效-黑暗契约"; k.snd = "skill_deathtag";
    k.buff = [](SkCtx& c) { return Vals{{"mp2hp", R100(c.K("dec_mp_rate"))}}; }; }
  { auto& k = add(L, "90613", 90613); k.mp = 300; k.cd = 20; k.dur = 6; k.self = "特效-治疗buff"; k.bfx = "特效-缓缓加红"; k.snd = "skill_relive";
    k.buff = [](SkCtx&) { return Vals{{"atk", 0.3}, {"drain", 0.01}, {"noHeal", 1}}; }; }
  add(L, "90609", 90609).pas = [](SkCtx& c) { return Vals{{"seal", c.K("trigger_effect_rate")}}; };
  add(L, "90612", 90612).pas = [](SkCtx& c) { return Vals{{"veil", c.K("trigger_effect_rate")}}; };
  add(L, "90611", 90611).pas = none;
}

// ırk becerileri (人类 150019 / 精灵 150013): kademe 1, kendiliğinden; artış seviyeyle (bizim)
static void races(std::map<std::string, std::vector<SkillDef>>& R) {
  auto& h = R["人类"];
  add(h, "r90082", 90082).pas = [](SkCtx& c) { return Vals{{"def", 2.0 * c.L}, {"mp", 5.0 * c.L}}; };
  add(h, "r90083", 90083).pas = [](SkCtx&) { return Vals{{"goldUp", 10}}; };
  auto& e = R["精灵"];
  add(e, "r90080", 90080).pas = [](SkCtx& c) { return Vals{{"res", 2.0 * c.L}, {"hp", 8.0 * c.L}}; };
  add(e, "r90081", 90081).pas = [](SkCtx&) { return Vals{{"lifeEl", 5}}; };
}

void Skills::load(const Vfs& vfs) {
  J_ = core::Json::parse(vfs.readText("skills.json"));
  cls_.clear(); race_.clear(); trees_.clear(); bySn_.clear();
  warrior(cls_["战士"]); mage(cls_["法师"]); priest(cls_["牧师"]); races(race_);
  const core::Json& S = J_["skills"];
  auto fill = [&](SkillDef& k, int mx) {
    k.d = &S[std::to_string(k.sn)];
    if (!k.d->isObj()) throw std::runtime_error("skills.json: beceri yok: " + std::to_string(k.sn));
    k.name = (*k.d)["tr"][0].str(); k.nameEn = (*k.d)["en"][0].str(); k.mx = mx ? mx : (*k.d)["mx"].i(10);
    bySn_[k.sn] = &k;
  };
  for (auto& c : cls_) for (SkillDef& k : c.second) { k.cls = c.first; fill(k, 0); }
  for (auto& r : race_) for (SkillDef& k : r.second) { k.race = r.first; fill(k, 1); }
  for (auto& c : cls_) {
    for (const core::Json& t : J_["trees"][c.first].arr()) {
      SkillTree T; T.id = t["id"].i(); T.name = t["tr"].str();
      for (const core::Json& cell : t["cells"].arr()) {
        auto it = bySn_.find(cell[0].i()); if (it == bySn_.end()) throw std::runtime_error("skills.json: ağaçta tanımsız beceri " + std::to_string(cell[0].i()));
        T.cells.push_back({it->second, cell[1].i()});
      }
      trees_[c.first].push_back(std::move(T));
    }
  }
}

const SkillTree* Skills::tree(int id) const {
  for (const auto& c : trees_) for (const SkillTree& t : c.second) if (t.id == id) return &t;
  return nullptr;
}

}  // namespace engine
