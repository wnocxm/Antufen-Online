// Çizim, arayüz ve girdi. Mantıksal ekran yüksekliği 360 piksel (orijinal S60v5: 640x360).
'use strict';
const $ = s => document.querySelector(s);
const esc = s => String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const VH = 360;

const UIIMG = {};
function uiImg(k) { if (UIIMG[k]) return UIIMG[k]; const im = new Image(); im.src = Assets.base + 'ui/' + k + '.png'; UIIMG[k] = im; return im; }
const U = k => uiImg('AnbufenUI_Resource_' + k);

// ---------------- Girdi ----------------
const Input = (() => {
  let joy = null, keys = {}, winPtr = null;
  const st = { joy: () => {
    if (joy && joy.active) { const l = Math.hypot(joy.dx, joy.dy); if (l > 6) return { x: joy.dx, y: joy.dy }; }
    let x = 0, y = 0; if (keys.a || keys.ArrowLeft) x -= 1; if (keys.d || keys.ArrowRight) x += 1; if (keys.w || keys.ArrowUp) y -= 1; if (keys.s || keys.ArrowDown) y += 1;
    return x || y ? { x: x * 21, y: y * 11 * 1.9 } : null;
  }, get joyState() { return joy; }, keys };
  st.bind = cv => {
    const pts = new Map();
    cv.addEventListener('pointerdown', e => {
      window.SFX && SFX.init && SFX.init();
      const L = UI.toLogical(e.clientX, e.clientY);
      if (Win.isOpen()) { winPtr = { id: e.pointerId, x: L.x, y: L.y, ly: L.y, moved: 0 }; e.preventDefault(); return; }
      const hit = UI.hudHit(L.x, L.y); if (hit) { hit(); e.preventDefault(); return; }
      if (L.x < Math.max(UI.vw * 0.33, 240) && L.y > VH * 0.4 && !joy) { const R = UI.rockerPos(); let dx = L.x - R.x, dy = L.y - R.y; const l = Math.hypot(dx, dy); if (l > 48) { dx = dx / l * 48; dy = dy / l * 48; } joy = { id: e.pointerId, ox: R.x, oy: R.y, dx, dy, active: true }; cv.setPointerCapture(e.pointerId); return; }
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
    });
    cv.addEventListener('pointermove', e => { if (winPtr && e.pointerId === winPtr.id) { const L = UI.toLogical(e.clientX, e.clientY); winPtr.moved += Math.abs(L.y - winPtr.ly); if (winPtr.moved > 6) Win.drag(L.y - winPtr.ly, winPtr.x, winPtr.y); winPtr.ly = L.y; return; }
      if (joy && e.pointerId === joy.id) { const L = UI.toLogical(e.clientX, e.clientY); let dx = L.x - joy.ox, dy = L.y - joy.oy; const l = Math.hypot(dx, dy), mx = 48; if (l > mx) { dx = dx / l * mx; dy = dy / l * mx; } joy.dx = dx; joy.dy = dy; } });
    const end = e => { if (winPtr && e.pointerId === winPtr.id) { const w = winPtr; winPtr = null; if (w.moved <= 6 && e.type === 'pointerup') Win.tap(w.x, w.y); return; }
      if (joy && e.pointerId === joy.id) joy = null; const s = pts.get(e.pointerId); if (s) { UI.cancelAssign(); pts.delete(e.pointerId); if (Math.hypot(e.clientX - s.x, e.clientY - s.y) < 12 && UI.mode === 'play' && !UI.panelOpen()) tapWorld(e.clientX, e.clientY); } };
    cv.addEventListener('pointerup', end); cv.addEventListener('pointercancel', end);
    addEventListener('keydown', e => { if (e.target.tagName === 'INPUT') return; const k = e.key.length === 1 ? e.key.toLowerCase() : e.key; keys[k] = true;
      if (UI.mode !== 'play') return;
      if ('123456'.includes(k)) useSkill(+k - 1); if (k === 'q') useItem('hp1'); if (k === 'e') useItem('mp1');
      if (k === 'Tab' || k === '9') { e.preventDefault(); cycleTarget(); } if (k === 'b' || k === '#') UI.open('bag'); if (k === 'c') UI.open('char'); if (k === 'm') UI.open('map'); if (k === 'j') UI.open('quest');
      if (k === ' ') { e.preventDefault(); UI.attack(); } if (k === 'Escape') UI.closeAll(); });
    addEventListener('keyup', e => { const k = e.key.length === 1 ? e.key.toLowerCase() : e.key; keys[k] = false; });
  };
  return st;
})();

// ---------------- Arayüz ----------------
const UI = (() => {
  const cv = $('#game'), ctx = cv.getContext('2d');
  let scale = 1, vw = 640, dpr = 1, mode = 'boot';
  const floats = [], logs = [], hud = [];
  let toastMsg = null, toastT = 0, zoneMsg = null, zoneT = 0, lvlT = 0, lvlN = 0, hurtT = 0, fadeOn = false, fadeA = 0;
  let safeL = 0, safeR = 0;
  function resize() {
    safeR = Math.min(40, (parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--sar')) || 0) * 0.5);
    safeL = Math.min(40, (parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--sal')) || 0) * 0.5);
    dpr = Math.min(devicePixelRatio || 1, 2);
    cv.width = innerWidth * dpr; cv.height = innerHeight * dpr;
    scale = cv.height / VH; vw = cv.width / scale;
    $('#rotate').classList.toggle('hidden', innerWidth >= innerHeight);
  }
  addEventListener('resize', resize); resize();
  const toLogical = (cx, cy) => ({ x: cx * dpr / scale, y: cy * dpr / scale });
  function toWorld(cx, cy) { const L = toLogical(cx, cy); return { x: L.x + Game.cam.x - vw / 2, y: L.y + Game.cam.y - VH / 2 }; }

  // ---------- dünya çizimi ----------
  function drawWorld() {
    const map = Game.map, ox = Math.round((Game.cam.x - vw / 2) * scale) / scale, oy = Math.round((Game.cam.y - VH / 2) * scale) / scale; // ekran pikseline yuvarla: akıcı kaydırma
    ctx.fillStyle = '#000'; ctx.fillRect(0, 0, vw, VH);
    // zemin
    const sx = Math.max(0, ox), sy = Math.max(0, oy), ex = Math.min(map.pw, ox + vw), ey = Math.min(map.ph, oy + VH);
    if (ex > sx && ey > sy) ctx.drawImage(map.ground, sx, sy, ex - sx, ey - sy, sx - ox, sy - oy, ex - sx, ey - sy);
    // nesneler ve varlıklar derinliğe göre
    const list = [];
    for (const o of map.objs) {
      if (o.X < ox - 350 || o.X > ox + vw + 350 || o.Y < oy - 40 || o.Y > oy + VH + 450) continue;
      if (o.flat) { o.sp.draw(ctx, o.anim, Game.time * TICK, o.X - ox, o.Y - oy); continue; }
      list.push([o.depth, o]);
    }
    for (const e of Game.ents) { const X = e.X, Y = e.Y; if (X < ox - 100 || X > ox + vw + 100 || Y < oy - 20 || Y > oy + VH + 150) continue; list.push([e.x + e.y + 0.01, e]); }
    list.sort((a, b) => a[0] - b[0]);
    for (const [, o] of list) {
      if (o.kind === 'obj') o.sp.draw(ctx, o.anim, Game.time * TICK, o.X - ox, o.Y - oy);
      else {
        const X = o.X - ox, Y = o.Y - oy;
        if (o === Game.target) { ctx.strokeStyle = '#e03020'; ctx.lineWidth = 1.5; ctx.beginPath(); ctx.ellipse(X, Y, 15, 7, 0, 0, 7); ctx.stroke(); }
        if (o.kind !== 'npc' || !o.hidden) { ctx.fillStyle = 'rgba(0,0,0,.35)'; ctx.beginPath(); ctx.ellipse(X, Y, 11, 5, 0, 0, 7); ctx.fill(); }
        o.draw(ctx, X, Y);
      }
    }
    for (const f of Game.fx) f.draw(ctx, map.px(f.x, f.y) - ox, map.py(f.x, f.y) - oy);
    // isimler ve işaretler
    ctx.textAlign = 'center'; ctx.font = '10px "Noto Sans", sans-serif';
    for (const e of Game.ents) {
      const X = e.X - ox, Y = e.Y - oy; if (X < -60 || X > vw + 60 || Y < -20 || Y > VH + 100) continue;
      if (e.kind === 'npc' && !e.hidden && (!e.dummy || e.node)) {
        const mk = npcMark(e.cn);
        if (!e.pickup) text(e.name, X, Y - 62, '#9cf58a');
        if (mk) { ctx.font = 'bold 18px serif'; text(mk, X, Y - 74 + Math.sin(Game.time * 4) * 2, '#ffd23a'); ctx.font = '10px "Noto Sans", sans-serif'; }
        if (e.pickup && QUESTS.some(q => q.type === 'pickup' && q.node === e.cn && Game.P.quests[q.id] && !Game.P.quests[q.id].ready)) { ctx.font = 'bold 14px serif'; text('✦', X, Y - 30 + Math.sin(Game.time * 5) * 2, '#ffe060'); ctx.font = '10px "Noto Sans", sans-serif'; }
      } else if (e.kind === 'mob' && !e.dead) {
        const show = e === Game.target || e.aggro || e.d.rank || e.hp < e.maxHp;
        if (show) {
          const n = trName(e.name);
          text(n + ' Sv' + e.d.lv, X, Y - 58, e.d.rank === 2 ? '#e890ff' : e.d.rank ? '#ffb050' : e.d.lv > Game.P.lv + 3 ? '#ff6040' : '#f0e0d0');
          ctx.fillStyle = '#000'; ctx.fillRect(X - 16, Y - 54, 32, 3); ctx.fillStyle = '#d02010'; ctx.fillRect(X - 16, Y - 54, 32 * Math.max(0, e.hp / e.maxHp), 3);
        }
      } else if (e.kind === 'player') text(Game.P.name, X, Y - 64, '#ffe48a');
    }
    // uçan sayılar
    for (let i = floats.length - 1; i >= 0; i--) {
      const f = floats[i]; f.t += 1 / 60; if (f.t > 1.1) { floats.splice(i, 1); continue; }
      const X = Game.map.px(f.e.x, f.e.y) - ox, Y = Game.map.py(f.e.x, f.e.y) - oy - 50 - f.t * 26;
      ctx.globalAlpha = f.t < 0.8 ? 1 : (1.1 - f.t) / 0.3; ctx.font = `bold ${Math.round(12 * f.s)}px "Noto Sans", sans-serif`; text(f.txt, X, Y, f.c); ctx.globalAlpha = 1;
    }
  }
  function text(s, x, y, c) { s = tx(s); ctx.lineWidth = 2.5; ctx.strokeStyle = '#000'; ctx.lineJoin = 'round'; ctx.strokeText(s, x, y); ctx.fillStyle = c; ctx.fillText(s, x, y); }

  // ---------- HUD (orijinal parçalar) ----------
  let mmCache = null, mmMap = null;
  function bar(x, y, w, h, v, colA, colB) {
    ctx.fillStyle = '#100808'; ctx.fillRect(x, y, w, h);
    const g = ctx.createLinearGradient(0, y, 0, y + h); g.addColorStop(0, colA); g.addColorStop(1, colB);
    ctx.fillStyle = g; ctx.fillRect(x + 1, y + 1, Math.max(0, (w - 2) * clamp(v, 0, 1)), h - 2);
    ctx.strokeStyle = '#6a5030'; ctx.lineWidth = 1; ctx.strokeRect(x + 0.5, y + 0.5, w - 1, h - 1);
  }
  const HS = 1.1;   // dokunmatik düğmelerin (yön kolu ve beceri yayı) ölçeği
  function rockerPos() { return { x: 104 * HS + safeL, y: VH - 74 * HS }; }
  function drawHud() {
    hud.length = 0;
    const P = Game.P, p = Game.player, s = stats();
    // sol üst: portre ve çubuklar
    // orijinal FORM_HEADIMG: 42x40 yuva, 7143 çerçevesi içinde 32x32 portre; yanında ince can/mana/tecrübe çizgileri
    const por = uiImg('Portrait_' + P.face), hk = 1.25, hx = 3, hy = 3;
    ctx.save(); ctx.translate(hx, hy); ctx.scale(hk, hk);
    const hf = U(7143); if (hf.complete && hf.naturalWidth) ctx.drawImage(hf, 2, 2, 40, 38);
    if (por.complete && por.naturalWidth) ctx.drawImage(por, 6, 6, 32, 30);
    ctx.fillStyle = 'rgba(0,0,0,.75)'; ctx.fillRect(26, 29, 14, 10); ctx.textAlign = 'center'; ctx.font = 'bold 8px "Noto Sans", sans-serif'; text(String(P.lv), 33, 37, '#ffe48a');
    ctx.restore();
    const bx0 = hx + 44 * hk + 2;
    ctx.textAlign = 'left'; ctx.font = 'bold 10px "Noto Sans", sans-serif'; text(P.name, bx0, 14, '#ffe48a');
    const thin = (y, v, c) => { ctx.fillStyle = 'rgba(0,0,0,.7)'; ctx.fillRect(bx0, y, 92, 5); ctx.fillStyle = c; ctx.fillRect(bx0 + 1, y + 1, 90 * clamp(v, 0, 1), 3); };
    thin(18, p.hp / s.hp, '#e02818'); thin(25, p.mp / s.mp, '#2a58e8'); thin(32, P.xp / xpNeed(P.lv), '#d8b030');
    ctx.font = '8px "Noto Sans", sans-serif'; text(`${Math.ceil(p.hp)}/${s.hp}`, bx0 + 96, 23, '#ffb0a0'); text(`${Math.floor(p.mp)}/${s.mp}`, bx0 + 96, 31, '#a8c0ff');
    // "Karakter" düğmesi: soldaki sekmeli menüyü açar (Karakter, Çanta, Beceri, Görev, Harita, Ayarlar)
    { const kx = 3, ky = 56, kw = 54, kh = 15; ctx.fillStyle = 'rgba(0,0,0,.7)'; ctx.fillRect(kx, ky, kw, kh); ctx.strokeStyle = '#8a6a30'; ctx.lineWidth = 1; ctx.strokeRect(kx + 0.5, ky + 0.5, kw - 1, kh - 1);
      ctx.textAlign = 'center'; ctx.font = 'bold 9px "Noto Sans", sans-serif'; text('Karakter ▸', kx + kw / 2, ky + 11, '#ffe48a'); hud.push([kx - 2, ky - 2, kw + 4, kh + 6, () => open('hub')]); }
    hud.push([2, 2, 56, 52, () => open('hub')]);
    // hedef
    const t = Game.target;
    if (t && !t.dead) {
      const w = 170, x = Math.round(vw / 2 - w / 2), y = 4, col = t.d.rank === 2 ? '#e890ff' : t.d.rank ? '#ffb050' : t.d.lv > P.lv + 3 ? '#ff6040' : '#f0e0d0';
      ctx.fillStyle = 'rgba(0,0,0,.72)'; ctx.fillRect(x, y, w, 30);
      ctx.fillStyle = '#9f998f'; ctx.fillRect(x, y, w, 1); ctx.fillRect(x, y + 29, w, 1); ctx.fillStyle = '#4b4547'; ctx.fillRect(x, y + 1, 1, 28); ctx.fillRect(x + w - 1, y + 1, 1, 28);
      ctx.textAlign = 'left'; ctx.font = 'bold 10px "Noto Sans", sans-serif'; text(trName(t.name), x + 6, y + 12, col);
      ctx.textAlign = 'right'; ctx.font = 'bold 9px "Noto Sans", sans-serif'; text('Sv' + t.d.lv, x + w - 6, y + 12, '#ffe48a');
      ctx.fillStyle = 'rgba(0,0,0,.8)'; ctx.fillRect(x + 6, y + 17, w - 12, 7); ctx.fillStyle = '#e02818'; ctx.fillRect(x + 7, y + 18, (w - 14) * clamp(t.hp / t.maxHp, 0, 1), 5);
      ctx.textAlign = 'center'; ctx.font = '7px "Noto Sans", sans-serif'; text(`${Math.max(0, Math.ceil(t.hp))}/${t.maxHp}`, vw / 2, y + 24, '#fff');
    }
    // sağ üst: mini harita
    drawMinimap(vw - 92, 4, 88, 66);
    hud.push([vw - 92, 4, 88, 66, () => open('map')]);
    ctx.textAlign = 'right'; ctx.font = 'bold 10px "Noto Sans", sans-serif'; text(trName(Game.scene.name), vw - 6, 82, '#ffe48a');
    ctx.font = '9px "Noto Sans", sans-serif'; text(`(${Math.round(p.x)},${Math.round(p.y)})  ${P.gold} altın`, vw - 6, 94, '#ffd060');
    // görev takibi
    drawTracker();
    // sol alt: ejderha madalyonu = yürüme kolu (orijinal FORM_ROCKER, 134x134)
    const R = rockerPos(), J = Input.joyState;
    const dm = U(7002); if (dm.complete) ctx.drawImage(dm, R.x - 66 * HS, R.y - 67 * HS, 132 * HS, 134 * HS);
    { const kx = R.x + (J ? J.dx : 0), ky = R.y + (J ? J.dy : 0), kn = U(7005);   // orijinal turuncu küre (7005)
      ctx.globalCompositeOperation = 'lighter'; ctx.globalAlpha = J ? 1 : 0.8; if (kn.complete && kn.naturalWidth) ctx.drawImage(kn, kx - 19.5 * HS, ky - 19.5 * HS, 39 * HS, 39 * HS); ctx.globalAlpha = 1; ctx.globalCompositeOperation = 'source-over'; }
    // sağ alt: klasik mobil MMORPG düzeni: büyük saldırı düğmesi, çevresinde yay biçiminde beceri ve iksir yuvaları
    // (yuvalar orijinal halka görseli 7078 ile; P.quick[0] = büyük düğme, [1..3] iç yay, [4..7] dış yay)
    const ring = U(7078), ax = vw - 50 * HS - safeR, ay = VH - 50 * HS;
    const pulse = assign ? 0.5 + 0.5 * Math.sin(performance.now() / 160) : 0;
    const slotAt = (cx, cy, r, sl, fn, qi) => {
      if (assign) { ctx.fillStyle = `rgba(255,210,80,${0.25 + 0.35 * pulse})`; ctx.beginPath(); ctx.arc(cx, cy, r + 5, 0, 7); ctx.fill(); }
      if (ring.complete && ring.naturalWidth) { const w = r * 2 + 8; ctx.drawImage(ring, cx - w / 2, cy - w / 2, w, w); }
      // simge halkanın iç boşluğuna, yuvarlak kırpılarak çizilir
      const ir = r * 0.66; ctx.save(); ctx.beginPath(); ctx.arc(cx, cy, ir, 0, 7); ctx.clip(); ctx.fillStyle = '#0c0805'; ctx.fillRect(cx - ir, cy - ir, ir * 2, ir * 2);
      const k = ir * 2 / 32; ctx.translate(cx - ir, cy - ir); ctx.scale(k, k); drawSlot(sl, 0, 0); ctx.restore();
      hud.push([cx - r - 2, cy - r - 2, r * 2 + 4, r * 2 + 4, () => assign ? doAssign(qi) : fn()]);
    };
    slotAt(ax, ay, 32 * HS, P.quick[0], () => attack(), 0);
    const arc = (R, n, from, to, r, base) => { for (let i = 0; i < n; i++) { const a = (from + (to - from) * (n === 1 ? 0 : i / (n - 1))) * Math.PI / 180, qi = base + i; slotAt(ax + Math.cos(a) * R * HS, ay + Math.sin(a) * R * HS, r * HS, P.quick[qi], () => quick(qi), qi); } };
    arc(66, 3, 180, 270, 19, 1);            // iç yay: 3 beceri
    arc(112, 4, 180, 270, 18, 4);           // dış yay: 2 beceri + 2 iksir
    // hedef değiştir: yayın dışında küçük düğme
    { const tx0 = ax - 142 * HS, ty0 = ay + 22 * HS; ctx.fillStyle = 'rgba(12,8,5,.8)'; ctx.beginPath(); ctx.arc(tx0, ty0, 14, 0, 7); ctx.fill(); ctx.strokeStyle = '#b89a50'; ctx.lineWidth = 1.5; ctx.stroke();
      ctx.textAlign = 'center'; ctx.font = 'bold 13px serif'; text('◎', tx0, ty0 + 5, '#ffe48a'); hud.push([tx0 - 18, ty0 - 18, 36, 36, () => cycleTarget()]); }
    // orta alt: yarı saydam mesaj kutusu (orijinaldeki gibi)
    { const now = performance.now(), L = logs.filter(l => now - l.t < 10000).slice(-5);
      if (L.length) {
        const bx = rockerPos().x + 76 * HS, bw = Math.max(110, Math.min(360, vw - bx - 215 * HS)), bh = L.length * 11 + 6, by = VH - 6 - bh;
        ctx.fillStyle = 'rgba(0,0,0,.5)'; ctx.fillRect(bx, by, bw, bh);
        ctx.textAlign = 'left'; ctx.font = '9px "Noto Sans", sans-serif';
        L.forEach((l, i) => { ctx.globalAlpha = Math.min(1, (10000 - (now - l.t)) / 1000); text(l.m, bx + 5, by + 12 + i * 11, l.c); });
        ctx.globalAlpha = 1;
      } }
    // duyurular
    if (zoneT > 0) { zoneT -= 1 / 60; ctx.globalAlpha = Math.min(1, zoneT); ctx.textAlign = 'center'; ctx.font = 'bold 20px "Noto Serif", serif'; text(zoneMsg, vw / 2, 92, '#ffe48a'); ctx.globalAlpha = 1; }
    if (toastT > 0) { toastT -= 1 / 60; ctx.globalAlpha = Math.min(1, toastT * 2); ctx.textAlign = 'center'; ctx.font = 'bold 13px "Noto Sans", sans-serif'; text(toastMsg, vw / 2, 130, '#ffd23a'); ctx.globalAlpha = 1; }
    if (lvlT > 0) { lvlT -= 1 / 60; ctx.globalAlpha = Math.min(1, lvlT); ctx.textAlign = 'center'; ctx.font = 'bold 28px "Noto Serif", serif'; text('Seviye ' + lvlN, vw / 2, 160, '#ffe080'); ctx.globalAlpha = 1; }
    if (hurtT > 0) { hurtT -= 1 / 60; const g = ctx.createRadialGradient(vw / 2, VH / 2, VH * 0.3, vw / 2, VH / 2, vw * 0.6); g.addColorStop(0, 'rgba(160,0,0,0)'); g.addColorStop(1, `rgba(160,0,0,${hurtT})`); ctx.fillStyle = g; ctx.fillRect(0, 0, vw, VH); }
  }
  function drawSlot(sl, x, y) {
    const P = Game.P, p = Game.player;
    if (!sl) return;
    if (sl[0] === 's') {
      const i = +sl.slice(1), sk = CLS[P.cls].skills[i]; if (!sk) return;
      const im = uiImg(`icon_res_${sk.ik || 'skill'}_${sk.icon}`); if (im.complete && im.naturalWidth) ctx.drawImage(im, x, y, 32, 32);
      if (!skRank(sk)) { ctx.fillStyle = 'rgba(0,0,0,.7)'; ctx.fillRect(x, y, 32, 32); if (P.lv < sk.lv) { ctx.textAlign = 'center'; ctx.font = '8px sans-serif'; text('Sv' + sk.lv, x + 16, y + 20, '#ccc'); } return; }
      const cd = p.cds[sk.id] || 0; if (cd > 0) { ctx.fillStyle = 'rgba(0,0,0,.65)'; ctx.fillRect(x, y + 32 * (1 - cd / sk.cd), 32, 32 * cd / sk.cd); ctx.textAlign = 'center'; ctx.font = 'bold 11px sans-serif'; text(Math.ceil(cd), x + 16, y + 21, '#fff'); }
      if (p.mp < sk.mp) { ctx.fillStyle = 'rgba(0,30,120,.45)'; ctx.fillRect(x, y, 32, 32); }
    } else {
      const id = sl.slice(2), it = ITEMS[id]; if (!it) return;
      const im = uiImg('icon_res_item_' + it.icon); if (im.complete) ctx.drawImage(im, x, y, 32, 32);
      ctx.textAlign = 'right'; ctx.font = 'bold 9px sans-serif'; text(countItem(id), x + 31, y + 31, '#fff');
    }
  }
  // kısayol atama: pencereden "Kısayol" seçilince yay yuvaları parlar, dokunulan yuvaya yerleşir
  let assign = null;
  function startAssign(sl, name) { assign = { sl, name }; closeAll(); toastMsg = tx('Bir yuvaya dokun') + ': ' + name; toastT = 3; }
  function doAssign(qi) { const P = Game.P, sl = assign.sl; P.quick = P.quick.map(q => q === sl ? null : q); P.quick[qi] = sl; assign = null; SFX.play('repair', 0.5); save(); toastMsg = tx('Kısayola yerleşti.'); toastT = 1.5; }
  function cancelAssign() { if (assign) { assign = null; toastT = 0; } }
  function quick(i) { const sl = Game.P.quick[i]; if (!sl) return; if (sl[0] === 's') useSkill(+sl.slice(1)); else useItem(sl.slice(2)); }
  function attack() { const p = Game.player; const t = Game.target && !Game.target.dead ? Game.target : nearestMob(9); if (t) { setTarget(t); p.path = null; } else log('Yakında hedef yok.'); }
  function drawMinimap(x, y, w, h) {
    const map = Game.map;
    if (mmMap !== map) {
      mmMap = map; mmCache = document.createElement('canvas'); const k = 0.18; mmCache.width = map.pw * k; mmCache.height = map.ph * k;
      const c = mmCache.getContext('2d'); c.drawImage(map.ground, 0, 0, mmCache.width, mmCache.height);
    }
    ctx.save(); ctx.fillStyle = '#000'; ctx.fillRect(x, y, w, h); ctx.beginPath(); ctx.rect(x, y, w, h); ctx.clip();
    const k = 0.18, cx = Game.player.X * k, cy = Game.player.Y * k;
    ctx.drawImage(mmCache, x + w / 2 - cx, y + h / 2 - cy);
    for (const e of Game.ents) { if (e.dead || e.hidden) continue; const ex = x + w / 2 + (e.X * k - cx), ey = y + h / 2 + (e.Y * k - cy); ctx.fillStyle = e.kind === 'npc' ? (npcMark(e.cn) ? '#ffd23a' : '#60e070') : e.kind === 'mob' ? '#ff4030' : '#fff'; ctx.fillRect(ex - 1, ey - 1, e.kind === 'player' ? 3 : 2, e.kind === 'player' ? 3 : 2); }
    for (const r of map.regionsOf(1)) { const X = map.px((r[2] + r[4]) / 2, (r[3] + r[5]) / 2) * k, Y = map.py((r[2] + r[4]) / 2, (r[3] + r[5]) / 2) * k; ctx.fillStyle = '#b080ff'; ctx.fillRect(x + w / 2 + X - cx - 2, y + h / 2 + Y - cy - 2, 4, 4); }
    ctx.restore(); ctx.strokeStyle = '#a88a48'; ctx.lineWidth = 2; ctx.strokeRect(x, y, w, h);
  }
  function drawTracker() {
    const P = Game.P; const act = QUESTS.filter(q => P.quests[q.id]).slice(0, 3);
    let y = 86; ctx.textAlign = 'left';
    const avail = QUESTS.filter(q => questState(q) === 'new').slice(0, 1);
    for (const q of act) {
      const st = P.quests[q.id]; ctx.font = 'bold 9px "Noto Sans", sans-serif'; text(q.title, 6, y, '#ffd23a'); y += 10;
      ctx.font = '8.5px "Noto Sans", sans-serif';
      const prog = st.ready ? `Tamam: ${trName(q.to)} ile konuş` : q.type === 'kill' ? `${trName(q.target)}: ${st.n}/${q.count}` : (q.type === 'collect' || q.type === 'pickup') ? `${q.item}: ${st.n}/${q.count}` : q.goal;
      text(prog.length > 44 ? prog.slice(0, 43) + '…' : prog, 8, y, st.ready ? '#9cf58a' : '#e8e0d0'); y += 12;
    }
    if (!act.length && avail.length) { ctx.font = '8.5px "Noto Sans", sans-serif'; text(`! ${trName(avail[0].giver)} sana görev verecek`, 6, y, '#ffd23a'); }
    hud.push([0, 76, 180, Math.max(20, y - 76), () => open('quest')]);
  }
  function hudHit(x, y) { if (mode !== 'play' || panelOpen()) return null; for (let i = hud.length - 1; i >= 0; i--) { const [a, b, w, h, f] = hud[i]; if (x >= a && x <= a + w && y >= b && y <= b + h) return f; } return null; }

  // ---------- paneller (DOM, orijinal çerçeve görselleriyle) ----------
  const panel = $('#panel'), pbody = $('#pbody'), ptitle = $('#ptitle');
  let cur = null, sel = null, shopNpc = null, shopTab = 0;
  const itemBox = (id, act) => { const it = ITEMS[id]; if (!it) return '';
    const why = it.slot ? canEquip(it) : null;
    const st = it.st ? Object.entries(it.st).map(([k, v]) => `<span>${STATN[k] || k} +${v}</span>`).join('') : '';
    return `<div class="ibox"><img src="${iconSrc(it)}"><div><b>${esc(it.name)}</b>
      <small>${it.slot ? `${SLOTS.find(x => x[0] === it.slot)[1]} · ${it.cls ? TR.cls[it.cls] : 'Tüm sınıflar'} · <i class="${Game.P.lv < it.lv ? 'bad' : ''}">Seviye ${it.lv}</i>` : esc(it.desc || '')}</small>
      <div class="ist">${st}</div>${why ? `<small class="bad">${why}</small>` : ''}</div></div><div class="iact">${act}</div>`; };
  function panelOpen() { return Win.isOpen() || !panel.classList.contains('hidden') || !$('#dlg').classList.contains('hidden'); }
  function closeAll() { Win.close(); panel.classList.add('hidden'); $('#dlg').classList.add('hidden'); cur = null; sel = null; shopNpc = null; }
  function open(kind) {
    if (mode !== 'play') return;
    if (kind === 'bag') { const sh = shopNpc; closeAll(); Win.open('bag', sh ? { shop: sh } : {}); return; }
    if (kind === 'char') { closeAll(); Win.open('role'); return; }
    if (kind === 'quest') { closeAll(); Win.open('task'); return; }
    if (kind === 'skill') { closeAll(); Win.open('skill'); return; }
    if (kind === 'menu') { closeAll(); Win.open('menu'); return; }
    if (kind === 'sys' || kind === 'map' || kind === 'hub') { closeAll(); Win.open(kind); return; }
    if (kind !== cur) sel = null; if (kind !== 'bag' && kind !== 'shop') shopNpc = null;
    cur = kind; panel.classList.remove('hidden'); SFX.play('menu_appear', 0.5); render(); if (kind === 'bag') questFlag('openBag');
  }
  function render() {
    const P = Game.P, s = stats(); let h = '', title = '';
    if (cur === 'menu') {
      title = 'Ana Menü';
      const items = [['char', 'Karakter', 0], ['bag', 'Çanta', 1], ['skill', 'Beceriler', 2], ['quest', 'Görevler', 3], ['map', 'Dünya Haritası', 15], ['sys', 'Ayarlar', 20]];
      h = `<div class="menu">${items.map(([k, n, ic]) => `<button class="mbtn" data-open="${k}"><span class="mic" style="background-position:-${ic * 32}px 0"></span>${n}</button>`).join('')}</div>`;
    } else if (cur === 'char') {
      title = 'Karakter';
      h = `<div class="charp"><div class="sil"><img src="${Assets.base}ui/Portrait_${P.face}.png"></div><div class="cstats">
        <div class="cname">${esc(P.name)}</div><div class="csub">${TR.race[P.race]} · ${TR.cls[P.cls]} · Seviye ${P.lv}</div>
        <table>${[['Can', s.hp], ['Mana', s.mp], ['Saldırı', s.atk], ['Savunma', s.def], ['Kritik', (8 + s.crit) + '%'], ['Tecrübe', `${P.xp}/${xpNeed(P.lv)}`], ['Altın', P.gold]].map(([a, b]) => `<tr><td>${a}</td><td>${b}</td></tr>`).join('')}</table>
        </div></div>
        <div class="eqgrid">${SLOTS.map(([k, n]) => { const id = P.eq[k], it = id && ITEMS[id]; return `<button class="slot eq ${sel === 'eq:' + k ? 'on' : ''}" data-sel="eq:${k}">${it ? `<img src="${iconSrc(it)}">` : `<span>${n}</span>`}</button>`; }).join('')}</div>
        ${sel && sel.startsWith('eq:') && P.eq[sel.slice(3)] ? itemBox(P.eq[sel.slice(3)], `<button class="obtn" data-act="uneq" data-slot="${sel.slice(3)}">Çıkar</button>`) : '<p class="hint">Bir ekipman yuvasına dokun. Yeni ekipmanı çantadan giyebilirsin.</p>'}`;
    } else if (cur === 'bag') {
      title = 'Çanta';
      const qi = []; for (const q of QUESTS) { const st = P.quests[q.id]; if (st && q.item && st.n) qi.push([q.item, st.n]); }
      h = `<div class="gold">${P.gold} altın</div><div class="grid">${P.bag.map(b => { const it = ITEMS[b.id]; if (!it) return ''; return `<button class="slot ${sel === b.id ? 'on' : ''} ${it.slot && canEquip(it) ? 'no' : ''}" data-sel="${b.id}"><img src="${iconSrc(it)}"><em>${b.n > 1 ? b.n : ''}</em></button>`; }).join('')}
        ${qi.map(([n, c]) => `<div class="slot q" title="${esc(n)}"><img src="${Assets.base}ui/icon_res_item_${Q_ICONS[n] || 1125}.png"><em>${c}</em></div>`).join('')}
        ${'<div class="slot e"></div>'.repeat(Math.max(0, 24 - P.bag.length - qi.length))}</div>`;
      if (sel && countItem(sel)) { const it = ITEMS[sel]; h += itemBox(sel, (it.slot ? `<button class="obtn" data-act="use" data-id="${sel}">Giy</button>` : it.use || it.growth ? `<button class="obtn" data-act="use" data-id="${sel}">${it.growth ? 'Aç' : 'Kullan'}</button>` : '') + (shopNpc && !it.quest && !it.growth ? `<button class="obtn" data-act="sell" data-id="${sel}">Sat (+${it.sell || 1})</button>` : '')); }
      else h += `<p class="hint">Bir eşyaya dokun: bilgisini gör, kullan ya da giy.${shopNpc ? ' Satmak için de seçebilirsin.' : ''} Görev eşyaları (sarı çerçeve) görev bitince teslim edilir.</p>`;
    } else if (cur === 'skill') {
      title = 'Beceriler';
      const row = (sk, i) => `<div class="skr ${P.lv < sk.lv ? 'lock' : ''}"><img src="${Assets.base}ui/icon_res_${sk.ik || 'skill'}_${sk.icon}.png"><div><b>${sk.name}</b> <small>${sk.pas ? '(edilgen)' : ''}</small><br><small>${esc(sk.desc || '')}</small><br><small>${sk.pas ? '' : `${sk.mp} mana · ${sk.cd} sn · `}${P.lv < sk.lv ? sk.lv + '. seviyede açılır' : sk.pas ? 'Etkin' : 'Kısayol ' + (i + 1)}</small></div></div>`;
      const all = CLS[P.cls].skills; h = `<div class="skgrid">${all.map((sk, i) => row(sk, i)).join('')}</div>`;
    } else if (cur === 'quest') {
      title = 'Görevler';
      const act = QUESTS.filter(q => P.quests[q.id]);
      h = act.length ? act.map(q => { const st = P.quests[q.id]; return `<div class="qr"><b>${q.title}</b><p>${esc(q.goal)}</p><small>${st.ready ? 'Tamamlandı — ' + trName(q.to) + ' ile konuş' : (q.count ? `${st.n}/${q.count}` : '')} · Teslim: ${trName(q.to)}</small></div>`; }).join('') : '<p>Aktif görev yok. Başında ! olan kişilerle konuş.</p>';
      h += `<p class="hint">Tamamlanan görev: ${Object.keys(P.done).length}</p>`;
    } else if (cur === 'map') {
      title = 'Dünya Haritası';
      h = `<div class="wmap"><img src="${Assets.base}ui/UIData_2047.png"><img src="${Assets.base}ui/UIData_2048.png"></div><p class="hint">Şu an: ${trName(Game.scene.name)}</p>`;
    } else if (cur === 'shop') {
      const tabs = SHOPS[shopNpc] || []; title = trName(shopNpc); if (shopTab >= tabs.length + 1) shopTab = 0;
      h = `<div class="tabs">${tabs.map(([n], i) => `<button class="${i === shopTab ? 'on' : ''}" data-tab="${i}">${n}</button>`).join('')}<button class="${shopTab === tabs.length ? 'on' : ''}" data-tab="${tabs.length}">Sat</button><span class="gold">${P.gold} altın</span></div>`;
      if (shopTab < tabs.length) {
        const ids = tabs[shopTab][1].slice().sort((a, b) => { const A = ITEMS[a], B = ITEMS[b]; return ((A.cls && A.cls !== P.cls) - (B.cls && B.cls !== P.cls)) || (A.lv || 0) - (B.lv || 0); });
        h += `<div class="shop">${ids.map(id => { const it = ITEMS[id], bad = it.slot && canEquip(it); return `<button class="srow ${sel === 's:' + id ? 'on' : ''} ${bad ? 'no' : ''}" data-sel="s:${id}"><img src="${iconSrc(it)}"><span>${esc(it.name)}${it.lv ? ` <small>Sv${it.lv}</small>` : ''}</span><em>${it.price}</em></button>`; }).join('')}</div>`;
        if (sel && sel.startsWith('s:')) { const id = sel.slice(2), it = ITEMS[id]; h += itemBox(id, `<button class="obtn" data-act="buy" data-id="${id}" data-n="1">Satın al (${it.price})</button>${it.use ? `<button class="obtn" data-act="buy" data-id="${id}" data-n="10">10 tane (${it.price * 10})</button>` : ''}`); }
      } else { const sh = shopNpc; closeAll(); Win.open('bag', { shop: sh }); return; }
    } else if (cur === 'sys') {
      title = 'Ayarlar';
      h = `<div class="iact"><button class="obtn" data-act="tsfx">Ses efektleri: ${SFX.opt.sfx ? 'Açık' : 'Kapalı'}</button><button class="obtn" data-act="tmus">Müzik: ${SFX.opt.music ? 'Açık' : 'Kapalı'}</button></div>
        <div class="iact"><button class="obtn" data-act="lang">${LANG === 'tr' ? 'Language: English' : 'Dil: Türkçe'}</button></div>
        <div class="iact"><button class="obtn" data-act="totitle">Giriş ekranına dön</button><button class="obtn" data-act="newchar">Yeni karakter oluştur</button></div><p class="hint">Oyun otomatik kaydedilir. Sürüm 11141708</p>`;
    }
    ptitle.textContent = tx(title); pbody.innerHTML = h; txDom(pbody);
  }
  pbody.addEventListener('click', e => {
    const b = e.target.closest('[data-open],[data-use],[data-act],[data-sel],[data-tab]'); if (!b) return;
    if (b.dataset.sel) { sel = sel === b.dataset.sel ? null : b.dataset.sel; render(); return; }
    if (b.dataset.tab) { shopTab = +b.dataset.tab; sel = null; SFX.play('skill_pageflip'); render(); return; }
    if (b.dataset.act === 'tsfx') { SFX.setSfx(!SFX.opt.sfx); render(); return; }
    if (b.dataset.act === 'tmus') { SFX.setMusic(!SFX.opt.music); render(); return; }
    const A = b.dataset.act;
    if (A === 'use') { useItem(b.dataset.id); if (!countItem(b.dataset.id)) sel = null; render(); return; }
    if (A === 'sell') { sellItem(b.dataset.id); if (!countItem(b.dataset.id)) sel = null; render(); return; }
    if (A === 'buy') { buyItem(b.dataset.id, +b.dataset.n); render(); return; }
    if (A === 'uneq') { unequip(b.dataset.slot); sel = null; render(); return; }
    if (b.dataset.open) { open(b.dataset.open); return; }
    if (b.dataset.use) { useItem(b.dataset.use); render(); return; }
    if (b.dataset.act === 'lang') { save(); setLang(LANG === 'tr' ? 'en' : 'tr'); return; }
    if (b.dataset.act === 'totitle') { save(); location.reload(); return; }
    if (b.dataset.act === 'newchar') { if (b.dataset.sure) { localStorage.removeItem(SAVE_KEY); location.reload(); } else { b.dataset.sure = 1; b.textContent = tx('Eminim, sil'); } }
  });
  $('#pclose').onclick = closeAll;

  // ---------- NPC diyaloğu ----------
  let dlgNpc = null, dlgQ = null;
  function dialog(n) {
    closeAll(); Win.open('npc', { npc: n });
  }
  function renderDlg() {
    const n = dlgNpc, P = Game.P; $('#dname').textContent = n.name;
    let txt = TR.greet[n.cn] || '...', btns = '';
    if (dlgQ) {
      const q = dlgQ, st = questState(q);
      if (st === 'new') { txt = q.text; btns = `<button data-q="accept">${esc(q.ok || 'Kabul et')}</button><button data-q="back">Daha sonra</button>`; }
      else if (st === 'ready' && q.to === n.cn) { txt = q.done; btns = `<button data-q="complete">Tamamla</button>`; }
      else { txt = q.wait || q.goal; btns = `<button data-q="back">Tamam</button>`; }
    } else {
      const qs = questsFor(n.cn);
      btns = qs.map(q => { const st = questState(q); return `<button data-qid="${q.id}">${st === 'ready' ? '? ' : st === 'new' ? '! ' : '… '}${esc(q.title)}</button>`; }).join('');
      if (n.cn === '观林镇传送员' && (P.quests[80003] || P.done[80003])) btns += `<button data-q="tp">✦ Guanlin Kasabası'na ışınlan</button>`;
      if (SHOPS[n.cn]) btns = `<button data-q="shop">🛒 Alışveriş</button>` + btns;
      btns += `<button data-q="bye">Hoşça kal</button>`;
    }
    $('#dtext').textContent = txt; $('#dbtns').innerHTML = btns; txDom($('#dbtns'));
  }
  $('#dbtns').addEventListener('click', e => {
    const b = e.target.closest('button'); if (!b) return;
    if (b.dataset.qid) { dlgQ = QBY[b.dataset.qid]; renderDlg(); return; }
    const a = b.dataset.q;
    if (a === 'bye') { closeAll(); return; }
    if (a === 'shop') { const cn = dlgNpc.cn; closeAll(); shopNpc = cn; shopTab = 0; cur = 'shop'; panel.classList.remove('hidden'); render(); return; }
    if (a === 'back') { dlgQ = null; renderDlg(); return; }
    if (a === 'tp') { closeAll(); setTimeout(() => gotoScene('120005', null, [33, 20]), 300); return; }
    if (a === 'accept' && dlgQ.teleport) { acceptQuest(dlgQ); dlgQ = null; closeAll(); setTimeout(() => gotoScene('120005', null, [33, 20]), 400); return; }
    if (a === 'accept') { acceptQuest(dlgQ); if (dlgQ.type === 'talk' && dlgQ.to === dlgNpc.cn) { Game.P.quests[dlgQ.id].ready = true; } dlgQ = null; renderDlg(); return; }
    if (a === 'complete') { const q = dlgQ; completeQuest(q); dlgQ = null; if (!q.teleport) renderDlg(); else closeAll(); return; }
  });
  function say(n, t) { closeAll(); Win.open('npc', { npc: n, say: t }); return; dlgNpc = n; dlgQ = null; $('#dlg').classList.remove('hidden'); $('#dname').textContent = n.name; $('#dtext').textContent = t; $('#dbtns').innerHTML = '<button data-q="bye">Tamam</button>'; txDom($('#dbtns')); }

  // ---------- karakter oluşturma ----------
  const cre = { cls: '战士', race: '人类', sex: 'male', face: 1 };
  let creDoll = null;
  function showCreate() {
    SFX.Music.play('cover.mid');
    mode = 'create'; $('#create').classList.remove('hidden'); renderCreate();
  }
  function renderCreate() {
    const g = (cre.race === '人类' ? 0 : 2) + (cre.sex === 'male' ? 1 : 2);
    $('#cfaces').innerHTML = [1, 2, 3, 4, 5, 6, 7, 8].map(i => `<button class="face ${cre.face === i ? 'on' : ''}" data-face="${i}"><img src="${Assets.base}ui/Portrait_${g}00${i}.png"></button>`).join('');
    document.querySelectorAll('[data-cls]').forEach(b => b.classList.toggle('on', b.dataset.cls === cre.cls));
    document.querySelectorAll('[data-race]').forEach(b => b.classList.toggle('on', b.dataset.race === cre.race));
    document.querySelectorAll('[data-sex]').forEach(b => b.classList.toggle('on', b.dataset.sex === cre.sex));
    const st = STARTER[cre.cls], gf = id => ITEMS[id] && ITEMS[id].gfx;
    creDoll = new Assets.Paperdoll({ cls: cre.cls, race: cre.race, sex: cre.sex, });
  }
  $('#create').addEventListener('click', e => {
    const b = e.target.closest('button'); if (!b) return;
    if (b.dataset.cls) cre.cls = b.dataset.cls; if (b.dataset.race) cre.race = b.dataset.race; if (b.dataset.sex) cre.sex = b.dataset.sex; if (b.dataset.face) cre.face = +b.dataset.face;
    if (b.id === 'cstart') {
      const name = ($('#cname').value.trim() || 'Kahraman').slice(0, 12);
      const g = (cre.race === '人类' ? 0 : 2) + (cre.sex === 'male' ? 1 : 2);
      Game.P = newSave(name, cre.cls, cre.race, cre.sex); Game.P.face = `${g}00${cre.face}`;
      $('#create').classList.add('hidden'); start(); return;
    }
    renderCreate();
  });
  function drawCreate() {
    ctx.fillStyle = '#0c0806'; ctx.fillRect(0, 0, vw, VH);
    const lg = uiImg('UIData_2067'); if (lg.complete) ctx.drawImage(lg, 16, 8, 192 * 0.8, 72 * 0.8);
    if (creDoll) { ctx.save(); ctx.translate(vw * 0.73, 250); ctx.scale(2.2, 2.2); creDoll.draw(ctx, 'comm', 2 + (Math.floor(performance.now() / 2500) % 2), performance.now() / 120, 0, 0); ctx.restore(); }
  }

  function log(m, c) { m = tx(m); logs.push({ m, c: c === 'q' ? '#ffd23a' : c === 'loot' ? '#e8e0c8' : (c || '#e8e0d0'), t: performance.now() }); if (logs.length > 30) logs.shift(); }
  function toast(m) { toastMsg = tx(m); toastT = 2.5; }
  // ---------- akış ----------
  async function start() {
    mode = 'loading'; $('#loading').classList.remove('hidden');
    await loadScene(Game.P.scene || (Game.P.race === '精灵' ? '120205' : '120207'));
    $('#loading').classList.add('hidden'); mode = 'play';
    if (!Object.keys(Game.P.done).length && !Object.keys(Game.P.quests).length) { toast('Rehber seni bekliyor: başında ! olan kişiye dokun'); log('Sol alttaki ejderhayı parmağınla kaydırarak yürü ya da haritada bir yere dokun.', '#ffd23a'); log('Canavara dokunursan saldırırsın; sağ alttaki büyük düğme de en yakın canavara saldırır.', '#ffd23a'); }
  }
  let last = performance.now();
  function loop(now) {
    try { frame(now); } catch (err) { console.error(err); }
    requestAnimationFrame(loop);
  }
  function frame(now) {
    const dt = Math.min(0.05, (now - last) / 1000); last = now;
    ctx.setTransform(scale, 0, 0, scale, 0, 0); ctx.imageSmoothingEnabled = false;
    if (mode === 'play' && Game.map && Game.player) {
      if (!panelOpen()) update(dt);
      drawWorld(); drawHud();
      try { Win.draw(ctx, vw, VH); } catch (err) { console.error(err); Win.close(); toast('Pencere açılamadı, sayfayı yenile.'); }
      if (fadeOn || fadeA > 0) { fadeA = clamp(fadeA + (fadeOn ? dt * 5 : -dt * 3), 0, 1); ctx.fillStyle = `rgba(0,0,0,${fadeA})`; ctx.fillRect(0, 0, vw, VH); }
      if (Game.player.dead) { ctx.fillStyle = 'rgba(40,0,0,.45)'; ctx.fillRect(0, 0, vw, VH); }
    } else if (mode === 'create') drawCreate();
    
  }
  async function boot() {
    txDom(document.body); await Assets.init('assets/'); await loadItems(); await Forms.init('assets/');
    Input.bind(cv);
    for (const k of ['AnbufenUI_Resource_7005', 'AnbufenUI_Resource_7078', 'icon_res_item_1038', 'AnbufenUI_Resource_7003', 'AnbufenUI_Resource_7002', 'AnbufenUI_Resource_7009', 'UIData_2067']) uiImg(k);
    $('#loading').classList.add('hidden');
    const s = load();
    if (s) {
      // giriş ekranı: devam et ya da yeni karakter
      const T = $('#title'); T.classList.remove('hidden'); SFX.Music.play('cover.mid');
      $('#tinfo').textContent = `${s.name} · ${TR.cls[s.cls]} · Seviye ${s.lv}`;
      $('#tcont').onclick = () => { T.classList.add('hidden'); Game.P = s; start(); };
      $('#tnew').onclick = e => { const b = e.currentTarget; if (b.dataset.sure) { localStorage.removeItem(SAVE_KEY); T.classList.add('hidden'); showCreate(); } else { b.dataset.sure = 1; b.textContent = tx('Eminim: eski karakter silinsin'); } };
      $('#tlang').onclick = () => setLang(LANG === 'tr' ? 'en' : 'tr');
    } else showCreate();
    requestAnimationFrame(loop);
    window.__G = Game;
  }
  return {
    openShop(cn) { closeAll(); Win.open('shop', { shop: cn }); },
    startAssign, cancelAssign,
    boot, rockerPos, toLogical, toWorld, hudHit, open, closeAll, panelOpen, dialog, say, attack,
    get vw() { return vw; }, get mode() { return mode; },
    log, toast, zone(m) { zoneMsg = m; zoneT = 3; }, levelUp(n) { lvlN = n; lvlT = 2.5; }, hurt() { hurtT = 0.4; },
    float(e, txt, c, s = 1) { floats.push({ e, txt: tx(String(txt)), c, s, t: 0 }); }, target() { }, refresh() { if (cur) render(); },
    fade(on) { fadeOn = on; if (on) fadeA = 1; }, death() { closeAll(); setTimeout(() => Win.open('dead'), 1200); },
  };
})();
$('#revive').onclick = () => { $('#death').classList.add('hidden'); revive(); };
window.addEventListener('load', () => UI.boot().catch(e => { $('#loading').textContent = 'Hata: ' + e.message; console.error(e); }));
