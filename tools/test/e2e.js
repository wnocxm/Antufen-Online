const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const errs = [];
  async function player(u, cname, cls) {
    const ctx = await b.newContext({ viewport: { width: 800, height: 400 } });
    const p = await ctx.newPage(); p.on('pageerror', e => errs.push(u + ': ' + e.message)); p.on('console', m => { if (m.type() === 'error') errs.push(u + ' console: ' + m.text()); });
    await p.goto('' + (process.env.URL || 'http://localhost:8099/') + '');
    await p.waitForSelector('#tbook', { state: 'visible' }); await p.waitForTimeout(900); await p.keyboard.press('ArrowRight'); await p.waitForTimeout(400); await p.keyboard.press('Enter');
    await p.fill('#ouser', u); await p.fill('#opass', 'gizli123'); await p.click('#oreg');
    await p.waitForSelector('#onew', { state: 'visible' }); await p.click('#onew');
    await p.fill('#cname', cname); if (cls) await p.click(`[data-cls="${cls}"]`); await p.click('#cstart');
    await p.waitForFunction(() => window.__G && window.__G.player && Net.live, null, { timeout: 15000 });
    return p;
  }
  const t = Date.now().toString(36).slice(-4);
  const a = await player('e2ea' + t, 'Ali' + t), c = await player('e2eb' + t, 'Ayse' + t, '法师');
  await a.waitForTimeout(800);
  console.log('A sees', await a.evaluate(() => [...Net.others.values()].map(o => o.name)), 'B sees', await c.evaluate(() => [...Net.others.values()].map(o => o.name)));
  // B yürüsün
  await c.evaluate(() => { const p = __G.player; p.x += 3; });
  await a.waitForTimeout(800);
  console.log('A sees B at', await a.evaluate(() => [...Net.others.values()].map(o => [o.x.toFixed(1), o.y.toFixed(1)])));
  // sohbet
  await a.mouse.click(1, 1);
  await a.evaluate(() => { document.querySelector('#chat').classList.remove('hidden'); document.querySelector('#ctext').value = 'Selam herkese!'; document.querySelector('#csend').click(); });
  await c.waitForTimeout(600);
  console.log('B bubble', await c.evaluate(() => [...Net.others.values()].map(o => o.say)));
  await c.screenshot({ path: '/tmp/claude-0/sp/b.png' });
  // kayıt ve yeniden giriş
  await a.evaluate(() => { __G.P.gold = 777; save(); return Net.now(); });
  await a.reload(); await a.waitForSelector('#tbook', { state: 'visible' }); await a.waitForTimeout(900); await a.keyboard.press('ArrowRight'); await a.waitForTimeout(400); await a.keyboard.press('Enter');
  await a.waitForSelector('.ochar'); console.log('list', await a.$$eval('.ochar', x => x.map(e => e.textContent)));
  await a.click('.ochar'); await a.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 15000 });
  console.log('gold after reload', await a.evaluate(() => __G.P.gold));
  console.log('ERRORS', errs);
  await b.close();
})();
