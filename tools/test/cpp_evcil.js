// C++ ↔ HTML evcil hayvan karşılaştırması (docs/09-cpp.md, 11. adım). Aynı tohum ve aynı saatle aynı işlem dizisi; her adımdan sonra
// hayvanlar (tür, dönüşüm, rastgele beceriler, seviye, deneyim, can, mana, tokluk, mutluluk, yetenek, ölü), çağrılmış olan, taktik, hak,
// hayvanın varlığı (yer, durum, yön, hedef), oyuncu (can, mana, seviye, deneyim, altın), güçlendirmeler (hale), canavarlar (yaşayan,
// toplam can, hayvana saldıran), çanta, son ileti ve bildirim karşılaştırılır. Dövüş adımlarında her saniye.
// Adımlar: kuluçka (Kurt), saldırı ve serbest modda dövüş, ikinci hayvan (Civciv), mama/iksir, acıkma, destek modunda iyileştirme,
// GM seviye/aşama/beceriler, dönüşüm (幻化), beceri aktarma (技能转移), ölüm, diriltme eşyası, 10 dakikada kendiliğinden dirilme, bırakma.
//   node tools/test/cpp_evcil.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_evcil', DT = 1 / 30, NOW = 1800000000000;
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
const uid = i => `Pet.list()[${i}] && Pet.list()[${i}].uid`;
// [C++ komutu, HTML kodu, dövüş saniyesi (0: dövüş yok)]
const STEPS = [
  ['evcilver 狼', 'Pet.GM.give("狼")'], ['evcilgm esya', 'Pet.GM.items()'], ['evcilmod free', 'Pet.setMode("free")'], ['evcilsavas pasif', '', 10],
  ['evcilcagir 0', `Pet.summon(${uid(0)})`], ['evcilsec 0', `Game.P.petSel = ${uid(0)}`], ['esya kullan 30025', 'useItem("30025")'], ['evcilcagir 0', `Pet.summon(${uid(0)})`],
  ['evcilmod attack', 'Pet.setMode("attack")'], ['esya kullan 30022', 'useItem("30022")'], ['evcilgm ac', 'Pet.GM.hungry()'], ['evcilsavas', '', 5],
  ['esya kullan 30022', 'useItem("30022")'], ['esya kullan 30021', 'useItem("30021")'], ['evcilsavas', '', 30],
  ['evcilver 小鸡', 'Pet.GM.give("小鸡")'], ['evcilgeri', 'Pet.dismiss()'], ['evcilcagir 1', `Pet.summon(${uid(1)})`], ['evcilmod support', 'Pet.setMode("support")'],
  ['can 0.5', 'Game.player.hp = stats().hp * 0.5'], ['evcilsavas', '', 10],
  ['evcilgm asama 3', 'Pet.GM.stage(3)'], ['evcilgm beceri', 'Pet.GM.skills()'], ['evcilgm asama 0', 'Pet.GM.stage(0)'],
  ['evcilgeri', 'Pet.dismiss()'], ['evcilcagir 0', `Pet.summon(${uid(0)})`], ['seviye 30', 'gmLevel(30)'], ['evcilgm seviye', 'Pet.GM.level()'], ['evcilgm tf', 'Pet.GM.tf()'],
  ['evcilgeri', 'Pet.dismiss()'], ['evcildonusum 0 2 30164,30731', `Pet.transform(${uid(0)}, ${uid(2)}, ["30164", "30731"])`],
  ['evcilaktar 0 2', `Pet.transferSkill(${uid(0)}, ${uid(2)}, [])`], ['evcildonusum 0 1', `Pet.transform(${uid(0)}, ${uid(1)}, [])`],
  ['evcilcagir 0', `Pet.summon(${uid(0)})`], ['evcilmod free', 'Pet.setMode("free")'], ['evcilcan 0.02', '(q => q && (q.hp = Pet.stats(q).hp * 0.02))(Pet.active())'], ['evcilsavas pasif', '', 15],
  ['saatms ' + (NOW + 700000), `window.__now = ${NOW + 700000}`], ['evcilcagir 0', `Pet.summon(${uid(0)})`],
  ['evcilcan 0.02', '(q => q && (q.hp = Pet.stats(q).hp * 0.02))(Pet.active())'], ['evcilsavas pasif', '', 15], ['evcilsec 0', `Game.P.petSel = ${uid(0)}`], ['esya kullan 30025', 'useItem("30025")'],
  ['evcilcagir 0', `Pet.summon(${uid(0)})`], ['evcilbirak 1', `Pet.release(${uid(1)})`],
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
  await p.evaluate(([M, NOW]) => {
    window.__upd = window.update; window.update = () => {}; SFX.play = () => {}; for (const k of ['zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {};
    window.__t = { log: '', toast: '' }; UI.log = m => { __t.log = m; }; UI.toast = m => { __t.toast = m; };
    window.__now = NOW; Date.now = () => window.__now;
    const P = Game.P; Object.assign(P, { cls: '战士', race: '人类', sex: 'male', lv: 1, xp: 0, gold: 0, bag: [], eq: {}, sk: {}, sp: 0, adv: 0, quests: {}, done: {}, pets: [], petOn: null, petMode: null, petSlots: null, petSel: null }); delete P.home;
    Pet.dismiss(); Game.flags = {}; gmLevel(15); gmGear(); Game.god = true; Game.warnT = 0;
    window.__dump = () => { const L = Pet.list(), P = Game.P, e = Pet.ent, pl = Game.player, mobs = Game.ents.filter(m => m.kind === 'mob');
      return { pets: L.map(q => [q.sp, q.st || 0, (q.sk || []).map(String), q.lv, q.xp, q.hp, q.mp, q.sat, q.joy, q.tal, !!q.dead]), on: L.findIndex(q => q.uid === P.petOn), mod: P.petMode || 'attack', hak: Pet.slots(),
        ent: e ? [e.x, e.y, e.state, e.dir, e.tg ? Game.ents.indexOf(e.tg) : -1] : null, oyuncu: [pl.hp, pl.mp, P.lv, P.xp, P.gold], guc: pl.buffs.map(x => x.id),
        canavar: [mobs.filter(m => !m.dead).length, mobs.filter(m => !m.dead).reduce((a, m) => a + m.hp, 0), mobs.filter(m => !m.dead && e && m.foe === e).length],
        canta: P.bag.map(x => [x.id, x.n]), ileti: __t.log, bildirim: __t.toast, bayrak: !!Game.flags.hatch }; };
    window.__fight = (sec, DT, pas) => { const out = [], per = Math.round(1 / DT), n = Math.round(sec / DT);
      for (let k = 1; k <= n; k++) { if (!pas && (!Game.target || Game.target.dead)) { const m = nearestMob(8); if (m) setTarget(m, true); } window.__upd(DT); if (k % per === 0) out.push(__dump()); }
      return out; };
  }, [MULBERRY, NOW]);
  await p.evaluate(M => { Math.random = eval(M)(7); gotoScene('120030', null, [28, 15], null); }, MULBERRY); await p.waitForFunction(() => Game.sceneId === '120030' && !Game.transit, null, { timeout: 30000 });
  await p.evaluate(() => { const pl = Game.player, s = stats(); pl.hp = s.hp; pl.mp = s.mp; Game.time = 0; __t.log = ''; __t.toast = ''; });
  const html = [await p.evaluate(() => __dump())];
  for (const [c, code, sec] of STEPS) {
    if (sec) html.push(await p.evaluate(([s, DT, pas]) => __fight(s, DT, pas), [sec, DT, c.includes('pasif')]));
    else { await p.evaluate(c => { eval(c); }, code); html.push(await p.evaluate(() => __dump())); }
  }
  await b.close(); if (srv) srv.kill();
  const scen = ['veri www/assets', 'karakter 战士 人类 male', `saatms ${NOW}`, 'seviye 15', 'gmgear', 'olumsuz 1', 'tohum 7', 'sahne 120030 28 15', 'doldur', 'zaman0', 'temizle', 'evcildurum -'];
  STEPS.forEach(([c, , sec], i) => { if (sec) scen.push(`evcilsavas ${DT} ${sec} ${path.join(OUT, 'savas' + i + '.json')}${c.includes('pasif') ? ' pasif' : ''}`); else scen.push(c, 'evcildurum -'); });
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  const lines = execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).split('\n').filter(l => l.startsWith('{')).map(l => JSON.parse(l));
  const cpp = [lines.shift()]; STEPS.forEach(([, , sec], i) => cpp.push(sec ? JSON.parse(fs.readFileSync(path.join(OUT, 'savas' + i + '.json'), 'utf8')) : lines.shift()));
  let bad = 0; const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);
  const show = h => { const q = h.on >= 0 ? h.pets[h.on] : null; return `hayvan ${h.pets.length}${q ? ` · çağrılı ${q[0]} Sv${q[3]} can ${Math.round(q[5])} st${q[1]}` : ''}${h.ent ? ` (${h.ent[2]})` : ''} · canavar ${h.canavar[0]}${h.bildirim ? ' · «' + h.bildirim + '»' : ''}`; };
  for (let i = 0; i < html.length; i++) {
    const name = i ? STEPS[i - 1][0] + (STEPS[i - 1][2] ? ' ' + STEPS[i - 1][2] + ' sn' : '') : 'başlangıç';
    const H = Array.isArray(html[i]) ? html[i] : [html[i]], C = Array.isArray(cpp[i]) ? cpp[i] : [cpp[i]];
    let diff = '';
    if (H.length !== C.length) diff = `satır sayısı HTML ${H.length} · C++ ${C.length}`;
    for (let k = 0; k < H.length && !diff; k++) for (const key of Object.keys(H[k])) if (!same(H[k][key], C[k][key])) { diff = `${H.length > 1 ? (k + 1) + '. sn ' : ''}${key}: HTML ${JSON.stringify(H[k][key]).slice(0, 260)} · C++ ${JSON.stringify(C[k][key]).slice(0, 260)}`; break; }
    console.log(`${String(i).padStart(2)} ${name.padEnd(34)} ${diff ? 'FARKLI ' + diff : 'aynı · ' + show(H[H.length - 1])}`);
    if (diff) bad++;
  }
  if (errs.length) { console.log('HATA', errs); bad++; }
  console.log(bad ? `${bad} adım farklı` : `${html.length} adımın hepsi aynı`);
  process.exitCode = bad ? 1 : 0;
})();
