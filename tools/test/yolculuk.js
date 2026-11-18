// Yolculuk ağı testi (arabacılar, ışınlayıcılar).  node tools/test/yolculuk.js  (OUT=görüntü öneki, DIL=en)
// 1) Fırtına Büyücüsü (Başkent Soylular Mahallesi) Bozbalta Şehri'ne ışınlar. 2) İnsan Kampı'ndaki arabacı: 100 altın, sayfalı şehir listesi,
// Altındalga'ya varış. 3) Altın yetmezse gidilmez. 4) Otomatik yol: yürüyerek gidilemeyen Bozbalta'ya yolculuk NPC'si üzerinden (hedef en üstte).
// 5) GM ücretsiz yolculuk. 6) Bütün yolculuk seçeneklerinin adı seçili dilde (Çince kalan yok).
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message)); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.addInitScript(D => { try { localStorage.setItem('anrufen_lang', D); } catch (e) {} }, process.env.DIL || 'tr');
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMYol'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const O = process.env.OUT || '/tmp/yol', log = (k, v) => console.log(k.padEnd(30), JSON.stringify(v));
  const go = async sid => { await p.evaluate(s => gotoScene(s, null, null, null), sid); await wait(sid); };
  const wait = async sid => { await p.waitForFunction(s => Game.sceneId === s && Game.player && !Game.transit && !document.querySelector('#loading:not(.hidden)'), sid, { timeout: 30000 }); await p.waitForTimeout(700); };
  const talk = async cn => { await p.evaluate(c => { UI.closeAll(); const n = Game.ents.find(e => e.kind === 'npc' && e.cn === c); Win.open('npc', { npc: n }); }, cn); await p.waitForTimeout(300); return p.evaluate(() => Win.npcOpts().o.map(x => x.t)); };
  // satıra dokun (uzun söz sayfalıysa önce "Devam"lara basılır, oyuncunun yaptığı gibi)
  const row = async re => {
    for (let k = 0; k < 8; k++) { const d = await p.evaluate(() => Win.npcDrawn()); if (!(d.length === 1 && /^(Devam|Continue)$/.test(d[0]))) break; await p.evaluate(() => Win.npcRow(0)); await p.waitForTimeout(250); }
    const i = await p.evaluate(r => Win.npcDrawn().findIndex(t => new RegExp(r).test(t)), re); if (i < 0) throw new Error('satır yok: ' + re + ' ' + JSON.stringify(await p.evaluate(() => Win.npcDrawn())));
    await p.evaluate(i => Win.npcRow(i), i); await p.waitForTimeout(350); };
  // 1) Fırtına Büyücüsü
  await go('120093'); log('Fırtına Büyücüsü', await talk('风暴法师'));
  await row('Bozbalta|Greyaxe'); await wait('120156'); log('vardı', await p.evaluate(() => [Game.sceneId, trName(Game.scene.name), Math.round(Game.player.x), Math.round(Game.player.y)]));
  // 2) arabacı (İnsan Kampı)
  await go('120521'); await p.evaluate(() => { Game.P.gold = 250; });
  log('arabacı', await talk('驿站老板（人类）')); await row('Yolculuk|Travel');
  log('liste 1', await p.evaluate(() => Win.npcOpts().o.map(x => x.t))); await p.screenshot({ path: O + '_liste.png' });
  await row('Diğer|More'); log('liste 2', await p.evaluate(() => Win.npcOpts().o.map(x => x.t)));
  await row('Geri|Back'); await row('Yolculuk|Travel');
  for (let k = 0; k < 4; k++) { const has = await p.evaluate(() => Win.npcDrawn().some(t => /Altındalga|Goldwave/.test(t))); if (has) break; await row('Diğer|More'); }
  await row('Altındalga|Goldwave'); await wait('120258'); log('Altındalga\'ya vardı', await p.evaluate(() => ({ sahne: trName(Game.scene.name), altın: Game.P.gold })));
  // 3) altın yetmez
  log('altın yetmez', await p.evaluate(() => { Game.P.gold = 20; const n = Game.ents.find(e => e.kind === 'npc' && travelOf(e)); const x = travelOf(n).find(y => y[0] === 'araba'); const s0 = Game.sceneId; travelGo(n, x); return { kaldı: Game.sceneId === s0, altın: Game.P.gold }; }));
  // 4) otomatik yol: Altındalga → Bozbalta
  await go('120094');
  log('yol (yürüyerek / yolculukla)', await p.evaluate(() => [!!scenePath('120094', '120156'), (routePath('120094', '120156') || []).map(s => trName(Assets.D.scenes[s].name))]));
  await p.evaluate(() => { Game.P.gold = 500; routeTo('120156'); });
  for (let k = 0; k < 40; k++) { const st = await p.evaluate(() => ({ s: Game.sceneId, h: Game.travelHint, open: Win.isOpen && Win.isOpen() })); if (st.h && (await p.evaluate(() => !!document.querySelector('canvas')))) { const n = await p.evaluate(() => Game.goTarget && Game.goTarget.cn); if (!n) break; } await p.waitForTimeout(500); }
  log('yolculuk NPC\'sine yürüyor', await p.evaluate(() => ({ sahne: trName(Game.scene.name), hedef: Game.travelHint && trName(Assets.D.scenes[Game.travelHint].name), npc: Game.goTarget && trName(Game.goTarget.cn) })));
  await p.evaluate(() => { const n = Game.goTarget || Game.ents.find(e => e.kind === 'npc' && (travelOf(e) || []).some(x => x[2] === Game.travelHint)); if (n) { Game.player.x = n.x; Game.player.y = n.y + 1; UI.closeAll(); Win.open('npc', { npc: n }); } });
  await p.waitForTimeout(300); log('ilk satır (hedef)', await p.evaluate(() => Win.npcOpts().o[0].t)); await p.screenshot({ path: O + '_ipucu.png' });
  // 5) GM ücretsiz
  log('GM ücretsiz', await p.evaluate(() => { Game.gmFreeTravel = true; const n = Game.ents.find(e => e.kind === 'npc' && travelOf(e)); const r = travelLabel(n, travelOf(n)[0]); Game.gmFreeTravel = false; return r; }));
  // 6) adlar
  log('çevrilmeyen adlar', await p.evaluate(() => { const bad = new Set(); for (const [id, L] of Object.entries(TRAVEL.npc)) for (const x of L) { const t = travelLabel({ id, cn: '' }, x); if (/[一-鿿]/.test(t)) bad.add(x[1]); } return [...bad]; }));
  console.log('HATA', errs); await b.close();
})();
