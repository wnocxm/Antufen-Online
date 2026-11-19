// C++ ↔ HTML görev karşılaştırması (docs/09-cpp.md). Üç bölüm:
//   1) bütün görevlerin açılma seviyesi (HTML questMinLv, liste sırasıyla hesaplanır),
//   2) görev botu: yeni karakter başlangıç kampından başlar; her adımda bulunduğu haritadaki herkesle konuşur (konuşma görevleri,
//      teslim, yeni görev; ışınlanma görevinde gider), sonra karar verir: teslim edilecek görev → alan kişinin haritası; sürmekte olan
//      görev → özel görevin bayrağı / teslim eşyası ("dükkândan almış gibi") / hedef canavarın haritasında savaş (en çok 90 sn) /
//      toplama noktası; yeni görev → verenin haritası; hiçbiri yoksa seviye kasma (açılmayı bekleyen en düşük görevin canavarları, 60 sn).
//      Haritalar arası geçiş ışınlanmayla (yol bulma ayrı); savaşta uzaktaki hedefin yanına konur; karakter ölümsüz (GM; ekipman eşya
//      adımında). Zar iki sürümde aynı tohumlu üreteçten. Her adımdan sonra karşılaştırılan: eylem, harita, seviye, deneyim, altın,
//      sınıf yükseltmesi, çanta, görev sayaçları, bitmiş görevler, yer; sonda bütün kişilerin baş işaretleri (! ?).
//   3) sınıf yükseltme zincirleri (40 ve 80; altı sınıf × ırk): 40. seviyede kendiliğinden görev, sonra zincirin her görevi GM ile
//      bitirilir (HTML ClassGM.done); her görevden sonra seviye, deneyim, altın, yükseltme, çanta, görevler karşılaştırılır.
//   node tools/test/cpp_gorev.js   (OUT=klasör, ADIM=adım sayısı; URL verilmezse www/ geçici sunucuyla açılır; önce: cmake --build native/build)
const { chromium } = require('playwright');
const { execFileSync, spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/cpp_gorev', STEPS = +(process.env.ADIM || 80), DT = 1 / 30;
// [ad, sınıf, ırk, cinsiyet, tohum]; başlangıç: insan 120207, gece elfi 120205 (3, 13) — newSave gibi
const BOTS = [
  ['insan_savasci', '战士', '人类', 'male', 3],
  ['elf_buyucu', '法师', '精灵', 'fema', 4],
  ['insan_rahip', '牧师', '人类', 'fema', 5],
  ['elf_savasci', '战士', '精灵', 'male', 6],
];
const MULBERRY = `(a => () => { a |= 0; a = a + 0x6D2B79F5 | 0; let t = Math.imul(a ^ a >>> 15, 1 | a); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; })`;
// sayfaya konan bot (C++ headless.cpp questBot ile aynı kurallar)
const BOT = `window.__bot = (() => {
  const S = () => Assets.D.scenes, P = () => Game.P;
  const dun = sid => { const k = S()[sid].kind; return !!(k && k[0] === 4); };
  const pickSc = (L0, scName) => { let L = (L0 || []).filter(s => !dun(s)); if (scName) { const F = L.filter(s => S()[s].name === scName); if (F.length) L = F; } return L.includes(Game.sceneId) ? Game.sceneId : (L[0] || ''); };
  let tries = {};
  function talk() {
    for (let pass = 0; pass < 10; pass++) {
      let ch = false;
      for (const e of Game.ents) {
        if (e.kind !== 'npc' || e.dummy || e.node || e.hidden || e.pickup) continue;
        const cn = e.cn; interact(e);
        for (const q of questsFor(cn)) {
          const st = questState(q);
          if (st === 'ready' && q.to === cn) { const was = !!P().done[q.id]; completeQuest(q); if (!was && P().done[q.id]) ch = true; }
          else if (st === 'new' && q.giver === cn) { ch = true; acceptQuest(q); if (q.tp) { questTeleport(q); UI.closeAll(); return true; } if (q.type === 'talk' && q.to === cn) P().quests[q.id].ready = true; }
        }
      }
      if (!ch) break;
    }
    UI.closeAll(); return false;
  }
  function decide() {
    sceneIndex(); const cur = Game.sceneId; let r = null;
    const go = (s, nm) => { const e = S()[s].ents.find(e => e[1] === nm); return { kind: 'git', gs: s, xy: e ? e[2].slice(0, 2) : null }; };
    for (const q of QUESTS) { if (!P().quests[q.id] || questState(q) !== 'ready') continue; const s = pickSc(NPC_SC[q.to], ''); if (s && s !== cur) return go(s, q.to); }
    for (const q of QUESTS) {
      const st = P().quests[q.id]; if (!st || st.ready || (tries[q.id] || 0) >= 5) continue;
      if (q.type === 'special' && q.flag) return { kind: 'bayrak', gid: q.id, gn: q.flag };
      if (q.type === 'deliver' && q.give && q.give.length && giveCount(q) < q.count) return { kind: 'esya', gid: q.id, gn: q.give[0] };
      if (q.type === 'kill' || q.type === 'collect') {
        const names = q.targets ? q.targets.filter(x => typeof x[2] !== 'string').map(x => x[0]) : q.mobs ? q.mobs.slice() : [q.target];
        if (!names.length || !names[0]) continue;
        const s = pickSc(MON_SC[names[0]], q.sc); if (!s) continue;
        const ql = sceneQLv(s); if (ql != null && ql > P().lv + 2) continue;
        return s !== cur ? go(s, names[0]) : { kind: 'savas', gid: q.id, names };
      }
      if (q.type === 'talk' || (q.type === 'pickup' && q.use)) { const nm = q.type === 'talk' ? q.to : q.node, s = pickSc(NPC_SC[nm], ''); if (s && s !== cur) return go(s, nm); continue; }
      if (q.type === 'pickup') { const s = pickSc(NPC_SC[q.node], ''); if (!s) continue; return s !== cur ? go(s, q.node) : { kind: 'topla', gid: q.id, gn: q.node }; }
    }
    for (const q of QUESTS) if (questState(q) === 'new') { const s = pickSc(NPC_SC[q.giver], ''); if (s && s !== cur) return go(s, q.giver); }
    let bq = null, bl = Infinity;
    for (const q of QUESTS) { if ((q.type !== 'kill' && q.type !== 'collect') || !q.target || questState(q) !== 'soon') continue; const l = questMinLv(q); if (l < bl) { bl = l; bq = q; } }
    if (bq) { const s = pickSc(MON_SC[bq.target], bq.sc); if (s) return s !== cur ? go(s, bq.target) : { kind: 'kas', names: [] }; }
    return { kind: 'yok' };
  }
  function fight(kind, names, gid, DT) {
    const p = Game.player;
    const revive = () => { if (p.dead) { p.dead = false; p.state = 'idle'; p.deadT = 0; } const s = stats(); p.hp = s.hp; p.mp = s.mp; };
    if (kind === 'savas') tries[gid] = (tries[gid] || 0) + 1;
    revive();
    const ok = nm => !names.length || names.includes(nm), n = Math.round((kind === 'kas' ? 60 : 90) / DT);
    for (let k = 0; k < n; k++) {
      if (kind === 'savas') { const st = P().quests[gid]; if (!st || st.ready) break; }
      const t = Game.target;
      if (!t || t.dead || t.kind !== 'mob' || !ok(t.name)) {
        let best = null, bd = 1e300;
        for (const e of Game.ents) { if (e.kind !== 'mob' || e.dead || !ok(e.name)) continue; const d = Math.hypot(e.x - p.x, e.y - p.y); if (d < bd) { bd = d; best = e; } }
        if (best) { setTarget(best, true); if (bd > 3) { p.x = best.x; p.y = best.y; } }
      }
      window.__upd(DT);
      if (p.dead) revive();
    }
  }
  function act(d, DT) {
    if (d.kind === 'esya') { tries[d.gid] = (tries[d.gid] || 0) + 1; const q = QBY[d.gid]; addItem(d.gn, q.count - giveCount(q), true); return ' ' + d.gn; }
    if (d.kind === 'bayrak') { tries[d.gid] = (tries[d.gid] || 0) + 1; questFlag(d.gn); return ' ' + d.gn; }
    if (d.kind === 'savas' || d.kind === 'kas') { fight(d.kind, d.names, d.gid, DT); return d.kind === 'savas' ? ' ' + d.gid : ''; }
    if (d.kind === 'topla') {
      tries[d.gid] = (tries[d.gid] || 0) + 1;
      for (const e of Game.ents) { const st = P().quests[d.gid]; if (!st || st.ready) break; if (e.kind === 'npc' && e.cn === d.gn && !e.hidden && e.pickup) interact(e); }
      const st = P().quests[d.gid]; if (st && !st.ready) for (let k = 0; k < Math.round(21 / DT); k++) window.__upd(DT);
      return ' ' + d.gid;
    }
    return '';
  }
  function rec(step, a) {
    const Pp = P(), p = Game.player;
    const qs = Object.keys(Pp.quests).map(Number).sort((a, b) => a - b).map(id => { const st = Pp.quests[id]; let s = id + ':' + (st.n || 0) + (st.ready ? 'r' : ''); for (const k of Object.keys(st.c || {}).sort()) if (st.c[k]) s += '/' + k + '=' + st.c[k]; return s; }).join(',');
    const dn = Object.keys(Pp.done).filter(k => Pp.done[k] && /^\\d+$/.test(k)).map(Number).sort((a, b) => a - b).join(',');
    return { adim: step, eylem: a, sahne: Game.sceneId, lv: Pp.lv, xp: Pp.xp, altin: Pp.gold, ust: Pp.adv || 0, canta: Pp.bag.map(b => b.id + ':' + b.n).join(','), gorev: qs, bitti: dn, x: p.x, y: p.y, ses: __snd.splice(0) };
  }
  function marks() { sceneIndex(); let m = ''; for (const cn of Object.keys(NPC_SC).sort()) { const k = npcMark(cn); if (k) m += cn + k + ','; } return m; }
  return { talk, decide, act, rec, marks, reset() { tries = {}; } };
})();`;
(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  let srv = null, URL = process.env.URL;
  if (!URL) { srv = spawn('python3', ['-m', 'http.server', '8097', '--directory', 'www'], { stdio: 'ignore' }); URL = 'http://localhost:8097/'; await new Promise(r => setTimeout(r, 800)); }
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(2500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMGorev'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 }); await p.waitForTimeout(800);
  await p.evaluate(() => { window.__upd = window.update; window.update = () => {}; window.__snd = []; SFX.play = (n, v = 1) => { if (n) __snd.push([n, v]); }; SFX.Music.play = n => { if (n) __snd.push(['muzik', n]); }; });
  await p.evaluate(BOT);
  const waitScene = () => p.waitForFunction(() => !Game.transit && Game.player, null, { timeout: 30000 });
  // 1) açılma seviyeleri
  const lvHtml = await p.evaluate(() => { for (const q of QUESTS) delete q._lv; QNEXT = null; HUBLV = null; return QUESTS.map(q => q.id + ':' + questMinLv(q)).join('\n') + '\n'; });
  const scen = ['veri www/assets', `gorevseviye ${path.join(OUT, 'seviye.txt')}`], html = {};
  // 2) botlar
  for (const [ad, cls, race, sex, seed] of BOTS) {
    const start = race === '精灵' ? '120205' : '120207';
    await p.evaluate(([cls, race, sex, seed, M]) => {
      const P = Game.P; Object.assign(P, { cls, race, sex, lv: 1, xp: 0, gold: 0, bag: [], eq: {}, sk: {}, sp: 0, adv: 0, quests: {}, done: {}, hp: 1e9, mp: 1e9 }); delete P.home;
      Game.flags = {}; Game.god = true; Game.target = null; window.__bot.reset(); Math.random = eval(M)(seed);
    }, [cls, race, sex, seed, MULBERRY]);
    await p.evaluate(s => gotoScene(s, null, [3, 13], null), start); await waitScene();
    await p.evaluate(() => { Game.time = 0; const s = stats(), pl = Game.player; pl.hp = s.hp; pl.mp = s.mp; pl.doll.set(look()); __snd = []; });
    const tr = [];
    for (let step = 0; step < STEPS; step++) {
      let a = 'konus';
      const tp = await p.evaluate(() => window.__bot.talk());
      if (tp) await waitScene();
      else {
        const d = await p.evaluate(() => window.__bot.decide());
        a = d.kind;
        if (d.kind === 'git') { await p.evaluate(([s, xy]) => gotoScene(s, null, xy, null), [d.gs, d.xy]); await waitScene(); a += ' ' + d.gs; }
        else a += await p.evaluate(([d, DT]) => window.__bot.act(d, DT), [d, DT]);
      }
      tr.push(await p.evaluate(([st, a]) => window.__bot.rec(st, a), [step, a]));
    }
    tr.push({ isaretler: await p.evaluate(() => window.__bot.marks()) });
    // hata ayıklama: botun sonunda haritadaki canavarlar (C++ tarafı "canavarlar" komutuyla aynı alanlar)
    fs.writeFileSync(path.join(OUT, ad + '_canavar_html.json'), JSON.stringify(await p.evaluate(() => Game.ents.map((e, i) => [e, i]).filter(([e]) => e.kind === 'mob').map(([e, i]) => ({ i, ad: e.name, x: e.x, y: e.y, can: e.hp, sv: e.d.lv, saldiri: e.atk, durum: e.state, olu: !!e.dead })))));
    html[ad] = tr; fs.writeFileSync(path.join(OUT, ad + '_html.json'), JSON.stringify(tr, null, 0).replace(/},{/g, '},\n{'));
    scen.push(`tohum ${seed}`, `karakter ${cls} ${race} ${sex}`, `sahne ${start} 3 13`, 'zaman0', 'doldur', 'olumsuz 1', 'sestemizle', `gorevbot ${STEPS} ${DT} ${path.join(OUT, ad + '_bot.json')}`, `canavarlar ${path.join(OUT, ad + '_canavar.json')}`);
  }
  // 3) sınıf yükseltme zincirleri
  const CHAINS = [['战士', '人类'], ['战士', '精灵'], ['法师', '人类'], ['法师', '精灵'], ['牧师', '人类'], ['牧师', '精灵']], chainHtml = {};
  for (const [cls, race] of CHAINS) {
    const ad = 'zincir_' + cls + '_' + race;
    const r = await p.evaluate(([cls, race]) => {
      const P = Game.P; Object.assign(P, { cls, race, lv: 1, xp: 0, gold: 0, bag: [], eq: {}, sk: {}, sp: 0, adv: 0, quests: {}, done: {} }); Game.flags = {};
      gmLevel(40); autoQuests();
      const ids = ClassGM.chain().map(q => q.id), recs = [];
      const rec = tag => { const qs = Object.keys(P.quests).map(Number).sort((a, b) => a - b).map(id => { const st = P.quests[id]; let s = id + ':' + (st.n || 0) + (st.ready ? 'r' : ''); for (const k of Object.keys(st.c || {}).sort()) if (st.c[k]) s += '/' + k + '=' + st.c[k]; return s; }).join(',');
        return { etiket: tag, lv: P.lv, xp: P.xp, altin: P.gold, ust: P.adv || 0, canta: P.bag.map(b => b.id + ':' + b.n).join(','), gorev: qs, bitti: Object.keys(P.done).filter(k => P.done[k] && /^\d+$/.test(k)).map(Number).sort((a, b) => a - b).join(',') }; };
      for (const id of ids) { ClassGM.done(id); recs.push(rec(String(id))); }
      return { ids, recs };
    }, [cls, race]);
    chainHtml[ad] = r.recs;
    scen.push(`karakter ${cls} ${race} male`, 'seviye 40', 'otogorev', `gmbitir ${r.ids.join(',')} ${path.join(OUT, ad + '.json')}`);
  }
  await b.close(); if (srv) srv.kill();
  fs.writeFileSync(path.join(OUT, 'senaryo.txt'), scen.join('\n') + '\n');
  execFileSync('native/build/anrufen_test', [path.join(OUT, 'senaryo.txt')], { stdio: ['ignore', 'ignore', 'inherit'] });
  let bad = 0;
  // karşılaştır: seviyeler
  const lc = fs.readFileSync(path.join(OUT, 'seviye.txt'), 'utf8'), lh = lvHtml.split('\n'), lcl = lc.split('\n');
  const lvDiff = lh.map((l, i) => l !== lcl[i] ? `${l} · C++ ${lcl[i]}` : null).filter(Boolean);
  console.log(`açılma seviyesi: ${lh.length - 1} görev, ${lvDiff.length ? 'FARKLI ' + lvDiff.length + ' (ilk: ' + lvDiff[0] + ')' : 'hepsi aynı'}`);
  if (lvDiff.length) bad++;
  const near = (a, b) => typeof a === 'number' ? Math.abs(a - b) <= 1e-6 * Math.max(1, Math.abs(a)) : a && typeof a === 'object' ? JSON.stringify(a) === JSON.stringify(b) : a === b;
  for (const [ad] of BOTS) {
    const ct = JSON.parse(fs.readFileSync(path.join(OUT, ad + '_bot.json'), 'utf8')), ht = html[ad];
    let diff = '';
    for (let i = 0; i < Math.min(ct.length, ht.length) && !diff; i++) for (const k of Object.keys(ht[i])) if (!near(ht[i][k], ct[i][k])) { diff = `${i}. adım ${k}: HTML ${JSON.stringify(ht[i][k]).slice(0, 200)} · C++ ${JSON.stringify(ct[i][k]).slice(0, 200)}`; break; }
    if (!diff && ct.length !== ht.length) diff = `adım sayısı ${ht.length}/${ct.length}`;
    const last = ht[ht.length - 2], kinds = {}; for (const r of ht.slice(0, -1)) { const k = r.eylem.split(' ')[0]; kinds[k] = (kinds[k] || 0) + 1; }
    console.log(`${ad.padEnd(14)} ${STEPS} adım: ${diff ? 'FARKLI ' + diff : 'aynı'} (son: Sv ${last.lv}, ${last.bitti ? last.bitti.split(',').length : 0} görev bitti, altın ${last.altin}, harita ${last.sahne}; ${Object.entries(kinds).map(([k, v]) => k + ' ' + v).join(', ')})`);
    if (diff) bad++;
  }
  for (const ad of Object.keys(chainHtml)) {
    const ct = JSON.parse(fs.readFileSync(path.join(OUT, ad + '.json'), 'utf8')), ht = chainHtml[ad];
    let diff = ct.length !== ht.length ? `görev sayısı ${ht.length}/${ct.length}` : '';
    for (let i = 0; i < Math.min(ct.length, ht.length) && !diff; i++) for (const k of Object.keys(ht[i])) if (ht[i][k] !== ct[i][k]) { diff = `${ht[i].etiket} ${k}: HTML ${ht[i][k]} · C++ ${ct[i][k]}`; break; }
    const last = ht[ht.length - 1];
    console.log(`${ad.padEnd(16)} ${ht.length} görev: ${diff ? 'FARKLI ' + diff : 'aynı'} (son: Sv ${last.lv}, yükseltme ${last.ust}, altın ${last.altin})`);
    if (diff) bad++;
  }
  if (errs.length) { console.log('HATA', errs); bad++; }
  process.exitCode = bad ? 1 : 0;
})();
