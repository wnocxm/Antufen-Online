const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Test'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const r = await p.evaluate(() => QUESTS.filter(q => q.id >= 81600 || [80051].includes(q.id) || q.id < 81000 && q.id > 80010).map(q => [q.id, questMinLv(q), q.type, q.title, trName(q.giver), q.req || '', q.goal]));
  r.sort((a, b) => a[1] - b[1] || a[0] - b[0]);
  for (const x of r) console.log(x.join(' | '));
  console.log('HATA', errs); await b.close();
})();
