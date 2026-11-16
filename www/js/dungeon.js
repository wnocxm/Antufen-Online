// Zindanlar (副本). Ayrıntı: docs/03-istemci.md › Zindanlar.
// Kapılar: alan haritalarındaki geçit tablosuna bağlanmamış geçit bölgeleri (APK geçit tablosu bunları boş bırakmış).
// Her girişte oyuncuya kendi kopyası açılır: normal zindanda kesilen canavar yeniden doğmaz, boss ölünce sandık;
// çıkınca ya da ölünce zindan kapanır. Sınav (练级) zindanları: "sayısız canavar, zayıf saldırı ve savunma" (orijinal pano metni), canavarlar yeniden doğar, giriş sınırı yok.
// Şimdilik tek kişi girer (kullanıcı kararı); grup girişi çevrimiçi grup sistemiyle eklenecek.
'use strict';
const DUNGEONS = [
  { id: 'slf', cn: '试炼森林', lv: 20, lvr: [20, 24], train: true, board: '试炼森林(20级)',
    copies: [{ door: ['120046', 3], scenes: ['120194'] }, { door: ['120040', 9], scenes: ['120275'] }] },
  { id: 'myk', cn: '月夜林地', lv: 30, lvr: [30, 32], daily: 3, board: '普通副本-月夜林地(30级)', boss: '★月夜狼王',
    copies: [{ door: ['120057', 5], scenes: ['120277', '120278'] }, { door: ['120193', 9], scenes: ['120316', '120343'] }] },
];
// pano metinleri (orijinal Çince metinlerin çevirisi)
Object.assign(TR.greet, LANG === 'en' ? {
  '试炼森林(20级)': 'Seasoned adventurers call this thicket the "Trial Forest": it is where their journey truly begins once they reach level 20.',
  '普通副本-月夜林地(30级)': 'On every full-moon night, a mournful wolf howl rises from the silent depths of this forest… Once you reach level 30, you can enter another dungeon of the Contract world: the Moonlit Woodland!',
} : {
  '试炼森林(20级)': 'Tecrübeli maceracılar bu sık ormana "Sınav Ormanı" der; 20. seviyeye gelince yolculuklarının asıl başladığı yer burasıdır.',
  '普通副本-月夜林地(30级)': 'Her dolunay gecesi bu ormanın sessiz derinliklerinden yürek burkan bir kurt uluması yükselir… 30. seviyeye ulaşınca Sözleşme dünyasının bir başka zindanına, Mehtap Korusu\'na girebilirsin!',
});

const Dungeon = (() => {
  const T = (tr, en) => LANG === 'en' ? en : tr;
  const BY_SCENE = {}, BY_DOOR = {};
  for (const d of DUNGEONS) for (const c of d.copies) { BY_DOOR[c.door.join(':')] = [d, c]; for (const s of c.scenes) BY_SCENE[s] = [d, c]; }
  let ready = false;
  // zindan haritalarının seviye aralığı (canavar seviyeleri bundan hesaplanır: monDef)
  function init() { if (ready) return; ready = true; for (const d of DUNGEONS) for (const c of d.copies) for (const s of c.scenes) { const sc = Assets.D.scenes[s]; if (sc) sc.lvr = d.lvr.slice(); } }
  const today = () => new Date().toISOString().slice(0, 10);
  function usedToday(d) { const P = Game.P, g = P.dg; return g && g.day === today() ? g.n[d.id] || 0 : 0; }
  function countEntry(d) { const P = Game.P; if (!P.dg || P.dg.day !== today()) P.dg = { day: today(), n: {} }; P.dg.n[d.id] = (P.dg.n[d.id] || 0) + 1; }
  const of = sid => BY_SCENE[sid] || null;
  const run = () => Game.P && Game.P.dun;
  const dname = d => trName(d.cn);
  // kapının dışındaki varış noktası: kapı bölgesinden sonraki (tür 0) bölge
  async function outside(c) {
    const sc = Assets.D.scenes[c.door[0]], json = await fetch(vq(Assets.base + 'maps/' + sc.map + '.json')).then(r => r.json());
    const r = arrivalNear(json.regions, c.door[1]);
    return r ? [Math.round((r[2] + r[4]) / 2), Math.round((r[3] + r[5]) / 2)] : null;
  }
  // alan haritasındaki kapıya basınca
  function door(region) {
    init(); const hit = BY_DOOR[Game.sceneId + ':' + region]; if (!hit) return false;
    if (Game.warnT > 0) return true; Game.warnT = 3;
    const [d, c] = hit, P = Game.P;
    if (P.lv < d.lv) { UI.toast(T(`${dname(d)}: ${d.lv}. seviyede girilir.`, `${dname(d)}: requires level ${d.lv}.`)); return true; }
    const left = d.daily ? d.daily - usedToday(d) : Infinity;
    if (left <= 0) { UI.toast(T(`${dname(d)}: bugünkü giriş hakkın bitti.`, `${dname(d)}: no entries left today.`)); return true; }
    const info = d.train ? T('Sınav zindanı: canavarlar zayıf ama çok, yeniden doğar.', 'Training dungeon: many weak monsters that respawn.') : T(`Bugün kalan giriş: ${left}/${d.daily}.`, `Entries left today: ${left}/${d.daily}.`);
    Win.ask(`${dname(d)} (${T('Sv', 'Lv')} ${d.lv}+) · ${info} ${T('Girilsin mi?', 'Enter?')}`, () => enter(d, c));
    return true;
  }
  function enter(d, c) {
    const P = Game.P; if (d.daily) countEntry(d);
    P.dun = { id: d.id, copy: d.copies.indexOf(c), cleared: {}, boss: false, t: Date.now() };
    UI.log(T(`Zindana girdin: ${dname(d)}`, `Entered dungeon: ${dname(d)}`), 'q'); SFX.play('accept_task');
    gotoScene(c.scenes[0], Game.scene.name, null, Game.sceneId);
  }
  // zindandan çıkış geçidi (alan haritasına dönen): kapının dışına çık, zindan kapanır
  function exitTo(sid) {
    const h = of(Game.sceneId); if (!h || of(sid)) return false;
    leave(true); return true;
  }
  async function leave(walk) {
    const h = of(Game.sceneId) || (run() && [DUNGEONS.find(x => x.id === run().id), null]); if (!h) return;
    const d = h[0], c = h[1] || d.copies[run() ? run().copy : 0]; Game.P.dun = null;
    if (walk !== 'dead') UI.log(T(`Zindandan çıktın: ${dname(d)}`, `Left dungeon: ${dname(d)}`), 'q');
    const at = await outside(c); Game.transit = true; await loadScene(c.door[0], at); Game.transit = false;
  }
  // harita yüklenince: zindanın içindeysek koşu kaydı olsun (yeniden açılan oyun, GM ışınlanması); dışarıdaysak kapanır
  function onLoad(sid) {
    init(); const P = Game.P, h = of(sid);
    if (h) { if (!P.dun || P.dun.id !== h[0].id) P.dun = { id: h[0].id, copy: h[0].copies.indexOf(h[1]), cleared: {}, boss: false, t: Date.now() }; }
    else if (P.dun) P.dun = null;
  }
  const key = (sid, ei, i) => sid + ':' + ei + ':' + i;
  // normal zindanda kesilmiş canavar bu koşuda yeniden çıkmaz
  function skip(sid, ei, i) { const h = of(sid), R = run(); return !!(h && !h[0].train && R && R.cleared[key(sid, ei, i)]); }
  // canavar değerleri: sınav zindanında zayıf; zindan boss'u tek kişiyle yenilebilir (alan boss'unun ×18 canı yerine ×8, ×1,8 saldırısı yerine ×1,2)
  function tune(m) {
    const h = of(Game.sceneId); if (!h) return; const d = h[0];
    if (d.train) { m.maxHp = m.hp = Math.round(m.hp * 0.7); m.atk = Math.round(m.atk * 0.6); m.def = Math.round(m.def * 0.5); }
    const info = Game.mobInfo(m.name); if (info && info.includes('instance_progress')) m.prog = true;   // orijinal zindan ilerleme boss'u
    if (m.d.rank === 2 || m.prog) { m.maxHp = m.hp = Math.round(m.hp * 8 / 18); m.atk = Math.round(m.atk * 1.2 / 1.8); m.boss = true; }
  }
  function onKill(m) {
    const h = of(Game.sceneId), R = run(); if (!h || !R) return; const d = h[0];
    if (!d.train) { m.respawnT = Infinity; if (m.key) R.cleared[m.key] = 1; }
    // son boss (d.boss; yoksa herhangi bir boss) zindanı tamamlar; ara boss'lar seçkin ganimeti bırakır (killMob)
    if (m.boss && (!d.boss || m.name === d.boss) && !R.boss) { R.boss = true; chest(d, m); }
    save();
  }
  // boss sandığı: altın, seviyeye uygun ekipman, iksir
  function chest(d, m) {
    const P = Game.P, L = m.d.lv, gold = 40 * L; P.gold += gold;
    const got = []; for (const k of [0, 1]) { if (k && Math.random() < 0.5) continue; const g = randomGear(Math.max(1, L + 2)); if (g) { addItem(g, 1, true); got.push(ITEMS[g].name); } }
    addItem(P.lv > 10 ? 'hp2' : 'hp1', 3);
    SFX.play('finish_task'); Game.fx.push(new Fx('LEVELUP', Game.player.x, Game.player.y));
    UI.toast(T(`${dname(d)}: zindan tamamlandı!`, `${dname(d)}: dungeon cleared!`));
    UI.log(T(`Zindan sandığı: ${gold} altın`, `Dungeon chest: ${gold} gold`) + (got.length ? ', ' + got.join(', ') : ''), 'q');
    later(1.5, () => Win.ask(T(`${dname(d)}: zindan tamamlandı! Zindandan çıkılsın mı?`, `${dname(d)}: dungeon cleared! Leave the dungeon?`), () => leave(true)));
  }
  // ölünce: kapının dışında dirilir, zindan kapanır
  function onRevive() { if (!of(Game.sceneId)) return false; UI.log(T('Zindanda öldün; kapının dışında dirildin.', 'You died in the dungeon and revived outside the gate.'), 'q'); leave('dead'); return true; }
  return { init, door, exitTo, leave, onLoad, skip, key, tune, onKill, onRevive, of, list: DUNGEONS, usedToday };
})();
