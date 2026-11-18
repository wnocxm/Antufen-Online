// Denge tablolarını HTML oyun kodundan (www/js/game.js) C++ istemcisinin okuyacağı veri dosyasına çıkarır: www/assets/denge.json
//   MON (elle yazılmış canavar değerleri + sonradan eklenenler), XPT / MXPT (seviye ve canavar deneyimi), CLS (sınıf taban değerleri).
// Kaynak game.js'tir (usta kopya); orada değişince bu araç yeniden çalıştırılır. Elle düzenleme.
//   node tools/denge_cikar.js
'use strict';
const fs = require('fs'), vm = require('vm');
const src = fs.readFileSync('www/js/game.js', 'utf8');
const block = (start) => {   // "const AD = {" ile başlayıp satır başındaki "};" ile biten blok
  const i = src.indexOf(start); if (i < 0) throw new Error('bulunamadı: ' + start);
  const j = src.indexOf('\n};', i); return src.slice(i, j + 3);
};
const line = (start) => { const i = src.indexOf(start); if (i < 0) throw new Error('bulunamadı: ' + start); return src.slice(i, src.indexOf('\n', i)); };
// MON'a sonradan eklenen satırlar: "MON['…'] = …" ve "for (const n of […]) MON[n] = …"
const extra = src.split('\n').filter(l => /^MON\[/.test(l) || /^for \(const n of \[[^\]]*\]\) MON\[n\]/.test(l)).join('\n');
const code = [
  'const clamp = (v, a, b) => Math.max(a, Math.min(b, v));', 'const R100 = v => v / 100;',
  line('const XPT = ['), line('const MXPT = ['), line('const mobXp = '),
  block('const MON = {'), extra, block('const CLS = {'),
  'out = { MON, XPT, MXPT, CLS };',
].join('\n');
const ctx = { out: null, Math }; vm.createContext(ctx); vm.runInContext(code, ctx);
const { MON, XPT, MXPT, CLS } = ctx.out;
const cls = {};
for (const [k, c] of Object.entries(CLS)) {
  cls[k] = {}; for (const f of ['hp', 'mp', 'atk', 'def', 'ghp', 'gmp', 'gatk', 'gdef', 'dmgK', 'range', 'melee', 'color', 'bolt', 'boltHit', 'snd']) if (c[f] != null) cls[k][f] = c[f];
}
const out = { kaynak: 'www/js/game.js (tools/denge_cikar.js)', MON, XPT, MXPT, CLS: cls };
fs.writeFileSync('www/assets/denge.json', JSON.stringify(out));
console.log('denge.json: MON', Object.keys(MON).length, '· XPT', XPT.length, '· MXPT', MXPT.length, '· sınıf', Object.keys(cls).join(' '));
