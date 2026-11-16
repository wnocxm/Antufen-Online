// Evcil hayvanlar (魔法兽). Ayrıntı ve kaynaklar: docs/07-evcil.md. Veri: assets/pets.json (tools/evcil.py).
// Kayıt: P.pets = [{uid, sp(Çince tür), st(幻化 dönüşüm düzeyi 0-7), sk([rastgele beceriler]), lv, xp, hp, mp, sat(tokluk), joy(mutluluk),
//         tal(yetenek), dead, deadAt, name}], P.petOn = çağrılmış hayvanın uid'si, P.petMode = taktik, P.petSlots.
// Türün 8 biçimi (temel + 7 dönüşüm aşaması) pets.json'da: species[].forms[st]. Beceriler: 1 doğuştan + 1-3 rastgele (orijinal görev metni).
'use strict';
const Pet = (() => {
  const T = (tr, en) => LANG === 'en' ? en : tr;
  let D = null, BY = {};
  const BOX = { wood: 0, metal: 1, magic: 2 }, TAL = { wood: [0.85, 1.0], metal: [0.95, 1.1], magic: [1.05, 1.25] };
  // doğuşta rastgele beceri sayısı: Usta'nın görev metni "en az bir, en fazla üç; kuluçkada belli olur" (yardım metni 0-3 der; görev metni esas).
  // Olasılıklar kutuya göre, bizim ağırlıklar: [0, 1, 2, 3 beceri]
  const RSK = { wood: [0, 65, 30, 5], metal: [0, 45, 40, 15], magic: [0, 25, 45, 30] };
  const MODES = ['attack', 'counter', 'support', 'free', 'idle'];
  const MODEN = { attack: ['Saldırı', 'Attack', 'Sahibinin saldırdığı hedefe saldırır.', "Attacks its owner's target."],
    counter: ['Karşı Saldırı', 'Counter', 'Sahibine saldıran düşmana saldırır.', 'Attacks enemies attacking its owner.'],
    support: ['Destek', 'Support', 'Yalnız destek becerilerini kullanır.', 'Only uses support skills.'],
    free: ['Serbest Saldırı', 'Free Attack', 'Görüş alanına giren düşmana kendiliğinden saldırır.', 'Attacks any enemy in sight.'],
    idle: ['Bekleme', 'Standby', 'Sahibini izler, hiçbir şey yapmaz.', 'Follows its owner and does nothing.'] };
  // beceri etkileri: orijinal açıklamalardaki etki türü, sayılar bizim ölçeğimiz (orijinal değerler sunucudaydı)
  // mult: saldırı çarpanı · mag: büyü saldırısı · both: fiziksel + büyü · aoe: hedef çevresi yarıçapı · nova: kendi çevresi
  // add*: ek hasar kaynağı · taunt: öfke çekme (sn) · slow: yavaşlatma · weak: hedef savunması düşer (sn) · self: kendine güçlendirme
  // sup: destek (heal ×büyü, healPct can sınırı yüzdesi, hot, buff) · pas: kalıcı · aura: çağrılıyken sahibine ve kendine · cd: bekleme
  const SK = {
    90146: { mult: 1.3, fx: '特效-刀光' }, 90145: { mult: 1.2, addHp: 0.02, fx: 'BLOOD' }, 90307: { mult: 1.5, fx: '特效-大喷血' },
    90147: { mult: 1.2, addLv: 4, fx: 'BLOOD' }, 90148: { mult: 1.2, addTLv: 5, fx: 'BLOOD' },
    90181: { mult: 1.15, aoe: 2.2, fx: '特效-刀光-红' }, 90302: { mult: 1.15, aoe: 3.2, fx: '特效-刀光-红' },
    90590: { mult: 1.5, both: 1, fx: '特效-火爆炸' }, 90150: { mult: 1.2, taunt: 8, fx: 'BLOOD' },
    90149: { mult: 1.2, mag: 1, taunt: 8, proj: '特效-火球', fx: '特效-火爆炸' }, 90151: { mult: 1.3, mag: 1, self: { def: 0.15 }, proj: '特效-冰球', fx: '特效-冰块碎裂' },
    90152: { mult: 1.2, self: { def: 0.2 }, fx: 'BLOOD' }, 90305: { mult: 1.15, mag: 1, addMp: 0.05, aoe: 3.2, fx: '特效-火爆炸' },
    90597: { mult: 1.8, mag: 1, cd: 10, fx: '特效-火爆炸' }, 90039: { mult: 1.8, mag: 1, cd: 10, fx: '特效-火爆炸' },
    90153: { mult: 1.4, mag: 1, proj: '特效-火球', fx: '特效-火爆炸' }, 90154: { mult: 1.3, mag: 1, addMp: 0.02, proj: '特效-冰球', fx: '特效-冰块碎裂' },
    90260: { mult: 1.3, mag: 1, weak: 5, cd: 12, proj: '特效-蓝火球', fx: '特效-蓝火球' }, 90157: { mult: 1.0, mag: 1, fx: 'LIGHT_ATTACK' },
    90155: { sup: 1, buff: { atk: 0.1 }, dur: 30, cd: 30 }, 90156: { sup: 1, buff: { atk: 0.1 }, dur: 30, cd: 30 },
    90299: { sup: 1, heal: 5, buff: { atk: 0.05 }, dur: 6, cd: 15 }, 90308: { sup: 1, heal: 5, buff: { atk: 0.05 }, dur: 6, cd: 15 }, 90298: { sup: 1, hot: 1, cd: 35 },
    // şablon becerileri (fiziksel / büyü / savunma / destek)
    90014: { mult: 1.6, mp: 0, cd: 5, fx: 'BLOOD' }, 90024: { mult: 1.8, fx: '特效-大喷血' }, 90025: { mult: 1.5, both: 1, fx: '特效-火爆炸' },
    90035: { mult: 1.5, both: 1, slow: 2, fx: '特效-冰块碎裂' }, 90036: { mult: 1.5, mag: 1, proj: '特效-火球', fx: '特效-火爆炸' },
    90038: { mult: 1.4, mag: 1, slow: 2, proj: '特效-冰球', fx: '特效-冰块碎裂' },
    90041: { sup: 1, healPct: 0.08, cd: 12 }, 90049: { sup: 1, healPct: 0.12, cd: 12 }, 90057: { sup: 1, healPct: 0.16, cd: 12 },
    90023: { pas: { patk: 0.05, crit: 2 } }, 90053: { pas: { patk: 0.1, crit: 4 } }, 90054: { pas: { patk: 0.15, crit: 6 } },
    90037: { pas: { matk: 0.05, crit: 2 } }, 90051: { pas: { matk: 0.1, crit: 4 } }, 90052: { pas: { matk: 0.15, crit: 6 } },
    90027: { pas: { hp: 0.05 } }, 90055: { pas: { hp: 0.1 } }, 90056: { pas: { hp: 0.15 } },
    90058: { aura: { atk: 0.03 } }, 90059: { aura: { atk: 0.04 } }, 90060: { aura: { atk: 0.05 } },
    90061: { aura: { def: 0.03 } }, 90062: { aura: { def: 0.04 } }, 90063: { aura: { def: 0.05 } },
    90064: { aura: { hpP: 0.03 } }, 90065: { aura: { hpP: 0.04 } }, 90066: { aura: { hpP: 0.05 } },
    90068: { aura: { res: 4 } }, 90069: { aura: { res: 6 } }, 90070: { aura: { res: 8 } }, 90071: { aura: { res: 4 } }, 90072: { aura: { res: 6 } }, 90073: { aura: { res: 8 } },
    90074: { aura: { dodge: 1 } }, 90075: { aura: { dodge: 2 } }, 90076: { aura: { dodge: 3 } },
    90077: { aura: { crit: 1 } }, 90078: { aura: { crit: 2 } }, 90079: { aura: { crit: 3 } },   // isabet: bizde ıska yalnız kaçınmadan; kritik olarak işler
    // sonraki sürümün türleri (APK 1019 açıklamaları)
    a90910: { field: 6, mp: 200, cd: 10, fx: '特效-大喷血' }, a90908: { mult: 1.4, mag: 1, weak: 5, mp: 100, cd: 4, proj: '特效-蓝火球', fx: '特效-冰块碎裂' },
    a91035: { mult: 1.3, nova: 3, mp: 30, cd: 3, fx: '特效-刀光' }, a90080: { sup: 1, dream: 6, mp: 200, cd: 12 },
  };
  async function init() { D = await fetch(vq(Assets.base + 'pets.json')).then(r => r.json()); for (const s of D.species) BY[s.cn] = s; }
  const sp = p => BY[p.sp];
  const tpl = p => D.templates[sp(p).tpl];
  const form = p => sp(p).forms[p.st || 0] || sp(p).forms[0];
  const nm = p => p.name || (sp(p) ? T(form(p).tr, form(p).en) : p.sp);
  const look = p => form(p).look;
  const P = () => Game.P;
  // eski kayıtlar: renk varyantı (v) dönüşüm düzeyine çevrilmez (o kavram yanlıştı); düzey 0, rastgele beceri yok
  const list = () => { const L = P().pets || (P().pets = []); for (const p of L) { if (p.st == null) { p.st = 0; delete p.v; } if (!p.sk) p.sk = []; } return L.filter(p => BY[p.sp]); };
  const active = () => list().find(p => p.uid === P().petOn) || null;
  const mode = () => P().petMode || 'attack';
  const slots = () => P().petSlots || 2;
  const needXp = L => Math.floor(xpNeed(L) * 0.5);
  const skills = p => [sp(p).skill, ...(p.sk || [])];
  // kalıcı beceriler ve haleler (hale hayvanın kendisine de işler)
  function bonus(p) {
    const b = { patk: 0, matk: 0, hp: 0, crit: 0, atk: 0, def: 0, hpP: 0, dodge: 0 };
    for (const k of skills(p)) { const d = SK[k]; if (!d) continue; const o = d.pas || d.aura; if (o) for (const x in o) b[x] = (b[x] || 0) + o[x]; }
    return b;
  }
  function aura(p) { const a = {}; for (const k of skills(p)) { const d = SK[k]; if (d && d.aura) for (const x in d.aura) a[x] = (a[x] || 0) + d.aura[x]; } return a; }
  // nitelikler: şablon oranları APK 1024'ten, dönüşüm çarpanı pets.json stages'ten, seviye ölçeği bizim (oyuncudan zayıf)
  function stats(p) {
    const t = tpl(p), L = p.lv, k = (p.tal || 1) * D.stages[p.st || 0].mult, b = bonus(p);
    return { hp: Math.round((400 + 170 * L) * t.hp_growth / 6400 * k * (1 + b.hp + b.hpP)), mp: Math.round((200 + 60 * L) * t.mp_growth / 6400 * k),
      patk: Math.round((22 + 9 * L) * t.base_phys_atk / 1040 * k * (1 + b.patk + b.atk)), matk: Math.round((22 + 9 * L) * t.base_mag_atk / 1040 * k * (1 + b.matk + b.atk)),
      def: Math.round((20 + 10 * L) * t.base_def / 550 * k * (1 + b.def)), dodge: (t.dodge || 120) / 40 + b.dodge, crit: b.crit, mag: t.cls === 'mag', range: t.cls === 'mag' ? 5 : 1.9 };   // yakın dövüş menzili canavarlarınki gibi (4 yönlü yürüyüşte engelli karelerde takılmasın)
  }
  // ---------------- kuluçka ----------------
  function rollSkills(s, box) {
    const w = RSK[box] || RSK.wood, r = Math.random() * 100; let n = 0, acc = 0; for (let i = 0; i < 4; i++) { acc += w[i]; if (r < acc) { n = i; break; } }
    // havuz: şablonun etkin/kalıcı/hale becerileri; I. kademe daha sık (I 6, II 3, III 1, kademesiz 4); aynı becerinin iki kademesi birlikte gelmez
    const base = k => D.skills[k].tr[0].replace(/ I+$/, ''), wt = k => { const n0 = D.skills[k].tr[0]; return / III$/.test(n0) ? 1 : / II$/.test(n0) ? 3 : / I$/.test(n0) ? 6 : 4; };
    const pool = D.templates[s.tpl].pool.filter(k => k !== s.skill && D.skills[k]), out = [];
    while (out.length < n) {
      const c = pool.filter(k => !out.some(o => base(o) === base(k))); if (!c.length) break;
      let t = Math.random() * c.reduce((a, k) => a + wt(k), 0); for (const k of c) { t -= wt(k); if (t <= 0) { out.push(k); break; } }
    }
    return out;
  }
  function make(s, box) {
    const [a, b] = TAL[box] || TAL.wood;
    const p = { uid: Date.now().toString(36) + Math.floor(Math.random() * 1e6), sp: s.cn, st: 0, sk: rollSkills(s, box), lv: 1, xp: 0, sat: 100, joy: 100, dead: false, tal: +(a + Math.random() * (b - a)).toFixed(3) };
    const S = stats(p); p.hp = S.hp; p.mp = S.mp; return p;
  }
  function hatch(eggId) {
    const it = ITEMS[eggId], s = BY[it.pet.egg]; if (!s) return;
    if (list().length >= slots()) return UI.toast(T(`En fazla ${slots()} evcil hayvan besleyebilirsin (Sözleşme Taşı hakkı artırır).`, `You can keep at most ${slots()} pets (a Contract Stone adds one).`));
    const need = BOX[it.pet.box]; const box = ['31149', '31147', '30166'].find(b => countItem(b) && BOX[ITEMS[b].pet.box] >= need);
    const bn = ITEMS[{ wood: '30166', metal: '31147', magic: '31149' }[it.pet.box]].name;
    if (!box) return UI.toast(T(`${it.name}: ${bn} gerekir.`, `${it.name}: requires a ${bn}.`));
    removeItem(eggId, 1); removeItem(box, 1);
    const p = make(s, ITEMS[box].pet.box); P().pets.push(p);
    const sk = p.sk.length ? p.sk.map(skName).join(', ') : T('yok', 'none');
    SFX.play('finish_task'); UI.toast(T(`${nm(p)} yumurtadan çıktı!`, `${nm(p)} hatched!`));
    UI.log(T(`Yeni evcil hayvan: ${nm(p)} (yetenek ×${p.tal}; rastgele beceriler: ${sk})`, `New pet: ${nm(p)} (talent ×${p.tal}; random skills: ${sk})`), 'q');
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
  function despawn() { if (ent) { Game.ents = Game.ents.filter(e => e !== ent); ent = null; } if (Game.player) Game.player.buffs = Game.player.buffs.filter(b => b.id !== 'petaura'); }
  function spawn() {
    despawn(); const p = active(); if (!p || p.dead || !Game.player || !Game.map) return;
    const pl = Game.player; ent = new PetEnt(p, pl.x - 1, pl.y + 1); Game.ents.push(ent);
  }
  // ölü hayvan 10 dakika sonra kendiliğinden canının %10'uyla dirilir
  function revived(p) { if (p.dead && Date.now() - (p.deadAt || 0) > 600000) { p.dead = false; p.hp = Math.round(stats(p).hp * 0.1); } }
  // ---------------- varlık ----------------
  class PetEnt extends Ent {
    constructor(p, x, y) {
      super('pet', x, y); this.p = p; this.atkT = 1; this.skT = 3; this.cd = {}; this.chatT = rnd(20, 50); this.state = 'idle'; this.dir = 2; this.animT = 0; this.auraT = 0;
      this.setLook();
    }
    setLook() { const L = look(this.p); this.lk = L; this.sp = Game.map.sprite(L); if (!this.sp.ok) Assets.preload([L]).then(() => { if (this.lk === L) this.sp = Game.map.sprite(L); }); }
    get name() { return nm(this.p); }
    draw(ctx, X, Y) {
      if (this.lk !== look(this.p)) this.setLook();   // dönüşümden sonra yeni biçim
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
    if (!m || m.dead) return; const s = S0(), atk = o.both ? (s.patk + s.matk) * 0.6 : o.mag ? s.matk : s.patk;
    const r = dmgCalc(atk, (m.def || 0) * (m.weakT > 0 ? 0.4 : 1), mult, s.crit, o.add || 0); m.hp -= r.d; m.aggro = true; m.state = 'hurt'; m.stateT = 0.15;
    if (o.taunt) { m.foe = ent; m.tauntT = o.taunt; } else if (!o.side && (!m.foe || m.foe.dead)) m.foe = ent;   // hayvan öfkeyi yalnız kendi başlattığı dövüşte ya da öfke çeken beceriyle alır
    if (o.slow) m.slowT = o.slow; if (o.weak) m.weakT = o.weak;
    UI.float(m, (r.crit ? '!' : '') + r.d, '#9fe0ff', r.crit ? 1.1 : 0.9);
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
  const skName = k => D.skills[k] ? T(D.skills[k].tr[0], D.skills[k].en[0]) : String(k);
  const DREAM = [{ atk: 0.15 }, { def: 0.2 }, { spd: 0.25 }, { crit: 10 }, { dr: 0.15 }];
  // tek beceriyi dene; kullanıldıysa true
  function useSkill(k, t) {
    const p = ent.p, d = SK[k], s = S0(); if (!d || d.pas || d.aura) return false;
    const cost = d.mp != null ? d.mp : 20 + p.lv * 2; if (p.mp < cost) return false;
    const pl = Game.player, ps = window.stats ? window.stats() : null, low = ps && pl.hp < ps.hp * 0.7;
    if (d.sup) {   // destek: sahibinin canı azaldıysa ya da dövüşte güçlendirme yoksa
      if ((d.heal || d.hot || d.healPct) && !low) return false;
      if ((d.buff || d.dream) && !d.heal && (pl.buffs.some(b => b.id === 'petbuff') || !(pl.combatT > 0))) return false;
      p.mp -= cost;
      if (d.heal || d.healPct) { const hp = d.heal ? s.matk * d.heal : ps.hp * d.healPct; pl.hp = Math.min(ps.hp, pl.hp + hp); p.hp = Math.min(s.hp, p.hp + (d.heal ? hp : s.hp * d.healPct)); UI.float(pl, '+' + Math.round(hp), '#7bff8a'); }
      if (d.hot) { pl.buffs = pl.buffs.filter(b => b.id !== 'pethot'); pl.buffs.push({ id: 'pethot', buff: { hotT: s.matk / 5 }, t: 30 }); }
      if (d.buff) { pl.buffs = pl.buffs.filter(b => b.id !== 'petbuff'); pl.buffs.push({ id: 'petbuff', buff: Object.assign({}, d.buff), t: d.dur || 30 }); }
      if (d.dream) { pl.buffs = pl.buffs.filter(b => b.id !== 'petbuff'); pl.buffs.push({ id: 'petbuff', buff: Object.assign({}, DREAM[irnd(0, DREAM.length - 1)]), t: d.dream }); }
      Game.fx.push(new Fx('特效-治疗buff', pl.x, pl.y)); UI.float(ent, skName(k), '#ffe070', 0.8); return true;
    }
    if (d.field) {   // Kan Yakan Kalkan: çevredeki dövüşen düşmanlar her saniye can kaybeder, sahibi can kazanır
      if (!Game.ents.some(m => m.kind === 'mob' && !m.dead && m.aggro && Math.hypot(m.x - ent.x, m.y - ent.y) < 3.5)) return false;
      p.mp -= cost; ent.field = { t: d.field, tick: 0 }; Game.fx.push(new Fx(d.fx, ent.x, ent.y)); UI.float(ent, skName(k), '#ffe070', 0.8); return true;
    }
    if (d.nova) {   // Kılıç Fırtınası: kendi çevresine, uzaklık arttıkça az
      const tg = Game.ents.filter(m => m.kind === 'mob' && !m.dead && (m === t || m.aggro) && Math.hypot(m.x - ent.x, m.y - ent.y) <= d.nova); if (!tg.length) return false;
      p.mp -= cost; for (const m of tg) hit(m, d.mult * (1 - 0.5 * Math.hypot(m.x - ent.x, m.y - ent.y) / d.nova), m === t ? {} : { side: 1 });
      Game.fx.push(new Fx(d.fx, ent.x, ent.y)); UI.float(ent, skName(k), '#ffe070', 0.8); return true;
    }
    if (!t || Math.hypot(t.x - ent.x, t.y - ent.y) > (d.mag || d.proj ? 5.5 : 2)) return false;
    p.mp -= cost;
    const add = (d.addHp ? s.hp * d.addHp : 0) + (d.addLv ? p.lv * d.addLv : 0) + (d.addTLv ? t.d.lv * d.addTLv : 0) + (d.addMp ? s.mp * d.addMp : 0);
    const o = { mag: d.mag, both: d.both, add, taunt: d.taunt, slow: d.slow, weak: d.weak };
    // alan becerisi yalnız zaten dövüşen canavarlara vurur ve öfkeyi yalnız asıl hedef çeker (uyuyan sürüyü uyandırmaz)
    const land = () => { if (d.aoe) { for (const m of Game.ents) if (m.kind === 'mob' && !m.dead && (m === t || m.aggro) && Math.hypot(m.x - t.x, m.y - t.y) <= d.aoe) hit(m, d.mult, m === t ? o : Object.assign({}, o, { side: 1 })); } else hit(t, d.mult, o); if (d.fx) Game.fx.push(new Fx(d.fx, t.x, t.y)); };
    if (d.self) ent.buffs = Object.assign({}, d.self, { t: 10 });
    ent.dir = dirOf(t.x - ent.x, t.y - ent.y);
    if (d.proj) shoot(d.proj, ent, t, land, true); else land();
    UI.float(ent, skName(k), '#ffe070', 0.8); return true;
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
    // hale: sahibine sürekli yenilenen güçlendirme
    if ((ent.auraT -= dt) <= 0) { ent.auraT = 1; const a = aura(p); pl.buffs = pl.buffs.filter(b => b.id !== 'petaura'); if (Object.keys(a).length) pl.buffs.push({ id: 'petaura', buff: a, t: 1.6 }); }
    // Kan Yakan Kalkan
    if (ent.field) {
      if ((ent.field.t -= dt) <= 0) ent.field = null;
      else if ((ent.field.tick -= dt) <= 0) {
        ent.field.tick = 1; let n = 0;
        for (const m of Game.ents) if (m.kind === 'mob' && !m.dead && m.aggro && Math.hypot(m.x - ent.x, m.y - ent.y) < 3.5) { hit(m, 0.35, { mag: 1, side: 1 }); n++; }
        if (n) { const ps = window.stats(), h = Math.round(st.matk * 0.3); pl.hp = Math.min(ps.hp, pl.hp + h); UI.float(pl, '+' + h, '#7bff8a', 0.7); }
      }
    }
    // yenilenme, tokluk, mutluluk
    const rg = ent.combatT > 0 ? 0.003 : 0.015; p.hp = Math.min(st.hp, p.hp + st.hp * rg * dt); p.mp = Math.min(st.mp, p.mp + st.mp * rg * 1.3 * dt);
    if ((satT += dt) >= 120) { satT = 0; p.sat = Math.max(0, p.sat - 1); }
    if ((joyT += dt) >= 60) { joyT = 0; if (p.sat < 20) p.joy = Math.max(0, p.joy - 1); }
    if (ent.chatT <= 0) {   // konuşma: türün satırları + bu biçime özgü satır (7. biçim)
      ent.chatT = rnd(45, 100); const f = form(p), L = (LANG === 'en' ? sp(p).chatEn : sp(p).chatTr).concat((LANG === 'en' ? f.sayEn : f.sayTr) || []);
      if (L.length) { ent.say = L[irnd(0, L.length - 1)]; ent.sayT = 4; }
    }
    if (ent.sayT > 0) ent.sayT -= dt;
    if (pl.dead) { ent.state = 'idle'; return; }
    // farklı haritaya geçince ya da çok uzaklaşınca sahibinin yanına ışınlanır
    const dp = Math.hypot(pl.x - ent.x, pl.y - ent.y); if (dp > 14) { ent.x = pl.x - 1; ent.y = pl.y + 1; }
    const hungry = p.sat <= 0 || p.joy <= 20;
    let t = hungry ? null : pickTarget(); if (t && Math.hypot(t.x - pl.x, t.y - pl.y) > 12) t = null; ent.tg = t;
    if (ent.state === 'attack' || ent.state === 'cast') return;
    if (!hungry && ent.skT <= 0 && mode() !== 'idle') {   // beceriler sırayla: doğuştan önce, sonra rastgeleler; her birinin kendi beklemesi
      ent.skT = 1; const now = Game.time;
      for (const k of skills(p)) { const d = SK[k]; if (!d || d.pas || d.aura || (ent.cd[k] || 0) > now) continue; if (mode() === 'support' && !d.sup) continue;
        if (useSkill(k, t)) { ent.cd[k] = now + (d.cd || 8); ent.state = 'cast'; ent.stateT = 0.4; ent.skT = 2; return; } }
    }
    if (t) {
      const d = Math.hypot(t.x - ent.x, t.y - ent.y);
      if (d > st.range) { stepTo(ent, t.x, t.y, RUN * 0.95, dt, true); ent.state = 'move'; }
      else if (ent.atkT <= 0) {
        ent.atkT = 1.5; ent.state = 'attack'; ent.animT = 0; ent.stateT = 0.45; ent.dir = dirOf(t.x - ent.x, t.y - ent.y); ent.combatT = 5;
        later(0.25, () => { if (!ent || t.dead) return; if (st.mag) shoot('特效-火球', ent, t, () => hit(t, 1, { mag: 1 }), true); else hit(t, 1); });
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
  // ---------------- dönüşüm (幻化) ----------------
  // Orijinal (yardım metni): ana hayvan, yardımcı hayvanın özünü alarak dönüşür. İkisi de çağrılmamış ve ölü olmamalı.
  // Başarı: ana hayvanın dönüşüm düzeyi +1 (görünüşü ve nitelikleri değişir). Başarısızlık: düzey −1. Yardımcı hayvan her durumda kaybolur.
  // Gereken seviye ve bedel all_petData'dan; başarı olasılıkları bizim (orijinal değerler sunucudaydı).
  const TFBASE = [0, 80, 70, 60, 50, 40, 30, 20];
  const resting = p => !!p && !p.dead && P().petOn !== p.uid;
  function tfInfo(main, mat, aids = []) {
    const r = { ok: false, chance: 0 }; if (!main) return Object.assign(r, { why: T('Ana hayvanı seç.', 'Choose the main pet.') });
    if ((main.st || 0) >= 7) return Object.assign(r, { why: T('En yüksek dönüşüm düzeyinde.', 'Already at the highest transformation level.') });
    const nx = (main.st || 0) + 1, S = D.stages[nx]; Object.assign(r, { next: nx, need: S.lv, cost: S.cost });
    if (!resting(main)) return Object.assign(r, { why: T('Ana hayvan dinleniyor olmalı (geri çağır; ölüyse dirilt).', 'The main pet must be resting (dismiss it; revive it if dead).') });
    if (main.lv < S.lv) return Object.assign(r, { why: T(`Gereken seviye: ${S.lv}`, `Required level: ${S.lv}`) });
    if (!mat) return Object.assign(r, { why: T('Yardımcı hayvanı seç.', 'Choose the helper pet.') });
    if (mat.uid === main.uid) return Object.assign(r, { why: T('Yardımcı hayvan başka olmalı.', 'The helper must be another pet.') });
    if (!resting(mat)) return Object.assign(r, { why: T('Yardımcı hayvan dinleniyor olmalı.', 'The helper pet must be resting.') });
    let c = TFBASE[nx] + (mat.sp === main.sp ? 10 : 0) + 5 * (mat.st || 0);
    for (const id of aids) { const u = ITEMS[id] && ITEMS[id].pet; if (!u) continue; if (u.tf === 'luck') c += u.add; if (u.tf === 'sure' && (main.st || 0) < u.below) c = 100; if (u.tf === 'keep') r.keep = true; }
    return Object.assign(r, { ok: true, chance: Math.min(100, c) });
  }
  function transform(mainUid, matUid, aids = []) {
    const L = list(), main = L.find(x => x.uid === mainUid), mat = L.find(x => x.uid === matUid), aid = aids.filter(id => id && countItem(id) > 0), r = tfInfo(main, mat, aid);
    if (!r.ok) { UI.toast(r.why); return null; }
    if (P().gold < r.cost) { UI.toast(T(`Yeterli altının yok (${r.cost}).`, `Not enough gold (${r.cost}).`)); return null; }
    P().gold -= r.cost; for (const id of aid) removeItem(id, 1); P().pets = P().pets.filter(x => x.uid !== mat.uid);
    const okk = Math.random() * 100 < r.chance, n0 = nm(main);
    if (okk) { main.st = r.next; const s = stats(main); main.hp = s.hp; main.mp = s.mp; SFX.play('finish_task');
      UI.toast(T(`Dönüşüm başarılı! ${n0} → ${nm(main)} (düzey ${main.st})`, `Transformation succeeded! ${n0} → ${nm(main)} (level ${main.st})`));
      UI.log(T(`${n0} dönüşüm düzeyi ${main.st}'e ulaştı!`, `${n0} reached transformation level ${main.st}!`), 'q'); }
    else { if (!r.keep && main.st > 0) main.st--; UI.toast(T(`Dönüşüm başarısız. ${r.keep ? 'Soy Rünü düzeyi korudu.' : `Düzey: ${main.st}`}`, `Transformation failed. ${r.keep ? 'The Bloodline Rune kept its level.' : `Level: ${main.st}`}`)); UI.log(T(`${n0}: dönüşüm başarısız.`, `${n0}: transformation failed.`), 'q'); }
    save(); UI.refresh(); return okk;
  }
  // ---------------- beceri aktarma (技能转移) ----------------
  // Orijinal: yalnız aynı türden (şablondan) hayvanlar; ana hayvanın bir rastgele becerisi yardımcının bir rastgele becerisiyle değişir;
  // hangisi olacağı şanstır (Öğrenme / Miras rünleri yuvayı belirler). Yardımcı hayvan kaybolur. Bedel bizim.
  function skInfo(main, mat, runes = []) {
    const r = { ok: false }; if (!main) return Object.assign(r, { why: T('Ana hayvanı seç.', 'Choose the main pet.') });
    if (!mat) return Object.assign(r, { why: T('Yardımcı hayvanı seç.', 'Choose the helper pet.') });
    if (mat.uid === main.uid) return Object.assign(r, { why: T('Yardımcı hayvan başka olmalı.', 'The helper must be another pet.') });
    if (!resting(main) || !resting(mat)) return Object.assign(r, { why: T('İki hayvan da dinleniyor olmalı.', 'Both pets must be resting.') });
    if (sp(main).tpl !== sp(mat).tpl) return Object.assign(r, { why: T('Yalnız aynı türden (fiziksel, büyü, savunma, destek) hayvanlar beceri aktarabilir.', 'Only pets of the same type (physical, magic, defense, support) can transfer skills.') });
    const give = (mat.sk || []).filter(k => !skills(main).includes(k)); if (!give.length) return Object.assign(r, { why: T('Yardımcının, ana hayvanda olmayan rastgele becerisi yok.', 'The helper has no random skill the main pet lacks.') });
    let gs = null, ls = null; for (const id of runes) { const u = ITEMS[id] && ITEMS[id].pet; if (!u || !u.sk) continue; if (u.sk === 'give' && mat.sk[u.slot] && give.includes(mat.sk[u.slot])) gs = u.slot; if (u.sk === 'learn' && main.sk[u.slot]) ls = u.slot; }
    return Object.assign(r, { ok: true, give, gs, ls, cost: 100 + 10 * main.lv });
  }
  function transferSkill(mainUid, matUid, runes = []) {
    const L = list(), main = L.find(x => x.uid === mainUid), mat = L.find(x => x.uid === matUid), rn = runes.filter(id => id && countItem(id) > 0), r = skInfo(main, mat, rn);
    if (!r.ok) { UI.toast(r.why); return null; }
    if (P().gold < r.cost) { UI.toast(T(`Yeterli altının yok (${r.cost}).`, `Not enough gold (${r.cost}).`)); return null; }
    P().gold -= r.cost; for (const id of rn) removeItem(id, 1);
    const k = r.gs != null ? mat.sk[r.gs] : r.give[irnd(0, r.give.length - 1)];
    // yuva: rün yoksa rastgele; 3'ten az rastgele becerisi olan hayvan bazen yeni yuva açar
    const slot = r.ls != null ? r.ls : main.sk.length < 3 && (!main.sk.length || Math.random() < 0.25) ? main.sk.length : irnd(0, main.sk.length - 1);
    const old = main.sk[slot]; main.sk[slot] = k; P().pets = P().pets.filter(x => x.uid !== mat.uid);
    SFX.play('finish_task'); UI.toast(T(`${nm(main)} yeni beceri öğrendi: ${skName(k)}${old ? ` (${skName(old)} yerine)` : ''}`, `${nm(main)} learned ${skName(k)}${old ? ` (replacing ${skName(old)})` : ''}`));
    UI.log(T(`Beceri aktarma: ${nm(main)} ← ${skName(k)}`, `Skill transfer: ${nm(main)} ← ${skName(k)}`), 'q');
    save(); UI.refresh(); return k;
  }
  // eşya kullanımı (çanta): kuluçka, mama, iksir, diriltme, sözleşme taşı, iç öz
  function useItem(id) {
    const it = ITEMS[id], u = it.pet; if (!u) return false;
    if (u.egg) { hatch(id); return true; }
    if (u.box) { UI.toast(T('Kuluçka kutusu: çantadaki bir yumurtayı kullanınca kendiliğinden kullanılır.', 'Incubator: used automatically when you use an egg from your bag.')); return true; }
    if (u.tf || u.sk) { UI.toast(T('Dönüşüm/beceri aktarma eşyası: Evcil hayvan penceresinin Dönüşüm bölümünde ya da Büyülü Canavar Ustası\'nda kullanılır.', "Transformation/skill transfer aid: used in the pet window's Transform panel or at the Magic Beast Master.")); return true; }
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
  const fam = L => String(L).replace(/^(怪物-[^-]+|[^-]+)(-.*)?$/, '$1');
  function dropEgg(m) {
    if (!D) return; const info = Game.mobInfo(m.name); if (!info) return; const f = fam(info[1]);
    const s = D.species.find(x => !x.apk && fam(x.forms[0].look) === f); if (!s) return;
    const ch = m.d.rank === 2 ? 0.25 : m.d.rank ? 0.03 : 0.004; if (Math.random() < ch) { addItem(s.egg, 1, true); UI.toast(T(`Ganimet: ${ITEMS[s.egg].name}!`, `Loot: ${ITEMS[s.egg].name}!`)); UI.log(T(`Ganimet: ${ITEMS[s.egg].name}`, `Loot: ${ITEMS[s.egg].name}`), 'q'); }
  }
  // ---------- GM komutları ----------
  const BOXI = { wood: '30166', metal: '31147', magic: '31149' };
  const AIDS = ['30164', '30730', '31234', '30731', '30749', '30023', '30750', '30751', '30752', '30753'];
  const cur = () => active() || list()[0];
  const GM = {
    egg(cn) { const s = BY[cn]; if (!s) return; addItem(s.egg, 1, true); addItem(BOXI[s.box], 1, true); UI.toast(T(`${ITEMS[s.egg].name} + kutu verildi; çantadan kullan.`, `${ITEMS[s.egg].name} + incubator given; use it from your bag.`)); },
    give(cn) { const s = BY[cn]; if (!s) return; if (list().length >= slots()) P().petSlots = list().length + 1; addItem(s.egg, 1, true); addItem('31149', 1, true); hatch(s.egg); },
    level() { const p = cur(); if (!p) return UI.toast(T('Evcil hayvanın yok.', 'No pet.')); p.lv = P().lv; p.xp = 0; const st = stats(p); p.hp = st.hp; p.mp = st.mp; p.dead = false; save(); UI.toast(`${nm(p)} ${T('Sv', 'Lv')} ${p.lv}`); },
    care() { for (const p of list()) { const st = stats(p); p.dead = false; p.hp = st.hp; p.mp = st.mp; p.sat = 100; p.joy = 100; } if (!active() && list()[0]) summon(list()[0].uid); save(); UI.toast(T('Bütün hayvanlar dirildi, doydu, iyileşti.', 'All pets revived, fed and healed.')); },
    items() { for (const [id, n] of [['30022', 20], ['30021', 10], ['30755', 10], ['30025', 5], ['30595', 2], ['30006', 3], ['30166', 3], ['31147', 3], ['31149', 3]]) addItem(id, n, true); UI.toast(T('Evcil hayvan eşyaları verildi.', 'Pet items given.')); },
    hungry() { const p = active(); if (p) { p.sat = 0; p.joy = 15; UI.toast(T('Hayvan acıktı (savaşmaz).', 'Pet is hungry (won\'t fight).')); } },
    clear() { P().pets = []; P().petOn = null; despawn(); save(); UI.toast(T('Bütün hayvanlar silindi.', 'All pets removed.')); },
    // dönüşüm ağacı: etkin hayvanın düzeyini değiştir (n yoksa bir sonraki; 7'den sonra 0)
    stage(n) { const p = cur(); if (!p) return UI.toast(T('Evcil hayvanın yok.', 'No pet.')); p.st = n != null ? clamp(+n, 0, 7) : ((p.st || 0) + 1) % 8; const s = stats(p); p.hp = s.hp; p.mp = s.mp; save(); UI.refresh(); UI.toast(`${nm(p)} · ${T('dönüşüm', 'transform')} ${p.st}/7`); },
    skills() { const p = cur(); if (!p) return UI.toast(T('Evcil hayvanın yok.', 'No pet.')); p.sk = []; for (let i = 0; i < 6 && p.sk.length < 3; i++) for (const k of rollSkills(sp(p), 'magic')) if (p.sk.length < 3 && !p.sk.includes(k)) p.sk.push(k);
      save(); UI.refresh(); UI.toast(T('Rastgele beceriler: ', 'Random skills: ') + (p.sk.map(skName).join(', ') || '-')); },
    // dönüşüm denemesi için: dönüşüm eşyaları + 2 yardımcı hayvan (etkin hayvanla aynı tür) + 20000 altın
    tf() { const p = cur(); if (!p) return UI.toast(T('Evcil hayvanın yok.', 'No pet.')); for (const id of AIDS) addItem(id, 3, true); P().gold += 20000;
      if (P().pets.length + 2 > slots()) P().petSlots = P().pets.length + 2; for (let i = 0; i < 2; i++) { const q = make(sp(p), 'magic'); q.lv = p.lv; const s = stats(q); q.hp = s.hp; q.mp = s.mp; P().pets.push(q); }
      save(); UI.refresh(); UI.toast(T('Dönüşüm eşyaları, 2 yardımcı hayvan ve 20000 altın verildi.', 'Transformation aids, 2 helper pets and 20000 gold given.')); },
  };
  function setMode(md) { P().petMode = md; save(); }
  function release(uid) { const L = P().pets || [], i = L.findIndex(x => x.uid === uid); if (i < 0) return; if (P().petOn === uid) dismiss(); L.splice(i, 1); save(); UI.refresh(); }
  return { GM, init, hatch, summon, dismiss, spawn, update, hurt, onKill, useItem, dropEgg, setMode, release, stats, nm, look, sp, form, tpl, skills, skName, list, active, get ent() { return ent; },
    MODES, MODEN, slots, needXp, revived, tfInfo, transform, skInfo, transferSkill, resting, AIDS, SK, get D() { return D; } };
})();
