// Sol menü (karakter menüsü) kaydırma testi.  node tools/test/menu.js  (OUT=görüntü öneki, DIL=en)
// GM karakterinde menüde 8. düğme (GM) vardır; 7 düğme ekranı doldurduğu için GM ilk açılışta görünmez. Menü parmakla yukarı
// sürüklenince (ya da fare tekerleğiyle) GM düğmesi gelir, dokununca GM paneli açılır. GM olmayan karakterde menü kaymaz.
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.addInitScript(D => { try { localStorage.setItem('anrufen_lang', D); } catch (e) {} }, process.env.DIL || 'tr');
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1500); await p.keyboard.press('Enter');
  await p.click('[data-cls="法师"]'); await p.fill('#cname', process.env.AD || 'GMMenu'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const O = process.env.OUT || '/tmp/menu', log = (k, v) => console.log(k.padEnd(30), JSON.stringify(v));
  // mantıksal koordinat → sayfa koordinatı
  const k = await p.evaluate(() => 100 / UI.toLogical(100, 100).x);
  const R = async () => { await p.waitForTimeout(250); return p.evaluate(() => ({ ...Win.HUB.r, y0: Win.HUB.y })); };
  const gmOpen = () => p.evaluate(() => !document.getElementById('gm').classList.contains('hidden'));
  const tapLast = async r => { const x = (r.x + r.w / 2) * k, y = (r.y + 290 * r.k) * k; await p.mouse.click(x, y); await p.waitForTimeout(300); };   // en alttaki düğme
  await p.evaluate(() => Win.open('hub')); let r = await R(); await p.screenshot({ path: O + '_ust.png' });
  log('açılış: kaydırma / en çok', { y: r.y0, max: r.max });
  await tapLast(r); log('en alt düğme (Sistem)', await p.evaluate(() => Win.cur));
  // parmakla yukarı sürükle
  await p.evaluate(() => { UI.closeAll(); Win.open('hub'); }); r = await R();
  const cx = (r.x + r.w / 2) * k; await p.mouse.move(cx, (r.y + 250 * r.k) * k); await p.mouse.down();
  for (let i = 1; i <= 10; i++) await p.mouse.move(cx, (r.y + (250 - i * 8) * r.k) * k);
  await p.mouse.up(); r = await R(); await p.screenshot({ path: O + '_alt.png' });
  log('sürükledikten sonra', { y: r.y0, max: r.max, pencere: await p.evaluate(() => Win.cur) });
  await tapLast(r); log('en alt düğme (GM) → panel', await gmOpen());
  // fare tekerleği
  await p.evaluate(() => { UI.closeAll(); Win.open('sys'); }); r = await R(); log('yeniden açılış başta', r.y0);
  await p.mouse.move(cx, (r.y + 160 * r.k) * k); await p.mouse.wheel(0, 300); r = await R();
  log('tekerlek', { y: r.y0 }); await tapLast(r); log('tekerlekle GM → panel', await gmOpen());
  // GM olmayan karakter: menü kaymaz
  await p.evaluate(() => { UI.closeAll(); Game.P.name = 'Oyuncu'; Win.open('hub'); }); r = await R();
  await p.mouse.move(cx, (r.y + 160 * r.k) * k); await p.mouse.wheel(0, 300); r = await R();
  log('GM değil: kaydırma / en çok', { y: r.y0, max: r.max });
  console.log('HATA', errs); await b.close();
})();
