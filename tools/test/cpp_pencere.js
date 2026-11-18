// C++ ↔ HTML pencere karşılaştırması (docs/09-cpp.md): konuşma (kişinin sözü ve seçenekleri; bir göreve dokununca görev metni),
// görev listesi (Aktif, Alınabilir; seçili görevin bilgi kartı), ana menü, ölüm penceresi, onay kutusu (görevi bırak). Pencereler iki
// tarafta aynı ekran noktalarına dokunularak açılır/ilerletilir (dokunma bölgeleri de sınanır). Her durum için iki kare:
//   <ad>_yazisiz (piksel; sınır SINIR, varsayılan %2) ve <ad>_yazili (yan yana göz denetimi; tools/test/cpp_arayuz.js gibi).
//   node tools/test/cpp_pencere.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_pencere';
const F2 = JSON.parse(fs.readFileSync('www/assets/forms2.json', 'utf8'));
const rect = (f, id) => F2[f].c.find(c => c.id === id).s[0].r;
// form biriminden ekrana (win.js nBegin): x = safeL + fx·k, y = (fy - oy)·k
const at = (f, id, k, oy = 0, dx = 0, dy = 0) => { const r = rect(f, id); return [(r[0] + dx + r[2] / 2) * k, (r[1] + dy + r[3] / 2 - oy) * k]; };
const kN = 360 / 373, kT = 360 / 320;
// [ad, eylemler]: eylem = ['pencere', ad, varlık?] | ['dokun', x, y]
const CASES = [
  ['konusma', [['pencere', 'npc', 10]]],
  ['konusma_gorev', [['pencere', 'npc', 10], ['dokun', ...at('npc_dialogue', 50289, kN)]]],
  ['konusma_yeni', [['pencere', 'npc', 10], ['dokun', ...at('npc_dialogue', 50290, kN)]]],
  ['gorevler', [['pencere', 'task']]],
  ['gorevler_alinabilir', [['pencere', 'task'], ['dokun', (116 + 50) * kT, (312 + 13 - 42) * kT]]],   // Alınabilir düğmesi
  ['menu', [['pencere', 'hub']]],
  ['olum', [['pencere', 'dead']]],
  ['onay', [['pencere', 'task'], ['dokun', (10 + 50) * kT, (312 + 13 - 42) * kT], ['dokun', ...at('item_info', 50424, kT, 42, 232, 62)]]],   // Aktif'e dön, Bırak
];
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, deviceScaleFactor: 1, locale: 'tr-TR' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kahraman'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; SFX.play = () => {}; for (const k of ['log', 'toast', 'zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {};
    const C = CanvasRenderingContext2D.prototype; window.__ft = [C.fillText, C.strokeText]; });
  await p.waitForTimeout(10500);   // açılış ipuçları sönsün
  // durum: Sv 8 insan savaşçı, Guanlin'e varmış (80004 bitti), Domuz Avı (80439) alınmış
  await p.evaluate(M => { const P = Game.P; Object.assign(P, { cls: '战士', race: '人类', sex: 'male', face: '1001', name: 'Kahraman', eq: {}, bag: [], gold: 0, xp: 0, lv: 1, sk: {}, adv: 0, quests: {}, done: {} }); gmLevel(8);
    ClassGM.done(80004); P.quests[80439] = { n: 0, ready: false }; Math.random = eval(M)(7); },
    `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`);
  await p.evaluate(() => gotoScene('120005', null, [10, 25], null));
  await p.waitForFunction(() => Game.sceneId === '120005' && Game.player && !Game.transit, null, { timeout: 30000 });
  await p.evaluate(() => { const pl = Game.player, s = stats(); pl.doll.set(look()); pl.hp = s.hp; pl.mp = s.mp; Game.time = 0; pl.t = 0; pl.state = 'idle'; pl.combatT = 0; for (const e of Game.ents) e.t = 0; window.__upd(0); setTarget(null); });
  await p.waitForTimeout(1500);
  const scen = ['veri www/assets', 'golge 1', 'ekran 640 360', 'arayuz 1', 'tohum 7', 'karakter 战士 人类 male', 'ad Kahraman', 'portre 1001', 'seviye 8',
    `gmbitir 80004 ${path.join(OUT, 'gm.json')}`, 'gorevver 80439', 'sahne 120005 10 25', 'saat0', 'doldur', 'temizle'];
  for (const [ad, acts] of CASES) {
    for (const a of acts) {
      // pencere açılınca bir kare çizilir (dokunma bölgeleri çizimde kurulur; gerçek oyunda dokunuştan önce hep kare vardır)
      if (a[0] === 'pencere') { await p.evaluate(([n, e]) => { Win.close(); Win.open(n, n === 'npc' ? { npc: Game.ents[e] } : {}); }, [a[1], a[2]]); await p.waitForTimeout(150); }
      else { await p.evaluate(([x, y]) => Win.tap(x, y), [a[1], a[2]]); await p.waitForTimeout(150); }
      scen.push(a[0] === 'pencere' ? `pencere ${a[1]}${a[2] != null ? ' ' + a[2] : ''}` : `dokun ${a[1]} ${a[2]}`, 'ciz');
    }
    await p.waitForTimeout(1200);   // görseller yüklensin, basılı vurgusu sönsün
    for (const yazi of [0, 1]) {
      await p.evaluate(on => { const C = CanvasRenderingContext2D.prototype; if (on) [C.fillText, C.strokeText] = window.__ft; else C.fillText = C.strokeText = () => {}; }, yazi);
      await p.waitForTimeout(300);
      await p.screenshot({ path: path.join(OUT, `${ad}_${yazi ? 'yazili' : 'yazisiz'}_html.png`), clip: { x: 0, y: 0, width: 640, height: 360 } });
    }
    scen.push('yazi 0', `goruntu ${path.join(OUT, ad + '_yazisiz_cpp.png')}`, 'yazi 1', `goruntu ${path.join(OUT, ad + '_yazili_cpp.png')}`);
    await p.evaluate(() => Win.close()); scen.push('pencere kapat');
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'], env: Object.assign({}, process.env, { ANRUFEN_TARAYICI_ALFA: '1' }) });
  const run = (lim, list) => { try { return execFileSync('python3', ['tools/test/goruntu_fark.py', OUT, ...list], { env: Object.assign({}, process.env, { SINIR: lim }) }).toString(); } catch (e) { process.exitCode = 1; return e.stdout.toString(); } };
  process.stdout.write('yazısız (piksel):\n' + run(process.env.SINIR || '2', CASES.map(c => c[0] + '_yazisiz')));
  process.stdout.write('yazılı (göz denetimi; yan yana: <ad>_yazili_fark.png):\n' + run('100', CASES.map(c => c[0] + '_yazili')));
  if (errs.length) { console.log('HATA', errs); process.exitCode = 1; }
})();
