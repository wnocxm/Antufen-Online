// Alışveriş adet girişi ve NPC'den geçme testi.  node tools/test/alisveris.js  (OUT=görüntü yolu)
// 1) Yığılabilen eşya: adet penceresi açılır; sayıya dokununca HTML sayı kutusu, 25 yazılır → 25 alınır. 2) Bilgisayar: rakam tuşları + Enter.
// 3) Satarken adet. 4) Ekipman tek tek (onay). 5) NPC'nin durduğu kare engel değil; karakter NPC'nin içinden yürüyerek geçer.
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Alis'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const log = (k, v) => console.log(k.padEnd(28), JSON.stringify(v));
  await p.evaluate(() => { Game.P.gold = 100000; });
  // 1) dokunmatik: Biluo meyvesi (yığılır, kullanılabilir değil — eskiden yalnız 1 alınıyordu)
  await p.evaluate(() => Win.buyAsk('30022')); await p.waitForTimeout(300);   // dokunma alanları ilk çizimde oluşur
  await p.evaluate(() => Win.tapId('m50761'));
  log('sayı kutusu açıldı', await p.evaluate(() => !document.getElementById('numin').classList.contains('hidden')));
  await p.fill('#numv', '25'); await p.screenshot({ path: process.env.OUT || '/tmp/alisveris.png' });
  await p.press('#numv', 'Enter'); await p.waitForTimeout(200);
  await p.evaluate(() => Win.tapId('m52791'));
  log('25 Biluo alındı', await p.evaluate(() => ({ adet: countItem('30022'), altın: Game.P.gold })));
  // 2) bilgisayar: rakamlar + Enter
  await p.evaluate(() => Win.buyAsk('30016')); await p.keyboard.type('12'); await p.keyboard.press('Enter');
  log('klavye 12 iksir', await p.evaluate(() => countItem('30016')));
  // sınır: en fazla altının yettiği kadar
  await p.evaluate(() => { Game.P.gold = 70; Win.buyAsk('30016'); }); await p.keyboard.type('99'); await p.keyboard.press('Enter');
  log('altın sınırı (70 altın → en çok 3)', await p.evaluate(() => ({ adet: countItem('30016'), altın: Game.P.gold })));
  // 3) satarken adet
  await p.evaluate(() => { Win.sellAsk('30022'); }); await p.keyboard.type('10'); await p.keyboard.press('Enter');
  log('10 Biluo satıldı', await p.evaluate(() => ({ kalan: countItem('30022'), altın: Game.P.gold })));
  // 4) ekipman: onay kutusu (adet yok)
  log('ekipman onay kutusu', await p.evaluate(() => { Game.P.gold = 100000; Win.buyAsk('10015'); const k = Win.isOpen(); Win.key({ key: 'Enter' }); return { açıldı: k, çantada: countItem('10015') }; }));
  // 5) NPC'den geçme
  const r = await p.evaluate(async () => {
    const pl = Game.player, n = Game.ents.find(e => e.kind === 'npc' && !e.dummy);
    const blocked = Game.map.blocked(n.x, n.y);
    pl.x = n.x - 2; pl.y = n.y; const path = [];
    // sağa doğru (x artan) NPC'nin karesinden geç
    for (let i = 0; i < 80 && pl.x < n.x + 2; i++) { moveEnt(pl, 0.1, 0); path.push(+pl.x.toFixed(1)); }
    return { npc: trName(n.cn), kare: [n.x, n.y], engelMi: blocked, vardığı: +pl.x.toFixed(2), geçti: pl.x >= n.x + 1.5 };
  });
  log('NPC içinden geçiş', r);
  console.log('HATA', errs); await b.close();
})();
