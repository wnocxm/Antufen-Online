// Seviye başına görev kapsamı: her ırk için her seviyede açılan görev sayısı ve orijinal görev deneyimi (gorev_ham.json),
// oyunun seviye eğrisiyle (xpNeed) karşılaştırma. node tools/test/gorev_seviye.js   (OUT=rapor yolu)
const { chromium } = require('playwright'), fs = require('fs'), path = require('path');
const H = JSON.parse(fs.readFileSync(path.join(__dirname, '../../kaynak/cikti/cozulmus/tablolar/gorev_ham.json'), 'utf8'));
const XP = {}; for (const [k, r] of Object.entries(H)) XP[k] = r.xp;
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Seviye'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const r = await p.evaluate(XP => {
    const out = {};
    for (const race of ['人类', '精灵']) {
      const L = {}; for (let lv = 1; lv <= 60; lv++) L[lv] = { n: 0, xpOrig: 0, xpOurs: 0, need: xpNeed(lv) };
      for (const q of QUESTS) { if (q.race && q.race !== race) continue; const lv = Math.min(60, questMinLv(q)); if (!L[lv]) continue; L[lv].n++; L[lv].xpOrig += XP[q.id] || 0; L[lv].xpOurs += q.reward.xp || 0; }
      out[race] = L;
    }
    return out;
  }, XP);
  const lines = ['sv | insan: görev, orij.deneyim, bizim | elf: görev, orij.deneyim, bizim | seviye için gereken (bizim xpNeed)'];
  for (let lv = 1; lv <= 60; lv++) { const a = r['人类'][lv], e = r['精灵'][lv]; lines.push(`${String(lv).padStart(2)} | ${String(a.n).padStart(3)} ${String(a.xpOrig).padStart(7)} ${String(a.xpOurs).padStart(7)} | ${String(e.n).padStart(3)} ${String(e.xpOrig).padStart(7)} ${String(e.xpOurs).padStart(7)} | ${a.need}`); }
  const rep = lines.join('\n'); if (process.env.OUT) fs.writeFileSync(process.env.OUT, rep); console.log(rep);
  if (process.env.JSON) fs.writeFileSync(process.env.JSON, JSON.stringify(r));   // tools/deneyim_tablosu.py girdisi
  await b.close();
})();
