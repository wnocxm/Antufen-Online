// C++ ↔ HTML görüntü karşılaştırması (docs/09-cpp.md): aynı sahne, aynı konum, aynı karakter, zaman 0.
// HTML tarafında oyunun kendi çizim parçalarıyla (harita zemini, nesne/NPC sprite'ları, karakter katmanları) 640×360 kare çizilir;
// C++ tarafında native/build/anrufen_test aynı kareyi çizer; tools/test/goruntu_fark.py piksel piksel karşılaştırır.
// Canavarlar da çizilir: zar iki tarafta aynı tohumlu üreteçten (mulberry32), yerleşimleri aynı. Girmeyenler: ayak gölgeleri, adlar, arayüz.
//   node tools/test/cpp_karsilastir.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_karsilastir';
// [ad, sahne, x, y, yön, sınıf, ırk, cinsiyet]
const CASES = [
  ['guanlin', '120005', 33, 20, 2, '战士', '人类', 'male'],
  ['guanlin_y0', '120005', 26, 12, 0, '战士', '人类', 'male'],
  ['elf_kamp', '120205', 0, 0, 1, '法师', '精灵', 'fema'],
  ['liman', '120094', 30, 30, 3, '牧师', '人类', 'fema'],
  ['bozbalta', '120156', 48, 30, 2, '战士', '精灵', 'male'],
  ['ruh_arafi', '120495', 0, 0, 2, '法师', '人类', 'male'],
  ['orumcek', '120018', 40, 75, 1, '战士', '人类', 'male'],   // 24 canavar
];
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMKarsilastir'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const scen = ['veri www/assets', 'golge 0', 'ekran 640 360', `sahne ${await p.evaluate(() => Game.sceneId)}`];
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; SFX.play = () => {}; });   // döngü durur: canavarlar yerinde kalır
  for (const [ad, sid, x, y, dir, cls, race, sex] of CASES) {
    await p.evaluate(([M, seed]) => { Math.random = eval(M)(seed); }, [MULBERRY, 7]);
    await p.evaluate(s => gotoScene(s, null, null, null), sid);
    await p.waitForFunction(s => Game.sceneId === s && Game.player && !Game.transit, sid, { timeout: 30000 });
    // konum (0,0 = sahnenin girişi, oyunun seçtiği yer), karakter, zaman 0; görsellerin yüklenmesini bekle
    const pos = await p.evaluate(([x, y, dir, cls, race, sex]) => {
      const P = Game.P, pl = Game.player; P.cls = cls; P.race = race; P.sex = sex; P.eq = {}; pl.doll.set(look());
      if (x || y) { pl.x = x; pl.y = y; } pl.dir = dir; pl.t = 0; pl.state = 'idle'; pl.combatT = 0; Game.time = 0;
      for (const e of Game.ents) e.t = 0;
      return [pl.x, pl.y];
    }, [x, y, dir, cls, race, sex]);
    await p.waitForTimeout(1500);
    const url = await p.evaluate(() => {
      const W = 640, H = 360, cv = document.createElement('canvas'); cv.width = W; cv.height = H; const ctx = cv.getContext('2d'); ctx.imageSmoothingEnabled = false;
      const map = Game.map, pl = Game.player, ox = Math.round(pl.X - W / 2), oy = Math.round(pl.Y - 40 - H / 2);
      ctx.fillStyle = '#000'; ctx.fillRect(0, 0, W, H);
      const sx = Math.max(0, ox), sy = Math.max(0, oy), ex = Math.min(map.pw, ox + W), ey = Math.min(map.ph, oy + H);
      if (ex > sx && ey > sy) ctx.drawImage(map.ground, sx, sy, ex - sx, ey - sy, sx - ox, sy - oy, ex - sx, ey - sy);
      const list = [];
      for (const o of map.objs) {
        if (o.X < ox - 350 || o.X > ox + W + 350 || o.Y < oy - 40 || o.Y > oy + H + 450) continue;
        if (o.flat) { o.sp.draw(ctx, o.anim, 0, o.X - ox, o.Y - oy); continue; }
        list.push([o.depth, o]);
      }
      for (const e of Game.ents) { if (!['player', 'npc', 'mob'].includes(e.kind)) continue; const X = e.X, Y = e.Y; if (X < ox - 100 || X > ox + W + 100 || Y < oy - 20 || Y > oy + H + 150) continue; list.push([e.x + e.y + 0.01, e]); }
      list.sort((a, b) => a[0] - b[0]);
      for (const [, o] of list) { if (o.kind === 'obj') o.sp.draw(ctx, o.anim, 0, o.X - ox, o.Y - oy); else o.draw(ctx, o.X - ox, o.Y - oy); }
      return cv.toDataURL();
    });
    fs.writeFileSync(path.join(OUT, ad + '_html.png'), Buffer.from(url.split(',')[1], 'base64'));
    scen.push('tohum 7', `karakter ${cls} ${race} ${sex}`, `sahne ${sid}`, `konum ${pos[0]} ${pos[1]}`, `yon ${dir}`, 'saat0', `goruntu ${path.join(OUT, ad + '_cpp.png')}`);
  }
  // yürüme: Guanlin'de aynı kareden dört yöne 0,5 sn (oyun döngüsü durdurulur, 1/60 sn adımlarla); tuşlar HTML'deki gibi
  await p.evaluate(s => gotoScene(s, null, null, null), '120005');
  await p.waitForFunction(() => Game.sceneId === '120005' && Game.player && !Game.transit, null, { timeout: 30000 });
  const WALK = [['sag', 'd'], ['sol', 'a'], ['yukari', 'w'], ['asagi', 's'], ['sag+yukari', 'dw'], ['sol+asagi', 'as']], walkHtml = {};
  for (const [ad, keys] of WALK) {
    walkHtml[ad] = await p.evaluate(keys => {
      const pl = Game.player, up = window.__upd;
      Game.ents = Game.ents.filter(e => e.kind !== 'mob'); pl.x = 33; pl.y = 20; pl.dir = 2; pl.t = 0; pl.state = 'idle'; pl.path = null; Game.engage = false;
      for (const k of keys) Input.keys[k] = true;
      for (let i = 0; i < 30; i++) up(1 / 60);
      for (const k of keys) Input.keys[k] = false; up(0);
      return [pl.x, pl.y, pl.dir, pl.t];
    }, keys);
    scen.push('sahne 120005', 'konum 33 20', 'yon 2', 'saat0', `yuru ${ad} 0.5`, `durum ${path.join(OUT, 'yuru_' + ad.replace('+', '_') + '.json')}`);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  // tarayıcının yarı saydam piksel yuvarlaması taklit edilir (gerçek oyunda kapalı: C++ alevleri kayıpsız, HTML benekli çizer)
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'], env: Object.assign({}, process.env, { ANRUFEN_TARAYICI_ALFA: '1' }) });
  let out = ''; try { out = execFileSync('python3', ['tools/test/goruntu_fark.py', OUT, ...CASES.map(c => c[0])]).toString(); } catch (e) { out = e.stdout.toString(); process.exitCode = 1; }
  process.stdout.write(out);
  for (const [ad] of WALK) {
    const c = JSON.parse(fs.readFileSync(path.join(OUT, 'yuru_' + ad.replace('+', '_') + '.json'), 'utf8')), h = walkHtml[ad];
    const ok = Math.abs(c.x - h[0]) < 1e-3 && Math.abs(c.y - h[1]) < 1e-3 && c.yon === h[2] && Math.abs(c.t - h[3]) < 1e-3;
    if (!ok) process.exitCode = 1;
    console.log(`yürüme ${ad.padEnd(11)} HTML (${h[0].toFixed(3)}, ${h[1].toFixed(3)}) yön ${h[2]} t ${h[3].toFixed(3)} · C++ (${c.x.toFixed(3)}, ${c.y.toFixed(3)}) yön ${c.yon} t ${c.t.toFixed(3)} · ${ok ? 'AYNI' : 'FARKLI'}`);
  }
  if (errs.length) console.log('HATA', errs);
})();
