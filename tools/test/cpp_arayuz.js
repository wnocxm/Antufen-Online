// C++ ↔ HTML oyun ekranı (HUD) karşılaştırması (docs/09-cpp.md): aynı durum (sahne, karakter, hedef, görevler, bekleme, can/mana),
// HTML'de oyunun kendi çizimi (drawWorld + drawHud; ekran görüntüsü), C++'ta anrufen_test "arayuz 1". İki kare:
//   <ad>_yazisiz: yazılar kapalı → piksel piksel (tools/test/goruntu_fark.py; sınır SINIR, varsayılan %1,5: kenar yumuşatması, görsel
//                 küçültme ve tarayıcının alfa yuvarlaması küçük farklar bırakır),
//   <ad>_yazili:  yazılar açık → yan yana göz denetimi (yazı tarayıcıda farklı yumuşatılır; fark yüzdesi bilgi için).
// Duyurular, günlük ve uçan sayılar iki tarafta da kapalı (kare sayacına bağlı); onlar göz denetiminde.
//   node tools/test/cpp_arayuz.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_arayuz';
// [ad, sahne, x, y, sınıf, ırk, cinsiyet, portre, seviye, [yükseltme, uzmanlık], hedef (varlık sırası; -1 yok, 'yakın' en yakın canavar,
//  'kişi' en yakın kişi), can, mana, bekleme [beceri, sn] | null, görev (alınmış görev numaraları)]
const CASES = [
  ['orman', '120018', 40, 75, '战士', '人类', 'male', '1001', 12, [0, 0], 'yakın', 0.62, 0.4, ['w2', 0.6], [80024, 80039]],
  ['kasaba', '120005', 33, 20, '牧师', '精灵', 'fema', '4003', 30, [0, 0], 'kişi', 1, 1, null, [80004]],
  ['buyucu', '120014', 10, 53, '法师', '精灵', 'male', '3002', 60, [1, 0], 'yakın', 0.2, 0.05, ['m1', 1.0], []],
];
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, deviceScaleFactor: 1, locale: 'tr-TR' })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kahraman'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  // oyun döngüsü durur (çizim sürer); arayüz olayları kapalı (kare sayacına bağlı: iki tarafta aynı ana denk getirilemez)
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; SFX.play = () => {}; for (const k of ['log', 'toast', 'zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {};
    const C = CanvasRenderingContext2D.prototype; window.__ft = [C.fillText, C.strokeText]; });
  await p.waitForTimeout(10500);   // açılıştaki ipucu mesajları (10 sn) sönsün
  const scen = ['veri www/assets', 'golge 1', 'ekran 640 360', 'arayuz 1'], names = [];
  for (const [ad, sid, x, y, cls, race, sex, face, lv, bec, tg, hp, mp, cd, qs] of CASES) {
    await p.evaluate(([cls, race, sex, face, lv, bec, qs, M]) => {
      const P = Game.P; Object.assign(P, { cls, race, sex, face, name: 'Kahraman', eq: {}, bag: [], gold: 0, xp: 0, lv: 1, sk: {}, adv: 0, quests: {}, done: {} }); gmLevel(lv);
      P.adv = bec[0]; P.sk = {}; P.sp = 0; skillAutoSpend(lv + 1, bec[1]);
      for (const id of qs) P.quests[id] = { n: 0, ready: false };
      Math.random = eval(M)(7);
    }, [cls, race, sex, face, lv, bec, qs, MULBERRY]);
    await p.evaluate(([s, x, y]) => gotoScene(s, null, [x, y], null), [sid, x, y]);
    await p.waitForFunction(s => Game.sceneId === s && Game.player && !Game.transit, sid, { timeout: 30000 });
    const ti = await p.evaluate(([tg, hp, mp, cd]) => {
      const pl = Game.player, s = stats(); pl.doll.set(look()); pl.hp = s.hp * hp; pl.mp = s.mp * mp; Game.time = 0; pl.t = 0; pl.state = 'idle'; pl.combatT = 0;
      for (const e of Game.ents) e.t = 0;
      let t = null;
      if (tg === 'yakın') t = nearestMob(30);
      else if (tg === 'kişi') { let bd = 1e9; for (const e of Game.ents) if (e.kind === 'npc' && !e.dummy && !e.hidden) { const d = Math.hypot(e.x - pl.x, e.y - pl.y); if (d < bd) { bd = d; t = e; } } }
      window.__upd(0);   // kamera (C++'ta "saat0" da bir kez günceller)
      setTarget(t); if (cd) pl.cds[cd[0]] = cd[1];
      return t ? Game.ents.indexOf(t) : -1;
    }, [tg, hp, mp, cd]);
    await p.waitForTimeout(2000);   // arayüz görselleri yüklensin
    for (const yazi of [0, 1]) {
      await p.evaluate(on => { const C = CanvasRenderingContext2D.prototype; if (on) [C.fillText, C.strokeText] = window.__ft; else C.fillText = C.strokeText = () => {}; }, yazi);
      await p.waitForTimeout(300);
      await p.screenshot({ path: path.join(OUT, `${ad}_${yazi ? 'yazili' : 'yazisiz'}_html.png`), clip: { x: 0, y: 0, width: 640, height: 360 } });
    }
    scen.push('tohum 7', `karakter ${cls} ${race} ${sex}`, `ad Kahraman`, `portre ${face}`, `seviye ${lv}`, `ust ${bec[0]}`, `dagit ${lv + 1} ${bec[1]}`);
    for (const id of qs) scen.push(`gorevver ${id}`);
    scen.push(`sahne ${sid} ${x} ${y}`, 'saat0', `can ${hp}`, `mana ${mp}`, `hedefle ${ti}`);
    if (cd) scen.push(`bekleme ${cd[0]} ${cd[1]}`);
    scen.push('temizle', 'yazi 0', `goruntu ${path.join(OUT, ad + '_yazisiz_cpp.png')}`, 'yazi 1', `goruntu ${path.join(OUT, ad + '_yazili_cpp.png')}`);
    names.push(ad);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'], env: Object.assign({}, process.env, { ANRUFEN_TARAYICI_ALFA: '1' }) });
  let out = '';
  const run = (lim, list) => { try { return execFileSync('python3', ['tools/test/goruntu_fark.py', OUT, ...list], { env: Object.assign({}, process.env, { SINIR: lim }) }).toString(); } catch (e) { process.exitCode = 1; return e.stdout.toString(); } };
  out += 'yazısız (piksel):\n' + run(process.env.SINIR || '1.5', names.map(n => n + '_yazisiz'));
  out += 'yazılı (göz denetimi; yan yana: <ad>_yazili_fark.png):\n' + run('100', names.map(n => n + '_yazili'));
  process.stdout.write(out);
  if (errs.length) { console.log('HATA', errs); process.exitCode = 1; }
})();
