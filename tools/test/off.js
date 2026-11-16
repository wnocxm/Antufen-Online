const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 740, height: 360 } })).newPage(); const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(900); await p.keyboard.press('Enter'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player); await p.waitForTimeout(500);
  console.log('net', await p.evaluate(() => Net.on), 'saved', await p.evaluate(() => !!localStorage.getItem(SAVE_KEY)), errs);
  await p.reload(); await p.waitForTimeout(1200); console.log('word:', await p.textContent('#tword'), '|', await p.textContent('#tinfo'));
  await b.close();
})();
