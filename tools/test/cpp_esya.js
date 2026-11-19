// C++ ↔ HTML eşya ve beceri işlemleri karşılaştırması (docs/09-cpp.md, 8. adım):
//   üç karakter (insan savaşçı, elf büyücü, insan rahip) aynı işlem dizisini yapar: Gelişim Paketi, satın alma (altın yetmeyince de),
//   kuşanma (başka sınıfın ve yüksek seviyenin eşyası reddedilir), çıkarma, satma, iksir (can doluyken de), GM ekipmanı, beceri yükseltme
//   (kilitli olan reddedilir), puan sıfırlama (Eğitim Kitabı'sız ve ile), kısayola yerleştirme. Her işlemden sonra altın, çanta, ekipman,
//   beceriler, değerler, görünüm, kısayollar, son ileti ve bildirim karşılaştırılır. Ayrıca her becerinin kilit iletisi, her kademedeki
//   açıklaması ve sonraki kademe farkı (beceri penceresinin yazıları) satır satır.
//   node tools/test/cpp_esya.js   (OUT=klasör; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
// DIL=en: İngilizce kip (HTML localStorage anrufen_lang = en; C++ "dil en")
const DIL = process.env.DIL === 'en' ? ['dil en'] : [];
const OUT = process.env.OUT || '/tmp/cpp_esya';
const CHARS = [['savasci', '战士', '人类', 'male'], ['buyucu', '法师', '精灵', 'fema'], ['rahip', '牧师', '人类', 'male']];
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 640, height: 360 }, locale: 'tr-TR' })).newPage(); if (DIL.length) await p.addInitScript(() => localStorage.setItem('anrufen_lang', 'en'));
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kahraman'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(() => {
    window.__upd = window.update; window.update = () => {}; window.__snd = []; SFX.play = (n, v = 1) => { if (n) __snd.push([n, v]); }; SFX.Music.play = n => { if (n) __snd.push(['muzik', n]); }; for (const k of ['zone', 'levelUp', 'float', 'hurt']) UI[k] = () => {};
    window.__t = { log: '', toast: '' }; UI.log = m => { __t.log = m; }; UI.toast = m => { __t.toast = m; };
    // C++ karakterdurum ile aynı biçim
    window.__dump = () => { const P = Game.P, s = stats(), L = look(), srt = o => Object.fromEntries(Object.keys(o).filter(k => o[k] != null && o[k] !== '').sort().map(k => [k, o[k]]));
      return { altin: P.gold, canta: P.bag.map(x => [x.id, x.n]), eq: srt(P.eq), sk: srt(P.sk), sp: P.sp, can: Game.player.hp, mana: Game.player.mp,
        st: [s.hp, s.mp, s.atk, s.def, s.crit, s.dodge, s.res, s.hpreg, s.mpreg], gorunum: [L.bodyG || '', L.headG || '', L.weapG || ''], kisayol: P.quick.map(q => q || ''), ileti: __t.log, bildirim: __t.toast, ses: __snd.splice(0) }; };
    window.__do = c => { const [op, a, n] = c.split(' '), P = Game.P;
      if (op === 'esya') { const [, o, id, k] = c.split(' '), m = k ? +k : 1;
        if (o === 'al') buyItem(id, m); else if (o === 'sat') sellItem(id, m); else if (o === 'giy') equip(id); else if (o === 'cikar') unequip(id);
        else if (o === 'kullan') useItem(id); else if (o === 'ekle') addItem(id, m, true); else if (o === 'sil') removeItem(id, m); }
      else if (op === 'gmgear') gmGear(); else if (op === 'altin') P.gold = +a;
      else if (op === 'beceriyukselt') skillUp(SKBYSN[a]); else if (op === 'becerisifirla') skillReset(!!+a);
      else if (op === 'kisayol') { P.quick = P.quick.map(q => q === a ? null : q); P.quick[+n] = a; }
      else if (op === 'can') Game.player.hp = stats().hp * +a;
      else throw new Error('bilinmeyen ' + c); };
    // beceri penceresinin yazıları (C++ beceriyazilari ile aynı satırlar)
    window.__skillTexts = () => { const P = Game.P, L = CLS[P.cls].skills.concat(RACE_SK[P.race] || []); let o = '';
      for (const sk of L) { const mx = sk.mx || 10; o += `${sk.id}\t${sk.name}\t${skLockMsg(sk)}\n`; for (let r = 1; r <= mx; r++) o += `  ${r}\t${skDesc(sk, r)}\t${r < mx ? Win.__nextDiff(sk, r) : ''}\n`; }
      return o; };
    // win.js skNextDiff modülün içinde: aynısı (seçili dilin şablonu)
    Win.__nextDiff = (sk, r) => { const keys = [...(sk.d[LANG === 'en' ? 'en' : 'tr'][1].matchAll(/\{(\w+)\}/g))].map(m => m[1]).filter(k => sk.d.c[k]), out = [];
      const fmt = v => Number.isInteger(v) ? String(v) : String(+v.toFixed(1));
      for (const k of [...new Set(keys)]) { const a = skC(sk, k, r), b = skC(sk, k, r + 1); if (a !== b) out.push(`${fmt(a)}→${fmt(b)}`); } return out.join(', '); };
  });
  let bad = 0;
  for (const [ad, cls, race, sex] of CHARS) {
    const pick = await p.evaluate(([cls, race, sex]) => {
      const P = Game.P; Object.assign(P, { cls, race, sex, lv: 1, xp: 0, gold: 0, bag: [], eq: {}, sk: {}, sp: 0, adv: 0, quests: {}, done: {}, quick: QUICK0.slice() }); delete P.home;
      Game.flags = {}; Game.player.buffs = []; gmLevel(12); refreshLook(); __t.log = ''; __t.toast = '';
      const all = Object.keys(ITEMS), shop = Object.values(SHOPS).flatMap(t => t.flatMap(x => x[1]));
      const weap = shop.filter(id => ITEMS[id].slot === 'weap' && ITEMS[id].cls === cls && ITEMS[id].lv <= 12 && ITEMS[id].lv > 1).sort((a, b) => ITEMS[b].lv - ITEMS[a].lv)[0];
      const other = all.find(id => ITEMS[id].slot === 'weap' && ITEMS[id].cls && ITEMS[id].cls !== cls);
      const high = all.find(id => ITEMS[id].slot && ITEMS[id].cls === cls && ITEMS[id].lv > 30);
      const T = TREES[cls], C = CLS[cls], sk0 = C.skills.find(k => k.id === T[0].cells[0][0]).sn, sk1 = C.skills.find(k => k.id === T[0].cells[1][0]).sn, lock = C.skills.find(k => k.id === T[1].cells[0][0]).sn;
      return { weap, other, high, sk0, sk1, lock };
    }, [cls, race, sex]);
    const ops = ['esya ekle growthBox 1', 'esya kullan growthBox', 'altin 5000', 'esya al 30016 5', `esya al ${pick.weap} 1`, `esya giy ${pick.weap}`,
      `esya ekle ${pick.other} 1`, `esya giy ${pick.other}`, `esya ekle ${pick.high} 1`, `esya giy ${pick.high}`, 'esya cikar weap', 'esya cikar head', 'esya cikar ring',
      'esya sat 30016 2', `esya sat ${pick.weap} 1`, `esya sat ${pick.other} 1`, 'esya kullan hp1', 'can 0.5', 'esya kullan hp1', 'esya kullan mp1',
      `beceriyukselt ${pick.sk0}`, `beceriyukselt ${pick.sk0}`, `beceriyukselt ${pick.sk1}`, `beceriyukselt ${pick.lock}`, 'becerisifirla 0', 'esya ekle 30092 1', 'becerisifirla 0',
      'gmgear', 'altin 10', 'esya al 30016 1', 'kisayol i:hp1 3', 'kisayol s0 5', 'esya sil hp1 3'];
    const html = [await p.evaluate(() => { __snd = []; return __dump(); })];
    for (const c of ops) { await p.evaluate(c => { __do(c); }, c); html.push(await p.evaluate(() => __dump())); }
    const htmlTxt = await p.evaluate(() => __skillTexts());
    const scen = ['veri www/assets', ...DIL, `karakter ${cls} ${race} ${sex}`, 'seviye 12', 'temizle', 'sestemizle', 'karakterdurum -'];
    for (const c of ops) scen.push(c, 'karakterdurum -');
    const txtF = path.join(OUT, ad + '_beceri_cpp.txt'); scen.push(`beceriyazilari ${txtF}`);
    fs.writeFileSync(path.join(OUT, ad + '_senaryo.txt'), scen.join('\n') + '\n');
    const cpp = execFileSync('native/build/anrufen_test', [path.join(OUT, ad + '_senaryo.txt')], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] }).split('\n').filter(l => l.startsWith('{')).map(l => JSON.parse(l));
    let diff = '';
    const eq = (a, b) => JSON.stringify(a) === JSON.stringify(b);
    for (let i = 0; i < html.length && !diff; i++) {
      const h = html[i], c = cpp[i]; if (!c) { diff = `${i}. adım: C++ çıktısı yok`; break; }
      for (const k of Object.keys(h)) if (!eq(h[k], c[k])) { diff = `${i ? ops[i - 1] : 'başlangıç'} → ${k}: HTML ${JSON.stringify(h[k])} · C++ ${JSON.stringify(c[k])}`; break; }
    }
    const last = html[html.length - 1];
    console.log(`${ad.padEnd(8)} ${ops.length} işlem: ${diff ? 'FARKLI ' + diff : 'aynı'} (son: altın ${last.altin}, ekipman ${Object.keys(last.eq).length}, beceri puanı ${last.sp}, saldırı ${last.st[2]})`);
    if (diff) bad++;
    fs.writeFileSync(path.join(OUT, ad + '_beceri_html.txt'), htmlTxt);
    const H = htmlTxt.split('\n'), C = fs.readFileSync(txtF, 'utf8').split('\n'), di = H.findIndex((l, i) => l !== C[i]);
    console.log(`${ad.padEnd(8)} beceri yazıları: ${H.length - 1} satır, ${di < 0 && H.length === C.length ? 'aynı' : `FARKLI ${di + 1}. satır\n  HTML: ${H[di]}\n  C++:  ${C[di]}`}`);
    if (di >= 0 || H.length !== C.length) bad++;
  }
  await b.close(); if (srv) srv.kill();
  if (errs.length) { console.log('HATA', errs); bad++; }
  process.exitCode = bad ? 1 : 0;
})();
