// Sınıf yükseltme (40) testi: orijinal görev zinciri, sınıf ağacı kilidi, çok eşyalı toplama, seçimli bitiş, eski kayıt.  node tools/test/sinif.js  (OUT=görüntü öneki, DIL=en)
// 1) İnsan savaşçı: 40'tan önce sınıf ağacı kilitli; 40'ta "Acemilikten Çıkış" kendiliğinden gelir; Ozan → Tom → Karagece → Şato Uşağı → Savaşçı.
//    NPC konuşmaları gerçekten açılıp satırlara dokunulur. 2) Ozan'ın her sınıf/ırk için verdiği giriş görevi. 3) İnsan büyücü: iki eşyalı toplama
//    ve perinin iki seçenekli bitişi. 4) Thomas Young seviyesi, Gümüşkartal Avlusu seviyesi. 5) Eski kayıt: sınıf ağacı puanları geri verilir.
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.addInitScript(D => { try { localStorage.setItem('anrufen_lang', D); } catch (e) {} }, process.env.DIL || 'tr');
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1500); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'GMSinif'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const O = process.env.OUT || '/tmp/sinif', log = (k, v) => console.log(k.padEnd(34), JSON.stringify(v));
  const go = async sid => { await p.evaluate(s => gotoScene(s, null, null, null), sid); await p.waitForFunction(s => Game.sceneId === s && Game.player && !document.querySelector('#loading:not(.hidden)'), sid, { timeout: 30000 }); await p.waitForTimeout(800); };
  // NPC ile konuş: seçeneklerin metinleri döner
  const talk = async cn => { await p.evaluate(c => { UI.closeAll(); const n = Game.ents.find(e => e.kind === 'npc' && e.cn === c); Win.open('npc', { npc: n }); }, cn); await p.waitForTimeout(300); return p.evaluate(() => Win.npcOpts().o.map(x => x.t)); };
  // satıra dokun (uzun söz sayfalıysa önce "Devam"lara basılır, oyuncunun yaptığı gibi)
  const row = async re => {
    for (let k = 0; k < 8; k++) { const d = await p.evaluate(() => Win.npcDrawn()); if (!(d.length === 1 && /^(Devam|Continue)$/.test(d[0]))) break; await p.evaluate(() => Win.npcRow(0)); await p.waitForTimeout(250); }
    const i = await p.evaluate(r => Win.npcDrawn().findIndex(t => new RegExp(r).test(t)), re); if (i < 0) throw new Error('satır yok: ' + re + ' ' + JSON.stringify(await p.evaluate(() => Win.npcDrawn())));
    await p.evaluate(i => Win.npcRow(i), i); await p.waitForTimeout(350); };
  const st = () => p.evaluate(() => ({ sınıf: clsName(), adv: Game.P.adv || 0, lv: Game.P.lv, sp: Game.P.sp, w4: Game.P.sk.w4 || 0, aktif: Object.keys(Game.P.quests).map(Number), biten: [80344, 80569, 80223, 80224].filter(i => Game.P.done[i]) }));
  // 1) 40'tan önce
  await p.evaluate(() => gmLevel(39)); await p.evaluate(() => { const sk = CLS[Game.P.cls].skills.find(k => k.id === 'w4'); skillUp(sk); });
  log('39: kilit / ad / w4', await p.evaluate(() => ({ kilit: skLock(CLS.战士.skills.find(k => k.id === 'w4')), ad: clsName(), w4: Game.P.sk.w4 || 0, görev80344: !!Game.P.quests[80344] })));
  await p.evaluate(() => { Win.open('skill'); Win.tapId(50397); }); await p.waitForTimeout(500); await p.screenshot({ path: O + '_agac_kilitli.png' });
  await p.evaluate(() => { UI.closeAll(); Game.P.xp = xpNeed(39) - 1; gainXp(10); });
  log('40: kendiliğinden görev', await st());
  // Ozan (Altındalga Limanı)
  await go('120094'); log('Ozan seçenekleri', await talk('吟游诗人'));
  await row('Acemilikten|Rookie'); await row('Tamamla|Complete'); log('80344 bitti', await st());
  const ozan = await talk('吟游诗人'); log('Ozan (sonra)', ozan); await p.screenshot({ path: O + '_ozan.png' });
  await row('Sınıf değiştirmek|change my class'); await row('Kabul|Accept');
  // Tom (Guanlin)
  await go('120005'); log('Tom seçenekleri', await talk('汤姆')); await row('Çocuğun|Boy'); await row('Tamamla|Complete');
  await talk('汤姆'); await row('Kayıp|Lost'); await row('Kabul|Accept');
  await p.evaluate(() => questKill('☆黑夜')); log('Karagece öldü', await p.evaluate(() => Game.P.quests[80223]));
  await talk('汤姆'); await row('Kayıp|Lost'); await row('Tamamla|Complete');
  await talk('汤姆'); await row('Yıldız|Star'); await row('Kabul|Accept');
  log('Şato Uşağı', await p.evaluate(() => { let k = 0; while (!Game.P.quests[80224].ready && k < 200) { questKill('城堡侍从'); k++; } return { öldürme: k, hazır: Game.P.quests[80224].ready }; }));
  await talk('汤姆'); await row('Yıldız|Star'); await p.screenshot({ path: O + '_tom.png' }); await row('Tamamla|Complete');
  log('SAVAŞÇI oldu', await st());
  log('ödül eşyaları', await p.evaluate(() => ['10097', '10095', '10098', '10100', '10101'].map(id => countItem(id))));
  // sınıf ağacı: orijinal kural, acemi ağacına 35 puan da gerekir (tools/test/beceri.js)
  await p.evaluate(() => { const P = Game.P, sk = CLS.战士.skills.find(k => k.id === 'w4'); P.sk = { w1: 1 }; P.sp = 40; skillAutoSpend(34); P.sp = 6; skillUp(sk); });
  log('w4 öğrenildi (acemi 35)', await p.evaluate(() => ({ w4: Game.P.sk.w4 || 0, kilit: skLock(CLS.战士.skills.find(k => k.id === 'w4')) })));
  await p.evaluate(() => { UI.closeAll(); Win.open('skill'); Win.tapId(50397); }); await p.waitForTimeout(500); await p.screenshot({ path: O + '_agac_acik.png' });
  // 2) Ozan'ın giriş görevi: her sınıf ve ırk için
  log('giriş görevleri', await p.evaluate(() => { const P = Game.P, s0 = [P.cls, P.race], out = {};
    for (const c of ['战士', '法师', '牧师']) for (const r of ['人类', '精灵']) { P.cls = c; P.race = r; out[c + '/' + r] = QUESTS.filter(q => q.giver === '吟游诗人' && questState(q) === 'new').map(q => q.id); }
    [P.cls, P.race] = s0; return out; }));
  // 3) insan büyücü: iki eşyalı toplama + seçim
  await p.evaluate(() => { const P = Game.P; P.cls = '法师'; P.adv = 0; ClassGM.done(80570); acceptQuest(QBY[80225]); });
  log('uçan canavarlar', await p.evaluate(() => { let k = 0; const st = Game.P.quests[80225]; while (!st.ready && k < 300) { questKill(['凶恶蝙蝠', '☆吸血蝙蝠', '☆暗尘仙子'][k % 3]); k++; } return { öldürme: k, sayaç: st.c, n: st.n, hazır: st.ready }; }));
  await p.evaluate(() => { completeQuest(QBY[80225]); acceptQuest(QBY[80226]); Game.P.quests[80226].ready = true; });
  await go('120020'); const peri = await talk('林隐仙子'); await row('Büyücünün|Mage'); log('peri seçenekleri', await p.evaluate(() => Win.npcOpts().o.map(x => x.t)));
  await p.screenshot({ path: O + '_peri.png' }); await row('Bırak|Let her'); log('seçim sonrası metin', await p.evaluate(() => Win.npcOpts().txt.slice(0, 60)));
  log('BÜYÜCÜ oldu', await p.evaluate(() => ({ sınıf: clsName(), adv: Game.P.adv, asa: countItem('10110') })));
  // 4) seviyeler
  log('seviyeler', await p.evaluate(() => ({ thomas: monDef('☆【叛神者】托马斯杨').lv, şatoUşağı: monDef('城堡侍从', Assets.D.scenes['120132']).lv, avlu: Assets.D.scenes['120132'].lvr, sınavOdası: Assets.D.scenes['120165'].lvr })));
  // 5) eski kayıt: 45. seviye, sınıf yükseltmesiz, sınıf ağacında 3 kademe → puan geri
  log('eski kayıt', await p.evaluate(() => { const s = JSON.parse(JSON.stringify(Game.P)); s.cls = '战士'; delete s.adv; s.sk = { w1: 5, w4: 3, wp4: 2 }; s.sp = 0; const f = fixSave(s); return { sk: f.sk, sp: f.sp }; }));
  // 6) 80. seviye ikinci sınıf yükseltmesi: Bozbalta Şehri zinciri (Kara Şövalye / Büyük Büyü Üstadı / Seçilmiş). Yükseltmesiz kilitli; Ozan
  //    80 öncesi ve sonrası ne der; NPC konuşmaları gerçekten açılır; düşen eşya, sandık, görev eşyası kullanma; ödül takımı + Eğitim Kitabı.
  const setup80 = (cls, adv) => p.evaluate(([cls, adv]) => { const P = Game.P; P.cls = cls; P.adv = adv; P.quests = {}; for (const q of QUESTS) if (q.id >= 83085 && q.id <= 83093) delete P.done[q.id]; if (P.lv < 80) gmLevel(80); fixSkills(P); return { giriş: [83085, 83088, 83091].map(i => questState(QBY[i])) }; }, [cls, adv]);
  log('80: yükseltmesiz', await setup80('战士', 0));
  log('80: yükseltmeli', await setup80('战士', 1));
  await go('120094'); await p.evaluate(() => { Game.P.lv = 79; }); log('Ozan (79)', await talk('吟游诗人')); await row('Sınıf değiştirmek|change my class'); log('  söz', await p.evaluate(() => Win.npcOpts().txt.slice(0, 70)));
  await p.evaluate(() => { Game.P.lv = 80; }); await talk('吟游诗人'); await row('Sınıf değiştirmek|change my class'); log('Ozan (80, savaşçı)', await p.evaluate(() => Win.npcOpts().txt.slice(0, 160)));
  const done80 = async (npc, id, re) => { await talk(npc); await row(re); await row('Tamamla|Complete'); return p.evaluate(i => !!Game.P.done[i], id); };
  const take80 = async (npc, re) => { await talk(npc); await row(re); await row('Kabul|Accept'); };
  // savaşçı
  await go('120156'); log('Komutan seçenekleri', await talk('黑骑士统领'));
  await row('Darboğaz|Bottleneck'); await row('Kabul|Accept'); log('Darboğaz bitti', await done80('黑骑士统领', 83085, 'Darboğaz|Bottleneck'));
  await take80('黑骑士统领', 'Güç Arayışı|Pursuit');
  log('Ölümsüz Şövalye + parça', await p.evaluate(() => { let k = 0; const st = Game.P.quests[83086]; while (!st.ready && k < 200) { questKill('☆不朽骑士'); k++; } return { öldürme: k, sayaç: st.c, hazır: st.ready }; }));
  log('Güç Arayışı bitti', await done80('黑骑士统领', 83086, 'Güç Arayışı|Pursuit'));
  await take80('黑骑士统领', 'Kara Şövalye|Black Knight'); await p.evaluate(() => questKill('☆☆【疯狂梦呓者】安德卡诺'));
  await talk('黑骑士统领'); await row('Kara Şövalye|Black Knight'); await p.screenshot({ path: O + '_kara_sovalye.png' }); await row('Tamamla|Complete');
  log('KARA ŞÖVALYE', await p.evaluate(() => ({ sınıf: clsName(), adv: Game.P.adv, takım: ['10212', '10201', '10202', '10204', '10205'].map(countItem), kitap: countItem('30788') })));
  // büyücü: sandık
  await setup80('法师', 1); await take80('大魔导师引导者', 'Güçlü Büyü|Mighty Magic'); log('Güçlü Büyü bitti', await done80('大魔导师引导者', 83088, 'Güçlü Büyü|Mighty Magic'));
  await take80('大魔导师引导者', 'Kristal|Crystals');
  await p.evaluate(() => { for (let k = 0; k < 10; k++) questKill('☆风尘怪'); });
  await go('120495'); log('sandık', await p.evaluate(() => { const n = Game.ents.find(e => e.cn === '尘封的导魔水晶箱'); interact(n); return { sayaç: Game.P.quests[83089].c, hazır: Game.P.quests[83089].ready }; }));
  await go('120156'); log('Kristaller bitti', await done80('大魔导师引导者', 83089, 'Kristal|Crystals'));
  await take80('大魔导师引导者', 'Büyük Büyü Üstadı|Grand Magister'); await p.evaluate(() => questKill('☆☆【疯狂梦呓者】安德卡诺'));
  await done80('大魔导师引导者', 83090, 'Büyük Büyü Üstadı|Grand Magister'); log('BÜYÜK BÜYÜ ÜSTADI', await p.evaluate(() => ({ sınıf: clsName(), adv: Game.P.adv, asa: countItem('10214') })));
  // rahip: Büyü Emici Küre
  await setup80('牧师', 1); await take80('虔诚的天选者', 'İzler|Footsteps'); await done80('虔诚的天选者', 83091, 'İzler|Footsteps');
  await take80('虔诚的天选者', 'Gezgin|Wandering'); await p.evaluate(() => { for (let k = 0; k < 10; k++) questKill('☆灵魂漫步者'); }); await done80('虔诚的天选者', 83093, 'Gezgin|Wandering');
  await take80('虔诚的天选者', 'Seçilmiş|The Chosen'); log('küre çantada', await p.evaluate(() => countItem('33662')));
  await go('120499');
  log('küresiz öldürme', await p.evaluate(() => { questKill('☆☆【疯狂梦呓者】安德卡诺'); return Game.P.quests[83092].c || {}; }));
  log('hedefsiz küre', await p.evaluate(() => { setTarget(null); useItem('33662'); return { küre: countItem('33662'), c: Game.P.quests[83092].c || {} }; }));
  log('küre + öldürme', await p.evaluate(() => { const m = Game.ents.find(e => e.kind === 'mob' && e.name === '☆☆【疯狂梦呓者】安德卡诺'); Game.player.x = m.x + 1; Game.player.y = m.y; setTarget(m, true); useItem('33662'); questKill(m.name); return { küre: countItem('33662'), c: Game.P.quests[83092].c, hazır: Game.P.quests[83092].ready, sv: m.d.lv }; }));
  await go('120156'); await done80('虔诚的天选者', 83092, 'Seçilmiş|The Chosen'); log('SEÇİLMİŞ', await p.evaluate(() => ({ sınıf: clsName(), adv: Game.P.adv, kitap: countItem('11349') })));
  log('hedef seviyeleri', await p.evaluate(() => ['☆不朽骑士', '☆风尘怪', '☆灵魂漫步者', '☆☆【疯狂梦呓者】安德卡诺'].map(n => n + ' ' + monDef(n).lv)));
  console.log('HATA', errs); await b.close();
})();
