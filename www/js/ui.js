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
  let joy = null, keys = {};
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
      const hit = UI.hudHit(L.x, L.y); if (hit) { hit(); e.preventDefault(); return; }
      if (L.x < UI.vw * 0.33 && L.y > VH * 0.45 && !joy) { joy = { id: e.pointerId, ox: L.x, oy: L.y, dx: 0, dy: 0, active: true }; cv.setPointerCapture(e.pointerId); return; }
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
    });
    cv.addEventListener('pointermove', e => { if (joy && e.pointerId === joy.id) { const L = UI.toLogical(e.clientX, e.clientY); let dx = L.x - joy.ox, dy = L.y - joy.oy; const l = Math.hypot(dx, dy), mx = 34; if (l > mx) { dx = dx / l * mx; dy = dy / l * mx; } joy.dx = dx; joy.dy = dy; } });
    const end = e => { if (joy && e.pointerId === joy.id) joy = null; const s = pts.get(e.pointerId); if (s) { pts.delete(e.pointerId); if (Math.hypot(e.clientX - s.x, e.clientY - s.y) < 12 && UI.mode === 'play' && !UI.panelOpen()) tapWorld(e.clientX, e.clientY); } };
    cv.addEventListener('pointerup', end); cv.addEventListener('pointercancel', end);
    addEventListener('keydown', e => { if (e.target.tagName === 'INPUT') return; const k = e.key.length === 1 ? e.key.toLowerCase() : e.key; keys[k] = true;
      if (UI.mode !== 'play') return;
      if ('1234'.includes(k)) useSkill(+k - 1); if (k === 'q') useItem('hp1'); if (k === 'e') useItem('mp1');
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
  function resize() {
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
      if (o.flat) { o.sp.draw(ctx, o.anim, Game.time * 8, o.X - ox, o.Y - oy); continue; }
      list.push([o.depth, o]);
    }
    for (const e of Game.ents) { const X = e.X, Y = e.Y; if (X < ox - 100 || X > ox + vw + 100 || Y < oy - 20 || Y > oy + VH + 150) continue; list.push([e.x + e.y + 0.01, e]); }
    list.sort((a, b) => a[0] - b[0]);
    for (const [, o] of list) {
      if (o.kind === 'obj') o.sp.draw(ctx, o.anim, Game.time * 8, o.X - ox, o.Y - oy);
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
      if (e.kind === 'npc' && !e.hidden && !e.dummy) {
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
  function text(s, x, y, c) { ctx.lineWidth = 2.5; ctx.strokeStyle = '#000'; ctx.lineJoin = 'round'; ctx.strokeText(s, x, y); ctx.fillStyle = c; ctx.fillText(s, x, y); }

  // ---------- HUD (orijinal parçalar) ----------
  let mmCache = null, mmMap = null;
  function bar(x, y, w, h, v, colA, colB) {
    ctx.fillStyle = '#100808'; ctx.fillRect(x, y, w, h);
    const g = ctx.createLinearGradient(0, y, 0, y + h); g.addColorStop(0, colA); g.addColorStop(1, colB);
    ctx.fillStyle = g; ctx.fillRect(x + 1, y + 1, Math.max(0, (w - 2) * clamp(v, 0, 1)), h - 2);
    ctx.strokeStyle = '#6a5030'; ctx.lineWidth = 1; ctx.strokeRect(x + 0.5, y + 0.5, w - 1, h - 1);
  }
  function drawHud() {
    hud.length = 0;
    const P = Game.P, p = Game.player, s = stats();
    // sol üst: portre ve çubuklar
    const por = uiImg('Portrait_' + P.face);
    ctx.drawImage(U(7009), 2, 2, 64, 60);
    if (por.complete) ctx.drawImage(por, 8, 7, 52, 50);
    ctx.fillStyle = 'rgba(0,0,0,.55)'; ctx.fillRect(66, 6, 132, 44);
    ctx.textAlign = 'left'; ctx.font = 'bold 10px "Noto Sans", sans-serif'; text(`${P.name}  Sv ${P.lv}`, 70, 17, '#ffe48a');
    bar(70, 21, 124, 9, p.hp / s.hp, '#ff6a4a', '#8a1408'); bar(70, 32, 124, 9, p.mp / s.mp, '#6aa0ff', '#142a8a');
    ctx.font = '8px "Noto Sans", sans-serif'; ctx.textAlign = 'center'; text(`${Math.ceil(p.hp)}/${s.hp}`, 132, 29, '#fff'); text(`${Math.floor(p.mp)}/${s.mp}`, 132, 40, '#fff');
    bar(70, 44, 124, 4, P.xp / xpNeed(P.lv), '#ffe080', '#a07010');
    hud.push([2, 2, 64, 60, () => open('char')]);
    // hedef
    const t = Game.target;
    if (t && !t.dead) {
      const x = vw / 2 - 80; ctx.fillStyle = 'rgba(0,0,0,.6)'; ctx.fillRect(x, 4, 160, 26);
      ctx.textAlign = 'center'; ctx.font = 'bold 10px "Noto Sans", sans-serif'; text(trName(t.name) + '  Sv' + t.d.lv, vw / 2, 15, t.d.rank ? '#ffb050' : '#f0e0d0');
      bar(x + 6, 19, 148, 7, t.hp / t.maxHp, '#ff6040', '#801008');
    }
    // sağ üst: mini harita
    drawMinimap(vw - 92, 4, 88, 66);
    hud.push([vw - 92, 4, 88, 66, () => open('map')]);
    ctx.textAlign = 'right'; ctx.font = 'bold 10px "Noto Sans", sans-serif'; text(trName(Game.scene.name), vw - 6, 82, '#ffe48a');
    ctx.font = '9px "Noto Sans", sans-serif'; text(`${P.gold} altın`, vw - 6, 94, '#ffd060');
    // görev takibi
    drawTracker();
    // alt orta: kısayol çubuğu (orijinal 7003)
    const qb = U(7003), qx = Math.round(vw / 2 - 240), qy = VH - 89;
    if (qb.complete) ctx.drawImage(qb, qx, qy);
    const slots = [66, 113, 160, 229, 276, 323, 370, 417];
    slots.forEach((cx, i) => {
      const x = qx + cx - 16, y = qy + 54 - 16, sl = P.quick[i];
      drawSlot(sl, x, y);
      hud.push([x, y, 32, 32, () => quick(i)]);
    });
    hud.push([qx + 14, qy + 40, 34, 36, () => open('menu')]);
    hud.push([qx + 430, qy + 40, 34, 36, () => open('bag')]);
    // sağ alt: ejderha madalyonu = saldırı
    const dm = U(7002), ds = 88, dx = vw - ds - 6, dy = VH - ds - 6;
    if (dm.complete) ctx.drawImage(dm, dx, dy, ds, ds * 134 / 132);
    hud.push([dx, dy, ds, ds, () => attack()]);
    // hedef değiştir
    const tx = dx - 34, ty = dy - 4; ctx.fillStyle = 'rgba(20,14,8,.75)'; ctx.beginPath(); ctx.arc(tx + 14, ty + 14, 14, 0, 7); ctx.fill(); ctx.strokeStyle = '#b89a50'; ctx.lineWidth = 1.5; ctx.stroke();
    ctx.textAlign = 'center'; ctx.font = 'bold 13px serif'; text('◎', tx + 14, ty + 19, '#ffe48a');
    hud.push([tx, ty, 28, 28, () => cycleTarget()]);
    // çanta düğmesi (telefon için)
    const bx = dx - 44, by = dy - 48, br = 19;
    ctx.fillStyle = 'rgba(20,14,8,.8)'; ctx.beginPath(); ctx.arc(bx + br, by + br, br, 0, 7); ctx.fill(); ctx.strokeStyle = '#d8b860'; ctx.lineWidth = 2; ctx.stroke();
    const bi = uiImg('icon_res_item_1038'); if (bi.complete && bi.naturalWidth) ctx.drawImage(bi, bx + br - 13, by + br - 14, 26, 26);
    ctx.textAlign = 'center'; ctx.font = 'bold 8px "Noto Sans", sans-serif'; text('Çanta', bx + br, by + br * 2 + 9, '#ffe48a');
    hud.push([bx - 4, by - 4, br * 2 + 8, br * 2 + 16, () => open('bag')]);
    // sanal kol
    const J = Input.joyState;
    if (J) { ctx.globalAlpha = 0.85; ctx.strokeStyle = '#c8a860'; ctx.lineWidth = 2; ctx.fillStyle = 'rgba(30,20,10,.35)'; ctx.beginPath(); ctx.arc(J.ox, J.oy, 34, 0, 7); ctx.fill(); ctx.stroke();
      const g = ctx.createRadialGradient(J.ox + J.dx - 4, J.oy + J.dy - 4, 2, J.ox + J.dx, J.oy + J.dy, 16); g.addColorStop(0, '#f0d890'); g.addColorStop(1, '#6a4a14'); ctx.fillStyle = g; ctx.beginPath(); ctx.arc(J.ox + J.dx, J.oy + J.dy, 15, 0, 7); ctx.fill(); ctx.globalAlpha = 1; }
    else if (matchMedia('(pointer:coarse)').matches) { ctx.globalAlpha = 0.35; ctx.strokeStyle = '#c8a860'; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(60, VH - 70, 34, 0, 7); ctx.stroke(); ctx.globalAlpha = 1; }
    // günlük
    ctx.textAlign = 'left'; ctx.font = '9px "Noto Sans", sans-serif';
    const now = performance.now(); let ly = VH - 98;
    for (let i = logs.length - 1; i >= 0 && ly > VH - 170; i--) { const L = logs[i]; if (now - L.t > 8000) continue; ctx.globalAlpha = Math.min(1, (8000 - (now - L.t)) / 1000); text(L.m, 6, ly, L.c); ly -= 11; }
    ctx.globalAlpha = 1;
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
      const im = uiImg('icon_res_skill_' + sk.icon); if (im.complete) ctx.drawImage(im, x, y, 32, 32);
      if (P.lv < sk.lv) { ctx.fillStyle = 'rgba(0,0,0,.7)'; ctx.fillRect(x, y, 32, 32); ctx.textAlign = 'center'; ctx.font = '8px sans-serif'; text('Sv' + sk.lv, x + 16, y + 20, '#ccc'); return; }
      const cd = p.cds[sk.id] || 0; if (cd > 0) { ctx.fillStyle = 'rgba(0,0,0,.65)'; ctx.fillRect(x, y + 32 * (1 - cd / sk.cd), 32, 32 * cd / sk.cd); ctx.textAlign = 'center'; ctx.font = 'bold 11px sans-serif'; text(Math.ceil(cd), x + 16, y + 21, '#fff'); }
      if (p.mp < sk.mp) { ctx.fillStyle = 'rgba(0,30,120,.45)'; ctx.fillRect(x, y, 32, 32); }
    } else {
      const id = sl.slice(2), it = ITEMS[id]; if (!it) return;
      const im = uiImg('icon_res_item_' + it.icon); if (im.complete) ctx.drawImage(im, x, y, 32, 32);
      ctx.textAlign = 'right'; ctx.font = 'bold 9px sans-serif'; text(countItem(id), x + 31, y + 31, '#fff');
    }
  }
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
    let y = 70; ctx.textAlign = 'left';
    const avail = QUESTS.filter(q => questState(q) === 'new').slice(0, 1);
    for (const q of act) {
      const st = P.quests[q.id]; ctx.font = 'bold 9px "Noto Sans", sans-serif'; text(q.title, 6, y, '#ffd23a'); y += 10;
      ctx.font = '8.5px "Noto Sans", sans-serif';
      const prog = st.ready ? `Tamam: ${trName(q.to)} ile konuş` : q.type === 'kill' ? `${trName(q.target)}: ${st.n}/${q.count}` : (q.type === 'collect' || q.type === 'pickup') ? `${q.item}: ${st.n}/${q.count}` : q.goal;
      text(prog.length > 44 ? prog.slice(0, 43) + '…' : prog, 8, y, st.ready ? '#9cf58a' : '#e8e0d0'); y += 12;
    }
    if (!act.length && avail.length) { ctx.font = '8.5px "Noto Sans", sans-serif'; text(`! ${trName(avail[0].giver)} sana görev verecek`, 6, y, '#ffd23a'); }
    hud.push([0, 62, 180, Math.max(20, y - 60), () => open('quest')]);
  }
  function hudHit(x, y) { if (mode !== 'play' || panelOpen()) return null; for (let i = hud.length - 1; i >= 0; i--) { const [a, b, w, h, f] = hud[i]; if (x >= a && x <= a + w && y >= b && y <= b + h) return f; } return null; }

  // ---------- paneller (DOM, orijinal çerçeve görselleriyle) ----------
  const panel = $('#panel'), pbody = $('#pbody'), ptitle = $('#ptitle');
  let cur = null;
  function panelOpen() { return !panel.classList.contains('hidden') || !$('#dlg').classList.contains('hidden'); }
  function closeAll() { panel.classList.add('hidden'); $('#dlg').classList.add('hidden'); cur = null; }
  function open(kind) {
    if (mode !== 'play') return;
    cur = kind; panel.classList.remove('hidden'); render(); if (kind === 'bag') questFlag('openBag');
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
        <table>${[['Can', s.hp], ['Mana', s.mp], ['Saldırı', s.atk], ['Savunma', s.def], ['Tecrübe', `${P.xp}/${xpNeed(P.lv)}`], ['Altın', P.gold]].map(([a, b]) => `<tr><td>${a}</td><td>${b}</td></tr>`).join('')}</table>
        <div class="gear">Silah kademesi: <b>${P.gear.weap || '-'}</b> · Zırh: <b>${P.gear.body || '-'}</b> · Başlık: <b>${P.gear.head || '-'}</b></div></div></div>`;
    } else if (cur === 'bag') {
      title = 'Çanta';
      const qi = []; for (const q of QUESTS) { const st = P.quests[q.id]; if (st && q.item && st.n) qi.push([q.item, st.n]); }
      h = `<div class="grid">${P.bag.map(b => `<button class="slot" data-use="${b.id}" title="${esc(ITEMS[b.id].name)}"><img src="${Assets.base}ui/icon_res_item_${ITEMS[b.id].icon}.png"><em>${b.n}</em></button>`).join('')}
        ${qi.map(([n, c]) => `<div class="slot q" title="${esc(n)}"><img src="${Assets.base}ui/icon_res_item_${Q_ICONS[n] || 1125}.png"><em>${c}</em></div>`).join('')}
        ${'<div class="slot e"></div>'.repeat(Math.max(0, 24 - P.bag.length - qi.length))}</div><p class="hint">Bir eşyaya dokunarak kullan. Görev eşyaları (sarı çerçeve) görev tamamlanınca teslim edilir.</p>`;
    } else if (cur === 'skill') {
      title = 'Beceriler';
      h = CLS[P.cls].skills.map((sk, i) => `<div class="skr ${P.lv < sk.lv ? 'lock' : ''}"><img src="${Assets.base}ui/icon_res_skill_${sk.icon}.png"><div><b>${sk.name}</b><br><small>${sk.mp} mana · ${sk.cd} sn · ${P.lv < sk.lv ? sk.lv + '. seviyede' : 'Kısayol ' + (i + 1)}</small></div></div>`).join('');
    } else if (cur === 'quest') {
      title = 'Görevler';
      const act = QUESTS.filter(q => P.quests[q.id]);
      h = act.length ? act.map(q => { const st = P.quests[q.id]; return `<div class="qr"><b>${q.title}</b><p>${esc(q.goal)}</p><small>${st.ready ? 'Tamamlandı — ' + trName(q.to) + ' ile konuş' : (q.count ? `${st.n}/${q.count}` : '')} · Teslim: ${trName(q.to)}</small></div>`; }).join('') : '<p>Aktif görev yok. Başında ! olan kişilerle konuş.</p>';
      h += `<p class="hint">Tamamlanan görev: ${Object.keys(P.done).length}</p>`;
    } else if (cur === 'map') {
      title = 'Dünya Haritası';
      h = `<div class="wmap"><img src="${Assets.base}ui/UIData_2047.png"><img src="${Assets.base}ui/UIData_2048.png"></div><p class="hint">Şu an: ${trName(Game.scene.name)}</p>`;
    } else if (cur === 'sys') {
      title = 'Ayarlar';
      h = `<button class="obtn" data-act="newchar">Yeni karakter oluştur</button><p class="hint">Oyun otomatik kaydedilir.</p>`;
    }
    ptitle.textContent = title; pbody.innerHTML = h;
  }
  pbody.addEventListener('click', e => {
    const b = e.target.closest('[data-open],[data-use],[data-act]'); if (!b) return;
    if (b.dataset.open) { open(b.dataset.open); return; }
    if (b.dataset.use) { useItem(b.dataset.use); render(); return; }
    if (b.dataset.act === 'newchar') { if (b.dataset.sure) { localStorage.removeItem(SAVE_KEY); location.reload(); } else { b.dataset.sure = 1; b.textContent = 'Eminim, sil'; } }
  });
  $('#pclose').onclick = closeAll;

  // ---------- NPC diyaloğu ----------
  let dlgNpc = null, dlgQ = null;
  function dialog(n) {
    dlgNpc = n; dlgQ = null; $('#dlg').classList.remove('hidden'); renderDlg();
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
      btns += `<button data-q="bye">Hoşça kal</button>`;
    }
    $('#dtext').textContent = txt; $('#dbtns').innerHTML = btns;
  }
  $('#dbtns').addEventListener('click', e => {
    const b = e.target.closest('button'); if (!b) return;
    if (b.dataset.qid) { dlgQ = QBY[b.dataset.qid]; renderDlg(); return; }
    const a = b.dataset.q;
    if (a === 'bye') { closeAll(); return; }
    if (a === 'back') { dlgQ = null; renderDlg(); return; }
    if (a === 'tp') { closeAll(); setTimeout(() => gotoScene('120005', null, [33, 20]), 300); return; }
    if (a === 'accept' && dlgQ.teleport) { acceptQuest(dlgQ); dlgQ = null; closeAll(); setTimeout(() => gotoScene('120005', null, [33, 20]), 400); return; }
    if (a === 'accept') { acceptQuest(dlgQ); if (dlgQ.type === 'talk' && dlgQ.to === dlgNpc.cn) { Game.P.quests[dlgQ.id].ready = true; } dlgQ = null; renderDlg(); return; }
    if (a === 'complete') { const q = dlgQ; completeQuest(q); dlgQ = null; if (!q.teleport) renderDlg(); else closeAll(); return; }
  });
  function say(n, t) { dlgNpc = n; dlgQ = null; $('#dlg').classList.remove('hidden'); $('#dname').textContent = n.name; $('#dtext').textContent = t; $('#dbtns').innerHTML = '<button data-q="bye">Tamam</button>'; }

  // ---------- karakter oluşturma ----------
  const cre = { cls: '战士', race: '人类', sex: 'male', face: 1 };
  let creDoll = null;
  function showCreate() {
    mode = 'create'; $('#create').classList.remove('hidden'); renderCreate();
  }
  function renderCreate() {
    const g = (cre.race === '人类' ? 0 : 2) + (cre.sex === 'male' ? 1 : 2);
    $('#cfaces').innerHTML = [1, 2, 3, 4, 5, 6, 7, 8].map(i => `<button class="face ${cre.face === i ? 'on' : ''}" data-face="${i}"><img src="${Assets.base}ui/Portrait_${g}00${i}.png"></button>`).join('');
    document.querySelectorAll('[data-cls]').forEach(b => b.classList.toggle('on', b.dataset.cls === cre.cls));
    document.querySelectorAll('[data-race]').forEach(b => b.classList.toggle('on', b.dataset.race === cre.race));
    document.querySelectorAll('[data-sex]').forEach(b => b.classList.toggle('on', b.dataset.sex === cre.sex));
    creDoll = new Assets.Paperdoll({ cls: cre.cls, race: cre.race, sex: cre.sex, body: [1, CLS[cre.cls].color], head: [1, CLS[cre.cls].color], weap: [1, CLS[cre.cls].color] });
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

  function log(m, c) { logs.push({ m, c: c === 'q' ? '#ffd23a' : c === 'loot' ? '#e8e0c8' : (c || '#e8e0d0'), t: performance.now() }); if (logs.length > 30) logs.shift(); }
  function toast(m) { toastMsg = m; toastT = 2.5; }
  // ---------- akış ----------
  async function start() {
    mode = 'loading'; $('#loading').classList.remove('hidden');
    await loadScene(Game.P.scene || '120207');
    $('#loading').classList.add('hidden'); mode = 'play';
    if (!Object.keys(Game.P.done).length && !Object.keys(Game.P.quests).length) { toast('Rehber seni bekliyor: başında ! olan kişiye dokun'); log('Sol altta parmağını kaydırarak yürü ya da bir yere dokun.', '#ffd23a'); log('Canavara dokunursan saldırırsın. Sağ alttaki ejderha da saldırı düğmesidir.', '#ffd23a'); }
  }
  let last = performance.now();
  function loop(now) {
    const dt = Math.min(0.05, (now - last) / 1000); last = now;
    ctx.setTransform(scale, 0, 0, scale, 0, 0); ctx.imageSmoothingEnabled = false;
    if (mode === 'play' && Game.map && Game.player) {
      if (!panelOpen()) update(dt);
      drawWorld(); drawHud();
      if (fadeOn || fadeA > 0) { fadeA = clamp(fadeA + (fadeOn ? dt * 5 : -dt * 3), 0, 1); ctx.fillStyle = `rgba(0,0,0,${fadeA})`; ctx.fillRect(0, 0, vw, VH); }
      if (Game.player.dead) { ctx.fillStyle = 'rgba(40,0,0,.45)'; ctx.fillRect(0, 0, vw, VH); }
    } else if (mode === 'create') drawCreate();
    requestAnimationFrame(loop);
  }
  async function boot() {
    await Assets.init('assets/');
    Input.bind(cv);
    for (const k of ['icon_res_item_1038', 'AnbufenUI_Resource_7003', 'AnbufenUI_Resource_7002', 'AnbufenUI_Resource_7009', 'UIData_2067']) uiImg(k);
    $('#loading').classList.add('hidden');
    const s = load();
    if (s) { Game.P = s; start(); } else showCreate();
    requestAnimationFrame(loop);
    window.__G = Game;
  }
  return {
    boot, toLogical, toWorld, hudHit, open, closeAll, panelOpen, dialog, say, attack,
    get vw() { return vw; }, get mode() { return mode; },
    log, toast, zone(m) { zoneMsg = m; zoneT = 3; }, levelUp(n) { lvlN = n; lvlT = 2.5; }, hurt() { hurtT = 0.4; },
    float(e, txt, c, s = 1) { floats.push({ e, txt, c, s, t: 0 }); }, target() { }, refresh() { if (cur) render(); },
    fade(on) { fadeOn = on; if (on) fadeA = 1; }, death() { $('#death').classList.remove('hidden'); },
  };
})();
$('#revive').onclick = () => { $('#death').classList.add('hidden'); revive(); };
window.addEventListener('load', () => UI.boot().catch(e => { $('#loading').textContent = 'Hata: ' + e.message; console.error(e); }));
