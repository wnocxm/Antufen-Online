// C++ ↔ HTML canavar ve savaş karşılaştırması (docs/09-cpp.md). Zar: HTML'de Math.random yerine C++'takiyle aynı tohumlu üreteç
// (mulberry32); oyun döngüsü durdurulur, iki tarafta da sabit adımla ilerletilir. Karşılaştırılan:
//   1) canavar yerleşimi (ad, yer, yön, can, seviye, saldırı, savunma, gezinme süresi),
//   2) otomatik savaş (her saniye: oyuncu canı/manası, seviye, deneyim, altın, yer, hedef ve canı, yaşayan canavarlar, canavarların
//      toplam yeri, ölüm, çanta) — en yakın canavarı hedef al, ölünce sıradakini.
//   node tools/test/cpp_savas.js   (OUT=klasör; URL verilmezse www/ geçici bir sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_savas';
// [ad, sahne, x, y, sınıf, ırk, cinsiyet, seviye, tohum, saniye]
// x, y = 0: sahnedeki ilk canavar kaydının doğduğu yer (oyuncu canavarların arasında başlar; geçilmezse oyun en yakın boş kareye koyar)
const CASES = [
  ['olum_9', '120018', 0, 0, '战士', '人类', 'male', 9, 9, 15],              // 24 canavarın ortasında: hepsi saldırır, oyuncu ölür
  ['savasci_20', '120018', 0, 0, '战士', '人类', 'male', 20, 11, 60],        // bölgeden yüksek: canavarlar kendiliğinden saldırmaz, tek tek avlanır
  ['buyucu_22', '120019', 0, 0, '法师', '人类', 'fema', 22, 12, 60],         // mermi (ateş topu) uçuşu
  ['elf_rahip_32', '120036', 0, 0, '牧师', '精灵', 'male', 32, 22, 60],     // gece elfi: Yaşam Elementi zarı
  ['elf_savasci_42', '120051', 0, 0, '战士', '精灵', 'fema', 42, 32, 60],
  ['buyucu_60', '120014', 0, 0, '法师', '精灵', 'male', 60, 55, 60],
  ['rahip_70', '120034', 0, 0, '牧师', '人类', 'male', 70, 60, 60],
  ['savasci_88', '120495', 0, 0, '战士', '精灵', 'male', 88, 80, 60],       // seçkinler (☆)
];
const DT = 1 / 30;
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMSavas'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  const start = await p.evaluate(() => Game.sceneId);
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; SFX.play = () => {}; });   // döngü durur; ses zar atmasın
  const scen = ['veri www/assets', `sahne ${start}`], html = {};
  for (let [ad, sid, x, y, cls, race, sex, lv, seed, sec] of CASES) {
    if (!x && !y) [x, y] = await p.evaluate(s => { const D = Assets.D, e = D.scenes[s].ents.find(e => D.mon[e[0]]); return e[2].slice(0, 2); }, sid);
    await p.evaluate(([cls, race, sex, lv, seed, M]) => {
      const P = Game.P; P.cls = cls; P.race = race; P.sex = sex; P.eq = {}; P.bag = []; P.gold = 0; P.xp = 0; P.lv = 1; P.sk = {}; gmLevel(lv);
      Math.random = eval(M)(seed);
    }, [cls, race, sex, lv, seed, MULBERRY]);
    await p.evaluate(([s, x, y]) => gotoScene(s, null, [x, y], null), [sid, x, y]);
    await p.waitForFunction(s => Game.sceneId === s && Game.player && !Game.transit, sid, { timeout: 30000 });
    html[ad] = await p.evaluate(([sec, DT]) => {
      const pl = Game.player, s0 = stats(); pl.hp = s0.hp; pl.mp = s0.mp; pl.doll.set(look());
      const mobs = Game.ents.map((e, i) => [e, i]).filter(([e]) => e.kind === 'mob').map(([e, i]) => ({ i, ad: e.name, x: e.x, y: e.y, yon: e.dir, can: e.hp, sv: e.d.lv, saldiri: e.atk, savunma: e.def, gezinme: e.wanderT, durum: e.state }));
      const trace = [], per = Math.round(1 / DT), steps = Math.round(sec / DT);
      for (let k = 1; k <= steps; k++) {
        if (!Game.target || Game.target.dead) { const m = nearestMob(8); if (m) setTarget(m, true); }
        window.__upd(DT);
        if (k % per === 0) {
          let alive = 0, sx = 0, sy = 0; for (const e of Game.ents) if (e.kind === 'mob') { alive += !e.dead; sx += e.x; sy += e.y; }
          const t = Game.target ? Game.ents.indexOf(Game.target) : -1;
          trace.push({ s: k * DT, hp: pl.hp, mp: pl.mp, lv: Game.P.lv, xp: Game.P.xp, altin: Game.P.gold, x: pl.x, y: pl.y, hedef: t, hedefCan: t >= 0 ? Game.target.hp : -1, canli: alive, canavarX: sx, canavarY: sy, olu: !!pl.dead, canta: Game.P.bag.map(b => b.id + ':' + b.n).join(',') });
        }
      }
      return { mobs, trace, pos: [pl.x, pl.y] };
    }, [sec, DT]);
    scen.push(`tohum ${seed}`, `karakter ${cls} ${race} ${sex}`, `seviye ${lv}`, `sahne ${sid} ${x} ${y}`, 'doldur',
      `canavarlar ${path.join(OUT, ad + '_canavar.json')}`, `savas ${DT} ${sec} ${path.join(OUT, ad + '_iz.json')} oto`);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  // karşılaştır
  const near = (a, b) => typeof a === 'number' ? Math.abs(a - b) <= 1e-6 * Math.max(1, Math.abs(a)) : a === b;
  let bad = 0;
  for (const [ad] of CASES) {
    const cm = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_canavar.json'), 'utf8')), hm = html[ad].mobs;
    let mobDiff = cm.length !== hm.length ? `sayı ${hm.length}/${cm.length}` : '';
    for (let i = 0; i < Math.min(cm.length, hm.length) && !mobDiff; i++) for (const k of Object.keys(hm[i])) if (!near(hm[i][k], cm[i][k])) { mobDiff = `#${i} ${k}: HTML ${hm[i][k]} · C++ ${cm[i][k]}`; break; }
    const ct = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_iz.json'), 'utf8')), ht = html[ad].trace;
    let trDiff = '';
    for (let i = 0; i < Math.min(ct.length, ht.length) && !trDiff; i++) for (const k of Object.keys(ht[i])) if (!near(ht[i][k], ct[i][k])) { trDiff = `${ht[i].s.toFixed(0)}. sn ${k}: HTML ${ht[i][k]} · C++ ${ct[i][k]}`; break; }
    const last = ht[ht.length - 1];
    console.log(`${ad.padEnd(13)} canavar ${String(hm.length).padStart(2)}: ${mobDiff ? 'FARKLI ' + mobDiff : 'aynı'} · savaş ${ht.length} sn: ${trDiff ? 'FARKLI ' + trDiff : 'aynı'}` +
      ` (son: Sv ${last.lv}, can ${Math.round(last.hp)}, altın ${last.altin}, yaşayan ${last.canli}, çanta ${last.canta || '-'})`);
    if (mobDiff || trDiff) bad++;
  }
  if (errs.length) console.log('HATA', errs);
  process.exitCode = bad ? 1 : 0;
})();
