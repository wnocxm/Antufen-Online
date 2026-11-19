// C++ ↔ HTML ses karıştırıcısı (docs/09-cpp.md, 13. adım). HTML'nin kendi audio.js'i tarayıcının çevrimdışı ses bağlamında
// (OfflineAudioContext, 48 kHz) aynı olay dizisiyle çalınır (window.AudioContext yerine; olaylar ctx.suspend(t) anlarında); C++'ta
// "karistir" komutu aynı diziyi engine/Audio ile karıştırır. Karşılaştırma: 20 ms'lik pencerelerde ses gücü (RMS) zarfı.
// Senaryolar: efektler (seviye, aynı efektin 0,06 sn engeli, aynı anda iki efekt, efektler kapalıyken), müzik (açılış rampası, parça
// geçişi, kapat/aç, aynı parça yeniden istenince dokunulmaz), döngü (church 32,016 sn'de başa döner).
// Not: efektler iki tarafta aynı WAV; müzik HTML'de MP3 (orijinal kaydın 22 kHz'e çevrilmişi), C++'ta orijinal 8 kHz WAV: müzikte
// zarf yakın olmalı ama birebir değil (kodlayıcı farkı), efektlerde yeniden örnekleme farkı kadar.
//   node tools/test/cpp_ses.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_ses', RATE = 48000, WIN = 960;
// [ad, süre (sn), olaylar [t, tür, a, b], karşılaştırma aralığı [t0, t1], sınır: ortalama göreli fark, en büyük göreli fark]
const CASES = [
  ['efektler', 3.2, [[0.08, 'efekt', 'coin', 1], [0.08, 'efekt', 'coin', 1], [0.40, 'efekt', 'menusel', 0.6], [0.72, 'efekt', 'kill', 0.7],
    [1.20, 'efekt', 'skill_fireball', 1], [1.20, 'efekt', 'skill_bomb', 0.4], [1.60, 'efektac', 0], [1.68, 'efekt', 'coin', 1], [1.76, 'efektac', 1], [1.84, 'efekt', 'levelup', 1]], [0, 3.2], 0.01, 0.05],
  ['muzik', 6.0, [[0, 'muzik', 'cover.mid'], [1.20, 'muzik', 'grassland.mid'], [2.40, 'muzikac', 0], [3.20, 'muzikac', 1], [4.80, 'muzik', 'grassland.mid']], [0, 6.0], 0.12, 0.35],
  ['dongu', 34.0, [[0, 'muzik', 'church.mid']], [30.0, 34.0], 0.12, 0.35],
];
const rms = (a, from, to) => { const o = []; for (let i = from; i + WIN <= to; i += WIN) { let s = 0; for (let k = i; k < i + WIN; k++) s += a[k] * a[k]; o.push(Math.sqrt(s / WIN)); } return o; };
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const errs = []; let bad = 0; const scen = ['veri www/assets'], html = {};
  for (const [ad, sec, ev] of CASES) {
    const p = await (await b.newContext({ viewport: { width: 640, height: 360 } })).newPage(); p.on('pageerror', e => errs.push(e.message));
    // audio.js'in AudioContext'i: çevrimdışı bağlam (süre sayfaya verilir)
    await p.addInitScript(() => { const O = window.OfflineAudioContext; window.AudioContext = function () { window.__off = new O(2, Math.round(window.__sec * 48000), 48000); return window.__off; }; window.webkitAudioContext = undefined; });
    await p.goto(URL); await p.evaluate(() => localStorage.clear()); await p.goto(URL); await p.waitForFunction(() => window.SFX && !document.querySelector('#title').classList.contains('hidden'), null, { timeout: 30000 });   // açılış bitsin (giriş ekranı kapak müziğini ister)
    html[ad] = await p.evaluate(async ([sec, ev]) => {
      // giriş ekranının istediği müzik (cover) init'te kendiliğinden başlamasın
      window.__sec = sec; SFX.Music.pending = null; SFX.init(); const ctx = window.__off, wait = ms => new Promise(r => setTimeout(r, ms));
      const apply = async e => { if (e[1] === 'efekt') SFX.play(e[2], e[3]); else if (e[1] === 'muzik') await SFX.Music.play(e[2]); else if (e[1] === 'muzikac') SFX.setMusic(!!e[2]); else if (e[1] === 'efektac') SFX.setSfx(!!e[2]); await wait(150); };
      const groups = new Map(); for (const e of ev) { if (!groups.has(e[0])) groups.set(e[0], []); groups.get(e[0]).push(e); }
      for (const e of groups.get(0) || []) await apply(e);
      for (const [t, L] of groups) if (t > 0) ctx.suspend(t).then(async () => { for (const e of L) await apply(e); ctx.resume(); });
      const buf = await ctx.startRendering(); return Array.from(buf.getChannelData(0));
    }, [sec, ev]);
    await p.context().close();
    scen.push(`karistir ${path.join(OUT, ad + '.wav')} ${sec} ${RATE} ${ev.map(e => e.join(':')).join(';')}`);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  for (const [ad, sec, , [t0, t1], limMean, limMax] of CASES) {
    const w = fs.readFileSync(path.join(OUT, ad + '.wav')); const n = (w.length - 44) / 8, c = new Float32Array(n);
    for (let i = 0; i < n; i++) c[i] = w.readFloatLE(44 + i * 8);
    const h = html[ad], from = Math.round(t0 * RATE), to = Math.min(h.length, n, Math.round(t1 * RATE));
    const H = rms(h, from, to), C = rms(c, from, to);
    let sum = 0, cnt = 0, worst = 0, wi = -1;
    for (let i = 0; i < H.length; i++) { const m = Math.max(H[i], C[i]); if (m < 0.004) continue; const d = Math.abs(H[i] - C[i]) / m; sum += d; cnt++; if (d > worst) { worst = d; wi = i; } }
    const mean = cnt ? sum / cnt : 0, silentBoth = H.filter((x, i) => (x < 0.004) !== (C[i] < 0.004)).length;
    const ok = mean <= limMean && worst <= limMax && silentBoth <= 2;
    console.log(`${ad.padEnd(9)} ${ok ? 'GEÇTİ' : 'KALDI'} · ${H.length} pencere (${cnt} sesli) · ortalama göreli fark %${(mean * 100).toFixed(1)} (sınır %${limMean * 100}) · en büyük %${(worst * 100).toFixed(1)} (${(t0 + wi * WIN / RATE).toFixed(2)} sn; sınır %${limMax * 100}) · yalnız birinde sessiz: ${silentBoth}`);
    if (!ok) bad++;
    fs.writeFileSync(path.join(OUT, ad + '_zarf.json'), JSON.stringify({ html: H, cpp: C }));
  }
  if (errs.length) { console.log('HATA', errs); bad++; }
  console.log(bad ? `${bad} senaryo kaldı` : 'hepsi geçti');
  process.exitCode = bad ? 1 : 0;
})();
