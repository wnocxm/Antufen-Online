// Hedef alma ve saldırı ayrımı: hedef seçmek saldırı başlatmaz; ikinci dokunuş / saldırı düğmesi saldırır; yön tuşu saldırıyı bırakır.
// node tools/test/hedef.js
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Hedef'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  await p.evaluate(async () => { gmLevel(20); await gotoScene('120040'); Game.god = true; window.M = Game.ents.filter(e => e.kind === 'mob' && !e.dead && !e.d.rank)[0]; const pl = Game.player; M.aggro = false; M.x = pl.x + 4; M.y = pl.y; M.home = { x: M.x, y: M.y }; });
  const run = (n, f) => p.evaluate(([n, f]) => { if (f) eval(f); const pl = Game.player, x0 = pl.x, h0 = M.hp; for (let i = 0; i < n; i++) update(0.05); return { yürüdü: +(pl.x - x0).toFixed(2), uzak: +Math.hypot(pl.x - M.x, pl.y - M.y).toFixed(2), durum: pl.state, ölü: M.dead, hasar: h0 - M.hp, saldırıda: !!Game.engage, hedef: Game.target === M }; }, [n, f]);
  const tapM = "tapWorld(...(() => { const r = UI.toScreen ? UI.toScreen(M.X, M.Y - 22) : null; return r ? [r.x, r.y] : [0, 0]; })())";
  console.log('ilk dokunuş (seç)  ', JSON.stringify(await run(30, "setTarget(M, Game.target === M)")));
  console.log('ikinci dokunuş     ', JSON.stringify(await run(30, "setTarget(M, Game.target === M)")));
  await p.keyboard.down('ArrowLeft'); console.log('yön tuşu basılı    ', JSON.stringify(await run(20))); await p.keyboard.up('ArrowLeft');
  console.log('yön tuşu bırakıldı ', JSON.stringify(await run(40)));
  console.log('saldırı düğmesi    ', JSON.stringify(await run(60, "UI.attack()")));
  console.log('HATA', errs); await b.close();
})();
