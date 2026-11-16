// Savaş dengesi: her sınıf (战士/法师/牧师), seviyeye uygun en iyi dükkân eşyası ve dağıtılmış beceri puanlarıyla,
// kendi seviyesindeki normal (ve ☆ seçkin) canavarla gerçek oyun döngüsünde (update) dövüşür.
// Çıktı: öldürme süresi, kaybedilen can yüzdesi, kazanan. node tools/test/savas.js   (LVS=5,10,… CLS=战士,…)
const { chromium } = require('playwright');
const LVS = (process.env.LVS || '3,5,10,15,20,25,30,35,40,45,50,55').split(',').map(Number);
const CLSS = (process.env.CLS || '战士,法师,牧师').split(',');
const BOSS = (process.env.BOSS || '').split(';').filter(Boolean).map(x => x.split(':'));   // örn. BOSS='120278:★月夜狼王:30'
(async () => {
  const b = await chromium.launch();
  for (const cls of CLSS) {
    const p = await (await b.newContext({ viewport: { width: 780, height: 360 } })).newPage();
    const errs = []; p.on('pageerror', e => errs.push(e.message));
    await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
    await p.click(`[data-cls="${cls}"]`); await p.fill('#cname', 'Savas'); await p.click('#cstart');
    await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
    const r = await p.evaluate(async ([LVS, BOSS]) => {
      const P = __G.P, S = Assets.D.scenes, q = () => {}; UI.log = q; UI.toast = q; SFX.play = q; save = q; UI.death = q; UI.float = q; UI.hurt = q; UI.levelUp = q;
      const C = CLS[P.cls], out = [];
      const spot = (L, elite) => { // seviyesi L'ye en yakın canavar
        let best = null;
        for (const s of Object.values(S)) { if (!s.lvr || s.lvr[0] > L || s.lvr[1] < L) continue;
          for (const e of s.ents) { if (!Assets.D.mon[e[0]] || e[1].includes('☆☆') || e[1].includes('☆') !== elite) continue;
            const d = monDef(e[1], s); const k = Math.abs(d.lv - L - (elite ? 1 : 0)); if (!best || k < best[2]) best = [s, e[1], k]; } }
        return best; };
      const fight = (L, elite, fixed) => {
        const sp = fixed || spot(L, elite); if (!sp) return null;
        L = fixed ? L : elite ? Math.max(1, monDef(sp[1], sp[0]).lv - 1) : L; gmLevel(L); P.sk = {};
        for (const sk of C.skills) if (sk.lv <= L) P.sk[sk.id] = clamp(Math.floor((L - sk.lv) / 4) + 1, 1, 10);
        gmGear(); const st = stats(); const pl = __G.player; pl.buffs = []; pl.cds = {}; pl.hp = st.hp; pl.mp = st.mp; pl.dead = false; pl.state = 'idle';
        Game.ents = Game.ents.filter(e => e.kind !== 'mob'); Game.fx = [];
        const m = new Mob(sp[1], pl.x + 1.2, pl.y); m.home = { x: m.x, y: m.y }; m.aggro = true; Game.ents.push(m); setTarget(m);
        let t = 0, casts = 0, pots = 0; const dt = 0.05; const pot = P.lv > 10 ? 'hp2' : 'hp1'; if (fixed) addItem(pot, 20, true);
        while (t < 240 && !m.dead && !pl.dead) {
          if (pl.state !== 'attack' && pl.state !== 'cast') {
            const s2 = stats();
            // beceri seçimi: şifa (can %45 altı), sonra en güçlü saldırı becerisi; normal saldırı kendiliğinden
            for (let i = C.skills.length - 1; i >= 0; i--) { const sk = C.skills[i]; if (sk.pas || !P.sk[sk.id] || (pl.cds[sk.id] || 0) > 0 || pl.mp < sk.mp) continue;
              const heal = sk.healT || sk.hotT; if (heal && pl.hp > s2.hp * 0.45) continue; if (!heal && !sk.mult && !sk.pct && !sk.aoe && !sk.buff) continue;
              useSkill(i); casts++; break; }
          }
          if (fixed && pl.hp < st.hp * 0.35 && (pl.potT || 0) <= t && countItem(pot)) { useItem(pot); pots++; pl.potT = t + 10; }
          update(dt); t += dt;
        }
        const st2 = stats();
        return { L, elite, mob: trName(sp[1]), mlv: m.d.lv, mhp: m.maxHp, matk: m.atk, php: st2.hp, patk: st2.atk, pdef: st2.def, t: +t.toFixed(1), lost: Math.round(100 * (st2.hp - Math.max(0, pl.hp)) / st2.hp), win: m.dead && !pl.dead, casts, pots };
      };
      if (BOSS.length) { for (const [sid, nm, L] of BOSS) { await gotoScene(sid); const f = fight(+L, false, [Assets.D.scenes[sid], nm]); if (f) out.push(f); } return out; }
      for (const L of LVS) for (const el of [false, true]) { const f = fight(L, el); if (f) out.push(f); }
      return out;
    }, [LVS, BOSS]);
    console.log(`\n== ${cls} ==  Sv | canavar (sv) | canavar TP/saldırı | oyuncu TP/saldırı/savunma | süre sn | kaybedilen can % | sonuç | beceri`);
    for (const x of r) console.log([x.L + (x.elite ? '☆' : ''), `${x.mob} (${x.mlv})`, `${x.mhp}/${x.matk}`, `${x.php}/${x.patk}/${x.pdef}`, x.t, x.lost, x.win ? 'kazandı' : 'KAYBETTİ', x.casts, x.pots != null ? 'iksir ' + x.pots : ''].join(' | '));
    if (errs.length) console.log('HATA', errs.slice(0, 3));
  }
  await b.close();
})();
