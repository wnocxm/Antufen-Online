// Görev yol bulma: alınmamış → veren; alınmış öldür/topla → canavarın haritası (varınca yanına yürür, seçer, saldırmaz); hazır → ödülü veren.
// node tools/test/yolbul.js
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Yolbul'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  // Guanlin'de verilen, hedefi başka haritada olan bir öldürme görevi
  const r = await p.evaluate(async () => {
    gmLevel(15); Game.god = true; await gotoScene('120078');
    const here = new Set(Game.ents.map(e => e.cn || e.name));
    const q = QUESTS.find(q => q.type === 'kill' && !q.targets && here.has(q.giver) && q.to === q.giver && !Game.ents.some(e => e.kind === 'mob' && e.name === q.target) && monSceneNear(q.target, q.sc));
    const sc = sid => sid && trName(Assets.D.scenes[sid].name), out = { görev: q.id + ' ' + q.title, hedef: trName(q.target), harita: sc(monSceneNear(q.target, q.sc)) };
    questWalk(q); out.alınmamış = Game.goTarget ? 'NPC: ' + trName(Game.goTarget.cn) : 'rota: ' + sc(Game.route);
    acceptQuest(q); Game.player.path = null; Game.goTarget = null; questWalk(q); out.alınmış = Game.route ? 'rota: ' + sc(Game.route) : Game.goTarget ? 'NPC: ' + trName(Game.goTarget.cn) : 'yok';
    // varışı taklit et: hedef haritaya git, rota bitişi görevi sürdürsün
    const dest = Game.route; Game.route = null; await gotoScene(dest); Game.route = dest; Game.routeQuest = q.id; routeStep();
    out.varınca = (Game.target ? 'hedef: ' + trName(Game.target.name) : 'hedef yok') + (Game.engage ? ' (SALDIRIYOR!)' : ' (saldırmıyor)') + (Game.player.path ? ', yanına yürüyor' : '');
    Game.P.quests[q.id].ready = true; Game.player.path = null; questWalk(q); out.hazır = Game.route ? 'rota: ' + sc(Game.route) + ' → ' + trName(Game.routeNpc || '') : Game.goTarget ? 'NPC: ' + trName(Game.goTarget.cn) : 'yok';
    return out;
  });
  for (const [k, v] of Object.entries(r)) console.log(k.padEnd(10), v);
  console.log('HATA', errs); await b.close();
})();
