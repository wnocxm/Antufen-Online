// Evcil hayvanlar (魔法兽). Ayrıntı ve kaynaklar: docs/07-evcil.md. Veri: assets/pets.json (tools/evcil.py).
// Kayıt: P.pets = [{uid, sp(Çince tür), v(renk varyantı, -1 temel), lv, xp, hp, mp, sat(tokluk), joy(mutluluk), tal(yetenek), dead, deadAt, name}],
// P.petOn = çağrılmış hayvanın uid'si, P.petMode = taktik ('attack' | 'counter' | 'support' | 'free' | 'idle'), P.petSlots.
'use strict';
const Pet = (() => {
  const T = (tr, en) => LANG === 'en' ? en : tr;
  let D = null, BY = {};
  const BOX = { wood: 0, metal: 1, magic: 2 }, TAL = { wood: [0.85, 1.0], metal: [0.95, 1.1], magic: [1.05, 1.25] };
  const MODES = ['attack', 'counter', 'support', 'free', 'idle'];
  const MODEN = { attack: ['Saldırı', 'Attack', 'Sahibinin saldırdığı hedefe saldırır.', "Attacks its owner's target."],
    counter: ['Karşı Saldırı', 'Counter', 'Sahibine saldıran düşmana saldırır.', 'Attacks enemies attacking its owner.'],
    support: ['Destek', 'Support', 'Yalnız destek becerilerini kullanır.', 'Only uses support skills.'],
    free: ['Serbest Saldırı', 'Free Attack', 'Görüş alanına giren düşmana kendiliğinden saldırır.', 'Attacks any enemy in sight.'],
    idle: ['Bekleme', 'Standby', 'Sahibini izler, hiçbir şey yapmaz.', 'Follows its owner and does nothing.'] };
  // ana beceriler (adlarına göre; orijinal açıklamalardaki etkiler, değerler bizim ölçeğimizde)
  const SK = {
    90181: { mult: 1.3, aoe: 2.2, fx: '特效-大喷血' }, 90014: { mult: 1.6, mp: 0, fx: 'BLOOD' }, 90146: { mult: 1.3, addAtk: 0.3, fx: 'BLOOD' }, 90307: { mult: 1.5, fx: '特效-大喷血' },
    90148: { mult: 1.2, addTLv: 5, fx: 'BLOOD' }, 90147: { mult: 1.2, addLv: 4, fx: 'BLOOD' }, 90590: { mult: 1.5, fx: '特效-火爆炸' }, 90150: { mult: 1.2, taunt: 8, fx: 'BLOOD' },
    90149: { mult: 1.2, mag: 1, taunt: 8, fx: '特效-火爆炸' }, 90151: { mult: 1.3, mag: 1, self: { res: 3 }, fx: '特效-冰块碎裂' }, 90152: { mult: 1.2, self: { def: 3 }, fx: 'BLOOD' },
    90154: { mult: 1.3, mag: 1, addMp: 0.02, fx: '特效-冰块碎裂' }, 90305: { mult: 1.2, mag: 1, aoe: 3, fx: '特效-火爆炸' }, 90036: { mult: 1.5, mag: 1, proj: '特效-火球', fx: '特效-火爆炸' },
    90153: { mult: 1.4, mag: 1, fx: '特效-火爆炸' }, 90156: { buff: { mag: 0.12 }, sup: 1 }, 90015: { mult: 1.2, leech: 0.3, fx: 'BLOOD' }, 90597: { mult: 1.8, mag: 1, fx: '特效-火爆炸' },
    90155: { buff: { atk: 0.1 }, sup: 1 }, 90157: { mult: 1.0, mag: 1, drain: 1, fx: 'LIGHT_ATTACK' }, 90299: { heal: 5, buff: { atk: 0.05 }, sup: 1 }, 90298: { hot: 1, sup: 1 }, 90308: { heal: 5, buff: { atk: 0.05 }, sup: 1 },
  };
  async function init() { D = await fetch(vq(Assets.base + 'pets.json')).then(r => r.json()); for (const s of D.species) BY[s.cn] = s; }
  const sp = p => BY[p.sp];
  const nm = p => p.name || (sp(p) ? T(sp(p).tr, sp(p).en) : p.sp);
  const look = p => { const s = sp(p); return (p.v >= 0 && s.variants[p.v]) || s.look; };
  const P = () => Game.P;
  const list = () => P().pets || (P().pets = []);
  const active = () => list().find(p => p.uid === P().petOn) || null;
  const mode = () => P().petMode || 'attack';
  const slots = () => P().petSlots || 2;
  const needXp = L => Math.floor(xpNeed(L) * 0.5);
  // nitelikler: şablon oranları APK 1024'ten (fiziksel/büyü/savunma/destek), seviye ölçeği bizim (oyuncudan zayıf)
  function stats(p) {
    const s = sp(p), t = D.templates[s.cls] || D.templates[2], L = p.lv, k = p.tal || 1;
    return { hp: Math.round((400 + 170 * L) * t.hp_growth / 6400 * k), mp: Math.round((200 + 60 * L) * t.mp_growth / 6400 * k),
      patk: Math.round((22 + 9 * L) * t.base_phys_atk / 1040 * k), matk: Math.round((22 + 9 * L) * t.base_mag_atk / 1040 * k),
      def: Math.round((20 + 10 * L) * t.base_def / 550 * k), dodge: (t.dodge || 120) / 40, range: s.cls === 4 ? 5 : 1.5 };
  }
  // ---------------- kuluçka ----------------
  function hatch(eggId) {
    const it = ITEMS[eggId], s = BY[it.pet.egg]; if (!s) return;
    if (list().length >= slots()) return UI.toast(T(`En fazla ${slots()} evcil hayvan besleyebilirsin (Sözleşme Taşı hakkı artırır).`, `You can keep at most ${slots()} pets (a Contract Stone adds one).`));
    const need = BOX[it.pet.box]; const box = ['31149', '31147', '30166'].find(b => countItem(b) && BOX[ITEMS[b].pet.box] >= need);
    if (!box) return UI.toast(T(`${it.name}: ${ITEMS[{ wood: '30166', metal: '31147', magic: '31149' }[it.pet.box]].name} gerekir.`, `${it.name}: requires a ${ITEMS[{ wood: '30166', metal: '31147', magic: '31149' }[it.pet.box]].name}.`));
    removeItem(eggId, 1); removeItem(box, 1);
    const [a, b] = TAL[ITEMS[box].pet.box], st0 = { sp: s.cn, lv: 1, tal: +(a + Math.random() * (b - a)).toFixed(3) };
    const p = Object.assign({ uid: Date.now().toString(36) + Math.floor(Math.random() * 1e4), v: Math.random() < 0.25 ? irnd(0, s.variants.length - 1) : -1, xp: 0, sat: 100, joy: 100, dead: false }, st0);
    const S = stats(p); p.hp = S.hp; p.mp = S.mp; list().push(p);
    SFX.play('finish_task'); UI.toast(T(`${nm(p)} yumurtadan çıktı!`, `${nm(p)} hatched!`)); UI.log(T(`Yeni evcil hayvan: ${nm(p)} (yetenek ×${p.tal})`, `New pet: ${nm(p)} (talent ×${p.tal})`), 'q');
    questFlag('hatch'); if (!P().petOn) summon(p.uid); save(); UI.refresh();
  }
  // ---------------- çağırma ----------------
  let ent = null;
  function summon(uid) {
    const p = list().find(x => x.uid === uid); if (!p) return;
    revived(p); if (p.dead) return UI.toast(T(`${nm(p)} ölü; Ejderin Kurtuluşu ile dirilt ya da biraz bekle.`, `${nm(p)} is dead; revive it with Dragon's Redemption or wait a while.`));
    P().petOn = uid; spawn(); save(); UI.refresh();
  }
  function dismiss() { P().petOn = null; despawn(); save(); UI.refresh(); }
  function despawn() { if (ent) { Game.ents = Game.ents.filter(e => e !== ent); ent = null; } }
  function spawn() {
    despawn(); const p = active(); if (!p || p.dead || !Game.player || !Game.map) return;
    const pl = Game.player; ent = new PetEnt(p, pl.x - 1, pl.y + 1); Game.ents.push(ent);
  }
  // ölü hayvan 10 dakika sonra kendiliğinden canının %10'uyla dirilir
  function revived(p) { if (p.dead && Date.now() - (p.deadAt || 0) > 600000) { p.dead = false; p.hp = Math.round(stats(p).hp * 0.1); } }
  // ---------------- varlık ----------------
  class PetEnt extends Ent {
    constructor(p, x, y) {
      super('pet', x, y); this.p = p; this.atkT = 1; this.skT = 4; this.chatT = rnd(20, 50); this.state = 'idle'; this.dir = 2; this.animT = 0;
      this.sp = Game.map.sprite(look(p)); if (!this.sp.ok) Assets.preload([look(p)]).then(() => { this.sp = Game.map.sprite(look(p)); });
    }
    get name() { return nm(this.p); }
    draw(ctx, X, Y) {
      if (!this.sp || !this.sp.ok) return;
      const a = this.state === 'attack' ? 2 : this.state === 'move' ? 1 : 0; let anim = a * 4 + this.dir;
      if (!this.sp.anims[anim] || !this.sp.anims[anim].length) anim = this.dir;
      const t = this.state === 'attack' ? Math.min(this.animT, this.sp.animLen(anim) - 1) : this.t;
      this.sp.draw(ctx, anim, t, X, Y);
    }
  }
  const S0 = () => ent && stats(ent.p);
  // hasar: oyuncunun formülü (dmgCalc), hayvanın kendi saldırısıyla
  function hit(m, mult, o = {}) {
    if (!m || m.dead) return; const s = S0(), atk = o.mag ? s.matk : s.patk;
    const r = dmgCalc(atk, m.def || 0, mult, 0, o.add || 0); m.hp -= r.d; m.aggro = true; m.state = 'hurt'; m.stateT = 0.15;
    if (o.taunt) { m.foe = ent; m.tauntT = o.taunt; } else if (!o.side && (!m.foe || m.foe.dead)) m.foe = ent;   // hayvan öfkeyi yalnız kendi başlattığı dövüşte ya da öfke çeken beceriyle alır
    UI.float(m, String(r.d), '#9fe0ff', 0.9);
    if (o.leech) ent.p.hp = Math.min(s.hp, ent.p.hp + Math.round(r.d * o.leech));
    if (m.hp <= 0) killMob(m);
  }
  function hurt(m) {   // canavar hayvana vurdu
    if (!ent) return; const p = ent.p, s = S0(); if (Math.random() < s.dodge / 100) { UI.float(ent, T('Iska', 'Miss'), '#cfcfcf'); return; }
    const b = ent.buffs || {}, def = s.def * (1 + (b.def || 0)), r = dmgCalc(m.atk || m.d.atk, def, 1); p.hp -= r.d; ent.combatT = 5; UI.float(ent, '-' + r.d, '#ff8060', 0.9);
    if (p.hp <= 0) die();
  }
  function die() {
    const p = ent.p; p.hp = 0; p.dead = true; p.deadAt = Date.now(); p.joy = Math.max(0, p.joy - 10);
    Game.fx.push(new Fx('特效-血爆死亡', ent.x, ent.y)); UI.toast(T(`${nm(p)} öldü!`, `${nm(p)} died!`)); UI.log(T(`${nm(p)} öldü. Ejderin Kurtuluşu ile diriltebilirsin; 10 dakika sonra kendiliğinden dirilir.`, `${nm(p)} died. Revive it with Dragon's Redemption, or it recovers by itself in 10 minutes.`), 'q');
    for (const e of Game.ents) if (e.foe === ent) e.foe = null;
    P().petOn = null; despawn(); save(); UI.refresh();
  }
  // görev ve taktik: hedef seçimi
  function pickTarget() {
    const pl = Game.player, md = mode(), near = (f, r) => { let b = null, bd = r; for (const e of Game.ents) if (e.kind === 'mob' && !e.dead && f(e)) { const d = Math.hypot(e.x - ent.x, e.y - ent.y); if (d < bd) { bd = d; b = e; } } return b; };
    if (md === 'idle' || md === 'support') return null;
    if (md === 'attack') { const t = Game.target; return t && t.kind === 'mob' && !t.dead && (pl.combatT > 0 || t.aggro) ? t : (ent.tg && !ent.tg.dead && ent.tg.foe === ent ? ent.tg : null); }
    if (md === 'counter') return near(e => e.aggro && (e.foe === pl || !e.foe || e.foe === ent), 7);
    return near(e => !e.d.passive, 6);   // serbest
  }
  function useSkill(t) {
    const p = ent.p, k = sp(p).skill, d = SK[k], s = S0(); if (!d) return false;
    const cost = d.mp != null ? d.mp : 20 + p.lv * 2; if (p.mp < cost) return false;
    const pl = Game.player, st = stats(p);
    if (d.sup) {   // destek: sahibinin canı azaldıysa ya da güçlendirme yoksa
      const ps = window.stats ? window.stats() : null; const low = ps && pl.hp < ps.hp * 0.7;
      if ((d.heal || d.hot) && !low) return false; if (d.buff && pl.buffs.some(b => b.id === 'petbuff') && !d.heal) return false;
      p.mp -= cost;
      if (d.heal) { const h = s.matk * d.heal; pl.hp = Math.min(ps.hp, pl.hp + h); p.hp = Math.min(st.hp, p.hp + h); UI.float(pl, '+' + Math.round(h), '#7bff8a'); }
      if (d.hot) { pl.buffs = pl.buffs.filter(b => b.id !== 'pethot'); pl.buffs.push({ id: 'pethot', buff: { hotT: s.matk / 5 }, t: 30 }); }
      if (d.buff) { pl.buffs = pl.buffs.filter(b => b.id !== 'petbuff'); pl.buffs.push({ id: 'petbuff', buff: { atk: d.buff.atk || d.buff.mag }, t: d.heal ? 6 : 30 }); }
      Game.fx.push(new Fx('特效-治疗buff', pl.x, pl.y)); UI.float(ent, T(D.skills[k].tr[0], D.skills[k].en[0]), '#ffe070', 0.8); return true;
    }
    if (!t) return false; p.mp -= cost;
    const add = (d.addAtk ? s.patk * d.addAtk : 0) + (d.addLv ? p.lv * d.addLv : 0) + (d.addTLv ? t.d.lv * d.addTLv : 0) + (d.addMp ? st.mp * d.addMp : 0);
    const o = { mag: d.mag, add, taunt: d.taunt, leech: d.leech };
    // alan becerisi yalnız zaten dövüşen canavarlara vurur ve öfkeyi yalnız asıl hedef çeker (uyuyan sürüyü uyandırmaz)
    const land = () => { if (d.aoe) { for (const m of Game.ents) if (m.kind === 'mob' && !m.dead && (m === t || m.aggro) && Math.hypot(m.x - t.x, m.y - t.y) <= d.aoe) hit(m, d.mult, m === t ? o : Object.assign({}, o, { side: 1 })); } else hit(t, d.mult, o); if (d.fx) Game.fx.push(new Fx(d.fx, t.x, t.y)); if (d.drain) p.mp = Math.min(st.mp, p.mp + cost + 10); };
    if (d.self) ent.buffs = Object.assign({}, d.self, { t: 10 });
    if (d.proj) shoot(d.proj, ent, t, land, true); else land();
    UI.float(ent, T(D.skills[k].tr[0], D.skills[k].en[0]), '#ffe070', 0.8); return true;
  }
  let satT = 0, joyT = 0;
  function update(dt) {
    if (list().length && !Game.flags.hatch) Game.flags.hatch = true;   // kuluçka görevi: hayvanı olan oyuncu için hazır
    const p = active();
    if (!p) { if (ent) despawn(); return; }
    if (!ent && Game.player && !p.dead) spawn();
    if (!ent) return;
    const pl = Game.player, st = stats(p);
    ent.t += dt * TICK; ent.animT += dt * TICK; ent.atkT -= dt; ent.skT -= dt; ent.combatT = (ent.combatT || 0) - dt; ent.chatT -= dt;
    if (ent.buffs && (ent.buffs.t -= dt) <= 0) ent.buffs = null;
    if (ent.stateT > 0 && (ent.stateT -= dt) <= 0) ent.state = 'idle';
    // yenilenme, tokluk, mutluluk
    const rg = ent.combatT > 0 ? 0.003 : 0.015; p.hp = Math.min(st.hp, p.hp + st.hp * rg * dt); p.mp = Math.min(st.mp, p.mp + st.mp * rg * 1.3 * dt);
    if ((satT += dt) >= 120) { satT = 0; p.sat = Math.max(0, p.sat - 1); }
    if ((joyT += dt) >= 60) { joyT = 0; if (p.sat < 20) p.joy = Math.max(0, p.joy - 1); }
    if (ent.chatT <= 0) { ent.chatT = rnd(45, 100); const L = LANG === 'en' ? sp(p).chatEn : sp(p).chatTr; if (L.length) { ent.say = L[irnd(0, L.length - 1)]; ent.sayT = 4; } }
    if (ent.sayT > 0) ent.sayT -= dt;
    if (pl.dead) { ent.state = 'idle'; return; }
    // farklı haritaya geçince ya da çok uzaklaşınca sahibinin yanına ışınlanır
    const dp = Math.hypot(pl.x - ent.x, pl.y - ent.y); if (dp > 14) { ent.x = pl.x - 1; ent.y = pl.y + 1; }
    const hungry = p.sat <= 0 || p.joy <= 20;
    let t = hungry ? null : pickTarget(); if (t && Math.hypot(t.x - pl.x, t.y - pl.y) > 12) t = null; ent.tg = t;
    if (ent.state === 'attack' || ent.state === 'cast') return;
    if (!hungry && ent.skT <= 0 && (mode() !== 'idle')) { if (useSkill(t)) { ent.skT = 8; ent.state = 'cast'; ent.stateT = 0.4; return; } ent.skT = 1; }
    if (t) {
      const d = Math.hypot(t.x - ent.x, t.y - ent.y);
      if (d > st.range) { stepTo(ent, t.x, t.y, RUN * 0.95, dt, true); ent.state = 'move'; }
      else if (ent.atkT <= 0) {
        ent.atkT = 1.5; ent.state = 'attack'; ent.animT = 0; ent.stateT = 0.45; ent.dir = dirOf(t.x - ent.x, t.y - ent.y); ent.combatT = 5;
        const mag = sp(p).cls === 4; later(0.25, () => { if (!ent || t.dead) return; if (mag) shoot('特效-火球', ent, t, () => hit(t, 1, { mag: 1 }), true); else hit(t, 1); });
      } else ent.state = 'idle';
    } else if (dp > 2.2) { stepTo(ent, pl.x - 0.8, pl.y + 0.8, RUN * (dp > 5 ? 1.3 : 1), dt, true); ent.state = 'move'; }
    else ent.state = 'idle';
  }
  // öldürmeden deneyim payı (sahibinin seviyesini geçemez; 5'ten fazla gerideyse ×3)
  function onKill(m, xp) {
    const p = active(); if (!p || p.dead) return; if (p.lv >= P().lv) return;
    p.xp += Math.round(xp * 0.5 * (p.lv < P().lv - 5 ? 3 : 1)); gainLv(p);
  }
  function gainLv(p) {
    let up = false; while (p.xp >= needXp(p.lv) && p.lv < P().lv) { p.xp -= needXp(p.lv); p.lv++; up = true; }
    if (up) { const s = stats(p); p.hp = s.hp; p.mp = s.mp; if (ent) { Game.fx.push(new Fx('LEVELUP', ent.x, ent.y)); UI.float(ent, T(`Seviye ${p.lv}!`, `Level ${p.lv}!`), '#ffe070', 1.2); } UI.log(T(`${nm(p)} ${p.lv}. seviyeye ulaştı.`, `${nm(p)} reached level ${p.lv}.`), 'q'); }
    if (p.lv >= P().lv) p.xp = Math.min(p.xp, needXp(p.lv) - 1);
  }
  // eşya kullanımı (çanta): kuluçka, mama, iksir, diriltme, sözleşme taşı, iç öz
  function useItem(id) {
    const it = ITEMS[id], u = it.pet; if (!u) return false;
    if (u.egg) { hatch(id); return true; }
    if (u.box) { UI.toast(T('Kuluçka kutusu: çantadaki bir yumurtayı kullanınca kendiliğinden kullanılır.', 'Incubator: used automatically when you use an egg from your bag.')); return true; }
    if (u.petSlot) { P().petSlots = slots() + 1; removeItem(id, 1); UI.toast(T(`Evcil hayvan hakkın: ${slots()}`, `Pet slots: ${slots()}`)); save(); return true; }
    const p = u.petRevive ? (list().find(x => x.uid === P().petSel && x.dead) || list().find(x => x.dead)) : active();
    if (!p) { UI.toast(u.petRevive ? T('Ölü evcil hayvanın yok.', 'You have no dead pet.') : T('Önce bir evcil hayvan çağır.', 'Summon a pet first.')); return true; }
    const st = stats(p);
    if (u.petRevive) { p.dead = false; p.hp = Math.round(st.hp * u.petRevive); UI.toast(T(`${nm(p)} dirildi.`, `${nm(p)} was revived.`)); }
    else if (u.food) { if (p.sat >= 100) { UI.toast(T(`${nm(p)} tok.`, `${nm(p)} is full.`)); return true; } p.sat = Math.min(100, p.sat + u.food); p.joy = Math.min(100, p.joy + 10); if (ent) UI.float(ent, T('Hım hım!', 'Yum!'), '#7bff8a'); }
    else if (u.petHp) { if (p.hp >= st.hp) { UI.toast(T('Canı dolu.', 'HP is full.')); return true; } p.hp = Math.min(st.hp, p.hp + u.petHp); if (ent) UI.float(ent, '+' + u.petHp, '#7bff8a'); }
    else if (u.petMp) { p.mp = Math.min(st.mp, p.mp + u.petMp); }
    else if (u.petXp) { if (p.lv >= P().lv) { UI.toast(T('Evcil hayvanın seviyesi senin seviyeni geçemez.', "Your pet's level can't exceed yours.")); return true; } p.xp += u.petXp; gainLv(p); }
    removeItem(id, 1); save(); UI.refresh(); return true;
  }
  // canavardan yumurta: türün görünüş ailesi (ör. 怪物-狼) canavarınkiyle aynıysa küçük olasılıkla (orijinal: "yumurta canavar öldürerek de elde edilir")
  function dropEgg(m) {
    if (!D) return; const info = Game.mobInfo(m.name); if (!info) return; const fam = String(info[1]).replace(/-[^-]+$/, '').replace(/^(怪物-[^-]+).*$/, '$1');
    const s = D.species.find(x => x.look && (x.look === info[1] || x.look.replace(/-[^-]+$/, '') === fam || x.look === fam)); if (!s) return;
    const ch = m.d.rank === 2 ? 0.25 : m.d.rank ? 0.03 : 0.004; if (Math.random() < ch) { addItem(s.egg, 1, true); UI.toast(T(`Ganimet: ${ITEMS[s.egg].name}!`, `Loot: ${ITEMS[s.egg].name}!`)); UI.log(T(`Ganimet: ${ITEMS[s.egg].name}`, `Loot: ${ITEMS[s.egg].name}`), 'q'); }
  }
  // ---------- GM komutları ----------
  const GM = {
    egg(cn) { const s = BY[cn]; if (!s) return; addItem(s.egg, 1, true); addItem({ wood: '30166', metal: '31147', magic: '31149' }[s.box], 1, true); UI.toast(T(`${ITEMS[s.egg].name} + kutu verildi; çantadan kullan.`, `${ITEMS[s.egg].name} + incubator given; use it from your bag.`)); },
    give(cn) { const s = BY[cn]; if (!s) return; if (list().length >= slots()) P().petSlots = list().length + 1; addItem(s.egg, 1, true); addItem('31149', 1, true); hatch(s.egg); },
    level() { const p = active() || list()[0]; if (!p) return UI.toast(T('Evcil hayvanın yok.', 'No pet.')); p.lv = P().lv; p.xp = 0; const st = stats(p); p.hp = st.hp; p.mp = st.mp; p.dead = false; save(); UI.toast(`${nm(p)} ${T('Sv', 'Lv')} ${p.lv}`); },
    care() { for (const p of list()) { const st = stats(p); p.dead = false; p.hp = st.hp; p.mp = st.mp; p.sat = 100; p.joy = 100; } if (!active() && list()[0]) summon(list()[0].uid); save(); UI.toast(T('Bütün hayvanlar dirildi, doydu, iyileşti.', 'All pets revived, fed and healed.')); },
    items() { for (const [id, n] of [['30022', 20], ['30021', 10], ['30755', 10], ['30025', 5], ['30595', 2], ['30006', 3], ['30166', 3], ['31147', 3], ['31149', 3]]) addItem(id, n, true); UI.toast(T('Evcil hayvan eşyaları verildi.', 'Pet items given.')); },
    hungry() { const p = active(); if (p) { p.sat = 0; p.joy = 15; UI.toast(T('Hayvan acıktı (savaşmaz).', 'Pet is hungry (won\'t fight).')); } },
    clear() { P().pets = []; P().petOn = null; despawn(); save(); UI.toast(T('Bütün hayvanlar silindi.', 'All pets removed.')); },
  };
  function setMode(md) { P().petMode = md; save(); }
  function release(uid) { const L = list(), i = L.findIndex(x => x.uid === uid); if (i < 0) return; if (P().petOn === uid) dismiss(); L.splice(i, 1); save(); UI.refresh(); }
  return { GM, init, hatch, summon, dismiss, spawn, update, hurt, onKill, useItem, dropEgg, setMode, release, stats, nm, look, sp, list, active, get ent() { return ent; }, MODES, MODEN, slots, needXp, revived, get D() { return D; } };
})();
