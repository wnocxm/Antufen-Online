// Görev denetimi: oyundaki her görevi (www/js/tr.js + quests_gen.js) orijinal Symbian ham kaydıyla
// (kaynak/cikti/cozulmus/tablolar/gorev_ham.json, tools/gorev_ham.py) alan alan karşılaştırır.
// Tarayıcı gerekmez:  node tools/test/gorev_denetim.js  [OUT=rapor.txt]  [AYRINTI=1]
// Denetlenen: numara eşleşmesi, veren, teslim alan, hedef, adet, zincir (önceki görev), altın, deneyim, ödül eşyaları (sınıfa göre).
'use strict';
const fs = require('fs'), path = require('path'), vm = require('vm');
const J = path.resolve(__dirname, '..', '..', 'www', 'js'), K = path.resolve(__dirname, '..', '..');
function quests() {
  const g = { document: { currentScript: null }, localStorage: { getItem: () => 'tr', setItem() {} }, navigator: { language: 'tr' }, location: {}, console };
  vm.createContext(g);
  vm.runInContext(['i18n.js', 'i18n_data.js', 'tr.js', 'tr_scenes.js', 'quests_gen.js'].map(f => fs.readFileSync(path.join(J, f), 'utf8')).join(';\n') + ';this.__Q = QUESTS;', g);
  return g.__Q;
}
const Q = quests(), H = JSON.parse(fs.readFileSync(path.join(K, 'kaynak/cikti/cozulmus/tablolar/gorev_ham.json'), 'utf8'));
const prev = {}; for (const r of Object.values(H)) if (r.next) (prev[r.next] = prev[r.next] || []).push(r.id);
const refNames = r => (r.refs || []).flatMap(x => [x[0], '☆' + x[0], '☆☆' + x[0], '★' + x[0]]);   // haritada yıldızlı adla duran canavar aynıdır
// içerikle eşleşen orijinal kayıt (numara tutmuyorsa): aynı veren + teslim + hedef
function byContent(q) {
  return Object.values(H).filter(r => r.gname === q.giver && r.tname === q.to && (!q.target || refNames(r).includes(q.target)) && (!q.count || (r.counts || []).reduce((a, b) => a + b, 0) === q.count));
}
// bilinen, belgelenmiş istisnalar (docs/04-gorevler.md › Orijinalden bilinçli sapmalar)
const ISTISNA = { 81063: 'adet', 81396: 'adet', 80597: 'veren/teslim', 81993: 'hedef', 81998: 'hedef' };
const ALIAS = { 30676: 'growthBox' };   // tools/gorevler.py ITEMALIAS
const out = [], stat = {}; let curId = 0; const add = (k, s) => { if (ISTISNA[curId] === k) k = 'istisna:' + k; stat[k] = (stat[k] || 0) + 1; out.push(`[${k}] ${s}`); };
const ok = { id: 0 };
for (const q of Q) {
  curId = q.id; let r = H[q.id];
  const same = r && r.tname === q.to && (!r.gname || r.gname === q.giver);
  if (!same) {
    const c = byContent(q);
    if (c.length) { add('numara', `${q.id} "${q.title}" ${q.giver}→${q.to} ${q.target || ''}: orijinali ${c.map(x => x.id).join('/')} (${r ? `${q.id} orijinalde "${r.title}" ${r.gname}→${r.tname}` : `${q.id} orijinalde yok`})`); r = c[0]; }
    else if (!r) { add('kayıtsız', `${q.id} "${q.title}" ${q.giver}→${q.to}: orijinal kayıt yok`); continue; }
    else { add('veren/teslim', `${q.id} "${q.title}": bizde ${q.giver}→${q.to}, orijinalde ${r.gname || '?'}→${r.tname}`); }
  } else ok.id++;
  if (r.err) add('çözülemedi', `${q.id}: ham kayıt sorunlu (${r.err})`);
  // hedef ve adet
  const cnt = (r.counts || []).reduce((a, b) => a + b, 0);
  if (q.targets) { for (const [n] of q.targets) if (!refNames(r).includes(n)) add('hedef', `${q.id}: ${n} orijinal başvurularda yok (${refNames(r).join(',')})`); }
  else if (q.target && q.type !== 'collect' && !refNames(r).includes(q.target)) add('hedef', `${q.id} "${q.title}": hedef ${q.target}, orijinal başvurular ${refNames(r).join(',')}`);
  if ((q.type === 'kill' || q.type === 'collect' || q.type === 'pickup' || q.type === 'deliver') && q.count && cnt && q.count !== cnt) add('adet', `${q.id} "${q.title}": bizde ${q.count}, orijinalde ${cnt}`);
  // zincir: orijinal "önceki" görev(ler); oyunda olmayan ara görevlerin üstünden atlanarak (ör. A→B→C, B oyunda yoksa C'nin öncesi A)
  const inGame = new Set(Q.map(x => x.id)), ours = q.req == null ? [] : Array.isArray(q.req) ? q.req : [q.req];
  const origPrev = (id, seen = new Set()) => { const o = []; for (const p of prev[id] || []) { if (seen.has(p)) continue; seen.add(p); if (inGame.has(p)) o.push(p); else o.push(...origPrev(p, seen)); } return o; };
  const orig = origPrev(r.id), raw = prev[r.id] || [];
  if (ours.length && orig.length && !ours.some(x => orig.includes(x))) add('zincir:yanlış', `${q.id} "${q.title}": bizde önceki ${ours.join('/')}, orijinalde ${orig.join('/')}${raw.join('/') !== orig.join('/') ? ` (ham ${raw.join('/')})` : ''}`);
  else if (!ours.length && orig.length) add('zincir:eksik', `${q.id} "${q.title}": bizde öncesiz, orijinalde önceki ${orig.join('/')}`);
  else if (ours.length && !orig.length) add('zincir:bizim', `${q.id} "${q.title}": orijinalde öncesiz, bizde ${ours.join('/')} (açılma için eklenmiş)`);
  // ödüller (oyundaki hesaplanmış ödül game.js'te; burada rw ve elle yazılan reward karşılaştırılır)
  const rw = q.rw || q.reward || {}, g0 = rw.gold, x0 = (q.reward || {}).xp;
  if (g0 != null && g0 !== r.gold) add('altın', `${q.id}: bizde ${g0}, orijinalde ${r.gold}`);
  if (x0 != null && x0 !== r.xp) add('deneyim', `${q.id}: bizde ${x0}, orijinalde ${r.xp}`);
  if (x0 == null) stat['deneyim (formülden)'] = (stat['deneyim (formülden)'] || 0) + 1;
  const oi = (r.items || []).map(x => `${ALIAS[x[0]] || x[0]}×${x[1]}${x[2] ? '/' + [].concat(x[2]).join('+') : ''}`).sort().join(' '), bi = (rw.items || []).map(x => `${x[0]}×${x[1]}${x[2] ? '/' + [].concat(x[2]).join('+') : ''}`).sort().join(' ');
  if (oi !== bi) add('eşya', `${q.id}: bizde [${bi}], orijinalde [${oi}]`);
}
const rep = [`oyundaki görev ${Q.length}, numarası ve veren/teslimi tutan ${ok.id}`, 'özet: ' + JSON.stringify(stat), '', ...out].join('\n');
if (process.env.OUT) fs.writeFileSync(process.env.OUT, rep);
console.log(rep.split('\n').slice(0, process.env.AYRINTI ? 1e6 : 3).join('\n'));
