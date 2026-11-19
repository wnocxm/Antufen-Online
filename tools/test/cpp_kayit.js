// C++ ↔ HTML kayıt karşılaştırması (docs/09-cpp.md, 12. adım). Kayıt biçimi iki sürümde aynı JSON (HTML localStorage 'anrufen_save_v1').
// A) Yeni karakter: HTML'de giriş ekranı → Yeni Karakter → oluşturma paneli (sınıf, ırk, cinsiyet, yüz, ad) → Oyuna başla; C++'ta
//    yenikarakter + baslat. Kayıt ve karakter durumu (değerler, görünüş, can, mana) aynı mı.
// B) HTML → C++: zengin bir HTML kaydı (Sv 45, sınıf yükseltmesi, ekipman ve çıkarılmış yuva, beceriler, görevler, evcil hayvanlar,
//    zindan koşusu, günlük sayaç, ev, kısayol, sunucu kimliği ve bilinmeyen alan) C++'ta okunup yazılınca aynı mı; sonra iki sürüm de
//    kayıttan başlar (HTML: sayfa yenilenir, giriş ekranında Devam Et): kayıt ve durum aynı mı.
// C) C++ → HTML: C++'ta oluşturulan kaydı HTML okur (localStorage + Devam Et), iki sürüm de kaydeder: aynı mı.
// D) Eski/bozuk kayıtlar (HTML fixSave): ekipmansız eski kayıt (acemi başlığı), eski kısayollar, becerisiz kayıt, kademesi aşan ve
//    kilitli beceriler, v ≠ 1, bilinmeyen sınıf: düzeltilmiş kayıt aynı mı (geçersizde iki sürüm de "kayıt yok").
//   node tools/test/cpp_kayit.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
// DIL=en: İngilizce kip (HTML localStorage anrufen_lang = en; C++ "dil en")
const DIL = process.env.DIL === 'en' ? ['dil en'] : [];
const OUT = process.env.OUT || '/tmp/cpp_kayit', NOW = 1800000000000;
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
const CHARS = [['Kahraman', '战士', '人类', 'male', 1], ['Ayşe', '法师', '精灵', 'fema', 3], ['Işıl', '牧师', '人类', 'fema', 8], ['Doğan', '牧师', '精灵', 'male', 5]];
// anahtarları sıralı, karşılaştırılabilir metin
const canon = v => Array.isArray(v) ? v.map(canon) : v && typeof v === 'object' ? Object.fromEntries(Object.keys(v).sort().map(k => [k, canon(v[k])])) : v;
const same = (a, b) => JSON.stringify(canon(a)) === JSON.stringify(canon(b));
// ilk fark: yol ve iki değer
function diff(a, b, p = '') {
  if (same(a, b)) return null;
  if (a && b && typeof a === 'object' && typeof b === 'object' && Array.isArray(a) === Array.isArray(b)) {
    for (const k of new Set([...Object.keys(a), ...Object.keys(b)])) { const d = diff(a[k], b[k], p + '.' + k); if (d) return d; }
  }
  return `${p || '.'}: HTML ${JSON.stringify(a)?.slice(0, 200)} · C++ ${JSON.stringify(b)?.slice(0, 200)}`;
}
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, locale: 'tr-TR' })).newPage(); if (DIL.length) await p.addInitScript(() => localStorage.setItem('anrufen_lang', 'en'));
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  const boot = async save => {   // sayfayı aç (kayıtla ya da kayıtsız), giriş ekranını bekle
    await p.goto(URL); await p.evaluate(s => { localStorage.clear(); if (s) localStorage.setItem('anrufen_save_v1', s); }, save);
    await p.goto(URL); await p.waitForFunction(() => !document.querySelector('#title').classList.contains('hidden'), null, { timeout: 30000 }); await p.waitForTimeout(900);
  };
  // zar, saat; oyun döngüsü durur (C++'ta kayıttan başladıktan sonra zaman akmaz)
  const seed = () => p.evaluate(([M, NOW]) => { Math.random = eval(M)(7); window.__now = NOW; Date.now = () => window.__now; window.update = () => {}; }, [MULBERRY, NOW]);
  const playing = () => p.waitForFunction(() => window.__G && __G.player && __G.map && !__G.transit && UI.mode === 'play', null, { timeout: 30000 });
  const hsave = () => p.evaluate(() => { save(); return JSON.parse(localStorage.getItem('anrufen_save_v1')); });
  const hstate = () => p.evaluate(() => { const P = Game.P, s = stats(), L = look(), srt = o => Object.fromEntries(Object.keys(o).filter(k => o[k] != null && o[k] !== '').sort().map(k => [k, o[k]]));
    return { altin: P.gold, canta: P.bag.map(x => [x.id, x.n]), eq: srt(P.eq), sk: srt(P.sk), sp: P.sp, can: Game.player.hp, mana: Game.player.mp,
      st: [s.hp, s.mp, s.atk, s.def, s.crit, s.dodge, s.res, s.hpreg, s.mpreg], gorunum: [L.bodyG || '', L.headG || '', L.weapG || ''], kisayol: P.quick.map(q => q || '') }; });
  // checks: [ad, tür, HTML değeri]; src: C++ değerinin yeri ({f: dosya} ya da {l: çıktı satırı, f: okunduysa yazılan dosya})
  const scen = ['veri www/assets', ...DIL, `saatms ${NOW}`], checks = [], src = []; let lineN = 0;
  const file = n => path.join(OUT, n);
  const cppFile = (c, f) => { checks.push(c); src.push({ f }); }, cppLine = (c, f) => { checks.push(c); src.push({ l: lineN++, f }); };
  // ---------- A: yeni karakter (arayüzden) ----------
  const titleTxt = [];
  for (const [name, cls, race, sex, face] of CHARS) {
    await boot(null);
    titleTxt.push(await p.evaluate(() => document.querySelector('#tword').textContent));
    await p.keyboard.press('Enter'); await p.waitForTimeout(300);
    await p.click(`[data-cls="${cls}"]`); await p.click(`[data-race="${race}"]`); await p.click(`[data-sex="${sex}"]`); await p.click(`[data-face="${face}"]`);
    await p.fill('#cname', name); await seed(); await p.click('#cstart'); await playing();
    const f = file(`a_${name}.json`);
    cppFile([`A ${name}`, 'kayit', await hsave()], f); cppLine([`A ${name}`, 'durum', await hstate()]);
    scen.push('yenidunya', 'tohum 7', `yenikarakter ${name} ${cls} ${race} ${sex} ${face}`, 'baslat', `kayityaz ${f}`, 'karakterdurum -');
  }
  // ---------- B: zengin HTML kaydı → C++ ----------
  await boot(null); await p.keyboard.press('Enter'); await p.waitForTimeout(300);
  await p.click('[data-cls="战士"]'); await p.click('[data-race="精灵"]'); await p.click('[data-sex="male"]'); await p.click('[data-face="2"]');
  await p.fill('#cname', 'Kurt'); await seed(); await p.click('#cstart'); await playing();
  await p.evaluate(() => {
    gmLevel(45); ClassGM.up(); gmGear(); const P = Game.P;
    const slot = Object.keys(P.eq).find(k => P.eq[k] && k !== 'weap'); if (slot) unequip(slot);   // çıkarılmış yuva HTML'de null kalır
    P.sk = {}; P.sp = 0; skillAutoSpend(P.lv + 1, 0);
    buyItem('hp2', 3); addItem('30022', 4, true);
    const Q = QUESTS.filter(q => !q.auto && questState(q) === 'new').slice(0, 3); for (const q of Q) acceptQuest(q);
    if (Q[0]) { P.quests[Q[0].id].n = 2; P.quests[Q[0].id].c = { x: 1 }; } if (Q[1]) P.quests[Q[1].id].c = {};
    if (Q[2]) completeQuest(Q[2]);
    Pet.GM.give('狼'); Pet.setMode('free'); Pet.GM.give('小鸡'); const L = Pet.list(); L[1].dead = true; L[1].deadAt = Date.now() - 1000; L[1].gift = { hp: 5, patk: 2 }; Game.P.petSel = L[1].uid;
    P.dg = { day: '2026-11-19', n: { myk: 2, slf: 1 } }; P.home = ['120005', 33, 20]; P.life = { '采矿': 2 };
    P.quick[3] = null; P.quick[5] = 'i:hp2'; P.id = 1234; P.zz = { a: [1, 'b', null], t: true };
    Dungeon.GM.enter('myk', 0);
  });
  await p.waitForFunction(() => Game.sceneId !== '120205' && !Game.transit && Game.P.dun, null, { timeout: 30000 }); await p.waitForTimeout(300);
  await p.evaluate(() => { Dungeon.GM.clear(); });
  const hB = await hsave(); fs.writeFileSync(file('b_html.json'), JSON.stringify(hB));
  lineN++; cppFile(['B okuyup yaz', 'kayit', hB], file('b_cpp.json'));   // kayitoku satırı
  scen.push('yenidunya', `kayitoku ${file('b_html.json')}`, `kayityaz ${file('b_cpp.json')}`);
  // B2: iki sürüm de kayıttan başlar
  await boot(JSON.stringify(hB)); titleTxt.push(await p.evaluate(() => document.querySelector('#tword').textContent + ' · ' + document.querySelector('#tinfo').textContent));
  await seed(); await p.keyboard.press('Enter'); await playing();
  cppFile(['B Devam Et', 'kayit', await hsave()], file('b2_cpp.json')); cppLine(['B Devam Et', 'durum', await hstate()]);
  scen.push('tohum 7', 'baslat', `kayityaz ${file('b2_cpp.json')}`, 'karakterdurum -');
  // ---------- C: C++ kaydı → HTML ----------
  const cScen = ['veri www/assets', ...DIL, `saatms ${NOW}`, 'tohum 3', 'yenikarakter Zeynep 牧师 精灵 fema 5', 'baslat', 'seviye 22', 'gmgear', 'esya al hp2 2', 'esya ekle 30022 3',
    'evcilver 小鸡', 'evcilmod support', 'gorevver 1', 'beceriler -', 'dagit 23 0', `kayityaz ${file('c_cpp.json')}`];
  fs.writeFileSync(file('c_senaryo.txt'), cScen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [file('c_senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  const cJson = fs.readFileSync(file('c_cpp.json'), 'utf8');
  await boot(cJson); titleTxt.push(await p.evaluate(() => document.querySelector('#tword').textContent + ' · ' + document.querySelector('#tinfo').textContent));
  await seed(); await p.keyboard.press('Enter'); await playing();
  lineN++; cppFile(['C Devam Et', 'kayit', await hsave()], file('c2_cpp.json')); cppLine(['C Devam Et', 'durum', await hstate()]);
  scen.push('yenidunya', 'tohum 7', `kayitoku ${file('c_cpp.json')}`, 'baslat', `kayityaz ${file('c2_cpp.json')}`, 'karakterdurum -');
  // ---------- D: eski ve bozuk kayıtlar (fixSave) ----------
  const ids = await p.evaluate(() => ({ w: CLS['战士'].skills.map(s => s.id), m: CLS['法师'].skills.map(s => s.id) }));
  const base = { v: 1, name: 'Eski', cls: '战士', race: '人类', sex: 'male', lv: 30, xp: 5, gold: 100, hp: 500, mp: 100, bag: [{ id: 'hp1', n: 2 }], quests: {}, done: { 1: true },
    scene: '120005', x: 33.5, y: 20.25, face: '1002' }, sp0 = { sp: 0 };
  const D = [
    ['ekipmansız eski kayıt', Object.assign({}, base, { gear: { weap: 1, body: 1, head: 1 } })],
    ['eski kısayol', Object.assign({}, base, sp0, { sv: 1, quick: ['s3', null], eq: { weap: '10003' }, sk: { [ids.w[0]]: 1 } })],
    ['kademesi aşan + kilitli', Object.assign({}, base, { sv: 2, quick: ['s0'], eq: {}, sk: { [ids.w[0]]: 15, [ids.w[3]]: 4, [ids.w[12]]: 3 }, sp: 2 })],
    ['büyücü, sınıf yükseltmeli', Object.assign({}, base, { cls: '法师', race: '精灵', lv: 50, adv: 1, sv: 2, quick: [], eq: {}, sk: { [ids.m[0]]: 3, [ids.m[12]]: 2, [ids.m[30]]: 2 }, sp: 0 })],
    ['v 2', Object.assign({}, base, { v: 2 })],
    ['bilinmeyen sınıf', Object.assign({}, base, { cls: 'xx' })],
  ];
  for (const [n, s] of D) {
    const f = file('d_' + n.replace(/\W+/g, '_') + '.json'); fs.writeFileSync(f, JSON.stringify(s));
    cppLine([`D ${n}`, 'oku', await p.evaluate(x => { const r = fixSave(JSON.parse(x)); return r ? JSON.parse(JSON.stringify(r)) : null; }, JSON.stringify(s))], f + '.cpp');
    scen.push('yenidunya', `kayitoku ${f}`, `kayityaz ${f}.cpp`);
  }
  await b.close(); if (srv) srv.kill();
  // ---------- C++ ----------
  fs.writeFileSync(file('senaryo.txt'), scen.join('\n') + '\n');
  const lines = execFileSync('native/build/anrufen_test', [file('senaryo.txt')], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).split('\n').filter(l => l.startsWith('{')).map(l => JSON.parse(l));
  const cpp = src.map((x, i) => {
    if (x.l == null) return JSON.parse(fs.readFileSync(x.f, 'utf8'));
    const L = lines[x.l];
    if (checks[i][1] === 'oku') return L.kayit ? JSON.parse(fs.readFileSync(x.f, 'utf8')) : null;
    delete L.ileti; delete L.bildirim; delete L.ses; return L;   // durum: iletiler HTML'de arayüzün içinde; sesler öteki testlerde (karşılaştırılmaz)
  });
  let bad = 0;
  checks.forEach(([n, kind, h], i) => {
    const d = diff(h, cpp[i]);
    const info = kind === 'durum' ? `can ${Math.round(h.can)} · saldırı ${h.st[2]} · ekipman ${Object.keys(h.eq).length} · beceri ${Object.keys(h.sk).length}`
      : h ? `${h.name} ${h.cls} Sv ${h.lv} · ${h.scene} (${(+h.x).toFixed(1)},${(+h.y).toFixed(1)}) · çanta ${h.bag.length} · görev ${Object.keys(h.quests).length}/${Object.keys(h.done).length} · hayvan ${(h.pets || []).length}${h.dun ? ' · zindan ' + h.dun.id : ''}` : 'kayıt yok';
    console.log(`${(n + ' ' + kind).padEnd(38)} ${d ? 'FARKLI ' + d : 'aynı · ' + info}`);
    if (d) bad++;
  });
  console.log('giriş ekranı:', titleTxt.join(' | '));
  if (errs.length) { console.log('HATA', errs); bad++; }
  console.log(bad ? `${bad} denetim farklı` : `${checks.length} denetimin hepsi aynı`);
  process.exitCode = bad ? 1 : 0;
})();
