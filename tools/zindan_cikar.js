// Zindan tanımlarını HTML oyun kodundan (www/js/dungeon.js: DUNGEONS, DUNGEON_EXIT, DUNGEON_TP, pano sözleri) C++ istemcisinin
// okuyacağı veri dosyasına çıkarır: www/assets/zindan.json. dungeon.js değişince yeniden çalıştır. Elle düzenleme.
//   node tools/zindan_cikar.js
'use strict';
const fs = require('fs'), vm = require('vm');
const src = fs.readFileSync('www/js/dungeon.js', 'utf8'), cut = src.indexOf('const Dungeon = (');
if (cut < 0) throw new Error('dungeon.js: Dungeon modülü bulunamadı');
function load(lang) {
  const ctx = { LANG: lang, TR: { greet: {} }, out: null };
  vm.createContext(ctx);
  vm.runInContext(src.slice(0, cut) + '\nout = { DUNGEONS, DUNGEON_EXIT, DUNGEON_TP, greet: TR.greet };', ctx, { filename: 'dungeon.js' });
  return ctx.out;
}
const T = load('tr'), E = load('en');
const out = { kaynak: 'www/js/dungeon.js (tools/zindan_cikar.js)', dungeons: T.DUNGEONS, exit: T.DUNGEON_EXIT, tp: T.DUNGEON_TP, greet: { tr: T.greet, en: E.greet } };
fs.writeFileSync('www/assets/zindan.json', JSON.stringify(out));
console.log('zindan.json:', out.dungeons.length, 'zindan,', Object.keys(out.tp).length, 'ışınlayıcı,', Object.keys(out.greet.tr).length, 'söz ·', (fs.statSync('www/assets/zindan.json').size / 1024).toFixed(1), 'KB');
