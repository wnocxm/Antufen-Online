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

// Sınıf değerleri ve yetenekler (orijinal efekt ve simgelerle)
// Beceriler orijinal beceri ağaçlarından (all_skilltree / all_skill): adlar, simgeler, efektler ve sesler orijinal.
// Etkin beceriler önce (kısayol sırası), edilgenler (pas) sonra gelir.
const CLS = {
  '战士': { hp: 150, mp: 50, atk: 14, def: 8, ghp: 26, gmp: 5, gatk: 3.2, gdef: 1.8, range: 1.4, color: '红', melee: true, snd: 'skill_sword',
    skills: [
      { id: 'w1', name: 'Temel Kılıç Ustalığı', icon: 1107, mp: 0, cd: 1.5, mult: 1.25, range: 1.6, fx: 'BLOOD', snd: 'skill_sword', lv: 1, desc: 'Yakın saldırı. Mana harcamaz.' },
      { id: 'w2', name: 'Güçlü Savurma', icon: 1114, mp: 8, cd: 5, mult: 1.9, crit: 20, range: 1.6, fx: '特效-刀光-红', snd: 'skill_daoguang', lv: 3, desc: 'Güçlü yakın saldırı, kritik şansı yüksek.' },
      { id: 'w3', name: 'Bıçak Fırlatma', icon: 1127, mp: 12, cd: 7, mult: 1.3, range: 6, proj: '特效-飞刀', hit: '特效-细碎爆炸', splash: 1.8, snd: 'skill_nife', snd2: 'skill_pilipala', lv: 6, desc: 'Uzaktan alan saldırısı.' },
      { id: 'w4', name: 'Çifte Darbe', icon: 1112, mp: 14, cd: 8, mult: 1.3, hits: 2, range: 1.6, fx: '特效-刀光', fx2: '特效-大喷血', snd: 'skill_daoguang', lv: 10, desc: 'Art arda iki vuruş.' },
      { id: 'w5', name: 'Hız Patlaması', icon: 1103, mp: 10, cd: 20, buff: { spd: 0.25, crit: 30 }, dur: 5, fx: '特性-聚气', snd: 'skill_juqi', lv: 13, desc: '5 saniye %25 hızlı koşarsın, kritik şansın artar.' },
      { id: 'w6', name: 'Ruh Yaran', icon: 1132, mp: 18, cd: 10, mult: 2.2, range: 5, fx: '特效-刀光', fx2: '特效-死亡标记', snd: 'skill_deathtag', lv: 17, desc: 'Uzaktan karanlık saldırı.' },
      { id: 'wp1', pas: { atk: 4 }, name: 'Silah Eğitimi', icon: 1136, lv: 2, desc: 'Saldırı +4.' },
      { id: 'wp2', pas: { hpPct: 8 }, name: 'Gürbüzlük', icon: 1109, lv: 4, desc: 'Can sınırı +%8.' },
      { id: 'wp3', pas: { dodge: 5 }, name: 'Çeviklik', icon: 1105, lv: 8, desc: 'Kaçınma +%5.' },
      { id: 'wp4', pas: { def: 6, res: 6 }, name: 'Savunma Ustalığı', icon: 1063, lv: 11, desc: 'Savunma ve direnç +6.' },
      { id: 'wp5', pas: { hpreg: 60 }, name: 'Hızlı İyileşme', icon: 1135, lv: 14, desc: 'Can yenilenmesi artar.' },
      { id: 'wp6', pas: { dr: 8 }, name: 'Dayanıklılık Halesi', icon: 1110, lv: 18, desc: 'Alınan hasar −%8.' },
    ] },
  '法师': { hp: 100, mp: 130, atk: 17, def: 4, ghp: 16, gmp: 15, gatk: 3.8, gdef: 1.0, range: 6, color: '蓝', bolt: '特效-蓝火球', snd: 'skill_fire2',
    skills: [
      { id: 'm1', name: 'Ateş Topu', icon: 1137, mp: 8, cd: 2.5, mult: 1.8, range: 7, proj: '特效-火球', hit: '特效-火爆炸', snd: 'skill_fireball', snd2: 'skill_bomb', lv: 1, desc: 'Uzaktan ateş büyüsü.' },
      { id: 'm2', name: 'Dondurma', icon: 1132, mp: 12, cd: 5, mult: 1.6, crit: 15, range: 7, proj: '特效-冰球', hit: 'WATER_ATTACK', slow: 4, snd: 'skill_wind', snd2: 'skill_bubble', lv: 3, desc: 'Buz büyüsü; hedefi yavaşlatır.' },
      { id: 'm3', name: 'Şifa', icon: 1135, mp: 18, cd: 10, heal: 0.3, fx: 'LIGHT_ATTACK', snd: 'skill_light', lv: 6, desc: 'Kendi canını yeniler.' },
      { id: 'm4', name: 'Alev Yakışı', icon: 1114, mp: 20, cd: 8, mult: 2.0, aoe: 2.4, fx: 'FIRE_ATTACK', hit: '特效-火爆炸', snd: 'skill_fireball2', snd2: 'skill_bomb', lv: 10, desc: 'Yakın çevrendeki düşmanları yakar.' },
      { id: 'm5', name: 'Büyü Kalkanı', icon: 1134, mp: 25, cd: 30, buff: { def: 0.6, dr: 30 }, dur: 10, fx: '特效-法力盾', snd: 'skill_juqi', lv: 13, desc: '10 saniye alınan hasarı azaltır.' },
      { id: 'm6', name: 'Kar Fırtınası', icon: 1101, mp: 30, cd: 12, mult: 1.7, range: 7, proj: '特效-冰球', hit: '特效-冰块碎裂', splash: 2.6, slow: 4, snd: 'skill_wind', snd2: 'skill_ice', lv: 16, desc: 'Buz alan saldırısı.' },
      { id: 'mp1', pas: { atk: 4 }, name: 'Büyü Çalışması', icon: 1133, lv: 2, desc: 'Büyü saldırısı +4.' },
      { id: 'mp2', pas: { mpPct: 10 }, name: 'Mana Güçlendirme', icon: 1105, lv: 4, desc: 'Mana sınırı +%10.' },
      { id: 'mp3', pas: { crit: 5 }, name: 'Mana Denetimi', icon: 1106, lv: 8, desc: 'İsabet ve kritik +%5.' },
      { id: 'mp4', pas: { res: 10 }, name: 'Doğal Direnç', icon: 1108, lv: 11, desc: 'Tüm dirençler +10.' },
      { id: 'mp5', pas: { mpreg: 60 }, name: 'Mana Yenilenmesi', icon: 1104, lv: 14, desc: 'Mana yenilenmesi artar.' },
      { id: 'mp6', pas: { mpPct: 10 }, name: 'Mana Halesi', icon: 1111, lv: 19, desc: 'Mana sınırı +%10 daha.' },
    ] },
  '牧师': { hp: 120, mp: 115, atk: 14, def: 6, ghp: 20, gmp: 13, gatk: 3.3, gdef: 1.4, range: 5.5, color: '金', bolt: '特效-黑暗火球', snd: 'skill_wind',
    skills: [
      { id: 'p1', name: 'Gölge Darbesi', icon: 1062, mp: 8, cd: 2.5, mult: 1.7, range: 7, proj: '特效-黑暗火球', hit: '特效-冲击爆炸', snd: 'skill_wind', snd2: 'skill_bomb', lv: 1, desc: 'Uzaktan gölge saldırısı.' },
      { id: 'p2', name: 'Çürüme', icon: 1066, mp: 12, cd: 6, mult: 0.5, dot: { mult: 0.45, n: 5 }, range: 7, fx: '特效-死亡标记', snd: 'skill_deathtag', lv: 3, desc: 'Hedefe lanet: 2 saniyede bir hasar verir.' },
      { id: 'p3', name: 'İlahi Gözdağı', icon: 1094, mp: 20, cd: 15, mult: 0.8, aoe: 3, weak: 10, fx: '特效-神之威慑', snd: 'skill_juqi', lv: 6, desc: 'Çevredeki düşmanların savunmasını düşürür.' },
      { id: 'p4', name: 'Şifa Pınarı', icon: 1100, ik: 'item', mp: 22, cd: 15, buff: { hot: 0.05 }, dur: 8, fx: '特效-治疗buff', snd: 'skill_light', lv: 10, desc: '8 saniye boyunca can yeniler.' },
      { id: 'p5', name: 'Gölge Yakışı', icon: 1119, mp: 18, cd: 6, mult: 2.3, range: 7, proj: '特效-黑暗火球', hit: '特效-火爆炸', snd: 'skill_fire2', snd2: 'skill_bomb', lv: 13, desc: 'Karanlık ateşle yakar.' },
      { id: 'p6', name: 'Kutsal Işık', icon: 1030, ik: 'item', mp: 26, cd: 12, heal: 0.4, fx: '特效-缓缓加红', snd: 'skill_light', lv: 16, desc: 'Canını yeniler.' },
      { id: 'p7', name: 'İlahi Öfke', icon: 1110, mp: 30, cd: 40, buff: { atk: 0.25, def: 0.25 }, dur: 20, fx: '特效-狂暴BUFF', snd: 'skill_relive', lv: 19, desc: 'Saldırı ve savunman 20 saniye artar.' },
      { id: 'pp1', pas: { atk: 4 }, name: 'Sofu İradesi', icon: 1244, ik: 'item', lv: 2, desc: 'Büyü saldırısı +4.' },
      { id: 'pp2', pas: { crit: 5 }, name: 'Zorbalık', icon: 1078, lv: 5, desc: 'Kritik şansı +%5.' },
      { id: 'pp3', pas: { atk: 3 }, name: 'Can Sömürüsü', icon: 1122, lv: 8, desc: 'Çürüme güçlenir (saldırı +3).' },
      { id: 'pp4', pas: { hpreg: 40, mpreg: 40 }, name: 'İlahi Işık Dökümü', icon: 1065, lv: 11, desc: 'Can ve mana yenilenmesi artar.' },
      { id: 'pp5', pas: { crit: 6 }, name: 'İlahi Ceza', icon: 1118, lv: 15, desc: 'Kritik şansı +%6.' },
    ] },
};
if (LANG === 'en') for (const c of Object.values(CLS)) for (const sk of c.skills) { const e = EN_SKILL[sk.id]; if (e) { sk.name = e[0]; sk.desc = e[1]; } }
// Orijinal beceri ağaçları (all_skilltree): her ağaçta 3 sütun; [beceri, sütun, satır]
const TREES = {
  '战士': [{ name: 'Acemi', cells: [['w1', 1, 0], ['wp1', 2, 0], ['wp3', 0, 1], ['wp2', 2, 1], ['w2', 0, 2], ['w3', 2, 2]] }, { name: 'Savaşçı', cells: [['w4', 1, 0], ['wp4', 2, 0], ['wp5', 0, 1], ['w5', 2, 1], ['wp6', 0, 2], ['w6', 2, 2]] }],
  '法师': [{ name: 'Çırak', cells: [['m1', 1, 0], ['mp1', 2, 0], ['mp2', 0, 1], ['mp3', 2, 1], ['m3', 0, 2], ['m2', 2, 2]] }, { name: 'Büyücü', cells: [['m4', 1, 0], ['mp4', 2, 0], ['mp6', 0, 1], ['mp5', 2, 1], ['m5', 0, 2], ['m6', 2, 2]] }],
  '牧师': [{ name: 'Başlangıç', cells: [['p1', 1, 0], ['pp1', 2, 0], ['p2', 0, 1], ['pp2', 2, 1], ['pp3', 0, 2], ['p3', 2, 2]] }, { name: 'Elçi', cells: [['p4', 1, 0], ['pp4', 2, 0], ['p5', 0, 1], ['p6', 2, 1], ['pp5', 0, 2], ['p7', 2, 2]] }],
};
const SK_MAX = 5;
const skRank = sk => (Game.P.sk && Game.P.sk[sk.id]) || 0;
const skMult = sk => 1 + 0.1 * (Math.max(1, skRank(sk)) - 1);          // her kademe +%10 güç
function skillUp(sk) {
  const P = Game.P, r = skRank(sk);
  if (r >= SK_MAX) return UI.toast('Bu beceri en yüksek kademede.');
  if (P.lv < sk.lv) return UI.toast(`${sk.lv}. seviye gerekir.`);
  if ((P.sp || 0) < 1) return UI.toast('Beceri puanın yok. Seviye atlayınca puan kazanırsın.');
  P.sp--; P.sk[sk.id] = r + 1; SFX.play('skill_levelup'); UI.log(`${sk.name}: ${tx('kademe')} ${r + 1}`, 'q'); clampVitals(); save();
}
const QUICK0 = ['s0', 's1', 's2', 's3', 's4', 's5', 'i:hp1', 'i:mp1'];
const ITEMS = {
  hp1: { name: 'Zayıf Can İksiri', icon: 1019, desc: '200 can yeniler.', price: 10, use: { hp: 200 } },
  hp2: { name: 'Can İksiri', icon: 1020, desc: '600 can yeniler.', price: 35, use: { hp: 600 } },
  mp1: { name: 'Zayıf Mana İksiri', icon: 1026, desc: '150 mana yeniler.', price: 10, use: { mp: 150 } },
  mp2: { name: 'Mana İksiri', icon: 1024, desc: '450 mana yeniler.', price: 35, use: { mp: 450 } },
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
    scene: race === '精灵' ? '120205' : '120207', x: 11, y: 15, quick: QUICK0.slice(), sv: 2, sk: { [CLS[cls].skills[0].id]: 1 }, sp: 1, flags: {} };
}
// ---------------- Ekipman (orijinal eşya tablolarından) ----------------
const STARTER = { '战士': { weap: '10003' }, '法师': { weap: '10006' }, '牧师': { weap: '10882' } };
const STARTER_BODY = { '战士': '10004', '法师': '10007', '牧师': '10883' };
const NEWBIE = { '战士': ['10002', '10439'], '法师': ['10005', '10058'], '牧师': ['10881', '10884'] };
const SLOTS = [['weap', 'Silah'], ['head', 'Başlık'], ['body', 'Zırh'], ['belt', 'Kemer'], ['shoe', 'Ayakkabı'], ['glove', 'Eldiven'], ['neck', 'Kolye'], ['ring', 'Yüzük']];
const STATN = { atk: 'Saldırı', def: 'Savunma', hp: 'Can', mp: 'Mana', crit: 'Kritik %', dodge: 'Kaçınma %', hpreg: 'Can yenileme', mpreg: 'Mana yenileme', res: 'Büyü direnci' };
let SHOPS = {};
async function loadItems() {
  const D = await fetch(vq(Assets.base + 'items.json')).then(r => r.json());
  for (const [id, it] of Object.entries(D.items)) { it.ik = it.icon[0]; it.icon = it.icon[1]; if (it.slot) it.desc = it.desc || ''; if (LANG === 'en') { it.name = EN_ITEM[it.name] || it.name; it.desc = tx(it.desc); } ITEMS[id] = it; }
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
function sellItem(id) {
  const P = Game.P, it = ITEMS[id]; if (!it || it.quest || !removeItem(id)) return;
  const g = it.sell || Math.max(1, Math.floor((it.price || 0) / 10)); P.gold += g; SFX.play('coin'); UI.log(`${it.name} satıldı (+${g} altın).`, 'loot'); save();
}
// seviyeye ve sınıfa uygun rastgele ekipman (dükkân listelerinden)
function randomGear(lv) {
  const P = Game.P, pool = Object.entries(ITEMS).filter(([, it]) => it.slot && (!it.cls || it.cls === P.cls) && it.lv <= lv && it.lv >= lv - 12);
  return pool.length ? pool[irnd(0, pool.length - 1)][0] : null;
}
function save() { const P = Game.P; if (!P || !Game.player) return; P.scene = Game.sceneId; P.x = Game.player.x; P.y = Game.player.y; P.hp = Game.player.hp; P.mp = Game.player.mp; try { localStorage.setItem(SAVE_KEY, JSON.stringify(P)); } catch (e) { } }
function load() { try { const s = JSON.parse(localStorage.getItem(SAVE_KEY)); if (s && s.v === 1) { if (!s.eq) { s.eq = Object.assign({}, STARTER[s.cls]); if (s.gear && s.gear.head) Object.assign(s.eq, { head: NEWBIE[s.cls][0], shoe: NEWBIE[s.cls][1] }); } if (s.sv !== 2) { s.sv = 2; s.quick = QUICK0.slice(); } if (!s.sk) { s.sk = {}; for (const k of CLS[s.cls].skills) if (s.lv >= k.lv) s.sk[k.id] = 1; s.sp = 1; } return s; } } catch (e) { } return null; }

function stats() {
  const P = Game.P, C = CLS[P.cls], L = P.lv - 1, g = P.gear;
  const s = { hp: C.hp + C.ghp * L, mp: C.mp + C.gmp * L, atk: C.atk + C.gatk * L, def: C.def + C.gdef * L, crit: 0, dodge: 0, hpreg: 0, mpreg: 0, res: 0 };
  for (const id of Object.values(P.eq || {})) { const it = id && ITEMS[id]; if (it && it.st) for (const k in it.st) s[k] = (s[k] || 0) + it.st[k]; }
  s.dr = 0; s.spd = 0; let hpPct = 0, mpPct = 0;
  for (const sk of C.skills) { const r = (P.sk && P.sk[sk.id]) || 0; if (!sk.pas || !r) continue; const m = 0.5 + 0.5 * r; for (const k in sk.pas) { const v = Math.round(sk.pas[k] * m); if (k === 'hpPct') hpPct += v; else if (k === 'mpPct') mpPct += v; else s[k] = (s[k] || 0) + v; } }
  s.hp *= 1 + hpPct / 100; s.mp *= 1 + mpPct / 100;
  if (P.race === '精灵') { s.mp += 15; s.hp -= 5; } else { s.def += 2; }
  for (const b of Game.player?.buffs || []) { if (b.buff.atk) s.atk *= 1 + b.buff.atk; if (b.buff.def) s.def *= 1 + b.buff.def; if (b.buff.spd) s.spd += b.buff.spd; if (b.buff.crit) s.crit += b.buff.crit; if (b.buff.dr) s.dr += b.buff.dr; }
  for (const k in s) s[k] = Math.round(s[k]);
  return s;
}
function look() {
  const P = Game.P, e = P.eq || {}, G = sl => (e[sl] && ITEMS[e[sl]] && ITEMS[e[sl]].gfx) || null;
  return { cls: P.cls, race: P.race, sex: P.sex, bodyG: G('body'), headG: G('head'), weapG: G('weap') };
}
function xpNeed(l) { return Math.floor(40 * Math.pow(l, 1.85) + 20); }

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
    if (this.dead) { anim = 16 + this.dir; return this.doll.draw(ctx, 'town', anim, 0, X, Y, 0.85); }
    if (this.state === 'move') return this.doll.draw(ctx, 'comm', 4 + this.dir, t, X, Y);   // savaşta da normal koşu (figh 12-15 saldırı kareleri)
    else if (this.state === 'attack') { anim = 4 + this.dir; t = this.animT; }
    else if (this.state === 'cast') { anim = 8 + this.dir; t = this.animT; }
    else anim = act === 'figh' ? this.dir : this.dir;
    this.doll.draw(ctx, act, anim, t, X, Y);
  }
}
class Mob extends Ent {
  constructor(name, x, y, home) {
    super('mob', x, y); const d = MON[name] || { lv: 1, hp: 50, atk: 5, xp: 5 };
    Object.assign(this, { name, d, hp: d.hp, maxHp: d.hp, home, state: 'idle', atkT: 0, wanderT: rnd(1, 4), aggro: false, slowT: 0 });
    const info = Game.mobInfo(name); this.sp = info ? Game.map.sprite(info[1]) : null; this.deathFx = info?.[2];
    this.dir = irnd(0, 3);
  }
  draw(ctx, X, Y) {
    if (!this.sp) return;
    const actIdx = this.dead ? 4 : this.state === 'attack' ? 2 : this.state === 'hurt' ? 3 : this.state === 'move' ? 1 : 0;
    let anim = actIdx * 4 + this.dir;
    if (!this.sp.anims[anim] || !this.sp.anims[anim].length) anim = this.dir;
    const t = this.dead ? Math.min(this.deadT * 8, this.sp.animLen(anim) - 1) : (this.state === 'attack' || this.state === 'hurt') ? this.animT : this.t;
    this.sp.draw(ctx, anim, t, X, Y, false, this.dead ? Math.max(0, 1 - (this.deadT - 1.5)) : 1);
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
class Fx {
  constructor(name, x, y, opt = {}) { this.sp = Game.map.sprite(name); this.x = x; this.y = y; this.t = 0; this.loop = opt.loop || 0; this.follow = opt.follow; this.z = opt.z || 0; this.len = this.sp.ok ? this.sp.animLen(0) : 0; this.done = !this.sp.ok; }
  draw(ctx, X, Y) { if (this.sp.ok) this.sp.draw(ctx, 0, this.t, X, Y - this.z); }
}

// ---------------- Sahne yükleme ----------------
Game.mobInfo = name => { for (const k in Assets.D.mon) if (Assets.D.mon[k][0] === name) return Assets.D.mon[k]; return null; };
async function loadScene(sid, arrive) {
  UI.fade(true);
  const D = Assets.D, sc = D.scenes[sid];
  const json = await fetch(vq(Assets.base + 'maps/' + sc.map + '.json')).then(r => r.json());
  const map = new GameMap(sc.map, json, sc);
  // gerekli görselleri önceden yükle
  const names = new Set(map.names);
  for (const [id, nm] of sc.ents) { const info = D.cit[id] || D.mon[id]; if (info) { names.add(info[1]); if (info[2]) names.add(info[2]); } }
  for (const n of ['特效-血爆死亡', '特效-刀光', 'LEVELUP', '特效-火球', '特效-火爆炸', '特效-冰球', '特效-冰块碎裂', '特效-黑暗火球', '特效-蓝火球', '特效-大喷血', '特效-治疗buff', 'NPC-新手引导－1', 'NPC-新手引导－2']) names.add(n);
  for (const s of CLS[Game.P.cls].skills) for (const k of ['fx', 'proj', 'hit']) if (s[k]) names.add(s[k]);
  await Assets.preload([...names]);
  Game.player && (Game.player = null);
  Game.map = map; Game.scene = sc; Game.sceneId = sid; Game.ents = []; Game.fx = []; Game.floats = [];
  map.build();
  // NPC'ler ve canavarlar
  for (const [id, nm, pos] of sc.ents) {
    const [x, y] = pos;
    if (D.cit[id]) { const n = new Npc(id, D.cit[id], x, y); Game.ents.push(n); if (!n.pickup) map.extraBlock[map.idx(x, y)] = 1; }
    else if (D.mon[id]) {
      const d = MON[nm] || {};
      if (d.dummy) { const n = new Npc(id, [nm, D.mon[id][1]], x, y); n.dummy = true; Game.ents.push(n); continue; }
      const cnt = d.n || 5, wide = d.wide || 5;
      for (let i = 0; i < cnt; i++) {
        let px = x, py = y;
        for (let k = 0; k < 30; k++) { const a = rnd(-wide, wide), b = rnd(-wide, wide); if (!map.blocked(x + a, y + b)) { px = Math.round(x + a); py = Math.round(y + b); break; } }
        Game.ents.push(new Mob(nm, px, py, { x: px, y: py }));
      }
    }
  }
  // oyuncu
  let px = Game.P.x, py = Game.P.y;
  if (arrive) { [px, py] = arrive; }
  if (map.blocked(px, py)) { const r = map.regionsOf(0)[0] || [0, 0, Math.floor(map.w / 2), Math.floor(map.h / 2)]; px = r[2]; py = r[3]; }
  if (map.blocked(px, py)) { outer: for (let r = 1; r < 30; r++) for (let dy = -r; dy <= r; dy++) for (let dx = -r; dx <= r; dx++) if (!map.blocked(px + dx, py + dy)) { px += dx; py += dy; break outer; } }
  Game.player = new Player(px, py); Game.ents.push(Game.player);
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
      const ex = map.scene.exits.find(e => e[0] === r[0]); if (!ex) continue;
      const target = ex[1].replace('(入口)', '');
      const sid = Object.keys(Assets.D.scenes).find(k => Assets.D.scenes[k].name === target);
      if (!sid) { if (!Game.warnT) { UI.toast(`${trName(target)}: bu bölge henüz açılmadı`); Game.warnT = 3; } return; }
      gotoScene(sid, Game.scene.name);
      return;
    }
  }
}
async function gotoScene(sid, fromName, fixed) {
  Game.transit = true; save();
  const sc = Assets.D.scenes[sid];
  let arrive = fixed || null;
  if (!arrive) {
    const json = await fetch(vq(Assets.base + 'maps/' + sc.map + '.json')).then(r => r.json());
    const back = sc.exits.find(e => e[1].replace('(入口)', '') === fromName);
    const regs = json.regions;
    const r = back ? (regs.find(g => g[0] === back[0] + 1 && g[1] === 0) || regs.find(g => g[0] === back[0])) : regs.find(g => g[1] === 0);
    if (r) arrive = [Math.round((r[2] + r[4]) / 2), Math.round((r[3] + r[5]) / 2)];
  }
  await loadScene(sid, arrive);
  Game.transit = false;
}

// ---------------- Savaş ----------------
function dmgCalc(atk, def, mult, critB = 0) { const base = atk * mult * rnd(0.9, 1.1); const d = Math.max(1, Math.round(base * 100 / (100 + def * 3))); const crit = Math.random() < 0.08 + critB / 100; return { d: crit ? Math.round(d * 1.8) : d, crit }; }
function hitMob(m, mult, o = {}) {
  if (!m || m.dead) return;
  const s = stats(); const r = dmgCalc(s.atk, m.d.lv * 2 * (m.weakT > 0 ? 0.4 : 1), mult * (m.weakT > 0 ? 1.15 : 1), s.crit + (o.crit || 0));
  m.hp -= r.d; m.aggro = true; m.state = 'hurt'; m.animT = 0; m.stateT = 0.3;
  if (o.slow) m.slowT = o.slow;
  UI.float(m, (r.crit ? '!' : '') + r.d, r.crit ? '#ffd040' : '#fff', r.crit ? 1.3 : 1);
  if (m.hp <= 0) killMob(m);
  if (Game.target === m) UI.target(m);
}
function killMob(m) {
  m.dead = true; m.deadT = 0; m.state = 'die'; m.respawnT = m.d.rank === 2 ? 90 : m.d.rank ? 40 : 15;
  if (Game.target === m) setTarget(null);
  const P = Game.P, diff = m.d.lv - P.lv, xp = Math.max(1, Math.round(m.d.xp * clamp(1 + diff * 0.1, 0.2, 1.5)));
  gainXp(xp); UI.float(m, '+' + xp + ' TP', '#9fe060');
  const gold = irnd(m.d.lv, m.d.lv * 3) + (m.d.rank || 0) * 20; P.gold += gold; SFX.play('kill', 0.7); later(0.35, () => SFX.play('coin', 0.5)); UI.log(`${gold} altın alındı`, 'loot');
  if (Math.random() < 0.1) addItem(P.lv > 10 ? 'hp2' : 'hp1', 1);
  if (Math.random() < 0.06) addItem(P.lv > 10 ? 'mp2' : 'mp1', 1);
  if (m.d.rank && Math.random() < 0.6) { const g = randomGear(Math.max(1, m.d.lv + 2)); if (g) { addItem(g, 1, true); UI.log(`Ganimet: ${ITEMS[g].name}!`, 'q'); UI.toast(`Ganimet: ${ITEMS[g].name}`); } }
  else if (!m.d.passive && Math.random() < 0.025) { const g = randomGear(Math.max(1, m.d.lv)); if (g) { addItem(g, 1, true); UI.log(`Ganimet: ${ITEMS[g].name}`, 'loot'); } }
  questKill(m.name);
  if (m.deathFx) Game.fx.push(new Fx(m.deathFx, m.x, m.y));
}
function hurtPlayer(m) {
  const p = Game.player; if (p.dead) return;
  const s = stats(); if (Math.random() < s.dodge / 100) { UI.float(p, 'Iska', '#cfcfcf'); return; }
  const r = dmgCalc(m.d.atk, s.def, 1); r.d = Math.max(1, Math.round(r.d * (1 - Math.min(60, s.dr) / 100)));
  p.hp -= r.d; p.combatT = 5; UI.float(p, '-' + r.d, '#ff5040'); UI.hurt();
  if (p.hp <= 0) { p.hp = 0; p.dead = true; p.state = 'dead'; UI.death(); setTarget(null); }
}
function gainXp(n) {
  const P = Game.P; P.xp += n;
  while (P.xp >= xpNeed(P.lv)) { P.xp -= xpNeed(P.lv); P.lv++; const s = stats(); Game.player.hp = s.hp; Game.player.mp = s.mp; Game.fx.push(new Fx('LEVELUP', Game.player.x, Game.player.y)); UI.levelUp(P.lv); SFX.play('levelup');
    P.sp = (P.sp || 0) + 1; UI.log('Beceri puanı kazandın! Beceriler ekranından harca.', 'q');
    for (const sk of CLS[P.cls].skills) if (sk.lv === P.lv) UI.log(`Yeni beceri: ${sk.name}`, 'q'); }
  UI.refresh();
}
function setTarget(e) { Game.target = e; UI.target(e); }
function cycleTarget() {
  const p = Game.player;
  const list = Game.ents.filter(e => e.kind === 'mob' && !e.dead && Math.hypot(e.x - p.x, e.y - p.y) < 9).sort((a, b) => Math.hypot(a.x - p.x, a.y - p.y) - Math.hypot(b.x - p.x, b.y - p.y));
  if (!list.length) { UI.log('Yakında hedef yok.'); return; }
  const i = list.indexOf(Game.target); setTarget(list[(i + 1) % list.length]); p.path = null;
  questFlag('cycleTarget');
}
function useSkill(i) {
  const P = Game.P, p = Game.player, C = CLS[P.cls], sk = C.skills[i]; if (!sk || sk.pas || p.dead) return;
  if (!skRank(sk)) { UI.log(P.lv < sk.lv ? `${sk.name} ${sk.lv}. seviyede açılır.` : 'Bu beceri henüz öğrenilmedi. Beceriler ekranından puan ver.'); return; }
  const SM = skMult(sk);
  if ((p.cds[sk.id] || 0) > 0) return;
  if (p.mp < sk.mp) { UI.log('Mana yetersiz!'); return; }
  let t = Game.target && !Game.target.dead && Game.target.kind === 'mob' ? Game.target : null;
  const needT = sk.mult && !sk.aoe;
  if (needT && !t) { t = nearestMob(8); if (t) setTarget(t); }
  if (needT && !t) { UI.log('Hedef yok.'); return; }
  if (t && sk.range && Math.hypot(t.x - p.x, t.y - p.y) > sk.range + 0.3) { p.pending = i; p.path = null; return; }
  p.pending = null; p.mp -= sk.mp; p.cds[sk.id] = sk.cd; p.combatT = 5; if (i === 0) p.atkT = Math.max(p.atkT, 0.9);
  if (t) p.dir = dirOf(t.x - p.x, t.y - p.y);
  p.state = C.melee && sk.mult && (sk.range || 9) < 3 ? 'attack' : 'cast'; p.animT = 0; p.stateT = 0.5;
  SFX.play(sk.snd);
  const mobsNear = (x, y, r) => Game.ents.filter(m => m.kind === 'mob' && !m.dead && Math.hypot(m.x - x, m.y - y) <= r);
  const o = { slow: sk.slow, crit: sk.crit };
  const land = () => {
    if (sk.snd2) SFX.play(sk.snd2);
    if (sk.splash) { Game.fx.push(new Fx(sk.hit, t.x, t.y)); for (const m of mobsNear(t.x, t.y, sk.splash)) hitMob(m, sk.mult * SM, o); }
    else { hitMob(t, sk.mult * SM, o); const f = sk.hit || sk.fx; if (f) Game.fx.push(new Fx(f, t.x, t.y)); }
    if (sk.fx2) Game.fx.push(new Fx(sk.fx2, t.x, t.y));
    if (sk.hits === 2) later(0.28, () => { if (!t.dead) { hitMob(t, sk.mult * SM, o); SFX.play(sk.snd); } });
    if (sk.dot && !t.dead) t.dot = { n: sk.dot.n, t: 2, mult: sk.dot.mult };
  };
  later(0.25, () => {
    if (sk.proj) shoot(sk.proj, p, t, land);
    else if (sk.aoe) { Game.fx.push(new Fx(sk.fx, p.x, p.y)); if (sk.snd2) SFX.play(sk.snd2); for (const m of mobsNear(p.x, p.y, sk.aoe)) { hitMob(m, sk.mult * SM, o); if (sk.weak) m.weakT = sk.weak; if (sk.hit) Game.fx.push(new Fx(sk.hit, m.x, m.y)); } }
    else if (sk.mult) land();
    else if (sk.heal) { const s = stats(); const h = Math.round((s.hp * sk.heal + s.atk) * SM); p.hp = Math.min(s.hp, p.hp + h); UI.float(p, '+' + h, '#7bff8a'); Game.fx.push(new Fx(sk.fx, p.x, p.y, { follow: p })); }
    else if (sk.buff) { p.buffs = p.buffs.filter(b => b.id !== sk.id); p.buffs.push({ id: sk.id, buff: sk.buff, t: sk.dur }); Game.fx.push(new Fx(sk.fx, p.x, p.y, { follow: p })); UI.log(`${sk.name} etkin.`); }
  });
  UI.refresh();
}
function shoot(name, from, to, cb) {
  const f = new Fx(name, from.x, from.y, { z: 30 }); f.proj = { to, cb, sp: 9 }; f.loop = 1; Game.fx.push(f);
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
  if (it.slot) return equip(id);
  if (it.use) {
    if (it.use.hp) { if (p.hp >= s.hp) return UI.log('Canın dolu.'); p.hp = Math.min(s.hp, p.hp + it.use.hp); UI.float(p, '+' + it.use.hp, '#7bff8a'); }
    if (it.use.mp) { if (p.mp >= s.mp) return UI.log('Manan dolu.'); p.mp = Math.min(s.mp, p.mp + it.use.mp); UI.float(p, '+' + it.use.mp, '#6fb7ff'); }
    removeItem(id);
  } else if (it.growth) {
    const P = Game.P; removeItem(id);
    for (const g of NEWBIE[P.cls]) { const sl = ITEMS[g].slot; if (!P.eq[sl]) P.eq[sl] = g; else addItem(g, 1, true); }
    for (const [sl, g] of Object.entries(STARTER[P.cls])) if (!P.eq[sl]) P.eq[sl] = g;
    if (!P.eq.body) P.eq.body = STARTER_BODY[P.cls]; else addItem(STARTER_BODY[P.cls], 1, true);
    addItem('hp1', 10, true); addItem('mp1', 10, true);
    UI.toast('Gelişim Paketi açıldı! Yeni ekipmanını kuşandın.'); refreshLook();
  }
}
function refreshLook() { Game.player.doll.set(look()); Assets.preload([]); UI.refresh(); save(); }

// ---------------- Görevler ----------------
const QBY = Object.fromEntries(QUESTS.map(q => [q.id, q]));
// q.race: yalnızca o ırk; q.req: tek kimlik ya da "herhangi biri" listesi
function questState(q) { const P = Game.P; if (P.done[q.id]) return 'done'; if (P.quests[q.id]) return P.quests[q.id].ready ? 'ready' : 'active'; if (q.race && q.race !== P.race) return 'locked';
  if (q.req && !(Array.isArray(q.req) ? q.req.some(r => P.done[r]) : P.done[q.req])) return 'locked'; return 'new'; }
// ışınlanma görevi: q.tp = [sahne, x, y]; gidilen yer "ev" olur (ölünce orada doğulur)
function questTeleport(q) { const P = Game.P; P.home = q.tp.slice(); save(); gotoScene(q.tp[0], null, q.tp[1] != null ? [q.tp[1], q.tp[2]] : null); }
const tpQuestOf = cn => QUESTS.find(q => q.tp && q.giver === cn && (Game.P.quests[q.id] || Game.P.done[q.id]));
function questsFor(cn) { return QUESTS.filter(q => (q.giver === cn && questState(q) === 'new') || (q.to === cn && questState(q) === 'ready') || ((q.to === cn || q.giver === cn) && questState(q) === 'active')); }
function npcMark(cn) {
  if (QUESTS.some(q => q.to === cn && questState(q) === 'ready')) return '?';
  if (QUESTS.some(q => q.giver === cn && questState(q) === 'new')) return '!';
  return '';
}
function acceptQuest(q) { const P = Game.P; P.quests[q.id] = { n: 0, ready: q.type === 'talk' }; if (q.type === 'special' && Game.flags[q.flag]) P.quests[q.id].ready = true; UI.log(`Görev alındı: ${q.title}`, 'q'); SFX.play('accept_task'); UI.refresh(); save(); }
function questKill(name) {
  const P = Game.P;
  for (const q of QUESTS) {
    const st = P.quests[q.id]; if (!st || st.ready) continue;
    if (q.type === 'kill' && q.target === name) { st.n++; if (st.n >= q.count) readyQuest(q); UI.refresh(); }
    if (q.type === 'collect' && q.target === name && Math.random() < q.chance) { st.n++; UI.log(`${q.item} ${st.n}/${q.count}`, 'loot'); if (st.n >= q.count) readyQuest(q); UI.refresh(); }
  }
}
function questFlag(f) { Game.flags[f] = true; for (const q of QUESTS) { const st = Game.P.quests[q.id]; if (st && !st.ready && q.type === 'special' && q.flag === f) readyQuest(q); } }
function readyQuest(q) { Game.P.quests[q.id].ready = true; SFX.play('message'); UI.toast(`Görev tamamlandı: ${q.title}`); UI.log(`${q.title} tamam. ${trName(q.to)} ile konuş.`, 'q'); }
function completeQuest(q) {
  const P = Game.P, r = q.reward; delete P.quests[q.id]; P.done[q.id] = true; SFX.play('finish_task');
  if (r.gold) P.gold += r.gold; if (r.items) r.items.forEach(([id, n]) => addItem(id, n));
  gainXp(r.xp || 0); UI.log(`Ödül: ${r.xp} TP${r.gold ? ', ' + r.gold + ' altın' : ''}`, 'q');
  UI.refresh(); save();
}
// Görev hedefine otomatik yürü (orijinaldeki "寻路"): teslim edilecek kişi, toplama noktası ya da en yakın hedef canavar
function questWalk(q) {
  const p = Game.player, st = Game.P.quests[q.id], near = f => { let b = null, bd = 1e9; for (const e of Game.ents) if (f(e)) { const d = Math.hypot(e.x - p.x, e.y - p.y); if (d < bd) { bd = d; b = e; } } return b; };
  let t = null;
  if (st && !st.ready) { if (q.type === 'kill' || q.type === 'collect') t = near(e => e.kind === 'mob' && !e.dead && e.name === q.target); else if (q.type === 'pickup') t = near(e => e.kind === 'npc' && e.cn === q.node && !e.hidden); }
  if (!t) t = near(e => e.kind === 'npc' && e.cn === q.to);
  if (!t) return UI.toast('Hedef bu haritada değil.');
  if (t.kind === 'mob') { setTarget(t); p.path = null; return; }
  p.path = findPath(Game.map, p.x, p.y, t.x, t.y + 1); Game.goTarget = t; setTarget(null);
}
function pickupNode(n) {
  const P = Game.P;
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
  if (p.stateT > 0) { p.stateT -= dt; if (p.stateT <= 0) p.state = 'idle'; }
  if (!p.dead) {
    const regen = Game.scene.name === '观林镇' ? 0.03 : p.combatT > 0 ? 0.003 : 0.012;
    p.hp = Math.min(s.hp, p.hp + (s.hp * regen + s.hpreg * 0.02) * dt); p.mp = Math.min(s.mp, p.mp + (s.mp * regen * 1.3 + s.mpreg * 0.02) * dt);
    for (const b of p.buffs) if (b.buff.hot) p.hp = Math.min(s.hp, p.hp + s.hp * b.buff.hot * dt);
    const J = Input.joy();
    let moving = false;
    if (J) {
      p.path = null; p.pending = null; Game.goTarget = null;
      const [cx, cy] = snapScreen4(J.x, J.y), l = 1, sp = RUN * (1 + s.spd) * dt;
      moveEnt(p, cx / l * sp, cy / l * sp); p.dir = dirOf(cx, cy); moving = true;
    } else if ((lastJoyDir = -1, p.state !== 'attack' && p.state !== 'cast')) {
      const t = Game.target;
      if (p.pending != null && t && !t.dead) {
        const sk = CLS[P.cls].skills[p.pending];
        if (Math.hypot(t.x - p.x, t.y - p.y) <= sk.range) useSkill(p.pending); else { stepTo(p, t.x, t.y, RUN * (1 + s.spd), dt, true); moving = true; }
      } else if (t && t.kind === 'mob' && !t.dead && !p.path) {
        const C = CLS[P.cls], d = Math.hypot(t.x - p.x, t.y - p.y);
        if (d > C.range) { stepTo(p, t.x, t.y, RUN * (1 + s.spd), dt, true); moving = true; }
        else if (p.atkT <= 0) {
          p.atkT = 1.1; p.combatT = 5; p.dir = dirOf(t.x - p.x, t.y - p.y);
          if (C.melee) { p.state = 'attack'; p.animT = 0; p.stateT = 0.45; later(0.25, () => { if (!t.dead && Math.hypot(t.x - p.x, t.y - p.y) < C.range + 0.6) { hitMob(t, 1); SFX.play(C.snd); Game.fx.push(new Fx('BLOOD', t.x, t.y)); } }); }
          else { p.state = 'cast'; p.animT = 0; p.stateT = 0.45; SFX.play(C.snd, 0.6); later(0.2, () => shoot(C.bolt, p, t, () => hitMob(t, 0.9))); }
        }
      }
      if (p.path && p.path.length) {
        const [tx, ty] = p.path[0]; if (stepTo(p, tx, ty, RUN * (1 + s.spd), dt, true)) p.path.shift(); moving = true;
        if (!p.path.length) { p.path = null; if (Game.goTarget) { const n = Game.goTarget; Game.goTarget = null; if (Math.hypot(n.x - p.x, n.y - p.y) < 2.2) interact(n); } }
      }
    }
    if (p.state === 'idle' || p.state === 'move') p.state = moving ? 'move' : 'idle';
    const went = Math.hypot(p.x - px0, p.y - py0) * CELL_PX;
    if (p.state === 'move') p.t += went * 8 / STRIDE; else p.t += dt * TICK;
    checkExits();
  }
  // canavarlar
  for (const e of Game.ents) {
    if (e.kind === 'npc') { e.t += dt * TICK * 0.8; if (e.hidden && (e.respawnT -= dt) <= 0) e.hidden = false; continue; }
    if (e.kind !== 'mob') continue;
    e.t += dt * TICK; e.animT = (e.animT || 0) + dt * TICK;
    if (e.dead) { e.deadT += dt; if ((e.respawnT -= dt) <= 0) { Object.assign(e, { dead: false, hp: e.maxHp, x: e.home.x, y: e.home.y, aggro: false, state: 'idle' }); } continue; }
    e.atkT -= dt; e.slowT -= dt; if (e.weakT > 0) e.weakT -= dt;
    if (e.dot && (e.dot.t -= dt) <= 0) { e.dot.t = 2; const D = e.dot; if (--D.n <= 0) e.dot = null; hitMob(e, D.mult); if (e.dead) continue; } if (e.stateT > 0) { e.stateT -= dt; if (e.stateT <= 0) e.state = 'idle'; }
    const dp = Math.hypot(p.x - e.x, p.y - e.y), dh = Math.hypot(e.x - e.home.x, e.y - e.home.y);
    const sp = (e.slowT > 0 ? 1 : 2) * (e.d.rank ? 1.1 : 1);
    if (!e.aggro && !e.d.passive && !p.dead && dp < 3.5 && e.d.lv >= P.lv - 5) e.aggro = true;
    if (e.aggro && (dh > 12 || p.dead)) { e.aggro = false; e.hp = e.maxHp; }
    if (e.state === 'hurt' || e.state === 'attack') continue;
    if (e.aggro && !p.dead) {
      if (dp > 1.3) { stepTo(e, p.x, p.y, sp, dt, true); e.state = 'move'; }
      else { e.dir = dirOf(p.x - e.x, p.y - e.y); if (e.atkT <= 0) { e.atkT = 1.6; e.state = 'attack'; e.animT = 0; e.stateT = 0.5; later(0.3, () => { if (!e.dead && Math.hypot(p.x - e.x, p.y - e.y) < 1.9) hurtPlayer(e); }); } else e.state = 'idle'; }
    } else {
      e.wanderT -= dt;
      if (e.wanderT <= 0) { e.wanderT = rnd(2, 6); e.wx = e.home.x + rnd(-3, 3); e.wy = e.home.y + rnd(-3, 3); if (Game.map.blocked(e.wx, e.wy)) e.wx = null; }
      if (e.wx != null && Math.hypot(e.wx - e.x, e.wy - e.y) > 0.2) { stepTo(e, e.wx, e.wy, 0.8, dt); e.state = 'move'; } else e.state = 'idle';
    }
  }
  // efektler
  for (const f of Game.fx) {
    f.t += dt * TICK; if (f.follow) { f.x = f.follow.x; f.y = f.follow.y; }
    if (f.proj) {
      const t = f.proj.to; if (!t || t.dead) { f.done = true; continue; }
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
    if (e.dummy) { UI.say(e, trName(e.cn) + ': eğitim alanı sergisi.'); return; }
    if (e.pickup) { pickupNode(e); return; }
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
    if (best.kind === 'mob') { setTarget(best); p.path = null; return; }
    if (Math.hypot(best.x - p.x, best.y - p.y) < 2) { interact(best); return; }
    p.path = findPath(Game.map, p.x, p.y, best.x, best.y + 1); Game.goTarget = best; setTarget(null); return;
  }
  const c = Game.map.toCell(W.x, W.y);
  const path = findPath(Game.map, p.x, p.y, c.x, c.y);
  if (path) { p.path = path; setTarget(null); Game.goTarget = null; Game.fx.push(Object.assign(new Fx('路标-左上', Math.round(c.x), Math.round(c.y)), { len: 6 })); }
}
function revive() { const p = Game.player, s = stats(); p.dead = false; p.state = 'idle'; p.hp = Math.round(s.hp * 0.5); p.mp = Math.round(s.mp * 0.5); const P0 = Game.P; if (!P0.home && (P0.done[80003] || P0.quests[80003])) P0.home = ['120005', 33, 20]; const town = P0.home; if (town) gotoScene(town[0], null, town[1] != null ? [town[1], town[2]] : null); else { const r = Game.map.regionsOf(0)[0]; if (r) { p.x = r[2]; p.y = r[3]; } } }
