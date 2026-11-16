// Denge benzetimi: yeni karakterle (ırk: RACE=人类|夜精灵) 1'den MAX'e (varsayılan 55) görevleri sırayla yapar.
// Görev hedefleri için gereken öldürmeler ve görev ödülleri sayılır; açık görev kalmayınca seviyeye uygun canavar "kasılır".
// Çıktı: her seviyede yapılan görev, görev/öldürme deneyimi, kasma öldürmesi. node tools/test/denge.js
const { chromium } = require('playwright');
const RACE = process.env.RACE || '人类', MAX = +(process.env.MAX || 55), GRIND = process.env.GRIND !== '0';   // RACE: 人类 | 精灵
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.click(`[data-race="${RACE}"]`).catch(() => {});
  await p.fill('#cname', 'Denge'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const r = await p.evaluate(([MAX, GRIND]) => {
    const P = __G.P, S = Assets.D.scenes, quiet = () => {}; UI.log = quiet; UI.toast = quiet; SFX.play = quiet; save = quiet;
    const scOf = nm => Object.values(S).find(s => s.name === nm);
    const mobXp = (nm, sc) => { const d = monDef(nm, sc); return Math.max(1, Math.round(d.xp * clamp(1 + (d.lv - P.lv) * 0.1, 0.2, 1.5))); };
    // kasma yeri: seviyeye uygun normal canavarlı bir harita
    const grindSpot = () => { let best = null;   // seviyesi oyuncuya en yakın (en çok 2 üstü) normal canavar
      for (const s of Object.values(S)) { if (!s.lvr || s.lvr[0] > P.lv + 2) continue;
        for (const e of s.ents) { if (!Assets.D.mon[e[0]] || e[1].includes('☆') || Assets.D.mon[e[0]][0] !== e[1]) continue; const d = monDef(e[1], s); if (d.passive || d.lv > P.lv + 2) continue;
          if (!best || d.lv > best[2]) best = [s, e[1], d.lv]; } }
      return best; };
    const rows = {}; const row = () => rows[P.lv] || (rows[P.lv] = { lv: P.lv, q: 0, qxp: 0, kill: 0, kxp: 0, grind: 0, gxp: 0, where: new Set(), need: xpNeed(P.lv), over: 0 });
    let guard = 0;
    while (P.lv < MAX && guard++ < 200000) {
      const av = QUESTS.filter(q => questState(q) === 'new').sort((a, b) => questMinLv(a) - questMinLv(b));
      if (av.length) {
        const q = av[0]; acceptQuest(q); const R = row(); R.where.add(trName(q.giver)); R.over += P.lv - questMinLv(q);
        if (q.type === 'kill' || q.type === 'collect') {
          const sc = scOf(q.sc), n = q.type === 'kill' ? q.count : Math.ceil(q.count / (q.chance || 0.5));
          for (let i = 0; i < n; i++) { const x = mobXp(q.target, sc); row().kill++; row().kxp += x; gainXp(x); }
        }
        P.quests[q.id].ready = true; const xp0 = q.reward.xp || 0; completeQuest(q); row().q++; row().qxp += xp0;
      } else {
        if (!GRIND) break;
        const g = grindSpot(); if (!g) break; const x = mobXp(g[1], g[0]); const R = row(); R.grind++; R.gxp += x; R.spot = trName(g[0].name) + ' / ' + trName(g[1]); gainXp(x);
      }
    }
    return Object.values(rows).map(R => ({ ...R, over: R.q ? (R.over / R.q).toFixed(1) : '', where: [...R.where].slice(0, 4).join(', ') }));
  }, [MAX, GRIND]);
  console.log('Sv | gerek TP | görev | ort. seviye fazlası | görev TP | hedef öldürme (TP) | kasma öldürme (TP) | kasma yeri | görev verenler');
  for (const R of r) console.log([R.lv, R.need, R.q, R.over, R.qxp, `${R.kill} (${R.kxp})`, `${R.grind} (${R.gxp})`, R.spot || '', R.where].join(' | '));
  const T = r.reduce((a, R) => ({ q: a.q + R.q, k: a.k + R.kill, g: a.g + R.grind }), { q: 0, k: 0, g: 0 });
  console.log(`TOPLAM görev ${T.q}, hedef öldürme ${T.k}, kasma öldürme ${T.g}`, 'HATA', errs);
  await b.close();
})();
