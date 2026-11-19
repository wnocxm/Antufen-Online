// C++ ↔ HTML yol bulma ve yürüme karşılaştırması (docs/09-cpp.md):
//   1) A* yolları (HTML findPath): üç haritada 20'şer rastgele nokta çifti (hedef geçilmezse en yakın boş kare dahil),
//   2) kişiye yürü (walkToEnt): Guanlin'de başlangıca uzak ilk kişiye; varınca konuşma penceresi açılır,
//   3) görev "Yol Bul" (questWalk): Domuz Avı alınmış → geçitlerden domuzların haritasına, en yakın domuzu seçer,
//   4) teslim: görev hazır → aynı yoldan Guanlin'e, muhtara yürür, konuşma açılır.
// Haritalar arası geçişte HTML'de yeni harita eşzamansız yüklenir: test kareleri durdurur, yüklenince 0,5 sn bekler (routeStep
// setTimeout 400) ve sürdürür; C++'ta "rotagecikme 0" (varışın ilk karesinde yola devam). Zar iki tarafta aynı tohumla.
// Karşılaştırılan: yollar, her varıştaki harita ve yer, sondaki harita, yer, hedef, konuşma.
//   node tools/test/cpp_yol.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
// DIL=en: İngilizce kip (HTML localStorage anrufen_lang = en; C++ "dil en")
const DIL = process.env.DIL === 'en' ? ['dil en'] : [];
const OUT = process.env.OUT || '/tmp/cpp_yol', DT = 1 / 30;
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
let seed = 12345; const rnd = n => { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return seed % n; };
(async () => {
  fs.mkdirSync(OUT, { recursive: true }); const yolF = path.join(OUT, 'yol_cpp.txt'); if (fs.existsSync(yolF)) fs.unlinkSync(yolF);
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, locale: 'tr-TR' })).newPage(); if (DIL.length) await p.addInitScript(() => localStorage.setItem('anrufen_lang', 'en'));
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kahraman'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; window.__snd = []; SFX.play = (n, v = 1) => { if (n) __snd.push([n, v]); }; SFX.Music.play = n => { if (n) __snd.push(['muzik', n]); }; for (const k of ['log', 'toast', 'zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {}; });
  const waitScene = () => p.waitForFunction(() => !Game.transit && Game.player, null, { timeout: 30000 });
  const go = async (sid, x, y) => { await p.evaluate(([s, x, y]) => gotoScene(s, null, [x, y], null), [sid, x, y]); await waitScene(); };
  const scen = ['veri www/assets', ...DIL];
  // 1) A* yolları
  const yolH = [];
  for (const sid of ['120005', '120018', '120004']) {
    await go(sid, 10, 10); scen.push(`sahne ${sid} 10 10`);
    const [W, H] = await p.evaluate(() => [Game.map.w, Game.map.h]);
    for (let i = 0; i < 20; i++) {
      const q = [rnd(W), rnd(H), rnd(W), rnd(H)];
      yolH.push(await p.evaluate(q => { const r = findPath(Game.map, ...q); return r ? (r.length ? r.map(a => a.join(',')).join(' ') : '-') : 'yok'; }, q));
      scen.push(`yol ${q.join(' ')} ${yolF}`);
    }
  }
  // karakter: Sv 8 insan savaşçı, Guanlin'e varmış (80004), ölümsüz (GM)
  await p.evaluate(M => { const P = Game.P; Object.assign(P, { cls: '战士', race: '人类', sex: 'male', lv: 1, xp: 0, gold: 0, bag: [], eq: {}, sk: {}, sp: 0, adv: 0, quests: {}, done: {} }); delete P.home;
    Game.flags = {}; gmLevel(8);
    ClassGM.done(80004); Game.god = true; Game.target = null; Math.random = eval(M)(7); }, MULBERRY);
  scen.push('karakter 战士 人类 male', 'seviye 8', `gmbitir 80004 ${path.join(OUT, 'gm.json')}`, 'olumsuz 1', 'rotagecikme 0', 'tohum 7');
  // HTML'de kareleri ilerlet; harita değişince yüklenmesini ve yola devamı (setTimeout 400) bekle
  const run = async sec => {
    let left = Math.round(sec / DT); const varis = [];
    while (left > 0) {
      const r = await p.evaluate(([n, DT]) => { let k = 0; for (; k < n; k++) { window.__upd(DT); if (Game.transit) { k++; break; } } return { k, transit: !!Game.transit }; }, [left, DT]);
      left -= r.k;
      if (r.transit) { await waitScene(); varis.push(await p.evaluate(() => [Game.sceneId, Game.player.x, Game.player.y])); await p.waitForTimeout(500); }
    }
    return Object.assign({ varis }, await p.evaluate(() => ({ sahne: Game.sceneId, x: Game.player.x, y: Game.player.y, hedef: Game.target ? Game.ents.indexOf(Game.target) : -1, konusma: Win.cur === 'npc', ses: __snd.splice(0) })));
  };
  const html = {};
  // 2) kişiye yürü
  await go('120005', 10, 25);
  const ki = await p.evaluate(() => { Game.time = 0; Win.close(); __snd = []; const i = Game.ents.findIndex(e => e.kind === 'npc' && !e.hidden && Math.hypot(e.x - 10, e.y - 25) > 12); walkToEnt(Game.ents[i]); return i; });
  html.kisiye = await run(15);
  scen.push('sahne 120005 10 25', 'zaman0', 'sestemizle', `kisiyeyuru ${ki}`, `ilerle ${DT} 15 ${path.join(OUT, 'kisiye.json')}`);
  // 3) görev yol bul: Domuz Avı
  await p.evaluate(() => { Win.close(); __snd = []; Game.P.quests[80439] = { n: 0, ready: false }; questWalk(QBY[80439]); });
  html.gorev = await run(60);
  scen.push('sestemizle', 'gorevver 80439', 'gorevyuru 80439', `ilerle ${DT} 60 ${path.join(OUT, 'gorev.json')}`);
  // 4) teslim: görev hazır → muhtara
  await p.evaluate(() => { Win.close(); __snd = []; Game.P.quests[80439] = { n: 20, ready: true }; questWalk(QBY[80439]); });
  html.teslim = await run(60);
  scen.push('sestemizle', 'gorevhazir 80439 20', 'gorevyuru 80439', `ilerle ${DT} 60 ${path.join(OUT, 'teslim.json')}`);
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  let bad = 0;
  const yolC = fs.readFileSync(yolF, 'utf8').trim().split('\n');
  const yd = yolH.map((h, i) => h === yolC[i] ? null : i).filter(i => i != null);
  console.log(`A* yolları: ${yolH.length} çift (${yolH.filter(x => x === 'yok').length} yolsuz), ${yd.length ? 'FARKLI ' + yd.length + ' (ilk #' + yd[0] + ')' : 'hepsi aynı'}`); if (yd.length) bad++;
  const near = (a, b) => typeof a === 'number' ? Math.abs(a - b) < 1e-6 : a === b;
  for (const ad of ['kisiye', 'gorev', 'teslim']) {
    const c = JSON.parse(fs.readFileSync(path.join(OUT, ad + '.json'), 'utf8')), h = html[ad]; c.konusma = c.konusma >= 0;
    let diff = '';
    if (c.varis.length !== h.varis.length) diff = `varış sayısı HTML ${h.varis.length} · C++ ${c.varis.length}`;
    for (let i = 0; i < Math.min(c.varis.length, h.varis.length) && !diff; i++) for (let k = 0; k < 3; k++) if (!near(h.varis[i][k], c.varis[i][k])) diff = `${i + 1}. varış: HTML ${h.varis[i]} · C++ ${c.varis[i]}`;
    for (const k of ['sahne', 'x', 'y', 'hedef', 'konusma']) if (!diff && !near(h[k], c[k])) diff = `${k}: HTML ${h[k]} · C++ ${c[k]}`;
    if (!diff && JSON.stringify(h.ses) !== JSON.stringify(c.ses)) diff = `ses: HTML ${JSON.stringify(h.ses)} · C++ ${JSON.stringify(c.ses)}`;
    console.log(`${ad.padEnd(7)} ${diff ? 'FARKLI ' + diff : 'aynı'} (haritalar: ${h.varis.map(v => v[0]).join(' → ') || '-'}; son ${h.sahne} (${(+h.x).toFixed(2)}, ${(+h.y).toFixed(2)}), hedef ${h.hedef}, konuşma ${h.konusma ? 'açık' : 'yok'}, ses ${h.ses.map(x => x[0] === 'muzik' ? '♪' + x[1] : x[0]).join(' ') || '-'})`);
    if (diff) bad++;
  }
  if (errs.length) { console.log('HATA', errs); bad++; }
  process.exitCode = bad ? 1 : 0;
})();
