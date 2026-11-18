// Beceri efektleri testi.  node tools/test/efekt.js  (OUT=görüntü öneki, DIL=en)
// 1) Kılıç izi: dört yönde saldırı hareketi + 特效-刀光 / 特效-刀光-红 (iz kılıcın üstünde; 2 kare gecikme; sola bakan yönler sağa bakanların aynası).
// 2) Üç sınıf, iki uzmanlık: bütün etkin beceriler canavara karşı kullanılır, her birinin oyundaki görüntüsü bir pafta olarak kaydedilir
//    (OUT_<sınıf>_<uzmanlık>.png). 3) Süren etkiler: güçlendirme görseli karakterde döner, yavaşlama/gözdağı canavarda; totemler yerde,
//    Büyü Hayali oyuncunun yanında; Alev Yakışı tek hedefli (orijinal).
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 1 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message)); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.addInitScript(D => { try { localStorage.setItem('anrufen_lang', D); } catch (e) {} }, process.env.DIL || 'tr');
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMEfekt'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(1000);
  const O = process.env.OUT || '/tmp/efekt', log = (k, v) => console.log(k.padEnd(30), JSON.stringify(v));
  const png = (f, url) => fs.writeFileSync(f, Buffer.from(url.split(',')[1], 'base64'));
  // 1) kılıç izi şeridi
  png(O + '_iz.png', await p.evaluate(async () => {
    const N = ['特效-刀光', '特效-刀光-红']; await Assets.preload(N); await new Promise(r => setTimeout(r, 800));
    const pl = Game.player, C = 110, cv = document.createElement('canvas'); cv.width = C * 8; cv.height = C * 8; const ctx = cv.getContext('2d');
    ctx.fillStyle = '#203018'; ctx.fillRect(0, 0, cv.width, cv.height); ctx.font = '11px sans-serif';
    N.forEach((n, j) => { const sp = Game.map.sprite(n); sp.glow = true;
      for (let d = 0; d < 4; d++) { const a = fxAnim(sp, d), L = sp.animLen(a), at = pl.doll.animLen('figh', 4 + d), r = j * 4 + d;
        ctx.fillStyle = '#fff'; ctx.fillText(`${n} yön ${d} → ${a}`, 4, r * C + 12);
        for (let k = 0; k < 8; k++) { const X = k * C + C / 2, Y = r * C + C - 22; pl.doll.draw(ctx, 'figh', 4 + d, Math.min(k, at - 1), X, Y); if (k >= 2 && k - 2 < L) sp.draw(ctx, a, k - 2, X, Y); } } });
    return cv.toDataURL();
  }));
  log('8 yuvalı yön eşlemesi', await p.evaluate(() => [0, 1, 2, 3].map(d => fxAnim(Game.map.sprite('特效-刀光'), d))));
  // 2) bütün etkin beceriler: oyun döngüsü durdurulur, adım adım ilerletilip ekran kesilir
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; });
  const frame = () => p.evaluate(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r))));
  for (const [cls, spec] of [['战士', 0], ['战士', 1], ['法师', 0], ['法师', 1], ['牧师', 0], ['牧师', 1]]) {
    const list = await p.evaluate(([cls, spec]) => {
      const P = Game.P; P.cls = cls; P.sk = {}; P.sp = 0; gmLevel(120); ClassGM.fill(spec); Game.player.doll.set(Object.assign({}, Game.player.doll.look, { cls }));
      return CLS[cls].skills.map((sk, i) => [i, sk]).filter(([, sk]) => !sk.pas && skRank(sk)).map(([i, sk]) => [i, sk.name, sk.range || 0]);
    }, [cls, spec]);
    await p.evaluate(() => { window.update = window.__upd; }); await p.waitForTimeout(3300); await p.evaluate(() => { window.update = () => {}; });   // seviye/sınıf yazıları geçsin
    const shots = [];
    for (const [i, name, range] of list) {
      const T = range && range < 3.5 ? 0.4 : range ? 0.75 : 0.6;
      await p.evaluate(([i, range]) => {
        const p = Game.player; Game.ents = Game.ents.filter(e => e.kind !== 'mob'); Game.fx = []; Game.phantom = null; p.buffs = []; p._aura = null;
        const d = range && range < 3.5 ? 1.2 : 2.6, m = new Mob('☆水仙子', p.x + d, p.y); m.hp = m.maxHp = 1e9; m.home = { x: m.x, y: m.y }; Game.ents.push(m); setTarget(m, true);
        p.cds = {}; p.mp = stats().mp; p.hp = stats().hp; p.state = 'idle'; p.dir = 1; useSkill(i);
      }, [i, range]);
      for (let k = 0; k < T / 0.05; k++) await p.evaluate(() => window.__upd(0.05));
      await frame();
      shots.push([name, await p.evaluate(() => { const c = document.querySelector('canvas'); return c.toDataURL(); })]);
      // süren etkiler ve çağrılan nesneler
      const st = await p.evaluate(() => { for (let k = 0; k < 10; k++) window.__upd(0.05); const pl = Game.player, m = Game.ents.find(e => e.kind === 'mob');
        return { güç: Object.values(pl._aura || {}).map(f => f.name), canavar: Object.values((m && m._aura) || {}).map(f => f.name), totem: Game.fx.filter(f => f.life != null).map(f => f.sp.r && f.sp.r[0]), hayal: !!(Game.phantom && Game.phantom.fx) }; });
      const extra = [st.güç.length && 'güç:' + st.güç, st.canavar.length && 'canavar:' + st.canavar, st.totem.length && 'totem:' + st.totem, st.hayal && 'hayal'].filter(Boolean);
      if (extra.length) log(`  ${cls}/${spec} ${name}`, extra.join(' '));
    }
    // pafta: her becerinin oyuncu çevresi (orta-alt), adıyla
    png(`${O}_${cls}_${spec}.png`, await p.evaluate(async shots => {
      const W = 320, H = 230, n = shots.length, cols = 4, sh = document.createElement('canvas'); sh.width = W * cols; sh.height = H * Math.ceil(n / cols); const ctx = sh.getContext('2d');
      ctx.fillStyle = '#000'; ctx.fillRect(0, 0, sh.width, sh.height); ctx.font = '13px sans-serif';
      for (let k = 0; k < n; k++) { const img = new Image(); img.src = shots[k][1]; await img.decode(); const sx = img.width / 2 - W / 2 + 20, sy = img.height / 2 - H / 2 + 10;
        ctx.drawImage(img, sx, sy, W, H, (k % cols) * W, Math.floor(k / cols) * H, W, H); ctx.fillStyle = '#ffe070'; ctx.fillText(shots[k][0], (k % cols) * W + 6, Math.floor(k / cols) * H + 16); }
      return sh.toDataURL();
    }, shots));
  }
  // 3) Alev Yakışı tek hedef: iki canavar yan yana, yalnızca hedef vurulur
  log('Alev Yakışı tek hedef', await p.evaluate(() => { const P = Game.P, p = Game.player; P.cls = '法师'; P.sk = {}; gmLevel(120); ClassGM.fill(0);
    p.buffs = []; Game.phantom = null; Game.ents = Game.ents.filter(e => e.kind !== 'mob'); const a = new Mob('☆水仙子', p.x + 2, p.y), c = new Mob('☆水仙子', p.x + 2, p.y + 0.6); for (const m of [a, c]) { m.home = { x: m.x, y: m.y }; Game.ents.push(m); }
    setTarget(a, true); p.cds = {}; p.mp = stats().mp; p.state = 'idle'; const h = [a.hp, c.hp]; useSkill(CLS.法师.skills.findIndex(k => k.id === 'm4')); for (let k = 0; k < 40; k++) window.__upd(0.05);
    return { hedef: h[0] - a.hp > 0, yandaki: h[1] - c.hp > 0, mermi: 3 }; }));
  await p.evaluate(() => { window.update = window.__upd; });
  console.log('HATA', errs); await b.close();
})();
