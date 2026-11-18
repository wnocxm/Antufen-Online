// Görevleri HTML oyun kodundan (www/js/tr.js elle yazılanlar + www/js/quests_gen.js üretilenler + game.js ödül kuralı) C++ istemcisinin
// okuyacağı veri dosyasına çıkarır: www/assets/quests.json. HTML'deki QUESTS dizisinin son hâli (sıra aynı: görev sayaçları ve
// toplama zarları bu sırayla işler), Türkçe ve İngilizce metinler, NPC/canavar/harita adları ve NPC sözleri.
// Kaynaklar değişince (tools/gorevler.py, tr.js, ödüller) yeniden çalıştır. Elle düzenleme.
//   node tools/gorev_cikar.js
'use strict';
const fs = require('fs'), vm = require('vm');
const FILES = ['i18n.js', 'i18n_data.js', 'tr.js', 'tr_scenes.js', 'quests_gen.js'];
const MON = JSON.parse(fs.readFileSync('www/assets/denge.json', 'utf8')).MON;
// game.js: ödülü olmayan görevlere yedek formül, sonra orijinal ödül (q.rw) — game.js'teki satırların aynısı
const REWARD = `
const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const QXP_F = L => clamp(1.2 - L / 40, 0.3, 1);
for (const q of QUESTS) if (!q.reward) { const L = q.lv || (MON[q.target] && MON[q.target].lv) || 3, mx = (MON[q.target] && MON[q.target].xp) || 20;
  q.reward = q.type === 'kill' || q.type === 'collect' ? { xp: Math.round(((q.count || 1) * mx * 1.6 + 60 * L) * QXP_F(L)), gold: 10 + L * 6 } : { xp: Math.round((80 + 50 * L) * QXP_F(L)), gold: 8 + L * 4 }; }
for (const q of QUESTS) if (q.rw) { q.reward.xp = q.rw.xp; q.reward.gold = q.rw.gold; q.reward.items = q.rw.items || []; }
out = { QUESTS, TR };`;
// game.js'teki ödül satırlarının bu araçtakiyle aynı kaldığını denetle (game.js değişirse burası da değişmeli)
const game = fs.readFileSync('www/js/game.js', 'utf8');
for (const l of REWARD.split('\n').filter(l => l.startsWith('for (const q of QUESTS)') || l.startsWith('  q.reward'))) if (!game.includes(l.split(' // ')[0].replace(/; }$/, ''))) throw new Error('game.js ödül kuralı değişmiş, aracı güncelle: ' + l);
function load(lang) {
  const ctx = { console, Math, JSON, Object, Array, Set, Map, String, Number, RegExp, MON, out: null,
    document: { currentScript: null }, navigator: { language: lang }, location: { reload() { } },
    localStorage: { getItem: k => (k === 'anrufen_lang' ? lang : null), setItem() { } } };
  vm.createContext(ctx);
  for (const f of FILES) vm.runInContext(fs.readFileSync('www/js/' + f, 'utf8'), ctx, { filename: f });
  vm.runInContext(REWARD, ctx);
  return ctx.out;
}
const T = load('tr'), E = load('en');
if (T.QUESTS.length !== E.QUESTS.length) throw new Error('iki dilde görev sayısı farklı');
const TEXT = ['title', 'text', 'ok', 'wait', 'done', 'goal', 'item'];
const quests = T.QUESTS.map((q, i) => {
  const e = E.QUESTS[i]; if (e.id !== q.id) throw new Error('sıra farklı: ' + q.id);
  const o = {};
  for (const [k, v] of Object.entries(q)) {
    if (TEXT.includes(k) || k === 'choice' || k === 'g' || k === 'rw' || k === 'reward' || k.startsWith('_')) continue;
    o[k] = k === 'drops' ? v.map(d => d.slice(0, 2)) : v;
  }
  o.reward = { xp: q.reward.xp || 0, gold: q.reward.gold || 0, items: q.reward.items || [] };
  const txt = x => { const t = {}; for (const k of TEXT) if (x[k] != null) t[k] = x[k]; if (x.choice) t.choice = x.choice; if (x.drops) t.drops = x.drops.map(d => d[2]); return t; };
  o.tr = txt(q); o.en = txt(e);
  return o;
});
const pick = (o, ks) => Object.fromEntries(ks.map(k => [k, o[k]]));
const out = { kaynak: 'www/js/tr.js + quests_gen.js + game.js ödülleri (tools/gorev_cikar.js)', quests,
  ad: { tr: pick(T.TR, ['name', 'scene', 'greet']), en: pick(E.TR, ['name', 'scene', 'greet']) } };
fs.writeFileSync('www/assets/quests.json', JSON.stringify(out));
const types = {}; for (const q of quests) types[q.type] = (types[q.type] || 0) + 1;
console.log('quests.json:', quests.length, 'görev', JSON.stringify(types), '·', (fs.statSync('www/assets/quests.json').size / 1024).toFixed(0), 'KB');
