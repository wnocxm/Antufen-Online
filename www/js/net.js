// Çevrimiçi oyun: sunucuya giriş, karakteri sunucuya kaydetme, aynı haritadaki diğer oyuncular ve sohbet.
// Sunucu kodu: server/ klasörü. Çevrimdışı oyun (telefonun hafızasına kayıt) aynen çalışmaya devam eder.
'use strict';

// Başka bir oyuncu: sunucudan gelen konuma yumuşakça yürür, kendi giysileriyle çizilir
class Remote extends Ent {
  constructor(p) {
    super('other', p.x, p.y);
    Object.assign(this, { id: p.id, name: p.name, lv: p.lv, cls: p.cls, race: p.race, sex: p.sex, tx: p.x, ty: p.y, dir: p.dir || 2, st: p.st || 'idle', lk: '', say: null, sayT: 0 });
    this.setLook(p.look);
  }
  setLook(l) {
    const L = Object.assign({}, l || {}, { cls: this.cls, race: this.race, sex: this.sex }), k = JSON.stringify(L);
    if (k === this.lk) return; this.lk = k; this.doll = new Assets.Paperdoll(L);
  }
  update(dt) {
    const dx = this.tx - this.x, dy = this.ty - this.y, d = Math.hypot(dx, dy);
    if (d > 8) { this.x = this.tx; this.y = this.ty; }          // çok gerideyse ışınla
    else if (d > 0.02) {
      const s = Math.min(d, Math.max(RUN * 1.1, d * 4) * dt), X0 = this.X, Y0 = this.Y;
      this.x += dx / d * s; this.y += dy / d * s;
      this.t += Math.hypot(this.X - X0, this.Y - Y0) * 8 / STRIDE; this.walk = 0.15;
    } else this.t += dt * TICK;
    if (this.walk > 0) this.walk -= dt;
    this.animT = (this.animT || 0) + dt * TICK;
    if (this.sayT > 0) this.sayT -= dt;
  }
  draw(ctx, X, Y) {
    const d = this.dir, D = this.doll;
    if (this.st === 'dead') return D.draw(ctx, 'figh', 16 + d, D.animLen('figh', 16 + d) - 1, X, Y);
    if (this.walk > 0 || this.st === 'move') return D.draw(ctx, 'comm', 4 + d, this.t, X, Y);
    if (this.st === 'attack') return D.draw(ctx, 'figh', 4 + d, this.animT, X, Y);
    if (this.st === 'cast') return D.draw(ctx, 'figh', 8 + d, this.animT, X, Y);
    D.draw(ctx, 'comm', d, this.t, X, Y);
  }
}

const Net = (() => {
  const KEY = 'anrufen_net';
  let st = {}; try { st = JSON.parse(localStorage.getItem(KEY) || '{}'); } catch (e) { }
  // oyun sunucunun kendisinden açıldıysa adres aynıdır; GitHub sayfası ya da uygulamada kullanıcı adresi girer
  const sameOrigin = /^https?:$/.test(location.protocol) && !/github\.io$/.test(location.hostname);
  let url = st.url || (sameOrigin ? location.origin : ''), token = st.token || null, user = st.user || '', remember = st.remember !== false;
  let admin = false, on = false, ws = null, joined = false, retry = 0, closing = false;
  const others = new Map();
  const keep = () => { try { localStorage.setItem(KEY, JSON.stringify({ url, user: remember ? user : '', remember, token: remember ? token : null })); } catch (e) { } };
  const base = () => url.trim().replace(/\/+$/, '');

  async function api(m, p, b) {
    let r;
    try { r = await fetch(base() + p, { method: m, headers: Object.assign({ 'Content-Type': 'application/json' }, token ? { Authorization: 'Bearer ' + token } : {}), body: b ? JSON.stringify(b) : undefined }); }
    catch (e) { const x = new Error('net'); x.code = 0; throw x; }
    let j = {}; try { j = await r.json(); } catch (e) { }
    if (!r.ok) { const x = new Error(j.err || 'http'); x.code = r.status; if (r.status === 401 && j.err === 'auth') { token = null; keep(); } throw x; }
    return j;
  }
  // hata kodunu oyuncuya gösterilecek metne çevirir
  function why(e) {
    return tx({ net: 'Sunucuya ulaşılamadı. Adresi ve internet bağlantını kontrol et.', taken: 'Bu kullanıcı adı alınmış.', bad: 'Kullanıcı adı ya da şifre yanlış.',
      invalid: 'Kullanıcı adı 3-24 harf/rakam, şifre en az 6 karakter olmalı.', slow: 'Çok fazla deneme yaptın, biraz bekle.', banned: 'Bu hesap kapatılmış.',
      name: 'Bu karakter adı alınmış.', gmname: '"GM" ile başlayan adlar yalnızca yöneticiler içindir.', limit: 'Bir hesapta en fazla 4 karakter olabilir.', auth: 'Oturumun sona erdi, yeniden giriş yap.' }[e.message] || 'Bir hata oldu: ' + e.message);
  }

  async function login(u, p, isNew) {
    user = u; token = null;
    const j = await api('POST', isNew ? '/api/register' : '/api/login', { username: u, password: p });
    token = j.token; admin = !!j.admin; keep();
    return j.characters || (await api('GET', '/api/characters')).characters;
  }
  async function changePass(u, oldP, newP) { await api('POST', '/api/password', { username: u, oldPassword: oldP, newPassword: newP }); token = null; keep(); }
  async function chars() { const j = await api('GET', '/api/characters'); admin = !!j.admin; return j.characters; }
  async function logout() { try { await api('POST', '/api/logout', {}); } catch (e) { } token = null; keep(); }
  async function create(P) { const j = await api('POST', '/api/characters', { state: P }); P.id = j.id; return j.id; }
  async function play(id) { const P = (await api('GET', '/api/characters/' + id)).state; on = true; return P; }
  async function remove(id) { await api('DELETE', '/api/characters/' + id); }

  // ---------- kayıt: en fazla 4 saniyede bir, son durum gönderilir ----------
  let pend = null, busy = false, lastSave = 0, timer = 0, failN = 0;
  function save(P) {
    if (!on || !P.id) return; pend = JSON.stringify({ state: P });
    if (busy || timer) return;
    const wait = Math.max(0, 4000 - (Date.now() - lastSave));
    timer = setTimeout(flush, wait);
  }
  async function flush() {
    timer = 0; if (!pend) return; const b = pend, id = JSON.parse(b).state.id; pend = null; busy = true; lastSave = Date.now();
    try {
      const r = await fetch(base() + '/api/characters/' + id, { method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + token }, body: b });
      if (!r.ok) throw new Error(r.status); if (failN >= 2) UI.toast('Sunucuya yeniden kaydedildi.'); failN = 0;
    } catch (e) { failN++; if (failN === 2) UI.toast('Sunucuya kaydedilemedi, tekrar denenecek…'); if (!pend) pend = b; }
    busy = false; if (pend && !timer) timer = setTimeout(flush, failN ? 5000 : 4000);
  }
  // bekleyen kaydı hemen gönder (giriş ekranına dönerken)
  async function now() { if (timer) { clearTimeout(timer); timer = 0; } while (busy) await new Promise(r => setTimeout(r, 50)); if (pend) await flush(); }
  // uygulama arka plana geçerken son durumu hemen gönder
  addEventListener('visibilitychange', () => {
    if (!on || document.visibilityState !== 'hidden' || !Game.P) return;
    const P = Game.P; if (Game.player) { P.scene = Game.sceneId; P.x = Game.player.x; P.y = Game.player.y; P.hp = Game.player.hp; P.mp = Game.player.mp; }
    try { fetch(base() + '/api/characters/' + P.id, { method: 'PUT', keepalive: true, headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + token }, body: JSON.stringify({ state: P }) }); } catch (e) { }
  });

  // ---------- canlı bağlantı ----------
  function sendj(o) { if (ws && ws.readyState === 1) ws.send(JSON.stringify(o)); }
  function me() { const p = Game.player; return { x: Math.round(p.x * 100) / 100, y: Math.round(p.y * 100) / 100, dir: p.dir, st: p.dead ? 'dead' : p.state || 'idle' }; }
  function connect() {
    if (!on || ws) return;
    ws = new WebSocket(base().replace(/^http/, 'ws') + '/ws?token=' + encodeURIComponent(token));
    ws.onopen = () => { retry = 0; if (Game.player) { sendj(Object.assign({ t: 'join', char: Game.P.id, scene: Game.sceneId, look: look() }, me())); joined = true; } };
    ws.onmessage = ev => { let m; try { m = JSON.parse(ev.data); } catch (e) { return; } msg(m); };
    ws.onclose = ev => {
      ws = null; joined = false; others.clear();
      if (ev.code === 4001) { on = false; UI.toast('Bu karakterle başka bir yerden girildi.'); return; }
      if (on && !closing) { retry = Math.min(retry + 1, 6); setTimeout(connect, 1000 * retry); }
    };
  }
  function msg(m) {
    if (m.t === 'players') { others.clear(); for (const p of m.list) others.set(p.id, new Remote(p)); }
    else if (m.t === 'add') { others.set(m.p.id, new Remote(m.p)); }
    else if (m.t === 'del') others.delete(m.id);
    else if (m.t === 'pos') { const o = others.get(m.id); if (o) { o.tx = m.x; o.ty = m.y; o.dir = m.dir; if (o.st !== m.st) o.animT = 0; o.st = m.st; if (m.lv) o.lv = m.lv; if (m.look) o.setLook(m.look); } }
    else if (m.t === 'chat') {
      const o = others.get(m.id); if (o) { o.say = m.text; o.sayT = 5; } else if (m.id === Game.P.id) { Game.player.say = m.text; Game.player.sayT = 5; }
      UI.chatLine(m.name, m.text, m.id === Game.P.id);
    }
  }
  // harita değişti (ilk giriş dahil)
  function scene(sid, x, y) {
    if (!on) return; others.clear();
    if (!ws) return connect();
    if (!joined) { if (ws.readyState === 1) { sendj(Object.assign({ t: 'join', char: Game.P.id, scene: sid, look: look() }, me())); joined = true; } return; }
    sendj({ t: 'scene', scene: sid, x, y });
  }
  let sendT = 0, beat = 0, lastK = '', lastLook = '', lastLv = 0;
  function tick(dt) {
    if (!on || !Game.player) return;
    for (const o of others.values()) o.update(dt);
    const p = Game.player; if (p.sayT > 0) p.sayT -= dt;
    if (!joined) return;
    sendT -= dt; beat -= dt; if (sendT > 0) return;
    const s = me(), k = `${s.x},${s.y},${s.dir},${s.st}`, L = JSON.stringify(look());
    if (k === lastK && beat > 0 && L === lastLook && Game.P.lv === lastLv) return;
    const m = Object.assign({ t: 'pos' }, s);
    if (L !== lastLook) { m.look = JSON.parse(L); lastLook = L; }
    if (Game.P.lv !== lastLv) { m.lv = Game.P.lv; lastLv = Game.P.lv; }
    sendj(m); lastK = k; sendT = 0.1; beat = 2;
  }
  function chat(text) { text = String(text || '').trim().slice(0, 120); if (text) sendj({ t: 'chat', text }); }
  function leave() { closing = true; on = false; if (ws) ws.close(); }

  return {
    get on() { return on; }, get admin() { return admin; }, get url() { return url; }, set url(v) { url = String(v || '').trim(); keep(); }, get user() { return user; }, get remember() { return remember; }, set remember(v) { remember = !!v; keep(); }, get token() { return token; },
    get others() { return others; }, get live() { return !!(ws && ws.readyState === 1); },
    why, now, login, changePass, chars, logout, create, play, remove, save, scene, tick, chat, leave,
  };
})();
