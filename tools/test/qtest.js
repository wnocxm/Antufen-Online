const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const ctx = await b.newContext({ viewport: { width: 780, height: 360 } });
  await ctx.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
  const p = await ctx.newPage(); const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Test'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  // 1) statik denetim
  const bad = await p.evaluate(() => { sceneIndex(); const out = []; const QGEN = new Set(QUESTS.filter(q => q.rw).map(q => q.id));
    for (const q of QUESTS) { if (!QGEN.has(q.id)) continue;
      if (!NPC_SC[q.giver]) out.push([q.id, 'veren yok', q.giver]); if (!NPC_SC[q.to]) out.push([q.id, 'teslim yok', q.to]);
      if (q.target && !MON_SC[q.target]) out.push([q.id, 'canavar yok', q.target]);
      if (q.node && !NPC_SC[q.node] && !MON_SC[q.node]) out.push([q.id, 'nokta yok', q.node]);
      if (!q.title || !q.text || !q.goal || /[一-鿿]/.test(q.title + q.goal)) out.push([q.id, 'metin', q.title, q.goal]); }
    return out; });
  console.log('STATİK', JSON.stringify(bad));
  // 2) zincir oyna: Koşanat 81654 -> 81655 -> 81656 (öldür, konuş, topla)
  const r = await p.evaluate(() => { gmLevel(47); const P = __G.P, log = [];
    const by = id => QUESTS.find(q => q.id === id);
    for (const id of [81915, 81917, 82421, 82422, 82423, 82424, 82469, 82470, 81056]) {
      const q = by(id); const st0 = questState(q); if (st0 !== 'new' && st0 !== 'avail' && st0 !== 'ready' && st0 !== 'can') log.push(id + ' durum ' + st0);
      acceptQuest(q);
      if (q.type === 'kill') for (let i = 0; i < q.count; i++) questKill(q.target);
      if (q.type === 'collect') for (let i = 0; i < q.count * 6 && !P.quests[q.id].ready; i++) questKill(q.target);
      if (q.type === "pickup" && q.use) { const g = __G.player; interact({ kind: "npc", cn: q.node, x: g.x + 1, y: g.y, name: q.node }); UI.close && UI.close(); } else if (q.type === "pickup") { P.quests[q.id].n = q.count; P.quests[q.id].ready = true; }
      const ok = P.quests[q.id].ready; const xp0 = P.xp, g0 = P.gold; completeQuest(q);
      log.push(`${id} ${q.type} ${q.title} hazır=${ok} bitti=${!!P.done[id]} +${P.gold - g0} altın | ${q.goal}`);
    }
    return log; });
  console.log(r.join('\n'));
  console.log('HATA', errs); await b.close();
})();
