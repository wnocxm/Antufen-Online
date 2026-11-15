// Oyun verisini (orijinal dosyalardan çıkarılmış eşyalar, dükkânlar, haritalar) veritabanına aktarır.
// Kullanım: node import.js   (tekrar çalıştırmak güvenlidir; mevcut satırları günceller)
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const { pool } = require('./db');
const A = path.resolve(__dirname, '..', 'www', 'assets');
const J = path.resolve(__dirname, '..', 'www', 'js');

(async () => {
  await pool.query(fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8'));
  const D = JSON.parse(fs.readFileSync(path.join(A, 'items.json'), 'utf8'));
  const data = JSON.parse(fs.readFileSync(path.join(A, 'data.json'), 'utf8'));
  // İngilizce eşya adları
  const ctx = { document: { currentScript: null }, localStorage: { getItem: () => 'tr' }, navigator: { language: 'tr' }, location: {} };
  vm.createContext(ctx); vm.runInContext(fs.readFileSync(path.join(J, 'i18n.js'), 'utf8') + ';' + fs.readFileSync(path.join(J, 'i18n_data.js'), 'utf8') + ';this.EN_ITEM=EN_ITEM;', ctx);
  const c = await pool.connect();
  try {
    await c.query('BEGIN');
    let n = 0;
    for (const [id, it] of Object.entries(D.items)) {
      await c.query(`INSERT INTO items (id, name_tr, name_en, slot, cls, lv, price, sell, icon_kind, icon, stats, use_effect, gfx) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
        ON CONFLICT (id) DO UPDATE SET name_tr=EXCLUDED.name_tr, name_en=EXCLUDED.name_en, slot=EXCLUDED.slot, cls=EXCLUDED.cls, lv=EXCLUDED.lv, price=EXCLUDED.price, sell=EXCLUDED.sell,
        icon_kind=EXCLUDED.icon_kind, icon=EXCLUDED.icon, stats=EXCLUDED.stats, use_effect=EXCLUDED.use_effect, gfx=EXCLUDED.gfx`,
        [id, it.name, it.en || ctx.EN_ITEM[it.name] || null, it.slot || null, it.cls || null, it.lv || null, it.price || 0, it.sell || 0, it.icon[0], it.icon[1],
          it.st ? JSON.stringify(it.st) : null, it.use ? JSON.stringify(it.use) : null, it.gfx || null]);
      n++;
    }
    await c.query('DELETE FROM shops');
    let s = 0;
    for (const [npc, tabs] of Object.entries(D.shops))
      for (const [ti, [tab, ids]] of tabs.entries())
        for (const [pos, id] of ids.entries()) { s++; await c.query('INSERT INTO shops (npc, tab_index, tab_name, pos, item_id) VALUES ($1,$2,$3,$4,$5)', [npc, ti, tab, pos, id]); }
    for (const [id, sc] of Object.entries(data.scenes))
      await c.query('INSERT INTO scenes (id, name, map, music) VALUES ($1,$2,$3,$4) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, map=EXCLUDED.map, music=EXCLUDED.music', [id, sc.name, sc.map, sc.music || null]);
    await c.query('COMMIT');
    console.log(`aktarıldı: ${n} eşya, ${s} dükkân satırı, ${Object.keys(data.scenes).length} harita`);
  } catch (e) { await c.query('ROLLBACK'); throw e; } finally { c.release(); await pool.end(); }
})().catch(e => { console.error(e); process.exit(1); });
