// Evcil hayvan görev zinciri (insan): bilgi → kayıp yumurta → kuluçka kutusu teslimi → kuluçka.  node tools/test/evcilgorev.js
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="法师"]'); await p.click('[data-race="' + (process.env.RACE || '人类') + '"]').catch(() => {}); await p.fill('#cname', 'Terbiye'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const r = await p.evaluate(() => {
    gmLevel(12); const P = Game.P, out = []; const by = id => QBY[id];
    const ids = P.race === '精灵' ? [80410, 80255, 80222, 80260, 80411, 80046] : [80268, 80249, 80221, 80254, 80405, 80045];
    for (const id of ids) {
      const q = by(id), st0 = questState(q); acceptQuest(q); const st = P.quests[id];
      if (q.type === 'collect') for (let i = 0; i < 5 && !st.ready; i++) questKill(q.target);
      if (q.type === 'deliver') { const a = questState(q); buyItem('30166', 1); out.push(`  teslimden önce: ${a}, satın aldıktan sonra: ${questState(q)}`); }
      if (q.type === 'special') { out.push(`  kuluçkadan önce: ${questState(q)}`); for (const it of P.bag.slice()) if (ITEMS[it.id] && ITEMS[it.id].pet && ITEMS[it.id].pet.egg) useItem(it.id); }
      const ready = questState(q); const g0 = P.gold; completeQuest(q);
      out.push(`${id} [${q.type}] ${q.title} | önce:${st0} hazır:${ready} bitti:${!!P.done[id]} | ${q.goal} | çanta: ${P.bag.filter(x => ITEMS[x.id] && ITEMS[x.id].pet).map(x => ITEMS[x.id].name + '×' + x.n).join(', ')}`);
    }
    out.push('hayvanlar: ' + Pet.list().map(x => Pet.nm(x) + ' Sv' + x.lv).join(', ') + ' · çağrılı: ' + !!Pet.ent);
    return out; });
  console.log(r.join('\n')); console.log('HATA', errs); await b.close();
})();
