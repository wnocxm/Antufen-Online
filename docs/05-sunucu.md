# 05 · Sunucu (server/)

Node.js (yalnız `pg` ve `ws`; Express yok) + PostgreSQL 16. Ayrıntılı kurulum: `server/README.md`.

## Dosyalar
| Dosya | İçerik |
|---|---|
| `schema.sql` | Tablolar (idempotent, `import.js` ve sunucu açılışında çalışır) |
| `db.js` | Hesap (scrypt şifre, oturum belirteci), karakter durumunu tablolara bölüp birleştirme |
| `server.js` | HTTP API + WebSocket `/ws`, IP başına hız sınırı, CORS (`https://wnocxm.github.io`) |
| `import.js` | Oyun verisini SQL'e aktarır: eşyalar, dükkânlar, sahneler, **görevler** (tarayıcı kodunu `vm` ile iki dilde çalıştırır) |
| `make-admin.js` | `node make-admin.js <kullanıcı>` yönetici yapar (GM) |
| `admin.html` | Basit yönetim sayfası (istatistik) |
| `test.js` | Uçtan uca test (kayıt, giriş, şifre, karakter, WebSocket, sohbet) |

## Tablolar
Hesap: `accounts`, `sessions`. Karakter: `characters` (temel alanlar), `character_items`, `character_equipment`,
`character_quests (state: active|ready|done, progress)`, `character_skills`, `character_quickbar`, `chat_log`.
Oyun verisi: `items`, `shops`, `scenes`, `quests` (tür, veren, teslim, hedef, adet, harita, önceki görevler, ödül, TR/EN metinler).

## API
`GET /api/health` · `POST /api/register|login` → `{token, admin, characters}` · `POST /api/password` · `POST /api/logout` ·
`GET/POST /api/characters` · `GET/PUT/DELETE /api/characters/:id` · `GET /api/admin/stats`.
"GM" önekli karakter adı yalnızca yöneticiye (aksi 403 `gmname`). Hesap başına en çok 4 karakter.
WebSocket mesajları: `join, pos, scene, chat` → `players, add, del, pos, chat`; aynı karakterle ikinci giriş eskisini 4001 ile kapatır.

## İstemci tarafı (`www/js/net.js`)
`Net.login/changePass/chars/create/play/remove`, `Net.save(P)` 4 sn'de bir son durumu gönderir, sayfa gizlenince `keepalive` ile gönderir.
`Remote`: diğer oyuncular (konuma yumuşak yürüme, kendi görünümü).

## Çıkış planı
- Sunucu için VPS + alan adı + HTTPS (kullanıcı hazırlayacak). `DATABASE_URL`, `PORT` ortam değişkenleri.
- Çıkışta çevrimdışı mod kapanacak: bir ayar bayrağı eklenip başlık ekranında yalnızca hesapla giriş kalacak.
