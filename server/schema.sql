-- Anrufen Online sunucu veritabanı (PostgreSQL 14+)
-- Çalıştırma: psql -d anrufen -f schema.sql   (tekrar çalıştırmak güvenlidir)

-- ================= Hesaplar =================
CREATE TABLE IF NOT EXISTS accounts (
  id          BIGSERIAL PRIMARY KEY,
  username    TEXT NOT NULL,
  pass_hash   TEXT NOT NULL,                 -- scrypt: tuz$özet
  is_admin    BOOLEAN NOT NULL DEFAULT FALSE,
  banned      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_login  TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS accounts_username_uq ON accounts (lower(username));

CREATE TABLE IF NOT EXISTS sessions (
  token       TEXT PRIMARY KEY,
  account_id  BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at  TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS sessions_account_idx ON sessions (account_id);

-- ================= Karakterler =================
CREATE TABLE IF NOT EXISTS characters (
  id            BIGSERIAL PRIMARY KEY,
  account_id    BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  race          TEXT NOT NULL,                -- 人类 | 精灵
  cls           TEXT NOT NULL,                -- 战士 | 法师 | 牧师
  sex           TEXT NOT NULL,                -- male | fema
  face          INT  NOT NULL DEFAULT 1,
  lv            INT  NOT NULL DEFAULT 1,
  xp            BIGINT NOT NULL DEFAULT 0,
  gold          BIGINT NOT NULL DEFAULT 0,
  hp            INT  NOT NULL DEFAULT 0,
  mp            INT  NOT NULL DEFAULT 0,
  skill_points  INT  NOT NULL DEFAULT 0,
  scene         TEXT NOT NULL,
  x             REAL NOT NULL DEFAULT 0,
  y             REAL NOT NULL DEFAULT 0,
  home          JSONB,                        -- ölünce doğulan yer [sahne, x, y]
  flags         JSONB NOT NULL DEFAULT '{}',
  extra         JSONB NOT NULL DEFAULT '{}',  -- henüz tabloya ayrılmamış alanlar
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen     TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS characters_name_uq ON characters (lower(name));
CREATE INDEX IF NOT EXISTS characters_account_idx ON characters (account_id);

-- çanta
CREATE TABLE IF NOT EXISTS character_items (
  character_id BIGINT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  item_id      TEXT NOT NULL,
  qty          INT  NOT NULL CHECK (qty > 0),
  PRIMARY KEY (character_id, item_id)
);
-- kuşanılmış ekipman
CREATE TABLE IF NOT EXISTS character_equipment (
  character_id BIGINT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  slot         TEXT NOT NULL,                 -- weap head body belt shoe glove neck ring
  item_id      TEXT NOT NULL,
  PRIMARY KEY (character_id, slot)
);
-- görevler: active | ready | done
CREATE TABLE IF NOT EXISTS character_quests (
  character_id BIGINT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  quest_id     INT  NOT NULL,
  state        TEXT NOT NULL CHECK (state IN ('active', 'ready', 'done')),
  progress     INT  NOT NULL DEFAULT 0,
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (character_id, quest_id)
);
-- beceri kademeleri
CREATE TABLE IF NOT EXISTS character_skills (
  character_id BIGINT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  skill_id     TEXT NOT NULL,
  rank         INT  NOT NULL CHECK (rank BETWEEN 1 AND 10),
  PRIMARY KEY (character_id, skill_id)
);
-- kısayol yuvaları (0 = büyük saldırı düğmesi, 1-7 yay)
CREATE TABLE IF NOT EXISTS character_quickbar (
  character_id BIGINT NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  slot         INT  NOT NULL CHECK (slot BETWEEN 0 AND 7),
  value        TEXT NOT NULL,                 -- s<beceri sırası> | i:<eşya>
  PRIMARY KEY (character_id, slot)
);

-- sohbet kaydı
CREATE TABLE IF NOT EXISTS chat_log (
  id           BIGSERIAL PRIMARY KEY,
  character_id BIGINT REFERENCES characters(id) ON DELETE SET NULL,
  scene        TEXT,
  channel      TEXT NOT NULL DEFAULT 'scene',
  text         TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS chat_log_time_idx ON chat_log (created_at DESC);

-- ================= Oyun verisi (orijinal dosyalardan aktarılır: node import.js) =================
CREATE TABLE IF NOT EXISTS items (
  id         TEXT PRIMARY KEY,
  name_tr    TEXT NOT NULL,
  name_en    TEXT,
  slot       TEXT,                            -- ekipman yuvası; tüketimde NULL
  cls        TEXT,
  lv         INT,
  price      INT NOT NULL DEFAULT 0,
  sell       INT NOT NULL DEFAULT 0,
  icon_kind  TEXT,
  icon       INT,
  stats      JSONB,                           -- {"atk":78,...}
  use_effect JSONB,                           -- {"hp":800}
  gfx        TEXT
);
CREATE TABLE IF NOT EXISTS shops (
  npc        TEXT NOT NULL,                   -- NPC'nin orijinal (Çince) adı
  tab_index  INT  NOT NULL,
  tab_name   TEXT NOT NULL,
  pos        INT  NOT NULL,
  item_id    TEXT NOT NULL REFERENCES items(id),
  PRIMARY KEY (npc, tab_index, pos)
);
CREATE TABLE IF NOT EXISTS scenes (
  id     TEXT PRIMARY KEY,
  name   TEXT NOT NULL,
  map    TEXT NOT NULL,
  music  TEXT
);
