const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click(`[data-cls="法师"]`); await p.fill('#cname', 'GMfx'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  await p.evaluate(async () => { gmLevel(25); __G.god = true; const C = CLS[__G.P.cls]; for (const s of C.skills) __G.P.sk[s.id] = 5; await loadScene('120018'); });
  await p.waitForTimeout(1500);
  for (const k of [0, 3]) {
    await p.evaluate(k => { const C = CLS[__G.P.cls], act = C.skills.filter(s => !s.pas), sk = act[k], i = C.skills.indexOf(sk), pl = __G.player;
      const m = __G.ents.filter(e => e.kind === 'mob' && !e.dead)[0]; m.x = pl.x + 2; m.y = pl.y; m.hp = m.maxHp = 99999; setTarget(m, true); pl.cds = {}; pl.mp = 99999; pl.atkT = 5; useSkill(i); }, k);
    for (let j = 0; j < 12; j++) { await p.waitForTimeout(70); await p.screenshot({ path: (process.env.OUT || '/tmp') + `/z_${k}_${String(j).padStart(2,'0')}.png`, clip: { x: 290, y: 60, width: 200, height: 200 } }); }
    await p.waitForTimeout(1200);
  }
  await b.close();
})();
