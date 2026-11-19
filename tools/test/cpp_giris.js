// C++ ↔ HTML giriş ekranı ve karakter oluşturma (docs/09-cpp.md, 12. adım). HTML'de bu iki ekran sayfa öğeleri (DOM); C++ tuvale çizer.
// Giriş ekranı: kitabın açılışı (kapalı, yarı açık, açık, ilk sayfa), oklarla sayfa çevirme (çevirme karesi + sonraki sözcük), kayıtlıyken
// Devam Et (bilgi satırı) ve "Eski karakter silinecek" onayı, geniş ekran (780). HTML'deki zamanlayıcılar (setTimeout 170-700 ms) tutulur
// ve sırayla elle çalıştırılır; C++'ta "giris bekle". Karakter oluşturma: varsayılan, elf kadın büyücü (yüz 3), insan kadın rahip (yüz 8,
// Türkçe harfli ad), geniş ekran; önizleme animasyonu zamanı 0 (HTML performance.now = 0).
// Her durumda: yazısız piksel karşılaştırması (sınır SINIR, varsayılan %1) + yazılı yan yana (<ad>_yazili_fark.png); ayrıca sözcük, bilgi,
// kitap karesi ve oluşturma seçimleri iki sürümde aynı mı.
//   node tools/test/cpp_giris.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_giris';
const HIDE = `#title *, #create *, #title .ver { color: transparent !important; text-shadow: none !important; caret-color: transparent !important; }`;
const SAVE = { v: 1, name: 'Kurt', cls: '战士', race: '人类', sex: 'male', lv: 45, xp: 0, gold: 30, hp: 1e9, mp: 1e9, gear: { weap: 0, body: 0, head: 0 }, eq: {}, bag: [], quests: {}, done: {}, qitems: {},
  scene: '120207', x: 3, y: 13, quick: ['s0', 's1', 's2', 's3', 's4', 's5', 'i:hp1', 'i:mp1'], sv: 2, sk: {}, sp: 0, flags: {}, face: '1002', adv: 1 };
// [ad, genişlik, kayıt, adımlar]; adım: [HTML kodu, C++ komutları]
// HTML zamanlayıcıları açılıştan (350, 520, 700 ms) ya da çevirmeden (170 ms) sayar; C++'ta aradaki süre kadar beklenir
const T = (ms) => [`__run(${ms})`, [`giris bekle ${{ 350: 0.35, 520: 0.17, 700: 0.18, 170: 0.17 }[ms]}`]];
const KEY = k => [`dispatchEvent(new KeyboardEvent('keydown', { key: '${k}' }))`, [`giris tus ${k}`]];
const TITLE = [
  ['kapali', 640, 0, []], ['yari', 640, 0, [T(350)]], ['acik', 640, 0, [T(350), T(520)]], ['yeni', 640, 0, [T(350), T(520), T(700)]],
  ['cevir', 640, 0, [T(350), T(520), T(700), KEY('ArrowRight')]], ['cevrimici', 640, 0, [T(350), T(520), T(700), KEY('ArrowRight'), T(170)]],
  ['dil', 640, 0, [T(350), T(520), T(700), KEY('ArrowRight'), T(170), KEY('ArrowRight'), T(170)]],
  ['devam', 640, 1, [T(350), T(520), T(700)]], ['geri_cevir', 640, 1, [T(350), T(520), T(700), KEY('ArrowLeft')]],
  ['sil_onay', 640, 1, [T(350), T(520), T(700), KEY('ArrowRight'), T(170), KEY('Enter')]],
  ['genis', 780, 1, [T(350), T(520), T(700)]],
];
// oluşturma: [ad, genişlik, tıklamalar (HTML seçici), C++ dokunuşları, ad]
const CREATE = [
  ['olustur', 640, [], [], null],
  ['elf_buyucu', 640, ['[data-cls="法师"]', '[data-race="精灵"]', '[data-sex="fema"]', '[data-face="3"]'], null, null],
  ['rahip_adli', 640, ['[data-cls="牧师"]', '[data-sex="fema"]', '[data-face="8"]'], null, 'Işıl Ağa'],
  ['genis_olustur', 780, ['[data-race="精灵"]', '[data-face="5"]'], null, null],
];
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const errs = [], scen = ['veri www/assets', 'giris surum Sürüm 11190635'], states = [], names = [], sesH = {};
  const page = async (W, save) => {
    const p = await (await b.newContext({ viewport: { width: W, height: 360 }, locale: 'tr-TR' })).newPage(); p.on('pageerror', e => errs.push(e.message));
    // giriş ekranının zamanlayıcıları (150-700 ms) tutulur; __run(ms) o süredeki ilkini çalıştırır
    await p.addInitScript(() => { window.__tq = []; const ST = window.setTimeout; window.setTimeout = (fn, d, ...a) => { if (d >= 150 && d <= 700) { __tq.push([d, fn]); return 0; } return ST(fn, d, ...a); };
      window.__run = ms => { const i = __tq.findIndex(x => x[0] === ms); if (i >= 0) { const [, fn] = __tq.splice(i, 1)[0]; fn(); } };
      // ses kaydı: SFX.play / SFX.Music.play (audio.js window.SFX'i yazınca sarılır) ve audio.js'in kuralı: sayfadaki her düğmeye tıklama "menusel" 0,6
      window.__snd = []; addEventListener('click', e => { if (e.target.closest && e.target.closest('button')) __snd.push(['menusel', 0.6]); }, { capture: true });
      let S0; Object.defineProperty(window, 'SFX', { configurable: true, get() { return S0; }, set(v) { S0 = v; v.play = (n, vol = 1) => { if (n) __snd.push([n, vol]); }; v.Music.play = n => { if (n) __snd.push(['muzik', n]); }; } }); });
    await p.goto(URL); await p.evaluate(s => { localStorage.clear(); if (s) localStorage.setItem('anrufen_save_v1', s); }, save ? JSON.stringify(SAVE) : null);
    await p.goto(URL); await p.waitForFunction(() => !document.querySelector('#title').classList.contains('hidden'), null, { timeout: 30000 }); await p.waitForTimeout(600);
    return p;
  };
  const shoot = async (p, ad, W) => {
    await p.waitForTimeout(150);
    await p.screenshot({ path: path.join(OUT, `${ad}_yazili_html.png`), clip: { x: 0, y: 0, width: W, height: 360 } });
    const st = await p.addStyleTag({ content: HIDE }); await p.waitForTimeout(80);
    await p.screenshot({ path: path.join(OUT, `${ad}_yazisiz_html.png`), clip: { x: 0, y: 0, width: W, height: 360 } });
    await st.evaluate(e => e.remove());
  };
  for (const [ad, W, save, steps] of TITLE) {
    const p = await page(W, save);
    for (const [code] of steps) await p.evaluate(c => eval(c), code);
    await shoot(p, ad, W); names.push(ad);
    states.push(await p.evaluate(() => { const t = document.querySelector('#tbook').style; return { sozcuk: document.querySelector('#tword').textContent, bilgi: document.querySelector('#tinfo').textContent, kare: t.backgroundPosition + ' ' + t.width + ' ' + t.height }; }));
    sesH[ad] = await p.evaluate(() => __snd.splice(0));
    await p.context().close();
    scen.push(`ekran ${W} 360`, `giris ac ${save} Kurt · Savaşçı · Seviye 45`, ...steps.flatMap(s => s[1]), `sesler ${path.join(OUT, ad + '_ses.json')}`, 'giris durum -', 'yazi 0', `giris goruntu ${path.join(OUT, ad + '_yazisiz_cpp.png')}`, 'yazi 1', `giris goruntu ${path.join(OUT, ad + '_yazili_cpp.png')}`);
  }
  const cstates = [];
  for (const [ad, W, clicks, , nm] of CREATE) {
    const p = await page(W, 0);
    await p.evaluate(() => { __run(350); __run(520); __run(700); }); await p.keyboard.press('Enter'); await p.waitForTimeout(300);
    await p.evaluate(() => { performance.now = () => 0; });
    for (const c of clicks) await p.click(c);
    if (nm) await p.fill('#cname', nm);
    await p.mouse.click(600, 20);   // odak ad kutusunda kalmasın
    const boxes = await p.evaluate(sels => sels.map(s => { const r = document.querySelector(s).getBoundingClientRect(); return [r.x + r.width / 2, r.y + r.height / 2]; }), clicks);
    await shoot(p, ad, W); names.push(ad);
    cstates.push(await p.evaluate(() => ({ ad: (document.querySelector('#cname').value.trim() || 'Kahraman').slice(0, 12) })));
    sesH[ad] = await p.evaluate(() => __snd.splice(0));
    await p.context().close();
    scen.push(`ekran ${W} 360`, 'giris ac 0', 'giris bekle 0.35', 'giris bekle 0.17', 'giris bekle 0.18', 'giris tus Enter', 'olustur ac', ...boxes.map(([x, y]) => `olustur dokun ${x} ${y}`));
    if (nm) scen.push('olustur dokun 200 82', 'olustur tus Backspace', ...Array(8).fill('olustur tus Backspace'), `olustur yaz ${nm}`, 'olustur tus Enter');
    scen.push(`sesler ${path.join(OUT, ad + '_ses.json')}`, 'olustur durum -', 'yazi 0', `olustur goruntu ${path.join(OUT, ad + '_yazisiz_cpp.png')} 0`, 'yazi 1', `olustur goruntu ${path.join(OUT, ad + '_yazili_cpp.png')} 0`);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  const lines = execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).split('\n').filter(l => l.startsWith('{')).map(l => JSON.parse(l)).filter(o => !o.eylem);
  let bad = 0;
  // giriş ekranı durumları: sözcük, bilgi, kitap karesi (HTML: arka plan konumu ve boy → C++ kare adı)
  const FR = { closed: '0px 0px 147px 122px', half: '-147px 0px 148px 172px', open: '0px -342px 236px 130px', flipL: '0px -172px 236px 168px', flipR: '-236px -160px 234px 180px',
    p1: '-236px -342px 234px 130px', p2: '0px -472px 236px 135px', p3: '-236px -472px 234px 135px', p4: '0px -607px 236px 138px' };
  TITLE.forEach(([ad], i) => { const h = states[i], c = lines[i], ok = h.sozcuk === c.sozcuk && h.bilgi === c.bilgi && h.kare === FR[c.kare];
    console.log(`${ad.padEnd(14)} ${ok ? 'aynı' : 'FARKLI'} · «${h.sozcuk}» · ${h.bilgi || '-'} · ${c.kare}${ok ? '' : ` | C++ «${c.sozcuk}» ${c.bilgi} ${FR[c.kare]} | HTML kare ${h.kare}`}`); if (!ok) bad++; });
  CREATE.forEach(([ad], i) => { const c = lines[TITLE.length + i], ok = c.ad === cstates[i].ad;
    console.log(`${ad.padEnd(14)} ${ok ? 'aynı' : 'FARKLI'} · ${c.sinif} ${c.irk} ${c.cins} yüz ${c.yuz} · ad «${c.ad}»${ok ? '' : ' (HTML «' + cstates[i].ad + '»)'}`); if (!ok) bad++; });
  const run = (lim, list) => { try { return execFileSync('python3', ['tools/test/goruntu_fark.py', OUT, ...list], { env: Object.assign({}, process.env, { SINIR: lim }) }).toString(); } catch (e) { bad++; return e.stdout.toString(); } };
  process.stdout.write('yazısız (piksel):\n' + run(process.env.SINIR || '1', names.map(n => n + '_yazisiz')));
  process.stdout.write('yazılı (göz denetimi; yan yana: <ad>_yazili_fark.png):\n' + run('100', names.map(n => n + '_yazili')));
  // sesler: müzik (cover), sayfa çevirme, düğme sesleri
  let sb = 0; for (const ad of names) { const c = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_ses.json'), 'utf8')).ses;
    if (JSON.stringify(c) !== JSON.stringify(sesH[ad])) { sb++; console.log(`ses FARKLI ${ad}: HTML ${JSON.stringify(sesH[ad])} · C++ ${JSON.stringify(c)}`); } }
  console.log(sb ? `ses: ${sb} durum farklı` : `ses: ${names.length} durumun hepsi aynı (${Object.values(sesH).reduce((a, x) => a + x.length, 0)} olay)`); bad += sb;
  if (errs.length) { console.log('HATA', errs); bad++; }
  console.log(bad ? `${bad} denetim farklı` : 'hepsi geçti');
  process.exitCode = bad ? 1 : 0;
})();
