const { chromium } = require('playwright');
const cls = process.argv[2];
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click(`[data-cls="${cls}"]`); await p.fill('#cname', 'GMfx'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  await p.evaluate(async () => { gmLevel(25); __G.god = true; const C = CLS[__G.P.cls]; for (const s of C.skills) __G.P.sk[s.id] = 5; await loadScene('120018'); });
  await p.waitForTimeout(1200);
  const n = await p.evaluate(() => CLS[__G.P.cls].skills.filter(s => !s.pas).length);
  for (let k = 0; k < n; k++) {
    const name = await p.evaluate(k => { const C = CLS[__G.P.cls], act = C.skills.filter(s => !s.pas), sk = act[k], i = C.skills.indexOf(sk), pl = __G.player;
      // en yakın canavarı oyuncunun 3 kare önüne getir, bekleme sürelerini sıfırla
      const m = __G.ents.filter(e => e.kind === 'mob' && !e.dead)[0]; m.x = pl.x + 3; m.y = pl.y; m.hp = m.maxHp; m.aggro = false; setTarget(m);
      pl.cds = {}; pl.mp = 99999; pl.atkT = 0; useSkill(i); return sk.name; }, k);
    for (const [j, ms] of [[0, 330], [1, 300], [2, 350]]) { await p.waitForTimeout(ms); await p.screenshot({ path: (process.env.OUT || '/tmp') + `/${cls}_${k}_${j}.png`, clip: { x: 190, y: 40, width: 400, height: 260 } }); }
    console.log(k, name);
    await p.waitForTimeout(900);
  }
  console.log(errs); await b.close();
})();
