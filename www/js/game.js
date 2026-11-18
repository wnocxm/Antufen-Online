// Anrufen Online — oyun çekirdeği (orijinal varlıklar üzerinde)
'use strict';

const SAVE_KEY = 'anrufen_save_v1';
const rnd = (a, b) => a + Math.random() * (b - a);
const irnd = (a, b) => Math.floor(rnd(a, b + 1));
const pick = a => a[Math.floor(Math.random() * a.length)];
const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
// Animasyon zamanlaması: orijinal karelerin süresi "tik" cinsinden. Saniyede ~14 tik.
const TICK = 14;
// Koşu döngüsü (8 kare = 2 adım) yerde yaklaşık 48 piksel ilerler; adımlar yürünen mesafeye bağlanır (ayak kayması olmaz)
const STRIDE = 66, CELL_PX = 30, RUN = 4.2;

// Yön: 0 sağ-yukarı (-y), 1 sağ-aşağı (+x), 2 sol-aşağı (+y), 3 sol-yukarı (-x)
// Karakter görselleri 4 çapraz yönde; ekranda düz sağ/sol/yukarı/aşağı giderken en yakın çapraz kullanılır.
function dirOf(dx, dy) {
  const ax = Math.abs(dx), ay = Math.abs(dy);
  if (ax > 0 && ay > 0 && Math.abs(ax - ay) < 0.2 * Math.max(ax, ay)) {
    if (dx > 0 && dy < 0) return 1;   // ekranda sağa
    if (dx < 0 && dy > 0) return 3;   // ekranda sola
    return dy > 0 ? 2 : 0;            // ekranda aşağı / yukarı
  }
  if (ax > ay) return dx > 0 ? 1 : 3;
  return dy > 0 ? 2 : 0;
}
// Orijinaldeki gibi yalnızca 4 yön: sağ-aşağı (+x), sol-aşağı (+y), sol-yukarı (-x), sağ-yukarı (-y)
const DIR4 = [[1, 0], [0, 1], [-1, 0], [0, -1]];
let lastJoyDir = -1;
function snapScreen4(sx, sy) {
  // yönlerin ekrandaki açıları: 27.6°, 152.4°, 207.6°, 332.4° (karo kenarları); en yakınını seç, sınırda titremesin diye son yöne küçük öncelik ver
  const ang = Math.atan2(sy, sx); let best = 0, bd = 9;
  for (let i = 0; i < 4; i++) { const a = Math.atan2(DIR4[i][0] * HH + DIR4[i][1] * HH, DIR4[i][0] * HW - DIR4[i][1] * HW); let d = Math.abs(Math.atan2(Math.sin(ang - a), Math.cos(ang - a))); if (i === lastJoyDir) d -= 0.25; if (d < bd) { bd = d; best = i; } }
  lastJoyDir = best; return DIR4[best];
}
// ekran vektöründen (sx, sy) kare vektörüne
function screenToCellVec(sx, sy) { const a = sx / HW, b = sy / HH; return { x: (a + b) / 2, y: (b - a) / 2 }; }

// Canavar değerleri (orijinal istemcide yok, sunucudaydı; bölge seviyelerine göre)
const MON = {
  '鸭子': { lv: 1, hp: 30, atk: 3, xp: 8, passive: true, n: 6 },
  '鸡': { lv: 2, hp: 40, atk: 4, xp: 10, passive: true, n: 8 },
  '神殿骑士': { dummy: true }, '魔法骷髅': { dummy: true }, '恶魔傀儡': { dummy: true },
  '蠕虫': { lv: 1, hp: 30, atk: 3, xp: 8, passive: true, n: 6 }, '食腐豺': { lv: 2, hp: 45, atk: 5, xp: 11, passive: true, n: 8, wide: 7 },
  '掠食秃鹫': { lv: 4, hp: 95, atk: 10, xp: 26, n: 8, wide: 8 }, '☆带刺野猪': { lv: 6, hp: 700, atk: 20, xp: 220, rank: 1, n: 2 }, '工会剑士': { dummy: true },
  '契约爱神': { skip: true },
  '饥饿织网者': { lv: 4, xp: 26, n: 9, wide: 9 }, '蝎子': { lv: 5, xp: 30, n: 9, wide: 9 }, '蛇': { lv: 7, xp: 38, n: 9, wide: 9 }, '史莱姆': { lv: 6, xp: 34, n: 9, wide: 9 },
  '饥饿的食腐豺': { lv: 8, xp: 42, n: 9, wide: 9 }, '狼': { lv: 10, xp: 50, n: 12, wide: 10 }, '精灵战士': { lv: 12, xp: 60, n: 8, wide: 9 }, '路匪': { lv: 11, xp: 55, n: 8, wide: 9 },
  '毒蛇帮路匪': { lv: 5, hp: 120, atk: 12, xp: 30, n: 6 },
  '野猪': { lv: 3, hp: 80, atk: 8, xp: 20, n: 10, wide: 9 },
  '☆【帝国叛徒】迪萨安': { lv: 7, hp: 900, atk: 24, xp: 300, rank: 1, n: 1 },
  '蜘蛛': { lv: 6, hp: 140, atk: 14, xp: 34, n: 9, wide: 8 },
  '蜘蛛掠夺者': { lv: 7, hp: 170, atk: 16, xp: 40, n: 6 },
  '森林狼': { lv: 7, hp: 160, atk: 17, xp: 42, n: 8, wide: 8 },
  '☆森林狼头领': { lv: 9, hp: 1400, atk: 30, xp: 500, rank: 1, n: 1 },
  '森林蝰蛇': { lv: 8, hp: 180, atk: 19, xp: 46, n: 9, wide: 8 },
  '恶作剧仙子': { lv: 8, hp: 160, atk: 20, xp: 46, n: 9, wide: 8 },
  '毒蛇帮精英': { lv: 9, hp: 230, atk: 22, xp: 55, n: 6 },
  '蜂蜜仙子': { lv: 10, hp: 240, atk: 24, xp: 60, n: 9, wide: 8 },
  '☆毒蛇帮虐杀者': { lv: 11, hp: 600, atk: 30, xp: 150, rank: 1, n: 4 },
  '☆精英护卫': { lv: 11, hp: 700, atk: 30, xp: 160, rank: 1, n: 3 },
  '☆☆【叛徒】萨丁曼': { lv: 13, hp: 4000, atk: 45, xp: 1500, rank: 2, n: 1 },
  '森林巨魔': { lv: 13, hp: 420, atk: 34, xp: 90, n: 8, wide: 8 },
  '☆巨魔摧毁者': { lv: 15, hp: 2200, atk: 48, xp: 700, rank: 1, n: 1 },
  '☆饥饿的巨魔': { lv: 15, hp: 2200, atk: 48, xp: 700, rank: 1, n: 1 },
};

// Sınıf değerleri ve beceriler. Ağaçlar, adlar, simgeler, açıklamalar, en yüksek kademe, ön koşullar ve kademe sabitleri orijinal:
// www/assets/skills.json (tools/beceriler.py ← all_skilltree, all_skill, skill_const_2nd.lua). Burada her becerinin oyundaki karşılığı durur:
// `sn` orijinal numara; `f(K, s, p, t)` etkin becerinin o kademedeki sayıları (K('sabit') = kademe değeri), `pas(K, s)` edilgen,
// `buff(K, s)` + `dur` güçlendirme, `heal(K, s)` şifa. Efektler orijinal efekt tablosundan (APK efekt_beceriler + Symbian all_skill/all_buff;
// docs/03 › Beceri efektleri): `self` oyuncuda oynar (`selfN` kez, `selfR` px saçılma), `proj` hedefe uçar (`projN` tane), `hit` hedefte
// (`hitN`/`hitR`), `fx` eski tek efekt (şifa, alan), `bfx` güçlendirme süresince karakterde döner, `totem` yere konan çağrılmış nesne
// (Gözdağı Totemi, Şifa Pınarı). Etkin beceriler önce (kısayol sırası), edilgenler sonra; yeni ağaçların becerileri
// eskilerin arkasına eklendi (eski kayıtlardaki kısayol sırası bozulmasın). Sınıf taban değerleri (hp, atk… ve seviye artışları) bizim
// dengemiz (orijinal sunucudaydı; docs/03 › Denge).
const R100 = v => v / 100;
const CLS = {
  '战士': { hp: 1200, mp: 300, atk: 60, def: 40, ghp: 180, gmp: 30, gatk: 12, gdef: 8, dmgK: 1.25, range: 1.4, color: '红', melee: true, snd: 'skill_sword',
    skills: [
      // acemi (见习 150008) ve sınıf (战士 150009) ağaçları
      { id: 'w1', sn: 90020, mp: 0, cd: 0.8, range: 1.6, fx: 'BLOOD', snd: 'skill_sword', f: K => ({ mult: 1, add: K('add_phy') }) },
      { id: 'w2', sn: 90095, mp: 25, cd: 1.0, range: 1.6, self: '特效-刀光-红', hit: 'BLOOD', hitN: 2, hitR: 5, snd: 'skill_daoguang', f: K => ({ mult: 1, add: K('add_phy'), crit: K('add_fatal') }) },
      { id: 'w3', sn: 90021, mp: 35, cd: 1.5, range: 6, proj: '特效-飞刀', hit: '特效-细碎爆炸', splash: 1.8, snd: 'skill_nife', snd2: 'skill_pilipala', f: K => ({ mult: R100(K('phy_basic')), add: K('add_phy'), taunt: 1 }) },
      { id: 'w4', sn: 90044, mp: 45, cd: 5, hits: 2, range: 1.6, self: '特效-刀光', hit: '特效-大喷血', fx2: 'BLOOD', snd: 'skill_daoguang', f: K => ({ mult: 1 + R100(K('add_phy_rate')), mult2: R100(K('add_holy_rate')) }) },
      { id: 'w5', sn: 90084, mp: 30, cd: 20, dur: 5, self: '特性-聚气', bfx: '特效-加速', snd: 'skill_juqi', buff: K => ({ spd: 0.25, nextCrit: K('next_attack_is_fatal_rate'), noSlow: 1 }) },
      { id: 'w6', sn: 90105, mp: 60, cd: 15, range: 5, self: '特效-刀光', hit: '特效-死亡标记', snd: 'skill_deathtag', f: K => ({ mult: R100(K('add_phy_rate')), crit: K('add_fatal') }) },
      { id: 'wp1', sn: 90022, pas: K => ({ atk: K('add_phy') }) },
      { id: 'wp2', sn: 90042, pas: K => ({ hpPct: K('add_hp_max_rate') }) },
      { id: 'wp3', sn: 90043, pas: K => ({ dodge: K('add_raw_jook_rate') }) },
      { id: 'wp4', sn: 90040, pas: K => ({ def: K('add_def'), res: K('add_def') }) },
      { id: 'wp5', sn: 90096, pas: K => ({ hpreg: K('hp_grow') }) },
      { id: 'wp6', sn: 90104, pas: K => ({ dr: K('add_sorbdamage_rate') }) },
      // uzmanlık: Kana Susamış (嗜血 150010)
      { id: '90106', sn: 90106, mp: 300, cd: 15, dur: 10, self: '特性-聚气', bfx: '特效-鲜血印记', snd: 'skill_juqi', buff: K => ({ leech: R100(K('add_hp_rate')) }) },
      { id: '90113', sn: 90113, mp: 150, cd: 2, range: 1.6, self: '特效-刀光-红', selfN: 5, selfR: 5, hit: 'RELIVE', snd: 'skill_daoguang', snd2: 'skill_relive', f: (K, s, p) => ({ mult: 0, add: p.hp * R100(K('dec_hp_rate')) * (skRankSn(90115) ? 1.05 : 1), pure: 1, refresh: '90106' }) },
      { id: '90598', sn: 90598, mp: 200, cd: 10, dur: 6, self: '特性-聚气', bfx: '特效-反击风暴', snd: 'skill_juqi', buff: () => ({ reflect: 0.1 }) },
      { id: '90107', sn: 90107, pas: K => ({ healUp: K('add_resume_effect_rate') }) },
      { id: '90119', sn: 90119, pas: K => ({ defToAtk: K('add_physical_attack_value') }) },
      { id: '90115', sn: 90115, pas: () => ({}) },
      // uzmanlık: Öfke (狂暴 150011)
      { id: '90117', sn: 90117, mp: 120, cd: 1.5, range: 1.6, self: '特效-刀光-红', selfN: 3, selfR: 5, hit: 'BLOOD', hitN: 5, hitR: 5, snd: 'skill_daoguang', snd2: 'skill_bomb', f: K => ({ mult: R100(K('phy_attack_factor')), add: K('add_phy_attack_value'), bleed: 1 }) },
      { id: '90116', sn: 90116, mp: 200, cd: 4, range: 5, hit: '特效-狂暴BUFF', snd: 'skill_deathtag', f: (K, s, p, t) => tearHit(K, s, p, t) },
      { id: '90599', sn: 90599, mp: 150, cd: 10, dur: 6, self: '特性-聚气', bfx: '特效-狂暴之怒', snd: 'skill_juqi', buff: () => ({ atk: 0.05, def: -0.05, noSlow: 1 }) },
      { id: '90118', sn: 90118, pas: K => ({ despair: K('trigger_effect_rate') }) },
      { id: '90121', sn: 90121, pas: K => ({ atkToDef: K('add_physical_defence_and_resist_value') }) },
      { id: '90120', sn: 90120, pas: () => ({}) },
    ] },
  '法师': { hp: 1000, mp: 800, atk: 70, def: 20, ghp: 140, gmp: 90, gatk: 14, gdef: 5, dmgK: 1.7, range: 6, color: '蓝', bolt: '特效-火球', boltHit: '特效-火爆炸', snd: 'skill_fire2',
    skills: [
      // acemi (学徒 150014) ve sınıf (法师 150015) ağaçları
      { id: 'm1', sn: 90122, mp: 20, cd: 1.2, range: 7, proj: '特效-火球', hit: '特效-火爆炸', snd: 'skill_fireball', snd2: 'skill_bomb', f: K => ({ mult: 1, add: K('add_fire') }) },
      { id: 'm2', sn: 90123, mp: 30, cd: 0.9, range: 7, proj: '特效-冰球', hit: 'WATER_ATTACK', slow: 2, snd: 'skill_wind', snd2: 'skill_bubble', f: K => ({ mult: 1, add: K('add_water'), crit: K('add_fatal') }) },
      { id: 'm3', sn: 90126, mp: 60, cd: 20, fx: 'LIGHT_ATTACK', snd: 'skill_light', heal: K => K('add_hp') },
      { id: 'm4', sn: 90127, mp: 70, cd: 8, range: 3, proj: 'FIRE_ATTACK', projN: 3, hit: '特效-火爆炸', hitN: 3, hitR: 2, snd: 'skill_fireball2', snd2: 'skill_bomb', f: K => ({ mult: 1 + R100(K('add_fire_rate')), add: K('add_fire_val') }) },
      { id: 'm5', sn: 90129, mp: 80, cd: 30, dur: 10, bfx: '特效-弱化术', snd: 'skill_juqi', buff: K => ({ manaShield: R100(K('work_rate')), mpPerDmg: K('mp_trans_hp') }) },
      { id: 'm6', sn: 90128, mp: 90, cd: 12, range: 7, proj: '特效-冰球', hit: '特效-冰块碎裂', hitN: 10, hitR: 50, splash: 2.6, slow: 2, snd: 'skill_wind', snd2: 'skill_ice', f: K => ({ mult: R100(K('basic_attack_rate')), add: K('add_water') }) },
      { id: 'mp1', sn: 90124, pas: K => ({ atk: K('add_mag') }) },
      { id: 'mp2', sn: 90125, pas: K => ({ mpPct: K('add_mp_max_rate') }) },
      { id: 'mp3', sn: 90097, pas: K => ({ acc: K('add_raw_shoot_rate') }) },
      { id: 'mp4', sn: 90130, pas: K => ({ res: K('add_resist') }) },
      { id: 'mp5', sn: 90098, pas: K => ({ mpreg: K('mp_grow') }) },
      { id: 'mp6', sn: 90131, mp: 60, cd: 1, snd: 'skill_light', dur: K => K('buff_duration') * 60, buff: K => ({ mpAdd: K('add_mp_max') }) },   // orijinalde etkin (eskiden edilgendi)
      // uzmanlık: Element (元素 150016)
      { id: '90132', sn: 90132, mp: 300, cd: 4, range: 7, proj: 'FIRE_ATTACK2', projN: 3, hit: 'FIRE_ATTACK2', hitN: 10, hitR: 30, splash: 2.2, snd: 'skill_fireball2', snd2: 'skill_bomb', f: K => ({ mult: R100(K('fire_attack_factor')), add: K('add_fire_attack_value'), burn: 1 }) },
      { id: '90134', sn: 90134, mp: 300, cd: 4, aoe: 3, fx: '特效-冰霜新星', snd: 'skill_ice', f: K => ({ mult: R100(K('ice_attack_factor')) * (skRankSn(90135) ? 1.02 : 1), add: K('add_ice_attack_value'), slow: 2, freeze: skRankSn(90135) ? 10 : 0 }) },
      { id: '90136', sn: 90136, mp: 0, cd: 15, dur: 6, self: '特性-聚气', bfx: '特效-元素赐生', snd: 'skill_light', buff: K => ({ mpTick: R100(K('add_mp_rate')) / 2, dmgOut: skRankSn(90600) ? R100(skCSn(90600, 'magic_attack_dec_to_rate')) : 0.5, atk: skRankSn(90600) ? 0.05 : 0, hpTick: skRankSn(90600) ? 1 : 0 }) },
      { id: '90133', sn: 90133, pas: K => ({ ccDmg: K('add_damage_rate') }) },
      { id: '90135', sn: 90135, pas: () => ({}) },
      { id: '90600', sn: 90600, pas: () => ({}) },
      // uzmanlık: Gizem (奥术 150017)
      { id: '90137', sn: 90137, mp: 0, cd: 1.5, range: 7, proj: '特效-黑暗火球', hit: '特效-火爆炸', snd: 'skill_wind', snd2: 'skill_bomb', f: K => ({ mult: 1.2, arcane: 1 }), mpPct: K => R100(K('count_up_dec_mp_rate')) },
      { id: '90140', sn: 90140, mp: 250, cd: 7.5, range: 7, snd: 'skill_wind', f: (K, s) => ({ phantom: R100(K('copy_factor')), life: 5 + (skRankSn(90138) ? skCSn(90138, 'extra_lifetime') : 0) }) },
      { id: '90139', sn: 90139, mp: 200, cd: 15, dur: 6, self: '特性-聚气', bfx: '特效-神圣之盾', snd: 'skill_juqi', buff: K => Object.assign({ dodge: K('add_jook_rate') }, skRankSn(90601) && Math.random() < 0.1 ? { spd: 0.3, noSlow: 1 } : null) },
      { id: '90141', sn: 90141, pas: K => ({ mpToAtk: K('add_magic_attack_value') }) },
      { id: '90138', sn: 90138, pas: () => ({}) },
      { id: '90601', sn: 90601, pas: () => ({}) },
    ] },
  '牧师': { hp: 1050, mp: 700, atk: 60, def: 30, ghp: 165, gmp: 80, gatk: 13, gdef: 7, dmgK: 1.75, range: 5.5, color: '金', bolt: '特效-暗影冲击_红', boltHit: '特效-冲击爆炸', snd: 'skill_wind',
    skills: [
      // acemi (初级 150022) ve sınıf (神使 150023) ağaçları
      { id: 'p1', sn: 90312, mp: 18, cd: 1.0, range: 7, proj: '特效-暗影冲击_红', hit: '特效-冲击爆炸', snd: 'skill_wind', snd2: 'skill_bomb', f: (K, s, p, t) => ({ mult: 1 + (t && t.dot && t.dot.corr ? R100(skCSn(90314, 'arrow_buff')) : 0), add: K('add_dark') }) },
      { id: 'p2', sn: 90314, mp: 30, cd: 1, range: 7, fx: '特效-死亡标记', snd: 'skill_deathtag', f: () => ({ mult: 0, corrode: 1 }) },
      { id: 'p3', sn: 90317, mp: 50, cd: 15, aoe: 3, totem: '特效-神之威慑', snd: 'skill_juqi', f: (K, s) => ({ mult: 0, weakDef: s.atk * R100(K('def_reduce_rate')), weakT: 10 }) },
      { id: 'p4', sn: 90319, mp: 60, cd: 15, dur: 10, totem: '特效-治疗之泉', snd: 'skill_light', buff: (K, s) => ({ hotT: s.atk * 0.1 + K('hp_resume') }) },
      { id: 'p5', sn: 90318, mp: 45, cd: 6, range: 7, hit: '特效-暗影灼烧_红', snd: 'skill_fire2', snd2: 'skill_bomb', f: (K, s, p, t) => burnHit(K, t) },
      { id: 'p6', sn: 90321, mp: 70, cd: 3, self: '特效-缓缓加红', selfN: 40, selfR: 180, snd: 'skill_light', heal: (K, s) => s.atk + K('heal_hp') },
      { id: 'p7', sn: 90322, mp: 90, cd: 40, self: '特效-狂暴BUFF', selfN: 40, selfR: 180, bfx: '特效-神努buff', snd: 'skill_relive', dur: K => K('buff_duration'), buff: (K, s) => ({ atkAdd: s.atk * R100(K('add_attack_rate')), defAdd: s.atk * R100(K('add_defence_rate')) }) },
      { id: 'pp1', sn: 90313, pas: K => ({ atk: K('add_magic_attack') }) },
      { id: 'pp2', sn: 90315, pas: K => ({ crit: K('add_cruel_rate') }) },
      { id: 'pp3', sn: 90316, pas: () => ({}) },
      { id: 'pp4', sn: 90320, pas: () => ({}) },   // stats() can/mana sınırı bilindikten sonra ekler
      { id: 'pp5', sn: 90323, pas: () => ({}) },
      // uzmanlık: Kutsal (神圣 150024)
      { id: '90602', sn: 90602, mp: 100, cd: 1, dur: 60, self: '特性-聚气', snd: 'skill_juqi', toggle: 1, buff: K => ({ convert: K('convert_factor') }) },
      { id: '90604', sn: 90604, mp: 300, cd: 5, aoe: 3, self: '特效-细碎爆炸', selfN: 5, selfR: 80, snd: 'skill_light', f: K => ({ mult: R100(K('holy_damage_factor')), add: K('add_holy_damage_value'), novaHeal: 1, stun: skRankSn(90605) ? 10 : 0 }) },
      { id: '90606', sn: 90606, mp: 200, cd: 20, dur: 3, bfx: '特效-圣光壁垒', snd: 'skill_relive', buff: K => ({ dr: K('add_sorbdamage_rate') }) },
      { id: '90603', sn: 90603, pas: K => ({ cheatDeath: K('trigger_effect_rate') }) },
      { id: '90605', sn: 90605, pas: () => ({}) },
      { id: '90607', sn: 90607, pas: () => ({}) },
      // uzmanlık: Gölge (暗影 150025)
      { id: '90608', sn: 90608, mp: 250, cd: 4, range: 7, proj: '特效-暗影冲击_红', hit: '特性-冰火爆炸', snd: 'skill_wind', snd2: 'skill_deathtag', f: K => ({ mult: R100(K('dark_damage_factor')), add: K('add_dark_damage_value'), corrode: 1 }) },
      { id: '90610', sn: 90610, mp: 0, cd: 10, dur: 6, self: '特性-聚气', bfx: '特效-黑暗契约', snd: 'skill_deathtag', buff: K => ({ mp2hp: R100(K('dec_mp_rate')) }) },
      { id: '90613', sn: 90613, mp: 300, cd: 20, dur: 6, self: '特效-治疗buff', bfx: '特效-缓缓加红', snd: 'skill_relive', buff: () => ({ atk: 0.3, drain: 0.01, noHeal: 1 }) },
      { id: '90609', sn: 90609, pas: K => ({ seal: K('trigger_effect_rate') }) },
      { id: '90612', sn: 90612, pas: K => ({ veil: K('trigger_effect_rate') }) },
      { id: '90611', sn: 90611, pas: () => ({}) },
    ] },
};
// ırk becerileri (人类 150019 / 精灵 150013): kademe 1, kendiliğinden; orijinal açıklama "seviyeyle artar" diyor, artış bizim
const RACE_SK = {
  '人类': [{ id: 'r90082', sn: 90082, pas: (K, s, L) => ({ def: 2 * L, mp: 5 * L }) }, { id: 'r90083', sn: 90083, pas: () => ({ goldUp: 10 }) }],
  '精灵': [{ id: 'r90080', sn: 90080, pas: (K, s, L) => ({ res: 2 * L, hp: 8 * L }) }, { id: 'r90081', sn: 90081, pas: () => ({ lifeEl: 5 }) }],
};
// ---------------- Beceri ağacı kuralları (orijinal) ----------------
// Bir beceri öğrenilebilir: ön koşulu (önceki beceri en az şu kademede), ağacın kök şartı (sınıf yükseltmesi + önceki ağaca harcanmış puan;
// örn. sınıf ağacı: acemi ağacına 35 puan, uzmanlık: sınıf ağacına 40 puan) ve iki uzmanlığın kökü birbirini dışlar. Seviye şartı yok;
// puan seviye başına 1. Sıfırlama: Eğitim Kitabı (30092) ile bütün puanlar geri alınır.
let SKD = null;   // skills.json
const TREES = {};
const SKBYSN = {};
async function loadSkills() {
  SKD = await fetch(vq(Assets.base + 'skills.json')).then(r => r.json());
  const E = LANG === 'en';
  for (const [c, C] of Object.entries(CLS)) {
    for (const sk of C.skills) { const d = SKD.skills[sk.sn]; Object.assign(sk, { d, name: d[E ? 'en' : 'tr'][0], icon: d.icon, ik: d.ik || undefined, mx: d.mx, cls: c }); SKBYSN[sk.sn] = sk; }
    TREES[c] = SKD.trees[c].map((t, k) => ({ id: t.id, name: t[E ? 'en' : 'tr'], tier: k, cells: t.cells.map(([sn, col]) => [SKBYSN[sn].id, col]) }));
  }
  for (const [r, L] of Object.entries(RACE_SK)) for (const sk of L) { const d = SKD.skills[sk.sn]; Object.assign(sk, { d, name: d[E ? 'en' : 'tr'][0], icon: d.icon, ik: d.ik || undefined, mx: 1, race: r }); SKBYSN[sk.sn] = sk; }
  for (const c in TREES) TREES[c].push({ race: true, name: '', cells: [] }, { life: true, name: SKD.life[E ? 'en' : 'tr'], cells: [] });
}
const raceTree = (P = Game.P) => SKD.race[P.race];
const skRank = sk => sk.race ? (sk.race === Game.P.race ? 1 : 0) : (Game.P.sk && Game.P.sk[sk.id]) || 0;
const skRankSn = sn => { const sk = SKBYSN[sn]; return sk ? skRank(sk) : 0; };
const skC = (sk, key, r) => { const t = sk.d && sk.d.c[key]; if (!t) return 0; const k = clamp(r != null ? r : Math.max(1, skRank(sk)), 1, t.length); return t[k - 1]; };
const skCSn = (sn, key) => { const sk = SKBYSN[sn]; return sk ? skC(sk, key) : 0; };
// ağaca harcanmış puan
function treePts(treeId) { const P = Game.P, T = SKD && Object.values(SKD.trees).flat().find(t => t.id === treeId); if (!T) return 0; let n = 0; for (const [sn] of T.cells) n += (P.sk && P.sk[SKBYSN[sn].id]) || 0; return n; }
const ADVCLS = { 130004: 1, 130005: 1, 130011: 1, 130006: 2, 130008: 2, 130012: 2 };
// öğrenme şartı: null (öğrenilebilir) ya da [tür, açıklama]
function skLock(sk) {
  const P = Game.P, d = sk.d; if (!d) return null;
  if (sk.race) return null;
  const rt = d.root;
  if (rt) {
    const need = ADVCLS[rt.cls]; if (need && (P.adv || 0) < need) return ['adv', need === 1 ? tx('Sınıf yükseltme görevi gerekir (40. seviye).') : tx('İkinci sınıf yükseltmesi gerekir (80. seviye).')];
    const have = treePts(rt.tree); if (have < rt.pts) { const T = Object.values(SKD.trees).flat().find(t => t.id === rt.tree); return ['pts', T_(`${T.tr} ağacına ${rt.pts} puan gerekir (şu an ${have}).`, `Requires ${rt.pts} points in ${T.en} (now ${have}).`)]; }
    if (rt.excl && skRankSn(rt.excl)) { const o = SKBYSN[rt.excl]; return ['excl', T_(`${o.name} seçildi; bu uzmanlık alınamaz.`, `${o.name} was chosen; this specialization is closed.`)]; }
  }
  if (d.pre) { const pk = SKBYSN[d.pre[0]]; if (skRank(pk) < d.pre[1]) return ['pre', T_(`Önce ${pk.name} ${d.pre[1]}. kademe.`, `Requires ${pk.name} rank ${d.pre[1]}.`)]; }
  return null;
}
const T_ = (a, b) => LANG === 'en' ? b : a;
const skLockMsg = sk => { const L = skLock(sk); return L ? L[1] : ''; };
// sınıf adı: acemi (见习战士 / 法师学徒 / 见习神使), 40'ta sınıf, 80'de ikinci sınıf (黑骑士 / 大魔导师 / 天选者)
const clsName = (P = Game.P) => tx(((P.adv || 0) >= 2 ? TR.cls2 : (P.adv || 0) >= 1 ? TR.cls : TR.cls0)[P.cls]);
const SK_MAX = 15;   // orijinal kayıtlarda en yüksek kademe 10 ya da 15 (sk.mx)
// becerinin açıklaması: orijinal şablon, {sabit} kademe değeriyle doldurulur
function skDesc(sk, r) {
  const E = LANG === 'en', t = sk.d[E ? 'en' : 'tr'][1], rr = Math.max(1, r || skRank(sk)), mpv = typeof sk.mpPct === 'function' ? Math.round(sk.mpPct(k => skC(sk, k, rr)) * 100) + '%' : sk.mp;
  const fmt = v => Number.isInteger(v) ? String(v) : String(+v.toFixed(1));
  return t.replace(/\{(\w+)\}/g, (m, k) => k === 'cd' ? fmt(sk.cd || 0) : k === 'mp' ? String(mpv || 0) : fmt(skC(sk, k, rr)));
}
function skillUp(sk) {
  const P = Game.P, r = skRank(sk);
  if (sk.race) return;
  if (r >= (sk.mx || 10)) return UI.toast(T_('Bu beceri en yüksek kademede.', 'This skill is at its highest rank.'));
  if (skLock(sk)) return UI.toast(skLockMsg(sk));
  if ((P.sp || 0) < 1) return UI.toast('Beceri puanın yok. Seviye atlayınca puan kazanırsın.');
  P.sp--; P.sk[sk.id] = r + 1; SFX.play('skill_levelup'); UI.log(`${sk.name}: ${tx('kademe')} ${r + 1}`, 'q'); clampVitals(); save();
}
// puanları oyuncu gibi dağıt (GM "ağaçları doldur", tools/test/savas.js): her puan, öğrenilebilir beceriler arasında kademesi en düşük olana
// (eşitse önceki ağaç / önceki yuva). spec: hangi uzmanlık (öbürü alınmaz).
function skillAutoSpend(points, spec = 0) {
  const P = Game.P, C = CLS[P.cls], T = TREES[P.cls], tr = [T[0], T[1], T[2 + spec]].map(t => t.cells.map(([id]) => C.skills.find(x => x.id === id)));
  const pick = L => { let best = null; for (const sk of L) { const r = skRank(sk); if (r >= (sk.mx || 10) || skLock(sk)) continue; if (!best || r < skRank(best)) best = sk; } return best; };
  const need = [SKBYSN[T[1].cells[0] && C.skills.find(x => x.id === T[1].cells[0][0]).sn], SKBYSN[C.skills.find(x => x.id === T[2 + spec].cells[0][0]).sn]].map(sk => sk && sk.d.root ? sk.d.root.pts : 0);
  for (let n = 0; n < points; n++) {
    // oyuncu gibi: önce bir sonraki ağacı açacak kadar (acemi 35, sınıf 40), sonra en üstteki açık ağaç, en son kalanlar
    let best = null;
    if ((P.adv || 0) >= 1 && treePts(T[0].id) < need[0]) best = pick(tr[0]);
    else if ((P.adv || 0) >= 2 && treePts(T[1].id) < need[1]) best = pick(tr[1]) || pick(tr[0]);
    if (!best) best = pick(tr[2]) || pick(tr[1]) || pick(tr[0]);
    if (!best) { P.sp = (P.sp || 0) + points - n; break; }
    P.sk[best.id] = skRank(best) + 1;
  }
}
// puanları sıfırla: Eğitim Kitabı (训练之书 30092) harcanır; GM'de bedava
function skillReset(free) {
  const P = Game.P, spent = Object.values(P.sk || {}).reduce((a, b) => a + b, 0);
  if (!spent) return UI.toast(T_('Harcanmış beceri puanı yok.', 'No skill points spent.'));
  if (!free && !removeItem('30092') && !removeItem('30788')) return UI.toast(T_('Eğitim Kitabı gerekir (beceri eğitmeninde satılır).', 'Requires a Training Book (sold by the skill trainer).'));
  P.sp = (P.sp || 0) + spent; P.sk = {}; Game.player.buffs = []; SFX.play('skill_levelup');
  UI.log(T_(`Beceri puanları sıfırlandı: ${spent} puan geri geldi.`, `Skill points reset: ${spent} points returned.`), 'q'); clampVitals(); UI.refresh(); save();
}
const QUICK0 = ['s0', 's1', 's2', 's3', 's4', 's5', 'i:hp1', 'i:mp1'];
const ITEMS = {
  hp1: { name: 'Zayıf Can İksiri', icon: 1019, desc: '800 can yeniler.', price: 20, use: { hp: 800 } },
  hp2: { name: 'Can İksiri', icon: 1020, desc: '2000 can yeniler.', price: 80, use: { hp: 2000 } },
  mp1: { name: 'Zayıf Mana İksiri', icon: 1026, desc: '800 mana yeniler.', price: 20, use: { mp: 800 } },
  mp2: { name: 'Mana İksiri', icon: 1024, desc: '2000 mana yeniler.', price: 80, use: { mp: 2000 } },
  growthBox: { name: 'Gelişim Paketi', icon: 1038, desc: 'Aç: seviyene uygun ekipman ve iksir çıkar.', growth: true },
  quest: { name: 'Görev Eşyası', icon: 1125, desc: 'Görev için gerekli.', quest: true },
};
const Q_ICONS = { 'Tavuk Kanı': 1125, 'Domuz Bacak Kemiği': 1196, 'Enfiye Kutusu': 1056, 'Orman Kurdu Eti': 1225, 'Yabani Sebze': 1229, 'Peri Tozu': 1171 };

const Game = {
  map: null, scene: null, sceneId: null, P: null, player: null, ents: [], fx: [], floats: [], cam: { x: 0, y: 0 },
  time: 0, flags: {}, msgs: [],
};

// ---------------- Kayıt ----------------
function newSave(name, cls, race, sex) {
  return { v: 1, name, cls, race, sex, lv: 1, xp: 0, gold: 30, hp: 1e9, mp: 1e9,
    gear: { weap: 0, body: 0, head: 0 }, eq: Object.assign({}, STARTER[cls]), bag: [{ id: 'hp1', n: 5 }, { id: 'mp1', n: 3 }], quests: {}, done: {}, qitems: {},
    scene: race === '精灵' ? '120205' : '120207', x: 3, y: 13,   // haritanın kendi varış noktası (Rehber'in yanı)
    quick: QUICK0.slice(), sv: 2, sk: { [CLS[cls].skills[0].id]: 1 }, sp: 1, flags: {} };
}
// ---------------- Ekipman (orijinal eşya tablolarından) ----------------
// Yeni karakter ekipmansız doğar; acemi silahı, zırhı, başlığı ve ayakkabısı Gelişim Paketi'nden gelir
const STARTER = { '战士': {}, '法师': {}, '牧师': {} };
const STARTER_WEAP = { '战士': '10003', '法师': '10006', '牧师': '10882' };
const STARTER_BODY = { '战士': '10004', '法师': '10007', '牧师': '10883' };
const NEWBIE = { '战士': ['10002', '10439'], '法师': ['10005', '10058'], '牧师': ['10881', '10884'] };
const SLOTS = [['weap', 'Silah'], ['head', 'Başlık'], ['body', 'Zırh'], ['belt', 'Kemer'], ['shoe', 'Ayakkabı'], ['glove', 'Eldiven'], ['neck', 'Kolye'], ['ring', 'Yüzük']];
const STATN = { atk: 'Saldırı', def: 'Savunma', hp: 'Can', mp: 'Mana', crit: 'Kritik %', dodge: 'Kaçınma %', hpreg: 'Can yenileme', mpreg: 'Mana yenileme', res: 'Büyü direnci' };
let SHOPS = {};
async function loadItems() {
  await loadSkills();   // beceri ağaçları (skills.json)
  await loadTravel();   // yolculuk ağı (travel.json)
  const D = await fetch(vq(Assets.base + 'items.json')).then(r => r.json());
  for (const [id, it] of Object.entries(D.items)) { it.ik = it.icon[0]; it.icon = it.icon[1]; if (it.slot) it.desc = it.desc || ''; if (LANG === 'en') { it.name = it.en || EN_ITEM[it.name] || it.name; it.desc = it.den || tx(it.desc); } ITEMS[id] = it; }
  if (LANG === 'en') { for (const k of ['hp1', 'hp2', 'mp1', 'mp2', 'growthBox', 'quest']) { ITEMS[k].name = tx(ITEMS[k].name); ITEMS[k].desc = tx(ITEMS[k].desc); } SLOTS.forEach(s => s[1] = tx(s[1])); for (const k in STATN) STATN[k] = tx(STATN[k]); for (const t of Object.values(D.shops)) t.forEach(x => x[0] = tx(x[0])); }
  SHOPS = D.shops;
  // gece elfi tüccarları aynı mal listelerini satar (orijinalde dükkân listeleri eş)
  for (const [h, e] of [['道具商人（人类）', '道具商人（夜精灵）'], ['武器商人（人类）', '武器商人（夜精灵）'], ['防具商人（人类）', '防具商人（夜精灵）'], ['饰品商人（人类）', '饰品商人（夜精灵）']]) SHOPS[e] = SHOPS[h];
}
function iconSrc(it) { return `${Assets.base}ui/icon_res_${it.ik || 'item'}_${it.icon}.png`; }
function canEquip(it) { const P = Game.P; if (it.cls && it.cls !== P.cls) return `Bu eşya ${TR.cls[it.cls]} içindir.`; if (P.lv < it.lv) return `${it.lv}. seviye gerekir.`; return null; }
function equip(id) {
  const P = Game.P, it = ITEMS[id]; if (!it || !it.slot || !countItem(id)) return;
  const why = canEquip(it); if (why) return UI.toast(why);
  removeItem(id); const old = P.eq[it.slot]; P.eq[it.slot] = id; if (old) addItem(old, 1, true);
  UI.log(`${it.name} kuşanıldı.`, 'q'); SFX.play('repair', 0.6); clampVitals(); refreshLook();
}
function unequip(slot) { const P = Game.P, id = P.eq[slot]; if (!id) return; P.eq[slot] = null; addItem(id, 1, true); UI.log(`${ITEMS[id].name} çıkarıldı.`); clampVitals(); refreshLook(); }
function clampVitals() { const p = Game.player, s = stats(); p.hp = Math.min(p.hp, s.hp); p.mp = Math.min(p.mp, s.mp); }
function buyItem(id, n = 1) {
  const P = Game.P, it = ITEMS[id], cost = it.price * n; if (P.gold < cost) return UI.toast('Yeterli altının yok.');
  P.gold -= cost; SFX.play('coin'); addItem(id, n, true); UI.log(`${it.name} ×${n} satın alındı (−${cost} altın).`, 'loot'); save();
}
function sellItem(id, n = 1) {
  const P = Game.P, it = ITEMS[id]; n = Math.min(n, countItem(id)); if (!it || it.quest || n < 1 || !removeItem(id, n)) return;
  const g = (it.sell || Math.max(1, Math.floor((it.price || 0) / 10))) * n; P.gold += g; SFX.play('coin'); UI.log(`${it.name}${n > 1 ? ' ×' + n : ''} satıldı (+${g} altın).`, 'loot'); save();
}
// seviyeye ve sınıfa uygun rastgele ekipman (dükkân listelerinden)
function randomGear(lv) {
  const P = Game.P, pool = Object.entries(ITEMS).filter(([, it]) => it.slot && (!it.cls || it.cls === P.cls) && it.lv <= lv && it.lv >= lv - 12);
  return pool.length ? pool[irnd(0, pool.length - 1)][0] : null;
}
function save() { const P = Game.P; if (!P || !Game.player) return; P.scene = Game.sceneId; P.x = Game.player.x; P.y = Game.player.y; P.hp = Game.player.hp; P.mp = Game.player.mp; if (Net.on) return Net.save(P); try { localStorage.setItem(SAVE_KEY, JSON.stringify(P)); } catch (e) { } }
function load() { try { return fixSave(JSON.parse(localStorage.getItem(SAVE_KEY))); } catch (e) { } return null; }
// eski ya da sunucudan gelen kaydı tamamla
function fixSave(s) { try { if (s && s.v === 1) { s.quests = s.quests || {}; s.done = s.done || {}; s.qitems = s.qitems || {}; s.flags = s.flags || {}; s.gear = s.gear || { weap: 0, body: 0, head: 0 }; if (!s.eq) { s.eq = Object.assign({}, STARTER[s.cls]); if (s.gear && s.gear.head) Object.assign(s.eq, { head: NEWBIE[s.cls][0], shoe: NEWBIE[s.cls][1] }); } if (s.sv !== 2) { s.sv = 2; s.quick = QUICK0.slice(); } if (!s.sk) { s.sk = {}; s.sk[CLS[s.cls].skills[0].id] = 1; s.sp = 1; } fixSkills(s); return s; } } catch (e) { } return null; }

// kayıttaki becerileri orijinal kurallarla denetle: şartı tutmayan (ön koşul, ağaç puanı, sınıf, dışlayan uzmanlık) ya da kademesi aşan beceri
// puanı geri verilir (eski kurallarla seviyeye göre alınmış beceriler)
function fixSkills(s) {
  if (!SKD) return; const P0 = Game.P; Game.P = s;
  try {
    for (let k = 0; k < 12; k++) { let ch = false;
      for (const sk of CLS[s.cls].skills) { const r = s.sk[sk.id] || 0; if (!r) continue;
        const over = Math.max(0, r - (sk.mx || 10)); if (over) { s.sk[sk.id] = r - over; s.sp = (s.sp || 0) + over; ch = true; }
        const L = skLock(sk); if (L && !(sk.id === CLS[s.cls].skills[0].id && L[0] === 'pre')) { s.sp = (s.sp || 0) + s.sk[sk.id]; delete s.sk[sk.id]; ch = true; } }
      if (!ch) break; }
  } finally { Game.P = P0; }
}
function stats() {
  const P = Game.P, C = CLS[P.cls], L = P.lv - 1, g = P.gear;
  const s = { hp: C.hp + C.ghp * L, mp: C.mp + C.gmp * L, atk: C.atk + C.gatk * L, def: C.def + C.gdef * L, crit: 0, dodge: 0, hpreg: 0, mpreg: 0, res: 0 };
  for (const id of Object.values(P.eq || {})) { const it = id && ITEMS[id]; if (it && it.st) for (const k in it.st) s[k] = (s[k] || 0) + it.st[k]; }
  s.dr = 0; s.spd = 0; let hpPct = 0, mpPct = 0;
  // edilgen beceriler (orijinal kademe sabitleri) ve ırk becerileri; yüzdeler ve dönüşümler en sonda
  const X = {}, pasOf = sk => { const r = skRank(sk); if (!r || !sk.pas) return; const o = sk.pas(k => skC(sk, k), s, P.lv); for (const k in o) X[k] = (X[k] || 0) + o[k]; };
  for (const sk of C.skills) pasOf(sk); for (const sk of RACE_SK[P.race] || []) pasOf(sk);
  for (const k of ['atk', 'def', 'res', 'hp', 'mp', 'dodge', 'crit', 'hpreg', 'mpreg', 'dr']) if (X[k]) s[k] += X[k];
  s.hp *= 1 + (X.hpPct || 0) / 100; s.mp *= 1 + (X.mpPct || 0) / 100;
  for (const k of ['acc', 'healUp', 'ccDmg', 'despair', 'cheatDeath', 'seal', 'veil', 'goldUp', 'lifeEl']) s[k] = X[k] || 0;
  // İlahi Işık Dökümü: can/mana sınırının yüzdesi (sınırlar hesaplandıktan sonra)
  const pp4 = C.skills.find(k => k.sn === 90320); if (pp4 && skRank(pp4)) { const v = R100(skC(pp4, 'add_hp_resume_rate')); s.hpreg += s.hp * v; s.mpreg += s.mp * v; }
  for (const b of Game.player?.buffs || []) { const B = b.buff; if (B.atk) s.atk *= 1 + B.atk; if (B.def) s.def *= 1 + B.def; if (B.def && B.def < 0) s.res *= 1 + B.def; if (B.spd) s.spd += B.spd; if (B.crit) s.crit += B.crit; if (B.dr) s.dr += B.dr; if (B.hpP) s.hp *= 1 + B.hpP; if (B.dodge) s.dodge += B.dodge; if (B.res) s.res += B.res;   // hpP/dodge/res: evcil hayvan haleleri de
    if (B.atkAdd) s.atk += B.atkAdd; if (B.defAdd) { s.def += B.defAdd; s.res += B.defAdd; } if (B.mpAdd) s.mp += B.mpAdd; }
  // dönüşümler: Kan Ruhu (savunma → saldırı), Çelik İrade (saldırı → savunma/direnç), Büyü Yankısı (mana → büyü saldırısı)
  if (X.defToAtk) s.atk += s.def / 100 * X.defToAtk;
  if (X.atkToDef) { s.def += s.atk / 100 * X.atkToDef; s.res += s.atk / 100 * X.atkToDef; }
  if (X.mpToAtk) s.atk += s.mp / 500 * X.mpToAtk;
  for (const k in s) s[k] = Math.round(s[k]);
  return s;
}
function look() {
  const P = Game.P, e = P.eq || {}, G = sl => (e[sl] && ITEMS[e[sl]] && ITEMS[e[sl]].gfx) || null;
  return { cls: P.cls, race: P.race, sex: P.sex, bodyG: G('body'), headG: G('head'), weapG: G('weap') };
}
// Seviye deneyim tablosu ve normal canavar deneyimi: tools/deneyim_tablosu.py üretir (elle değiştirme; orijinal görev deneyimine göre,
// görevler gereken deneyimin ~%40'ı, canavarlar ~%60'ı; docs/04). XPT[L] = L → L+1 için gereken, MXPT[L] = L. seviye normal canavar.
const XPT = [0, 670, 991, 1460, 2160, 3200, 3840, 4490, 4630, 4770, 4910, 5060, 5210, 5360, 5520, 5690, 5860, 6040, 6220, 6400, 7150, 7760, 8430, 9150, 9930, 30900, 38500, 47900, 59600, 74300, 78000, 94100, 113000, 137000, 165000, 236000, 294000, 327000, 337000, 347000, 358000, 369000, 380000, 391000, 403000, 415000, 427000, 440000, 453000, 467000, 481000, 495000, 510000, 525000, 541000, 557000, 574000, 591000, 609000, 627000, 646000, 666000, 686000, 706000, 727000, 749000, 772000, 795000, 819000, 843000, 869000, 895000, 921000, 949000, 978000, 1010000, 1040000, 1070000, 1100000, 1130000, 1170000, 1200000, 1240000, 1280000, 1310000, 1350000, 1390000, 1440000, 1480000, 1520000, 1570000, 1620000, 1660000, 1710000, 1770000, 1820000, 1870000, 1930000, 1990000, 2050000, 2110000, 2170000, 2240000, 2300000, 2370000, 2440000, 2520000, 2590000, 2670000, 2750000, 2830000, 2920000, 3010000, 3100000, 3190000, 3280000, 3380000, 3480000, 3590000, 3700000, 3810000];
const MXPT = [0, 8, 11, 14, 18, 24, 26, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 30, 93, 116, 144, 179, 223, 234, 282, 339, 411, 495, 708, 882, 981, 1010, 1040, 1070, 1110, 1140, 1170, 1210, 1240, 1280, 1320, 1360, 1400, 1440, 1480, 1530, 1580, 1620, 1670, 1720, 1770, 1830, 1880, 1940, 2000, 2060, 2120, 2180, 2250, 2320, 2380, 2460, 2530, 2610, 2680, 2760, 2850, 2930, 3030, 3120, 3210, 3300, 3390, 3510, 3600, 3720, 3840, 3930, 4050, 4170, 4320, 4440, 4560, 4710, 4860, 4980, 5130, 5310, 5460, 5610, 5790, 5970, 6150, 6330, 6510, 6720, 6900, 7110, 7320, 7560, 7770, 8010, 8250, 8490, 8760, 9030, 9300, 9570, 9840, 10100, 10400, 10800, 11100, 11400];
function xpNeed(l) { return XPT[clamp(Math.round(l), 1, XPT.length - 1)]; }

// ---------------- Varlıklar ----------------
class Ent {
  constructor(kind, x, y) { Object.assign(this, { kind, x, y, dir: 2, t: Math.random() * 20, act: 0, path: null }); }
  get X() { return Game.map.px(this.x, this.y); }
  get Y() { return Game.map.py(this.x, this.y); }
}
class Player extends Ent {
  constructor(x, y) { super('player', x, y); this.doll = new Assets.Paperdoll(look()); const s = stats(); this.hp = Math.min(Game.P.hp, s.hp); this.mp = Math.min(Game.P.mp, s.mp); this.buffs = []; this.atkT = 0; this.state = 'idle'; this.anim = 0; this.cds = {}; this.combatT = 0; }
  draw(ctx, X, Y) {
    const act = this.state === 'attack' || this.state === 'cast' || this.combatT > 0 ? 'figh' : 'comm';
    let anim, t = this.t;
    if (this.dead) { anim = 16 + this.dir; return this.doll.draw(ctx, 'figh', anim, Math.min((this.deadT || 0) * TICK * 0.7, this.doll.animLen('figh', anim) - 1), X, Y); }   // figh 16-19: yere düşme, son karede kalır
    if (this.state === 'move') return this.doll.draw(ctx, 'comm', 4 + this.dir, t, X, Y);   // savaşta da normal koşu (figh 12-15 saldırı kareleri)
    else if (this.state === 'attack') { anim = 4 + this.dir; t = Math.min(this.animT, this.doll.animLen('figh', anim) - 1); }   // tek savuruş: baştan başlamaz, son karede bekler
    else if (this.state === 'cast') { anim = 8 + this.dir; t = Math.min(this.animT, this.doll.animLen('figh', anim) - 1); }
    else anim = act === 'figh' ? this.dir : this.dir;
    this.doll.draw(ctx, act, anim, t, X, Y);
  }
}
// Elle ayarlanmamış canavarlar: seviye sahnenin seviyesinden, sıra adındaki yıldızlardan (☆ seçkin, ☆☆ patron) gelir.
// Sahnenin seviyesi harita dosyası adındaki sayıdır (…-10, …-50); bir sahnedeki canavarlar o aralığa sırayla dağıtılır.
// canavar deneyimi: seviyedeki normal canavar (MXPT, tools/deneyim_tablosu.py) × seçkin 3 / boss 25
const mobXp = (lv, rank) => Math.round(MXPT[clamp(lv, 1, MXPT.length - 1)] * (rank === 2 ? 25 : rank ? 3 : 1));
function monDef(nm, sc) {
  const R = sc && sc.lvr, xpOf = (lv, rank) => mobXp(lv, rank);
  if (MON[nm]) {
    const d = MON[nm];
    // elle yazılmış değerler gerçek seviye aralığının dışındaysa aralığa çekilir (aralıklar dünya haritası tablosundan)
    if (R && !d.auto && !d.fit && d.lv) { d.fit = true; const lv = clamp(d.lv, R[0], R[1] + (d.rank === 2 ? 2 : d.rank ? 1 : 0)); if (lv !== d.lv) { d.lv = lv; d.xp = xpOf(lv, d.rank || 0); } }
    return d;
  }
  const rank = nm.startsWith('☆☆') || nm.startsWith('★') ? 2 : nm.includes('☆') ? 1 : 0, S = (sc && sc.lv) || 1;   // ★ = zindan boss'u
  const kinds = sc ? [...new Set(sc.ents.filter(e => Assets.D.mon[e[0]] && !e[1].includes('☆')).map(e => e[1]))] : [], i = Math.max(0, kinds.indexOf(nm));
  let lv;
  if (R) lv = rank === 2 ? R[1] + 2 : rank ? R[1] + 1 : R[0] + Math.round(i * (R[1] - R[0]) / Math.max(1, kinds.length - 1));
  else { const base = Math.max(1, S - 9), span = Math.max(1, Math.min(9, kinds.length)); lv = Math.min(S + 5, base + Math.round(i * 8 / span) + (rank === 2 ? 6 : rank ? 3 : 0)); }
  return MON[nm] = { lv, rank, xp: xpOf(lv, rank), n: rank === 2 ? 1 : rank ? 2 : 7, wide: rank ? 4 : 8, auto: true };
}
// Sınıf yükseltme görevlerinin hedefi: orijinalde yalnız 82938/82941'de geçen, 40. seviye görevi için konmuş seçkin (bulunduğu koridor ~52)
MON['☆【叛神者】托马斯杨'] = { lv: 42, rank: 1, xp: mobXp(42, 1), n: 1, wide: 2 };
// 80. seviye ikinci sınıf yükseltme hedefleri (Ruh Arafı, Andecano Tahtı: haritaların seviye aralığı tabloda yok; bölge 77)
for (const n of ['☆不朽骑士', '☆风尘怪', '☆灵魂漫步者']) MON[n] = { lv: 80, rank: 1, xp: mobXp(80, 1), n: 3, wide: 5 };
MON['☆☆【疯狂梦呓者】安德卡诺'] = { lv: 82, rank: 2, xp: mobXp(82, 2), n: 1, wide: 1, solo: 1 };   // üç sınıfın da son görev hedefi: tek kişilik boss (tools/test/savas.js BOSS)
class Mob extends Ent {
  constructor(name, x, y, home) {
    super('mob', x, y); const d = monDef(name, Game.scene);
    // canavar değerleri orijinalde sunucudaydı: seviyeden hesaplanır (haritaların seviye aralığına göre)
    const L = d.lv || 1, rk = d.rank || 0, soft = d.passive ? 0.55 : 1;
    // denge (tools/test/savas.js): seçkin ☆ ×3 can ×1,15 saldırı; saldırı yüksek seviyede biraz daha hızlı artar
    const mhp = Math.round((250 + 260 * L) * soft * (rk === 2 ? 18 : rk ? 3 : 1)); this.atk = Math.round((48 + 27 * L + 0.15 * L * L) * soft * (rk === 2 ? 1.8 : rk ? 1.15 : 1)); this.def = 8 * L * (rk ? 1.5 : 1);
    Object.assign(this, { name, d, hp: mhp, maxHp: mhp, home, state: 'idle', atkT: 0, wanderT: rnd(1, 4), aggro: false, slowT: 0 });
    Dungeon.tune(this);   // zindan: sınav canavarı zayıf, boss tek kişilik
    if (d.solo && rk === 2) { this.maxHp = this.hp = Math.round(this.hp * 8 / 18); this.atk = Math.round(this.atk / 1.8); }   // görev boss'u tek kişilik: ×8 can, saldırı seçkin düzeyinde (tools/test/savas.js BOSS)
    const info = Game.mobInfo(name); this.sp = info ? Game.map.sprite(info[1]) : null; this.deathFx = info?.[2];
    this.dir = irnd(0, 3);
  }
  draw(ctx, X, Y) {
    if (!this.sp) return;
    if (this.dead && this.deadT > 0.2) return;                                   // ölüm efekti (kan patlaması) oynarken gövde kaybolur
    const actIdx = this.state === 'attack' ? 2 : this.state === 'move' ? 1 : 0;
    let anim = actIdx * 4 + this.dir;
    if (!this.sp.anims[anim] || !this.sp.anims[anim].length) anim = this.dir;
    const t = this.state === 'attack' ? Math.min(this.animT, this.sp.animLen(anim) - 1) : this.t;
    const hit = this.state === 'hurt' && !this.dead;                              // vurulunca kısa bir an parlar
    this.sp.draw(ctx, anim, t, X + (hit ? Math.sin(this.animT * 3) * 1.5 : 0), Y, false, this.dead ? Math.max(0, 1 - this.deadT * 5) : 1);
  }
}
class Npc extends Ent {
  constructor(id, info, x, y) {
    super('npc', x, y); Object.assign(this, { id, info, cn: info[0], name: trName(info[0]) });
    this.sp = Game.map.sprite(info[1]); this.pickup = info.some(s => /npc_pickup/.test(s));
    this.anim = 0;
  }
  draw(ctx, X, Y) { if (this.hidden) return; if (this.sp && this.sp.ok) this.sp.draw(ctx, Math.min(this.anim, this.sp.anims.length - 1), this.t, X, Y); }
}
// Efekt dosyalarında 0. animasyon tek karelik duruş karesidir; asıl efekt sonraki animasyondadır.
// Yöne bağlı efektlerde (kılıç izi, kan sıçraması) her yönün kendi animasyonu vardır: bakılan yöne göre seçilir.
// 8 yuvalı yönlü efektler (kılıç izi 特效-刀光, kan BLOOD, 特效-疾风斩): tek numaralı yuvalar 4 çapraz yön; (1,5) ve (3,7) yuvaları
// birbirinin yatay aynası, 1 ve 3 sağa, 5 ve 7 sola bakar → yön 0 sağ-yukarı: 1, 1 sağ-aşağı: 3, 2 sol-aşağı: 7, 3 sol-yukarı: 5
// (eskiden 1,3,5,7 sırasıyla alınıyordu; sola bakan iki yönde iz kılıcın tersine düşüyordu)
const FX8 = [1, 3, 7, 5];
function fxAnim(sp, dir) {
  if (!sp.ok) return 0; const L = sp.anims.map(a => a.length), cand = [];
  if (L.length === 8 && [1, 3, 5, 7].every(i => L[i] > 1)) return FX8[((dir || 0) % 4 + 4) % 4];
  L.forEach((n, i) => { if (n > 1) cand.push(i); });
  // tek kareli efektlerde de 0. animasyon boş duruş karesidir (örn. buz kalıbı 特效-冻结: 0 boş, 1 buz): 1. animasyon alınır
  if (!cand.length) { const i = L.findIndex((n, k) => n > 0 && (k > 0 || L.length === 1)); return i < 0 ? 0 : i; }
  return cand.length === 1 ? cand[0] : cand[((dir || 0) % cand.length + cand.length) % cand.length];
}
// opt: anim/dir (animasyon), follow (varlığı izler), loop (bitmez; süren etkiler), z (yükseklik), ox/oy (piksel kayması: saçılma)
class Fx {
  constructor(name, x, y, opt = {}) {
    this.sp = Game.map.sprite(name); this.sp.glow = opt.glow !== false; this.x = x; this.y = y; this.t = 0; this.loop = opt.loop || 0; this.follow = opt.follow; this.z = opt.z || 0;
    this.ox = opt.ox || 0; this.oy = opt.oy || 0; this.map = Game.map;
    this.anim = opt.anim != null ? opt.anim : fxAnim(this.sp, opt.dir != null ? opt.dir : Game.player ? Game.player.dir : 0);
    this.len = this.sp.ok ? this.sp.animLen(this.anim) : 0; this.done = !this.sp.ok || !this.len;
  }
  draw(ctx, X, Y) { if (this.sp.ok) this.sp.draw(ctx, this.anim, this.t, X + this.ox, Y + this.oy - this.z); }
}
// Orijinal efekt tablosundaki "sayı + yarıçap": efekt n kez, ilki tam ortada, ötekiler r piksellik daire içinde rastgele (yer düzlemi:
// dikeyde yarı) ve kısa aralıklarla (toplam en çok ~0,6 sn) oynar. Örn. Öç Bıçağı kılıç izi 5×5 px, Kutsal Işık kırmızı ışık 40×180 px.
function fxBurst(name, x, y, n, r, opt = {}) {
  if (!name) return; n = n || 1; const gap = Math.min(0.06, 0.6 / n);
  for (let k = 0; k < n; k++) {
    const go = () => { const a = Math.random() * 6.283, d = k && r ? Math.sqrt(Math.random()) * r : 0; Game.fx.push(new Fx(name, x, y, Object.assign({}, opt, { ox: Math.cos(a) * d, oy: Math.sin(a) * d * 0.5 }))); };
    const dl = (opt.delay || 0) + k * gap; if (dl > 0) later(dl, go); else go();
  }
}
// Çağrılan nesneler (orijinal all_monster: 威慑图腾 → 特效-神之威慑, 治疗之泉 → 特效-治疗之泉, 魔法幻象 → 怪物-魔法幻象): yere konur,
// süresi boyunca durur, sonra kaybolur.
function totemAt(name, x, y, life) { const f = new Fx(name, x, y, { loop: 1 }); f.life = life; Game.fx.push(f); return f; }
// Büyü Hayali (90140): "hayal totemi" oyuncunun yanına dikilir, süresince oyuncunun hedefine ateş eder; mermiler totemden çıkar.
// Canavar görseli (ışık değil): 0-3 duruş, 8-11 saldırı.
function phantomFx() {
  const p = Game.player, f = new Fx('怪物-魔法幻象', p.x - 1, p.y + 0.3, { loop: 1, anim: p.dir, glow: false });
  f.at = () => ({ x: f.x, y: f.y }); Game.fx.push(f); return f;
}
// Süren etkilerin görseli (orijinal all_buff: her güçlendirme/zayıflatmanın bir efekti var): etki sürdükçe efekt varlığın üstünde
// döner, bitince kalkar; harita değişince yeniden kurulur. want = { anahtar: efekt adı }.
function auraSync(e, want) {
  const A = e._aura || (e._aura = {});
  for (const k in want) { const f = A[k]; if (!f || f.done || f.map !== Game.map || f.name !== want[k]) { if (f) f.done = true; const g = new Fx(want[k], e.x, e.y, { follow: e, loop: 1 }); g.name = want[k]; Game.fx.push(g); A[k] = g; } }
  for (const k in A) if (!(k in want)) { A[k].done = true; delete A[k]; }
}

// ---------------- Sahne yükleme ----------------
Game.mobInfo = name => { for (const k in Assets.D.mon) if (Assets.D.mon[k][0] === name) return Assets.D.mon[k]; return null; };
// veri düzeltmesi: bir canavar kaydında (☆☆【小胖】拉斯) görünüm ile ölüm efekti alanları yer değiştirmiş
let MON_FIXED = false;
function fixMonData() { if (MON_FIXED) return; MON_FIXED = true; for (const v of Object.values(Assets.D.mon)) if (v.length > 2 && /^特效-/.test(v[1]) && !/^特效-/.test(v[2])) [v[1], v[2]] = [v[2], v[1]]; }
async function loadScene(sid, arrive) {
  UI.fade(true); fixMonData();
  const D = Assets.D, sc = D.scenes[sid];
  const json = await fetch(vq(Assets.base + 'maps/' + sc.map + '.json')).then(r => r.json());
  const map = new GameMap(sc.map, json, sc);
  // gerekli görselleri önceden yükle
  const names = new Set(map.names);
  for (const [id, nm] of sc.ents) { const info = D.cit[id] || D.mon[id]; if (info) { names.add(info[1]); if (info[2]) names.add(info[2]); } }
  for (const n of ['特效-血爆死亡', '特效-刀光', 'LEVELUP', '特效-火球', '特效-火爆炸', '特效-冰球', '特效-冰块碎裂', '特效-黑暗火球', '特效-蓝火球', '特效-大喷血', '特效-治疗buff', 'NPC-新手引导－1', 'NPC-新手引导－2']) names.add(n);
  for (const s of CLS[Game.P.cls].skills) for (const k of ['fx', 'proj', 'hit', 'self', 'fx2', 'bfx', 'totem']) if (s[k]) names.add(s[k]);
  for (const n of ['特效-冻结', '特效-缓缓加蓝', '特效-抗性衰减buff', '特效-漆黑之幕', '怪物-魔法幻象']) names.add(n);   // süren etkiler (donma, yavaşlama, gözdağı, perde) ve Büyü Hayali
  for (const k of ['bolt', 'boltHit']) if (CLS[Game.P.cls][k]) names.add(CLS[Game.P.cls][k]);
  await Assets.preload([...names]);
  Game.player && (Game.player = null);
  Game.map = map; Game.scene = sc; Game.sceneId = sid; Game.target = null; Game.ents = []; Game.fx = []; Game.floats = [];
  timers.length = 0;   // önceki haritanın bekleyen işleri (canavar darbesi, beceri vuruşu) yeni haritada çalışmasın (C++ karşılaştırmasında bulundu)
  map.build();
  Dungeon.onLoad(sid);
  // NPC'ler ve canavarlar
  for (let ei = 0; ei < sc.ents.length; ei++) {
    const [id, nm, pos] = sc.ents[ei], [x, y] = pos;
    if (D.cit[id]) { const n = new Npc(id, D.cit[id], x, y); Game.ents.push(n); }   // NPC'ler yolu kapatmaz: içlerinden geçilir (kullanıcı bildirdi; dar yolda/kapıda takılıyordu)
    else if (D.mon[id]) {
      const d = monDef(nm, sc);
      // tek kareli "canavarlar" aslında maden kayası, kalıntı gibi sabit toplama noktalarıdır: saldırılmaz
      const msp = map.sprite(D.mon[id][1]), still = msp.ok && msp.anims.slice(0, 12).every(a => a.length <= 1);
      if (d.skip) continue;   // etkinlik canavarları (yalnızca bayramlarda çıkar)
      if (d.dummy || still) { const n = new Npc(id, [nm, D.mon[id][1]], x, y); n.dummy = true; n.node = still; Game.ents.push(n); if (still && !d.dummy) map.extraBlock[map.idx(x, y)] = 1; continue; }
      const cnt = d.n || 5, wide = d.wide || 5;
      for (let i = 0; i < cnt; i++) {
        if (Dungeon.skip(sid, ei, i)) continue;   // normal zindanda bu koşuda kesilmiş
        let px = x, py = y;
        for (let k = 0; k < 30; k++) { const a = rnd(-wide, wide), b = rnd(-wide, wide); if (!map.blocked(x + a, y + b)) { px = Math.round(x + a); py = Math.round(y + b); break; } }
        const mb = new Mob(nm, px, py, { x: px, y: py }); mb.key = Dungeon.key(sid, ei, i); Game.ents.push(mb);
      }
    }
  }
  // oyuncu
  let px = Game.P.x, py = Game.P.y;
  if (arrive) { [px, py] = arrive; }
  if (map.blocked(px, py)) { const r = map.regionsOf(0)[0] || [0, 0, Math.floor(map.w / 2), Math.floor(map.h / 2)]; px = r[2]; py = r[3]; }
  if (map.blocked(px, py)) { outer: for (let r = 1; r < 30; r++) for (let dy = -r; dy <= r; dy++) for (let dx = -r; dx <= r; dx++) if (!map.blocked(px + dx, py + dy)) { px += dx; py += dy; break outer; } }
  Game.player = new Player(px, py); Game.ents.push(Game.player);
  Pet.spawn();   // çağrılmış evcil hayvan sahibinin yanında
  Net.scene(sid, px, py);   // çevrimiçiyse sunucuya bu haritada olduğumuzu bildir
  if (Game.route) setTimeout(routeStep, 400);   // otomatik yol sürüyorsa sonraki geçide yürü
  Game.cam.x = Game.player.X; Game.cam.y = Game.player.Y;
  Game.arriveT = 1.5;
  UI.zone(trName(sc.name));
  SFX.Music.play(sc.music);
  save();
  setTimeout(() => UI.fade(false), 80);
}
// Haritadan çıkış
function checkExits() {
  const p = Game.player, map = Game.map; if (Game.arriveT > 0 || Game.transit) return;
  const cx = Math.round(p.x), cy = Math.round(p.y);
  for (const r of map.regionsOf(1)) {
    if (cx >= r[2] && cx <= r[4] && cy >= r[3] && cy <= r[5]) {
      const fx = Dungeon.exitFix(Game.sceneId, r[0]); if (fx) { gotoScene(fx[0], null, [fx[1], fx[2]]); return; }   // yanlış bağlı geçit
      const ex = map.scene.exits.find(e => e[0] === r[0]); if (!ex) { if (Dungeon.door(r[0])) return; continue; }   // bağlanmamış geçit: zindan kapısı olabilir
      const target = ex[1].replace('(入口)', '');
      // hedef sahne numarası paketlemede çözülür (aynı adlı birden çok sahne olabilir)
      const sid = ex[2] || Object.keys(Assets.D.scenes).find(k => Assets.D.scenes[k].name === target);
      if (!sid || !Assets.D.scenes[sid]) { if (!Game.warnT) { UI.toast(`${trName(target)}: bu bölge henüz açılmadı`); Game.warnT = 3; } return; }
      if (Dungeon.exitTo(sid)) return;   // zindandan alana çıkış: kapının dışına
      gotoScene(sid, Game.scene.name, null, Game.sceneId);
      return;
    }
  }
}
// geçidin yanındaki varış bölgesi: çoğunlukla geçit+1 (tür 0); değilse geçide en yakın varış bölgesi (ör. Mehtap Korusu'nda geçit−1)
function arrivalNear(regs, idx) {
  const ex = regs.find(g => g[0] === idx && g[1] === 1) || regs.find(g => g[0] === idx), nx = regs.find(g => g[0] === idx + 1 && g[1] === 0);
  if (nx || !ex) return nx || ex;
  const c = g => [(g[2] + g[4]) / 2, (g[3] + g[5]) / 2], [ax, ay] = c(ex); let best = null, bd = 1e9;
  for (const g of regs) if (g[1] === 0) { const [x, y] = c(g), d = Math.hypot(x - ax, y - ay); if (d < bd) { bd = d; best = g; } }
  return best || ex;
}
async function gotoScene(sid, fromName, fixed, fromSid) {
  Game.transit = true; save();
  const sc = Assets.D.scenes[sid];
  let arrive = fixed || null;
  if (!arrive) {
    const json = await fetch(vq(Assets.base + 'maps/' + sc.map + '.json')).then(r => r.json());
    const back = (fromSid && sc.exits.find(e => e[2] === fromSid)) || sc.exits.find(e => e[1].replace('(入口)', '') === fromName);
    const regs = json.regions;
    const r = back ? arrivalNear(regs, back[0]) : regs.find(g => g[1] === 0);
    if (r) arrive = [Math.round((r[2] + r[4]) / 2), Math.round((r[3] + r[5]) / 2)];
  }
  await loadScene(sid, arrive);
  Game.transit = false;
}

// ---------------- Savaş ----------------
function dmgCalc(atk, def, mult, critB = 0, add = 0) { const base = (atk * mult + add) * rnd(0.92, 1.08); const d = Math.max(1, Math.round(base * 1000 / (1000 + def * 3))); const crit = Math.random() < 0.08 + critB / 100; return { d: crit ? Math.round(d * 1.8) : d, crit }; }
// o: { crit, add, slow, pure (savunma tanımaz), bleed, burn, freeze, stun (olasılık %), critDmg, onCrit, tick (sürekli hasar: tetikleyiciler yok) }
function hitMob(m, mult, o = {}) {
  if (!m || m.dead) return 0;
  const s = stats(), p = Game.player, B = {}; for (const b of p.buffs) for (const k in b.buff) if (typeof b.buff[k] === 'number') B[k] = (B[k] || 0) + b.buff[k];
  // İlahi Gözdağı: savunma, büyü saldırısının yüzdesi kadar düşer; eski genel zayıflatma (evcil) savunmayı %60 düşürür
  const def = m.weakT > 0 ? (m.weakDef ? Math.max(0, m.def - m.weakDef) : m.def * 0.4) : m.def;
  let critB = s.crit + (o.crit || 0);
  if (!o.tick && B.nextCrit) { if (Math.random() * 100 < B.nextCrit) critB = 1000; for (const b of p.buffs) delete b.buff.nextCrit; }   // Hız Patlaması: sonraki saldırı
  const K0 = CLS[Game.P.cls].dmgK || 1;   // büyü gücü: büyücü/rahip vuruş çarpanı (bizim denge; orijinal hasar formülü sunucudaydı)
  const r = dmgCalc(s.atk, o.pure ? 0 : def, mult * K0 * (m.weakT > 0 && !m.weakDef ? 1.15 : 1), critB, (o.add || 0) * K0);
  let d = r.d;
  if (r.crit && o.critDmg) d = Math.round(d * (1 + o.critDmg / 100));
  if (s.ccDmg && (m.slowT > 0 || m.rootT > 0 || m.burn)) d = Math.round(d * (1 + s.ccDmg / 100));   // Element Ustalığı
  if (B.dmgUp) d = Math.round(d * (1 + B.dmgUp / 100));   // Büyü Darbesi katları
  if (B.dmgOut) d = Math.round(d * Math.min(1, B.dmgOut));   // Element Bağışı sırasında hasar düşer
  d = Math.max(1, d);
  m.hp -= d; m.aggro = true; m.state = 'hurt'; m.animT = 0; m.stateT = 0.3; if (!(m.tauntT > 0)) m.foe = Game.player;
  if (o.slow) m.slowT = o.slow;
  UI.float(m, (r.crit ? '!' : '') + d, r.crit ? '#ffd040' : o.tick ? '#d8b0ff' : '#fff', r.crit ? 1.3 : 1);
  if (!o.tick) {
    if (B.leech) healPlayer(d * B.leech);   // Kan Damgası
    if (o.bleed) { m.bleed = { n: Math.min(5, ((m.bleed && m.bleed.n) || 0) + 1), t: 10, tick: 2 }; }   // Testere Bıçak: en çok 5 kat
    if (o.burn) m.burn = { t: 6, tick: 2 };   // Alev Darbesi: yanma (yığılmaz)
    if (o.freeze && Math.random() * 100 < o.freeze) m.rootT = 2;
    const now = Game.time;
    if (o.stun && Math.random() * 100 < o.stun && !(p.stunCd > now)) { m.stunT = 3; p.stunCd = now + 15; UI.float(m, T_('Sersem', 'Stun'), '#ffe070'); }
    if (s.seal && Math.random() * 100 < s.seal && !(p.sealCd > now)) { m.sealT = 3; p.sealCd = now + 10; UI.float(m, T_('Mühür', 'Sealed'), '#c080ff'); }
    if (s.despair && Math.random() * 100 < s.despair && !(p.despCd > now)) { m.despairT = 6; p.despCd = now + 15; }
    if (r.crit && o.onCrit) o.onCrit(m);
  }
  if (m.hp <= 0) killMob(m);
  if (Game.target === m) UI.target(m);
  return d;
}
function killMob(m) {
  m.dead = true; m.deadT = 0; m.state = 'die'; m.respawnT = m.d.rank === 2 ? 90 : m.d.rank ? 40 : 15;
  if (Game.target === m) setTarget(null);
  const P = Game.P, diff = m.d.lv - P.lv, xp = Math.max(1, Math.round(mobXp(m.d.lv, m.d.rank || 0) * clamp(1 + diff * 0.1, 0.2, 1.5)));
  gainXp(xp); UI.float(m, '+' + xp + ' TP', '#9fe060');
  const st = stats(), gold = Math.round((irnd(m.d.lv, m.d.lv * 3) + (m.d.rank || 0) * 20) * (1 + (st.goldUp || 0) / 100)); P.gold += gold;
  if (st.lifeEl && ITEMS['30127'] && Math.random() * 100 < st.lifeEl) addItem('30127', 1);   // gece elfi: Yaşam Özütü SFX.play('kill', 0.7); later(0.35, () => SFX.play('coin', 0.5)); UI.log(`${gold} altın alındı`, 'loot');
  if (Math.random() < 0.1) addItem(P.lv > 10 ? 'hp2' : 'hp1', 1);
  if (Math.random() < 0.06) addItem(P.lv > 10 ? 'mp2' : 'mp1', 1);
  if (m.d.rank && Math.random() < 0.6) { const g = randomGear(Math.max(1, m.d.lv + 2)); if (g) { addItem(g, 1, true); UI.log(`Ganimet: ${ITEMS[g].name}!`, 'q'); UI.toast(`Ganimet: ${ITEMS[g].name}`); } }
  else if (!m.d.passive && Math.random() < 0.025) { const g = randomGear(Math.max(1, m.d.lv)); if (g) { addItem(g, 1, true); UI.log(`Ganimet: ${ITEMS[g].name}`, 'loot'); } }
  questKill(m.name);
  Dungeon.onKill(m); Pet.onKill(m, xp); Pet.dropEgg(m);
  if (m.deathFx) Game.fx.push(new Fx(m.deathFx, m.x, m.y));
}
function hurtPlayer(m) {
  if (Game.god) return;   // GM: ölümsüzlük
  const p = Game.player; if (p.dead) return;
  const s = stats(); if (Math.random() < s.dodge / 100) { UI.float(p, 'Iska', '#cfcfcf'); return; }
  const r = dmgCalc(m.atk || m.d.atk, s.def, 1); r.d = Math.max(1, Math.round(r.d * (1 - Math.min(80, s.dr) / 100)));
  const B = {}; for (const b of p.buffs) for (const k in b.buff) if (typeof b.buff[k] === 'number') B[k] = (B[k] || 0) + b.buff[k];
  const now = Game.time;
  // Büyücü Bedeni (90611): Karanlık Ahit sırasında %10 hasarı savuştur, hasar kadar mana
  if (B.mp2hp && skRankSn(90611) && Math.random() < 0.1) { p.mp = Math.min(s.mp, p.mp + r.d); UI.float(p, T_('Savuşturuldu', 'Negated'), '#9fd0ff'); return; }
  // Zifiri Perde (90612): Karanlık Ahit dışında, 15 saniyede bir, savunma ve dirençler 6 saniye artar
  if (s.veil && !B.mp2hp && !(p.veilCd > now) && Math.random() * 100 < s.veil) { p.veilCd = now + 15; p.buffs.push({ id: 'veil', buff: { def: 0.5, res: Math.round(s.res * 0.5) }, t: 6, fx: '特效-漆黑之幕' }); }   // güçlendirme 210192
  // Büyü Kalkanı (90129): hasarın bir kısmı manadan düşer
  if (B.manaShield) { const per = B.mpPerDmg || 1, want = Math.round(r.d * Math.min(1, B.manaShield)), can = Math.min(want, Math.floor(p.mp / per)); p.mp -= can * per; r.d -= can; }
  // Karşı Saldırı Fırtınası (90598): fiziksel saldırının %10'u ile alınan hasardan küçük olanı yansır
  if (B.reflect && r.d > 0 && !m.dead) { const back = Math.round(Math.min(s.atk * B.reflect, r.d)); if (back > 0) hitMob(m, 0, { add: back, pure: 1, tick: 1 }); }
  if (r.d <= 0) return;
  p.hp -= r.d; p.combatT = 5; UI.float(p, '-' + r.d, '#ff5040'); UI.hurt();
  // Kutsanmış Beden (90603): ölümcül darbeyi olasılıkla savuştur, biraz can (orijinal kayıtta efekt yok: yalnızca yazı)
  if (p.hp <= 0 && s.cheatDeath && Math.random() * 100 < s.cheatDeath) { p.hp = Math.round(s.hp * 0.2); UI.float(p, T_('Kutsandı', 'Blessed'), '#ffe070'); return; }
  if (p.hp <= 0) { p.hp = 0; p.dead = true; p.deadT = 0; p.state = 'dead'; SFX.play('kill', 0.5); UI.death(); setTarget(null); }
}
function gainXp(n) {
  const P = Game.P; P.xp += n;
  while (P.xp >= xpNeed(P.lv)) { P.xp -= xpNeed(P.lv); P.lv++; const s = stats(); Game.player.hp = s.hp; Game.player.mp = s.mp; Game.fx.push(new Fx('LEVELUP', Game.player.x, Game.player.y)); UI.levelUp(P.lv); SFX.play('levelup');
    P.sp = (P.sp || 0) + 1; UI.log('Beceri puanı kazandın! Beceriler ekranından harca.', 'q');
    autoQuests();
    const nq = questsUnlockedAt(P.lv); for (const q of nq) UI.log(`${tx('Yeni görev')}: ${q.title} · ${trName(q.giver)}`, 'q'); if (nq.length) UI.toast(`${nq.length} ${tx('yeni görev açıldı')}`); }
  UI.refresh();
}
// hedef seçmek saldırı başlatmaz: Game.engage yalnız saldırı düğmesi, seçili canavara ikinci dokunuş, beceri ya da görev yürüyüşüyle açılır;
// yön tuşu (joystick) saldırıyı bırakır, hedef seçili kalır (kullanıcı isteği)
function setTarget(e, engage = false) { Game.engage = !!(engage && e); Game.target = e; UI.target(e); }
function cycleTarget() {
  const p = Game.player;
  const list = Game.ents.filter(e => e.kind === 'mob' && !e.dead && Math.hypot(e.x - p.x, e.y - p.y) < 9).sort((a, b) => Math.hypot(a.x - p.x, a.y - p.y) - Math.hypot(b.x - p.x, b.y - p.y));
  if (!list.length) { UI.log('Yakında hedef yok.'); return; }
  const i = list.indexOf(Game.target); setTarget(list[(i + 1) % list.length]); p.path = null;
  questFlag('cycleTarget');
}
function useSkill(i) {
  const P = Game.P, p = Game.player, C = CLS[P.cls], sk = C.skills[i]; if (!sk || sk.pas || p.dead) return;
  if (!skRank(sk)) { const L = skLock(sk); UI.log(L ? `${sk.name}: ${L[1]}` : 'Bu beceri henüz öğrenilmedi. Beceriler ekranından puan ver.'); return; }
  const K = k => skC(sk, k), s = stats();
  if (Game.gmNoCd) { p.cds = {}; p.mp = s.mp; }   // GM: beklemesiz + manasız
  if ((p.cds[sk.id] || 0) > 0) return;
  // Gölge Hükümdarı: şifa ve destek becerileri çalışmaz (orijinal)
  if ((sk.heal || (sk.buff && sk.sn !== 90613)) && p.buffs.some(b => b.buff.noHeal)) { UI.log(T_('Gölge Hükümdarı etkinken şifa ve destek becerileri çalışmaz.', 'Healing and support skills do not work during Shadow Sovereign.')); return; }
  // aç/kapa beceri (Kutsal Akış): etkinse kapanır
  if (sk.toggle && p.buffs.some(b => b.id === sk.id)) { p.buffs = p.buffs.filter(b => b.id !== sk.id); UI.log(`${sk.name}: ${T_('kapandı', 'off')}`); p.cds[sk.id] = sk.cd; return; }
  const arc = p.buffs.find(b => b.id === 'arcane');
  const mpCost = sk.mpPct ? Math.max(1, Math.round(p.mp * sk.mpPct(K) * (1 + (arc ? arc.n : 0)))) : sk.mp;   // Büyü Darbesi: mananın yüzdesi, her katta artar
  if (p.mp < mpCost) { UI.log('Mana yetersiz!'); return; }
  let t = Game.target && !Game.target.dead && Game.target.kind === 'mob' ? Game.target : null;
  const needT = sk.f && !sk.aoe;
  if (needT && !t) { t = nearestMob(8); if (t) setTarget(t, true); } else if (t) Game.engage = true;   // beceri kullanınca o hedefle dövüş sürer
  if (needT && !t) { UI.log('Hedef yok.'); return; }
  if (t && sk.range && Math.hypot(t.x - p.x, t.y - p.y) > sk.range + 0.3) { p.pending = i; p.path = null; return; }
  p.pending = null; p.mp -= mpCost; p.cds[sk.id] = sk.cd; p.combatT = 5; if (i === 0) p.atkT = Math.max(p.atkT, 0.9);
  if (t) p.dir = dirOf(t.x - p.x, t.y - p.y);
  p.state = C.melee && sk.f && (sk.range || 9) < 3 ? 'attack' : 'cast'; p.animT = 0; p.stateT = 0.5;
  SFX.play(sk.snd);
  const F = sk.f ? sk.f(K, s, p, t) || {} : {};
  const mobsNear = (x, y, r) => Game.ents.filter(m => m.kind === 'mob' && !m.dead && Math.hypot(m.x - x, m.y - y) <= r);
  const o = { crit: F.crit || 0, add: F.add || 0, slow: F.slow || sk.slow, pure: F.pure, bleed: F.bleed, burn: F.burn, freeze: F.freeze, stun: F.stun, critDmg: F.critDmg, onCrit: F.onCrit };
  const MUL = F.mult || 0;
  // vuruşun ardından: Çürüme bırakma, hayal totemi, Kan Damgası'nı yenileme, Büyü Darbesi katı; başka bir saldırı becerisi Büyü Darbesi etkisini tüketir
  const after = tg => {
    if (F.corrode && tg && !tg.dead) applyCorrosion(tg);
    if (F.phantom && tg) { if (Game.phantom && Game.phantom.fx) Game.phantom.fx.done = true; Game.phantom = { t: F.life, tick: 0, mult: F.phantom, tg, fx: phantomFx() }; }
    if (F.refresh) { const b = p.buffs.find(x => x.id === F.refresh); if (b) b.t = Math.max(b.t, typeof SKBYSN[90106].dur === 'number' ? SKBYSN[90106].dur : 10); }
    if (F.arcane) { const n = Math.min(3, (arc ? arc.n : 0) + 1); p.buffs = p.buffs.filter(b => b.id !== 'arcane'); p.buffs.push({ id: 'arcane', n, buff: { dmgUp: n * K('count_up_damage_rate') }, t: 3 }); }
    else if (arc && sk.f && (MUL || o.add)) p.buffs = p.buffs.filter(b => b !== arc);
  };
  // vuruş efekti: hitN kez hitR px içinde; birden çok mermide (projN) her mermi kendi payını patlatır
  const PN = sk.projN || 1, per = Math.ceil((sk.hitN || 1) / PN), hitFx = n => fxBurst(sk.hit || sk.fx, t.x, t.y, n, sk.hitR || 0);
  const land = () => {
    if (sk.snd2) SFX.play(sk.snd2);
    hitFx(per);
    if (sk.splash) { for (const m of mobsNear(t.x, t.y, sk.splash)) hitMob(m, MUL, o); }
    else if (MUL || o.add) hitMob(t, MUL, o);
    if (sk.fx2) Game.fx.push(new Fx(sk.fx2, t.x, t.y));
    if (sk.hits === 2) later(0.28, () => { if (!t.dead) { hitMob(t, F.mult2 != null ? F.mult2 : MUL, Object.assign({}, o, { add: F.mult2 != null ? 0 : o.add })); SFX.play(sk.snd); } });
    after(t);
  };
  // oyuncudaki efekt; yakın dövüşte kılıç izi saldırı hareketinin inişine denk gelsin diye 2 kare sonra (kılıç kalkarken değil)
  if (sk.self) fxBurst(sk.self, p.x, p.y, sk.selfN, sk.selfR, { dir: p.dir, delay: p.state === 'attack' ? 2 / TICK : 0 });
  later(0.25, () => {
    if (sk.proj && t) { shoot(sk.proj, p, t, land); for (let k = 1; k < PN; k++) later(k * 0.12, () => shoot(sk.proj, p, t, () => hitFx(Math.min(per, (sk.hitN || 1) - k * per)), true)); }
    else if (sk.aoe) {
      const near = mobsNear(p.x, p.y, sk.aoe); if (sk.fx) Game.fx.push(new Fx(sk.fx, p.x, p.y)); if (sk.snd2) SFX.play(sk.snd2);
      if (sk.totem) totemAt(sk.totem, p.x, p.y, F.weakT || 10);
      let dealt = 0;
      for (const m of near) {
        if (MUL || o.add) dealt += hitMob(m, MUL, o);
        if (F.weakDef) { m.weakT = F.weakT; m.weakDef = F.weakDef; }   // görseli süren zayıflatma (特效-抗性衰减buff)
      }
      if (F.novaHeal && dealt) healPlayer(dealt);   // Kutsal Nova: verilen hasar kadar can
      after(near[0]);
    }
    else if (sk.f) land();
    else if (sk.heal) { healPlayer(Math.round(sk.heal(K, s)), sk.fx); }
    else if (sk.buff) {
      const dur = typeof sk.dur === 'function' ? sk.dur(K) : sk.dur;
      const b = { id: sk.id, buff: sk.buff(K, s), t: dur }; if (sk.bfx) b.fx = sk.bfx;
      // Şifa Pınarı: pınar yere konur, yalnızca yanındayken iyileştirir (orijinal: çağrılan nesne 治疗之泉)
      if (sk.totem) { b.at = { x: p.x, y: p.y, r: 3 }; totemAt(sk.totem, p.x, p.y, dur); }
      p.buffs = p.buffs.filter(x => x.id !== sk.id); p.buffs.push(b);
      if (sk.fx) Game.fx.push(new Fx(sk.fx, p.x, p.y, { follow: p })); UI.log(`${sk.name} etkin.`); clampVitals();
    }
  });
  UI.refresh();
}
// şifa: Kana Hasret ile artar (alınan şifa); Gölge Hükümdarı sırasında şifa yok
function healPlayer(h, fx) {
  const p = Game.player, s = stats(); if (p.buffs.some(b => b.buff.noHeal)) return 0;
  h = Math.round(h * (1 + (s.healUp || 0) / 100)); p.hp = Math.min(s.hp, p.hp + h); UI.float(p, '+' + h, '#7bff8a'); if (fx) Game.fx.push(new Fx(fx, p.x, p.y, { follow: p })); return h;
}
// Çürüme (90314): 10 saniye, 2 saniyede bir; Can Sömürüsü (90316) payı ve can emme
function applyCorrosion(m) {
  const er = skRankSn(90316) ? R100(skCSn(90316, 'add_erosion_damage_rate')) : 0;
  m.dot = { n: 5, t: 2, mult: 0.1 * (1 + er), add: skCSn(90314, 'dur_dmg'), corr: 1, suck: skRankSn(90316) ? R100(skCSn(90316, 'suck_rate')) : 0 };
}
// Ağır Yarık (90116): Ölüm Kırımı (90120) can kaybıyla güçlendirir; kanamayı yutup kat başına ek hasar
function tearHit(K, s, p, t) {
  let mult = R100(K('phy_attack_factor'));
  if (skRankSn(90120)) mult *= 1 + R100(skCSn(90120, 'add_tisi_damage_rate')) * Math.floor((1 - p.hp / s.hp) * 10);
  if (t && t.bleed) { mult += 0.25 * t.bleed.n; if (!(skRankSn(90120) && Math.random() * 100 < skCSn(90120, 'not_del_bloodshed_buff_rate'))) t.bleed = null; }
  return { mult, add: K('add_phy_attack_value') };
}
// Gölge Yakışı (90318): İlahi Ceza (90323) çürümüş hedefe kritik şansı ve hasarı artırır, kritik çürümeyi yutar
function burnHit(K, t) {
  const o = { mult: 1, add: K('add_dark') };
  if (t && t.dot && t.dot.corr && skRankSn(90323)) Object.assign(o, { crit: skCSn(90323, 'fatal_rate'), critDmg: skCSn(90323, 'fatal_damage'), onCrit: m => { if (m.dot && m.dot.corr) m.dot = null; } });
  return o;
}
function shoot(name, from, to, cb, vis) {
  const f = new Fx(name, from.x, from.y, { z: 30 }); f.proj = { to, cb, sp: 9, vis }; f.loop = 1; Game.fx.push(f);
}
function nearestMob(r) { const p = Game.player; let best = null, bd = r; for (const e of Game.ents) if (e.kind === 'mob' && !e.dead) { const d = Math.hypot(e.x - p.x, e.y - p.y); if (d < bd) { bd = d; best = e; } } return best; }
const timers = [];
function later(s, fn) { timers.push({ t: s, fn }); }

// ---------------- Eşyalar ----------------
function addItem(id, n = 1, quiet) { const P = Game.P; const e = P.bag.find(b => b.id === id); if (e) e.n += n; else P.bag.push({ id, n }); if (!quiet) UI.log(`${ITEMS[id].name} ×${n}`, 'loot'); UI.refresh(); }
function countItem(id) { const e = Game.P.bag.find(b => b.id === id); return e ? e.n : 0; }
function removeItem(id, n = 1) { const P = Game.P, e = P.bag.find(b => b.id === id); if (!e || e.n < n) return false; e.n -= n; if (e.n <= 0) P.bag.splice(P.bag.indexOf(e), 1); UI.refresh(); return true; }
function useItem(id) {
  const it = ITEMS[id], p = Game.player, s = stats(); if (!it || !countItem(id) || p.dead) return;
  if (it.pet) return Pet.useItem(id);   // evcil hayvan eşyaları (pet.js)
  if (it.slot) return equip(id);
  if (it.use) {
    if (it.use.qt) return questUseItem(id);   // görev eşyası
    if (it.use.hp) { if (p.hp >= s.hp) return UI.log('Canın dolu.'); p.hp = Math.min(s.hp, p.hp + it.use.hp); UI.float(p, '+' + it.use.hp, '#7bff8a'); }
    if (it.use.mp) { if (p.mp >= s.mp) return UI.log('Manan dolu.'); p.mp = Math.min(s.mp, p.mp + it.use.mp); UI.float(p, '+' + it.use.mp, '#6fb7ff'); }
    for (const h of [it.use.hot, it.use.hot2]) if (h) { // yiyecek: süre boyunca yavaş yavaş yeniler (aynı türden yenisi eskisinin yerine geçer); hot2: can + mana birlikte
      const [res, amt, sec] = h, k = res === 'hp' ? 'hotT' : 'motT'; p.buffs = p.buffs.filter(b => !b.buff[k]);
      p.buffs.push({ id: 'food_' + res, buff: { [k]: amt / sec }, t: sec }); UI.float(p, it.name, res === 'hp' ? '#7bff8a' : '#6fb7ff', 0.8);
    }
    removeItem(id);
  } else if (it.growth) {
    const P = Game.P; removeItem(id);
    for (const g of NEWBIE[P.cls]) { const sl = ITEMS[g].slot; if (!P.eq[sl]) P.eq[sl] = g; else addItem(g, 1, true); }
    for (const [sl, g] of Object.entries(STARTER[P.cls])) if (!P.eq[sl]) P.eq[sl] = g;
    if (!P.eq.body) P.eq.body = STARTER_BODY[P.cls]; else addItem(STARTER_BODY[P.cls], 1, true);
    if (!P.eq.weap) P.eq.weap = STARTER_WEAP[P.cls]; else addItem(STARTER_WEAP[P.cls], 1, true);
    addItem('hp1', 10, true); addItem('mp1', 10, true);
    UI.toast('Gelişim Paketi açıldı! Yeni ekipmanını kuşandın.'); refreshLook();
  }
}
function refreshLook() { Game.player.doll.set(look()); Assets.preload([]); UI.refresh(); save(); }

// ---------------- Görevler ----------------
const QBY = Object.fromEntries(QUESTS.map(q => [q.id, q]));
// q.race: yalnızca o ırk; q.req: tek kimlik ya da "herhangi biri" listesi
function questState(q) { const P = Game.P; if (P.done[q.id]) return 'done'; if (P.quests[q.id]) return P.quests[q.id].ready || (q.type === 'deliver' && giveCount(q) >= q.count) ? 'ready' : 'active'; if ((q.race && q.race !== P.race) || (q.cls && q.cls !== P.cls)) return 'locked';
  if (q.req && !(Array.isArray(q.req) ? q.req.some(r => P.done[r]) : P.done[q.req])) return 'locked'; if (q.advMin && (P.adv || 0) !== q.advMin) return 'locked'; if (P.lv < questMinLv(q)) return 'soon'; return 'new'; }
// ---------------- Görevlerin seviye şartı ----------------
// Orijinal istemci seviye şartını taşımaz (sunucudaydı); şart orijinal verilerden türetilir:
//  1) hedef canavarın yaşadığı haritanın seviye aralığının alt sınırı - 1 (aralıklar dünya haritası tablosundan),
//  2) hedefi olmayan (konuşma, teslim) görev: zincirde kendinden sonra gelen ilk savaş görevinin şartı; yoksa veren NPC'nin haritası,
//  3) bir görev, zincirde kendinden önceki görevden daha düşük seviyede açılmaz.
let NPC_SC = null, MON_SC = null;
function sceneIndex() {
  if (NPC_SC) return; NPC_SC = {}; MON_SC = {}; const S = Assets.D.scenes;
  for (const [sid, s] of Object.entries(S)) for (const e of s.ents) { const M = Assets.D.mon[e[0]] ? MON_SC : NPC_SC; (M[e[1]] || (M[e[1]] = [])).push(sid); }
}
const zoneMin = sids => { let m = null; for (const sid of sids || []) { const r = Assets.D.scenes[sid].lvr; if (r && (m == null || r[0] < m)) m = r[0]; } return m; };
// bir haritanın görev seviyesi: aralığın alt sınırı - 1; başlangıç kampları (aralıksız) 1
function sceneQLv(sid) { const s = Assets.D.scenes[sid], r = s && s.lvr; return r ? Math.max(1, r[0] - 1) : s && s.kind && s.kind[0] === 3 ? 1 : s && s.lv ? Math.max(1, s.lv - 1) : null; }
function questOwnLv(q) {
  sceneIndex(); if (!q.target && !q.node) return null;
  const T = q.target ? (MON_SC[q.target] || []) : (NPC_SC[q.node] || MON_SC[q.node] || []), G = NPC_SC[q.giver] || [], S = Assets.D.scenes;
  // hedefin, görevi verenin haritasında ya da ona komşu haritalarda yaşadığı yer önce gelir (aynı canavar başka bölgelerde de olabilir)
  const near = new Set(G); for (const g of G) for (const e of S[g].exits) if (e[2]) near.add(e[2]);
  const pick = L => { let m = null; for (const sid of L) { const v = sceneQLv(sid); if (v != null && (m == null || v < m)) m = v; } return m; };
  const a = pick(T.filter(s => near.has(s))); return a != null ? a : pick(T);
}
let QNEXT = null, HUBLV = null;
// şehirde (seviye aralığı olmayan harita) duran kişinin görev seviyesi: aynı şehirde verilen savaş görevlerinin en düşüğü
function hubLv(giver) {
  sceneIndex();
  if (!HUBLV) { HUBLV = {}; for (const x of QUESTS) { const o = questOwnLv(x); if (o == null) continue; for (const sid of NPC_SC[x.giver] || []) if (HUBLV[sid] == null || o < HUBLV[sid]) HUBLV[sid] = o; } }
  let m = null; for (const sid of NPC_SC[giver] || []) if (HUBLV[sid] != null && (m == null || HUBLV[sid] < m)) m = HUBLV[sid];
  return m != null ? m : 1;
}
function questMinLv(q) {
  if (q._lv != null) return q._lv;
  if (q.lvAt) return q._lv = q.lvAt;   // kesin açılma seviyesi (sınıf görevleri: orijinalde 40; hedef haritası daha yüksek olsa da)
  q._lv = 1;   // döngü koruması
  if (!QNEXT) { QNEXT = {}; for (const x of QUESTS) for (const r of [].concat(x.req || [])) (QNEXT[r] || (QNEXT[r] = [])).push(x); }
  let lv = questOwnLv(q);
  const pre = [].concat(q.req || []).map(r => QBY[r]).filter(Boolean).map(questMinLv), preLv = pre.length ? Math.min(...pre) : null;
  if (lv == null && preLv != null) lv = preLv;   // hedefsiz ara adım: önceki görev biter bitmez açılır
  if (lv == null) { // ileriye bak: zincirdeki ilk savaş görevi
    const seen = new Set(); let front = [q];
    for (let d = 0; d < 6 && lv == null && front.length; d++) { const nx = []; for (const x of front) for (const y of QNEXT[x.id] || []) if (!seen.has(y.id)) { seen.add(y.id); const o = questOwnLv(y); if (o != null) lv = lv == null ? o : Math.min(lv, o); nx.push(y); } front = nx; }
  }
  if (lv == null) { sceneIndex(); const z = zoneMin(NPC_SC[q.giver]); lv = q.lv0 || (z != null ? Math.max(1, z - 1) : hubLv(q.giver)); }
  // önceki görev: tek kimlikse onun seviyesi; "herhangi biri" listesiyse (ırklara göre ayrı yollar) en düşüğü
  if (preLv != null) lv = Math.max(lv, preLv);
  if (q.lvMin) lv = Math.max(lv, q.lvMin);   // bölge dosyasında elle verilen en düşük seviye
  return q._lv = lv;
}
// seviye atlayınca açılan görevler
function questsUnlockedAt(lv) { return QUESTS.filter(q => questMinLv(q) === lv && questState(q) === 'new'); }
// bir NPC'nin bulunduğu haritalardan, buradan yürüyerek en kısa yoldan varılanı
function npcSceneNear(cn) {
  sceneIndex(); const L = NPC_SC[cn] || []; if (L.includes(Game.sceneId)) return Game.sceneId;
  let best = null, bl = 1e9; for (const sid of L) { const p = scenePath(Game.sceneId, sid); if (p && p.length < bl) { bl = p.length; best = sid; } } return best || L[0] || null;
}
function monSceneNear(name, scName) {   // scName: görevde yazan harita adı (q.sc) varsa o adlı haritalar öncelikli
  sceneIndex(); let L = MON_SC[name] || []; if (scName) { const F = L.filter(sid => Assets.D.scenes[sid].name === scName); if (F.length) L = F; } if (L.includes(Game.sceneId)) return Game.sceneId;
  let best = null, bl = 1e9; for (const sid of L) { const p = scenePath(Game.sceneId, sid); if (p && p.length < bl) { bl = p.length; best = sid; } } return best || L[0] || null;
}
// bir kişiye git: başka haritadaysa geçitlerden yürür, varınca kişiye yürür
function routeToNpc(cn) {
  const sid = npcSceneNear(cn); if (!sid) return UI.toast('Bu kişinin yeri bilinmiyor.');
  if (sid === Game.sceneId) { const e = Game.ents.find(e => e.cn === cn); if (e) return walkToEnt(e); return; }
  Game.routeNpc = cn; Game.routeQuest = null; routeTo(sid);
}
// ışınlanma görevi: q.tp = [sahne, x, y]; gidilen yer "ev" olur (ölünce orada doğulur)
function questTeleport(q) { const P = Game.P; P.home = q.tp.slice(); save(); gotoScene(q.tp[0], null, q.tp[1] != null ? [q.tp[1], q.tp[2]] : null); }
const tpQuestOf = cn => QUESTS.find(q => q.tp && q.giver === cn && (Game.P.quests[q.id] || Game.P.done[q.id]));
function questsFor(cn) { return QUESTS.filter(q => (q.giver === cn && questState(q) === 'new') || (q.to === cn && questState(q) === 'ready') || ((q.to === cn || q.giver === cn) && questState(q) === 'active')); }
function npcMark(cn) {
  if (QUESTS.some(q => q.to === cn && questState(q) === 'ready')) return '?';
  if (QUESTS.some(q => q.giver === cn && questState(q) === 'new')) return '!';
  return '';
}
// teslim görevi: çantadaki eşyalar (q.give kimlikleri) sayılır, tamamlanınca alınır
const giveCount = q => (q.give || []).reduce((a, id) => a + countItem(id), 0);
function takeGive(q) { let n = q.count; for (const id of q.give || []) { const k = Math.min(n, countItem(id)); if (k) { removeItem(id, k); n -= k; } } }
// ödülü olmayan görevlere (orijinal kaydı olmayan; şu an yok) yedek ödül formülü. Asıl ödüller orijinal (aşağıda q.rw).
// Deneyim dengesi: görevler gereken deneyimin ~%40'ını, canavarlar ~%60'ını verir (XPT/MXPT, tools/deneyim_tablosu.py). Ölçüm: GRIND=1 tools/test/denge.js
const QXP_F = L => clamp(1.2 - L / 40, 0.3, 1);
for (const q of QUESTS) if (!q.reward) { const L = q.lv || (MON[q.target] && MON[q.target].lv) || 3, mx = (MON[q.target] && MON[q.target].xp) || 20;
  q.reward = q.type === 'kill' || q.type === 'collect' ? { xp: Math.round(((q.count || 1) * mx * 1.6 + 60 * L) * QXP_F(L)), gold: 10 + L * 6 } : { xp: Math.round((80 + 50 * L) * QXP_F(L)), gold: 8 + L * 4 }; }
// orijinal tablodaki altın ve eşya ödülü (tools/gorevler.py)
// orijinal deneyim, altın ve eşya ödülü (Symbian ham kaydı, tools/gorev_ham.py → quests_gen.js QRW); eşyanın 3. öğesi sınıf: yalnız o sınıfa verilir
for (const q of QUESTS) if (q.rw) { q.reward.xp = q.rw.xp; q.reward.gold = q.rw.gold; q.reward.items = q.rw.items || []; }   // deneyim de orijinal (kullanıcı kararı 16.11)
const rewardItems = q => (q.reward.items || []).filter(([id, , c]) => ITEMS[id] && (!c || [].concat(c).includes(Game.P.cls)));
// görev alınınca: accItems görev eşyası çantaya konur (ör. Büyü Emici Küre)
function acceptQuest(q) { const P = Game.P; P.quests[q.id] = { n: 0, ready: q.type === 'talk' }; for (const [id, n] of q.accItems || []) if (!countItem(id)) addItem(id, n); if (q.type === 'special' && Game.flags[q.flag]) P.quests[q.id].ready = true; UI.log(`Görev alındı: ${q.title}`, 'q'); SFX.play('accept_task'); UI.refresh(); save(); }
function questKill(name) {
  const P = Game.P;
  for (const q of QUESTS) {
    const st = P.quests[q.id]; if (!st || st.ready) continue;
    if (q.type === 'kill' && q.targets) {   // çok hedefli: her hedefin kendi sayacı, toplam st.n (türler: tgKey üstünde)
      for (const x of q.targets) { if (x[0] !== name || x[2] === 'node' || x[2] === 'use') continue;
        if (typeof x[2] === 'number') { if (Math.random() < x[2]) tgAdd(q, st, x); continue; }   // canavardan düşen eşya
        // önce görev eşyası kullanılmalıysa (Büyü Emici Küre) kullanılmadan öldürmek sayılmaz
        const use = q.targets.find(y => y[0] === name && y[2] === 'use' && ((st.c || {})[tgKey(y)] || 0) < y[1]);
        if (use) { UI.log(T_(`Önce ${trName(use[3])} kullanılmalıydı.`, `You had to use the ${trName(use[3])} first.`), 'q'); continue; }
        tgAdd(q, st, x); }
      continue;
    }
    if (q.type === 'collect' && q.drops) {   // çok eşyalı toplama: q.mobs'tan biri her öldürmede eksik eşyaların her biri için şans
      if (!(q.mobs || [q.target]).includes(name)) continue; st.c = st.c || {};
      q.drops.forEach(([n, ch, nm], i) => { const k = 'd' + i; if ((st.c[k] || 0) < n && Math.random() < ch) { st.c[k] = (st.c[k] || 0) + 1; st.n = (st.n || 0) + 1; UI.log(`${nm} ${st.c[k]}/${n}`, 'loot'); } });
      if (q.drops.every(([n], i) => (st.c['d' + i] || 0) >= n)) readyQuest(q); UI.refresh(); continue;
    }
    if (q.type === 'kill' && q.target === name) { st.n++; if (st.n >= q.count) readyQuest(q); UI.refresh(); }
    if (q.type === 'collect' && q.target === name && Math.random() < q.chance) { st.n++; UI.log(`${q.item} ${st.n}/${q.count}`, 'loot'); if (st.n >= q.count) readyQuest(q); UI.refresh(); }
  }
}
// Çok hedefli görevin hedef türleri (q.targets): [canavar, adet] öldür; [canavar, adet, şans, eşya] canavardan düşen eşya; [nesne, adet, 'node', eşya]
// yerdeki nesneden alınır (sandık); [canavar, adet, 'use', eşya, eşyaNo] çantadaki görev eşyası o canavar hedefteyken kullanılır. Sayaç anahtarı: eşya adı ya da canavar.
const tgKey = x => x[3] || x[0];
function tgAdd(q, st, x) {
  const k = tgKey(x); st.c = st.c || {}; if ((st.c[k] || 0) >= x[1]) return false;
  st.c[k] = (st.c[k] || 0) + 1; st.n = (st.n || 0) + 1; UI.log(`${trName(k)} ${st.c[k]}/${x[1]}`, 'loot');
  if (q.targets.every(y => (st.c[tgKey(y)] || 0) >= y[1])) readyQuest(q); UI.refresh(); return true;
}
// görev eşyasını kullan (Büyü Emici Küre): hedefteki canavar görevin 'use' hedefi olmalı ve yakında
function questUseItem(id) {
  const P = Game.P, p = Game.player, t = Game.target;
  for (const q of QUESTS) { const st = P.quests[q.id]; if (!st || st.ready || !q.targets) continue;
    const x = q.targets.find(y => y[2] === 'use' && y[4] === id); if (!x || ((st.c || {})[tgKey(x)] || 0) >= x[1]) continue;
    if (!t || t.dead || t.name !== x[0]) return UI.toast(T_(`Önce ${trName(x[0])} hedef al.`, `Target ${trName(x[0])} first.`));
    if (Math.hypot(t.x - p.x, t.y - p.y) > 6) return UI.toast(T_('Çok uzak.', 'Too far away.'));
    Game.fx.push(new Fx('特效-治疗buff', t.x, t.y, { follow: t })); SFX.play('skill_juqi'); removeItem(id); tgAdd(q, st, x); return;
  }
  UI.toast(T_('Bunu şimdi kullanamazsın.', 'You cannot use this now.'));
}
function questFlag(f) { Game.flags[f] = true; for (const q of QUESTS) { const st = Game.P.quests[q.id]; if (st && !st.ready && q.type === 'special' && q.flag === f) readyQuest(q); } }
function readyQuest(q) { Game.P.quests[q.id].ready = true; SFX.play('message'); UI.toast(`Görev tamamlandı: ${q.title}`); UI.log(`${q.title} tamam. ${trName(q.to)} ile konuş.`, 'q'); }
function completeQuest(q) {
  if (q.type === 'deliver') { if (giveCount(q) < q.count) return UI.toast(`${q.item}: ${giveCount(q)}/${q.count}`); takeGive(q); }
  const P = Game.P, r = q.reward; delete P.quests[q.id]; P.done[q.id] = true; SFX.play('finish_task');
  if (r.gold) P.gold += Math.round(r.gold * (1 + (stats().goldUp || 0) / 100)); for (const [id, n] of rewardItems(q)) addItem(id, n);
  gainXp(r.xp || 0); if (r.xp || r.gold) UI.log(`Ödül: ${r.xp} TP${r.gold ? ', ' + r.gold + ' altın' : ''}`, 'q');
  if (q.adv) classUp(q.adv);
  UI.refresh(); save();
}
// ---------------- Sınıf yükseltme (orijinal 40. seviye görevleri: sinif.json; 80'deki uzmanlık kapsam dışı) ----------------
function classUp(n) {
  const P = Game.P; if ((P.adv || 0) >= n) return; P.adv = n;
  Game.fx.push(new Fx('LEVELUP', Game.player.x, Game.player.y)); SFX.play('levelup');
  UI.toast(`${tx('Sınıf yükseltildi')}: ${clsName()}`); UI.log(`${tx('Sınıf yükseltildi')}: ${clsName()} · ${tx(n >= 2 ? 'uzmanlık ağaçları açıldı' : 'sınıf beceri ağacı açıldı')}`, 'q');
  UI.refresh(); save();
}
// seviyesi gelince kendiliğinden alınan görevler (orijinalde verensiz "gönderilen" görev: 80344 Acemilikten Çıkış)
function autoQuests() { for (const q of QUESTS) if (q.auto && questState(q) === 'new') { acceptQuest(q); UI.toast(`${tx('Yeni görev')}: ${q.title}`); } }
// GM: sınıf yükseltme (GM paneli › Sınıf; tools/test/sinif.js)
const ClassGM = {
  chain() { const P = Game.P; return QUESTS.filter(q => (q.cls === P.cls && (!q.race || q.race === P.race) && q.lvMin >= 40) || q.id === 80344).sort((a, b) => (a.id === 80344 ? -1 : b.id === 80344 ? 1 : 0) || (a.lvMin || 0) - (b.lvMin || 0) || chainDepth(a) - chainDepth(b)); },
  up() { classUp(1); },
  up2() { classUp(1); classUp(2); },   // 80: ikinci sınıf yükseltmesi (uzmanlık ağaçları; görevleri Bozbalta Şehri'nde)
  start80() { const P = Game.P; if (P.lv < 80) gmLevel(80); classUp(1); gotoScene('120156', null, [50, 39]); },   // 80 yap + Bozbalta'ya ışınla
  reset() { const P = Game.P; P.adv = 0; fixSkills(P); for (const q of this.chain()) { delete P.quests[q.id]; delete P.done[q.id]; } UI.refresh(); save(); },
  resetPts() { skillReset(true); },
  // ağaçları doldur: seviyeyi en az 80 yap, iki yükseltme, puanları oyuncu gibi dağıt; spec: 0 = ilk uzmanlık, 1 = ikinci
  fill(spec = 0) { const P = Game.P; if (P.lv < 80) gmLevel(80); classUp(1); classUp(2); P.sk = {}; P.sp = 0; skillAutoSpend(P.lv + 1, spec); UI.refresh(); save(); },
  start() { const P = Game.P; if (P.lv < 40) gmLevel(40); autoQuests(); UI.refresh(); },
  ready(id) { const q = QBY[id], P = Game.P; if (!q || P.done[id]) return; for (let r = q.req; r && !P.done[r]; r = QBY[r] && QBY[r].req) { P.done[r] = true; delete P.quests[r]; } if (!P.quests[id]) acceptQuest(q); readyQuest(q); save(); },
  done(id) { const q = QBY[id]; if (!q || Game.P.done[id]) return; this.ready(id); if (q.type === 'deliver') return; completeQuest(q); },
  // efekt denemesi: yanına ölmeyen, saldırmayan kukla canavar; beklemesiz + manasız beceri (aç/kapa)
  dummy() { const p = Game.player; Game.ents = Game.ents.filter(e => !e.gmDummy); const m = new Mob('☆水仙子', p.x + 1.5, p.y); m.hp = m.maxHp = 1e9; m.gmDummy = 1; m.home = { x: m.x, y: m.y }; Game.ents.push(m); setTarget(m, true); },
  nocd() { Game.gmNoCd = !Game.gmNoCd; UI.toast(Game.gmNoCd ? T_('Beklemesiz beceri: açık', 'No cooldown: on') : T_('Beklemesiz beceri: kapalı', 'No cooldown: off')); },
};
// Ozan (金波港): 40'ta sınıf yükseltme görevlerini dağıtır (80344 metni)
// Ozan'ın 80 için anlattıkları (orijinal 吟游诗人 kaydı: 80 öncesi, savaşçı / büyücü / elçi)
const BARD80 = LANG === 'en' ? {
  soon: 'If you want greater power, you must reach level 80; only then can you touch the secrets of the higher classes.',
  '战士': 'I can feel the fierce killing intent on your weapon from far away, my brave warrior. When you reach level 80 your strength will touch an unprecedented peak. Then find the Black Knight Commander in Greyaxe City, accept the trial to become a Black Knight and pursue even greater power!',
  '法师': 'I can see you growing, my child; your potential goes beyond the limits of an ordinary mage. When you reach level 80, go to Greyaxe City: the Grand Magister Guide will guide you better. Becoming a Grand Magister is your true destiny.',
  '牧师': "As a priest, your deeds have won everyone's approval, but what a priest truly seeks is the approval of the god. When you reach level 80, the Devout Chosen may lead you onto the path of the god; the Devout Chosen waits in Greyaxe City to choose the god's envoys." } : {
  soon: 'Daha büyük güç istiyorsan 80. seviyeye ulaşmalısın; ancak o zaman üst sınıfların sırlarına erişebilirsin.',
  '战士': "Silahındaki o korkunç öldürme hırsını çok uzaktan bile hissedebiliyorum, cesur savaşçım. 80. seviyeye ulaştığında gücün daha önce hiç görülmemiş bir doruğa varacak. O zaman Bozbalta Şehri'ndeki Kara Şövalye Komutanı'nı bul, Kara Şövalye olma sınavını kabul et ve daha büyük gücün peşine düş!",
  '法师': "Büyüdüğünü görüyorum, çocuğum; potansiyelin sıradan bir büyücünün sınırlarını aşıyor. 80. seviyeye ulaştığında Bozbalta Şehri'ne git; Büyük Büyü Üstadı Rehberi sana daha iyi yol gösterecek. Büyük Büyü Üstadı olmak, senin asıl yazgın.",
  '牧师': "Bir kutsal elçi olarak yaptıkların herkesçe takdir edildi; ama bir kutsal elçinin asıl aradığı, tanrının onayıdır. 80. seviyeye ulaştığında Dindar Seçilmiş seni tanrının yoluna götürebilir; Dindar Seçilmiş, tanrının elçilerini seçmek için Bozbalta Şehri'nde bekliyor." };
TR.greet['吟游诗人'] = LANG === 'en' ? 'My songs tell the tales of many heroes. When you reach level 40, come to me and I will tell you how to become a true warrior, mage or priest.'
  : 'Şarkılarım nice kahramanın hikâyesini anlatır. 40. seviyeye gelince bana uğra; gerçek bir savaşçı, büyücü ya da kutsal elçi olmanın yolunu anlatayım.';
function chainDepth(q) { let d = 0; for (let r = q.req; r && d < 20; r = QBY[r] && QBY[r].req) d++; return d; }
// Görev hedefine otomatik yürü (orijinaldeki "寻路"): teslim edilecek kişi, toplama noktası ya da en yakın hedef canavar
// ---------------- GM (oyun yöneticisi) ----------------
// Çevrimdışı: adı "GM" ile başlayan karakter. Çevrimiçi: sunucuda yönetici yetkisi olan hesap (node make-admin.js <kullanıcı>).
function isGM() { const P = Game.P; return !!P && (Net.on ? Net.admin : /^GM/i.test(P.name || '')); }
function gmLevel(lv) {
  const P = Game.P, n = clamp(Math.round(lv), 1, 120), d = n - P.lv; P.lv = n; P.xp = 0; if (d > 0) P.sp = (P.sp || 0) + d;
  const s = stats(); Game.player.hp = s.hp; Game.player.mp = s.mp; UI.levelUp(n); UI.refresh(); save();
}
// seviyeye uygun en iyi ekipmanı giydirir (dükkân listelerindeki orijinal eşyalar)
function gmGear() {
  const P = Game.P;
  for (const [sl] of SLOTS) { let best = null; for (const [id, it] of Object.entries(ITEMS)) if (it.slot === sl && (!it.cls || it.cls === P.cls) && it.lv <= P.lv && (!best || it.lv > ITEMS[best].lv)) best = id; if (best) P.eq[sl] = best; }
  refreshLook(); const s = stats(); Game.player.hp = s.hp; Game.player.mp = s.mp;
}
function gmHeal() { const s = stats(), p = Game.player; p.hp = s.hp; p.mp = s.mp; if (p.dead) { p.dead = false; p.state = 'idle'; } }
// ---------------- Otomatik yol: haritalar arası geçitlerden hedef haritaya yürür ----------------
function routeTo(sid) {
  if (sid === Game.sceneId) return UI.toast('Zaten buradasın.');
  if (!routePath(Game.sceneId, sid)) { if (isGM()) { Game.route = null; return gotoScene(sid, null, null, null); } return UI.toast('Buradan oraya yürüyerek gidilemiyor.'); }
  Game.route = sid; routeStep();
}
// geçit bağlantıları üzerinde en kısa sahne zinciri; tv: arabacı/ışınlayıcı yolculukları da kullanılır
function scenePath(from, to, tv) {
  const S = Assets.D.scenes, prev = { [from]: null }, q = [from];
  while (q.length) { const c = q.shift(); if (c === to) { const out = []; for (let x = to; x; x = prev[x]) out.unshift(x); return out; }
    for (const e of S[c].exits) if (e[2] && S[e[2]] && !(e[2] in prev)) { prev[e[2]] = c; q.push(e[2]); }
    if (tv) for (const t of travelEdges(c)) for (const o of t.L) if (S[o[2]] && !(o[2] in prev)) { prev[o[2]] = c; q.push(o[2]); } }
  return null;
}
// önce yürüyerek; yürüyerek gidilemiyorsa yolculuk NPC'leriyle (Bozbalta Şehri gibi ayrı bölgeler)
const routePath = (from, to) => scenePath(from, to) || scenePath(from, to, true);
// ---------------- Yolculuk: arabacılar ve ışınlayıcılar ----------------
// Orijinal NPC seçenekleri (www/assets/travel.json ← tools/seyahat.py): arabacı (驿站老板 / 盲眼向导) 100 altın, ışınlayıcı (传送法阵,
// 风暴法师, 首席大法师 …) ücretsiz; NPC → [[tür, şehir adı, hedef sahne, varış x, y]]. GM: ücretsiz yolculuk (Game.gmFreeTravel).
let TRAVEL = { npc: {}, cost: {}, ucret: {} }, TRAVEL_SC = null;
async function loadTravel() { try { TRAVEL = await fetch(vq(Assets.base + 'travel.json')).then(r => r.json()); } catch (e) { console.warn('travel.json', e); } }
const travelOf = n => (n && TRAVEL.npc[n.id]) || null;
const travelCost = (n, x) => Game.gmFreeTravel ? 0 : x[0] === 'araba' ? (TRAVEL.cost.araba || 100) : (TRAVEL.ucret[n.cn] || 0);
function travelLabel(n, x) { const c = travelCost(n, x), nm = trName(x[1]); return (x[0] === 'tp' ? T_('Işınlan: ', 'Teleport: ') : T_('Yolculuk: ', 'Travel: ')) + nm + (c ? T_(` (${c} altın)`, ` (${c} gold)`) : ''); }
function travelGo(n, x) {
  const P = Game.P, c = travelCost(n, x);
  if (c && P.gold < c) return UI.toast(T_(`${c} altın gerekir.`, `Requires ${c} gold.`));
  P.gold -= c; UI.log(travelLabel(n, x), 'q'); Game.travelHint = null; SFX.play('menusel', 0.6);
  UI.closeAll(); setTimeout(() => gotoScene(x[2], null, x[3] != null ? [x[3], x[4]] : null), 300);
}
// sahnedeki yolculuk NPC'leri (yol bulma)
function travelEdges(sid) {
  if (!TRAVEL_SC) { TRAVEL_SC = {}; for (const [s, sc] of Object.entries(Assets.D.scenes)) for (const e of sc.ents) { const L = TRAVEL.npc[e[0]]; if (L) (TRAVEL_SC[s] || (TRAVEL_SC[s] = [])).push({ id: String(e[0]), cn: e[1], L }); } }
  return TRAVEL_SC[sid] || [];
}
function routeStep() {
  const to = Game.route; if (!to || !Game.player) return;
  if (to === Game.sceneId) { Game.route = null; const rq = Game.routeQuest && QUESTS.find(x => x.id === Game.routeQuest); Game.routeQuest = null; if (rq && Game.P.quests[rq.id]) return questWalk(rq); const cn = Game.routeNpc; Game.routeNpc = null; if (cn) { const e = Game.ents.find(e => e.cn === cn); if (e) return walkToEnt(e); } return UI.toast('Hedefe vardın.'); }
  const path = routePath(Game.sceneId, to), ex = path && Game.scene.exits.find(e => e[2] === path[1]), r = ex && Game.map.regionsOf(1).find(g => g[0] === ex[0]);
  if (path && !ex) {   // sıradaki adım yolculuk: o hedefe giden arabacıya/ışınlayıcıya yürü, konuşunca hedef en üstte çıkar
    const n = Game.ents.find(e => e.kind === 'npc' && (travelOf(e) || []).some(x => x[2] === path[1]));
    if (n) { Game.travelHint = path[1]; UI.toast(T_(`${trName(n.cn)} ile yolculuk: ${trName(Assets.D.scenes[path[1]].name)}`, `Travel with ${trName(n.cn)}: ${trName(Assets.D.scenes[path[1]].name)}`)); return walkToEnt(n); }
  }
  if (!r) { Game.route = null; return UI.toast('Yol bulunamadı.'); }
  const p = Game.player; let best = null;
  for (let y = r[3]; y <= r[5]; y++) for (let x = r[2]; x <= r[4]; x++) if (!Game.map.blocked(x, y)) { const d = Math.hypot(x - p.x, y - p.y); if (!best || d < best[2]) best = [x, y, d]; }
  const path2 = best && findPath(Game.map, p.x, p.y, best[0], best[1]);
  if (!path2) { Game.route = null; return UI.toast('Yol bulunamadı.'); }
  p.path = path2; Game.goTarget = null; setTarget(null);
}
// bu haritadaki bir NPC'ye yürü (harita penceresindeki NPC listesi)
function walkToEnt(t) { const p = Game.player; p.path = findPath(Game.map, p.x, p.y, t.x, t.y + 1); Game.goTarget = t; setTarget(null); if (!p.path) UI.toast('Oraya yol bulunamadı.'); }
// Görev yol bulma (orijinaldeki "寻路"), görevin durumuna göre:
//  alınmamış → görevi veren; hazır (ya da konuş/teslim/özel görev) → ödülü veren kişi (q.to);
//  öldür/topla → hedef canavar (bu haritada yaşayan varsa yanına yürüyüp seçer, saldırmaz; hepsi ölüyse doğdukları yere yürür, yoksa canavarın haritasına — q.sc öncelikli);
//  nesne toplama → nesne (bu haritada yoksa nesnenin haritasına). Başka haritaya gidilince varışta görev yürüyüşü kendiliğinden sürer (Game.routeQuest).
function questWalk(q) {
  const p = Game.player, st = Game.P.quests[q.id], near = f => { let b = null, bd = 1e9; for (const e of Game.ents) if (f(e)) { const d = Math.hypot(e.x - p.x, e.y - p.y); if (d < bd) { bd = d; b = e; } } return b; };
  const goNpc = cn => { const e = near(e => e.kind === 'npc' && e.cn === cn && !e.hidden); if (e) return walkToEnt(e); return routeToNpc(cn); };
  const away = sid => { Game.routeNpc = null; Game.routeQuest = q.id; routeTo(sid); };
  if (!st) return goNpc(q.giver);
  if (st.ready || !['kill', 'collect', 'pickup'].includes(q.type)) return goNpc(q.to);
  if (q.type === 'pickup') {
    const n = near(e => e.kind === 'npc' && e.cn === q.node && !e.hidden) || near(e => e.kind === 'npc' && e.cn === q.node);
    if (n) return walkToEnt(n);
    const sid = npcSceneNear(q.node); if (sid && sid !== Game.sceneId) return away(sid);
    UI.toast('Toplanacak yer bilinmiyor.'); return goNpc(q.to);
  }
  const rem = q.targets && q.targets.filter(x => ((st.c || {})[tgKey(x)] || 0) < x[1]);
  // geriye yalnız yerdeki nesne kaldıysa (sandık) ona yürü
  if (rem && rem.length && rem.every(x => x[2] === 'node')) { const n = near(e => e.kind === 'npc' && e.cn === rem[0][0] && !e.hidden); if (n) return walkToEnt(n); const sid = npcSceneNear(rem[0][0]); if (sid && sid !== Game.sceneId) return away(sid); }
  const names = rem ? [...new Set(rem.filter(x => x[2] !== 'node').map(x => x[0]))] : q.mobs || [q.target];
  const t = near(e => e.kind === 'mob' && !e.dead && names.includes(e.name));
  if (t) { p.path = findPath(Game.map, p.x, p.y, t.x, t.y + 1); Game.goTarget = null; setTarget(t); return; }   // canavarın yanına yürür ve seçer; saldırmaz (kullanıcı isteği)
  const spot = near(e => e.kind === 'mob' && names.includes(e.name));   // hepsi ölü: yeniden doğdukları yere yürü
  if (spot) { p.path = findPath(Game.map, p.x, p.y, spot.x, spot.y + 1); Game.goTarget = null; setTarget(null); UI.toast('Canavarlar yeniden doğuyor; doğdukları yere gidiliyor.'); return; }
  let best = null, bl = 1e9;
  for (const n of names) { const sid = monSceneNear(n, q.sc); const L = sid && scenePath(Game.sceneId, sid); const l = L ? L.length : 1e8; if (sid && l < bl) { bl = l; best = sid; } }
  if (best && best !== Game.sceneId) return away(best);
  UI.toast('Hedef canavarın yeri bilinmiyor.');
}
function pickupNode(n) {
  const P = Game.P;
  // çok hedefli görevdeki sandık (Tozlu Büyü İletken Kristal Sandık): açılınca eşya sayılır
  for (const q2 of QUESTS) { const st = P.quests[q2.id]; if (!st || st.ready || !q2.targets) continue;
    const x = q2.targets.find(y => y[2] === 'node' && y[0] === n.cn); if (!x || ((st.c || {})[tgKey(x)] || 0) >= x[1]) continue;
    SFX.play('coin', 0.7); tgAdd(q2, st, x); n.hidden = true; n.respawnT = 20; return; }
  const q = QUESTS.find(q => q.type === 'pickup' && q.node === n.cn && P.quests[q.id] && !P.quests[q.id].ready);
  if (!q) { UI.say(n, TR.greet[n.cn] || '...'); return; }
  const st = P.quests[q.id]; st.n++; UI.log(`${q.item} ${st.n}/${q.count}`, 'loot');
  n.hidden = true; n.respawnT = 20; if (st.n >= q.count) readyQuest(q); UI.refresh();
}

// ---------------- Güncelleme ----------------
function moveEnt(e, dx, dy) {
  const m = Game.map;
  if (!m.blocked(e.x + dx, e.y)) e.x += dx; else if (!m.blocked(e.x + dx, Math.round(e.y))) e.x += dx;
  if (!m.blocked(e.x, e.y + dy)) e.y += dy;
}
// Hedefe yalnızca 4 yönde ilerle: önce bir eksen, sonra diğeri (L biçiminde)
function stepTo(e, tx, ty, sp, dt) {
  const dx = tx - e.x, dy = ty - e.y, eps = 0.04;
  if (Math.abs(dx) <= eps && Math.abs(dy) <= eps) { if (!Game.map.blocked(tx, ty)) { e.x = tx; e.y = ty; } return true; }
  // eldeki eksende kalan yol bitene kadar o eksende kal; yoksa uzun olanı seç
  if (e.ax === 'x' && Math.abs(dx) <= eps) e.ax = null; if (e.ax === 'y' && Math.abs(dy) <= eps) e.ax = null;
  if (!e.ax) e.ax = Math.abs(dx) >= Math.abs(dy) ? 'x' : 'y';
  const st = sp * dt, ox = e.x, oy = e.y;
  if (e.ax === 'x') { moveEnt(e, Math.sign(dx) * Math.min(st, Math.abs(dx)), 0); e.dir = dirOf(dx, 0); if (Math.abs(e.x - ox) < 1e-4) e.ax = Math.abs(dy) > eps ? 'y' : null; }
  else { moveEnt(e, 0, Math.sign(dy) * Math.min(st, Math.abs(dy))); e.dir = dirOf(0, dy); if (Math.abs(e.y - oy) < 1e-4) e.ax = Math.abs(dx) > eps ? 'x' : null; }
  return Math.abs(tx - e.x) <= eps && Math.abs(ty - e.y) <= eps;
}
function update(dt) {
  Game.time += dt; if (Game.arriveT > 0) Game.arriveT -= dt; if (Game.warnT > 0) Game.warnT -= dt;
  for (let i = timers.length - 1; i >= 0; i--) { timers[i].t -= dt; if (timers[i].t <= 0) { const f = timers[i].fn; timers.splice(i, 1); f(); } }
  const p = Game.player, P = Game.P, s = stats(), m = Game.map;
  // oyuncu
  const px0 = p.x, py0 = p.y; p.animT = (p.animT || 0) + dt * TICK; p.combatT -= dt; p.atkT -= dt;
  for (const k in p.cds) p.cds[k] = Math.max(0, p.cds[k] - dt);
  p.buffs.forEach(b => b.t -= dt); p.buffs = p.buffs.filter(b => b.t > 0);
  { const w = {}; if (!p.dead) for (const b of p.buffs) if (b.fx) w[b.id] = b.fx; auraSync(p, w); }   // güçlendirme görselleri (b.fx)
  if (p.stateT > 0) { p.stateT -= dt; if (p.stateT <= 0) p.state = 'idle'; }
  if (p.dead) p.deadT = (p.deadT || 0) + dt;
  if (!p.dead) {
    const regen = Game.scene.name === '观林镇' ? 0.03 : p.combatT > 0 ? 0.003 : 0.012;
    p.hp = Math.min(s.hp, p.hp + (s.hp * regen + s.hpreg * 0.1) * dt); p.mp = Math.min(s.mp, p.mp + (s.mp * regen * 1.3 + s.mpreg * 0.1) * dt);
    const noHeal = p.buffs.some(b => b.buff.noHeal), hu = 1 + (s.healUp || 0) / 100;
    for (const b of p.buffs) { const B = b.buff;
      if (b.at && Math.hypot(p.x - b.at.x, p.y - b.at.y) > b.at.r) continue;   // yere konmuş etki (Şifa Pınarı): uzaktayken işlemez
      if (B.hot && !noHeal) p.hp = Math.min(s.hp, p.hp + s.hp * B.hot * hu * dt); if (B.hotT && !noHeal) p.hp = Math.min(s.hp, p.hp + B.hotT * hu * dt); if (B.motT) p.mp = Math.min(s.mp, p.mp + B.motT * dt);
      if (B.mpTick) { const v = s.mp * B.mpTick * dt; p.mp = Math.min(s.mp, p.mp + v); if (B.hpTick && !noHeal) p.hp = Math.min(s.hp, p.hp + v); }   // Element Bağışı (+ Ruh Uyumu)
      if (B.mp2hp) { const v = Math.min(p.mp, p.mp * B.mp2hp * dt); p.mp -= v; if (!noHeal) p.hp = Math.min(s.hp, p.hp + v * hu); }   // Karanlık Ahit
      if (B.drain && (b.acc = (b.acc || 0) + dt) >= 1) { b.acc -= 1; for (const m of Game.ents) if (m.kind === 'mob' && !m.dead && Math.hypot(m.x - p.x, m.y - p.y) <= 3) hitMob(m, 0, { add: m.maxHp * B.drain, pure: 1, tick: 1 }); }   // Gölge Hükümdarı
    }
    const ph = Game.phantom;   // Büyü Hayali: saniyede bir, savunma tanımayan hasar
    if (ph) { ph.t -= dt; ph.tick -= dt; const tg = Game.target && !Game.target.dead && Game.target.kind === 'mob' ? Game.target : ph.tg && !ph.tg.dead ? ph.tg : null;
      if (!ph.fx || ph.fx.map !== Game.map) ph.fx = phantomFx();   // harita değişince yeniden
      ph.fx.anim = (tg ? dirOf(tg.x - ph.fx.x, tg.y - ph.fx.y) : p.dir) + (ph.tick < 0.4 && tg ? 8 : 0);   // hedefe bakar; atarken saldırı hareketi
      if (ph.tick <= 0 && tg) { ph.tick = 1; shoot('特效-蓝火球', ph.fx.at(), tg, () => hitMob(tg, ph.mult, { pure: 1, tick: 1 })); }
      if (ph.t <= 0) { ph.fx.done = true; Game.phantom = null; } }
    const J = Input.joy();
    let moving = false;
    if (J) {
      p.path = null; p.pending = null; Game.goTarget = null; Game.route = null; Game.routeNpc = null; Game.routeQuest = null; Game.engage = false;
      const [cx, cy] = snapScreen4(J.x, J.y), l = 1, sp = RUN * (1 + s.spd) * (Game.fast ? 2.6 : 1) * dt;
      moveEnt(p, cx / l * sp, cy / l * sp); p.dir = dirOf(cx, cy); moving = true;
    } else if ((lastJoyDir = -1, p.state !== 'attack' && p.state !== 'cast')) {
      const t = Game.target;
      if (p.pending != null && t && !t.dead) {
        const sk = CLS[P.cls].skills[p.pending];
        if (Math.hypot(t.x - p.x, t.y - p.y) <= sk.range) useSkill(p.pending); else { stepTo(p, t.x, t.y, RUN * (1 + s.spd) * (Game.fast ? 2.6 : 1), dt, true); moving = true; }
      } else if (Game.engage && t && t.kind === 'mob' && !t.dead && !p.path) {
        const C = CLS[P.cls], d = Math.hypot(t.x - p.x, t.y - p.y);
        // 4 yönlü yürüyüşte engelli karede takılırsa (yaklaşamıyorsa) ve yeterince yakınsa olduğu yerden vurur
        const stuck = p.chaseD != null && p.chaseD - d < 0.005 && d <= C.range + 0.6; p.chaseD = d;
        if (d > C.range && !stuck) { stepTo(p, t.x, t.y, RUN * (1 + s.spd) * (Game.fast ? 2.6 : 1), dt, true); moving = true; }
        else if (p.atkT <= 0) {
          p.atkT = 1.1; p.combatT = 5; p.dir = dirOf(t.x - p.x, t.y - p.y);
          if (C.melee) { p.state = 'attack'; p.animT = 0; p.stateT = 0.45; later(0.25, () => { if (!t.dead && Math.hypot(t.x - p.x, t.y - p.y) < C.range + 0.6) { hitMob(t, 1); SFX.play(C.snd); Game.fx.push(new Fx('BLOOD', t.x, t.y)); } }); }
          else { p.state = 'cast'; p.animT = 0; p.stateT = 0.45; SFX.play(C.snd, 0.6); later(0.2, () => shoot(C.bolt, p, t, () => { hitMob(t, 0.9); if (C.boltHit) Game.fx.push(new Fx(C.boltHit, t.x, t.y)); SFX.play('skill_bomb', 0.4); }, true)); }
        }
      }
      if (p.path && p.path.length) {
        const [tx, ty] = p.path[0]; if (stepTo(p, tx, ty, RUN * (1 + s.spd) * (Game.fast ? 2.6 : 1), dt, true)) p.path.shift(); moving = true;
        if (!p.path.length) { p.path = null; if (Game.goTarget) { const n = Game.goTarget; Game.goTarget = null; if (Math.hypot(n.x - p.x, n.y - p.y) < 2.2) interact(n); } }
      }
    }
    if (p.state === 'idle' || p.state === 'move') p.state = moving ? 'move' : 'idle';
    const went = Math.hypot(p.x - px0, p.y - py0) * CELL_PX;
    if (p.state === 'move') p.t += went * 8 / STRIDE; else p.t += dt * TICK;
    checkExits();
  }
  Pet.update(dt);   // evcil hayvan
  // canavarlar
  for (const e of Game.ents) {
    if (e.kind === 'npc') { e.t += dt * TICK * 0.8; if (e.hidden && (e.respawnT -= dt) <= 0) e.hidden = false; continue; }
    if (e.kind !== 'mob') continue;
    e.t += dt * TICK; e.animT = (e.animT || 0) + dt * TICK;
    if (e.dead) { if (e._aura) auraSync(e, {}); e.deadT += dt; if ((e.respawnT -= dt) <= 0) { Object.assign(e, { dead: false, hp: e.maxHp, x: e.home.x, y: e.home.y, aggro: false, state: 'idle' }); } continue; }
    e.atkT -= dt; e.slowT -= dt; if (e.weakT > 0) e.weakT -= dt; else if (e.weakDef) e.weakDef = 0;
    // zayıflatma görselleri (orijinal all_buff): yavaşlama (210148) 特效-缓缓加蓝, Tanrı Gözdağı (210146) 特效-抗性衰减buff, donma (210015) 特效-冻结
    { const w = {}; if (e.slowT > 0) w.slow = '特效-缓缓加蓝'; if (e.weakT > 0 && e.weakDef) w.weak = '特效-抗性衰减buff'; if (e.rootT > 0) w.root = '特效-冻结'; if (e._aura || w.slow || w.weak || w.root) auraSync(e, w); }
    if (e.gmDummy) { e.state = e.state === 'hurt' && e.stateT > 0 ? 'hurt' : 'idle'; if (e.stateT > 0) e.stateT -= dt; continue; }   // GM kuklası: kıpırdamaz, saldırmaz
    if (e.bleed && (e.bleed.tick -= dt) <= 0) { e.bleed.tick = 2; e.bleed.t -= 2; hitMob(e, 0.08 * e.bleed.n, { tick: 1 }); if (e.bleed && e.bleed.t <= 0) e.bleed = null; if (e.dead) continue; }   // Testere Bıçak kanaması
    if (e.burn && (e.burn.tick -= dt) <= 0) { e.burn.tick = 2; e.burn.t -= 2; hitMob(e, 0.15, { tick: 1 }); if (e.burn && e.burn.t <= 0) e.burn = null; if (e.dead) continue; }   // Alev Darbesi yanması
    if (e.rootT > 0) e.rootT -= dt; if (e.sealT > 0) e.sealT -= dt; if (e.despairT > 0) e.despairT -= dt;
    if (e.stunT > 0) { e.stunT -= dt; continue; }   // Kutsal Ceza: sersem (kıpırdamaz, saldırmaz)
    if (e.dot && (e.dot.t -= dt) <= 0) { e.dot.t = 2; const D = e.dot; if (--D.n <= 0) e.dot = null; const dd = hitMob(e, D.mult, { add: D.add, tick: 1 }); if (D.suck && dd) healPlayer(dd * D.suck); if (e.dead) continue; } if (e.stateT > 0) { e.stateT -= dt; if (e.stateT <= 0) e.state = 'idle'; }
    const dp = Math.hypot(p.x - e.x, p.y - e.y), dh = Math.hypot(e.x - e.home.x, e.y - e.home.y);
    const sp = (e.slowT > 0 ? 1 : 2) * (e.d.rank ? 1.1 : 1);
    if (!e.aggro && !e.d.passive && !p.dead && dp < 3.5 && e.d.lv >= P.lv - 5) e.aggro = true;
    if (e.aggro && (dh > 12 || p.dead)) { e.aggro = false; e.hp = e.maxHp; }
    if (e.state === 'hurt' || e.state === 'attack') continue;
    if (e.tauntT > 0) e.tauntT -= dt;
    // hedef: son vuran (evcil hayvan da olabilir); hayvan yoksa oyuncu
    const fo = e.foe && e.foe.kind === 'pet' && e.foe === Pet.ent ? e.foe : p, df = Math.hypot(fo.x - e.x, fo.y - e.y);
    if (e.aggro && !p.dead) {
      // donmuş (kök) canavar yürüyemez; mühürlü canavar saldıramaz
      if (df > 1.3) { if (!(e.rootT > 0)) { stepTo(e, fo.x, fo.y, sp, dt, true); e.state = 'move'; } }
      else { e.dir = dirOf(fo.x - e.x, fo.y - e.y); if (e.atkT <= 0 && !(e.sealT > 0)) { e.atkT = 1.6; e.state = 'attack'; e.animT = 0; e.stateT = 0.5; later(0.3, () => { if (e.dead || Math.hypot(fo.x - e.x, fo.y - e.y) >= 1.9) return; if (fo === p) hurtPlayer(e); else if (fo === Pet.ent) Pet.hurt(e); }); } else e.state = 'idle'; }
    } else {
      e.wanderT -= dt;
      if (e.wanderT <= 0) { e.wanderT = rnd(2, 6); e.wx = e.home.x + rnd(-3, 3); e.wy = e.home.y + rnd(-3, 3); if (Game.map.blocked(e.wx, e.wy)) e.wx = null; }
      if (e.wx != null && Math.hypot(e.wx - e.x, e.wy - e.y) > 0.2) { stepTo(e, e.wx, e.wy, 0.8, dt); e.state = 'move'; } else e.state = 'idle';
    }
  }
  // efektler
  for (const f of Game.fx) {
    if (f.done) continue; f.t += dt * TICK; if (f.follow) { f.x = f.follow.x; f.y = f.follow.y; }
    if (f.life != null && (f.life -= dt) <= 0) { f.done = true; continue; }
    if (f.proj) {
      const t = f.proj.to; if (!t || (t.dead && !f.proj.vis)) { f.done = true; continue; }
      const dx = t.x - f.x, dy = t.y - f.y, d = Math.hypot(dx, dy), st = f.proj.sp * dt;
      if (d <= st + 0.2) { f.done = true; f.proj.cb(); } else { f.x += dx / d * st; f.y += dy / d * st; }
    } else if (!f.loop && f.t >= f.len) f.done = true;
  }
  Game.fx = Game.fx.filter(f => !f.done);
  // kamera
  Game.cam.x = p.X; Game.cam.y = p.Y - 40; // kamera karaktere kilitli: titreme olmaz
  Game.saveT = (Game.saveT || 0) + dt; if (Game.saveT > 8) { Game.saveT = 0; save(); }
}

// ---------------- Etkileşim ----------------
function interact(e) {
  const p = Game.player;
  if (e.kind === 'npc') {
    p.dir = dirOf(e.x - p.x, e.y - p.y);
    if (e.node) { UI.say(e, 'Bu bir toplama noktası. Madencilik ve toplama meslekleri yakında eklenecek.'); return; }
    if (e.dummy) { UI.say(e, trName(e.cn) + ': eğitim alanı sergisi.'); return; }
    if (e.pickup) { pickupNode(e); return; }
    // hedefi bir NPC olan "kullan/ver" görevleri (ör. iksiri Gary'ye içir): NPC'ye dokununca tamamlanır
    for (const q of QUESTS) { const st = Game.P.quests[q.id]; if (st && !st.ready && q.type === 'pickup' && q.node === e.cn) { st.n = q.count; if (q.item) UI.log(`${q.item} ${st.n}/${q.count}`, 'loot'); readyQuest(q); } }
    // konuşma görevlerini tamamla
    for (const q of QUESTS) { const st = Game.P.quests[q.id]; if (st && !st.ready && q.type === 'talk' && q.to === e.cn) st.ready = true; }
    UI.dialog(e);
  }
}
function tapWorld(sx, sy) {
  const p = Game.player; if (!p || p.dead) return;
  const W = UI.toWorld(sx, sy);
  // ekranda en yakın varlık
  let best = null, bd = 34;
  for (const e of Game.ents) {
    if (e === p || e.dead || e.hidden) continue;
    const d = Math.hypot(e.X - W.x, (e.Y - 22) - W.y); if (d < bd) { bd = d; best = e; }
  }
  if (best) {
    if (best.kind === 'mob') { setTarget(best, Game.target === best); p.path = null; return; }   // ilk dokunuş seçer, seçiliye ikinci dokunuş saldırır
    // NPC: ilk dokunuş hedef alır (sağ alttaki büyük düğme konuşma düğmesine döner); hedefliyken ikinci dokunuş konuşmaya gider
    if (best.kind === 'npc' && Game.target !== best) { setTarget(best); p.path = null; SFX.play('menusel', 0.5); return; }
    return talkTo(best);
  }
  // boş yere dokunmak karakteri yürütmez (orijinalde de yoktu): yürüme yalnızca sol alttaki ejderhayla
}
// hedef alınmış NPC ile konuş: yakınsa hemen, uzaksa yanına yürüyüp konuşur (hedef korunur)
function talkTo(n) {
  const p = Game.player; if (!n || n.hidden) return;
  if (Math.hypot(n.x - p.x, n.y - p.y) < 2) return interact(n);
  p.path = findPath(Game.map, p.x, p.y, n.x, n.y + 1); Game.goTarget = n; if (!p.path) UI.toast('Oraya yol bulunamadı.');
}
function revive() { const p = Game.player, s = stats(); p.dead = false; p.state = 'idle'; p.hp = Math.round(s.hp * 0.5); p.mp = Math.round(s.mp * 0.5); if (Dungeon.onRevive()) return; const P0 = Game.P; if (!P0.home && (P0.done[80003] || P0.quests[80003])) P0.home = ['120005', 33, 20]; const town = P0.home; if (town) gotoScene(town[0], null, town[1] != null ? [town[1], town[2]] : null); else { const r = Game.map.regionsOf(0)[0]; if (r) { p.x = r[2]; p.y = r[3]; } } }
