const { chromium } = require('playwright');
const O = process.argv[2] || 'tanitim/';
(async () => {
  const b = await chromium.launch(); const ctx = await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 });
  await ctx.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
  const p = await ctx.newPage(); const errs = []; p.on('pageerror', e => errs.push(e.message));
  const shot = async n => { await p.waitForTimeout(500); await p.screenshot({ path: O + n + '.png' }); console.log(n); };
  await p.goto('' + (process.env.URL || 'http://localhost:8099/') + ''); await p.waitForTimeout(2500); await shot('01_giris_ekrani');
  await p.keyboard.press('Enter'); await p.waitForTimeout(800);
  await p.click('[data-cls="法师"]'); await p.fill('#cname', 'Aldera'); await p.waitForTimeout(400); await shot('02_karakter_olusturma');
  await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  await p.waitForTimeout(2000); await shot('03_ilk_kamp');
  await p.evaluate(() => { gmLevel(32); gmGear(); __G.god = true; const C = CLS[__G.P.cls]; for (const s of C.skills) __G.P.sk[s.id] = 5; });
  const go = async (sid, w = 2500, center = true) => { await p.evaluate(async ([s, c]) => { await loadScene(s); if (!c) return; const M = __G.map, pl = __G.player; let best = null, bd = 1e9;
      for (let y = 8; y < M.h - 8; y++) for (let x = 8; x < M.w - 8; x++) if (!M.blocked(x, y) && !M.blocked(x + 3, y) && !M.blocked(x, y + 1)) { const d = Math.hypot(x - M.w / 2, y - M.h / 2); if (d < bd) { bd = d; best = [x, y]; } }
      if (best) { pl.x = best[0]; pl.y = best[1]; pl.path = null; } }, [sid, center]); await p.waitForTimeout(w); };
  // savaş: büyücü ateş topu + kar fırtınası
  await go('120018');
  const cast = async (k, waits) => { await p.evaluate(k => { const C = CLS[__G.P.cls], act = C.skills.filter(s => !s.pas), i = C.skills.indexOf(act[k]), pl = __G.player;
      const ms = __G.ents.filter(e => e.kind === 'mob' && !e.dead); const m = ms[0]; m.x = pl.x + 3; m.y = pl.y + 0.5; if (ms[1]) { ms[1].x = pl.x + 3.6; ms[1].y = pl.y - 0.6; } m.hp = m.maxHp = 99999; setTarget(m); pl.cds = {}; pl.mp = 99999; useSkill(i); }, k); for (const w of waits) await p.waitForTimeout(w); };
  await p.waitForTimeout(1500); await cast(0, [380]); await p.screenshot({ path: O + '04_savas_ates_topu.png' }); console.log('04');
  await p.waitForTimeout(1500);
  await cast(5, [700]); await p.screenshot({ path: O + '05_savas_kar_firtinasi.png' }); console.log('05');
  await p.waitForTimeout(1200);
  await go('120067', 3500, false); await shot('06_sehir_mangri');
  await go('120086', 3500); await shot('07_imparatorluk_baskenti');
  await go('120094', 3500); await shot('08_liman');
  await go('120218', 3500); await shot('09_kar_bolgesi');
  await go('120016', 3000, false);
  await p.evaluate(() => { for (const id of Object.keys(ITEMS).filter(k => ITEMS[k].slot || ITEMS[k].use).slice(0, 14)) addItem(id, 1 + (ITEMS[id].use ? 4 : 0), true); for (const q of QUESTS.slice(0, 4)) if (!__G.P.quests[q.id] && !__G.P.done[q.id]) acceptQuest(q); UI.refresh(); });
  for (const [k, n] of [['char', '10_karakter_penceresi'], ['bag', '11_canta'], ['skill', '12_beceriler'], ['quest', '13_gorevler'], ['map', '14_dunya_haritasi']]) { await p.evaluate(k => UI.open(k), k); await shot(n); await p.evaluate(() => UI.closeAll()); }
  console.log(errs); await b.close();
})();
