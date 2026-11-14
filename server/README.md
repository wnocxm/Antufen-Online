# Anrufen Online sunucusu

Hesaplar, karakter kayıtları, aynı haritadaki oyuncuları gösterme ve sohbet işlerini yapar. Oyun dosyalarını (`www/`) ve yönetim panelini (`/admin`) de sunar.

## Neler var

| Dosya | Görevi |
|---|---|
| `schema.sql` | Veritabanı tabloları: hesaplar, oturumlar, karakterler, çanta, ekipman, görevler, beceriler, kısayollar, sohbet kaydı, eşyalar, dükkânlar, haritalar |
| `db.js` | Şifreleme (scrypt), giriş, karakteri tablolara yazma ve okuma |
| `server.js` | HTTP API ve WebSocket |
| `import.js` | Orijinal dosyalardan çıkarılan eşya, dükkân ve harita verisini veritabanına aktarır |
| `make-admin.js` | Bir hesaba yönetici yetkisi verir |
| `admin.html` | Yönetim paneli: çevrimiçi oyuncular, en yüksek seviyeler, son sohbetler (5 saniyede bir yenilenir) |
| `test.js` | Uçtan uca test |

## API

- `POST /api/register` `{username, password}` → `{token}`
- `POST /api/login` `{username, password}` → `{token, characters}`
- `POST /api/logout`
- `GET /api/characters`, `POST /api/characters` `{state}`
- `GET`, `PUT` `{state}` ve `DELETE /api/characters/:id`
- `GET /api/admin/stats` (yalnızca yönetici)
- WebSocket `/ws?token=...` ile şu mesajlar gider: `join`, `pos`, `scene`, `chat`. Sunucu şunları gönderir: `players`, `add`, `pos`, `del`, `chat`.

`Authorization: Bearer <token>` başlığı, kayıt ve giriş dışındaki tüm isteklerde gerekir.

## Bilgisayarda çalıştırma

```bash
sudo apt install postgresql nodejs npm
sudo -u postgres psql -c "CREATE ROLE anrufen LOGIN PASSWORD 'anrufen_dev'" -c "CREATE DATABASE anrufen OWNER anrufen"
cd server && npm install
npm run import      # tabloları kurar, oyun verisini aktarır
npm test            # her şey çalışıyor mu?
npm start           # http://localhost:8080 (oyun), http://localhost:8080/admin (panel)
```

Yönetici olmak için önce oyunda ya da API ile hesap açın, sonra şunu çalıştırın:

```bash
node make-admin.js kullanici_adi
```

## Gerçek sunucu (telefondan oynamak için)

1. Bir VPS kiralayın (Ubuntu, 1 GB RAM yeter) ve bir alan adı alın.
2. Yukarıdaki kurulumu yapın, ama **güçlü bir veritabanı şifresi** kullanın.
3. Ortam değişkenlerini ayarlayın:
   - `DATABASE_URL=postgres://anrufen:GUCLU_SIFRE@localhost:5432/anrufen`
   - `PORT=8080`
   - `ALLOW_ORIGINS=https://wnocxm.github.io` (oyunun açıldığı adresler, virgülle ayrılır)
4. HTTPS için önüne Caddy koyun. Telefon tarayıcıları şifresiz `ws://` bağlantısına izin vermez. Caddy sertifikayı kendisi alır. `/etc/caddy/Caddyfile` içeriği:
   ```
   oyun.alanadiniz.com {
     reverse_proxy localhost:8080
   }
   ```
5. Sunucunun sürekli açık kalması için `systemd` servisi ya da `pm2 start server.js` kullanın.

## Güvenlik notları

- Şifreler scrypt ve tuzla saklanır; düz metin şifre hiçbir yerde tutulmaz.
- Kayıt ve giriş isteklerinde IP başına hız sınırı vardır.
- Bir hesap yalnızca kendi karakterlerini görebilir ve değiştirebilir.
- Şimdilik kayıt dosyasını istemci gönderiyor ve sunucu yalnızca temel kontrolleri yapıyor. Savaş, ödül ve eşya hesapları adım adım sunucuya taşınacak, böylece hile yapılamayacak.
