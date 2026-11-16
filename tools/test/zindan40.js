// 40. seviye Ruhyiyen zindanları: ışınlanma, ön görev şartı, çok hedefli görev, zincir, boss seviyeleri.  node tools/test/zindan40.js
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Zindan40'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const step = async (name, fn) => { const r = await p.evaluate(fn); console.log(name.padEnd(26), JSON.stringify(r).slice(0, 700)); await p.waitForTimeout(600); return r; };
  await p.evaluate(() => { window.ASKS = []; Win.ask = (t, f) => { ASKS.push(t); f(); }; UI.toast = t => ASKS.push('toast:' + t); Game.god = true; });
  const stepA = async (name, fn, a) => { const r = await p.evaluate(fn, a); console.log(name.padEnd(26), JSON.stringify(r).slice(0, 700)); await p.waitForTimeout(600); return r; };
  await step('Levazımcı ışınlama', async () => { gmLevel(40); await gotoScene('120094'); const tp = Dungeon.npcTp('噬魂远征军军需官'); tp[0].go(); await new Promise(r => setTimeout(r, 1500)); return { sahne: Game.sceneId, ad: trName(Game.scene.name), seçenek: tp.map(x => x.label) }; });
  await step('görev zinciri başı', () => { const q = QBY[82836]; acceptQuest(q); Game.P.quests[82836].ready = true; completeQuest(q); const q2 = QBY[82837]; return { s82837: questState(q2), s82840: questState(QBY[82840]), hedef: q2.goal }; });
  await step('Vadi: ön görev yok', () => { Game.warnT = 0; Dungeon.door(3); return ASKS.slice(-1); });
  await step('Ölüm Yabanı kapı (5)', async () => { acceptQuest(QBY[82837]); acceptQuest(QBY[82838]); Game.warnT = 0; Dungeon.door(5); await new Promise(r => setTimeout(r, 1500)); const m = Game.ents.filter(e => e.kind === 'mob'); return { sahne: Game.sceneId, ad: trName(Game.scene.name), lv: [...new Set(m.map(x => trName(x.name) + ':' + x.d.lv + (x.boss ? '★' : '')))] }; });
  await step('çok hedef 82838', () => { const q = QBY[82838]; for (let i = 0; i < 6; i++) { questKill('失心烈焰祭祀'); questKill('失心寒冰祭祀'); } const st = Game.P.quests[82838]; const a = { c: st.c, n: st.n, hazır: !!st.ready }; for (let i = 0; i < 5; i++) questKill('失心魔魂祭祀'); return { önce: a, sonra: { c: st.c, n: st.n, hazır: !!st.ready }, hedef: q.goal }; });
  await step('son boss → sandık', async () => { await gotoScene('120283', '白骨之庭', null, '120282'); const m = Game.ents.find(e => e.kind === 'mob' && e.name === '★嗜血暴徒首领'); const info = [m.d.lv, m.maxHp, m.atk]; killMob(m); await new Promise(r => setTimeout(r, 2500)); return { boss: info, görev: questState(QBY[82837]), sahne: trName(Game.scene.name), son: ASKS.slice(-2) }; });
  await step('zincir 82840', () => { completeQuest(QBY[82837]); const q = QBY[82840]; acceptQuest(q); return { durum: questState(q), hedef: q.goal }; });
  for (const [door, nm] of [[3, 'Vadi'], [7, 'Bataklık'], [9, 'Yayla']]) {
    if (door === 9) await p.evaluate(() => { const q = QBY[82840]; Game.P.quests[82840].ready = true; completeQuest(q); acceptQuest(QBY[82850]); });
    await stepA(`${nm} kapı (${door})`, async (door) => { if (Game.sceneId !== '120276') await gotoScene('120276', null, [16, 21]); Game.warnT = 0; Dungeon.door(door); await new Promise(r => setTimeout(r, 1500)); const D = Dungeon.of(Game.sceneId); const last = D && D[1].scenes.slice(-1)[0]; await gotoScene(last); const m = Game.ents.filter(e => e.kind === 'mob' && e.boss); return { zindan: D && trName(D[0].cn), son: trName(Game.scene.name), boss: m.map(x => [trName(x.name), x.d.lv, x.maxHp, x.atk]), son2: ASKS.slice(-1) }; }, door);
    await p.evaluate(async () => { await Dungeon.leave(true); });
  }
  console.log('HATA', errs); await b.close();
})();
