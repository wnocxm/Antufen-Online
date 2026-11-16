const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const ctx = await b.newContext({ viewport: { width: 780, height: 360 }, hasTouch: true });
  const p = await ctx.newPage(); const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Test'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(1500);
  const a = await p.evaluate(() => [__G.player.x, __G.player.y]);
  await p.mouse.click(300, 250); await p.waitForTimeout(1500);
  await p.touchscreen.tap(450, 120); await p.waitForTimeout(1500);
  const c = await p.evaluate(() => [__G.player.x, __G.player.y, !!__G.player.path]);
  // NPC'ye dokun: hedef alınmalı
  const npc = await p.evaluate(() => { const n = __G.ents.find(e => e.kind === 'npc' && !e.hidden); const o = Game.map; return n ? [n.cn, n.X, n.Y] : null; });
  console.log('önce', a, 'sonra', c, 'npc', npc && npc[0], errs);
  await b.close();
})();
