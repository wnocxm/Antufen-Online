// 50. seviye zindanlar: Kuleler (Ruh Balkonu) ve Akankum Limanı.  node tools/test/zindan50.js
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="牧师"]'); await p.fill('#cname', 'Zindan50'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const step = async (name, fn, a) => { const r = await p.evaluate(fn, a); console.log(name.padEnd(24), JSON.stringify(r).slice(0, 600)); await p.waitForTimeout(500); return r; };
  await p.evaluate(() => { window.ASKS = []; Win.ask = (t, f) => { ASKS.push(t); f(); }; UI.toast = t => ASKS.push('toast:' + t); Game.god = true; });
  await step('Bilgin → Ruh Balkonu', async () => { gmLevel(50); await gotoScene('120078'); Dungeon.npcTp('矮人学者')[0].go(); await new Promise(r => setTimeout(r, 1500)); return { ad: trName(Game.scene.name), greet: TR.greet['普通副本-英雄塔(50级)'].slice(0, 40) }; });
  for (const door of [3, 5, 7, 9]) {
    await step('kule kapı ' + door, async (door) => { if (Game.sceneId !== '120360') await gotoScene('120360', null, [22, 30]); Game.warnT = 0; Dungeon.door(door); await new Promise(r => setTimeout(r, 1400)); const D = Dungeon.of(Game.sceneId); const k1 = trName(Game.scene.name); const mobs1 = Game.ents.filter(e => e.kind === 'mob').length; await gotoScene(D[1].scenes[3]); const bs = Game.ents.filter(e => e.kind === 'mob').map(x => [trName(x.name), x.d.lv, !!x.boss]); await Dungeon.leave(true); return { zindan: trName(D[0].cn), kat1: k1, canavar: mobs1, tepe: trName(Game.scene.name) && bs }; }, door);
  }
  await step('Balkon → Dağgören çıkışı', async () => { await gotoScene('120360', null, [22, 30]); const fx = Dungeon.exitFix('120360', 1); await gotoScene(fx[0], null, [fx[1], fx[2]]); return { ad: trName(Game.scene.name), sid: Game.sceneId }; });
  await step('Akankum kapı 5', async () => { await gotoScene('120315'); Game.warnT = 0; Dungeon.door(5); await new Promise(r => setTimeout(r, 1400)); const m = Game.ents.filter(e => e.kind === 'mob'); return { ad: trName(Game.scene.name), dun: Game.P.dun && Game.P.dun.id, lv: [...new Set(m.map(x => x.d.lv))] }; });
  await step('Kâşif → Uzun Ada', async () => { await gotoScene('120308'); const tp = Dungeon.npcTp('瑟瑟发抖的勘察员'); tp[0].go(); await new Promise(r => setTimeout(r, 1500)); return { ad: trName(Game.scene.name), dun: Game.P.dun && Game.P.dun.id, boss: Game.ents.filter(e => e.kind === 'mob').map(x => [trName(x.name), x.d.lv, x.maxHp]) }; });
  await step('son boss Turayan', async () => { await gotoScene('120307'); const m = Game.ents.find(e => e.kind === 'mob' && e.name === '★大投机者图拉杨'); killMob(m); await new Promise(r => setTimeout(r, 2500)); return { sahne: trName(Game.scene.name), son: ASKS.slice(-2) }; });
  console.log('HATA', errs); await b.close();
})();
