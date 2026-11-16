// Zindan testi: kapıdan giriş, canavar seviyeleri, boss sandığı, çıkış, kesilenlerin geri gelmemesi, günlük sınır, ölüm.
// node tools/test/zindan.js   (sunucu açık olmalı; onay kutuları otomatik "Tamam")
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message)); p.on('console', m => /anahtar/.test(m.text()) && console.log(m.text().slice(0, 400)));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="法师"]'); await p.fill('#cname', 'Zindan'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const step = async (name, fn) => { const r = await p.evaluate(fn); console.log(name.padEnd(28), JSON.stringify(r)); await p.waitForTimeout(900); return r; };
  await p.evaluate(() => { window.ASKS = []; Win.ask = (t, f) => { ASKS.push(t); f(); }; UI.toast = t => ASKS.push('toast:' + t); });
  const mobs = () => __G.ents ? 0 : Game.ents.filter(e => e.kind === 'mob' && !e.dead);
  await step('seviye 15, kapı', async () => { gmLevel(15); await gotoScene('120046'); Dungeon.door(3); return { sahne: Game.sceneId, son: ASKS.slice(-1) }; });
  await step('seviye 20, kapı', async () => { gmLevel(20); Game.warnT = 0; Dungeon.door(3); await new Promise(r => setTimeout(r, 1500)); return { sahne: Game.sceneId, dun: Game.P.dun && Game.P.dun.id, ask: ASKS.slice(-1) }; });
  await step('sınav canavarları', () => { const m = Game.ents.filter(e => e.kind === 'mob'); const by = {}; for (const x of m) by[x.name] = [x.d.lv, x.maxHp, x.atk, !!x.boss]; return { adet: m.length, by }; });
  await step('boss öldür → sandık', async () => { const m = Game.ents.find(e => e.kind === 'mob' && e.boss); const g0 = Game.P.gold; killMob(m); await new Promise(r => setTimeout(r, 2600)); for (let i = 0; i < 40; i++) update(0.05); await new Promise(r => setTimeout(r, 1500)); return { boss: m && m.name, altın: Game.P.gold - g0, sahne: Game.sceneId, dun: Game.P.dun, ask: ASKS.slice(-2) }; });
  await step('30: Mehtap kapı', async () => { gmLevel(30); await gotoScene('120057'); Game.warnT = 0; Dungeon.door(5); await new Promise(r => setTimeout(r, 1500)); const m = Game.ents.filter(e => e.kind === 'mob'); return { sahne: Game.sceneId, dun: Game.P.dun && Game.P.dun.id, kalan: Dungeon.usedToday(Dungeon.list[1]), adet: m.length, lv: [...new Set(m.map(x => x.name + ':' + x.d.lv))] }; });
  await step('3 canavar kes, kat 2, geri', async () => { Game.god = true; const m = Game.ents.filter(e => e.kind === 'mob' && !e.dead).slice(0, 3); const keys = m.map(x => x.key); m.forEach(killMob); const dun = JSON.stringify(Game.P.dun); console.log('  anahtar', keys, dun); const n0 = Game.ents.filter(e => e.kind === 'mob' && !e.dead).length; await gotoScene('120278', '月夜林地', null, '120277'); const boss = Game.ents.filter(e => e.kind === 'mob').map(x => [x.name, x.d.lv, x.maxHp, x.atk]); await gotoScene('120277', '狼王丛林', null, '120278'); const n1 = Game.ents.filter(e => e.kind === 'mob' && !e.dead).length; return { önce: n0, sonra: n1, boss, temizlenen: Object.keys(Game.P.dun.cleared).length }; });
  await step('ölüm → dışarı', async () => { Game.player.dead = true; revive(); await new Promise(r => setTimeout(r, 1500)); return { sahne: Game.sceneId, ad: Game.scene.name, dun: Game.P.dun, x: Math.round(Game.player.x), y: Math.round(Game.player.y) }; });
  await step('günlük sınır (3)', async () => { const out = []; for (let i = 0; i < 3; i++) { Game.warnT = 0; await gotoScene('120057'); Dungeon.door(5); await new Promise(r => setTimeout(r, 1200)); out.push(Game.sceneId); } return { sahneler: out, son: ASKS.slice(-1), sayaç: Game.P.dg }; });
  await step('yeniden açılış (zindanda)', async () => { const P = Game.P; P.dun = null; await loadScene('120316'); return { dun: P.dun && P.dun.id, sahne: Game.sceneId }; });
  await p.screenshot({ path: process.env.OUT || '/tmp/zindan.png' });
  console.log('HATA', errs); await b.close();
})();
