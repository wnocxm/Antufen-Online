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
    if (cur === 'bag') drawBag(ctx, vw, VH);
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
    let h = null; for (const r of hits) if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) { h = r; if (r.w < 100) break; }
    if (!h) { close(); return true; }
    pressed = h.id; pressT = performance.now();
    if (cur === 'bag') tapBag(h.id);
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
  return { open, close, isOpen, draw, tap, get cur() { return cur; } };
})();
