// C++ ↔ HTML canavar, savaş ve beceri karşılaştırması (docs/09-cpp.md). Zar: HTML'de Math.random yerine C++'takiyle aynı tohumlu
// üreteç (mulberry32); oyun döngüsü durdurulur, iki tarafta da sabit adımla ilerletilir. Karşılaştırılan:
//   1) canavar yerleşimi (ad, yer, yön, can, seviye, saldırı, savunma, gezinme süresi),
//   2) beceri puanı dağılımı (becerili senaryolarda: puanlar oyuncu gibi dağıtılır, HTML skillAutoSpend),
//   3) otomatik savaş (her saniye: oyuncu canı/manası, seviye, deneyim, altın, yer, hedef ve canı, yaşayan canavarlar, canavarların
//      toplam yeri ve canı, güçlendirmeler, ölüm, çanta, o saniyedeki ses olayları) — en yakın canavarı hedef al, ölünce sıradakini; becerili senaryolarda her
//      adımda sıradaki hazır beceri de kullanılır (sırayla döner: bir önceki kullanılandan sonraki ilk hazır beceri; bekleme bitmiş,
//      mana yeter; menzil dışındaysa oyuncu yürür).
//   node tools/test/cpp_savas.js   (OUT=klasör; URL verilmezse www/ geçici bir sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_savas';
// [ad, sahne, x, y, sınıf, ırk, cinsiyet, seviye, tohum, saniye, beceri: [sınıf yükseltmesi, uzmanlık] (yoksa yalnız normal saldırı)]
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
  // becerili: acemi ağacı (40 altı), sınıf ağacı (40-79), 80'de altı uzmanlığın her biri
  ['b_savasci_20', '120018', 0, 0, '战士', '人类', 'male', 20, 101, 60, [0, 0]],
  ['b_buyucu_22', '120019', 0, 0, '法师', '人类', 'fema', 22, 102, 60, [0, 0]],
  ['b_rahip_32', '120036', 0, 0, '牧师', '精灵', 'male', 32, 103, 60, [0, 0]],
  ['b_savasci_45', '120051', 0, 0, '战士', '精灵', 'fema', 45, 104, 60, [1, 0]],
  ['b_buyucu_60', '120014', 0, 0, '法师', '精灵', 'male', 60, 105, 60, [1, 0]],
  ['b_rahip_70', '120034', 0, 0, '牧师', '人类', 'male', 70, 106, 60, [1, 0]],
  ['b_kana_88', '120495', 0, 0, '战士', '精灵', 'male', 88, 107, 60, [2, 0]],      // Kana Susamış
  ['b_ofke_88', '120495', 0, 0, '战士', '人类', 'male', 88, 108, 60, [2, 1]],      // Öfke
  ['b_element_88', '120495', 0, 0, '法师', '人类', 'fema', 88, 109, 60, [2, 0]],   // Element
  ['b_gizem_88', '120495', 0, 0, '法师', '精灵', 'male', 88, 110, 60, [2, 1]],     // Gizem
  ['b_kutsal_88', '120495', 0, 0, '牧师', '人类', 'male', 88, 111, 60, [2, 0]],    // Kutsal
  ['b_golge_88', '120495', 0, 0, '牧师', '精灵', 'fema', 88, 112, 60, [2, 1]],     // Gölge
  // 120: uzmanlıkların 5.-6. kademe becerileri de açılır (Karşı Saldırı Fırtınası, Öfke, Gölge Hükümdarı, Kutsal Kalkan…)
  ['b_kana_120', '120495', 0, 0, '战士', '人类', 'fema', 120, 121, 60, [2, 0]],
  ['b_ofke_120', '120495', 0, 0, '战士', '精灵', 'male', 120, 122, 60, [2, 1]],
  ['b_element_120', '120495', 0, 0, '法师', '精灵', 'fema', 120, 123, 60, [2, 0]],
  ['b_gizem_120', '120495', 0, 0, '法师', '人类', 'male', 120, 124, 60, [2, 1]],
  ['b_kutsal_120', '120495', 0, 0, '牧师', '精灵', 'male', 120, 125, 60, [2, 0]],
  ['b_golge_120', '120495', 0, 0, '牧师', '人类', 'fema', 120, 126, 60, [2, 1]],
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
  // döngü durur; ses çağrıları kaydedilir (C++'ın ses olaylarıyla karşılaştırılır)
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; window.__snd = []; SFX.play = (n, v = 1) => { if (n) __snd.push([n, v]); }; SFX.Music.play = n => { if (n) __snd.push(['muzik', n]); }; });
  const scen = ['veri www/assets', `sahne ${start}`], html = {};
  for (let [ad, sid, x, y, cls, race, sex, lv, seed, sec, bec] of CASES) {
    if (!x && !y) [x, y] = await p.evaluate(s => { const D = Assets.D, e = D.scenes[s].ents.find(e => D.mon[e[0]]); return e[2].slice(0, 2); }, sid);
    const sk = await p.evaluate(([cls, race, sex, lv, seed, M, bec]) => {
      const P = Game.P; P.cls = cls; P.race = race; P.sex = sex; P.eq = {}; P.bag = []; P.gold = 0; P.xp = 0; P.lv = 1; P.sk = {}; P.adv = 0; gmLevel(lv);
      if (bec) { P.adv = bec[0]; P.sk = {}; P.sp = 0; skillAutoSpend(lv + 1, bec[1]); }
      Math.random = eval(M)(seed);
      return Object.keys(P.sk).sort().map(k => k + '=' + P.sk[k]).join(',');
    }, [cls, race, sex, lv, seed, MULBERRY, bec || null]);
    await p.evaluate(([s, x, y]) => gotoScene(s, null, [x, y], null), [sid, x, y]);
    await p.waitForFunction(s => Game.sceneId === s && Game.player && !Game.transit, sid, { timeout: 30000 });
    html[ad] = await p.evaluate(([sec, DT, bec]) => {
      Game.time = 0;
      const pl = Game.player, s0 = stats(); pl.hp = s0.hp; pl.mp = s0.mp; pl.doll.set(look());
      const mobs = Game.ents.map((e, i) => [e, i]).filter(([e]) => e.kind === 'mob').map(([e, i]) => ({ i, ad: e.name, x: e.x, y: e.y, yon: e.dir, can: e.hp, sv: e.d.lv, saldiri: e.atk, savunma: e.def, gezinme: e.wanderT, durum: e.state }));
      const trace = [], per = Math.round(1 / DT), steps = Math.round(sec / DT); let rot = 0; __snd = [];   // beceriler sırayla (her biri sırası gelince)
      for (let k = 1; k <= steps; k++) {
        if (!Game.target || Game.target.dead) { const m = nearestMob(8); if (m) setTarget(m, true); }
        if (bec && !pl.dead && pl.pending == null && pl.state !== 'attack' && pl.state !== 'cast') {
          const L = CLS[Game.P.cls].skills;
          for (let j = 0; j < L.length; j++) { const i = (rot + j) % L.length, sk = L[i]; if (sk.pas || !skRank(sk) || (pl.cds[sk.id] || 0) > 0) continue; useSkill(i); if ((pl.cds[sk.id] || 0) > 0 || pl.pending != null) { rot = i + 1; break; } }
        }
        window.__upd(DT);
        if (k % per === 0) {
          let alive = 0, sx = 0, sy = 0, mh = 0; for (const e of Game.ents) if (e.kind === 'mob') { alive += !e.dead; sx += e.x; sy += e.y; mh += e.hp; }
          const t = Game.target ? Game.ents.indexOf(Game.target) : -1;
          trace.push({ s: k * DT, hp: pl.hp, mp: pl.mp, lv: Game.P.lv, xp: Game.P.xp, altin: Game.P.gold, x: pl.x, y: pl.y, hedef: t, hedefCan: t >= 0 ? Game.target.hp : -1, canli: alive, canavarX: sx, canavarY: sy, olu: !!pl.dead, canta: Game.P.bag.map(b => b.id + ':' + b.n).join(','), canavarCan: mh, guc: pl.buffs.map(b => b.id).join(','), ses: __snd.splice(0) });
        }
      }
      return { mobs, trace, pos: [pl.x, pl.y] };
    }, [sec, DT, bec || null]);
    html[ad].sk = sk;
    scen.push(`tohum ${seed}`, `karakter ${cls} ${race} ${sex}`, `seviye ${lv}`);
    if (bec) scen.push(`ust ${bec[0]}`, `dagit ${lv + 1} ${bec[1]} ${path.join(OUT, ad + '_beceri.txt')}`);
    scen.push(`sahne ${sid} ${x} ${y}`, 'zaman0', 'doldur',
      `canavarlar ${path.join(OUT, ad + '_canavar.json')}`, 'sestemizle', `savas ${DT} ${sec} ${path.join(OUT, ad + '_iz.json')} ${bec ? 'beceri' : 'oto'}`);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  // karşılaştır
  const near = (a, b) => typeof a === 'number' ? Math.abs(a - b) <= 1e-6 * Math.max(1, Math.abs(a)) : a && typeof a === 'object' ? JSON.stringify(a) === JSON.stringify(b) : a === b;
  let bad = 0;
  for (const [ad, , , , , , , , , , bec] of CASES) {
    const cm = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_canavar.json'), 'utf8')), hm = html[ad].mobs;
    let mobDiff = cm.length !== hm.length ? `sayı ${hm.length}/${cm.length}` : '';
    if (bec) { const cs = fs.readFileSync(path.join(OUT, ad + '_beceri.txt'), 'utf8').trim(); if (cs !== html[ad].sk) mobDiff = `beceri puanları HTML ${html[ad].sk} · C++ ${cs}`; }
    for (let i = 0; i < Math.min(cm.length, hm.length) && !mobDiff; i++) for (const k of Object.keys(hm[i])) if (!near(hm[i][k], cm[i][k])) { mobDiff = `#${i} ${k}: HTML ${hm[i][k]} · C++ ${cm[i][k]}`; break; }
    const ct = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_iz.json'), 'utf8')), ht = html[ad].trace;
    let trDiff = '';
    for (let i = 0; i < Math.min(ct.length, ht.length) && !trDiff; i++) for (const k of Object.keys(ht[i])) if (!near(ht[i][k], ct[i][k])) { trDiff = `${ht[i].s.toFixed(0)}. sn ${k}: HTML ${ht[i][k]} · C++ ${ct[i][k]}`; break; }
    const last = ht[ht.length - 1];
    console.log(`${ad.padEnd(13)} canavar ${String(hm.length).padStart(2)}: ${mobDiff ? 'FARKLI ' + mobDiff : 'aynı'} · savaş ${ht.length} sn: ${trDiff ? 'FARKLI ' + trDiff : 'aynı'}` +
      ` (son: Sv ${last.lv}, can ${Math.round(last.hp)}, altın ${last.altin}, yaşayan ${last.canli}, çanta ${last.canta || '-'}${bec ? ', güç ' + (last.guc || '-') : ''})`);
    if (mobDiff || trDiff) bad++;
  }
  if (errs.length) console.log('HATA', errs);
  process.exitCode = bad ? 1 : 0;
})();
