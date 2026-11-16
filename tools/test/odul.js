// Görev ödülü testi: orijinal altın ve sınıfa göre eşya (her sınıf yalnız kendi eşyasını alır), görev penceresindeki ödül satırı.
// node tools/test/odul.js   (OUT=görüntü yolu)
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const out = [];
  for (const cls of ['战士', '法师', '牧师']) {
    const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
    const errs = []; p.on('pageerror', e => errs.push(e.message));
    await p.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
    await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1500); await p.keyboard.press('Enter');
    await p.click(`[data-cls="${cls}"]`); await p.fill('#cname', 'Odul'); await p.click('#cstart');
    await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
    const r = await p.evaluate(() => {
      const q = QUESTS.find(x => x.rw && x.rw.items.some(i => i[2]) && (!x.race || x.race === Game.P.race));   // sınıfa özel eşya veren ilk görev
      const g0 = Game.P.gold, bag0 = Game.P.bag.map(x => x.id).join(',');
      acceptQuest(q); Game.P.quests[q.id].ready = true; Game.P.quests[q.id].n = q.count || 1;
      if (q.type === 'deliver') for (const id of q.give) addItem(id, q.count);
      completeQuest(q);
      const got = Game.P.bag.map(x => x.id).filter(id => !bag0.split(',').includes(id));
      return { görev: `${q.id} ${q.title}`, altın: [Game.P.gold - g0, q.rw.gold], orijinal: q.rw.items.map(i => i.join('/')), aldığı: got.map(id => `${id} ${ITEMS[id].name}${ITEMS[id].cls ? ' (' + ITEMS[id].cls + ')' : ''}`) };
    });
    out.push([cls, r, errs]);
    if (cls === '战士') {   // görev penceresinde ödül satırı
      await p.evaluate(() => { const q = QUESTS.find(x => questState(x) === 'new'); acceptQuest(q); Win.open('task'); });
      await p.waitForTimeout(1200); await p.screenshot({ path: process.env.OUT || '/tmp/odul.png' });
    }
  }
  for (const [c, r, e] of out) console.log(c.padEnd(3), JSON.stringify(r), 'HATA', e);
  await b.close();
})();
