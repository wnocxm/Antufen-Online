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

  function open(name, o = {}) { cur = name; opt = o; if (name === 'npc') { D.q = null; SFX.play('request', 0.6); } if (name === 'task') { K.sel = null; K.sure = false; } if (name === 'menu') M.page = 0; if (name === 'shop') { H.tab = 0; H.sel = null; H.off = 0; } B.sel = null; B.sure = false; B.assign = false; B.page = 0; if (o.cat != null) B.cat = o.cat; SFX.play('menu_appear', 0.5); if (name === 'bag') questFlag('openBag'); }
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
    if (cur === 'bag') drawBag(ctx, vw, VH); else if (cur === 'role') drawRole(ctx, vw, VH); else if (cur === 'npc') drawNpc(ctx, vw, VH); else if (cur === 'task') drawTask(ctx, vw, VH); else if (cur === 'menu') drawMenu(ctx, vw, VH); else if (cur === 'skill') drawSkill(ctx, vw, VH); else if (cur === 'shop') drawShop(ctx, vw, VH); else if (cur === 'dead') drawDead(ctx, vw, VH);
    if (cur === 'sys') drawSys(ctx, vw, VH); else if (cur === 'map') drawMap(ctx, vw, VH);
    if (HUB.some(h => h[0] === cur) || cur === 'hub') drawHub(ctx, vw, VH);
    if (pressed && performance.now() - pressT > 160) pressed = null;
  }
  // ---------------- Karakter menüsü: ekranın solunda sekmeler; pencereler arasında geçiş ----------------
  const HUB = [['role', 'Karakter'], ['bag', 'Çanta'], ['skill', 'Beceri'], ['task', 'Görev'], ['map', 'Harita'], ['sys', 'Ayarlar']];
  function drawHub(ctx, vw, VH) {
    const x = 2, w = 72, h = 38, y0 = Math.round((VH - HUB.length * h) / 2);
    ctx.fillStyle = 'rgba(0,0,0,.72)'; ctx.fillRect(x, y0, w, HUB.length * h);
    HUB.forEach(([k, n], i) => { const y = y0 + i * h, on = k === cur, pr = pressed === 'hub:' + k;
      if (on || pr) { ctx.fillStyle = 'rgba(188,0,0,.38)'; ctx.fillRect(x + 1, y + 1, w - 2, h - 2); }
      ctx.fillStyle = '#686868'; ctx.fillRect(x, y, w, 1); ctx.fillStyle = '#000'; ctx.fillRect(x, y + h - 1, w, 1); ctx.fillRect(x, y, 1, h); ctx.fillRect(x + w - 1, y, 1, h);
      Forms.label(ctx, n, x, y, w, h, on ? '#ffffff' : '#e6cf89', 'center', 12); hits.push({ id: 'hub:' + k, x, y, w, h }); });
  }
  // standart orijinal çerçeve (çantanın 307x239 çerçevesi) + başlık + kapatma düğmesi
  function stdFrame(ctx, ox, oy, title) {
    Forms.drawCtrl(ctx, Forms.ctrl('bag', 50771), 0, ox, oy); Forms.drawCtrl(ctx, Forms.ctrl('bag', 52696), pressed === 'close' ? 1 : 0, ox, oy);
    Forms.label(ctx, title, ox + 4, oy + 13, 262, 20, '#e6cf89', 'center', 12);
    hits.push({ id: 'close', x: ox + 272, y: oy, w: 34, h: 34 }); hits.push({ id: 'frame', x: ox, y: oy, w: 307, h: 250 });
  }
  function rowBtn(ctx, id, x, y, label, value, on) {
    const c = Forms.ctrl('shop', 50509); Forms.drawCtrl(ctx, c, on || pressed === id ? 1 : 0, x - c.s[0].r[0], y - c.s[0].r[1]);
    Forms.label(ctx, label, x + 12, y + 3, 190, 20, on || pressed === id ? '#ffffff' : '#e6cf89', 'left', 12); if (value != null) Forms.label(ctx, value, x + 200, y + 3, 90, 20, '#ffffff', 'right', 12);
    hits.push({ id, x, y, w: 300, h: 33 });
  }
  // ---------------- Ayarlar ----------------
  let sysSure = false;
  function drawSys(ctx, vw, VH) {
    const ox = Math.round((vw - 307) / 2), oy = Math.round((VH - 260) / 2); stdFrame(ctx, ox, oy, 'Ayarlar');
    const on = tx('Açık'), off = tx('Kapalı');
    rowBtn(ctx, 'sfx', ox + 4, oy + 40, 'Ses efektleri', SFX.opt.sfx ? on : off);
    rowBtn(ctx, 'mus', ox + 4, oy + 75, 'Müzik', SFX.opt.music ? on : off);
    rowBtn(ctx, 'lang', ox + 4, oy + 110, 'Dil / Language', LANG === 'tr' ? 'Türkçe' : 'English');
    rowBtn(ctx, 'title', ox + 4, oy + 145, 'Giriş ekranına dön', null);
    rowBtn(ctx, 'newc', ox + 4, oy + 180, sysSure ? 'Eminim: karakter silinsin' : 'Yeni karakter oluştur', null, sysSure);
    Forms.label(ctx, tx('Oyun otomatik kaydedilir.') + '  ' + tx('Sürüm ' + VER), ox + 8, oy + 222, 290, 14, '#8d8983', 'left', 10);
  }
  function tapSys(id) {
    if (id !== 'newc') sysSure = false;
    if (id === 'sfx') SFX.setSfx(!SFX.opt.sfx); else if (id === 'mus') SFX.setMusic(!SFX.opt.music);
    else if (id === 'lang') { save(); setLang(LANG === 'tr' ? 'en' : 'tr'); }
    else if (id === 'title') { save(); location.reload(); }
    else if (id === 'newc') { if (!sysSure) { sysSure = true; return; } localStorage.removeItem(SAVE_KEY); location.reload(); }
  }
  // ---------------- Dünya haritası (dosyadaki orijinal harita görselleri) ----------------
  const mapImg = {};
  function drawMap(ctx, vw, VH) {
    const W = Math.min(vw - 170, 520), H = 320, ox = Math.round((vw - W) / 2) + 30, oy = Math.round((VH - H) / 2);
    ctx.fillStyle = 'rgba(0,0,0,.8)'; ctx.fillRect(ox, oy, W, H); ctx.strokeStyle = '#9f998f'; ctx.strokeRect(ox + 0.5, oy + 0.5, W - 1, H - 1); ctx.strokeStyle = '#4b4547'; ctx.strokeRect(ox + 1.5, oy + 1.5, W - 3, H - 3);
    // iki parça yan yana bir bütün: 2047 (400x752) ve 2048 (480x752)
    const parts = ['UIData_2047', 'UIData_2048'].map(k => mapImg[k] || (mapImg[k] = Object.assign(new Image(), { src: `${Assets.base}ui/${k}.png` })));
    if (parts.every(i => i.complete && i.naturalWidth)) { const tw = 880, th = 752, k = Math.min((W - 12) / tw, (H - 34) / th), mx = ox + (W - tw * k) / 2, my = oy + 24;
      ctx.imageSmoothingEnabled = true; ctx.drawImage(parts[0], mx, my, 400 * k, th * k); ctx.drawImage(parts[1], mx + 400 * k, my, 480 * k, th * k); ctx.imageSmoothingEnabled = false; }
    Forms.label(ctx, `${tx('Dünya Haritası')}  ·  ${tx('Şu an: ' + trName(Game.scene.name))}`, ox + 6, oy + 4, W - 46, 18, '#e6cf89', 'left', 12);
    Forms.drawCtrl(ctx, Forms.ctrl('bag', 52696), pressed === 'close' ? 1 : 0, ox + W - 306, oy - 6);
    hits.push({ id: 'close', x: ox + W - 34, y: oy - 6, w: 34, h: 34 }); hits.push({ id: 'frame', x: ox, y: oy, w: W, h: H });
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
    let h = null; for (const r of hits) if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) { if (r.id === 'frame') { if (!h) h = r; } else if (!h || h.id === 'frame' || r.w * r.h < h.w * h.h) h = r; }
    if (!h) { if (cur !== 'dead') close(); return true; }
    pressed = h.id; pressT = performance.now();
    if (typeof h.id === 'string' && h.id.startsWith('hub:')) { const k = h.id.slice(4); SFX.play('skill_pageflip'); if (k !== cur) { close(); open(k); } return true; }
    if (h.id === 'close') { UI.closeAll(); return true; }
    if (cur === 'sys') { tapSys(h.id); return true; } if (cur === 'map' || cur === 'hub') return true;
    if (cur === 'bag') tapBag(h.id); else if (cur === 'role') tapRole(h.id); else if (cur === 'npc') tapNpc(h.id); else if (cur === 'task') tapTask(h.id); else if (cur === 'menu') tapMenu(h.id); else if (cur === 'skill') tapSkill(h.id); else if (cur === 'shop') tapShop(h.id); else if (cur === 'dead') tapDead(h.id);
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
  // yazıyı genişliğe göre satırlara böl
  function wrap(ctx, str, w, size = 11) {
    ctx.font = `${size}px "Noto Sans", sans-serif`; const out = [];
    for (const para of String(str).split('\n')) { let line = ''; for (const word of para.split(' ')) { const t = line ? line + ' ' + word : word; if (ctx.measureText(t).width > w && line) { out.push(line); line = word; } else line = t; } out.push(line); }
    return out;
  }
  // ---------------- NPC konuşması (FORM_NPC_DIALOGUE): üstte söz, altta seçenek satırları ----------------
  const D = { q: null };
  const NROWS = [50734, 50735, 50736, 50737, 50738, 50739];
  function npcOptions() {
    const n = opt.npc, P = Game.P, o = [];
    if (opt.say) return { txt: opt.say, o: [{ t: 'Tamam', a: 'bye' }] };
    let txt = TR.greet[n.cn] || '...';
    if (D.q) {
      const q = D.q, st = questState(q);
      if (st === 'new') { txt = q.text; o.push({ t: q.ok || 'Kabul et', a: 'accept' }, { t: 'Daha sonra', a: 'back' }); }
      else if (st === 'ready' && q.to === n.cn) { txt = q.done; o.push({ t: 'Tamamla', a: 'complete' }); }
      else { txt = q.wait || q.goal; o.push({ t: 'Tamam', a: 'back' }); }
    } else {
      if (SHOPS[n.cn]) o.push({ t: 'Alışveriş', a: 'shop', c: '#ffe070' });
      for (const q of questsFor(n.cn)) { const st = questState(q); o.push({ t: (st === 'ready' ? '? ' : st === 'new' ? '! ' : '… ') + q.title, a: 'q', q, c: st === 'active' ? '#c8c0b0' : '#ffe070' }); }
      const tq = tpQuestOf(n.cn); if (tq) o.push({ t: '✦ Işınlan: ' + trName(Assets.D.scenes[tq.tp[0]].name), a: 'tp', q: tq });
      o.push({ t: 'Hoşça kal', a: 'bye' });
    }
    return { txt, o: o.slice(0, 6) };
  }
  let npcMap = {};
  const GOLD = '#e6cf89';
  function drawNpc(ctx, vw, VH) {
    const f = Forms.get('npc'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2) - 6; let { txt, o } = npcOptions();
    // söz 5 satırlık alana sığmazsa sayfalanır; son sayfaya kadar tek seçenek "Devam"dır (orijinaldeki gibi)
    const lines = wrap(ctx, txt, 276), per = 3, pages = Math.max(1, Math.ceil(lines.length / per)); if (D.key !== txt) { D.key = txt; D.pg = 0; D.focus = 0; }
    if (D.pg < pages - 1) o = [{ t: 'Devam', a: 'next' }];
    if (D.focus >= o.length) D.focus = 0; npcMap = {};
    Forms.draw(ctx, 'npc', ox, oy, { hide: c => NROWS.includes(c.id) && NROWS.indexOf(c.id) >= o.length, state: c => { const i = NROWS.indexOf(c.id); return pressed === c.id || (i >= 0 && i === D.focus) ? 1 : 0; },
      after: (c, x, y, w, h) => { const i = NROWS.indexOf(c.id); if (i >= 0 && i < o.length) { const e = o[i]; npcMap[c.id] = e; Forms.label(ctx, e.t, x + 7, y + 2, 288, 24, i === D.focus ? '#ffffff' : GOLD, 'left', 12); hits.push({ id: c.id, x, y, w, h: 31 }); } } });
    Forms.label(ctx, opt.npc.name, ox + 4, oy + 15, 262, 20, GOLD, 'center', 12);
    lines.slice(D.pg * per, D.pg * per + per).forEach((l, i) => Forms.label(ctx, l, ox + 14, oy + 40 + i * 14, 280, 14, GOLD, 'left', 11));
    const cl = Forms.ctrl('npc', 52688).s[0].r; hits.push({ id: 52688, x: ox + cl[0], y: oy + cl[1], w: cl[2], h: cl[3] }); hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: f.h });
  }
  function tapNpc(id) {
    if (id === 52688) return UI.closeAll();
    const e = npcMap[id]; if (!e) return; const n = opt.npc; D.focus = NROWS.indexOf(id);
    if (e.a === 'next') { D.pg++; D.focus = 0; return; }
    if (e.a === 'bye') return UI.closeAll();
    if (e.a === 'q') { D.q = e.q; return; }
    if (e.a === 'back') { D.q = null; return; }
    if (e.a === 'shop') { UI.openShop(n.cn); return; }
    if (e.a === 'tp') { UI.closeAll(); setTimeout(() => questTeleport(e.q), 300); return; }
    if (e.a === 'accept') { const q = D.q; acceptQuest(q); D.q = null; UI.closeAll(); if (q.tp) { setTimeout(() => questTeleport(q), 400); return; } if (q.type === 'talk' && q.to === n.cn) Game.P.quests[q.id].ready = true; return; }   // görev alınınca pencere kapanır
    if (e.a === 'complete') { const q = D.q; completeQuest(q); D.q = null; return; }
  }
  // ---------------- Görev listesi (FORM_TASK) ----------------
  const K = { sel: null, sure: false, detail: false };
  const KROWS = [50555, 50556, 50557, 50558, 50559, 50816, 50817];
  function drawTask(ctx, vw, VH) {
    const P = Game.P, f = Forms.get('task'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2), act = QUESTS.filter(q => P.quests[q.id]);
    if (K.sel && !P.quests[K.sel]) K.sel = null; if (!K.sel && act.length) K.sel = act[0].id;
    const selQ = K.sel && QBY[K.sel];
    Forms.draw(ctx, 'task', ox, oy, { hide: c => c.t === 5 || c.id === 52574, state: c => pressed === c.id ? 1 : 0 });
    // liste alanı çerçevenin içinde, başlık şeridinin altında başlar
    KROWS.slice(0, 6).forEach((id, i) => { const q = act[i]; if (!q) return; const c = Forms.ctrl('task', id), st = P.quests[q.id], x = ox + c.s[0].r[0], y = oy + 36 + c.s[0].r[1];
      Forms.drawCtrl(ctx, c, pressed === id || q.id === K.sel ? 1 : 0, ox, oy + 36);
      Forms.label(ctx, q.title, x + 8, y + 3, 215, 22, '#e6cf89', 'left', 12); Forms.label(ctx, st.ready ? 'Tamam' : q.count ? `${st.n}/${q.count}` : '…', x + 226, y + 3, 68, 22, st.ready ? '#8cf07a' : '#ffffff', 'right', 11);
      hits.push({ id, x, y, w: 300, h: 35 }); });
    // çerçeve satırların üstünde 35 piksel başlar: satırlar pencere içine kaydırılır (orijinalde liste alanı çerçevenin içindedir)
    Forms.label(ctx, 'Görev Listesi', ox + 4, oy + 14, 262, 20, '#e6cf89', 'center', 12);
    if (!act.length) Forms.label(ctx, 'Aktif görev yok. Başında ! olan kişilerle konuş.', ox + 10, oy + 100, 288, 20, '#d8d0c0', 'center', 11);
    const bp = Forms.ctrl('task', 50815); Forms.drawCtrl(ctx, bp, 0, ox, oy);
    if (selQ) { const st = P.quests[selQ.id], lines = wrap(ctx, K.detail ? selQ.text : selQ.goal, 288, 10).slice(0, 4);
      lines.forEach((l, i) => Forms.label(ctx, l, ox + 10, oy + 257 + i * 12, 290, 12, '#ffffff', 'left', 10));
      Forms.label(ctx, tx('Teslim') + ': ' + trName(selQ.to), ox + 10, oy + 257 + 48, 290, 12, '#e6cf89', 'left', 10); }
    const Rm = Forms.drawGroup(ctx, 'task', 7, ox + f.w + 2, oy + 10, { page: 0, state: c => pressed === c.id || (c.id === 52573 && K.detail) || (c.id === 52475 && K.sure) ? 1 : 0, text: c => c.id === 52475 && K.sure ? 'Emin misin?' : undefined });
    for (const m of Rm) hits.push({ id: m.c.id, x: m.x, y: m.y, w: m.w, h: m.h });
    const cl = Forms.ctrl('task', 52734).s[0].r; hits.push({ id: 52734, x: ox + cl[0], y: oy + cl[1], w: cl[2], h: cl[3] }); hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: f.h });
  }
  function tapTask(id) {
    const P = Game.P, act = QUESTS.filter(q => P.quests[q.id]);
    if (id !== 52475) K.sure = false;
    if (id === 52734) return UI.closeAll();
    const i = KROWS.indexOf(id); if (i >= 0 && act[i]) { K.sel = act[i].id; SFX.play('menusel', 0.6); return; }
    const q = K.sel && QBY[K.sel]; if (!q) return;
    if (id === 52573) { K.detail = !K.detail; return; }
    if (id === 52476) { UI.closeAll(); questWalk(q); return; }                                   // Yol Bul
    if (id === 52475) { if (!K.sure) { K.sure = true; return; } delete P.quests[q.id]; K.sure = false; K.sel = null; UI.log(`${tx('Görev bırakıldı')}: ${q.title}`); save(); return; }
  }
  // ---------------- Ana menü (FORM_V5_MENU): sayfa 0 kategoriler, alt sayfalar işlevler ----------------
  const M = { page: 0 };
  const MSHOW = { 52219: 1, 52220: 1, 52222: 1, 52228: 1, 52230: 1, 52396: 1, 52233: 1, 52232: 1, 52234: 1, 52244: 1, 52237: 1 };
  function drawMenu(ctx, vw, VH) {
    const f = Forms.get('menu'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2) - 10;
    Forms.draw(ctx, 'menu', ox, oy, { page: M.page, hide: c => (c.t === 0 && c.pg !== -1 && !MSHOW[c.id]) || c.id === 52941 || (c.id === 52336 && M.page === 0), state: c => pressed === c.id ? 1 : 0,
      after: (c, x, y, w, h) => { if (c.id === 52336) Forms.label(ctx, 'Geri', x, y, w, h, '#ffffff', 'center', 11); if (c.t === 0) hits.push({ id: c.id, x, y, w, h }); } });
    Forms.label(ctx, 'Ana Menü', ox + 4, oy + 14, 240, 20, '#e6cf89', 'center', 12);
    hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: f.h });
  }
  function tapMenu(id) {
    const go = k => { UI.closeAll(); UI.open(k); };
    if (id === 52790) return UI.closeAll();
    if (id === 52336) { M.page = 0; return; }
    if (id === 52219) { M.page = 1; return; } if (id === 52220) { M.page = 2; return; } if (id === 52222) { M.page = 4; return; }
    if (id === 52228) return go('char'); if (id === 52230) return go('skill'); if (id === 52396) return go('quest'); if (id === 52233) return go('map');
    if (id === 52232) { const q = QUESTS.find(q => Game.P.quests[q.id]); UI.closeAll(); if (q) questWalk(q); else UI.toast('Aktif görev yok.'); return; }
    if (id === 52234) return go('bag'); if (id === 52244) return go('sys'); if (id === 52237) { save(); location.reload(); }
  }
  // ---------------- Beceri ağacı (FORM_SKILLTREE): solda ağaçlar, ortada 3 sütun, sağda Yükselt/Kısayol/Ayrıntı ----------------
  const S = { tree: 0, sel: null, detail: true, assign: false };
  const STABS = [52931, 52932], SGRID = [[50844, 50845, 50846], [50847, 50848, 50849], [50850, 50851, 50852]], SQUICK = [51706, 51707, 51708, 51709, 51710, 51711];
  function drawSkill(ctx, vw, VH) {
    const P = Game.P, C = CLS[P.cls], f = Forms.get('skill'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - 322) / 2), trees = TREES[P.cls], tree = trees[S.tree];
    const byId = id => C.skills.find(k => k.id === id), cell = {}; for (const [sid, col, row] of tree.cells) cell[SGRID[row][col]] = byId(sid);
    const selSk = S.sel && byId(S.sel);
    Forms.draw(ctx, 'skill', ox, oy, {
      hide: c => c.id === 50866 || c.id === 50307 || (c.t === 8 && !cell[c.id] && !SQUICK.includes(c.id)) || [51702, 51703, 51704, 51705].includes(c.id),
      state: c => pressed === c.id || (cell[c.id] && cell[c.id].id === S.sel) || (SQUICK.includes(c.id) && S.assign) ? 1 : 0,
      text: c => c.id === 50313 ? '' : undefined,
      after: (c, x, y, w, h) => {
        const sk = cell[c.id];
        if (sk) { const r = skRank(sk); if (!r) ctx.globalAlpha = 0.4; drawIcon(ctx, { ik: sk.ik || 'skill', icon: sk.icon }, x + 5, y + 5); ctx.globalAlpha = 1;
          Forms.label(ctx, `${r}/${SK_MAX}`, x - 6, y + 35, 48, 11, r ? '#ffe070' : P.lv < sk.lv ? '#888' : '#ffffff', 'center', 9);
          Forms.label(ctx, sk.name, x - 32, y + 45, 100, 11, r ? '#e8e0d0' : '#999', 'center', 8); hits.push({ id: c.id, x: x - 6, y: y - 2, w: 48, h: 52 }); }
        const qi = SQUICK.indexOf(c.id);
        if (qi >= 0) { const sl = P.quick[qi]; if (sl && sl[0] === 's') { const k = C.skills[+sl.slice(1)]; if (k) drawIcon(ctx, { ik: k.ik || 'skill', icon: k.icon }, x + 5, y + 5); } else if (sl) { const it = ITEMS[sl.slice(2)]; if (it) drawIcon(ctx, it, x + 5, y + 5); } hits.push({ id: c.id, x, y, w, h }); }
      },
    });
    Forms.label(ctx, `${tx('Beceri puanı')}: ${P.sp || 0}`, ox + 4, oy + 14, 262, 20, (P.sp || 0) > 0 ? '#ffe070' : '#e6cf89', 'center', 12);
    const L = Forms.drawGroup(ctx, 'skill', 5, ox - 80, oy + 10, { hide: c => !STABS.includes(c.id), state: c => STABS.indexOf(c.id) === S.tree ? 1 : 0 });
    L.forEach((m, i) => Forms.label(ctx, trees[i].name, m.x, m.y, m.w, m.h, '#ffffff', 'center', 12));
    const Rm = Forms.drawGroup(ctx, 'skill', 7, ox + f.w + 2, oy + 10, { hide: c => c.id === 52485, state: c => pressed === c.id || (c.id === 52586 && S.detail) || (c.id === 51712 && S.assign) ? 1 : 0 });
    for (const m of L.concat(Rm)) hits.push({ id: m.c.id, x: m.x, y: m.y, w: m.w, h: m.h });
    if (selSk && S.detail) {
      const r = skRank(selSk), lines = [[selSk.name + (selSk.pas ? ' ' + tx('(edilgen)') : ''), '#ffd870', 12], [`${tx('Kademe')} ${r}/${SK_MAX}`, '#ffffff', 10]];
      wrap(ctx, selSk.desc || '', 140, 10).forEach(l => lines.push([l, '#d8d0c0', 10]));
      if (!selSk.pas) lines.push([`${selSk.mp} mana · ${selSk.cd} sn`, '#9fc8ff', 10]);
      if (P.lv < selSk.lv) lines.push([`${selSk.lv}. seviye gerekir.`, '#ff6050', 10]);
      const bw = 152, bh = lines.length * 13 + 10, bx = ox - 2 - bw, by = oy + 10 + 2 * 46 + 8; panel(ctx, bx, by, bw, bh);
      lines.forEach(([t, c, sz], i) => Forms.label(ctx, t, bx + 5, by + 5 + i * 13, bw - 10, 13, c, 'left', sz));
    }
    if (S.assign) Forms.label(ctx, 'Alttaki bir kısayol yuvasına dokun', ox, oy + 322 + 2, f.w, 14, '#ffe070', 'center', 11);
    const cl = Forms.ctrl('skill', 52693).s[0].r; hits.push({ id: 52693, x: ox + cl[0], y: oy + cl[1], w: cl[2], h: cl[3] }); hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: 322 });
    S._cell = cell;
  }
  function tapSkill(id) {
    const P = Game.P, C = CLS[P.cls];
    if (id === 52693) return UI.closeAll();
    if (STABS.includes(id)) { S.tree = STABS.indexOf(id); S.sel = null; S.assign = false; SFX.play('skill_pageflip'); return; }
    if (S._cell && S._cell[id]) { S.sel = S._cell[id].id; SFX.play('menusel', 0.6); return; }
    const sk = S.sel && C.skills.find(k => k.id === S.sel);
    const qi = SQUICK.indexOf(id);
    if (qi >= 0) { if (S.assign && sk && !sk.pas && skRank(sk)) { const idx = C.skills.indexOf(sk); P.quick = P.quick.map(q => q === 's' + idx ? null : q); P.quick[qi] = 's' + idx; S.assign = false; SFX.play('repair', 0.5); save(); } return; }
    if (id === 52586) { S.detail = !S.detail; return; }
    if (!sk) return;
    if (id === 50250) { skillUp(sk); return; }
    if (id === 51712) { if (sk.pas) UI.toast('Edilgen beceriler kısayola konmaz.'); else if (!skRank(sk)) UI.toast('Önce beceriyi öğren.'); else S.assign = !S.assign; return; }
  }
  // ---------------- Dükkân (FORM_STORE): solda sekmeler, ortada liste (simge, ad, fiyat), sağda Satın Al / Sat / Ayrıntı ----------------
  const H = { tab: 0, sel: null, off: 0, detail: true, acc: 0 };
  const HTABS = [50515, 50516, 50517, 50518], HROWS = [50509, 50510, 50511, 50512, 50513, 50514], HROW_H = 35;
  function shopItems() { const P = Game.P, tabs = SHOPS[opt.shop] || [], t = tabs[H.tab]; if (!t) return [];
    return t[1].slice().sort((a, b) => { const A = ITEMS[a], B = ITEMS[b]; return ((A.cls && A.cls !== P.cls) - (B.cls && B.cls !== P.cls)) || (A.lv || 0) - (B.lv || 0) || a - b; }); }
  function drawShop(ctx, vw, VH) {
    const P = Game.P, f = Forms.get('shop'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2), tabs = SHOPS[opt.shop] || [], items = shopItems();
    H.off = Math.max(0, Math.min(H.off, items.length - HROWS.length));
    const selIt = H.sel && ITEMS[H.sel];
    Forms.draw(ctx, 'shop', ox, oy, { hide: c => c.t === 5 || c.t === 11, state: c => pressed === c.id ? 1 : 0 });
    Forms.label(ctx, trName(opt.shop), ox + 4, oy + 13, 262, 20, GOLD, 'center', 12);
    HROWS.forEach((id, i) => { const itId = items[H.off + i]; if (!itId) return; const it = ITEMS[itId], c = Forms.ctrl('shop', id), x = ox + 4, y = oy + 36 + i * HROW_H, on = itId === H.sel, bad = it.slot && canEquip(it);
      Forms.drawCtrl(ctx, c, on || pressed === id ? 1 : 0, x - c.s[0].r[0], y - c.s[0].r[1]);
      if (bad) ctx.globalAlpha = 0.45; drawIcon(ctx, it, x + 9, y, 28); ctx.globalAlpha = 1;
      Forms.label(ctx, it.name + (it.lv ? `  ${tx('Sv' + it.lv)}` : ''), x + 49, y + 3, 180, 20, bad ? '#8a8272' : on ? '#ffffff' : GOLD, 'left', 11);
      Forms.label(ctx, String(it.price), x + 239, y + 3, 50, 20, P.gold < it.price ? '#ff6050' : on ? '#ffffff' : GOLD, 'right', 11);
      hits.push({ id, x, y, w: 300, h: HROW_H }); });
    if (items.length > HROWS.length) { const th = 210 * HROWS.length / items.length, ty = oy + 36 + (210 - th) * H.off / (items.length - HROWS.length); ctx.fillStyle = 'rgba(230,207,137,.6)'; ctx.fillRect(ox + 303, ty, 2, th); }
    const bp = Forms.ctrl('shop', 50742); Forms.drawCtrl(ctx, bp, 0, ox, oy);
    Forms.label(ctx, `${tx('Altın')}: ${P.gold}`, ox + 10, oy + 256, 290, 14, '#ffe070', 'left', 11);
    if (selIt && H.detail) { const st = selIt.st ? Object.entries(selIt.st).map(([k, v]) => `${tx(STATN[k] || k)} +${v}`).join('  ') : (selIt.desc || '');
      Forms.label(ctx, selIt.slot ? `${SLOTS.find(s => s[0] === selIt.slot)[1]} · ${selIt.cls ? TR.cls[selIt.cls] : tx('Tüm sınıflar')} · ${tx('Seviye ' + selIt.lv)}` : selIt.name, ox + 10, oy + 271, 290, 14, '#d8d0c0', 'left', 10);
      Forms.label(ctx, st, ox + 10, oy + 285, 290, 14, '#8cf07a', 'left', 10);
      const why = selIt.slot && canEquip(selIt); if (why) Forms.label(ctx, why, ox + 10, oy + 299, 290, 14, '#ff6050', 'left', 10); else Forms.label(ctx, `${tx('Çantada')}: ${countItem(H.sel)}`, ox + 10, oy + 299, 290, 14, '#8d8983', 'left', 10); }
    else if (!selIt) Forms.label(ctx, 'Listeden bir eşya seç.', ox + 10, oy + 278, 290, 14, '#8d8983', 'left', 11);
    const L = Forms.drawGroup(ctx, 'shop', 5, ox - 80, oy + 10, { hide: c => HTABS.indexOf(c.id) >= tabs.length, state: c => HTABS.indexOf(c.id) === H.tab ? 1 : 0 });
    L.forEach((m, i) => Forms.label(ctx, tabs[i][0], m.x, m.y, m.w, m.h, '#ffffff', 'center', 12));
    const RB = [[50751, 'Satın Al'], [50752, 'Sat'], [50753, 'Ayrıntı']];
    const Rm = Forms.drawGroup(ctx, 'shop', 7, ox + f.w + 2, oy + 10, { hide: c => !RB.some(r => r[0] === c.id), state: c => pressed === c.id || (c.id === 50753 && H.detail) ? 1 : 0 });
    Rm.forEach(m => Forms.label(ctx, RB.find(r => r[0] === m.c.id)[1], m.x, m.y, m.w, m.h, '#ffffff', 'center', 12));
    for (const m of L.concat(Rm)) hits.push({ id: m.c.id, x: m.x, y: m.y, w: m.w, h: m.h });
    const cl = Forms.ctrl('shop', 52701).s[0].r; hits.push({ id: 52701, x: ox + cl[0], y: oy + cl[1], w: cl[2], h: cl[3] }); hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: f.h });
  }
  let shopTap = { id: null, t: 0 };
  function tapShop(id) {
    if (id === 52701) return UI.closeAll();
    if (HTABS.includes(id)) { H.tab = HTABS.indexOf(id); H.sel = null; H.off = 0; SFX.play('skill_pageflip'); return; }
    const i = HROWS.indexOf(id);
    if (i >= 0) { const it = shopItems()[H.off + i]; if (!it) return; const now = performance.now(); if (H.sel === it && shopTap.id === it && now - shopTap.t < 450) { buyItem(it, 1); shopTap.id = null; return; } H.sel = it; shopTap = { id: it, t: now }; SFX.play('menusel', 0.6); return; }
    if (id === 50753) { H.detail = !H.detail; return; }
    if (id === 50752) { const sh = opt.shop; close(); open('bag', { shop: sh }); return; }          // Sat: çantayı satış kipinde aç
    if (id === 50751) { if (!H.sel) return UI.toast('Listeden bir eşya seç.'); buyItem(H.sel, 1); return; }
  }
  // liste kaydırma (parmakla sürükleme)
  function drag(dy) { if (cur !== 'shop') return; H.acc += dy; while (H.acc <= -HROW_H) { H.off++; H.acc += HROW_H; } while (H.acc >= HROW_H) { H.off--; H.acc -= HROW_H; } if (H.off < 0) H.off = 0; }
  // ---------------- Ölüm ekranı (FORM_DEADSELECT): üstte mesaj, altta seçenek satırları ----------------
  function drawDead(ctx, vw, VH) {
    const f = Forms.get('dead'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - 226) / 2), P = Game.P;
    const home = P.home || ((P.done[80003] || P.quests[80003]) ? ['120005'] : null), where = home ? trName(Assets.D.scenes[home[0]].name) : trName(Game.scene.name);
    const opts = [{ t: `${tx('Yeniden doğ')}: ${where}`, id: 52040 }];
    Forms.draw(ctx, 'dead', ox, oy, { hide: c => c.t === 5 && !opts.some(o => o.id === c.id), state: c => c.t === 5 ? 1 : 0, text: () => '' });
    Forms.label(ctx, 'Öldün', ox + 10, oy + 8, 280, 20, '#ff5040', 'center', 14);
    Forms.label(ctx, 'Savaşta yenildin. Canının ve mananın yarısıyla yeniden doğacaksın.', ox + 10, oy + 28, 280, 16, GOLD, 'center', 10);
    for (const o of opts) { const r = Forms.ctrl('dead', o.id).s[0].r; Forms.label(ctx, o.t, ox + r[0] + 7, oy + r[1] + 2, 288, 24, '#ffffff', 'left', 12); hits.push({ id: o.id, x: ox + r[0], y: oy + r[1], w: r[2], h: r[3] }); }
    hits.push({ id: 'frame', x: ox, y: oy, w: f.w, h: 226 });
  }
  function tapDead(id) { if (id === 52040) { close(); revive(); } }
  return { open, close, isOpen, draw, tap, drag, get cur() { return cur; } };
})();
