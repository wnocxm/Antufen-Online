const { chromium } = require('playwright');
const cls = process.argv[2];
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click(`[data-cls="${cls}"]`); await p.fill('#cname', 'Deneme'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  await p.evaluate(async () => { await loadScene('120018'); });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const pl = __G.player, m = __G.ents.filter(e => e.kind === 'mob' && !e.dead)[0]; m.x = pl.x + 3; m.y = pl.y; m.hp = m.maxHp = 99999; m.aggro = false; setTarget(m); pl.atkT = 0; __G.auto = true; });
  const box = await p.evaluate(() => { const c = document.querySelector('canvas').getBoundingClientRect(); return c; });
  // büyük saldırı tuşuna bas (oyunun kendi tuşu)
  await p.evaluate(() => { UI.attack ? UI.attack() : 0; });
  for (let j = 0; j < 16; j++) { await p.waitForTimeout(60); await p.screenshot({ path: (process.env.OUT || '/tmp') + `/a_${cls}_${String(j).padStart(2,'0')}.png`, clip: { x: 290, y: 60, width: 200, height: 200 } }); }
  console.log(errs, await p.evaluate(() => __G.fx.map(f => f.sp.r && f.sp.r[1])));
  await b.close();
})();
