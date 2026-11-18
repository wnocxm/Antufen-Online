// Beceri ağaçları testi (orijinal kurallar).  node tools/test/beceri.js  (OUT=görüntü öneki, DIL=en)
// 1) 6 sekme (acemi, sınıf, iki uzmanlık, ırk, yaşam). 2) Ön koşul: alt beceri üstündekinin 5. kademesini ister. 3) Sınıf ağacı: sınıf
// yükseltmesi + acemi ağacına 35 puan. 4) Uzmanlık: ikinci yükseltme + sınıf ağacına 40 puan; iki uzmanlık birbirini dışlar.
// 5) Puanları Sıfırla: Eğitim Kitabı ister, puanlar geri gelir. 6) Irk becerileri. 7) Eski kayıt: şartı tutmayan beceri geri alınır.
// 8) Üç sınıfta iki uzmanlıkla ağaçları doldurup bütün etkin becerileri canavara karşı kullanır (hata çıkmamalı).
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message)); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.addInitScript(D => { try { localStorage.setItem('anrufen_lang', D); } catch (e) {} }, process.env.DIL || 'tr');
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMBeceri'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const O = process.env.OUT || '/tmp/beceri', log = (k, v) => console.log(k.padEnd(30), JSON.stringify(v));
  const ev = f => p.evaluate(f);
  log('sekmeler', await ev(() => TREES[Game.P.cls].map(t => t.race ? raceTree().tr : t.name)));
  log('başlangıç', await ev(() => ({ sk: Game.P.sk, sp: Game.P.sp })));
  // ön koşul
  log('ön koşul (Bıçak Fırlatma)', await ev(() => { const sk = SKBYSN[90021]; skillUp(sk); return { kilit: skLock(sk), kademe: skRank(sk) }; }));
  log('1. beceri 5 → Çeviklik açılır', await ev(() => { const P = Game.P; P.sp = 10; for (let k = 0; k < 4; k++) skillUp(SKBYSN[90020]); skillUp(SKBYSN[90043]); return { w1: P.sk.w1, wp3: P.sk.wp3, kilit: skLock(SKBYSN[90043]) }; }));
  // sınıf ağacı
  log('sınıf ağacı (yükseltmesiz)', await ev(() => skLock(SKBYSN[90044])));
  log('yükseltme var, puan az', await ev(() => { classUp(1); return skLock(SKBYSN[90044]); }));
  log('acemiye 35 puan → açık', await ev(() => { const P = Game.P; P.sp = 40; skillAutoSpend(30); return { acemi: treePts(150008), kilit: skLock(SKBYSN[90044]) }; }));
  // uzmanlık ve dışlama
  log('uzmanlık (80 yok)', await ev(() => skLock(SKBYSN[90106])));
  log('kök seçildi → öbürü kapalı', await ev(() => { const P = Game.P; gmLevel(80); classUp(2); P.sk = {}; P.sp = 0; skillAutoSpend(81, 0); return { kana: skRank(SKBYSN[90106]), öfke: skLock(SKBYSN[90117]), sınıfPuanı: treePts(150009), ad: clsName() }; }));
  await ev(() => { UI.closeAll(); Win.open('skill'); Win.tapId(50398); }); await p.waitForTimeout(300); await ev(() => Win.tapId('sk:2')); await p.waitForTimeout(500); await p.screenshot({ path: O + '_uzmanlik.png' });
  await ev(() => Win.tapId(50399)); await p.waitForTimeout(500); await p.screenshot({ path: O + '_dislanan.png' });
  // sıfırlama
  log('sıfırla (kitapsız)', await ev(() => { const P = Game.P, a = Object.keys(P.sk).length; skillReset(false); return { önce: a, sonra: Object.keys(P.sk).length }; }));
  log('sıfırla (Eğitim Kitabı)', await ev(() => { const P = Game.P, spent = Object.values(P.sk).reduce((a, b) => a + b, 0), sp0 = P.sp; addItem('30092', 1); skillReset(false); return { harcanan: spent, puan: P.sp, eski: sp0, kitap: countItem('30092'), sk: P.sk }; }));
  log('eğitmen dükkânı', await ev(() => SHOPS['技能训练师（人类）']));
  // ırk becerileri
  log('ırk: insan', await ev(() => { const s = stats(); return { altın: s.goldUp, savunmaEk: 2 * Game.P.lv }; }));
  log('ırk: elf', await ev(() => { const P = Game.P; P.race = '精灵'; const s = stats(); const r = { yaşamElementi: s.lifeEl, ad: raceTree().tr }; P.race = '人类'; return r; }));
  // eski kayıt
  log('eski kayıt düzeltme', await ev(() => { const s = JSON.parse(JSON.stringify(Game.P)); s.adv = 0; s.sk = { w1: 2, w3: 4, wp1: 3, w4: 2 }; s.sp = 0; fixSkills(s); return { sk: s.sk, sp: s.sp }; }));
  // bütün etkin beceriler, üç sınıf, iki uzmanlık (120. seviye: uzmanlık ağacının hepsi öğrenilir)
  const run = (cls, spec) => p.evaluate(async ([cls, spec]) => {
    const P = Game.P, q = () => {}; P.cls = cls; P.sk = {}; P.sp = 0; gmLevel(120); ClassGM.fill(spec); const C = CLS[cls], p = Game.player, used = [];
    for (let i = 0; i < C.skills.length; i++) { const sk = C.skills[i]; if (sk.pas || !skRank(sk)) continue;
      Game.ents = Game.ents.filter(e => e.kind !== 'mob'); const m = new Mob('☆水仙子', p.x + 1.2, p.y); m.home = { x: m.x, y: m.y }; m.aggro = true; Game.ents.push(m); setTarget(m, true);
      p.cds = {}; p.mp = stats().mp; p.hp = stats().hp; p.state = 'idle'; p.buffs = []; const hp0 = m.hp;
      useSkill(i); for (let k = 0; k < 60; k++) update(0.05);
      used.push(`${sk.name}:${hp0 - m.hp > 0 ? '-' + Math.round(hp0 - m.hp) : p.buffs.length ? 'güç' : '·'}`); }
    return used.join(' | ');
  }, [cls, spec]);
  for (const [c, s] of [['战士', 0], ['战士', 1], ['法师', 0], ['法师', 1], ['牧师', 0], ['牧师', 1]]) log(`beceriler ${c}/${s}`, await run(c, s));
  console.log('HATA', errs); await b.close();
})();
