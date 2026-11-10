// Orijinal ekran tanımlarıyla çizilen pencereler (tuval üzerinde). Şimdilik: Çanta (FORM_BAG).
'use strict';

const Win = (() => {
  let cur = null, opt = {}, hits = [], pressed = null, pressT = 0;
  // çanta durumu
  const B = { cat: 0, page: 0, sel: null, detail: true, sure: false, assign: false };
  const CATS = [50774, 50775, 50776, 50777];
  const slotIds = () => Forms.get('bag').c.filter(c => c.t === 8 && c.ev.includes('OnFocus')).sort((a, b) => (a.s[0].r[1] - b.s[0].r[1]) || (a.s[0].r[0] - b.s[0].r[0]));
  const quickIds = () => Forms.get('bag').c.filter(c => c.t === 8 && c.ev.includes('OnDrop')).sort((a, b) => a.s[0].r[0] - b.s[0].r[0]);
  const PAGES = [51668, 51669, 51670, 51674];

  function open(name, o = {}) { cur = name; opt = o; B.sel = null; B.sure = false; B.assign = false; B.page = 0; if (o.cat != null) B.cat = o.cat; SFX.play('menu_appear', 0.5); if (name === 'bag') questFlag('openBag'); }
  function close() { cur = null; opt = {}; }
  const isOpen = () => !!cur;

  function bagItems() {
    const P = Game.P;
    if (B.cat === 3) { const qi = []; for (const q of QUESTS) { const st = P.quests[q.id]; if (st && q.item && st.n) qi.push({ quest: q.item, n: st.n }); } return qi; }
    return P.bag.filter(b => { const it = ITEMS[b.id]; if (!it) return false; const c = it.slot ? 0 : (it.use || it.growth) ? 1 : 2; return c === B.cat; });
  }
  function drawIcon(ctx, it, x, y, s = 26) { const im = Forms.img; const I = uiImgAny(it); if (I.complete && I.naturalWidth) ctx.drawImage(I, x, y, s, s); }
  const icache = {};
  function uiImgAny(it) { const k = `icon_res_${it.ik || 'item'}_${it.icon}`; let I = icache[k]; if (!I) { I = new Image(); I.src = `${Assets.base}ui/${k}.png`; icache[k] = I; } return I; }

  function draw(ctx, vw, VH) {
    if (!cur) return; hits = [];
    ctx.fillStyle = 'rgba(0,0,0,.5)'; ctx.fillRect(0, 0, vw, VH);
    if (cur === 'bag') drawBag(ctx, vw, VH); else if (cur === 'role') drawRole(ctx, vw, VH);
    if (pressed && performance.now() - pressT > 160) pressed = null;
  }
  function drawBag(ctx, vw, VH) {
    const P = Game.P, f = Forms.get('bag'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2);
    const items = bagItems(), slots = slotIds(), quick = quickIds(), per = slots.length, pages = Math.max(1, Math.ceil(items.length / per));
    if (B.page >= pages) B.page = pages - 1;
    const selIt = B.sel && ITEMS[B.sel] && countItem(B.sel) ? ITEMS[B.sel] : null; if (!selIt) B.sel = null;
    const slotMap = new Map(slots.map((c, i) => [c.id, i])), quickMap = new Map(quick.map((c, i) => [c.id, i]));
    Forms.draw(ctx, 'bag', ox, oy, {
      hide: c => c.id === 51661 || (PAGES.includes(c.id) && PAGES.indexOf(c.id) >= Math.max(pages, 1)),
      state: c => {
        if (pressed === c.id) return 1;
        if (PAGES.includes(c.id)) return PAGES.indexOf(c.id) === B.page ? 1 : 0;
        if (slotMap.has(c.id)) { const e = items[B.page * per + slotMap.get(c.id)]; return e && e.id && e.id === B.sel ? 1 : 0; }
        if (quickMap.has(c.id)) return B.assign ? 1 : 0;
        return 0;
      },
      after: (c, x, y, w, h) => {
        if (slotMap.has(c.id)) {
          const e = items[B.page * per + slotMap.get(c.id)]; if (!e) return;
          if (e.quest) { const I = uiImgAny({ icon: Q_ICONS[e.quest] || 1125 }); if (I.complete && I.naturalWidth) ctx.drawImage(I, x + 5, y + 5, 26, 26); }
          else { const it = ITEMS[e.id]; if (it.slot && canEquip(it)) ctx.globalAlpha = 0.45; drawIcon(ctx, it, x + 5, y + 5); ctx.globalAlpha = 1; }
          if (e.n > 1) Forms.label(ctx, String(e.n), x + 4, y + 22, 28, 10, '#fff', 'right', 9);
        } else if (quickMap.has(c.id)) {
          const sl = P.quick[2 + quickMap.get(c.id)]; if (!sl) return;
          if (sl[0] === 's') { const sk = CLS[P.cls].skills[+sl.slice(1)]; if (sk) drawIcon(ctx, { ik: sk.ik || 'skill', icon: sk.icon }, x + 5, y + 5); }
          else { const id = sl.slice(2), it = ITEMS[id]; if (it) { drawIcon(ctx, it, x + 5, y + 5); Forms.label(ctx, String(countItem(id)), x + 4, y + 22, 28, 10, '#fff', 'right', 9); } }
        } else if (c.id === 52402) Forms.label(ctx, String(P.gold), x, y, w, h, '#ffe070', 'left', 11);
        else if (c.id === 52120) Forms.label(ctx, `${P.bag.length}/100`, x, y, w, h, '#e8e0d0', 'left', 10);
      },
    });
    // dokunma alanları: form denetimleri
    for (const c of f.c) if (c.g === -1 && c.s.length && c.id !== 50771 && c.id !== 50772) { const r = c.s[0].r; hits.push({ id: c.id, x: ox + r[0], y: oy + r[1], w: r[2], h: r[3] }); }
    // sol menü: kategoriler, sağ menü: işlemler
    const L = Forms.drawGroup(ctx, 'bag', 5, ox - 80, oy + 10, { state: c => CATS.indexOf(c.id) === B.cat ? 1 : 0 });
    const act = selIt ? (selIt.slot ? 'Giy' : selIt.growth ? 'Aç' : selIt.use ? 'Kullan' : '') : '';
    const Rm = Forms.drawGroup(ctx, 'bag', 7, ox + f.w + 2, oy + 10, {
      hide: c => c.id === 52793 || c.id === 52093 || (c.id === 52400 && !opt.shop),
      state: c => pressed === c.id || (c.id === 52336 && B.detail) || (c.id === 51672 && B.assign) || (c.id === 52337 && B.sure) ? 1 : 0,
      text: c => c.id === 52400 && selIt ? `Sat (+${selIt.sell || 1})` : c.id === 52337 && B.sure ? 'Emin misin?' : undefined,
    });
    for (const m of Rm) if (m.c.id === 50773) Forms.label(ctx, act || '—', m.x, m.y, m.w, m.h, act ? '#ffe070' : '#777', 'center', 12);
    for (const m of L.concat(Rm)) hits.push({ id: m.c.id, x: m.x, y: m.y, w: m.w, h: m.h });
    // ayrıntı kutusu (orijinal pencere renkleriyle)
    if (selIt && B.detail) {
      const lines = [[selIt.name, '#ffd870', 12]];
      if (selIt.slot) { lines.push([`${SLOTS.find(s => s[0] === selIt.slot)[1]} · ${selIt.cls ? TR.cls[selIt.cls] : 'Tüm sınıflar'}`, '#d8d0c0', 10]); lines.push([`Gereken seviye: ${selIt.lv}`, P.lv < selIt.lv ? '#ff6050' : '#d8d0c0', 10]); for (const k in selIt.st) lines.push([`${STATN[k] || k} +${selIt.st[k]}`, '#8cf07a', 10]); const why = canEquip(selIt); if (why) lines.push([why, '#ff6050', 10]); }
      else if (selIt.desc) lines.push([selIt.desc, '#d8d0c0', 10]);
      lines.push([`Satış: ${selIt.sell || 1} altın`, '#c8b070', 10]);
      const bw = 150, bh = lines.length * 14 + 10, bx = Math.max(2, ox - 80 - bw - 4 > 0 ? ox - 80 : 2), by = oy + 10 + 4 * 46 + 8;
      const X = Math.max(2, ox - 80 - 0), W = Math.min(bw, 160);
      panel(ctx, X - (W - 79), by, W, bh);
      lines.forEach(([t, c, s], i) => Forms.label(ctx, t, X - (W - 79) + 5, by + 5 + i * 14, W - 10, 14, c, 'left', s));
    }
    if (B.assign) Forms.label(ctx, 'Alttaki bir kısayol yuvasına dokun', ox, oy + f.h + 2, f.w, 14, '#ffe070', 'center', 11);
  }
  function panel(ctx, x, y, w, h) { ctx.fillStyle = 'rgba(0,0,0,.8)'; ctx.fillRect(x, y, w, h); ctx.strokeStyle = '#9f998f'; ctx.lineWidth = 1; ctx.strokeRect(x + 0.5, y + 0.5, w - 1, h - 1); ctx.strokeStyle = '#4b4547'; ctx.strokeRect(x + 1.5, y + 1.5, w - 3, h - 3); }

  function tap(x, y) {
    if (!cur) return false;
    let h = null; for (const r of hits) if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) { h = r; if (r.id !== 'frame' && r.w < 200) break; }
    if (!h) { close(); return true; }
    pressed = h.id; pressT = performance.now();
    if (cur === 'bag') tapBag(h.id); else if (cur === 'role') tapRole(h.id);
    return true;
  }
  let lastTap = { id: null, t: 0 };
  function tapBag(id) {
    const P = Game.P, slots = slotIds(), quick = quickIds(), per = slots.length, items = bagItems();
    const si = slots.findIndex(c => c.id === id), qi = quick.findIndex(c => c.id === id);
    if (id !== 52337) B.sure = false;
    if (id === 52696) return close();
    if (CATS.includes(id)) { B.cat = CATS.indexOf(id); B.page = 0; B.sel = null; SFX.play('skill_pageflip'); return; }
    if (PAGES.includes(id)) { B.page = PAGES.indexOf(id); SFX.play('skill_pageflip'); return; }
    if (id === 52397) { B.page = Math.max(0, B.page - 1); return; }
    if (id === 50806) { B.page = Math.min(Math.max(0, Math.ceil(items.length / per) - 1), B.page + 1); return; }
    if (si >= 0) {
      const e = items[B.page * per + si]; SFX.play('menusel', 0.6);
      if (!e || e.quest) { B.sel = null; return; }
      const now = performance.now();
      if (B.sel === e.id && lastTap.id === e.id && now - lastTap.t < 450) { useItem(e.id); lastTap.id = null; return; }   // çift dokunuş: kullan / giy
      B.sel = e.id; lastTap = { id: e.id, t: now }; return;
    }
    if (qi >= 0) { if (B.sel && (ITEMS[B.sel].use)) { P.quick[2 + qi] = 'i:' + B.sel; B.assign = false; SFX.play('repair', 0.5); save(); } return; }
    if (!B.sel) return;
    const it = ITEMS[B.sel];
    if (id === 50773) { useItem(B.sel); return; }
    if (id === 52400 && opt.shop) { sellItem(B.sel); return; }
    if (id === 51672) { if (it.use) B.assign = !B.assign; else UI.toast('Yalnızca iksirler kısayola konabilir.'); return; }
    if (id === 52336) { B.detail = !B.detail; return; }
    if (id === 52337) { if (it.quest) return; if (!B.sure) { B.sure = true; return; } removeItem(B.sel, countItem(B.sel)); B.sure = false; UI.log(`${it.name} yok edildi.`); save(); return; }
  }
  // ---------------- Karakter ekranı (FORM_ROLEPROP): sayfa 0 özellikler, sayfa 1 ekipman ----------------
  const R = { page: 0, sel: null };
  const RTABS = [50386, 50387];                       // sol menü: Özellik, Ekipman
  const RSLOT = { 52281: 'head', 52282: 'neck', 52283: 'body', 52284: 'weap', 52285: 'belt', 52286: 'glove', 52287: 'ring', 52288: 'shoe' };
  let rolePairs = null;
  function roleValues() {
    const P = Game.P, p = Game.player, s = stats(), C = CLS[P.cls];
    return { '昵称': P.name, '种族': TR.race[P.race], '等级': String(P.lv), '称号': '-', '体力': `${Math.ceil(p.hp)}/${s.hp}`, '物攻': String(C.melee ? s.atk : Math.round(s.atk * 0.3)), '防御': String(s.def),
      '闪避': s.dodge + '%', '释放': Math.round(100 + s.spd * 100) + '%', '圣抗': String(s.res), '火抗': String(s.res), '职业': TR.cls[P.cls], '经验': `${P.xp}/${xpNeed(P.lv)}`, '公会': '-',
      '法力': `${Math.floor(p.mp)}/${s.mp}`, '魔攻': String(C.melee ? 0 : s.atk), '命中': (95 + Math.min(5, s.crit)) + '%', '暴击': (8 + s.crit) + '%', '韧性': s.dr + '%', '暗抗': String(s.res), '冰抗': String(s.res) };
  }
  function drawRole(ctx, vw, VH) {
    const P = Game.P, f = Forms.get('role'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - 322) / 2);
    if (!rolePairs) { // her etiketin yanındaki değer alanını bul
      rolePairs = {}; const labs = f.c.filter(c => c.pg === 0 && c.t === 3 && c.s[0].L[0][11]), vals = f.c.filter(c => c.pg === 0 && c.t === 11);
      for (const l of labs) { const r = l.s[0].r; let best = null, bd = 99; for (const v of vals) { const q = v.s[0].r, d = Math.abs(q[1] - r[1]) + Math.abs(q[0] - (r[0] + 48)) * 0.2; if (d < bd && q[0] > r[0]) { bd = d; best = v; } } if (best) rolePairs[best.id] = l.s[0].L[0][11].trim(); }
    }
    const V = R.page === 0 ? roleValues() : null, selId = R.sel && P.eq[R.sel], selIt = selId && ITEMS[selId];
    Forms.draw(ctx, 'role', ox, oy, {
      page: R.page, hide: c => c.id === 52600 || c.id === 52603,
      text: c => (c.pg === 0 && c.t === 3 && c.s[0].r[2] !== 75) ? '' : undefined,
      state: c => pressed === c.id || (RSLOT[c.id] && RSLOT[c.id] === R.sel) ? 1 : 0,
      after: (c, x, y, w, h) => {
        if (V && c.pg === 0 && c.t === 3 && c.s[0].r[2] !== 75) { const k = c.s[0].L[0][11].trim(); Forms.label(ctx, Forms.T[k] || k, x + 8, y, 72, h, '#e6cf89', 'left', 10); Forms.label(ctx, V[k], x + 80, y, 74, h, '#ffffff', 'left', 11); }
        if (R.page === 1 && RSLOT[c.id]) { const id = P.eq[RSLOT[c.id]], it = id && ITEMS[id]; if (it) drawIcon(ctx, it, x + 5, y + 5); }
      },
    });
    for (const c of f.c) if (c.g === -1 && c.s.length && (c.pg === -1 || c.pg === R.page) && c.id !== 50812 && c.id !== 50841 && c.t !== 3 && c.t !== 11) { const r = c.s[0].r; hits.push({ id: c.id, x: ox + r[0], y: oy + r[1], w: r[2], h: r[3] }); }
    if (R.page === 1) { // alt bilgi paneli (grup 4) ve seçili ekipmanın bilgisi
      const bp = f.c.find(c => c.id === 50813); Forms.drawCtrl(ctx, bp, 0, ox, oy + 253);
      const slotName = R.sel ? SLOTS.find(s => s[0] === R.sel)[1] : null;
      if (selIt) { Forms.label(ctx, `${slotName}: ${selIt.name}`, ox + 10, oy + 259, 285, 16, '#ffd870', 'left', 12);
        Forms.label(ctx, Object.entries(selIt.st || {}).map(([k, v]) => `${tx(STATN[k] || k)} +${v}`).join('   '), ox + 10, oy + 277, 285, 14, '#8cf07a', 'left', 11);
        Forms.label(ctx, `${tx('Gereken seviye: ' + selIt.lv)}`, ox + 10, oy + 293, 285, 14, '#d8d0c0', 'left', 10); }
      else Forms.label(ctx, R.sel ? `${slotName}: ${tx('Boş yuva')}` : 'Bir ekipman yuvasına dokun.', ox + 10, oy + 268, 285, 16, '#d8d0c0', 'left', 11);
    }
    const L = Forms.drawGroup(ctx, 'role', 5, ox - 80, oy + 10, { hide: c => !RTABS.includes(c.id), state: c => RTABS.indexOf(c.id) === R.page ? 1 : 0 });
    const Rm = Forms.drawGroup(ctx, 'role', 7, ox + f.w + 2, oy + 10, { page: R.page, hide: c => R.page === 0 || c.id === 52042, state: c => pressed === c.id ? 1 : 0 });
    for (const m of L.concat(Rm)) hits.push({ id: m.c.id, x: m.x, y: m.y, w: m.w, h: m.h });
    hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: 322 });
  }
  function tapRole(id) {
    const P = Game.P;
    if (id === 52695) return close();
    if (RTABS.includes(id)) { R.page = RTABS.indexOf(id); R.sel = null; SFX.play('skill_pageflip'); return; }
    if (RSLOT[id]) { R.sel = RSLOT[id]; SFX.play('menusel', 0.6); return; }
    if (id === 52043 && R.sel && P.eq[R.sel]) { unequip(R.sel); return; }                 // Çıkar
    if (id === 52044) { close(); open('bag', { cat: 0 }); return; }                         // Değiştir: çantayı ekipman sekmesinde aç
  }
  return { open, close, isOpen, draw, tap, get cur() { return cur; } };
})();
