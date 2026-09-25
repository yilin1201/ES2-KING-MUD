-- ES2-KING durable backing store.
-- Neolith save files remain opaque; Postgres stores one checksummed snapshot.
CREATE TABLE IF NOT EXISTS es2_persistence_snapshots (
  slot text PRIMARY KEY,
  archive bytea NOT NULL,
  checksum text NOT NULL CHECK (checksum ~ '^[0-9a-f]{64}$'),
  size_bytes bigint NOT NULL CHECK (size_bytes >= 0),
  updated_at timestamptz NOT NULL DEFAULT now()
);
