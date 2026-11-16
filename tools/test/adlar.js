// Ad denetimi: bütün haritalardaki NPC/canavar/nesne adlarının TR ve EN'de Çince kalmadığını denetler. node tools/test/adlar.js
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch();
  for (const lang of ['tr', 'en']) {
    const ctx = await b.newContext({ viewport: { width: 780, height: 360 } }); const p = await ctx.newPage();
    const errs = []; p.on('pageerror', e => errs.push(e.message));
    await p.addInitScript(l => { try { localStorage.setItem('anrufen_lang', l); } catch (e) {} }, lang);
    await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1500);
    const r = await p.evaluate(async () => {
      const D = await (await fetch('assets/data.json')).json(); const out = { lang: LANG, n: 0, cn: [] };
      const sc = D && D.scenes ? Object.values(D.scenes) : [];
      for (const s of sc) for (const e of s.ents) { out.n++; const t = trName(e[1]); if (/[一-鿿]/.test(t)) out.cn.push(e[1]); }
      out.cn = [...new Set(out.cn)].slice(0, 20);
      out.ornek = ['☆冰地狱犬', '★噬魂男爵卡加斯', '城市守卫', '珠宝商洛奇'].map(trName);
      return out; });
    console.log(JSON.stringify(r), 'HATA', errs); await ctx.close();
  }
  await b.close();
})();
