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

  let modal = null;
  function ask(text, onYes) { modal = { k: 'yesno', text, onYes }; SFX.play('menu_appear', 0.4); }
  function askNum(title, max, onOk, unit) { modal = { k: 'num', title, max: Math.max(1, max), n: 1, onOk, unit }; SFX.play('menu_appear', 0.4); }
  function buyAsk(id) {
    const it = ITEMS[id], P = Game.P, can = Math.floor(P.gold / it.price);
    if (can < 1) return UI.toast('Yeterli altının yok.');
    if (it.slot) return ask(`${it.name}: ${it.price} ${tx('altın')}. ${tx('Satın alınsın mı?')}`, () => buyItem(id, 1));   // ekipman tek tek
    askNum(it.name, Math.min(999, can), n => buyItem(id, n), it.price);   // yığılabilen her eşya: adet sorulur
  }
  function sellAsk(id) {   // birden çok varsa satarken de adet sorulur
    const it = ITEMS[id], n = countItem(id); if (!it) return;
    if (n <= 1 || it.slot) return sellItem(id);
    askNum(it.name, n, k => sellItem(id, k), it.sell || Math.max(1, Math.floor((it.price || 0) / 10)));
  }
  // ---- adet girişi: sayı alanına dokununca telefonda sayı klavyesi (HTML kutusu), bilgisayarda rakam tuşları doğrudan ----
  let numBound = false;
  const numBox = () => document.getElementById('numin'), numInp = () => document.getElementById('numv');
  function numApply() { const m = modal, v = parseInt(numInp().value, 10); if (m && m.k === 'num' && v > 0) m.n = clamp(v, 1, m.max); }
  function numClose() { const b = numBox(); if (b && !b.classList.contains('hidden')) { numApply(); b.classList.add('hidden'); numInp().blur(); } }
  function numEdit() {
    const m = modal; if (!m || m.k !== 'num' || !numBox()) return;
    if (!numBound) { numBound = true; const i = numInp();
      i.addEventListener('input', numApply);
      i.addEventListener('keydown', e => { e.stopPropagation(); if (e.key === 'Enter') numClose(); else if (e.key === 'Escape') { numBox().classList.add('hidden'); i.blur(); } });
      document.getElementById('numok').addEventListener('click', numClose); i.addEventListener('blur', () => setTimeout(numClose, 0)); }
    document.getElementById('numt').textContent = `${tx('Adet')} (1-${m.max})`; const i = numInp(); i.max = m.max; i.value = m.n;
    numBox().classList.remove('hidden'); i.focus(); i.select();
  }
  // bilgisayar: adet penceresi açıkken rakamlar sayıyı yazar, Enter onaylar, Esc kapatır (oyun kısayollarına gitmez)
  function key(e) {
    const m = modal; if (!m) return false;
    if (m.k === 'num') {
      if (/^[0-9]$/.test(e.key)) { m.typed = ((m.typed || '') + e.key).replace(/^0+/, '').slice(0, 4); m.n = clamp(parseInt(m.typed || '1', 10), 1, m.max); return true; }
      if (e.key === 'Backspace') { m.typed = (m.typed || String(m.n)).slice(0, -1); m.n = clamp(parseInt(m.typed || '1', 10), 1, m.max); return true; }
      if (e.key === 'Enter') { modal = null; numClose(); m.onOk(m.n); return true; }
      if (e.key === 'ArrowUp' || e.key === '+') { m.n = Math.min(m.max, m.n + 1); m.typed = ''; return true; }
      if (e.key === 'ArrowDown' || e.key === '-') { m.n = Math.max(1, m.n - 1); m.typed = ''; return true; }
    }
    if (e.key === 'Escape') { modal = null; numClose(); return true; }
    if (m.k === 'yesno' && e.key === 'Enter') { modal = null; m.onYes(); return true; }
    return true;   // açık onay/adet kutusu varken tuşlar oyuna gitmez
  }
  function drawModal(ctx, vw, VH) {
    ctx.fillStyle = 'rgba(0,0,0,.45)'; ctx.fillRect(0, 0, vw, VH); const mh = [];
    if (modal.k === 'yesno') {
      const f = Forms.get('yesno'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2);
      Forms.draw(ctx, 'yesno', ox, oy, { state: c => pressed === 'm' + c.id ? 1 : 0 });
      wrap(ctx, modal.text, f.w - 30, 12).slice(0, 5).forEach((l, i) => Forms.label(ctx, l, ox + 15, oy + 14 + i * 16, f.w - 30, 16, GOLD, 'center', 12));
      for (const [id, t] of [[52786, 'Tamam'], [52788, 'İptal']]) { const r = Forms.ctrl('yesno', id).s[0].r; Forms.label(ctx, t, ox + r[0], oy + r[1], r[2], r[3], '#ffffff', 'center', 12); mh.push({ id: 'm' + id, x: ox + r[0], y: oy + r[1], w: r[2], h: r[3] }); }
    } else {
      const f = Forms.get('selnum'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2);
      Forms.draw(ctx, 'selnum', ox, oy, { hide: c => c.id === 50763 || c.id === 50764, state: c => pressed === 'm' + c.id ? 1 : 0, text: c => c.id === 52791 ? 'Tamam' : c.id === 52792 ? 'İptal' : undefined });
      Forms.label(ctx, modal.title, ox + 10, oy + 14, f.w - 20, 20, GOLD, 'center', 13);
      const nb = Forms.ctrl('selnum', 50761).s[0].r; Forms.label(ctx, String(modal.n), ox + nb[0], oy + nb[1], nb[2], nb[3], '#ffffff', 'center', 16);
      if (modal.unit) Forms.label(ctx, `${tx('Toplam')}: ${modal.n * modal.unit} ${tx('altın')}  ·  ${tx('En fazla')}: ${modal.max}`, ox + 10, oy + 98, f.w - 20, 18, '#d8d0c0', 'center', 11);
      for (const id of [50758, 50759, 50761, 52791, 52792]) { const r = Forms.ctrl('selnum', id).s[0].r; mh.push({ id: 'm' + id, x: ox + r[0], y: oy + r[1], w: r[2], h: r[3] }); }
    }
    modal.hits = mh;
  }
  function tapModal(x, y) {
    const h = (modal.hits || []).find(r => x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h); if (!h) return;
    pressed = h.id; pressT = performance.now(); SFX.play('menusel', 0.6); const m = modal;
    if (h.id === 'm52786') { modal = null; m.onYes(); } else if (h.id === 'm52788' || h.id === 'm52792') { modal = null; numClose(); }
    else if (h.id === 'm50758') { m.n = m.n > 1 ? m.n - 1 : m.max; m.typed = ''; } else if (h.id === 'm50759') { m.n = m.n < m.max ? m.n + 1 : 1; m.typed = ''; }
    else if (h.id === 'm50761') numEdit();   // sayıya dokun: klavyeyle adet yaz
    else if (h.id === 'm52791') { numClose(); modal = null; m.onOk(m.n); }
  }
  function open(name, o = {}) { if (!cur) HUB.y = 0; cur = name; opt = o; if (name === 'map') { WM.mode = 'world'; WM.sel = null; wmData(); } if (name === 'npc') { D.q = null; SFX.play('request', 0.6); } if (name === 'task') { K.sel = null; K.sure = false; } if (name === 'menu') M.page = 0; if (name === 'shop') { H.tab = 0; H.sel = null; H.off = 0; } if (name === 'pet') { const L = Pet.list(), i = L.findIndex(x => x.uid === Game.P.petOn); if (i >= 0) PW.i = i; } if (name === 'petf') { TF.mode = o.mode || 'tf'; TF.main = o.main && Pet.resting(Pet.list().find(x => x.uid === o.main)) ? o.main : null; TF.mat = null; TF.a = [null, null]; } B.sel = null; B.sure = false; B.assign = false; B.page = 0; if (o.cat != null) B.cat = o.cat; SFX.play('menu_appear', 0.5); if (name === 'bag') questFlag('openBag'); }
  function close() { cur = null; opt = {}; modal = null; numClose(); }
  const isOpen = () => !!cur || !!modal;   // tek başına onay kutusu da (ör. zindan girişi) pencere sayılır

  function bagItems() {
    const P = Game.P;
    if (B.cat === 3) { const qi = []; for (const q of QUESTS) { const st = P.quests[q.id]; if (st && q.item && st.n) qi.push({ quest: q.item, n: st.n }); } return qi; }
    return P.bag.filter(b => { const it = ITEMS[b.id]; if (!it) return false; const c = it.slot ? 0 : (it.use || it.growth) ? 1 : 2; return c === B.cat; });
  }
  function drawIcon(ctx, it, x, y, s = 26) { const im = Forms.img; const I = uiImgAny(it); if (I.complete && I.naturalWidth) ctx.drawImage(I, x, y, s, s); }
  const icache = {};
  function uiImgAny(it) { const k = `icon_res_${it.ik || 'item'}_${it.icon}`; let I = icache[k]; if (!I) { I = new Image(); I.src = `${Assets.base}ui/${k}.png`; icache[k] = I; } return I; }

  function draw(ctx, vw, VH) {
    if (!cur) { if (modal) { hits = []; drawModal2(ctx, vw, VH); } return; } hits = [];
    const modern = cur !== 'menu';   // yeni arayüz: oyun ekranı karartılmaz
    if (!modern) { ctx.fillStyle = 'rgba(0,0,0,.5)'; ctx.fillRect(0, 0, vw, VH); }
    if (cur === 'bag') drawBag2(ctx, vw, VH); else if (cur === 'role') drawRole2(ctx, vw, VH); else if (cur === 'npc') drawNpc2(ctx, vw, VH); else if (cur === 'task') drawTask2(ctx, vw, VH); else if (cur === 'menu') drawMenu(ctx, vw, VH); else if (cur === 'skill') drawSkill2(ctx, vw, VH); else if (cur === 'shop') drawShop2(ctx, vw, VH); else if (cur === 'dead') drawDead2(ctx, vw, VH);
    if (cur === 'sys') { drawHub2(ctx, vw, VH); drawSys2(ctx, vw, VH); } else if (cur === 'pet') { drawHub2(ctx, vw, VH); drawPet2(ctx, vw, VH); } else if (cur === 'petf') drawPetF(ctx, vw, VH); else if (cur === 'map') { drawMap(ctx, vw, VH); drawHub2(ctx, vw, VH); }
    if (cur === 'hub') drawHub2(ctx, vw, VH);
    if (modal) drawModal2(ctx, vw, VH);
    if (pressed && performance.now() - pressT > 160) pressed = null;
  }
  // ---------------- Karakter menüsü: ekranın solunda sekmeler; pencereler arasında geçiş ----------------
  const HUB0 = [['role', 'Karakter'], ['bag', 'Çanta'], ['skill', 'Beceri'], ['task', 'Görev'], ['map', 'Harita'], ['sys', 'Ayarlar']];
  function drawHub(ctx, vw, VH) {
    const HUB = isGM() ? HUB0.concat([['gm', 'GM']]) : HUB0;
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
  // ================= Yeni arayüz (Android sürümünün NEW_FORM_* ekranları) =================
  // Ekranlar 320 yüksekliğinde tasarlanmış; ekran yüksekliğine ölçeklenip sol kenara yaslanır: solda kırmızı sekme sütunu (126),
  // ortada parşömen (227), sağda yalnızca bir şey seçiliyken açılan işlem paneli (135).
  let NK = 1, NX = 0, NY = 0, NSX = 0, NSY = 0, NHT = null;
  // o: { x, y: ekran konumu, k: ölçek, oy: ekran tanımındaki boş üst payı (form birimi) }
  function nBegin(ctx, VH, o = {}) { NK = o.k || VH / 320; NX = o.x != null ? o.x : (UI.safeL || 0); NY = o.y || 0; NSX = 0; NSY = -(o.oy || 0); ctx.save(); ctx.translate(NX, NY); ctx.scale(NK, NK); ctx.translate(0, NSY); ctx.imageSmoothingEnabled = true; }
  function nEnd(ctx) { ctx.imageSmoothingEnabled = false; ctx.restore(); NHT = null; }
  // ekranın içine ikinci bir ekran (bilgi kutusu) yerleştirmek için kaydırma
  function nSub(ctx, dx, dy, fn) { ctx.save(); ctx.translate(dx, dy); const sx = NSX, sy = NSY; NSX += dx; NSY += dy; fn(); NSX = sx; NSY = sy; ctx.restore(); }
  const nHit = (id, x, y, w, h) => (NHT || hits).push({ id, x: NX + (x + NSX) * NK, y: NY + (y + NSY) * NK, w: w * NK, h: h * NK });
  const nC = (f, id) => Forms.ctrl(f, id);
  function nDraw(ctx, f, id, st, txt) { const c = nC(f, id); Forms.drawCtrl(ctx, c, st ? 1 : 0, 0, 0, txt); return c.s[0].r; }
  // parşömen üstünde gölgesiz yazı
  function nText(ctx, s, x, y, col, size = 11, align = 'left', w) { ctx.font = `${size}px "Noto Sans", sans-serif`; ctx.textAlign = align; ctx.textBaseline = 'middle'; ctx.fillStyle = col; if (w) ctx.fillText(tx(String(s)), x, y, w); else ctx.fillText(tx(String(s)), x, y); ctx.textBaseline = 'alphabetic'; }
  // sol sütun: arka plan + sekmeler (seçili olan sarı) + kapatma düğmesi
  function nTabs(ctx, f, bgId, ids, labels, active, closeId) {
    nDraw(ctx, f, bgId, 0);
    ids.forEach((id, i) => { if (labels[i] == null) return; const c = nC(f, id), on = i === active || pressed === id, r = nDraw(ctx, f, id, on, tx(labels[i]));
      // bazı ekranlarda sekmenin kendi yazı katmanı yok: yazı aynı yere elle çizilir
      if (!c.s[0].L.some(L => L[0] === 3)) { ctx.font = 'bold 11px "Noto Sans", sans-serif'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillStyle = 'rgba(255,230,170,.55)'; ctx.fillText(tx(labels[i]), r[0] + 54, r[1] + 16.5, 96); ctx.fillStyle = '#1c0a04'; ctx.fillText(tx(labels[i]), r[0] + 54, r[1] + 15.5, 96); ctx.textBaseline = 'alphabetic'; }
      nHit(id, r[0], r[1], r[2], r[3]); });
    if (closeId) { const r = nDraw(ctx, f, closeId, pressed === closeId); nHit(closeId, r[0], r[1], r[2], r[3]); }
    nHit('frame', 0, 0, 126, 320);
  }
  // sağ işlem paneli: [etiket, kimlik] listesi
  function nActions(ctx, f, bgId, btnIds, acts) {
    nDraw(ctx, f, bgId, 0); nHit('frame', 353, 0, 135, 320);
    acts.forEach(([label, key], i) => { const id = btnIds[i]; if (!id) return; const r = nDraw(ctx, f, id, pressed === key, ''); Forms.label(ctx, label, r[0], r[1], r[2], r[3], '#f4ead0', 'center', 11); nHit(key, r[0], r[1], r[2], r[3]); });
  }
  // ---------------- Ana menü (NEW_FORM_V5_MENU): sol sütunda kırmızı düğmeler ----------------
  const HUBB = [50223, 50224, 50225, 50226, 50227, 50228, 50229], HUBS = 43, HUBT = 8, HUBA = 312;   // düğmeler 43 birim arayla; görünen bant HUBT..HUBA
  // Liste 7 düğmeden uzunsa (GM) sayfa gibi aşağı kaydırılır: parmakla sürükle ya da fare tekerleği. HUB.y kaydırma (form birimi), HUB.r ekrandaki alan.
  const HUB = { y: 0, r: null };
  function hubItems() { const L = [['role', 'Karakter'], ['skill', 'Beceri'], ['bag', 'Çanta'], ['pet', 'Evcil'], ['task', 'Görev'], ['map', 'Harita'], ['sys', 'Sistem']]; if (isGM()) L.push(['gm', 'GM']); return L; }
  const hubShown = () => cur === 'sys' || cur === 'pet' || cur === 'map' || cur === 'hub';
  function drawHub2(ctx, vw, VH) {
    nBegin(ctx, VH); const f = 'n_v5_menu', L = hubItems(), max = Math.max(0, (L.length - HUBB.length) * HUBS);
    HUB.y = clamp(HUB.y, 0, max); HUB.r = { x: NX, y: NY, w: 126 * NK, h: 320 * NK, k: NK, max };
    nDraw(ctx, f, 50222, 0); nHit('frame', 0, 0, 126, 320);
    ctx.save(); ctx.beginPath(); ctx.rect(0, HUBT, 126, HUBA - HUBT); ctx.clip();
    L.forEach(([k, n], i) => { const j = Math.min(i, HUBB.length - 1), dy = (i - j) * HUBS - HUB.y, c = nC(f, HUBB[j]), r = c.s[0].r;
      const y0 = Math.max(r[1] + dy, HUBT), y1 = Math.min(r[1] + dy + r[3], HUBA); if (y1 - y0 < 2) return;
      Forms.drawCtrl(ctx, c, k === cur || pressed === 'hub:' + k ? 1 : 0, 0, dy, tx(n)); if (y1 - y0 > 10) nHit('hub:' + k, r[0], y0, r[2], y1 - y0); });
    ctx.restore();
    // daha aşağıda / yukarıda düğme varsa küçük ok
    const arrow = (y, up) => { ctx.fillStyle = 'rgba(255,214,120,.9)'; ctx.beginPath(); ctx.moveTo(57, y); ctx.lineTo(69, y); ctx.lineTo(63, up ? y - 6 : y + 6); ctx.closePath(); ctx.fill(); };
    if (HUB.y < max) arrow(HUBA - 3, false); if (HUB.y > 0) arrow(HUBT + 9, true);
    const r = nDraw(ctx, f, 50230, pressed === 'close'); nHit('close', r[0] - 4, r[1], r[2] + 4, r[3]);
    nEnd(ctx);
  }
  // ---------------- Çanta (NEW_FORM_BAG_2) ----------------
  const B2TABS = [50003, 50004, 50005, 50006, 50049], B2ACT = [50035, 50036, 50037, 50038, 50039, 50040, 50041];
  const B2SLOT = Array.from({ length: 20 }, (_, i) => 50007 + i);
  function bag2Items() {
    const P = Game.P;
    if (B.cat === 3) { const qi = []; for (const q of QUESTS) { const st = P.quests[q.id]; if (st && q.item && st.n) qi.push({ quest: q.item, n: st.n }); } return qi; }
    if (B.cat === 4) return [];
    return P.bag.filter(b => { const it = ITEMS[b.id]; if (!it) return false; return (it.slot ? 0 : (it.use || it.growth || it.pet) ? 1 : 2) === B.cat; });
  }
  function itemLines(it) {
    const P = Game.P, L = [[it.name, '#7a1c08', 12]];
    if (it.slot) { L.push([`${tx(SLOTS.find(s => s[0] === it.slot)[1])} · ${it.cls ? tx(TR.cls[it.cls]) : tx('Tüm sınıflar')} · ${tx('Sv')} ${it.lv}`, P.lv < it.lv ? '#c02010' : '#3a2a14', 10]); L.push([Object.entries(it.st || {}).map(([k, v]) => `${tx(STATN[k] || k)} +${v}`).join('  '), '#1c5a12', 10]); }
    else if (it.desc) L.push([it.desc, '#3a2a14', 10]);
    L.push([`${tx('Satış')}: ${it.sell || 1} ${tx('altın')}`, '#6a4a14', 10]); return L;
  }
  function drawBag2(ctx, vw, VH) {
    nBegin(ctx, VH); const f = 'n_bag_2', P = Game.P, items = bag2Items(), per = 20, pages = Math.max(1, Math.ceil(items.length / per));
    if (B.page >= pages) B.page = pages - 1;
    const selIt = B.sel && ITEMS[B.sel] && countItem(B.sel) ? ITEMS[B.sel] : null; if (!selIt) B.sel = null;
    nDraw(ctx, f, 50042, 0); nHit('frame', 126, 0, 227, 320);
    nTabs(ctx, f, 50000, B2TABS, ['Ekipman', 'Tüketim', 'Genel', 'Görev', 'Binek'], B.cat, null);
    B2SLOT.forEach((id, i) => {
      const e = items[B.page * per + i], r = nDraw(ctx, f, id, e && e.id && e.id === B.sel); nHit(id, r[0] + 3, r[1] + 3, 40, 40);
      if (!e) return;
      if (e.quest) { const I = uiImgAny({ icon: Q_ICONS[e.quest] || 1125 }); if (I.complete && I.naturalWidth) ctx.drawImage(I, r[0] + 7, r[1] + 7, 32, 32); }
      else { const it = ITEMS[e.id]; if (it.slot && canEquip(it)) ctx.globalAlpha = 0.45; drawIcon(ctx, it, r[0] + 7, r[1] + 7, 32); ctx.globalAlpha = 1; }
      if (e.n > 1) Forms.label(ctx, String(e.n), r[0] + 6, r[1] + 5, 30, 12, '#fff', 'left', 10);
    });
    for (const id of [50027, 50028]) { const off = id === 50027 ? B.page === 0 : B.page >= pages - 1; const r = nDraw(ctx, f, id, off); nHit(id, r[0] - 8, r[1] - 4, r[2] + 16, r[3] + 8); }   // gri: gidilecek sayfa yok
    nText(ctx, `${B.page + 1}/${pages}`, 239, 219, '#3a2a14', 11, 'center');
    if (selIt) { // seçili eşyanın bilgisi: alt kutu
      nDraw(ctx, f, 50029, 0); const LC = { '#7a1c08': '#ffd870', '#3a2a14': '#f0e4c8', '#c02010': '#ff8a70', '#1c5a12': '#a8f090', '#6a4a14': '#e0c080' };   // koyu deri zemin: açık renkler
      itemLines(selIt).forEach(([t, c, s], i) => nText(ctx, t, 140, 250 + i * 15, LC[c] || c, s, 'left', 198));
    } else {
      nText(ctx, `${P.bag.length}/100`, 170, 298, '#e8dcc0', 11, 'center'); nDraw(ctx, f, 50045, 0); nText(ctx, String(P.gold), 228, 298, '#ffe070', 11, 'left'); nDraw(ctx, f, 50043, 0);
    }
    if (selIt) {
      const A = [[selIt.slot ? 'Giy' : selIt.growth ? 'Aç' : selIt.use ? 'Kullan' : '—', 'use']];
      if (selIt.use) A.push(['Kısayol', 'quick']); if (opt.shop) A.push([`${tx('Sat')} (+${selIt.sell || 1})`, 'sell']); A.push(['Yok Et', 'del']);
      nActions(ctx, f, 50032, B2ACT, A);
    }
    { const r = nDraw(ctx, f, 50030, pressed === 50030); nHit(50030, r[0] - 4, r[1], r[2] + 4, r[3]); }
    nEnd(ctx);
  }
  function tapBag2(id) {
    const items = bag2Items(), per = 20, si = B2SLOT.indexOf(id);
    if (id === 50030) { close(); open('hub'); return; }
    if (B2TABS.includes(id)) { B.cat = B2TABS.indexOf(id); B.page = 0; B.sel = null; SFX.play('skill_pageflip'); return; }
    if (id === 50027) { B.page = Math.max(0, B.page - 1); return; }
    if (id === 50028) { B.page = Math.min(Math.max(0, Math.ceil(items.length / per) - 1), B.page + 1); return; }
    if (si >= 0) {
      const e = items[B.page * per + si]; SFX.play('menusel', 0.6);
      if (!e || e.quest) { B.sel = null; return; }
      const now = performance.now();
      if (B.sel === e.id && lastTap.id === e.id && now - lastTap.t < 450) { useItem(e.id); lastTap.id = null; return; }   // çift dokunuş: kullan / giy
      B.sel = e.id; lastTap = { id: e.id, t: now }; return;
    }
    if (!B.sel) return; const it = ITEMS[B.sel];
    if (id === 'use') return useItem(B.sel);
    if (id === 'sell' && opt.shop) return sellAsk(B.sel);
    if (id === 'quick') { if (it.use) UI.startAssign('i:' + B.sel, it.name); return; }
    if (id === 'del') { const sid = B.sel; ask(`${it.name}: ${tx('yok edilsin mi?')}`, () => { removeItem(sid, countItem(sid)); B.sel = null; UI.log(`${it.name} yok edildi.`); save(); }); }
  }
  // ---------------- Karakter (NEW_FORM_PLAYER): Özellik ve Ekipman sayfaları ----------------
  const R2TABS = [50084, 50085, 50913, 50087, 50912];
  const R2SLOT = { 50093: 'head', 50095: 'body', 50094: 'weap', 50099: 'shoe', 50096: 'neck', 50098: 'ring', 50100: 'belt', 50097: 'glove' };
  const porImg = {};
  function drawRole2(ctx, vw, VH) {
    nBegin(ctx, VH); const f = 'n_player', P = Game.P, p = Game.player, s = stats(), C = CLS[P.cls];
    const selId = R.sel && P.eq[R.sel], selIt = selId && ITEMS[selId];
    if (R.page === 1) nDraw(ctx, f, 50092, 0); else nDraw(ctx, f, 50083, 0);
    nHit('frame', 126, 0, 227, 320);
    nTabs(ctx, f, 50082, R2TABS, ['Özellik', 'Ekipman', 'Potansiyel', 'Başarım', 'Diğer'], R.page, null);
    if (R.page === 0) {
      const r = nDraw(ctx, f, 50122, 0), k = 'Portrait_' + P.face, I = porImg[k] || (porImg[k] = Object.assign(new Image(), { src: `${Assets.base}ui/${k}.png` }));
      if (I.complete && I.naturalWidth) ctx.drawImage(I, r[0] + 5, r[1] + 5, 59, 59);
      nText(ctx, P.name, 280, 22, '#2a1a0a', 13, 'center', 118); nText(ctx, `${tx(TR.race[P.race])} · ${clsName()}`, 280, 42, '#5a4020', 11, 'center', 118);
      nText(ctx, `${tx('Seviye')} ${P.lv}`, 280, 62, '#7a1c08', 12, 'center', 118);
      const rows = [['Tecrübe', `${P.xp}/${xpNeed(P.lv)}`], ['Can', `${Math.ceil(p.hp)}/${s.hp}`], ['Mana', `${Math.floor(p.mp)}/${s.mp}`], [C.melee ? 'Fiz. Saldırı' : 'Büyü Saldırı', String(s.atk)], ['Savunma', String(s.def)],
        ['Kritik', (8 + s.crit) + '%'], ['Kaçınma', s.dodge + '%'], ['Büyü direnci', String(s.res)], ['Can yenileme', String(s.hpreg)], ['Mana yenileme', String(s.mpreg)], ['Altın', String(P.gold)]];
      rows.forEach(([k2, v], i) => { const y = 96 + i * 19.5; nText(ctx, tx(k2) + ':', 142, y, '#a83018', 12, 'left'); nText(ctx, v, 240, y, '#2a1a0a', 12, 'left', 104); });
    } else if (R.page === 1) {
      for (const [id, sl] of Object.entries(R2SLOT)) {
        const r = nDraw(ctx, f, +id, sl === R.sel); nHit(+id, r[0] + 3, r[1] + 3, 40, 40);
        const eid = P.eq[sl], it = eid && ITEMS[eid]; if (it) drawIcon(ctx, it, r[0] + 8, r[1] + 8, 32);
      }
      const slotName = R.sel ? tx(SLOTS.find(q => q[0] === R.sel)[1]) : null;
      if (selIt) itemLines(selIt).slice(0, 4).forEach(([t, c, sz], i) => nText(ctx, i === 0 ? `${slotName}: ${t}` : t, 142, 256 + i * 14.5, c, sz, 'left', 196));
      else nText(ctx, R.sel ? `${slotName}: ${tx('Boş yuva')}` : tx('Bir ekipman yuvasına dokun.'), 142, 272, '#5a4020', 11, 'left', 196);
    } else nText(ctx, tx('Yakında'), 239, 150, '#5a4020', 13, 'center');
    if (R.page === 1 && R.sel) nActions(ctx, f, 50105, [50106, 50107], selIt ? [['Çıkar', 'uneq'], ['Değiştir', 'swap']] : [['Değiştir', 'swap']]);
    { const r = nDraw(ctx, f, 50104, pressed === 50104); nHit(50104, r[0] - 4, r[1], r[2] + 4, r[3]); }
    nEnd(ctx);
  }
  function tapRole2(id) {
    const P = Game.P;
    if (id === 50104) { close(); open('hub'); return; }
    if (R2TABS.includes(id)) { R.page = R2TABS.indexOf(id); R.sel = null; SFX.play('skill_pageflip'); return; }
    if (R2SLOT[id]) { R.sel = R2SLOT[id]; SFX.play('menusel', 0.6); return; }
    if (id === 'uneq' && R.sel && P.eq[R.sel]) return unequip(R.sel);
    if (id === 'swap') { close(); open('bag', { cat: 0 }); }
  }

  // ---------------- NPC konuşması (NEW_FORM_NPC_DIALOGUE): üstte söz, altında seçenek satırları ----------------
  const N2ROWS = [50289, 50290, 50291, 50292, 50293], R3 = 'AnbufenUI_3_Resource';
  // uzun parşömen: 227x320 zemin, satırlar 370'e kadar indiği için zemin o boya gerilir
  function nLongBg(ctx, h = 373) { const I = Forms.img(7033, R3); if (I.complete && I.naturalWidth) ctx.drawImage(I, 0, 0, 227, h); nHit('frame', 0, 0, 227, h); }
  function nRow(ctx, f, id, on, label, key, col) { const c = nC(f, id), r = c.s[0].r; Forms.drawCtrl(ctx, c, on ? 1 : 0, 0, 0); nText(ctx, label, r[0] + 14, r[1] + 19, on ? '#ffffff' : (col || '#3a1c08'), 12, 'left', 190); nHit(key, r[0], r[1], r[2], 50); }
  function drawNpc2(ctx, vw, VH) {
    nBegin(ctx, VH, { k: VH / 373 }); const f = 'n_npc_dialogue'; let { txt, o } = npcOptions(); o = o.slice(0, 5);
    const lines = wrap(ctx, txt, 196, 11), per = 5, pages = Math.max(1, Math.ceil(lines.length / per)); if (D.key !== txt) { D.key = txt; D.pg = 0; D.focus = 0; }
    if (D.pg < pages - 1) o = [{ t: 'Devam', a: 'next' }];
    if (D.focus >= o.length) D.focus = 0; npcMap = {};
    nLongBg(ctx); nText(ctx, opt.npc.name, 16, 20, '#7a1c08', 12, 'left', 180);
    lines.slice(D.pg * per, D.pg * per + per).forEach((l, i) => nText(ctx, l, 16, 38 + i * 13.5, '#2a1a0a', 11, 'left', 198));
    o.forEach((e, i) => { const id = N2ROWS[i]; npcMap[id] = e; nRow(ctx, f, id, pressed === id || i === D.focus, e.t, id, e.c === '#c8c0b0' ? '#6a5a40' : null); });
    { const r = nDraw(ctx, f, 50294, pressed === 'close'); nHit('close', r[0] + 6, r[1], 36, 36); }
    nEnd(ctx);
  }
  function tapNpc2(id) {
    const e = npcMap[id]; if (!e) return; const n = opt.npc; D.focus = N2ROWS.indexOf(id);
    if (e.a === 'next') { D.pg++; D.focus = 0; return; }
    if (e.a === 'bye') return UI.closeAll();
    if (e.a === 'q') { D.q = e.q; return; }
    if (e.a === 'back') { D.q = null; return; }
    if (e.a === 'petf') { open('petf', { mode: e.m }); return; }
    if (e.a === 'say') { opt.say = e.s; return; }
    if (e.a === 'shop') { UI.openShop(n.cn); return; }
    if (e.a === 'tp') { UI.closeAll(); setTimeout(() => questTeleport(e.q), 300); return; }
    if (e.a === 'dtp') { UI.closeAll(); setTimeout(() => e.d.go(), 300); return; }
    if (e.a === 'accept') { const q = D.q; acceptQuest(q); D.q = null; UI.closeAll(); if (q.tp) { setTimeout(() => questTeleport(q), 400); return; } if (q.type === 'talk' && q.to === n.cn) Game.P.quests[q.id].ready = true; return; }
    if (e.a === 'complete') { const q = D.q; completeQuest(q); D.q = null; if (e.ch != null && q.choice) opt.say = q.choice[e.ch][1]; return; }
  }
  // ---------------- Görev listesi (NEW_FORM_TASK): solda görev satırları, sağda seçili görevin bilgisi ----------------
  const K2ROWS = [50274, 50275, 50276, 50277, 50278], R2 = 'AnbufenUI_2_Resource';
  // iki liste: Aktif (alınmış görevler) ve Alınabilir (şimdi alınabilenler + 5 seviye içinde açılacaklar)
  function taskList() {
    const P = Game.P;
    if (K.mode !== 'avail') return QUESTS.filter(q => P.quests[q.id]);
    return QUESTS.filter(q => { const st = questState(q); return st === 'new' || (st === 'soon' && questMinLv(q) <= P.lv + 5); })
      .sort((a, b) => (questState(a) === 'new' ? 0 : 1) - (questState(b) === 'new' ? 0 : 1) || questMinLv(a) - questMinLv(b) || a.id - b.id);
  }
  function drawTask2(ctx, vw, VH) {
    nBegin(ctx, VH, { oy: 42 }); const f = 'n_task', P = Game.P, list = taskList(), avail = K.mode === 'avail';
    if (K.sel && !list.some(q => q.id === K.sel)) K.sel = null; if (!K.sel && list.length) K.sel = list[0].id;
    if (K.off == null || K.off > Math.max(0, list.length - 5)) K.off = 0;
    const selQ = K.sel && QBY[K.sel];
    nDraw(ctx, f, 50787, 0); nHit('frame', 0, 42, 227, 320);
    list.slice(K.off, K.off + 5).forEach((q, i) => { const id = K2ROWS[i], c = nC(f, id), r = c.s[0].r, on = q.id === K.sel || pressed === id, st = questState(q);
      Forms.drawCtrl(ctx, c, on ? 1 : 0, 0, 0); nText(ctx, (avail ? (st === 'new' ? '! ' : '') : '') + q.title, r[0] + 12, r[1] + 17, on ? '#ffffff' : st === 'soon' ? '#7a6a50' : '#3a1c08', 12, 'left', 190);
      let sub, col = '#6a4a14';
      if (avail) { sub = st === 'soon' ? `${tx('Sv')} ${questMinLv(q)}` : trName(q.giver); col = st === 'soon' ? '#a03010' : '#3a2a14'; }
      else { const a = P.quests[q.id]; sub = a.ready ? tx('Tamam') : q.count ? `${a.n}/${q.count}` : '…'; col = a.ready ? '#1c6a12' : '#6a4a14'; }
      nText(ctx, sub, r[0] + 204, r[1] + 35, col, 10, 'right', 150); nHit(id, r[0], r[1], r[2], 50); });
    if (!list.length) { nText(ctx, avail ? 'Şu an alınabilecek görev yok.' : 'Aktif görev yok.', 113, 150, '#5a4020', 12, 'center', 200); if (!avail) nText(ctx, 'Alınabilir listesine bak.', 113, 168, '#5a4020', 11, 'center', 200); }
    // alt kısım: liste seçimi ve sayfa
    const nA = QUESTS.filter(q => P.quests[q.id]).length, nN = QUESTS.filter(q => questState(q) === 'new').length;
    for (const [k, label, x] of [['act', `${tx('Aktif')} (${nA})`, 10], ['avail', `${tx('Alınabilir')} (${nN})`, 116]]) {
      const on = (K.mode || 'act') === k, I = Forms.img(7019, R2); if (I.complete && I.naturalWidth) { ctx.globalAlpha = on ? 1 : 0.6; ctx.drawImage(I, 0, 0, 84, 24, x, 312, 100, 26); ctx.globalAlpha = 1; }
      Forms.label(ctx, label, x, 312, 100, 26, on ? '#ffe070' : '#d8d0c0', 'center', 11); nHit('mode:' + k, x, 312, 100, 26); }
    if (list.length > 5) { nText(ctx, `${K.off + 1}-${Math.min(list.length, K.off + 5)} / ${list.length}  ▾`, 113, 348, '#5a4020', 10, 'center'); nHit('more', 40, 340, 150, 20); }
    { const r = nDraw(ctx, f, 50280, pressed === 'close'); nHit('close', r[0] + 6, r[1], 36, 36); }
    if (selQ) nSub(ctx, 232, 62, () => { const g = 'n_item_info', st = questState(selQ), S = Assets.D.scenes;
      nDraw(ctx, g, 50419, 0); nHit('frame', 0, 9, 227, 250);
      nText(ctx, selQ.title, 18, 36, '#6a0c00', 12.5, 'left', 192);
      const L = [];
      if (avail) { const sid = npcSceneNear(selQ.giver); L.push([`${tx('Veren')}: ${trName(selQ.giver)}${sid ? ' · ' + trName(S[sid].name) : ''}`, '#2a1608']); L.push([`${tx('Seviye')}: ${questMinLv(selQ)}${st === 'soon' ? ' · ' + tx('henüz açılmadı') : ''}`, st === 'soon' ? '#b01808' : '#0c4208']); }
      else L.push([`${tx('Teslim')}: ${trName(selQ.to)}`, '#2a1608']);
      wrap(ctx, selQ.goal, 190, 10).forEach(l => L.push([l, '#0c4208']));
      { const r = selQ.reward, it = rewardItems(selQ).map(([id, n]) => `${ITEMS[id].name}${n > 1 ? ' ×' + n : ''}`);   // orijinaldeki gibi ödül satırı
        wrap(ctx, `${tx('Ödül')}: ${r.xp} ${tx('TP')} · ${r.gold} ${tx('altın')}${it.length ? ' · ' + it.join(', ') : ''}`, 190, 10).forEach(l => L.push([l, '#6a3a00'])); }
      L.push(['', '']);
      wrap(ctx, selQ.text || '', 190, 10).forEach(l => L.push([l, '#1a0f05']));
      L.slice(0, 12).forEach(([l, c], i) => nText(ctx, l, 18, 54 + i * 12.5, c, 10, 'left', 192));
      const B = avail ? [[50423, 'Yol Bul', 'walk']] : [[50423, 'Yol Bul', 'walk'], [50424, 'Bırak', 'drop']];
      for (const [id, label, key] of B) { const r = nDraw(ctx, g, id, pressed === key, ''); Forms.label(ctx, label, r[0], r[1], r[2], r[3], '#f4ead0', 'center', 11); nHit(key, r[0], r[1], r[2], r[3]); } });
    nEnd(ctx);
  }
  function tapTask2(id) {
    const P = Game.P, list = taskList(), i = K2ROWS.indexOf(id);
    if (typeof id === 'string' && id.startsWith('mode:')) { K.mode = id.slice(5); K.sel = null; K.off = 0; SFX.play('skill_pageflip'); return; }
    if (i >= 0 && list[K.off + i]) { K.sel = list[K.off + i].id; SFX.play('menusel', 0.6); return; }
    if (id === 'more') { K.off = K.off + 5 >= list.length ? 0 : K.off + 5; return; }
    const q = K.sel && QBY[K.sel]; if (!q) return;
    if (id === 'walk') { UI.closeAll(); if (K.mode === 'avail') routeToNpc(q.giver); else questWalk(q); return; }
    if (id === 'drop') ask(`${q.title}: ${tx('görev bırakılsın mı?')}`, () => { delete P.quests[q.id]; K.sel = null; UI.log(`${tx('Görev bırakıldı')}: ${q.title}`); save(); });
  }
  // ---------------- Beceri ağacı (NEW_FORM_SKILLTREE), APK'daki gibi: solda 6 sekme (acemi, sınıf, iki uzmanlık, ırk, yaşam); ortada
  // 6 kademeli yuva (orta, sağ, sol, sağ, sol, sağ = ağaç kaydındaki sıra) ve ön koşul çizgileri; yuvada "Öğrenilmedi" ya da "Sv n";
  // sağda seçili becerinin bilgisi + Yükselt / Kısayol; altta beceri puanı ve Puanları Sıfırla (Eğitim Kitabı). Kilitli ağaçlar da görünür.
  const S2TABS = [50396, 50397, 50398, 50399, 50400, 50872], S2SLOT = [50402, 50403, 50404, 50405, 50406, 50407];
  const lifeJobs = () => (SKD && SKD.life.jobs) || [];
  function skillCells(P, tree) {
    const C = CLS[P.cls];
    if (tree.race) return (RACE_SK[P.race] || []).map((sk, i) => ({ sk, i }));
    if (tree.life) return lifeJobs().map((j, i) => ({ job: j, i }));
    return tree.cells.map(([id], i) => ({ sk: C.skills.find(k => k.id === id), i }));
  }
  function drawSkill2(ctx, vw, VH) {
    nBegin(ctx, VH); const f = 'n_skilltree', P = Game.P, trees = TREES[P.cls], tree = trees[S.tree] || trees[0], E = LANG === 'en';
    S._cell = {};
    nDraw(ctx, f, 50408, 0); nHit('frame', 126, 0, 227, 320);
    nTabs(ctx, f, 50394, S2TABS, trees.map(t => t.race ? raceTree()[E ? 'en' : 'tr'] : t.name), S.tree, null);
    const cells = skillCells(P, tree), R = i => nC(f, S2SLOT[i]).s[0].r;
    // bağlantı çizgileri (APK'daki sabit desen: 1→3, 1→4, 3→5, 4→6; hep turuncu). Şartlar verideki ön koşuldan gelir, bilgi panelinde yazar.
    const line = pts => { ctx.lineCap = 'butt'; ctx.lineJoin = 'miter'; for (const [w, c] of [[8, '#7a4a08'], [5, '#ffa400']]) { ctx.strokeStyle = c; ctx.lineWidth = w; ctx.beginPath(); pts.forEach(([x, y], k) => k ? ctx.lineTo(x, y) : ctx.moveTo(x, y)); ctx.stroke(); } };
    if (!tree.race && !tree.life) for (const [i, j] of [[0, 2], [0, 3], [2, 4], [3, 5]]) {
      const a = R(i), b = R(j), ax = a[0] + 23, ay = a[1] + 46, by = b[1] + 23;
      if (Math.abs(ax - (b[0] + 23)) < 3) line([[ax, ay], [ax, b[1]]]);
      else line([[ax, ay], [ax, by], [b[0] < a[0] ? b[0] + 46 : b[0], by]]);
    }
    for (const c of cells) {
      const r0 = R(c.i), x = r0[0], y = r0[1], key = 'sk:' + c.i; S._cell[key] = c;
      Forms.drawCtrl(ctx, nC(f, S2SLOT[c.i]), S.sel === key ? 1 : 0, 0, 0);
      let icon, ik, rank, lock;
      if (c.job) { const t = (P.life && P.life[c.job.cn]) || 0, tier = c.job.tiers[Math.max(0, t - 1)]; icon = tier.icon; ik = tier.ik; rank = t; lock = !t; }
      else { icon = c.sk.icon; ik = c.sk.ik; rank = skRank(c.sk); lock = !rank; }
      drawIcon(ctx, { ik: ik || 'skill', icon }, x + 7, y + 7, 32);
      if (lock) { ctx.fillStyle = 'rgba(0,0,0,.45)'; ctx.fillRect(x + 7, y + 7, 32, 32); }
      ctx.font = '8px "Noto Sans", sans-serif'; ctx.textAlign = 'left'; ctx.textBaseline = 'top';
      if (lock) { ctx.fillStyle = '#ff5a5a'; const w = E ? ['Not', 'Learned'] : ['Öğrenil-', 'medi']; ctx.fillText(w[0], x + 6, y + 9); ctx.fillText(w[1], x + 6, y + 19); }
      else { ctx.fillStyle = '#000'; ctx.fillText((E ? 'Lv' : 'Sv') + rank, x + 9, y + 9); ctx.fillStyle = '#fff'; ctx.fillText((E ? 'Lv' : 'Sv') + rank, x + 8, y + 8); }
      ctx.textBaseline = 'alphabetic';
      nHit(key, x, y, 46, 46);
    }
    // ağacın kök şartı tutmuyorsa (sınıf yükseltmesi, önceki ağaca puan, seçilmiş öbür uzmanlık) yazılır
    const root = cells[0] && cells[0].sk && !tree.race ? skLock(cells[0].sk) : null;
    if (root && root[0] !== 'pre') nText(ctx, root[1], 240, 266, '#a02010', 9, 'center', 200);
    if (tree.life) nText(ctx, T2('Meslekler eğitmenlerden öğrenilir.', 'Professions are learned from trainers.'), 240, 266, '#5a4020', 9, 'center', 200);
    // alt çubuk: beceri puanı + Puanları Sıfırla
    nText(ctx, `${tx('Beceri puanı')}: ${P.sp || 0}`, 205, 299, (P.sp || 0) > 0 ? '#ffe070' : '#e8dcc0', 12, 'center');
    { const r = nDraw(ctx, f, 50430, pressed === 50430, T2('Puanları Sıfırla', 'Reset Points')); nHit(50430, r[0], r[1], r[2], r[3]); }
    const c = S.sel && S._cell[S.sel];
    if (c) {
      const L = [];
      if (c.job) {
        const t = (P.life && P.life[c.job.cn]) || 0, tier = c.job.tiers[Math.max(0, t - 1)];
        nDraw(ctx, f, 50401, 0); nHit('frame', 353, 0, 135, 320);
        L.push([c.job[E ? 'en' : 'tr'], '#7a1c08', 11], [t ? tier[E ? 'en' : 'tr'][0] : T2('Öğrenilmedi', 'Not learned'), '#5a4020', 9.5]);
        wrap(ctx, tier[E ? 'en' : 'tr'][1], 92, 9.5).forEach(l => L.push([l, '#2a1a0a', 9.5]));
        if (t < 5) { L.push([T2('Sonraki kademe:', 'Next tier:'), '#5a4020', 9.5]); wrap(ctx, c.job.tiers[t][E ? 'en' : 'tr'][1], 92, 9.5).forEach(l => L.push([l, '#5a4020', 9.5])); }
        L.slice(0, 20).forEach(([t2, col, sz], i) => nText(ctx, t2, 362, 30 + i * 12.5, col, sz, 'left', 94));
      } else {
        const sk = c.sk, r = skRank(sk), mx = sk.mx || 10;
        if (!sk.race) nActions(ctx, f, 50401, [50410, 50411], [['Yükselt', 'up'], ['Kısayol', 'quick']]); else { nDraw(ctx, f, 50401, 0); nHit('frame', 353, 0, 135, 320); }
        L.push([sk.name, '#7a1c08', 11], [`${tx('Kademe')} ${r}/${mx}${sk.pas ? ' · ' + tx('edilgen') : ''}`, '#5a4020', 9.5]);
        wrap(ctx, skDesc(sk, r), 92, 9.5).forEach(l => L.push([l, '#2a1a0a', 9.5]));
        if (r && r < mx) { const nx = skNextDiff(sk, r); if (nx) L.push([`${T2('Sonraki', 'Next')}: ${nx}`, '#1a3a7a', 9.5]); }
        const lk = skLock(sk); if (lk) wrap(ctx, lk[1], 92, 9.5).forEach(l => L.push([l, '#c02010', 9.5]));
        L.slice(0, 15).forEach(([t2, col, sz], i) => nText(ctx, t2, 362, sk.race ? 30 + i * 12.5 : 118 + i * 12.5, col, sz, 'left', 94));
      }
    }
    { const r = nDraw(ctx, f, 50413, pressed === 50413); nHit(50413, r[0] - 4, r[1], r[2] + 4, r[3]); }
    nEnd(ctx);
  }
  // sonraki kademede değişen sayılar: "20→40, 5→6"
  function skNextDiff(sk, r) {
    const keys = [...(sk.d[LANG === 'en' ? 'en' : 'tr'][1].matchAll(/\{(\w+)\}/g))].map(m => m[1]).filter(k => sk.d.c[k]), out = [];
    const fmt = v => Number.isInteger(v) ? String(v) : String(+v.toFixed(1));
    for (const k of [...new Set(keys)]) { const a = skC(sk, k, r), b = skC(sk, k, r + 1); if (a !== b) out.push(`${fmt(a)}→${fmt(b)}`); }
    return out.join(', ');
  }
  function tapSkill2(id) {
    const P = Game.P, C = CLS[P.cls];
    if (id === 50413) { close(); open('hub'); return; }
    if (S2TABS.includes(id)) { S.tree = S2TABS.indexOf(id); S.sel = null; SFX.play('skill_pageflip'); return; }
    if (id === 50430) { ask(T2('Bütün beceri puanları geri alınsın mı? (Eğitim Kitabı harcanır)', 'Reset all skill points? (uses a Training Book)'), () => skillReset(false)); return; }
    if (S._cell && S._cell[id]) { S.sel = id; SFX.play('menusel', 0.6); return; }
    const c = S.sel && S._cell && S._cell[S.sel], sk = c && c.sk; if (!sk) return;
    if (id === 'up') return skillUp(sk);
    if (id === 'quick') { const i = C.skills.indexOf(sk); if (sk.pas || i < 0) UI.toast('Edilgen beceriler kısayola konmaz.'); else if (!skRank(sk)) UI.toast('Önce beceriyi öğren.'); else UI.startAssign('s' + i, sk.name); }
  }
  // ---------------- Dükkân (NEW_FORM_SHOP): solda sekmeler, ortada liste, altta altın ve Sat; seçilince sağda bilgi ve Satın Al ----------------
  const H2TABS = [50899, 50900, 50901, 50902, 50903], H2ROWS = [50334, 50335, 50336, 50337, 50338];
  function drawShop2(ctx, vw, VH) {
    nBegin(ctx, VH, { oy: 41 }); const f = 'n_shop', P = Game.P, tabs = SHOPS[opt.shop] || [], items = shopItems();
    H.off = Math.max(0, Math.min(H.off, items.length - H2ROWS.length)); const selIt = H.sel && ITEMS[H.sel];
    nDraw(ctx, f, 50332, 0); nHit('frame', 126, 41, 227, 320);
    nTabs(ctx, f, 50327, H2TABS, H2TABS.map((_, i) => tabs[i] ? tabs[i][0] : null), H.tab, null);
    H2ROWS.forEach((id, i) => { const itId = items[H.off + i]; if (!itId) return; const it = ITEMS[itId], c = nC(f, id), x = c.s[0].r[0], y = 49 + i * 53, on = itId === H.sel || pressed === id, bad = it.slot && canEquip(it);
      Forms.drawCtrl(ctx, c, on ? 1 : 0, 0, y - c.s[0].r[1]);
      if (bad) ctx.globalAlpha = 0.45; drawIcon(ctx, it, x + 8, y + 9, 32); ctx.globalAlpha = 1;
      nText(ctx, it.name, x + 49, y + 17, bad ? '#8a7a60' : on ? '#ffffff' : '#3a1c08', 11, 'left', 152);
      nText(ctx, it.lv ? `${tx('Sv')} ${it.lv}` : '', x + 49, y + 34, '#6a5a40', 9.5, 'left'); nText(ctx, String(it.price), x + 200, y + 34, P.gold < it.price ? '#c02010' : '#6a4a14', 11, 'right');
      nHit(id, x, y, 209, 52); });
    if (items.length > H2ROWS.length) { const th = 265 * H2ROWS.length / items.length, ty = 49 + (265 - th) * H.off / (items.length - H2ROWS.length); ctx.fillStyle = 'rgba(90,60,20,.6)'; ctx.fillRect(345, ty, 3, th); }
    nDraw(ctx, f, 50333, 0); nText(ctx, String(P.gold), 163, 340, '#ffe070', 12, 'left');
    { const r = nDraw(ctx, f, 50393, pressed === 'sellmode', ''); Forms.label(ctx, 'Sat', r[0], r[1], r[2], r[3], '#f4ead0', 'center', 11); nHit('sellmode', r[0], r[1], r[2], r[3]); }
    { const r = nDraw(ctx, f, 50356, pressed === 'close'); nHit('close', r[0] - 4, r[1], r[2] + 4, r[3]); }
    if (selIt) nSub(ctx, Math.min(358, (vw - NX) / NK - 229), 70, () => { const g = 'n_shopinfo';
      nDraw(ctx, g, 50365, 0); nHit('frame', 0, 9, 227, 250); drawIcon(ctx, selIt, 19, 29, 32); nText(ctx, selIt.name, 62, 38, '#6a0c00', 12.5, 'left', 150); nText(ctx, `${selIt.price} ${tx('altın')}`, 62, 54, P.gold < selIt.price ? '#b01808' : '#2a1608', 10.5, 'left');
      const L = itemLines(selIt).slice(1); const why = selIt.slot && canEquip(selIt); if (why) L.push([why, '#c02010', 10]); L.push([`${tx('Çantada')}: ${countItem(H.sel)}`, '#5a4020', 10]);
      const DK = { '#3a2a14': '#1a0f05', '#6a4a14': '#2a1608', '#5a4020': '#2a1608', '#1c5a12': '#0c4208', '#c02010': '#b01808' };
      let y = 80; for (const [t, c, sz] of L) for (const l of wrap(ctx, tx(t), 190, sz)) { nText(ctx, l, 18, y, DK[c] || c, sz, 'left', 192); y += 13.5; }
      const r = nDraw(ctx, g, 50369, pressed === 'buy', ''); Forms.label(ctx, 'Satın Al', r[0], r[1], r[2], r[3], '#f4ead0', 'center', 11); nHit('buy', r[0], r[1], r[2], r[3]); });
    nEnd(ctx);
  }
  function tapShop2(id) {
    if (H2TABS.includes(id)) { H.tab = H2TABS.indexOf(id); H.sel = null; H.off = 0; SFX.play('skill_pageflip'); return; }
    const i = H2ROWS.indexOf(id);
    if (i >= 0) { const it = shopItems()[H.off + i]; if (!it) return; const now = performance.now(); if (H.sel === it && shopTap.id === it && now - shopTap.t < 450) { buyAsk(it); shopTap.id = null; return; } H.sel = it; shopTap = { id: it, t: now }; SFX.play('menusel', 0.6); return; }
    if (id === 'sellmode') { const sh = opt.shop; close(); open('bag', { shop: sh }); return; }
    if (id === 'buy' && H.sel) buyAsk(H.sel);
  }
  // ---------------- Ölüm ekranı ve Ayarlar: söz alanı + seçenek satırları (NEW_FORM_DEADSELECT) ----------------
  const DS = [50447, 50448, 50449, 50450, 50451];
  function drawDead2(ctx, vw, VH) {
    const k = VH / 373; nBegin(ctx, VH, { k, x: Math.round((vw - 227 * k) / 2) }); const f = 'n_deadselect', P = Game.P;
    const home = P.home || ((P.done[80003] || P.quests[80003]) ? ['120005'] : null), where = home ? trName(Assets.D.scenes[home[0]].name) : trName(Game.scene.name);
    nLongBg(ctx, 170); nText(ctx, 'Öldün', 113, 26, '#a81808', 15, 'center');
    wrap(ctx, tx('Savaşta yenildin. Canının ve mananın yarısıyla yeniden doğacaksın.'), 196, 11).forEach((l, i) => nText(ctx, l, 113, 52 + i * 14, '#2a1a0a', 11, 'center', 200));
    nRow(ctx, f, DS[0], true, `${tx('Yeniden doğ')}: ${where}`, 'revive');
    nEnd(ctx);
  }
  function drawSys2(ctx, vw, VH) {
    const k = VH / 373; nBegin(ctx, VH, { k, x: (UI.safeL || 0) + 126 * VH / 320 }); const f = 'n_deadselect', on = tx('Açık'), off = tx('Kapalı');
    nLongBg(ctx); nText(ctx, 'Ayarlar', 113, 24, '#7a1c08', 14, 'center');
    nText(ctx, Net.on ? 'Sunucuya otomatik kaydedilir.' : 'Oyun otomatik kaydedilir.', 113, 52, '#2a1a0a', 11, 'center', 200); nText(ctx, tx('Sürüm ' + VER), 113, 70, '#5a4020', 10, 'center');
    const rows = [['sfx', `${tx('Ses efektleri')}: ${SFX.opt.sfx ? on : off}`], ['mus', `${tx('Müzik')}: ${SFX.opt.music ? on : off}`], ['lang', `Dil / Language: ${LANG === 'tr' ? 'Türkçe' : 'English'}`], ['title', 'Giriş ekranına dön'], ['newc', Net.on ? 'Karakter değiştir' : 'Yeni karakter oluştur']];
    rows.forEach(([key, label], i) => nRow(ctx, f, DS[i], pressed === 's:' + key, label, 's:' + key));
    nEnd(ctx);
  }
  // ---------------- Onay ve sayı kutuları (NEW_FORM_DIALOG_YESNO, NEW_FORM_SELNUM) ----------------
  function drawModal2(ctx, vw, VH) {
    ctx.fillStyle = 'rgba(0,0,0,.45)'; ctx.fillRect(0, 0, vw, VH); const mh = [], k = 1.3;
    nBegin(ctx, VH, { k, x: Math.round((vw - 227 * k) / 2), y: Math.round((VH - 129 * k) / 2) }); NHT = mh;
    const btn = (f, id, label, key) => { const r = nDraw(ctx, f, id, pressed === key, ''); Forms.label(ctx, label, r[0], r[1], r[2], r[3], '#f4ead0', 'center', 11); nHit(key, r[0], r[1], r[2], r[3]); };
    if (modal.k === 'yesno') {
      const f = 'n_dialog_yesno'; nDraw(ctx, f, 50042, 0);
      const L = wrap(ctx, modal.text, 196, 11).slice(0, 5); L.forEach((l, i) => nText(ctx, l, 113, 46 - L.length * 7 + i * 14 + 7, '#2a1a0a', 11, 'center', 200));
      btn(f, 50041, 'Tamam', 'm52786'); btn(f, 50040, 'İptal', 'm52788');
    } else {
      const f = 'n_selnum'; nDraw(ctx, f, 50253, 0);
      nText(ctx, modal.title, 113, 13, '#7a1c08', 11, 'center', 120);
      { const r = nDraw(ctx, f, 50259, 0); const I = Forms.img(7036, R3); if (I.complete && I.naturalWidth) ctx.drawImage(I, 0, 0, 53, 26, r[0] + 54, r[1], 54, 26); nText(ctx, String(modal.n), 112, 43, '#ffffff', 14, 'center'); nHit('m50761', r[0], r[1], r[2], r[3]); }
      for (const [id, key] of [[50254, 'm50758'], [50255, 'm50759']]) { const r = nDraw(ctx, f, id, pressed === key); nHit(key, r[0] - 3, r[1] - 3, r[2] + 6, r[3] + 6); }
      if (modal.unit) nText(ctx, `${tx('Toplam')}: ${modal.n * modal.unit} ${tx('altın')} · ${tx('En fazla')}: ${modal.max}`, 113, 68, '#2a1a0a', 9.5, 'center', 200);
      for (const [id, label, key] of [[50263, 'Tamam', 'm52791'], [50264, 'İptal', 'm52792']]) { const r = nC(f, id).s[0].r, I = Forms.img(7017, R3); if (I.complete && I.naturalWidth) ctx.drawImage(I, 0, 0, 84, 24, r[0], r[1], 84, 24); Forms.label(ctx, label, r[0], r[1], r[2], r[3], '#f4ead0', 'center', 11); nHit(key, r[0], r[1], r[2], r[3]); }
    }
    nEnd(ctx); modal.hits = mh;
  }

  // ---------------- Evcil hayvan (NEW_FORM petcomplex + taktik newpetai) ----------------
  // bilgi alanı üç sekme: Bilgi · Beceriler (doğuştan + rastgele, simgeli) · Ağaç (8 biçim: temel + 7 dönüşüm aşaması)
  const PW = { i: 0, ai: false, tab: 0, skd: 0, tree: null, pre: {} };
  const T2 = (a, b) => LANG === 'en' ? b : a;
  const SKIND = { active: ['Saldırı', 'Attack'], support: ['Destek', 'Support'], passive: ['Kalıcı', 'Passive'], aura: ['Hale', 'Aura'] };
  // hayvan görselini küçültüp kutuya sığdır
  function petSprite(ctx, L, x, y, w, h, sc, alpha = 1) {
    const sp = Game.map.sprite(L); if (!sp.ok) { if (!PW.pre[L]) { PW.pre[L] = 1; Assets.preload([L]); } return; }
    ctx.save(); ctx.globalAlpha = alpha; ctx.beginPath(); ctx.rect(x, y, w, h); ctx.clip(); ctx.translate(x + w / 2, y + h - 3); ctx.scale(sc, sc); sp.draw(ctx, 2, Game.time * TICK, 0, 0); ctx.restore();
  }
  function drawPet2(ctx, vw, VH) {
    const k = VH / 290, f = 'n_petcomplex', L = Pet.list(); if (PW.i >= L.length) PW.i = 0; const p = L[PW.i];
    nBegin(ctx, VH, { k, x: (UI.safeL || 0) + 126 * VH / 320, y: Math.round((VH - 259 * k) / 2) });
    nDraw(ctx, f, 50123, 0); nHit('frame', 0, 9, 227, 250);
    { const r = nDraw(ctx, f, 50124, pressed === 'p:x'); nHit('p:x', r[0], r[1], r[2], r[3]); }
    const box = nC(f, 50125).s[0].r; nDraw(ctx, f, 50125, 0);
    if (!p) {
      nText(ctx, T2('Evcil hayvanın yok', 'No pets yet'), 146, 43, '#3a1c08', 12, 'center', 120);
      wrap(ctx, T2('Şehirlerdeki Hayvan Terbiyecisi\'nden bilgi al. Yumurtayı kuluçka kutusuyla çıkar; yumurtalar canavarlardan da düşer.', 'Ask a Beast Tamer in town. Hatch an egg with an incubator; eggs also drop from monsters.'), 196, 11).slice(0, 8).forEach((l, i) => nText(ctx, l, 14, 140 + i * 14, '#2a1a0a', 10.5, 'left', 198));
      nEnd(ctx); return;
    }
    const st = Pet.stats(p), S = Pet.sp(p), on = Game.P.petOn === p.uid, D0 = Pet.D, tp = Pet.tpl(p);
    // portre: hayvanın şimdiki biçimi
    { const sp = Game.map.sprite(Pet.look(p)); if (!sp.ok && !PW.loading) { PW.loading = true; Assets.preload([Pet.look(p)]).then(() => PW.loading = false); }
      if (sp.ok) { ctx.save(); ctx.beginPath(); ctx.rect(box[0] + 2, box[1] + 2, box[2] - 4, box[3] - 4); ctx.clip(); sp.draw(ctx, 2, Game.time * TICK, box[0] + box[2] / 2, box[1] + box[3] - 8); ctx.restore(); } }
    { const r = nDraw(ctx, f, 50126, 0); nText(ctx, `${Pet.nm(p)}  ${tx('Sv')} ${p.lv}`, r[0] + r[2] / 2, r[1] + r[3] / 2, p.dead ? '#a02010' : '#ffe9a8', 11, 'center', r[2] - 6); }
    { const r = nDraw(ctx, f, 50127, pressed === 'p:on'), lab = p.dead ? T2('Ölü', 'Dead') : on ? T2('Geri çağır', 'Dismiss') : T2('Çağır', 'Summon'); nText(ctx, lab, r[0] + r[2] / 2, r[1] + r[3] / 2, '#f4ead0', 11, 'center'); nHit('p:on', r[0], r[1], r[2], r[3]); }
    // yuvalar: besle, taktik, dönüşüm; küçük yuva: sıradaki hayvan
    [[50756, 'feed', T2('Besle', 'Feed')], [50757, 'ai', T2('Taktik', 'Tactics')], [50758, 'tf', T2('Dönüşüm', 'Transform')]].forEach(([id, key, lab]) => { const r = nDraw(ctx, f, id, pressed === 'p:' + key || (key === 'ai' && PW.ai)); nText(ctx, lab, r[0] + r[2] / 2, r[1] + r[3] / 2, '#2a1a0a', 9, 'center', r[2] - 2); nHit('p:' + key, r[0], r[1], r[2], r[3]); });
    { const r = nDraw(ctx, f, 50128, pressed === 'p:next'); nText(ctx, `${PW.i + 1}/${L.length}`, r[0] + r[2] / 2, r[1] + r[3] / 2, '#2a1a0a', 9.5, 'center'); if (L.length > 1) nHit('p:next', r[0], r[1], r[2], r[3]); }
    // sekmeler
    [T2('Bilgi', 'Info'), T2('Beceriler', 'Skills'), T2('Ağaç', 'Tree')].forEach((l, i) => { const x = 14 + i * 66, a = PW.tab === i; nText(ctx, l, x + 31, 140, a ? '#7a1c08' : '#5a4a30', 11, 'center'); if (a) { ctx.fillStyle = '#7a1c08'; ctx.fillRect(x + 8, 147, 46, 1.5); } nHit('p:tab:' + i, x, 131, 62, 18); });
    const Y = 160, LH = 13;
    if (PW.tab === 0) {
      const nx = D0.stages[(p.st || 0) + 1];
      const lines = [
        [`${T2(S.tr, S.en)} · ${T2(tp.tr, tp.en)} · ${T2('Yetenek', 'Talent')} ×${p.tal}`, '#7a1c08'],
        [`${T2('Can', 'HP')} ${Math.round(p.hp)}/${st.hp} · ${T2('Mana', 'MP')} ${Math.round(p.mp)}/${st.mp}`],
        [`${T2('Saldırı', 'Attack')} ${st.mag ? st.matk : st.patk} · ${T2('Savunma', 'Defense')} ${st.def} · ${T2('Kaçınma', 'Dodge')} %${st.dodge.toFixed(0)}`],
        [`${T2('Deneyim', 'XP')} ${p.xp}/${Pet.needXp(p.lv)}${p.lv >= Game.P.lv ? T2(' (sınır: senin seviyen)', ' (cap: your level)') : ''}`],
        [`${T2('Tokluk', 'Satiety')} ${p.sat} · ${T2('Mutluluk', 'Happiness')} ${p.joy}${p.sat <= 0 || p.joy <= 20 ? T2(' · savaşmıyor!', ' · won\'t fight!') : ''}`, p.sat <= 0 || p.joy <= 20 ? '#a02010' : null],
        [`${T2('Dönüşüm', 'Transform')} ${p.st || 0}/7${nx ? ` · ${T2('sonraki', 'next')}: ${tx('Sv')} ${nx.lv}` : ''}`],
        [`${T2('Taktik', 'Tactics')}: ${T2(Pet.MODEN[Game.P.petMode || 'attack'][0], Pet.MODEN[Game.P.petMode || 'attack'][1])}`],
      ];
      lines.forEach(([l, c], i) => nText(ctx, l, 14, Y + i * LH, c || '#2a1a0a', 10, 'left', 198));
      nText(ctx, T2('Bırak', 'Release'), 210, Y + 6 * LH, pressed === 'p:rel' ? '#ff4020' : '#a02010', 10, 'right'); nHit('p:rel', 172, Y + 6 * LH - 8, 42, 16);
    } else if (PW.tab === 1) {
      const ks = Pet.skills(p); if (PW.skd >= ks.length) PW.skd = 0;
      ks.forEach((kk, i) => { const d = D0.skills[kk], y = 151 + i * 19, sel = PW.skd === i; if (!d) return;
        if (sel) { ctx.fillStyle = 'rgba(122,28,8,.12)'; ctx.fillRect(12, y - 1, 202, 19); }
        if (d.icon) drawIcon(ctx, { ik: 'skill', icon: d.icon }, 14, y, 17);
        nText(ctx, T2(d.tr[0], d.en[0]), 36, y + 8.5, sel ? '#7a1c08' : '#2a1a0a', 10.5, 'left', 110);
        nText(ctx, `${i ? T2('rastgele', 'random') : T2('doğuştan', 'innate')} · ${T2(...(SKIND[d.kind] || SKIND.active))}`, 212, y + 8.5, '#7a6a50', 8.5, 'right', 64); nHit('p:sk:' + i, 12, y - 1, 202, 19); });
      if (ks.length < 4) nText(ctx, T2(`Rastgele beceri yuvası: ${ks.length - 1}/3`, `Random skill slots: ${ks.length - 1}/3`), 14, 151 + ks.length * 19 + 8, '#5a4a30', 9, 'left', 198);
      const d = D0.skills[ks[PW.skd]]; if (d) wrap(ctx, T2(d.tr[1], d.en[1]), 198, 9).slice(0, 2).forEach((l, i) => nText(ctx, l, 14, 232 + i * 11, '#3a2a10', 9, 'left', 200));
    } else {
      const F = S.forms, cw = 50, ch = 44;
      F.forEach((fm, i) => { const x = 13 + (i % 4) * cw, y = 150 + Math.floor(i / 4) * (ch + 1), got = i <= (p.st || 0), cur0 = i === (p.st || 0), sel = PW.tree === i;
        ctx.fillStyle = cur0 ? 'rgba(255,208,64,.35)' : sel ? 'rgba(122,28,8,.15)' : 'rgba(0,0,0,.06)'; ctx.fillRect(x, y, cw - 2, ch);
        if (cur0 || sel) { ctx.strokeStyle = cur0 ? '#c08a10' : '#7a1c08'; ctx.lineWidth = 1; ctx.strokeRect(x + 0.5, y + 0.5, cw - 3, ch - 1); }
        petSprite(ctx, fm.look, x, y, cw - 2, ch, 0.36, got ? 1 : 0.45);
        nText(ctx, i ? String(i) : '0', x + 3, y + 6, '#7a1c08', 8, 'left'); if (i) nText(ctx, `${tx('Sv')}${D0.stages[i].lv}`, x + cw - 4, y + 6, '#5a4a30', 7.5, 'right');
        nHit('p:tr:' + i, x, y, cw - 2, ch); });
      const si = PW.tree != null ? PW.tree : (p.st || 0), fm = F[si];
      nText(ctx, `${si}: ${T2(fm.tr, fm.en)}${si ? ` · ${tx('Sv')} ${D0.stages[si].lv} · ${D0.stages[si].cost} ${tx('altın')}` : ''}`, 113, 246, '#3a2a10', 9, 'center', 200);
    }
    nEnd(ctx);
    if (PW.ai) {   // taktik: 5 orijinal mod
      const f2 = 'n_newpetai', rows = [50145, 50146, 50147, 50148, 50149, 50150];
      nBegin(ctx, VH, { k: k * 0.9, x: (UI.safeL || 0) + 126 * VH / 320 + 232 * k, y: Math.round((VH - 300 * k * 0.9) / 2) });
      nDraw(ctx, f2, 50143, 0); nHit('frame', 0, 20, 227, 250);
      Pet.MODES.forEach((m, i) => { const r = nDraw(ctx, f2, rows[i], (Game.P.petMode || 'attack') === m || pressed === 'p:m:' + m), M = Pet.MODEN[m];
        nText(ctx, T2(M[0], M[1]), r[0] + 12, r[1] + 15, '#3a1c08', 12, 'left', 170); nText(ctx, T2(M[2], M[3]), r[0] + 12, r[1] + 30, '#5a3a18', 9, 'left', 175); nHit('p:m:' + m, r[0], r[1], r[2], r[3]); });
      { const r = nDraw(ctx, f2, 50144, pressed === 'p:aix'); nHit('p:aix', r[0], r[1], r[2], r[3]); }
      nEnd(ctx);
    }
  }
  function tapPet2(id) {
    if (typeof id !== 'string') return; const L = Pet.list(), p = L[PW.i];
    if (id === 'p:x') return close();
    if (id === 'p:next') { PW.i = (PW.i + 1) % L.length; PW.tree = null; PW.skd = 0; return; }
    if (id === 'p:aix') { PW.ai = false; return; }
    if (id.startsWith('p:m:')) { Pet.setMode(id.slice(4)); PW.ai = false; return; }
    if (id.startsWith('p:tab:')) { PW.tab = +id.slice(6); PW.tree = null; SFX.play('skill_pageflip', 0.5); return; }
    if (id.startsWith('p:sk:')) { PW.skd = +id.slice(5); return; }
    if (id.startsWith('p:tr:')) { const i = +id.slice(5); PW.tree = PW.tree === i ? null : i; return; }
    if (!p) return;
    if (id === 'p:on') { if (Game.P.petOn === p.uid) Pet.dismiss(); else Pet.summon(p.uid); return; }
    if (id === 'p:ai') { PW.ai = !PW.ai; return; }
    if (id === 'p:tf') { open('petf', { mode: 'tf', main: p.uid }); return; }
    if (id === 'p:feed') { const f = ['30022'].find(x => countItem(x)); if (!f) return UI.toast(T2('Biluo Meyven yok (Hayvan Terbiyecisi satar).', 'No Biluo Fruit (Beast Tamers sell it).')); if (Game.P.petOn !== p.uid) return UI.toast(T2('Beslemek için önce çağır.', 'Summon it first to feed it.')); useItem(f); return; }
    if (id === 'p:rel') { ask(T2(`${Pet.nm(p)} serbest bırakılsın mı? Geri dönmez.`, `Release ${Pet.nm(p)}? It won't come back.`), () => { Pet.release(p.uid); PW.i = 0; }); return; }
  }
  // ---------------- Dönüşüm (幻化) ve beceri aktarma (技能转移): orijinal NEW_FORM fantasize_pet ----------------
  // solda: ana hayvan, yardımcı hayvan, iki yardımcı eşya → sağda sonuç; sağ balonda açıklama; altta bedel ve onay düğmesi
  const TF = { mode: 'tf', main: null, mat: null, a: [null, null] };
  const TFS = { main: 50697, mat: 50698, a0: 50700, a1: 50699, res: 50701 };
  function tfPets() { const L = Pet.list(), m = L.find(x => x.uid === TF.main) || null, s = L.find(x => x.uid === TF.mat) || null; return { m, s }; }
  function tfAids() { return Pet.AIDS.filter(id => { const u = ITEMS[id] && ITEMS[id].pet; return u && (TF.mode === 'tf' ? u.tf : u.sk) && countItem(id) > 0; }); }
  function drawPetF(ctx, vw, VH) {
    const f = 'n_fantasize_pet', k = Math.min(VH / 330, vw / 495), { m, s } = tfPets(), sk = TF.mode === 'sk';
    TF.a = TF.a.map(id => id && countItem(id) > 0 ? id : null);
    nBegin(ctx, VH, { k, x: Math.round((vw - 481 * k) / 2), y: Math.round((VH - 320 * k) / 2) });
    nDraw(ctx, f, 50696, 0); nHit('frame', 0, 0, 481, 320); nDraw(ctx, f, 50869, 0); nDraw(ctx, f, 50721, 0);
    { const r = nDraw(ctx, f, 50720, pressed === 'f:x'); nHit('f:x', r[0] + 10, r[1], 40, 40); }
    // yuvalar
    const slot = (key, id, fill) => { const r = nDraw(ctx, f, id, pressed === 'f:' + key); if (fill) { ctx.fillStyle = '#d9c59c'; ctx.fillRect(r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10); fill(r); } nHit('f:' + key, r[0], r[1], r[2], r[3]); return r; };
    slot('main', TFS.main, m && (r => petSprite(ctx, Pet.look(m), r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10, 0.34)));
    slot('mat', TFS.mat, s && (r => petSprite(ctx, Pet.look(s), r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10, 0.34)));
    ['a0', 'a1'].forEach((key, i) => slot(key, TFS[key], TF.a[i] && (r => drawIcon(ctx, ITEMS[TF.a[i]], r[0] + 5, r[1] + 5, r[2] - 10))));
    const info = sk ? Pet.skInfo(m, s, TF.a.filter(Boolean)) : Pet.tfInfo(m, s, TF.a.filter(Boolean));
    { const r = nC(f, TFS.res).s[0].r; nDraw(ctx, f, TFS.res, 0);
      if (!sk && m && info.next) { ctx.fillStyle = '#d9c59c'; ctx.fillRect(r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10); petSprite(ctx, Pet.sp(m).forms[info.next].look, r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10, 0.3); }
      else if (sk && info.ok && info.gs != null) { ctx.fillStyle = '#d9c59c'; ctx.fillRect(r[0] + 5, r[1] + 5, r[2] - 10, r[3] - 10); const d = Pet.D.skills[s.sk[info.gs]]; if (d && d.icon) drawIcon(ctx, { ik: 'skill', icon: d.icon }, r[0] + 5, r[1] + 5, r[2] - 10); } }
    // etiketler
    const lab = (id, t, col = '#3a1c08') => { const r = nC(f, id).s[0].r; nText(ctx, t, r[0], r[1] + r[3] / 2, col, 9.5, 'left', 110); };
    lab(50712, m ? `${Pet.nm(m)} ${tx('Sv')}${m.lv} · ${m.st || 0}/7` : T2('Ana hayvan', 'Main pet'));
    lab(50713, s ? `${Pet.nm(s)} ${tx('Sv')}${s.lv} · ${s.st || 0}/7` : T2('Yardımcı hayvan', 'Helper pet'));
    lab(50715, TF.a[0] ? T2(ITEMS[TF.a[0]].name, ITEMS[TF.a[0]].en) : T2('Yardımcı eşya', 'Aid item'), '#5a3a18');
    lab(50714, TF.a[1] ? T2(ITEMS[TF.a[1]].name, ITEMS[TF.a[1]].en) : T2('Yardımcı eşya', 'Aid item'), '#5a3a18');
    if (!sk && info.next) { const r = nC(f, 50737).s[0].r; nText(ctx, `${T2('Düzey', 'Level')} ${(m && m.st) || 0} → ${info.next}`, r[0] + 30, r[1] + 3, '#7a1c08', 9.5, 'center', 90); }
    // bedel + onay
    { const r = nDraw(ctx, f, 50716, 0); nText(ctx, info.cost != null ? `${info.cost} ${tx('altın')}` : '-', r[0] + 22, r[1] + 9, Game.P.gold >= (info.cost || 0) ? '#ffe9a8' : '#ff6040', 10, 'left', 92); }
    { const r = nDraw(ctx, f, 50719, pressed === 'f:go'); nText(ctx, sk ? T2('Aktar', 'Transfer') : T2('Dönüştür', 'Transform'), r[0] + r[2] / 2, r[1] + r[3] / 2, info.ok ? '#f4ead0' : '#a09080', 11, 'center'); nHit('f:go', r[0], r[1], r[2], r[3]); }
    { const r = nDraw(ctx, f, 50736, pressed === 'f:shop'); nHit('f:shop', r[0], r[1], r[2], r[3]); }
    // sağ balon: kip sekmeleri + açıklama
    [T2('Dönüşüm', 'Transform'), T2('Beceri Aktarma', 'Skill Transfer')].forEach((t, i) => { const x = 250 + i * 104, a = (i === 1) === sk; nText(ctx, t, x + 50, 34, a ? '#7a1c08' : '#8a6a40', 11.5, 'center', 100); if (a) { ctx.fillStyle = '#7a1c08'; ctx.fillRect(x + 12, 42, 76, 1.5); } nHit('f:mode:' + (i ? 'sk' : 'tf'), x, 24, 100, 22); });
    const T = [];
    if (!sk) {
      if (m && info.next) { const fm = Pet.sp(m).forms[info.next]; T.push(`${T2('Sonraki biçim', 'Next form')}: ${T2(fm.tr, fm.en)} (${tx('Sv')} ${info.need})`); }
      T.push(info.ok ? `${T2('Başarı şansı', 'Success chance')}: %${info.chance}${info.keep ? T2(' · başarısızlıkta düzey korunur', ' · level kept on failure') : ''}` : info.why);
      T.push(T2('Başarıda düzey +1, görünüş ve nitelikler değişir; başarısızlıkta düzey −1. Yardımcı hayvan her durumda kaybolur.', 'On success level +1 and the form and stats change; on failure level −1. The helper pet is always lost.'));
    } else {
      if (m) T.push(`${T2('Ana', 'Main')}: ${Pet.skills(m).slice(1).map(Pet.skName).join(', ') || T2('rastgele becerisi yok', 'no random skills')}`);
      if (s) T.push(`${T2('Yardımcı', 'Helper')}: ${(s.sk || []).map(Pet.skName).join(', ') || T2('rastgele becerisi yok', 'no random skills')}`);
      T.push(info.ok ? T2(`Yardımcının ${info.gs != null ? 'seçilen' : 'rastgele bir'} becerisi ana hayvanın ${info.ls != null ? 'seçilen' : 'rastgele bir'} becerisinin yerine geçer.`, `The helper's ${info.gs != null ? 'chosen' : 'random'} skill replaces the main pet's ${info.ls != null ? 'chosen' : 'random'} skill.`) : info.why);
      T.push(T2('Yalnız aynı türden hayvanlar. Yardımcı hayvan kaybolur.', 'Same pet type only. The helper pet is lost.'));
    }
    let y = 56; for (const t of T) for (const l of wrap(ctx, t, 206, 9.5).slice(0, 4)) { if (y > 168) break; nText(ctx, l, 252, y, '#3a2a10', 9.5, 'left', 210); y += 12; }
    nEnd(ctx);
  }
  function tapPetF(id) {
    if (typeof id !== 'string') return; const L = Pet.list(), { m } = tfPets();
    const cyc = (cands, curv) => { if (!cands.length) return null; const i = cands.indexOf(curv); return i < 0 ? cands[0] : i + 1 < cands.length ? cands[i + 1] : null; };
    if (id === 'f:x') return close();
    if (id.startsWith('f:mode:')) { TF.mode = id.slice(7); TF.a = [null, null]; SFX.play('skill_pageflip', 0.5); return; }
    if (id === 'f:main') { const c = L.filter(Pet.resting).map(x => x.uid); if (!c.length) return UI.toast(T2('Dinlenen hayvanın yok (çağrılmış hayvanı geri çağır).', 'No resting pets (dismiss the summoned one).')); TF.main = cyc(c, TF.main) || c[0]; if (TF.mat === TF.main) TF.mat = null; return; }
    if (id === 'f:mat') { const c = L.filter(x => Pet.resting(x) && x.uid !== TF.main).map(x => x.uid); if (!c.length) return UI.toast(T2('Yardımcı olabilecek başka dinlenen hayvanın yok.', 'No other resting pet to use as helper.')); TF.mat = cyc(c, TF.mat); return; }
    if (id === 'f:a0' || id === 'f:a1') { const i = +id.slice(3), c = tfAids().filter(x => x !== TF.a[1 - i] || countItem(x) > 1); if (!c.length) return UI.toast(T2('Yardımcı eşyan yok (Büyülü Canavar Ustası satar).', 'No aid items (the Magic Beast Master sells them).')); TF.a[i] = cyc(c, TF.a[i]); return; }
    if (id === 'f:shop') { UI.openShop('魔法兽强化大师'); return; }
    if (id === 'f:go') {
      const { s } = tfPets(), sk = TF.mode === 'sk', info = sk ? Pet.skInfo(m, s, TF.a.filter(Boolean)) : Pet.tfInfo(m, s, TF.a.filter(Boolean));
      if (!info.ok) return UI.toast(info.why);
      ask(sk ? T2(`${Pet.nm(s)} kaybolacak ve becerisi ${Pet.nm(m)}'e geçecek. Emin misin?`, `${Pet.nm(s)} will be lost and its skill passed to ${Pet.nm(m)}. Are you sure?`)
        : T2(`${Pet.nm(s)} kaybolacak. Başarı şansı %${info.chance}. Dönüştürülsün mü?`, `${Pet.nm(s)} will be lost. Success chance ${info.chance}%. Transform?`),
      () => { if (sk) Pet.transferSkill(TF.main, TF.mat, TF.a.filter(Boolean)); else Pet.transform(TF.main, TF.mat, TF.a.filter(Boolean)); TF.mat = null; });
    }
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
    rowBtn(ctx, 'newc', ox + 4, oy + 180, Net.on ? 'Karakter değiştir' : 'Yeni karakter oluştur', null);
    Forms.label(ctx, tx(Net.on ? 'Sunucuya otomatik kaydedilir.' : 'Oyun otomatik kaydedilir.') + '  ' + tx('Sürüm ' + VER), ox + 8, oy + 222, 290, 14, '#8d8983', 'left', 10);
  }
  function tapSys(id) {
    if (id !== 'newc') sysSure = false;
    if (id === 'gm') { UI.open('gm'); return; }
    if (id === 'sfx') SFX.setSfx(!SFX.opt.sfx); else if (id === 'mus') SFX.setMusic(!SFX.opt.music);
    else if (id === 'lang') { save(); Net.now().then(() => setLang(LANG === 'tr' ? 'en' : 'tr')); }
    else if (id === 'title' || (id === 'newc' && Net.on)) { save(); Net.now().then(() => location.reload()); }
    else if (id === 'newc') ask('Karakterin silinecek ve yeni karakter oluşturacaksın. Emin misin?', () => { localStorage.removeItem(SAVE_KEY); location.reload(); });
  }
  // ---------------- Dünya haritası (dosyadaki orijinal harita görselleri) ----------------
  // ---------------- Dünya haritası ----------------
  // Üç görünüm: kıta (renkli harita, bölge noktaları) -> bölge (şehir, kamp, kır ve zindan simgeleri) ; ve bulunduğun haritanın yakın görünümü.
  // Resimler ve yerleşim Android sürümünden (tools/dunya.py); düğmeler orijinal 70x30 düğmeler.
  const wmImg = {}, WM = { mode: 'world', area: null, sel: null, data: null, load: false };
  const wimg = k => wmImg[k] || (wmImg[k] = Object.assign(new Image(), { src: vq(`${Assets.base}wm/${k}`) }));
  function wmData() { if (!WM.data && !WM.load) { WM.load = true; fetch(vq(Assets.base + 'wm/wm.json')).then(r => r.json()).then(d => { WM.data = d; }).catch(() => { WM.load = false; }); } return WM.data; }
  const areaOf = sid => { const d = WM.data; return d ? d.areas.find(a => a.scenes.some(s => s.sid === sid)) : null; };
  function mapRect(vw, VH) { const W = Math.min(560, Math.round(vw - 96)), H = Math.min(344, VH - 12); return { W, H, ox: Math.max(80, Math.round((vw - W) / 2) + 34), oy: Math.round((VH - H) / 2) }; }
  function mapBtn(ctx, id, label, x, y) { Forms.drawCtrl(ctx, Forms.ctrl('worldmap', 52801), pressed === id ? 1 : 0, x - 1, y - 1, ''); Forms.label(ctx, tx(label), x, y, 70, 30, '#ffffff', 'center', 10); hits.push({ id, x, y, w: 70, h: 30 }); }
  function drawMap(ctx, vw, VH) {
    const { W, H, ox, oy } = mapRect(vw, VH), top = 4, bh = 36, vh = H - top - bh, vx = ox + 4, vy = oy + top, vwid = W - 8, D = wmData();
    ctx.fillStyle = '#000'; ctx.fillRect(ox, oy, W, H); ctx.strokeStyle = '#9f998f'; ctx.strokeRect(ox + 0.5, oy + 0.5, W - 1, H - 1); ctx.strokeStyle = '#4b4547'; ctx.strokeRect(ox + 1.5, oy + 1.5, W - 3, H - 3);
    hits.push({ id: 'frame', x: ox, y: oy, w: W, h: H });
    ctx.save(); ctx.beginPath(); ctx.rect(vx, vy, vwid, vh); ctx.clip(); ctx.imageSmoothingEnabled = true;
    const pulse = 0.5 + 0.5 * Math.sin(Game.time * 5), here = D && areaOf(Game.sceneId);
    if (WM.mode === 'world') {
      const im = wimg('world.jpg'); if (im.complete && im.naturalWidth) ctx.drawImage(im, vx, vy, vwid, vh);
      if (D) for (const a of D.areas) {
        const x = vx + a.cx / 100 * vwid, y = vy + a.cy / 100 * vh, cur = a === here;
        ctx.fillStyle = 'rgba(0,0,0,.45)'; ctx.beginPath(); ctx.arc(x + 1, y + 2, 11, 0, 7); ctx.fill();
        const g = ctx.createRadialGradient(x - 3, y - 3, 1, x, y, 11); g.addColorStop(0, '#ff7a3a'); g.addColorStop(1, '#c8300e'); ctx.fillStyle = g; ctx.beginPath(); ctx.arc(x, y, 10, 0, 7); ctx.fill();
        if (cur) { ctx.strokeStyle = `rgba(255,255,255,${0.5 + 0.5 * pulse})`; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(x, y, 13 + pulse * 2, 0, 7); ctx.stroke(); ctx.fillStyle = '#fff'; ctx.beginPath(); ctx.arc(x, y - 1, 3.2, 0, 7); ctx.fill(); }
        hits.push({ id: 'area:' + a.i, x: x - 16, y: y - 16, w: 32, h: 32 });
      }
    } else if (WM.mode === 'area' && WM.area) {
      const a = WM.area, im = wimg(a.img); if (im.complete && im.naturalWidth) ctx.drawImage(im, vx, vy, vwid, vh);
      for (const s of a.scenes) {
        const x = vx + s.x / 100 * vwid, y = vy + s.y / 100 * vh, ic = wimg(s.icon + '.png'), sz = 22;
        if (s.sid === Game.sceneId || s.sid === WM.sel) { const r = wimg('ring.png'), k = s.sid === WM.sel ? 34 : 30 + pulse * 4; if (r.complete && r.naturalWidth) ctx.drawImage(r, x - k / 2, y - k / 2, k, k); }
        if (ic.complete && ic.naturalWidth) ctx.drawImage(ic, x - sz / 2, y - sz / 2, sz, sz);
        hits.push({ id: 'sc:' + s.sid, x: x - 15, y: y - 15, w: 30, h: 30 });
      }
    } else {
      // bulunduğun harita: zemin görüntüsü sığacak kadar küçültülür
      const map = Game.map, g = map.ground, k = Math.min((vwid - 8) / map.pw, (vh - 4) / map.ph), gw = map.pw * k, gh = map.ph * k, gx = vx + (vwid - gw) / 2, gy = vy + (vh - gh) / 2;
      ctx.drawImage(g, 0, 0, map.pw, map.ph, gx, gy, gw, gh);
      const dot = (e, c, r) => { ctx.fillStyle = c; ctx.beginPath(); ctx.arc(gx + map.px(e.x, e.y) * k, gy + map.py(e.x, e.y) * k, r, 0, 7); ctx.fill(); };
      for (const r of map.regionsOf(1)) dot({ x: (r[2] + r[4]) / 2, y: (r[3] + r[5]) / 2 }, '#4aa8ff', 3.5);
      for (const e of Game.ents) if (e.kind === 'npc' && !e.dummy && !e.hidden) dot(e, '#7cf06a', 2);
      if (Math.floor(Game.time * 3) % 2 === 0) { dot(Game.player, '#000', 4); dot(Game.player, '#ffe048', 3); }
    }
    ctx.imageSmoothingEnabled = false; ctx.restore();
    // kapatma düğmesi (orijinal çanta penceresinin düğmesi) ve alt satır
    Forms.drawCtrl(ctx, Forms.ctrl('bag', 52696), pressed === 'close' ? 1 : 0, ox + W - 306, oy - 6); hits.push({ id: 'close', x: ox + W - 34, y: oy - 6, w: 34, h: 34 });
    const by = oy + H - bh + 3;
    mapBtn(ctx, 'sw', WM.mode === 'area' ? 'Geri' : 'Değiştir', ox + 8, by);
    if (WM.mode === 'area') mapBtn(ctx, 'go', 'Otomatik Yol', ox + W - 156, by);
    mapBtn(ctx, 'npcs', 'NPC Listesi', ox + W - 78, by);
    const S = Assets.D.scenes; let info = `${tx('Şimdi')}: ${tx(trName(Game.scene.name))}`, col = '#e6cf89';
    if (WM.mode === 'area' && WM.sel) { const s = WM.area.scenes.find(q => q.sid === WM.sel); info = tx(trName(S[WM.sel].name)) + (s && s.lv ? `  ·  ${tx('Sv')} ${s.lv[0]}${s.lv[1] !== s.lv[0] ? '-' + s.lv[1] : ''}` : ''); col = '#ffffff'; }
    Forms.label(ctx, info, ox + 84, by, W - (WM.mode === 'area' ? 246 : 168), 30, col, 'center', 11);
  }
  function tapMap(id) {
    if (id === 'npcs') return UI.open('npcs');
    if (id === 'sw') { SFX.play('skill_pageflip'); WM.sel = null; WM.mode = WM.mode === 'area' ? 'world' : WM.mode === 'world' ? 'local' : 'world'; return; }
    if (id === 'go') { if (!WM.sel) return UI.toast('Önce haritadan bir yer seç.'); const t = WM.sel; UI.closeAll(); Game.routeQuest = null; Game.routeNpc = null; routeTo(t); return; }
    if (typeof id === 'string' && id.startsWith('area:')) { WM.area = WM.data.areas.find(a => a.i === +id.slice(5)); WM.mode = 'area'; WM.sel = null; SFX.play('skill_pageflip'); return; }
    if (typeof id === 'string' && id.startsWith('sc:')) { WM.sel = id.slice(3); SFX.play('menusel', 0.6); }
  }
  function drawBag(ctx, vw, VH) {
    const P = Game.P, f = Forms.get('bag'), ox = Math.round((vw - f.w) / 2), oy = Math.round((VH - f.h) / 2);
    const items = bagItems(), slots = slotIds(), quick = quickIds(), per = slots.length, pages = Math.max(1, Math.ceil(items.length / per));
    if (B.page >= pages) B.page = pages - 1;
    const selIt = B.sel && ITEMS[B.sel] && countItem(B.sel) ? ITEMS[B.sel] : null; if (!selIt) B.sel = null;
    const slotMap = new Map(slots.map((c, i) => [c.id, i])), quickMap = new Map(quick.map((c, i) => [c.id, i]));
    Forms.draw(ctx, 'bag', ox, oy, {
      hide: c => c.id === 51661 || c.id === 50772 || quickMap.has(c.id) || (PAGES.includes(c.id) && PAGES.indexOf(c.id) >= Math.max(pages, 1)),
      state: c => {
        if (pressed === c.id) return 1;
        if (PAGES.includes(c.id)) return PAGES.indexOf(c.id) === B.page ? 1 : 0;
        if (slotMap.has(c.id)) { const e = items[B.page * per + slotMap.get(c.id)]; return e && e.id && e.id === B.sel ? 1 : 0; }

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
      state: c => pressed === c.id || (c.id === 52336 && B.detail) || false ? 1 : 0,
      text: c => c.id === 52400 && selIt ? `Sat (+${selIt.sell || 1})` : undefined,
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

  }
  function panel(ctx, x, y, w, h) { ctx.fillStyle = 'rgba(0,0,0,.8)'; ctx.fillRect(x, y, w, h); ctx.strokeStyle = '#9f998f'; ctx.lineWidth = 1; ctx.strokeRect(x + 0.5, y + 0.5, w - 1, h - 1); ctx.strokeStyle = '#4b4547'; ctx.strokeRect(x + 1.5, y + 1.5, w - 3, h - 3); }

  function tap(x, y) {
    if (modal) { tapModal(x, y); return true; }
    if (!cur) return false;
    let h = null; for (const r of hits) if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) { if (r.id === 'frame') { if (!h) h = r; } else if (!h || h.id === 'frame' || r.w * r.h < h.w * h.h) h = r; }
    if (!h) { if (cur !== 'dead') close(); return true; }
    pressed = h.id; pressT = performance.now();
    if (typeof h.id === 'string' && h.id.startsWith('hub:')) { const k = h.id.slice(4); SFX.play('skill_pageflip'); if (k === 'gm') { UI.open('gm'); return true; } if (k !== cur) { close(); open(k); } return true; }
    if (h.id === 'close') { UI.closeAll(); return true; }
    if (cur === 'sys') { if (typeof h.id === 'string' && h.id.startsWith('s:')) tapSys(h.id.slice(2)); return true; } if (cur === 'pet') { tapPet2(h.id); return true; } if (cur === 'petf') { tapPetF(h.id); return true; } if (cur === 'map') { tapMap(h.id); return true; } if (cur === 'hub') return true;
    if (cur === 'bag') tapBag2(h.id); else if (cur === 'role') tapRole2(h.id); else if (cur === 'npc') tapNpc2(h.id); else if (cur === 'task') tapTask2(h.id); else if (cur === 'menu') tapMenu(h.id); else if (cur === 'skill') tapSkill2(h.id); else if (cur === 'shop') tapShop2(h.id); else if (cur === 'dead') { if (h.id === 'revive') { close(); revive(); } }
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
    if (id === 52400 && opt.shop) { sellAsk(B.sel); return; }
    if (id === 51672) { if (it.use) UI.startAssign('i:' + B.sel, it.name); else UI.toast('Yalnızca iksirler kısayola konabilir.'); return; }
    if (id === 52336) { B.detail = !B.detail; return; }
    if (id === 52337) { if (it.quest) return; const sid = B.sel; ask(`${it.name}: ${tx('yok edilsin mi?')}`, () => { removeItem(sid, countItem(sid)); B.sel = null; UI.log(`${it.name} yok edildi.`); save(); }); return; }
  }
  // ---------------- Karakter ekranı (FORM_ROLEPROP): sayfa 0 özellikler, sayfa 1 ekipman ----------------
  const R = { page: 0, sel: null };
  const RTABS = [50386, 50387];                       // sol menü: Özellik, Ekipman
  const RSLOT = { 52281: 'head', 52282: 'neck', 52283: 'body', 52284: 'weap', 52285: 'belt', 52286: 'glove', 52287: 'ring', 52288: 'shoe' };
  let rolePairs = null;
  function roleValues() {
    const P = Game.P, p = Game.player, s = stats(), C = CLS[P.cls];
    return { '昵称': P.name, '种族': TR.race[P.race], '等级': String(P.lv), '称号': '-', '体力': `${Math.ceil(p.hp)}/${s.hp}`, '物攻': String(C.melee ? s.atk : Math.round(s.atk * 0.3)), '防御': String(s.def),
      '闪避': s.dodge + '%', '释放': Math.round(100 + s.spd * 100) + '%', '圣抗': String(s.res), '火抗': String(s.res), '职业': clsName(), '经验': `${P.xp}/${xpNeed(P.lv)}`, '公会': '-',
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
  // Büyülü Canavar Ustası'nın açıklaması (orijinal NPC metninden, kısaltılmış)
  const PETHELP = ['Dönüşüm, bir evcil hayvanın özünü alıp başka birini evrimleştiren özel bir törendir. İki hayvan da dinleniyor olmalı. Evcil hayvan penceresinde Dönüşüm\'ü seç, evrimleşecek hayvanı ana yuvaya, malzeme hayvanı yardımcı yuvaya koy. Başarılı olursa ana hayvanın dönüşüm düzeyi artar, gücü de artar; başarısız olursa düzeyi bir düşer. Yardımcı eşyalar başarı şansını artırır ya da düşüşü önler. Yardımcı hayvan her durumda kaybolur. Beceri aktarma da buna benzer: ana hayvan, yardımcı hayvanın bir becerisini öğrenir. Yalnız aynı türden (fiziksel, savunma, büyü, destek) hayvanlar beceri aktarabilir ve hangi becerinin geçeceği şansa bağlıdır.',
    'Transformation is a special rite that draws the essence of one pet to evolve another. Both pets must be resting. In the pet window choose Transform, put the pet to evolve in the main slot and the material pet in the helper slot. On success the main pet\'s transformation level and power rise; on failure the level drops by one. Aid items raise the chance or prevent the drop. The helper pet is always lost. Skill transfer is similar: the main pet learns one of the helper\'s skills. Only pets of the same type (physical, defense, magic, support) can transfer skills, and which skill passes is up to luck.'];
  function npcOptions() {
    const n = opt.npc, P = Game.P, o = [];
    if (opt.say) return { txt: opt.say, o: [{ t: 'Tamam', a: 'bye' }] };
    let txt = TR.greet[n.cn] || '...';
    if (D.q) {
      const q = D.q, st = questState(q);
      if (st === 'new') { txt = q.text; o.push({ t: q.ok || 'Kabul et', a: 'accept' }, { t: 'Daha sonra', a: 'back' }); }
      else if (st === 'ready' && q.to === n.cn) { txt = q.done; if (q.choice) q.choice.forEach((c, i) => o.push({ t: c[0], a: 'complete', ch: i })); else o.push({ t: 'Tamamla', a: 'complete' }); }   // q.choice: orijinaldeki iki seçenekli bitiş
      else { txt = q.wait || q.goal; o.push({ t: 'Tamam', a: 'back' }); }
    } else {
      if (SHOPS[n.cn]) o.push({ t: 'Alışveriş', a: 'shop', c: '#ffe070' });
      if (n.cn === '魔法兽强化大师') o.push({ t: '✦ ' + T2('Dönüşüm', 'Transformation'), a: 'petf', m: 'tf' }, { t: '✦ ' + T2('Beceri aktarma', 'Skill transfer'), a: 'petf', m: 'sk' },
        { t: T2('Dönüşüm ve beceri aktarma nedir?', 'What are transformation and skill transfer?'), a: 'say', s: T2(PETHELP[0], PETHELP[1]) });   // orijinal: 幻化 / 技能转移 düğmeleri
      for (const q of questsFor(n.cn)) { const st = questState(q), cc = st === 'new' && q.req === 80344;   // orijinal: Ozan'da “我要转职！” seçeneği sınıfın giriş görevini verir
        o.push({ t: cc ? '✦ ' + T2('Sınıf değiştirmek istiyorum!', 'I want to change my class!') : (st === 'ready' ? '? ' : st === 'new' ? '! ' : '… ') + q.title, a: 'q', q, c: st === 'active' ? '#c8c0b0' : '#ffe070' }); }
      const tq = tpQuestOf(n.cn); if (tq) o.push({ t: '✦ Işınlan: ' + trName(Assets.D.scenes[tq.tp[0]].name), a: 'tp', q: tq });
      for (const d of Dungeon.npcTp(n.cn)) o.push({ t: '✦ ' + d.label, a: 'dtp', d });   // zindan merkezine/merkezden ışınlanma
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
    if (e.a === 'petf') { open('petf', { mode: e.m }); return; }
    if (e.a === 'say') { opt.say = e.s; return; }
    if (e.a === 'shop') { UI.openShop(n.cn); return; }
    if (e.a === 'tp') { UI.closeAll(); setTimeout(() => questTeleport(e.q), 300); return; }
    if (e.a === 'dtp') { UI.closeAll(); setTimeout(() => e.d.go(), 300); return; }
    if (e.a === 'accept') { const q = D.q; acceptQuest(q); D.q = null; UI.closeAll(); if (q.tp) { setTimeout(() => questTeleport(q), 400); return; } if (q.type === 'talk' && q.to === n.cn) Game.P.quests[q.id].ready = true; return; }   // görev alınınca pencere kapanır
    if (e.a === 'complete') { const q = D.q; completeQuest(q); D.q = null; if (e.ch != null && q.choice) opt.say = q.choice[e.ch][1]; return; }
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
    const Rm = Forms.drawGroup(ctx, 'task', 7, ox + f.w + 2, oy + 10, { page: 0, state: c => pressed === c.id || (c.id === 52573 && K.detail) || (c.id === 52475 && K.sure) ? 1 : 0, text: () => undefined });
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
    if (id === 52475) { ask(`${q.title}: ${tx('görev bırakılsın mı?')}`, () => { delete P.quests[q.id]; K.sel = null; UI.log(`${tx('Görev bırakıldı')}: ${q.title}`); save(); }); return; }
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
      hide: c => c.id === 50866 || c.id === 50307 || c.id === 50843 || (c.t === 8 && !cell[c.id]) || [51702, 51703, 51704, 51705].includes(c.id),
      state: c => pressed === c.id || (cell[c.id] && cell[c.id].id === S.sel) ? 1 : 0,
      text: c => c.id === 50313 ? '' : undefined,
      after: (c, x, y, w, h) => {
        const sk = cell[c.id];
        if (sk) { const r = skRank(sk); if (!r) ctx.globalAlpha = 0.4; drawIcon(ctx, { ik: sk.ik || 'skill', icon: sk.icon }, x + 5, y + 5); ctx.globalAlpha = 1;
          Forms.label(ctx, `${r}/${SK_MAX}`, x - 6, y + 35, 48, 11, r ? '#ffe070' : skLock(sk) ? '#888' : '#ffffff', 'center', 9);
          Forms.label(ctx, sk.name, x - 32, y + 45, 100, 11, r ? '#e8e0d0' : '#999', 'center', 8); hits.push({ id: c.id, x: x - 6, y: y - 2, w: 48, h: 52 }); }
        const qi = -1;
        if (qi >= 0) { const sl = P.quick[qi]; if (sl && sl[0] === 's') { const k = C.skills[+sl.slice(1)]; if (k) drawIcon(ctx, { ik: k.ik || 'skill', icon: k.icon }, x + 5, y + 5); } else if (sl) { const it = ITEMS[sl.slice(2)]; if (it) drawIcon(ctx, it, x + 5, y + 5); } hits.push({ id: c.id, x, y, w, h }); }
      },
    });
    Forms.label(ctx, `${tx('Beceri puanı')}: ${P.sp || 0}`, ox + 4, oy + 14, 262, 20, (P.sp || 0) > 0 ? '#ffe070' : '#e6cf89', 'center', 12);
    const L = Forms.drawGroup(ctx, 'skill', 5, ox - 80, oy + 10, { hide: c => !STABS.includes(c.id), state: c => STABS.indexOf(c.id) === S.tree ? 1 : 0 });
    L.forEach((m, i) => Forms.label(ctx, trees[i].name, m.x, m.y, m.w, m.h, '#ffffff', 'center', 12));
    const Rm = Forms.drawGroup(ctx, 'skill', 7, ox + f.w + 2, oy + 10, { hide: c => c.id === 52485, state: c => pressed === c.id || (c.id === 52586 && S.detail) ? 1 : 0 });
    for (const m of L.concat(Rm)) hits.push({ id: m.c.id, x: m.x, y: m.y, w: m.w, h: m.h });
    if (selSk && S.detail) {
      const r = skRank(selSk), lines = [[selSk.name + (selSk.pas ? ' ' + tx('(edilgen)') : ''), '#ffd870', 12], [`${tx('Kademe')} ${r}/${SK_MAX}`, '#ffffff', 10]];
      wrap(ctx, selSk.desc || '', 140, 10).forEach(l => lines.push([l, '#d8d0c0', 10]));
      if (!selSk.pas) lines.push([`${selSk.mp} mana · ${selSk.cd} sn`, '#9fc8ff', 10]);
      if (skLock(selSk)) lines.push([skLockMsg(selSk), '#ff6050', 10]);
      const bw = 152, bh = lines.length * 13 + 10, bx = ox - 2 - bw, by = oy + 10 + 2 * 46 + 8; panel(ctx, bx, by, bw, bh);
      lines.forEach(([t, c, sz], i) => Forms.label(ctx, t, bx + 5, by + 5 + i * 13, bw - 10, 13, c, 'left', sz));
    }

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
    if (id === 51712) { if (sk.pas) UI.toast('Edilgen beceriler kısayola konmaz.'); else if (!skRank(sk)) UI.toast('Önce beceriyi öğren.'); else UI.startAssign('s' + C.skills.indexOf(sk), sk.name); return; }
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
    if (i >= 0) { const it = shopItems()[H.off + i]; if (!it) return; const now = performance.now(); if (H.sel === it && shopTap.id === it && now - shopTap.t < 450) { buyAsk(it); shopTap.id = null; return; } H.sel = it; shopTap = { id: it, t: now }; SFX.play('menusel', 0.6); return; }
    if (id === 50753) { H.detail = !H.detail; return; }
    if (id === 50752) { const sh = opt.shop; close(); open('bag', { shop: sh }); return; }          // Sat: çantayı satış kipinde aç
    if (id === 50751) { if (!H.sel) return UI.toast('Listeden bir eşya seç.'); buyAsk(H.sel); return; }
  }
  // liste kaydırma (parmakla sürükleme)
  function drag(dy, x, y, dx = 0) {
    const R = HUB.r; if (R && hubShown() && x >= R.x && x < R.x + R.w && y >= R.y && y < R.y + R.h) { HUB.y = clamp(HUB.y - dy / R.k, 0, R.max); return; }   // sol menü
    if (cur !== 'shop') return; const RH = 53 * NK; H.acc += dy; while (H.acc <= -RH) { H.off++; H.acc += RH; } while (H.acc >= RH) { H.off--; H.acc -= RH; } if (H.off < 0) H.off = 0; }
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
  // testler için: açık penceredeki bir düğmeye kimliğiyle bas
  function tapId(id) { if (modal) { const h = (modal.hits || []).find(r => r.id === id); if (h) tapModal(h.x + h.w / 2, h.y + h.h / 2); return; } if (cur === 'petf') tapPetF(id); else if (cur === 'pet') tapPet2(id); else if (cur === 'skill') tapSkill2(id); }
  // testler için: NPC konuşmasının seçenekleri ve i. satıra dokunma (tools/test/sinif.js)
  const npcOpts = () => npcOptions(), npcRow = i => tapNpc2(N2ROWS[i]), npcDrawn = () => N2ROWS.map(id => npcMap[id]).filter(Boolean).map(e => e.t);   // çizilen satırlar (sayfalı söz: "Devam")
  return { ask, askNum, buyAsk, sellAsk, open, close, isOpen, draw, tap, tapId, drag, key, get cur() { return cur; }, PW, TF, HUB, npcOpts, npcRow, npcDrawn };
})();
