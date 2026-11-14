// Bir hesaba yönetici yetkisi verir. Kullanım: node make-admin.js <kullanıcı adı>
'use strict';
const { pool } = require('./db');
const u = process.argv[2];
if (!u) { console.log('Kullanım: node make-admin.js <kullanıcı adı>'); process.exit(1); }
pool.query('UPDATE accounts SET is_admin = TRUE WHERE lower(username) = lower($1)', [u])
  .then(r => { console.log(r.rowCount ? `${u} artık yönetici` : `${u} bulunamadı`); return pool.end(); })
  .catch(e => { console.error(e); process.exit(1); });
