// Görünüş karşılaştırma: verilen kayıt adlarını (LOOKS=ad1,ad2,...) yan yana çizer. OUT=çıktı yolu.
// node tools/test/gorunus.js   LOOKS='怪物-雪人,怪物-雪人-白' OUT=/tmp/g.png
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Gorunus'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const url = await p.evaluate(async L => {
    await Assets.preload(L); const W = 110, H = 130, cv = document.createElement('canvas'); cv.width = W * Math.min(8, L.length); cv.height = H * Math.ceil(L.length / 8);
    const c = cv.getContext('2d'); c.fillStyle = '#3a332b'; c.fillRect(0, 0, cv.width, cv.height); c.font = '10px sans-serif';
    L.forEach((n, i) => { const x = (i % 8) * W, y = Math.floor(i / 8) * H, sp = Game.map.sprite(n); c.strokeStyle = '#5a4d3c'; c.strokeRect(x, y, W, H);
      if (sp.ok) sp.draw(c, 2, 0, x + W / 2, y + H - 22); c.fillStyle = sp.ok ? '#ffe9a8' : '#f66'; c.fillText(n.slice(0, 16), x + 3, y + H - 6); });
    return cv.toDataURL('image/png');
  }, (process.env.LOOKS || '').split(',').filter(Boolean));
  require('fs').writeFileSync(process.env.OUT || '/tmp/gorunus.png', Buffer.from(url.split(',')[1], 'base64')); await b.close();
})();
