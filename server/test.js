// Sunucu testi: kayıt, giriş, karakter oluşturma/kaydetme/yükleme ve iki oyuncunun aynı haritada görüşüp yazışması.
// Çalışan bir PostgreSQL gerekir (DATABASE_URL). Kullanım: node test.js
'use strict';
const assert = require('assert');
const WebSocket = require('ws');
const { server } = require('./server');
const { pool } = require('./db');

const fail = e => { console.error('BAŞARISIZ:', e); process.exit(1); };
server.listen(0, async () => {
  const base = `http://localhost:${server.address().port}`;
  const call = async (m, p, body, token) => {
    const r = await fetch(base + p, { method: m, headers: Object.assign({ 'Content-Type': 'application/json' }, token ? { Authorization: 'Bearer ' + token } : {}), body: body ? JSON.stringify(body) : undefined });
    return { code: r.status, j: await r.json() };
  };
  const tag = Date.now().toString(36).slice(-6);
  try {
    await pool.query('DELETE FROM accounts WHERE username LIKE $1', ['t_%']);
    assert.equal((await call('GET', '/api/health')).j.ok, true);
    // kayıt ve giriş
    assert.equal((await call('POST', '/api/register', { username: 'x', password: '123456' })).code, 400);
    const a = await call('POST', '/api/register', { username: 't_a' + tag, password: 'gizli123' }); assert.equal(a.code, 200);
    assert.equal((await call('POST', '/api/register', { username: 'T_A' + tag, password: 'gizli123' })).code, 409, 'aynı ad büyük harfle tekrar alınamaz');
    assert.equal((await call('POST', '/api/login', { username: 't_a' + tag, password: 'yanlis' })).code, 401);
    const la = await call('POST', '/api/login', { username: 't_a' + tag, password: 'gizli123' }); assert.equal(la.code, 200); let TA = la.j.token;
    assert.equal((await call('GET', '/api/characters')).code, 401, 'oturumsuz erişim yok');
    // şifre değiştirme: eski şifre yanlışsa olmaz; değişince eski oturum kapanır
    assert.equal((await call('POST', '/api/password', { username: 't_a' + tag, oldPassword: 'yanlis', newPassword: 'yeni12345' })).code, 401);
    assert.equal((await call('POST', '/api/password', { username: 't_a' + tag, oldPassword: 'gizli123', newPassword: 'yeni12345' })).code, 200);
    assert.equal((await call('GET', '/api/characters', null, TA)).code, 401, 'şifre değişince eski oturum geçersiz');
    assert.equal((await call('POST', '/api/login', { username: 't_a' + tag, password: 'gizli123' })).code, 401);
    TA = (await call('POST', '/api/login', { username: 't_a' + tag, password: 'yeni12345' })).j.token; assert.ok(TA);
    // karakter
    const P = { v: 1, sv: 2, name: 'Ali' + tag.slice(0, 4), cls: '战士', race: '人类', sex: 'male', lv: 1, xp: 0, gold: 30, hp: 1000, mp: 200,
      gear: { weap: 0 }, eq: {}, bag: [{ id: 'hp1', n: 5 }, { id: 'mp1', n: 3 }], quests: {}, done: {}, qitems: {}, scene: '120207', x: 3, y: 13,
      quick: ['s0', null, null, null, null, null, null, null], sk: { 101: 1 }, sp: 1, flags: { tut: 1 } };
    assert.equal((await call('POST', '/api/characters', { state: Object.assign({}, P, { name: '<script>' }) }, TA)).code, 400, 'geçersiz ad reddedilir');
    const c = await call('POST', '/api/characters', { state: P }, TA); assert.equal(c.code, 200); const CID = c.j.id;
    // oyun ilerledi: seviye, çanta, ekipman, görevler, beceriler, kısayollar
    Object.assign(P, { lv: 7, xp: 1234, gold: 980, x: 18.5, y: 9, bag: [{ id: 'hp1', n: 2 }, { id: '30016', n: 4 }], eq: { weap: '10003', body: '10004' },
      quests: { 80293: { n: 3, ready: false }, 80295: { n: 0, ready: true } }, done: { 80001: true }, sk: { 101: 3, 102: 1 }, quick: ['s0', 's1', 'i:hp1', null, null, null, null, null],
      home: ['120207', 3, 13], qitems: { 9001: 2 } });
    assert.equal((await call('PUT', `/api/characters/${CID}`, { state: P }, TA)).code, 200);
    const L = (await call('GET', `/api/characters/${CID}`, null, TA)).j.state;
    for (const k of ['lv', 'xp', 'gold', 'x', 'y', 'eq', 'quests', 'done', 'sk', 'quick', 'home', 'qitems', 'gear', 'flags']) assert.deepStrictEqual(norm(L[k]), norm(P[k]), 'alan: ' + k);
    assert.deepStrictEqual(L.bag.sort((p, q) => p.id < q.id ? -1 : 1), P.bag.slice().sort((p, q) => p.id < q.id ? -1 : 1));
    // ikinci hesap başkasının karakterine dokunamaz
    const b = await call('POST', '/api/register', { username: 't_b' + tag, password: 'gizli456' }); const TB = b.j.token;
    assert.equal((await call('GET', `/api/characters/${CID}`, null, TB)).code, 404);
    assert.equal((await call('PUT', `/api/characters/${CID}`, { state: P }, TB)).code, 404);
    assert.equal((await call('POST', '/api/characters', { state: P }, TB)).code, 409, 'aynı karakter adı alınamaz');
    const cb = await call('POST', '/api/characters', { state: Object.assign({}, P, { name: 'Ayse' + tag.slice(0, 4), cls: '法师', race: '精灵', sex: 'fema', scene: '120205' }) }, TB);
    assert.equal(cb.code, 200);
    assert.equal((await call('GET', '/api/admin/stats', null, TA)).code, 403, 'yönetici olmayan panele giremez');
    // WebSocket: iki oyuncu aynı haritada
    const wsUrl = `ws://localhost:${server.address().port}/ws?token=`;
    const open = t => new Promise((ok, bad) => { const w = new WebSocket(wsUrl + t); w.inbox = []; w.on('message', m => w.inbox.push(JSON.parse(m))); w.on('open', () => ok(w)); w.on('error', bad); });
    const wait = (w, f, ms = 2000) => new Promise((ok, bad) => { const t0 = Date.now(); (function chk() { const i = w.inbox.findIndex(f); if (i >= 0) return ok(w.inbox.splice(i, 1)[0]); if (Date.now() - t0 > ms) return bad(new Error('mesaj gelmedi')); setTimeout(chk, 20); })(); });
    const wa = await open(TA), wb = await open(TB);
    wa.send(JSON.stringify({ t: 'join', char: CID, scene: '120207', x: 3, y: 13 }));
    assert.deepStrictEqual((await wait(wa, m => m.t === 'players')).list, []);
    wb.send(JSON.stringify({ t: 'join', char: cb.j.id, scene: '120207', x: 5, y: 13 }));
    const seen = await wait(wb, m => m.t === 'players'); assert.equal(seen.list.length, 1); assert.equal(seen.list[0].name, P.name);
    assert.equal((await wait(wa, m => m.t === 'add')).p.name, 'Ayse' + tag.slice(0, 4));
    wb.send(JSON.stringify({ t: 'pos', x: 6, y: 12, dir: 1, st: 'walk' }));
    const pm = await wait(wa, m => m.t === 'pos'); assert.equal(pm.x, 6);
    wa.send(JSON.stringify({ t: 'chat', text: 'Merhaba!' }));
    assert.equal((await wait(wb, m => m.t === 'chat')).text, 'Merhaba!');
    wb.send(JSON.stringify({ t: 'scene', scene: '120005', x: 1, y: 1 }));
    await wait(wa, m => m.t === 'del');
    wa.close(); wb.close();
    await new Promise(r => setTimeout(r, 200));
    const log = await pool.query('SELECT text FROM chat_log WHERE character_id = $1', [CID]); assert.equal(log.rows[0].text, 'Merhaba!');
    // silme ve temizlik
    assert.equal((await call('DELETE', `/api/characters/${CID}`, null, TA)).code, 200);
    assert.equal((await call('POST', '/api/logout', {}, TA)).code, 200);
    assert.equal((await call('GET', '/api/characters', null, TA)).code, 401, 'çıkıştan sonra oturum geçersiz');
    await pool.query('DELETE FROM accounts WHERE username LIKE $1', ['t_%']);
    console.log('TÜM TESTLER GEÇTİ');
    server.close(); await pool.end(); process.exit(0);
  } catch (e) { fail(e); }
});
// JSON yuvarlamasında anahtar türleri (sayı/metin) eşitlensin
function norm(v) { return v === undefined ? null : JSON.parse(JSON.stringify(v)); }
