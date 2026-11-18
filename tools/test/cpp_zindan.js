// C++ ↔ HTML zindan karşılaştırması (docs/09-cpp.md, 10. adım). Aynı tohumla aynı işlem dizisi; her adımdan sonra harita, yer,
// zindan koşusu (kimlik, kopya, kesilen sayısı, boss), günlük sayaç, altın, çanta, canavarlar (ad, can, saldırı, savunma, boss, ölü),
// son ileti, bildirim ve onay kutusu sorusu karşılaştırılır. Adımlar: Mehtap Korusu (kapı, onay, giriş, temizleme, son kat ve geri:
// kesilenler doğmaz, boss sandığı, "çıkılsın mı?", çıkış; ikinci girişte ölüm → kapının dışı; üçüncü giriş + çıkış; dördüncüde günlük
// hak bitti; düşük seviye), Sınav Ormanı (zayıf canavarlar, sınırsız), Alacakaranlık Vadisi (ön görev yok), zindan ışınlayıcıları
// (Subay, Dağ Cücesi Bilgin: seviye şartı), Ruh Balkonu'nun yanlış bağlı çıkışı, Ölüm Yabanı (son kat boss'u).
//   node tools/test/cpp_zindan.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_zindan';
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
const YES = '__ask && (() => { const y = __ask.y; __ask = null; y(); })()';
const door = r => [`kapi ${r}`, `Game.warnT = 0; Dungeon.door(${r})`, 0];
const lv = n => [`seviye ${n}`, `gmLevel(${n})`, 0];
// [C++ komutu, HTML kodu, harita yüklenir mi]
const STEPS = [
  ['zindankapi myk 0', 'Dungeon.GM.door("myk", 0)', 1], door(5), ['evet', YES, 1],
  ['gmtemizle', 'Dungeon.GM.clear()', 0], ['gmsonkat', 'Dungeon.GM.lastFloor()', 1], ['gmsonkat', 'Dungeon.GM.lastFloor()', 1], ['gmsonkat', 'Dungeon.GM.lastFloor()', 1],
  ['gmboss', 'Dungeon.GM.boss()', 0], ['bekle 2', 'for (let k = 0; k < 120; k++) __upd(1 / 60)', 0], ['evet', YES, 1],
  door(5), ['evet', YES, 1], ['dirilt', 'revive()', 1],
  door(5), ['evet', YES, 1], ['zindancik', 'Dungeon.GM.leave()', 1], door(5),
  lv(25), ['gmsifirla', 'Dungeon.GM.reset()', 0], door(5),
  lv(22), ['zindankapi slf 0', 'Dungeon.GM.door("slf", 0)', 1], door(3), ['evet', YES, 1], ['gmtemizle', 'Dungeon.GM.clear()', 0], ['dirilt', 'revive()', 1],
  lv(40), ['zindankapi svd 0', 'Dungeon.GM.door("svd", 0)', 1], door(3),
  ['isinla 噬魂远征军军官', 'Dungeon.npcTp("噬魂远征军军官")[0].go()', 1], ['isinla 矮人学者', 'Dungeon.npcTp("矮人学者")[0].go()', 0],
  lv(50), ['isinla 矮人学者', 'Dungeon.npcTp("矮人学者")[0].go()', 1],
  ['geciste 1 0.03333333333333333', 'const r = Game.map.regionsOf(1).find(g => g[0] === 1), p = Game.player; p.x = Math.round((r[2] + r[4]) / 2); p.y = Math.round((r[3] + r[5]) / 2); Game.arriveT = 0; Game.warnT = 0; __upd(1 / 30)', 1],
  lv(40), ['zindankapi swy 0', 'Dungeon.GM.door("swy", 0)', 1], door(5), ['evet', YES, 1], ['gmsonkat', 'Dungeon.GM.lastFloor()', 1], ['gmboss', 'Dungeon.GM.boss()', 0],
];
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, locale: 'tr-TR' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kahraman'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(M => {
    window.__upd = window.update; window.update = () => {}; SFX.play = () => {}; for (const k of ['zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {};
    window.__t = { log: '', toast: '' }; UI.log = m => { __t.log = m; }; UI.toast = m => { __t.toast = m; };
    window.__ask = null; Win.ask = (t, y) => { __ask = { t, y }; };
    window.__loads = 0; const L0 = loadScene; window.loadScene = async (...a) => { const r = await L0(...a); window.__loads++; return r; };
    const P = Game.P; Object.assign(P, { cls: '战士', race: '人类', sex: 'male', lv: 1, xp: 0, gold: 0, bag: [], eq: {}, sk: {}, sp: 0, adv: 0, quests: {}, done: {}, dun: null, dg: null }); delete P.home;
    Game.flags = {}; gmLevel(30); gmGear(); Game.god = true; Game.warnT = 0; Math.random = eval(M)(7);
    window.__dump = () => { const P = Game.P, pl = Game.player;
      return { sahne: Game.sceneId, x: pl.x, y: pl.y, dun: P.dun ? [P.dun.id, P.dun.copy, Object.keys(P.dun.cleared).length, P.dun.boss] : null,
        dg: P.dg ? Object.entries(P.dg.n).sort() : [], altin: P.gold, canta: P.bag.map(x => [x.id, x.n]),
        mobs: Game.ents.filter(e => e.kind === 'mob').map(m => [m.name, m.hp, m.maxHp, m.atk, m.def, !!m.boss, !!m.dead]), ileti: __t.log, bildirim: __t.toast, soru: __ask ? __ask.t : '' }; };
  }, MULBERRY);
  const html = [await p.evaluate(() => __dump())];
  for (const [, code, load] of STEPS) {
    const n0 = await p.evaluate(() => window.__loads);
    await p.evaluate(c => { eval(c); }, code);
    if (load) await p.waitForFunction(n => window.__loads > n && !Game.transit, n0, { timeout: 30000 });
    await p.waitForTimeout(load ? 250 : 30);
    html.push(await p.evaluate(() => __dump()));
  }
  await b.close(); if (srv) srv.kill();
  const scen = ['veri www/assets', 'karakter 战士 人类 male', 'sahne 120207 3 13', 'seviye 30', 'gmgear', 'olumsuz 1', 'tohum 7', 'temizle', 'zindandurum -'];
  for (const [c] of STEPS) scen.push(c, 'zindandurum -');
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  const cpp = execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).split('\n').filter(l => l.startsWith('{')).map(l => JSON.parse(l));
  let bad = 0; const near = (a, b) => JSON.stringify(a) === JSON.stringify(b);
  for (let i = 0; i < html.length; i++) {
    const h = html[i], c = cpp[i], name = i ? STEPS[i - 1][0] : 'başlangıç';
    if (!c) { console.log(`${name}: C++ çıktısı yok`); bad++; break; }
    const diff = Object.keys(h).filter(k => !near(h[k], c[k]));
    const live = h.mobs.filter(m => !m[6]).length, boss = h.mobs.filter(m => m[5] && !m[6]).length;
    console.log(`${String(i).padStart(2)} ${name.padEnd(30)} ${diff.length ? 'FARKLI ' + diff.join(', ') : 'aynı'} · ${h.sahne} (${(+h.x).toFixed(0)},${(+h.y).toFixed(0)}) koşu ${h.dun ? h.dun.join('/') : '-'} · canavar ${live}${boss ? ' (boss ' + boss + ')' : ''} · altın ${h.altin}${h.bildirim ? ' · «' + h.bildirim + '»' : ''}`);
    if (diff.length) { bad++; for (const k of diff.slice(0, 2)) console.log(`     ${k}: HTML ${JSON.stringify(h[k]).slice(0, 300)}\n     ${' '.repeat(k.length)}  C++  ${JSON.stringify(c[k]).slice(0, 300)}`); }
  }
  if (errs.length) { console.log('HATA', errs); bad++; }
  console.log(bad ? `${bad} adım farklı` : `${html.length} adımın hepsi aynı`);
  process.exitCode = bad ? 1 : 0;
})();
