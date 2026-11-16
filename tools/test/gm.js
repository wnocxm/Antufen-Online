// GM paneli: zindan ve evcil hayvan komutları (panel düğmelerine gerçekten basılır).  node tools/test/gm.js  (OUT=görüntü öneki)
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="牧师"]'); await p.fill('#cname', 'GMTest'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const O = process.env.OUT || '/tmp/gm';
  const open = async () => { await p.evaluate(() => UI.open('gm')); await p.waitForTimeout(300); };
  const x = async (k) => { await p.click(`[data-x="${k}"]`); await p.waitForTimeout(1600); };
  const st = () => p.evaluate(() => ({ sahne: trName(Game.scene.name), dun: Game.P.dun && Game.P.dun.id, lv: Game.P.lv, hayvan: Pet.list().map(q => `${Pet.nm(q)} Sv${q.lv}`), çağrılı: !!Pet.ent, boss: Game.ents.filter(e => e.kind === 'mob' && e.boss && !e.dead).map(e => trName(e.name)) }));
  await open(); await p.click('[data-g="lvset"]').catch(() => {}); 
  await p.evaluate(() => gmLevel(40)); await p.click('[data-g="v:dg"]'); await p.waitForTimeout(300); await p.screenshot({ path: O + '_zindan.png' });
  await x('dg:in:swy:0'); console.log('zindana gir     ', JSON.stringify(await st()));
  await open(); await p.click('[data-g="v:dg"]'); await x('dg:last'); console.log('son kat         ', JSON.stringify(await st()));
  await open(); await p.click('[data-g="v:dg"]'); await p.click('[data-x="dg:boss"]'); await p.waitForTimeout(2500); console.log("boss'u öldür    ", JSON.stringify(await st()));
  await open(); await p.click('[data-g="v:dg"]'); await x('dg:door:myk:1'); console.log('kapıya git (elf)', JSON.stringify(await st()));
  await open(); await p.click('[data-g="v:pet"]'); await p.waitForTimeout(300); await p.screenshot({ path: O + '_evcil.png' });
  await x('pet:give:熊猫'); await x('pet:level'); console.log('hayvan ver+seviye', JSON.stringify(await st()));
  await p.click('[data-x="pet:items"]'); await p.click('[data-x="pet:hungry"]'); await p.click('[data-x="pet:care"]'); await p.waitForTimeout(300);
  console.log('eşya/bakım      ', JSON.stringify(await p.evaluate(() => ({ biluo: countItem('30022'), tokluk: Pet.active() && Pet.active().sat }))));
  await p.click('[data-x="pet:win"]'); await p.waitForTimeout(1000); await p.screenshot({ path: O + '_panda.png' });
  // dönüşüm ağacı: Ateş Devi ver, çağır, biçimleri sırayla geç (7. biçim mor Kıyıcı Ateş Tanrısı), rastgele beceri, dönüşüm malzemesi, dönüşüm penceresi
  await open(); await p.click('[data-g="v:pet"]'); await p.waitForTimeout(300); await x('pet:give:火巨灵');
  await p.evaluate(() => { const f = Pet.list().find(q => q.sp === '火巨灵'); Pet.summon(f.uid); });
  const ag = []; for (let i = 0; i < 7; i++) { await p.click('[data-x="pet:stage"]'); await p.waitForTimeout(150); ag.push(await p.evaluate(() => { const a = Pet.active(); return `${a.st}:${Pet.nm(a)}:${Pet.look(a)}`; })); }
  console.log('ağaç            ', ag.join(' | '));
  await p.click('[data-x="pet:skills"]'); await p.waitForTimeout(200); await p.click('[data-x="pet:tf"]'); await p.waitForTimeout(200);
  console.log('beceri+malzeme  ', JSON.stringify(await p.evaluate(() => ({ beceriler: Pet.skills(Pet.active()).map(Pet.skName), hayvan: Pet.list().length, lütuf: countItem('30164'), altın: Game.P.gold }))));
  await p.evaluate(() => { UI.closeAll(); Win.open('pet'); }); await p.waitForTimeout(1200); await p.screenshot({ path: O + '_atesdevi.png' });
  await open(); await p.click('[data-g="v:pet"]'); await p.waitForTimeout(300); await p.click('[data-x="pet:petfs"]'); await p.waitForTimeout(1000); await p.screenshot({ path: O + '_aktarma.png' });
  console.log('HATA', errs); await b.close();
})();
