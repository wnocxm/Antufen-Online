// Veritabanı katmanı: hesaplar, oturumlar, karakterlerin tablolara yazılıp okunması
'use strict';
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://anrufen:anrufen_dev@localhost:5432/anrufen' });

// ---------------- şifre ----------------
function hashPass(pass) {
  const salt = crypto.randomBytes(16).toString('hex');
  const h = crypto.scryptSync(pass, salt, 64).toString('hex');
  return `${salt}$${h}`;
}
function checkPass(pass, stored) {
  const [salt, h] = String(stored).split('$'); if (!salt || !h) return false;
  const got = crypto.scryptSync(pass, salt, 64);
  const want = Buffer.from(h, 'hex');
  return want.length === got.length && crypto.timingSafeEqual(got, want);
}

// ---------------- hesap ve oturum ----------------
const SESSION_DAYS = 30;
async function register(username, pass) {
  const r = await pool.query('INSERT INTO accounts (username, pass_hash) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING id', [username, hashPass(pass)]);
  return r.rows[0] ? r.rows[0].id : null;
}
async function login(username, pass) {
  const r = await pool.query('SELECT id, pass_hash, banned, is_admin FROM accounts WHERE lower(username) = lower($1)', [username]);
  const a = r.rows[0]; if (!a || !checkPass(pass, a.pass_hash)) return { err: 'bad' };
  if (a.banned) return { err: 'banned' };
  const token = crypto.randomBytes(32).toString('hex');
  await pool.query(`INSERT INTO sessions (token, account_id, expires_at) VALUES ($1, $2, now() + interval '${SESSION_DAYS} days')`, [token, a.id]);
  await pool.query('UPDATE accounts SET last_login = now() WHERE id = $1', [a.id]);
  return { token, accountId: a.id, isAdmin: a.is_admin };
}
async function session(token) {
  if (!token || typeof token !== 'string') return null;
  const r = await pool.query('SELECT s.account_id, a.is_admin, a.banned FROM sessions s JOIN accounts a ON a.id = s.account_id WHERE s.token = $1 AND s.expires_at > now()', [token]);
  const s = r.rows[0]; if (!s || s.banned) return null;
  return { accountId: Number(s.account_id), isAdmin: s.is_admin };
}
async function changePassword(username, oldPass, newPass) {
  const r = await pool.query('SELECT id, pass_hash FROM accounts WHERE lower(username) = lower($1)', [username]);
  const a = r.rows[0]; if (!a || !checkPass(oldPass, a.pass_hash)) return false;
  await pool.query('UPDATE accounts SET pass_hash = $2 WHERE id = $1', [a.id, hashPass(newPass)]);
  await pool.query('DELETE FROM sessions WHERE account_id = $1', [a.id]);   // eski oturumlar kapanır
  return true;
}
async function logout(token) { await pool.query('DELETE FROM sessions WHERE token = $1', [token]); }

// ---------------- karakter <-> tablolar ----------------
// İstemcinin kayıt nesnesi (P) tablolara ayrılır; bilinmeyen alanlar "extra" sütununda saklanır.
const CORE = ['v', 'sv', 'name', 'race', 'cls', 'sex', 'face', 'lv', 'xp', 'gold', 'hp', 'mp', 'sp', 'scene', 'x', 'y', 'home', 'flags', 'bag', 'eq', 'quests', 'done', 'sk', 'quick', 'id'];
const num = (v, d = 0) => (Number.isFinite(+v) ? +v : d);

async function listCharacters(accountId) {
  const r = await pool.query('SELECT id, name, race, cls, sex, face, lv, scene, last_seen FROM characters WHERE account_id = $1 ORDER BY id', [accountId]);
  return r.rows.map(c => ({ ...c, id: Number(c.id) }));
}

async function createCharacter(accountId, P) {
  const c = await pool.connect();
  try {
    await c.query('BEGIN');
    const cnt = await c.query('SELECT count(*)::int AS n FROM characters WHERE account_id = $1', [accountId]);
    if (cnt.rows[0].n >= 4) { await c.query('ROLLBACK'); return { err: 'limit' }; }
    const r = await c.query(`INSERT INTO characters (account_id, name, race, cls, sex, face, scene, x, y) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      ON CONFLICT DO NOTHING RETURNING id`, [accountId, P.name, P.race, P.cls, P.sex, num(P.face, 1), P.scene, num(P.x), num(P.y)]);
    if (!r.rows[0]) { await c.query('ROLLBACK'); return { err: 'name' }; }
    const id = Number(r.rows[0].id);
    await writeState(c, id, P);
    await c.query('COMMIT');
    return { id };
  } catch (e) { await c.query('ROLLBACK'); throw e; } finally { c.release(); }
}

async function saveCharacter(accountId, id, P) {
  const c = await pool.connect();
  try {
    await c.query('BEGIN');
    const own = await c.query('SELECT 1 FROM characters WHERE id = $1 AND account_id = $2 FOR UPDATE', [id, accountId]);
    if (!own.rows[0]) { await c.query('ROLLBACK'); return false; }
    await writeState(c, id, P);
    await c.query('COMMIT');
    return true;
  } catch (e) { await c.query('ROLLBACK'); throw e; } finally { c.release(); }
}

async function writeState(c, id, P) {
  const extra = {}; for (const k in P) if (!CORE.includes(k)) extra[k] = P[k];
  // çok hedefli görevlerin hedef başına sayaçları (character_quests yalnız toplamı tutar)
  const qc = {}; for (const [q, st] of Object.entries(P.quests || {})) if (st && st.c) qc[q] = st.c; if (Object.keys(qc).length) extra.qc = qc; else delete extra.qc;
  await c.query(`UPDATE characters SET lv=$2, xp=$3, gold=$4, hp=$5, mp=$6, skill_points=$7, scene=$8, x=$9, y=$10, home=$11, flags=$12, extra=$13,
    face=$14, updated_at=now(), last_seen=now() WHERE id=$1`,
    [id, Math.max(1, Math.min(200, num(P.lv, 1))), Math.max(0, num(P.xp)), Math.max(0, num(P.gold)), Math.max(0, Math.min(2e9, Math.round(num(P.hp)))),
      Math.max(0, Math.min(2e9, Math.round(num(P.mp)))), Math.max(0, num(P.sp)), String(P.scene || ''), num(P.x), num(P.y),
      P.home ? JSON.stringify(P.home) : null, JSON.stringify(P.flags || {}), JSON.stringify(extra), num(P.face, 1)]);
  for (const t of ['character_items', 'character_equipment', 'character_quests', 'character_skills', 'character_quickbar']) await c.query(`DELETE FROM ${t} WHERE character_id = $1`, [id]);
  const bag = (Array.isArray(P.bag) ? P.bag : []).filter(b => b && b.id && num(b.n) > 0);
  if (bag.length) await c.query('INSERT INTO character_items (character_id, item_id, qty) SELECT $1, * FROM unnest($2::text[], $3::int[]) ON CONFLICT (character_id, item_id) DO UPDATE SET qty = character_items.qty + EXCLUDED.qty',
    [id, bag.map(b => String(b.id)), bag.map(b => Math.round(num(b.n)))]);
  const eq = Object.entries(P.eq || {}).filter(([, v]) => v);
  if (eq.length) await c.query('INSERT INTO character_equipment (character_id, slot, item_id) SELECT $1, * FROM unnest($2::text[], $3::text[])', [id, eq.map(e => e[0]), eq.map(e => String(e[1]))]);
  const qs = [];
  for (const [q, st] of Object.entries(P.quests || {})) qs.push([+q, st && st.ready ? 'ready' : 'active', num(st && st.n)]);
  for (const q of Object.keys(P.done || {})) qs.push([+q, 'done', 0]);
  const qq = qs.filter(q => Number.isInteger(q[0]));
  if (qq.length) await c.query('INSERT INTO character_quests (character_id, quest_id, state, progress) SELECT $1, * FROM unnest($2::int[], $3::text[], $4::int[]) ON CONFLICT DO NOTHING',
    [id, qq.map(q => q[0]), qq.map(q => q[1]), qq.map(q => q[2])]);
  const sk = Object.entries(P.sk || {}).filter(([, r]) => num(r) >= 1);
  if (sk.length) await c.query('INSERT INTO character_skills (character_id, skill_id, rank) SELECT $1, * FROM unnest($2::text[], $3::int[])', [id, sk.map(s => s[0]), sk.map(s => Math.min(10, num(s[1])))]);
  const qb = (Array.isArray(P.quick) ? P.quick : []).map((v, i) => [i, v]).filter(([i, v]) => v && i < 8);
  if (qb.length) await c.query('INSERT INTO character_quickbar (character_id, slot, value) SELECT $1, * FROM unnest($2::int[], $3::text[])', [id, qb.map(q => q[0]), qb.map(q => String(q[1]))]);
}

async function loadCharacter(accountId, id) {
  const r = await pool.query('SELECT * FROM characters WHERE id = $1 AND account_id = $2', [id, accountId]);
  const c = r.rows[0]; if (!c) return null;
  const [items, eq, qs, sk, qb] = await Promise.all(['character_items', 'character_equipment', 'character_quests', 'character_skills', 'character_quickbar']
    .map(t => pool.query(`SELECT * FROM ${t} WHERE character_id = $1`, [id]).then(x => x.rows)));
  const P = Object.assign({}, c.extra, {
    v: 1, sv: 2, id: Number(c.id), name: c.name, race: c.race, cls: c.cls, sex: c.sex, face: c.face, lv: c.lv, xp: Number(c.xp), gold: Number(c.gold),
    hp: c.hp, mp: c.mp, sp: c.skill_points, scene: c.scene, x: c.x, y: c.y, home: c.home || undefined, flags: c.flags || {},
    bag: items.map(i => ({ id: i.item_id, n: i.qty })), eq: Object.fromEntries(eq.map(e => [e.slot, e.item_id])),
    quests: {}, done: {}, sk: Object.fromEntries(sk.map(s => [s.skill_id, s.rank])), quick: [null, null, null, null, null, null, null, null],
  });
  for (const q of qs) { if (q.state === 'done') P.done[q.quest_id] = true; else P.quests[q.quest_id] = { n: q.progress, ready: q.state === 'ready' }; }
  for (const [q, c] of Object.entries(P.qc || {})) if (P.quests[q]) P.quests[q].c = c; delete P.qc;
  for (const q of qb) P.quick[q.slot] = q.value;
  return P;
}
async function deleteCharacter(accountId, id) { const r = await pool.query('DELETE FROM characters WHERE id = $1 AND account_id = $2', [id, accountId]); return r.rowCount > 0; }

async function logChat(characterId, scene, text) { await pool.query('INSERT INTO chat_log (character_id, scene, text) VALUES ($1, $2, $3)', [characterId, scene, text]); }
async function stats() {
  const q = s => pool.query(s).then(r => r.rows);
  const [[a], [c], chats, top] = await Promise.all([q('SELECT count(*)::int AS n FROM accounts'), q('SELECT count(*)::int AS n FROM characters'),
    q('SELECT l.created_at, l.scene, l.text, c.name FROM chat_log l LEFT JOIN characters c ON c.id = l.character_id ORDER BY l.id DESC LIMIT 20'),
    q('SELECT name, cls, race, lv, scene, last_seen FROM characters ORDER BY lv DESC, xp DESC LIMIT 20')]);
  return { accounts: a.n, characters: c.n, chats, top };
}

module.exports = { pool, register, login, changePassword, session, logout, listCharacters, createCharacter, saveCharacter, loadCharacter, deleteCharacter, logChat, stats, hashPass, checkPass };
