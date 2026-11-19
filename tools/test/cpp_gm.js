// C++ ↔ HTML GM paneli karşılaştırması (docs/09-cpp.md › GM paneli). Karakter "GMTest" (adı GM ile başlayan: GM yetkisi).
// (1) Yerleşim: HTML'de panelin her kutusu (getBoundingClientRect: panel, başlık, durum, ✕, araç düğmeleri, arama kutusu, liste, satırlar,
//     satır başlığı/açıklaması/düğmeleri, harita düğmeleri, not) ile C++'ın hesapladığı kutular (gm kutular) 1/64 px'e kadar; ayrıca panel
//     siyah zeminde yazısız piksel karşılaştırması (sınır %1) ve yazılı yan yana. Sekme simgeleri renkli emoji: HTML'ye testte Android'deki
//     gibi "Noto Color Emoji" yazı tipi listesine eklenir (bu makinede 🗺 başka bir yazı tipinden siyah-beyaz gelirdi).
// (2) İşlevler: araç düğmeleri (seviye, seviye seç, altın, puan, ölümsüzlük, hızlı koşu, can, ekipman), harita düğmesi, yolculuk ağı,
//     zindan, evcil, sınıf düğmeleri sırayla iki sürümde de basılır; her adımdan sonra durum (harita, seviye, altın, puan, yükseltme,
//     bayraklar, zindan, hayvanlar, görevler, kukla, pencere, bildirim) karşılaştırılır.
//   node tools/test/cpp_gm.js   (OUT=klasör; DIL=en İngilizce; GENIS=780 ikinci ekran genişliği; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const DIL = process.env.DIL === 'en' ? ['dil en'] : [];
const OUT = process.env.OUT || '/tmp/cpp_gm';
const EMOJI = '#gm { font-family: Alegreya, "Noto Color Emoji", "Noto Sans", "Microsoft YaHei", serif; }';
const NOTEXT = '#gm, #gm * { color: transparent !important; caret-color: transparent !important; } #gq::placeholder { color: transparent !important; }';
// yerleşim durumları: [ad, genişlik, eylemler]; eylem: ['g', data-g] | ['ara', metin] | ['kaydir', px] | ['js', HTML kodu, C++ satırları]
const LAYOUT = [
  ['haritalar', 640, []],
  ['haritalar_kaydir', 640, [['kaydir', 900]]],
  ['haritalar_ara', 640, [['ara', 'kamp']]],
  ['haritalar_ara_buyuk', 640, [['ara', 'İNSAN']]],
  ['haritalar_numara', 640, [['ara', '1201']]],
  ['zindanlar', 640, [['g', 'v:dg']]],
  ['zindanlar_kaydir', 640, [['g', 'v:dg'], ['kaydir', 400]]],
  ['evcil', 640, [['g', 'v:pet']]],
  ['evcil_hayvanli', 640, [['g', 'v:pet'], ['js', "__seed(11); Pet.GM.give('熊猫'); Pet.summon(Pet.list()[0].uid)", ['tohum 11', 'evcilver 熊猫', 'evcilcagir 0']]]],
  ['sinif', 640, [['g', 'v:cls']]],
  ['sinif_ara', 640, [['g', 'v:cls'], ['ara', 'şövalye']]],
  ['bayraklar', 640, [['g', 'god'], ['g', 'fast'], ['g', 'v:maps']]],
  ['genis', +(process.env.GENIS || 780), [['g', 'v:cls']]],
];
// işlev adımları: [ad, eylemler, bekle(ms; HTML) / C++ bekleme sn]; eylem: ['b', kimlik] (g:…, x:…, s:…) | ['js', HTML, C++ satırları] | ['lvset', n]
const STEPS = [
  ['seviye +1', [['b', 'g:lv1']]],
  ['seviye +10', [['b', 'g:lv10']]],
  ['seviye seç 25', [['lvset', 25]]],
  ['altın', [['b', 'g:gold']]],
  ['puan', [['b', 'g:sp']]],
  ['ölümsüz + hızlı', [['b', 'g:god'], ['b', 'g:fast']]],
  ['can doldur', [['js', 'Game.player.hp = 5; Game.player.mp = 3', ['can 0.001', 'mana 0.001']], ['b', 'g:heal']]],
  ['ekipman', [['b', 'g:gear']]],
  ['Guanlin\'e ışınlan', [['b', 'g:v:maps'], ['b', 's:120005']], 1500],
  ['ücretsiz yolculuk', [['ac'], ['b', 'x:tv:free']]],
  ['yolculuk NPC\'sine yürü', [['b', 'x:tv:near']]],
  ['Bozbalta\'ya git', [['ac'], ['b', 'x:tv:axe']], 1500],
  ['zindana gir', [['ac'], ['b', 'g:v:dg'], ['b', 'x:dg:in:swy:0']], 1500],
  ['son kat', [['ac'], ['b', 'x:dg:last']], 1500],
  ['boss\'u öldür', [['ac'], ['b', 'x:dg:boss']], 300],
  ['canavarları öldür', [['b', 'x:dg:clear']], 300],
  ['zindandan çık', [['b', 'x:dg:leave']], 1500],
  ['günlük haklar', [['ac'], ['b', 'x:dg:reset']]],
  ['kapıya git (elf)', [['b', 'x:dg:door:myk:1']], 1500],
  ['hayvan ver', [['ac'], ['b', 'g:v:pet'], ['b', 'x:pet:give:熊猫']]],
  ['seviyeme çek', [['b', 'x:pet:level']]],
  ['eşya + acıktır + bakım', [['b', 'x:pet:items'], ['b', 'x:pet:hungry'], ['b', 'x:pet:care']]],
  ['sonraki biçim ×2', [['b', 'x:pet:stage'], ['b', 'x:pet:stage']]],
  ['temel biçim', [['b', 'x:pet:stage0']]],
  ['dönüşüm malzemesi', [['b', 'x:pet:tf']]],
  ['yumurta', [['b', 'x:pet:egg:狼']]],
  ['evcil penceresi', [['b', 'x:pet:win']], 300],
  ['dönüşüm penceresi', [['ac'], ['b', 'g:v:pet'], ['b', 'x:pet:petf']], 300],
  ['hepsini sil', [['ac'], ['b', 'g:v:pet'], ['b', 'x:pet:clear']]],
  ['acemiye döndür + 40', [['b', 'g:v:cls'], ['b', 'x:cls:reset'], ['b', 'x:cls:start']]],
  ['zinciri bitir', [['zincir']]],
  ['acemiye döndür', [['b', 'x:cls:reset']]],
  ['ağaçları doldur (2.)', [['b', 'x:cls:fill:1']]],
  ['puanları sıfırla', [['b', 'x:cls:resetPts']]],
  ['doldur (1.) + kukla', [['b', 'x:cls:fill:0'], ['b', 'x:cls:dummy'], ['b', 'x:cls:dummy']]],
  ['beklemesiz', [['b', 'x:cls:nocd']]],
  ['sınıf yükselt', [['b', 'x:cls:reset'], ['b', 'x:cls:up']]],
  ['ikinci yükseltme', [['b', 'x:cls:up2']]],
  ['80 + Bozbalta', [['b', 'x:cls:start80']], 1500],
  ['kapat', [['ac'], ['b', 'close']]],
  ['ana menüden GM', [['hub']]],   // ana menü: listeyi kaydır, 8. düğme (GM) → panel açılır
];
const M = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const ctx = await b.newContext({ viewport: { width: 640, height: 360 }, deviceScaleFactor: 1, locale: 'tr-TR' }); const p = await ctx.newPage();
  if (DIL.length) await p.addInitScript(() => localStorage.setItem('anrufen_lang', 'en'));
  // kısa bildirimler ui.js'in iç toast() işlevinden geçer: testte yüklenirken kayıt satırı eklenir (window.__toast)
  await p.route(/\/js\/ui\.js/, async r => { const res = await r.fetch(); const body = (await res.text()).replace('function toast(m) { toastMsg = tx(m); toastT = 2.5; }', 'function toast(m) { toastMsg = tx(m); toastT = 2.5; window.__toast = toastMsg; }');
    if (!body.includes('window.__toast = toastMsg')) throw new Error('ui.js toast() bulunamadı'); r.fulfill({ response: res, body }); });
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMTest'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(([M, css]) => { window.__upd = window.update; window.update = () => {}; window.__seed = s => { Math.random = eval(M)(s); }; __seed(7); Date.now = () => 1800000000000;
    window.__toast = '';
    const st = document.createElement('style'); st.textContent = css; document.head.appendChild(st); document.getElementById('game').style.visibility = 'hidden'; }, [M, EMOJI]);
  const base = ['veri www/assets', ...DIL, 'tohum 7', 'saatms 1800000000000', 'yenikarakter GMTest 战士 人类 male 1', 'baslat', 'temizle'];

  // ---------------- (1) yerleşim ----------------
  const rectsH = () => p.evaluate(() => {
    const R = e => { const q = e.getBoundingClientRect(); return [q.x, q.y, q.width, q.height]; }, $ = s => document.querySelector(s);
    const o = [['panel', '', ...R($('.gbox'))], ['head', '', ...R($('.ghead'))], ['title', $('#gtitle').textContent, ...R($('#gtitle'))], ['state', $('#gstate').textContent, ...R($('#gstate'))], ['close', '✕', ...R($('#gclose'))]];
    for (const bt of document.querySelectorAll('#gtools button')) o.push(['tool', bt.textContent, ...R(bt)]);
    o.push(['input', $('#gq').value || $('#gq').placeholder, ...R($('#gq'))], ['list', '', ...R($('#glist'))]);
    for (const e of $('#glist').children) {
      if (e.classList.contains('grow')) { o.push(['row', e.querySelector('b').textContent, ...R(e)], ['b', e.querySelector('b').textContent, ...R(e.querySelector('b'))], ['small', e.querySelector('small').textContent, ...R(e.querySelector('small'))]);
        for (const bt of e.querySelectorAll('button')) o.push(['btn', bt.textContent, ...R(bt)]); }
      else if (e.dataset.s) o.push(['scene', e.querySelector('b').textContent, ...R(e)]);
      else o.push(['hint', e.textContent, ...R(e)]);
    }
    return { kutular: o, kaydirma: $('#glist').scrollTop };
  });
  const scen = [...base];
  const lay = {};
  for (const [ad, W, acts] of LAYOUT) {
    await p.setViewportSize({ width: W, height: 360 }); scen.push(`ekran ${W} 360`);
    await p.evaluate(() => { UI.closeAll(); Game.god = false; Game.fast = false; UI.open('gm'); document.querySelector('[data-g="v:maps"]').click(); document.querySelectorAll('#gtools .gv').forEach(x => x.classList.remove('on')); });
    scen.push('gm bayraklar0', 'gm ac', 'gm bas g:v:maps', 'gm sekmesiz');
    for (const a of acts) {
      if (a[0] === 'g') { await p.evaluate(g => document.querySelector(`[data-g="${g}"]`).click(), a[1]); scen.push(`gm bas g:${a[1]}`); }
      else if (a[0] === 'ara') { await p.evaluate(t => { const q = document.querySelector('#gq'); q.value = t; q.dispatchEvent(new Event('input')); }, a[1]); scen.push(`gm ara ${a[1]}`); }
      else if (a[0] === 'kaydir') { await p.evaluate(y => { document.querySelector('#glist').scrollTop = y; }, a[1]); }
      else if (a[0] === 'js') { await p.evaluate(c => { eval(c); }, a[1]); scen.push(...a[2]); await p.evaluate(() => document.querySelector('#gq').dispatchEvent(new Event('input'))); }
    }
    await p.waitForTimeout(250);
    const H = await rectsH(); lay[ad] = H; fs.writeFileSync(path.join(OUT, ad + '_kutular_html.json'), JSON.stringify(H));
    scen.push(`gm kaydir ${H.kaydirma}`, `gm kutular ${path.join(OUT, ad + '_kutular.json')}`);
    for (const yazi of [0, 1]) {
      await p.evaluate(([on, css]) => { let s = document.getElementById('__nt'); if (!s) { s = document.createElement('style'); s.id = '__nt'; document.head.appendChild(s); } s.textContent = on ? '' : css; }, [yazi, NOTEXT]);
      await p.waitForTimeout(150);
      await p.screenshot({ path: path.join(OUT, `${ad}_${yazi ? 'yazili' : 'yazisiz'}_html.png`), clip: { x: 0, y: 0, width: W, height: 360 } });
      scen.push(`yazi ${yazi}`, `gm goruntu ${path.join(OUT, `${ad}_${yazi ? 'yazili' : 'yazisiz'}_cpp.png`)}`);
    }
    if (acts.some(a => a[0] === 'js')) { await p.evaluate(() => Pet.GM.clear()); scen.push('evcilgm sil'); }
  }
  await p.evaluate(() => { UI.closeAll(); Game.god = false; Game.fast = false; }); await p.setViewportSize({ width: 640, height: 360 }); scen.push('gm kapat', 'gm bayraklar0', 'ekran 640 360');
  // ---------------- (2) işlevler ----------------
  const stH = () => p.evaluate(() => { const P = Game.P, pc = Pet.list(); return {
    acik: !document.getElementById('gm').classList.contains('hidden'), sahne: Game.sceneId, sv: P.lv, altin: P.gold, puan: P.sp || 0, harcanan: Object.values(P.sk || {}).reduce((a, x) => a + x, 0), ust: P.adv || 0,
    olumsuz: !!Game.god, hizli: !!Game.fast, beklemesiz: !!Game.gmNoCd, ucretsiz: !!Game.gmFreeTravel, zindan: (P.dun && P.dun.id) || '', hayvan: pc.map(q => `${Pet.nm(q)} Sv${q.lv} st${q.st || 0}`),
    gorev: Object.keys(P.quests).map(Number), bitti: Object.keys(P.done).length, kukla: Game.ents.filter(e => e.gmDummy).length, hedefKukla: !!(Game.target && Game.target.gmDummy),
    pencere: Win.cur || '', bildirim: window.__toast, ekipman: Object.values(P.eq || {}).filter(Boolean).length, x: Math.round(Game.player.x * 100) / 100, y: Math.round(Game.player.y * 100) / 100 }; });
  const stepsH = [];
  scen.push('tohum 13', 'gm ac', 'gm bas g:v:maps');   // zarlar iki tarafta aynı noktadan (sahne yüklemeleri, ganimet)
  await p.evaluate(() => { __seed(13); UI.open('gm'); document.querySelector('[data-g="v:maps"]').click(); });
  for (const [ad, acts, wait] of STEPS) {
    await p.evaluate(() => { window.__toast = ''; }); scen.push('gm toastsil');
    for (const a of acts) {
      if (a[0] === 'ac') { await p.evaluate(() => UI.open('gm')); scen.push('gm ac'); }
      else if (a[0] === 'b') {
        await p.evaluate(id => { const [k, v] = [id.slice(0, 2), id.slice(2)]; const sel = id === 'close' ? '#gclose' : k === 'g:' ? `[data-g="${v}"]` : k === 'x:' ? `[data-x="${v}"]` : `[data-s="${v}"]`; const e = document.querySelector(sel); if (!e) throw new Error('düğme yok ' + id); e.click(); }, a[1]);
        scen.push(`gm bas ${a[1]}`);
      } else if (a[0] === 'lvset') {
        p.once('dialog', d => d.accept(String(a[1]))); await p.evaluate(() => document.querySelector('[data-g="lvset"]').click());
        scen.push('gm bas g:lvset', `gm yaz ${a[1]}`, 'gm bas n:ok');
      } else if (a[0] === 'js') { await p.evaluate(c => { eval(c); }, a[1]); scen.push(...a[2]); }
      else if (a[0] === 'hub') {   // v5_menu 50229 (7. düğme) [10, 273, 108, 31]; kaydırınca 8. düğme (GM) onun yerine gelir; ölçek 360/320
        const k = 360 / 320, x = (10 + 54) * k, y = (273 + 15.5) * k;
        await p.evaluate(() => { UI.closeAll(); Win.open('hub'); }); await p.waitForTimeout(200);
        await p.evaluate(() => Win.drag(-100, 40, 150)); await p.waitForTimeout(150);
        await p.evaluate(([x, y]) => Win.tap(x, y), [x, y]);
        scen.push('gm kapat', 'pencere hub', 'ciz', 'surukle -100 40 150', 'ciz', `dokun ${x} ${y}`);
      }
      else if (a[0] === 'zincir') {   // zincirin sınıf yükselten (★) ilk görevini bitir
        const id = await p.evaluate(() => ClassGM.chain().filter(q => q.adv).map(q => q.id)[0]);
        await p.evaluate(id => document.querySelector(`[data-x="cls:done:${id}"]`).click(), id); scen.push(`gm bas x:cls:done:${id}`);
      }
      await p.waitForTimeout(60);
    }
    await p.waitForTimeout(wait || 300);
    await p.waitForFunction(() => !Game.transit, null, { timeout: 30000 });
    stepsH.push([ad, await stH()]);
    scen.push(`gm bekle ${((wait || 300) + 60 * acts.length) / 1000}`, `gm durum ${path.join(OUT, 'adim_' + stepsH.length + '.json')}`);   // HTML'de döngü durduruldu: yalnız zamanlayıcılar
  }
  // ana menü: GM düğmesi 8. sırada, liste kayar; GM'e dokununca panel açılır
  const hubH = await p.evaluate(() => { UI.closeAll(); Win.open('hub'); return 1; });
  const txMiss = await p.evaluate(() => [...TX_MISS]);
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  // yerleşim karşılaştırması
  let lb = 0;
  for (const [ad] of LAYOUT) {
    const H = lay[ad].kutular, C = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_kutular.json'), 'utf8')).kutular.map(k => [k[0], k[2], k[3], k[4], k[5], k[6]]);
    const n = Math.max(H.length, C.length); let worst = 0, bad = null, txt = 0;
    for (let i = 0; i < n; i++) {
      const h = H[i], c = C[i]; if (!h || !c || h[0] !== c[0]) { bad = bad || `${i}. kutu: HTML ${JSON.stringify(h)} · C++ ${JSON.stringify(c)}`; continue; }
      if (h[1] !== c[1] && h[0] !== 'input') txt++;
      for (let k = 2; k < 6; k++) { const d = Math.abs(h[k] - c[k]); if (d > worst) { worst = d; if (d > 0.02) bad = bad || `${i}. ${h[0]} "${h[1]}": HTML ${h.slice(2).map(v => v.toFixed(3))} · C++ ${c.slice(2).map(v => v.toFixed(3))}`; } }
    }
    const ok = !bad && !txt && H.length === C.length;
    if (!ok) lb++;
    console.log(`${ad.padEnd(22)} ${H.length} kutu · en büyük fark ${worst.toFixed(4)} px${txt ? ` · yazısı farklı ${txt}` : ''} · ${ok ? 'AYNI' : 'FARKLI'}${bad ? '\n    ' + bad : ''}`);
    if (txt) for (let i = 0; i < Math.min(H.length, C.length); i++) if (H[i][1] !== C[i][1] && H[i][0] !== 'input') { console.log(`    yazı: HTML "${H[i][1]}" · C++ "${C[i][1]}"`); if (--txt <= -3) break; }
  }
  if (lb) process.exitCode = 1;
  const run = (lim, list) => { try { return execFileSync('python3', ['tools/test/goruntu_fark.py', OUT, ...list], { env: Object.assign({}, process.env, { SINIR: lim }) }).toString(); } catch (e) { process.exitCode = 1; return e.stdout.toString(); } };
  process.stdout.write('yazısız (piksel):\n' + run(process.env.SINIR || '1', LAYOUT.map(c => c[0] + '_yazisiz')));
  process.stdout.write('yazılı (göz denetimi; yan yana: <ad>_yazili_fark.png):\n' + run('100', LAYOUT.map(c => c[0] + '_yazili')));
  // işlev karşılaştırması
  let sb = 0;
  stepsH.forEach(([ad, h], i) => {
    const c = JSON.parse(fs.readFileSync(path.join(OUT, 'adim_' + (i + 1) + '.json'), 'utf8'));
    const keys = Object.keys(h).filter(k => k !== 'x' && k !== 'y' || ad.includes('Bozbalta')); const diff = keys.filter(k => JSON.stringify(h[k]) !== JSON.stringify(c[k]));
    if (diff.length) sb++;
    console.log(`${String(i + 1).padStart(2)} ${ad.padEnd(26)} ${diff.length ? 'FARKLI ' + diff.map(k => `${k}: HTML ${JSON.stringify(h[k])} · C++ ${JSON.stringify(c[k])}`).join(' | ') : `aynı (Sv ${h.sv}, ${h.sahne}${h.zindan ? ', zindan ' + h.zindan : ''}${h.hayvan.length ? ', ' + h.hayvan.length + ' hayvan' : ''}${h.pencere ? ', pencere ' + h.pencere : ''}${h.bildirim ? ' · "' + h.bildirim + '"' : ''})`}`);
  });
  console.log(sb ? `işlevler: ${sb} adım farklı` : `işlevler: ${STEPS.length} adımın hepsi aynı`); if (sb) process.exitCode = 1;
  if (DIL.length) { const c = JSON.parse(execFileSync('native/build/anrufen_test', ['-'], { input: fs.readFileSync(path.join(OUT, 'senaryo.txt'), 'utf8') + 'dileksik -\n', encoding: 'utf8' }).split('\n').filter(l => l.startsWith('{"eksik"'))[0]).eksik;
    const fark = c.filter(x => !txMiss.includes(x)); console.log(`çeviri: C++'ta eksik ${c.length}, HTML'de eksik ${txMiss.length}; yalnız C++'ta ${fark.length}` + (fark.length ? ':\n  ' + fark.join('\n  ') : '')); if (fark.length) process.exitCode = 1; }
  if (errs.length) { console.log('HATA', errs); process.exitCode = 1; }
  void hubH;
})();
