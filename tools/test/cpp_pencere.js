// C++ ↔ HTML pencere karşılaştırması (docs/09-cpp.md): konuşma (kişinin sözü ve seçenekleri; bir göreve dokununca görev metni),
// görev listesi (Aktif, Alınabilir; seçili görevin bilgi kartı), ana menü, ölüm penceresi, onay kutusu (görevi bırak); 8. adım: çanta
// (sekmeler, seçili eşyanın bilgisi ve işlemleri), karakter (özellikler, ekipman yuvaları), beceri ağacı (acemi, kilitli sınıf ağacı, ırk),
// dükkân (satır, bilgi kartı), adet kutusu (Satın Al → +1). Pencereler iki
// tarafta aynı ekran noktalarına dokunularak açılır/ilerletilir (dokunma bölgeleri de sınanır). Her durum için iki kare:
//   <ad>_yazisiz (piksel; sınır SINIR, varsayılan %1) ve <ad>_yazili (yan yana göz denetimi; tools/test/cpp_arayuz.js gibi).
//   node tools/test/cpp_pencere.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
// DIL=en: İngilizce kip (HTML localStorage anrufen_lang = en; C++ "dil en")
const DIL = process.env.DIL === 'en' ? ['dil en'] : [];
const OUT = process.env.OUT || '/tmp/cpp_pencere';
const F2 = JSON.parse(fs.readFileSync('www/assets/forms2.json', 'utf8'));
const rect = (f, id) => F2[f].c.find(c => c.id === id).s[0].r;
// form biriminden ekrana (win.js nBegin): x = safeL + fx·k, y = (fy - oy)·k
const at = (f, id, k, oy = 0, dx = 0, dy = 0) => { const r = rect(f, id); return [(r[0] + dx + r[2] / 2) * k, (r[1] + dy + r[3] / 2 - oy) * k]; };
const kN = 360 / 373, kT = 360 / 320;
const kP = 360 / 290, PX = 126 * 360 / 320, PY = Math.round((360 - 259 * kP) / 2), kF = Math.min(360 / 330, 640 / 495);   // evcil penceresi, dönüşüm penceresi
// dünya haritası (win.js mapRect, 640×360): görünüm alanı ve Guanlin'in bölgesi, o bölgede başka bir harita
const WMD = JSON.parse(fs.readFileSync('www/assets/wm/wm.json', 'utf8'));
const MW = 544, MH = 344, MOX = 82, MOY = 8, MVX = MOX + 4, MVY = MOY + 4, MVW = MW - 8, MVH = MH - 4 - 36, MBY = MOY + MH - 36 + 3;
const GA = WMD.areas.find(a => a.scenes.some(s => s.sid === '120005')), GS = GA.scenes.find(s => s.sid !== '120005');
const areaAt = [MVX + GA.cx / 100 * MVW, MVY + GA.cy / 100 * MVH], scAt = [MVX + GS.x / 100 * MVW, MVY + GS.y / 100 * MVH];
// [ad, eylemler]: eylem = ['pencere', ad, varlık?] | ['dokun', x, y]
const CASES = [
  ['konusma', [['pencere', 'npc', 10]]],
  ['konusma_gorev', [['pencere', 'npc', 10], ['dokun', ...at('npc_dialogue', 50289, kN)]]],
  ['konusma_yeni', [['pencere', 'npc', 10], ['dokun', ...at('npc_dialogue', 50290, kN)]]],
  ['gorevler', [['pencere', 'task']]],
  ['gorevler_alinabilir', [['pencere', 'task'], ['dokun', (116 + 50) * kT, (312 + 13 - 42) * kT]]],   // Alınabilir düğmesi
  ['menu', [['pencere', 'hub']]],
  ['olum', [['pencere', 'dead']]],
  ['onay', [['pencere', 'task'], ['dokun', (10 + 50) * kT, (312 + 13 - 42) * kT], ['dokun', ...at('item_info', 50424, kT, 42, 232, 62)]]],   // Aktif'e dön, Bırak
  // 8. adım: çanta, karakter, beceri ağacı, dükkân, adet kutusu
  ['canta', [['pencere', 'bag']]],
  ['canta_tuketim', [['pencere', 'bag'], ['dokun', ...at('bag_2', 50004, kT)], ['dokun', ...at('bag_2', 50007, kT)]]],   // Tüketim, ilk yuva
  ['canta_ekipman', [['pencere', 'bag'], ['dokun', ...at('bag_2', 50003, kT)], ['dokun', ...at('bag_2', 50008, kT)]]],   // Ekipman, ikinci yuva
  ['karakter', [['pencere', 'role']]],
  ['karakter_ekipman', [['pencere', 'role'], ['dokun', ...at('player', 50085, kT)], ['dokun', ...at('player', 50094, kT)]]],   // Ekipman, silah yuvası
  ['beceri', [['pencere', 'skill'], ['dokun', ...at('skilltree', 50402, kT)]]],   // acemi ağacı, ilk beceri
  ['beceri_sinif', [['pencere', 'skill'], ['dokun', ...at('skilltree', 50397, kT)], ['dokun', ...at('skilltree', 50403, kT)]]],   // sınıf ağacı (kilitli)
  ['beceri_irk', [['pencere', 'skill'], ['dokun', ...at('skilltree', 50400, kT)], ['dokun', ...at('skilltree', 50402, kT)]]],   // ırk ağacı
  ['dukkan', [['pencere', 'shop', '武器商人（人类）'], ['dokun', (rect('shop', 50334)[0] + 104) * kT, (49 + 53 + 26 - 41) * kT]]],   // silahçı, ikinci satır
  // 9. adım: dünya haritası (kıta, bölge + seçili harita, bulunduğun harita), ayarlar
  ['harita', [['pencere', 'map']]],
  ['harita_bolge', [['pencere', 'map'], ['dokun', ...areaAt], ['dokun', ...scAt]]],
  ['harita_yerel', [['pencere', 'map'], ['dokun', MOX + 8 + 35, MBY + 15]]],
  ['ayarlar', [['pencere', 'sys']]],
  // 11. adım: evcil hayvan (Bilgi, Beceriler, Ağaç, Taktik), dönüşüm / beceri aktarma
  ['evcil', [['pencere', 'pet']]],
  ['evcil_beceri', [['pencere', 'pet'], ['dokun', PX + (14 + 66 + 31) * kP, PY + 140 * kP]]],
  ['evcil_agac', [['pencere', 'pet'], ['dokun', PX + (14 + 132 + 31) * kP, PY + 140 * kP]]],
  ['evcil_taktik', [['pencere', 'pet'], ['dokun', ...at('petcomplex', 50757, kP, 0, PX / kP, PY / kP)]]],
  ['donusum', [['pencere', 'petf']]],
  ['donusum_aktarma', [['pencere', 'petf'], ['dokun', 58 + 404 * kF, 5 + 35 * kF]]],
  // 15. adım: GM karakterde ana menü 8 düğme (GM en altta), liste kayar; yarı kaydırılmışken iki ok
  ['menu_gm', [['ad', 'GMKahraman'], ['pencere', 'hub']]],
  ['menu_gm_kaydir', [['ad', 'GMKahraman'], ['pencere', 'hub'], ['surukle', -30, 40, 150]]],
  ['adet', [['pencere', 'shop', '道具商人（人类）'], ['dokun', (rect('shop', 50334)[0] + 104) * kT, (49 + 26 - 41) * kT], ['dokun', ...at('shopinfo', 50369, kT, 41, Math.min(358, 640 / kT - 229), 70)], ['dokun', ...at('selnum', 50255, 1.3, 0, 172 / 1.3, 96 / 1.3)]]],
];
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, deviceScaleFactor: 1, locale: 'tr-TR' })).newPage(); if (DIL.length) await p.addInitScript(() => localStorage.setItem('anrufen_lang', 'en'));
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kahraman'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; window.__snd = []; SFX.play = (n, v = 1) => { if (n) __snd.push([n, v]); }; SFX.Music.play = n => { if (n) __snd.push(['muzik', n]); }; for (const k of ['log', 'toast', 'zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {};
    const C = CanvasRenderingContext2D.prototype; window.__ft = [C.fillText, C.strokeText]; });
  await p.waitForTimeout(10500);   // açılış ipuçları sönsün
  // durum: Sv 8 insan savaşçı, Guanlin'e varmış (80004 bitti), Domuz Avı (80439) alınmış
  // eşyalar: Gelişim Paketi açılmış (acemi ekipmanı kuşanılmış), iksirler, bir silah, başka sınıfın silahı; acemi becerisi 2. kademe
  const kit = await p.evaluate(() => { const shop = Object.values(SHOPS).flatMap(t => t.flatMap(x => x[1]));
    return { weap: Object.keys(ITEMS).filter(id => ITEMS[id].slot === 'weap' && ITEMS[id].cls === '战士' && ITEMS[id].lv > 1).sort((a, b) => ITEMS[a].lv - ITEMS[b].lv)[0], other: shop.find(id => ITEMS[id].slot === 'weap' && ITEMS[id].cls === '法师'),
      sk0: CLS['战士'].skills.find(k => k.id === TREES['战士'][0].cells[0][0]).sn }; });
  await p.evaluate(([M, kit]) => { const P = Game.P; Object.assign(P, { cls: '战士', race: '人类', sex: 'male', face: '1001', name: 'Kahraman', eq: {}, bag: [], gold: 0, xp: 0, lv: 1, sk: {}, sp: 0, adv: 0, quests: {}, done: {}, quick: QUICK0.slice() }); gmLevel(8);
    ClassGM.done(80004); P.quests[80439] = { n: 0, ready: false };
    addItem('growthBox', 1, true); useItem('growthBox'); addItem('30016', 12, true); addItem('30019', 4, true); addItem(kit.weap, 1, true); addItem(kit.other, 1, true); P.gold = 1234;
    skillUp(SKBYSN[kit.sk0]); skillUp(SKBYSN[kit.sk0]); Math.random = eval(M)(7); Date.now = () => 1800000000000; Pet.GM.give('狼'); }, [`(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`, kit]);
  await p.evaluate(() => gotoScene('120005', null, [10, 25], null));
  await p.waitForFunction(() => Game.sceneId === '120005' && Game.player && !Game.transit, null, { timeout: 30000 });
  await p.evaluate(() => { const pl = Game.player, s = stats(); pl.doll.set(look()); pl.hp = s.hp; pl.mp = s.mp; Game.time = 0; pl.t = 0; pl.state = 'idle'; pl.combatT = 0; for (const e of Game.ents) e.t = 0; window.__upd(0); setTarget(null); });
  await p.waitForTimeout(1500);
  const scen = ['veri www/assets', ...DIL, 'golge 1', 'ekran 640 360', 'arayuz 1', 'tohum 7', 'karakter 战士 人类 male', 'ad Kahraman', 'portre 1001', 'seviye 8',
    `gmbitir 80004 ${path.join(OUT, 'gm.json')}`, 'gorevver 80439', 'esya ekle growthBox 1', 'esya kullan growthBox', 'esya ekle 30016 12', 'esya ekle 30019 4', `esya ekle ${kit.weap} 1`, `esya ekle ${kit.other} 1`,
    'altin 1234', `beceriyukselt ${kit.sk0}`, `beceriyukselt ${kit.sk0}`, 'sahne 120207 3 13', 'tohum 7', 'saatms 1800000000000', 'evcilver 狼', 'sahne 120005 10 25', 'saat0', 'doldur', 'temizle'];
  const sesH = {};   // her durumun ses olayları (dokunuşlar, pencere açılışları)
  for (const [ad, acts] of CASES) {
    await p.evaluate(() => { __snd = []; }); scen.push('sestemizle');
    for (const a of acts) {
      // pencere açılınca bir kare çizilir (dokunma bölgeleri çizimde kurulur; gerçek oyunda dokunuştan önce hep kare vardır)
      if (a[0] === 'pencere' && a[1] === 'shop') { a[2] = await p.evaluate(cn => { Win.close(); Win.open('shop', { shop: cn }); return Game.ents.findIndex(e => e.cn === cn); }, a[2]); if (a[2] < 0) throw new Error('dükkân yok'); await p.waitForTimeout(150); }
      else if (a[0] === 'pencere') { await p.evaluate(([n, e]) => { Win.close(); Win.open(n, n === 'npc' ? { npc: Game.ents[e] } : {}); }, [a[1], a[2]]); await p.waitForTimeout(150); }
      else if (a[0] === 'ad') { await p.evaluate(n => { Game.P.name = n; }, a[1]); scen.push(`ad ${a[1]}`); continue; }
      else if (a[0] === 'surukle') { await p.evaluate(([dy, x, y]) => Win.drag(dy, x, y), [a[1], a[2], a[3]]); await p.waitForTimeout(150); scen.push(`surukle ${a[1]} ${a[2]} ${a[3]}`, 'ciz'); continue; }
      else { await p.evaluate(([x, y]) => Win.tap(x, y), [a[1], a[2]]); await p.waitForTimeout(150); }
      scen.push(a[0] === 'pencere' ? `pencere ${a[1]}${a[2] != null ? ' ' + a[2] : ''}` : `dokun ${a[1]} ${a[2]}`, 'ciz');
    }
    sesH[ad] = await p.evaluate(() => __snd.splice(0)); scen.push(`sesler ${path.join(OUT, ad + '_ses.json')}`);
    await p.waitForTimeout(1200);   // görseller yüklensin, basılı vurgusu sönsün
    for (const yazi of [0, 1]) {
      await p.evaluate(on => { const C = CanvasRenderingContext2D.prototype; if (on) [C.fillText, C.strokeText] = window.__ft; else C.fillText = C.strokeText = () => {}; }, yazi);
      await p.waitForTimeout(300);
      await p.screenshot({ path: path.join(OUT, `${ad}_${yazi ? 'yazili' : 'yazisiz'}_html.png`), clip: { x: 0, y: 0, width: 640, height: 360 } });
    }
    scen.push('yazi 0', `goruntu ${path.join(OUT, ad + '_yazisiz_cpp.png')}`, 'yazi 1', `goruntu ${path.join(OUT, ad + '_yazili_cpp.png')}`);
    await p.evaluate(() => { Win.close(); Game.P.name = 'Kahraman'; }); scen.push('pencere kapat', 'ad Kahraman');
  }
  const txMiss = await p.evaluate(() => [...TX_MISS]);
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'], env: Object.assign({}, process.env, { ANRUFEN_TARAYICI_ALFA: '1' }) });
  const run = (lim, list) => { try { return execFileSync('python3', ['tools/test/goruntu_fark.py', OUT, ...list], { env: Object.assign({}, process.env, { SINIR: lim }) }).toString(); } catch (e) { process.exitCode = 1; return e.stdout.toString(); } };
  process.stdout.write('yazısız (piksel):\n' + run(process.env.SINIR || '1', CASES.map(c => c[0] + '_yazisiz')));
  process.stdout.write('yazılı (göz denetimi; yan yana: <ad>_yazili_fark.png):\n' + run('100', CASES.map(c => c[0] + '_yazili')));
  // İngilizce kipte: çevirisi bulunamayan metinler (C++'ta olup HTML'de olmayan = C++'ta unutulmuş çeviri)
  if (DIL.length) { const c = JSON.parse(execFileSync('native/build/anrufen_test', ['-'], { input: 'veri www/assets\ndil en\n' + fs.readFileSync(path.join(OUT, 'senaryo.txt'), 'utf8').split('\n').slice(2).join('\n') + '\ndileksik -\n', encoding: 'utf8' }).split('\n').filter(l => l.startsWith('{"eksik"'))[0]).eksik;
    const fark = c.filter(x => !txMiss.includes(x)); console.log(`çeviri: C++'ta eksik ${c.length}, HTML'de eksik ${txMiss.length}; yalnız C++'ta ${fark.length}` + (fark.length ? ':\n  ' + fark.join('\n  ') : '')); if (fark.length) process.exitCode = 1; }
  // sesler: her durumda dokunuşların ve pencere açılışlarının ses olayları aynı mı
  let sb = 0; for (const [ad] of CASES) { const c = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_ses.json'), 'utf8')).ses;
    if (JSON.stringify(c) !== JSON.stringify(sesH[ad])) { sb++; console.log(`ses FARKLI ${ad}: HTML ${JSON.stringify(sesH[ad])} · C++ ${JSON.stringify(c)}`); } }
  console.log(sb ? `ses: ${sb} durum farklı` : `ses: ${CASES.length} durumun hepsi aynı (${Object.values(sesH).reduce((a, x) => a + x.length, 0)} olay)`); if (sb) process.exitCode = 1;
  if (errs.length) { console.log('HATA', errs); process.exitCode = 1; }
})();
