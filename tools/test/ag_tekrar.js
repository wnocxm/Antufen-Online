// Ağ aşama 1 sınaması (docs/10-ag.md): kayıttan yeniden oynatma. Her senaryoda bir bot yalnız karo yönü + komut göndererek oynar
// (savaş, beceri, iksir, kişiyle konuşma, görev al/teslim et, görev yürüyüşü, ölüm/diriliş, onay kutuları); kayıt sunucunun yapacağı gibi
// yeni bir dünyada aynı başlangıçtan (kayıt JSON'u + tohum + oyun saati) yeniden oynatılır. Her yarım saniyede iki dünyanın özeti aynı olmalı.
//   node tools/test/ag_tekrar.js   (SN=süre saniye, varsayılan 600; OUT=klasör; önce: cmake --build native/build)
const { execFileSync } = require('child_process');
const fs = require('fs'), path = require('path');
const OUT = process.env.OUT || '/tmp/ag_tekrar', SN = +(process.env.SN || 600);
const CASES = [
  ['acemi savaşçı (kamp, görevler)', ['yenikarakter Bot 战士 人类 male 1', 'baslat'], 11],
  ['savaşçı Sv 12, orman', ['yenikarakter Kurt 战士 人类 male 1', 'baslat', 'seviye 12', 'gmgear', 'sahne 120004 30 30'], 1],
  ['elf büyücü Sv 30 + kurt', ['yenikarakter Elf 法师 精灵 fema 2', 'baslat', 'seviye 30', 'gmgear', 'evcilver 狼', 'evcilcagir 0', 'sahne 120019 30 30'], 2],
  ['rahip Sv 45, zindanda + panda', ['yenikarakter Rahip 牧师 人类 fema 3', 'baslat', 'seviye 45', 'ust 1', 'gmgear', 'evcilver 熊猫', 'evcilcagir 0', 'zindangir swy 0'], 3],
  ['zayıf elf, yüksek harita (ölüm)', ['yenikarakter Zayif 战士 精灵 male 1', 'baslat', 'seviye 5', 'sahne 120019 30 30'], 4],
];
fs.mkdirSync(OUT, { recursive: true });
let bad = 0;
for (const [ad, setup, bot] of CASES) {
  const f = path.join(OUT, `kayit_${bot}.json`);
  const t0 = Date.now();
  const o = execFileSync('native/build/anrufen_test', ['-'], { input: ['veri www/assets', 'tohum 7', ...setup, `agbot ${SN} ${bot} ${f}`, `agoyna ${f} -`].join('\n') + '\n', encoding: 'utf8' });
  const ms = Date.now() - t0;
  const son = (o.match(/agbot: (.*) · özet/) || [])[1], r = JSON.parse(o.split('\n').find(l => l.startsWith('{"adim"')));
  const ok = r.ozetFarkli === 0 && r.ozetAyni > 0;
  if (!ok) bad++;
  console.log(`${ad.padEnd(34)} ${r.adim} adım, ${r.komut} komut · özet ${r.ozetAyni} aynı, ${r.ozetFarkli} farklı${r.ilkFark >= 0 ? ` (ilk ${r.ilkFark})` : ''} · son: ${son} · ${ms} ms · ${ok ? 'AYNI' : 'FARKLI'}`);
}
console.log(bad ? `${bad} senaryo farklı` : `${CASES.length} senaryonun hepsi aynı`);
if (bad) process.exitCode = 1;
