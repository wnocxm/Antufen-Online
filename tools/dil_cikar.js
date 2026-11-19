// İngilizce çeviri verisini HTML oyun kodundan (www/js/i18n.js + i18n_data.js) C++ istemcisinin okuyacağı dosyaya çıkarır:
// www/assets/dil_en.json = { ui: EN_UI sözlüğü, kurallar: EN_RULES [kaynak, bayraklar, değiştirme], esya: EN_ITEM, sinif, irk }.
// Değiştirme metni JS biçiminde ($1, $&, $$); işlev olan kurallar (tx'i bir gruba uygulayanlar) şablona çevrilir: "$t1" = tx(1. grup).
// i18n.js / i18n_data.js değişince yeniden çalıştır. Çıktı üretilmiş veridir (elle düzenleme).
//   node tools/dil_cikar.js
'use strict';
const fs = require('fs'), vm = require('vm');
const ctx = { console, Math, JSON, Object, Array, Set, Map, String, Number, RegExp, document: { currentScript: null }, navigator: { language: 'en' }, location: { reload() { } },
  localStorage: { getItem: k => (k === 'anrufen_lang' ? 'en' : null), setItem() { } } };
vm.createContext(ctx);
for (const f of ['i18n.js', 'i18n_data.js']) vm.runInContext(fs.readFileSync('www/js/' + f, 'utf8'), ctx, { filename: f });
vm.runInContext('out = { EN_UI, EN_RULES, EN_ITEM, EN }', ctx);
const { EN_UI, EN_RULES, EN_ITEM, EN } = ctx.out;
// işlev kuralları: tx'i işaretleyen bir yerine koyma ile çağır, çıktıdan şablon çıkar
ctx.tx = s => '\u0002' + s + '\u0003';
const rules = EN_RULES.map(([re, rep]) => {
  if (/\[[^\]]*[^\x00-\x7f][^\]]*\]/.test(re.source)) throw new Error('kural köşeli ayraç içinde ASCII dışı harf içeriyor (C++ std::regex bayt bayt çalışır): ' + re.source);
  if (typeof rep === 'string') return [re.source, re.flags, rep];
  const args = ['\u0001M']; for (let i = 1; i <= 9; i++) args.push('\u0001G' + i);
  const s = rep(...args).replace(/\u0002\u0001G(\d)\u0003/g, '$t$1').replace(/\u0001G(\d)/g, '$$$1');
  if (/[\u0001-\u0003]/.test(s)) throw new Error('kural şablona çevrilemedi: ' + re.source);
  return [re.source, re.flags, s, 1];
});
const out = { kaynak: 'www/js/i18n.js + i18n_data.js (tools/dil_cikar.js; elle düzenleme)', ui: EN_UI, kurallar: rules, esya: EN_ITEM, sinif: EN.cls, irk: EN.race };
fs.writeFileSync('www/assets/dil_en.json', JSON.stringify(out));
console.log('dil_en.json:', Object.keys(EN_UI).length, 'sözlük ·', rules.length, 'kural (' + rules.filter(r => r[3]).length + ' şablon) ·', Object.keys(EN_ITEM).length, 'eşya ·',
  (fs.statSync('www/assets/dil_en.json').size / 1024).toFixed(0), 'KB');
