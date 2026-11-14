// Anrufen Online sunucusu: HTTP API (hesap, karakter) + WebSocket (aynı haritadaki oyuncular, sohbet) + oyun dosyaları + yönetim paneli
'use strict';
const http = require('http');
const fs = require('fs');
const path = require('path');
const { WebSocketServer } = require('ws');
const db = require('./db');

const PORT = +process.env.PORT || 8080;
const WWW = path.resolve(__dirname, '..', 'www');
const ALLOW = (process.env.ALLOW_ORIGINS || 'https://wnocxm.github.io').split(',').map(s => s.trim()).filter(Boolean);
const NAME_RE = /^[\p{L}\p{N}_]{2,12}$/u, USER_RE = /^[A-Za-z0-9_.-]{3,24}$/;
const RACES = ['人类', '精灵'], CLASSES = ['战士', '法师', '牧师'], SEXES = ['male', 'fema'];

// ---------------- yardımcılar ----------------
function cors(req, res) {
  const o = req.headers.origin;
  if (o && (ALLOW.includes(o) || ALLOW.includes('*') || /^http:\/\/localhost(:\d+)?$/.test(o))) { res.setHeader('Access-Control-Allow-Origin', o); res.setHeader('Vary', 'Origin'); }
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
}
function send(res, code, obj) { res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(JSON.stringify(obj)); }
function body(req, limit = 512 * 1024) {
  return new Promise((ok, bad) => { let n = 0; const ch = []; req.on('data', d => { n += d.length; if (n > limit) { bad(new Error('too big')); req.destroy(); } else ch.push(d); });
    req.on('end', () => { try { ok(ch.length ? JSON.parse(Buffer.concat(ch).toString('utf8')) : {}); } catch (e) { bad(e); } }); req.on('error', bad); });
}
const bearer = req => (req.headers.authorization || '').replace(/^Bearer\s+/i, '') || null;
// basit hız sınırı: IP başına dakikada en fazla N istek
const hits = new Map();
function limited(req, key, max) {
  const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || '').split(',')[0].trim(), k = key + '|' + ip, now = Date.now();
  const h = hits.get(k) || { t: now, n: 0 }; if (now - h.t > 60000) { h.t = now; h.n = 0; } h.n++; hits.set(k, h); return h.n > max;
}
setInterval(() => { const now = Date.now(); for (const [k, h] of hits) if (now - h.t > 120000) hits.delete(k); }, 60000).unref();

// karakter kaydının temel doğrulaması (ileride oyun mantığı sunucuya taşındıkça sıkılaşacak)
function validState(P) {
  return P && typeof P === 'object' && NAME_RE.test(P.name || '') && RACES.includes(P.race) && CLASSES.includes(P.cls) && SEXES.includes(P.sex) && typeof P.scene === 'string' && P.scene.length < 16;
}

// ---------------- API ----------------
async function api(req, res, url) {
  const p = url.pathname, m = req.method;
  if (p === '/api/health') return send(res, 200, { ok: true, online: online.size });
  if (p === '/api/register' && m === 'POST') {
    if (limited(req, 'reg', 10)) return send(res, 429, { err: 'slow' });
    const { username, password } = await body(req);
    if (!USER_RE.test(username || '') || typeof password !== 'string' || password.length < 6 || password.length > 100) return send(res, 400, { err: 'invalid' });
    const id = await db.register(username, password); if (!id) return send(res, 409, { err: 'taken' });
    const s = await db.login(username, password); return send(res, 200, { token: s.token });
  }
  if (p === '/api/login' && m === 'POST') {
    if (limited(req, 'login', 20)) return send(res, 429, { err: 'slow' });
    const { username, password } = await body(req);
    const s = await db.login(String(username || ''), String(password || ''));
    if (s.err) return send(res, s.err === 'banned' ? 403 : 401, { err: s.err });
    return send(res, 200, { token: s.token, characters: await db.listCharacters(s.accountId) });
  }
  const ses = await db.session(bearer(req));
  if (!ses) return send(res, 401, { err: 'auth' });
  if (p === '/api/logout' && m === 'POST') { await db.logout(bearer(req)); return send(res, 200, { ok: true }); }
  if (p === '/api/characters' && m === 'GET') return send(res, 200, { characters: await db.listCharacters(ses.accountId) });
  if (p === '/api/characters' && m === 'POST') {
    const P = (await body(req)).state;
    if (!validState(P)) return send(res, 400, { err: 'invalid' });
    const r = await db.createCharacter(ses.accountId, P);
    if (r.err) return send(res, 409, { err: r.err });
    return send(res, 200, { id: r.id });
  }
  const cm = p.match(/^\/api\/characters\/(\d+)$/);
  if (cm) {
    const id = +cm[1];
    if (m === 'GET') { const P = await db.loadCharacter(ses.accountId, id); return P ? send(res, 200, { state: P }) : send(res, 404, { err: 'none' }); }
    if (m === 'PUT') { const P = (await body(req)).state; if (!validState(P)) return send(res, 400, { err: 'invalid' }); return (await db.saveCharacter(ses.accountId, id, P)) ? send(res, 200, { ok: true }) : send(res, 404, { err: 'none' }); }
    if (m === 'DELETE') return (await db.deleteCharacter(ses.accountId, id)) ? send(res, 200, { ok: true }) : send(res, 404, { err: 'none' });
  }
  if (p === '/api/admin/stats' && m === 'GET') {
    if (!ses.isAdmin) return send(res, 403, { err: 'admin' });
    const s = await db.stats();
    return send(res, 200, Object.assign(s, { online: [...online.values()].map(o => ({ name: o.name, cls: o.cls, lv: o.lv, scene: o.scene, x: Math.round(o.x), y: Math.round(o.y) })), uptime: Math.round(process.uptime()) }));
  }
  return send(res, 404, { err: 'route' });
}

// ---------------- dosyalar ----------------
const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css', '.json': 'application/json', '.png': 'image/png', '.wav': 'audio/wav', '.mid': 'audio/midi', '.bin': 'application/octet-stream' };
function serveFile(res, root, rel) {
  const f = path.resolve(root, '.' + rel); if (!f.startsWith(root)) { res.writeHead(403); return res.end(); }
  fs.stat(f, (e, st) => {
    if (e) { res.writeHead(404); return res.end('yok'); }
    const file = st.isDirectory() ? path.join(f, 'index.html') : f;
    res.writeHead(200, { 'Content-Type': TYPES[path.extname(file)] || 'application/octet-stream', 'Cache-Control': /\.(png|wav|mid|bin)$/.test(file) ? 'public, max-age=86400' : 'no-cache' });
    fs.createReadStream(file).on('error', () => res.end()).pipe(res);
  });
}

const server = http.createServer(async (req, res) => {
  cors(req, res);
  if (req.method === 'OPTIONS') { res.writeHead(204); return res.end(); }
  const url = new URL(req.url, 'http://x');
  try {
    if (url.pathname.startsWith('/api/')) return await api(req, res, url);
    if (url.pathname === '/admin' || url.pathname === '/admin/') return serveFile(res, __dirname, '/admin.html');
    return serveFile(res, WWW, decodeURIComponent(url.pathname));
  } catch (e) { console.error(e); if (!res.headersSent) send(res, 500, { err: 'server' }); }
});

// ---------------- WebSocket: aynı haritadaki oyuncular ve sohbet ----------------
// istemci -> sunucu: {t:'join', char, scene, x, y, look} | {t:'pos', x, y, dir, st} | {t:'scene', scene, x, y} | {t:'chat', text}
// sunucu -> istemci: {t:'players', list} | {t:'add', p} | {t:'pos', id, x, y, dir, st} | {t:'del', id} | {t:'chat', id, name, text}
const wss = new WebSocketServer({ noServer: true, maxPayload: 8 * 1024 });
const online = new Map();   // karakter kimliği -> bağlantı bilgisi
const pub = o => ({ id: o.id, name: o.name, cls: o.cls, race: o.race, sex: o.sex, lv: o.lv, x: o.x, y: o.y, dir: o.dir, st: o.st, look: o.look });
function toScene(scene, msg, except) { const s = JSON.stringify(msg); for (const o of online.values()) if (o.scene === scene && o !== except && o.ws.readyState === 1) o.ws.send(s); }

server.on('upgrade', async (req, sock, head) => {
  const url = new URL(req.url, 'http://x');
  if (url.pathname !== '/ws') return sock.destroy();
  const ses = await db.session(url.searchParams.get('token')).catch(() => null);
  if (!ses) { sock.write('HTTP/1.1 401 Unauthorized\r\n\r\n'); return sock.destroy(); }
  wss.handleUpgrade(req, sock, head, ws => onConn(ws, ses));
});

function onConn(ws, ses) {
  let me = null, last = 0, chatT = 0;
  ws.on('message', async raw => {
    let m; try { m = JSON.parse(raw); } catch (e) { return; }
    if (m.t === 'join' && !me) {
      const P = await db.loadCharacter(ses.accountId, +m.char).catch(() => null); if (!P) return ws.close(4004, 'char');
      const old = online.get(P.id); if (old) { old.ws.close(4001, 'again'); online.delete(P.id); toScene(old.scene, { t: 'del', id: old.id }); }
      me = { ws, id: P.id, name: P.name, cls: P.cls, race: P.race, sex: P.sex, lv: P.lv, scene: String(m.scene || P.scene), x: +m.x || 0, y: +m.y || 0, dir: 2, st: 'idle', look: m.look || null };
      online.set(me.id, me);
      ws.send(JSON.stringify({ t: 'players', list: [...online.values()].filter(o => o !== me && o.scene === me.scene).map(pub) }));
      toScene(me.scene, { t: 'add', p: pub(me) }, me);
      return;
    }
    if (!me) return;
    if (m.t === 'pos') {
      const now = Date.now(); if (now - last < 80) return; last = now;   // en fazla ~12 güncelleme/sn
      me.x = +m.x || 0; me.y = +m.y || 0; me.dir = m.dir | 0; me.st = String(m.st || 'idle').slice(0, 8); if (m.lv) me.lv = m.lv | 0; if (m.look) me.look = m.look;
      toScene(me.scene, { t: 'pos', id: me.id, x: me.x, y: me.y, dir: me.dir, st: me.st }, me);
    } else if (m.t === 'scene') {
      toScene(me.scene, { t: 'del', id: me.id }, me);
      me.scene = String(m.scene).slice(0, 16); me.x = +m.x || 0; me.y = +m.y || 0;
      ws.send(JSON.stringify({ t: 'players', list: [...online.values()].filter(o => o !== me && o.scene === me.scene).map(pub) }));
      toScene(me.scene, { t: 'add', p: pub(me) }, me);
    } else if (m.t === 'chat') {
      const text = String(m.text || '').replace(/[\u0000-\u001f]/g, '').trim().slice(0, 120); const now = Date.now();
      if (!text || now - chatT < 1000) return; chatT = now;
      toScene(me.scene, { t: 'chat', id: me.id, name: me.name, text });
      db.logChat(me.id, me.scene, text).catch(e => console.error(e));
    }
  });
  ws.on('close', () => { if (me && online.get(me.id) === me) { online.delete(me.id); toScene(me.scene, { t: 'del', id: me.id }); } });
  ws.on('error', () => { });
}

if (require.main === module) server.listen(PORT, () => console.log(`Anrufen sunucusu: http://localhost:${PORT}  (oyun /, yönetim /admin)`));
module.exports = { server, online };
