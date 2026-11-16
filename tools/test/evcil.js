// Evcil hayvan testi: kuluçka (kutu şartı), çağırma, savaş (taktik modları), deneyim, besleme, ölüm, diriltme, yumurta düşmesi.
// node tools/test/evcil.js   (OUT=ekran görüntüsü yolu)
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Evcil'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const step = async (name, fn) => { const r = await p.evaluate(fn); console.log(name.padEnd(22), JSON.stringify(r).slice(0, 500)); await p.waitForTimeout(400); return r; };
  await p.evaluate(() => { window.TO = []; const t = UI.toast; UI.toast = m => { TO.push(m); t(m); }; });
  await step('veri', () => ({ tür: Pet.D.species.length, örnek: Pet.D.species.slice(0, 3).map(s => [s.tr, s.box, s.cls]), dükkân: SHOPS['驯兽师（人类）'] ? SHOPS['驯兽师（人类）'][0][1].length : null }));
  await step('kutusuz kuluçka', () => { addItem('30105', 1); useItem('30105'); return { son: TO.slice(-1), hayvan: Pet.list().length }; });
  await step('tahta kutu yetmez', () => { addItem('30166', 1); useItem('30105'); return { son: TO.slice(-1), hayvan: Pet.list().length }; });
  await step('metal kutuyla', () => { addItem('31147', 1); useItem('30105'); const a = Pet.active(); return { son: TO.slice(-1), hayvan: Pet.list().map(x => [Pet.nm(x), x.lv, x.tal, x.v]), çağrılı: !!Pet.ent, nit: a && Pet.stats(a), kutu: countItem('31147') }; });
  await step('dövüş (saldırı modu)', async () => {
    gmLevel(20); gmGear(); const a = Pet.active(); a.lv = 18; const s = Pet.stats(a); a.hp = s.hp; a.mp = s.mp; await gotoScene('120040'); Game.god = true;
    const pl = Game.player, m = Game.ents.filter(e => e.kind === 'mob' && !e.dead && !e.d.rank).sort((x, y) => Math.hypot(x.x - pl.x, x.y - pl.y) - Math.hypot(y.x - pl.x, y.y - pl.y))[0];
    pl.x = m.x - 1.5; pl.y = m.y; Pet.ent.x = pl.x; Pet.ent.y = pl.y + 1; setTarget(m); pl.combatT = 5; const h0 = m.hp, xp0 = a.xp, lv0 = a.lv;
    let petDmg = 0, plDmg = 0; const hf = UI.float; UI.float = (e, t, c, k) => { if (e === m) { const v = +String(t).replace('!', '') || 0; if (c === '#9fe0ff') petDmg += v; else if (c === '#fff' || c === '#ffd040') plDmg += v; } hf(e, t, c, k); };
    for (let i = 0; i < 400 && !m.dead; i++) update(0.05);
    UI.float = hf; return { canavar: trName(m.name), öldü: !!m.dead, oyuncuHasarı: plDmg, hayvanHasarı: petDmg, toplam: h0, hayvanDeneyim: [lv0, xp0, '→', a.lv, a.xp], hayvanCan: [Math.round(a.hp), s.hp] };
  });
  await step('bekleme modu', () => { Pet.setMode('idle'); const pl = Game.player, m = Game.ents.find(e => e.kind === 'mob' && !e.dead); setTarget(m); pl.combatT = 5; for (let i = 0; i < 60; i++) update(0.05); return { hedef: Pet.ent && Pet.ent.tg ? 'var' : 'yok' }; });
  await step('besleme', () => { Pet.setMode('attack'); const a = Pet.active() || (Pet.summon(Pet.list()[0].uid), Pet.active()) || Pet.list()[0]; a.sat = 40; addItem('30022', 2); useItem('30022'); return { tokluk: a.sat, mutluluk: a.joy }; });
  await step('ölüm + diriltme', () => { const a = Pet.active(); a.hp = 1; const m = Game.ents.find(e => e.kind === 'mob' && !e.dead); m.atk = 99999; Pet.hurt(m); const ölü = a.dead; addItem('30025', 1); useItem('30025'); return { ölü, sonra: a.dead, can: a.hp, çağrılı: !!Pet.ent }; });
  await step('yeniden çağır', () => { const a = Pet.list()[0]; Pet.summon(a.uid); return { çağrılı: !!Pet.ent, ad: Pet.ent && Pet.ent.name }; });
  await step('yumurta düşmesi (☆☆)', () => { const before = Game.P.bag.length; let n = 0; for (let i = 0; i < 200; i++) { const egg = Pet.D.species.find(s => s.cn === '狼').egg; const c0 = countItem(egg); Pet.dropEgg({ name: '狼', d: { rank: 2 } }); if (countItem(egg) > c0) n++; } return { kurtYumurtası200de: n }; });
  await p.evaluate(() => { const pl = Game.player; Game.ents.filter(e => e.kind === 'mob').slice(0, 1).forEach(m => { m.x = pl.x + 3; m.y = pl.y; }); Pet.ent.say = 'Kaburgamın sağdan üçüncüsü ağrıyor.'; Pet.ent.sayT = 4; });
  await p.waitForTimeout(800); await p.screenshot({ path: process.env.OUT || '/tmp/evcil.png' });
  const O = (process.env.OUT || '/tmp/evcil.png').replace(/\.png$/, '');
  await p.evaluate(() => { addItem('30022', 5); Win.open('pet'); }); await p.waitForTimeout(1200); await p.screenshot({ path: O + '_pencere.png' });
  await p.evaluate(() => { Win.PW.ai = true; }); await p.waitForTimeout(500); await p.screenshot({ path: O + '_taktik.png' });
  console.log('HATA', errs); await b.close();
})();
