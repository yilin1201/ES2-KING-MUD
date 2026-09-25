#!/usr/bin/env python3
"""ES2-KING Neon/Lakebase durable backing bridge.

Neolith save files stay opaque: one checksummed tar.gz snapshot is stored in
Postgres. This program never prints DATABASE_URL or save-file contents.
"""
from __future__ import annotations
import argparse, gzip, hashlib, io, json, os, shutil, sys, tarfile, tempfile
from datetime import datetime, timezone
from pathlib import Path

STATUS = Path(os.environ.get("ES2_PERSISTENCE_STATUS_FILE", "/tmp/es2-neon-persistence-status.json"))
CACHE = Path(os.environ.get("ES2_PERSISTENCE_CHECKSUM_FILE", "/tmp/es2-neon-persistence-checksum"))
SLOT = os.environ.get("ES2_PERSISTENCE_SLOT", "production")

def write_status(**updates):
    state={"backend":"neon","configured":bool(os.environ.get("DATABASE_URL"))}
    try:
        old=json.loads(STATUS.read_text(encoding="utf-8"))
        if isinstance(old,dict): state.update(old)
    except Exception:
        pass
    state.update(updates); state["updated_at"]=datetime.now(timezone.utc).isoformat()
    STATUS.parent.mkdir(parents=True,exist_ok=True)
    tmp=STATUS.with_suffix(".tmp"); tmp.write_text(json.dumps(state,ensure_ascii=False),encoding="utf-8"); tmp.replace(STATUS)

def connect():
    url=os.environ.get("DATABASE_URL")
    if not url: raise RuntimeError("DATABASE_URL is not configured")
    import psycopg2
    conn=psycopg2.connect(url,connect_timeout=10,application_name="es2-king-persistence")
    # Idempotent bootstrap mirrors db/migrations/001_es2_persistence.sql.
    ddl=(
        "CREATE TABLE IF NOT EXISTS es2_persistence_snapshots ("
        "slot text PRIMARY KEY,"
        "archive bytea NOT NULL,"
        "checksum text NOT NULL CHECK (checksum ~ '^[0-9a-f]{64}$'),"
        "size_bytes bigint NOT NULL CHECK (size_bytes >= 0),"
        "updated_at timestamptz NOT NULL DEFAULT now()"
        ")"
    )
    with conn.cursor() as cur:
        cur.execute(ddl)
    conn.commit()
    return conn

def make_archive(source:Path):
    if not source.is_dir(): raise RuntimeError(f"source directory does not exist: {source}")
    buf=io.BytesIO()
    # mtime=0 makes unchanged save trees byte-identical, so the sync loop can skip DB writes.
    with gzip.GzipFile(fileobj=buf,mode="wb",compresslevel=6,mtime=0) as gz:
        with tarfile.open(fileobj=gz,mode="w") as tf:
            for path in sorted(source.rglob("*")):
                rel=path.relative_to(source)
                if path.is_symlink(): raise RuntimeError(f"refusing symlink in persistence data: {rel}")
                tf.add(path,arcname=str(rel),recursive=False)
    payload=buf.getvalue()
    return payload,hashlib.sha256(payload).hexdigest()

def safe_extract(payload:bytes,target:Path):
    target.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="es2-neon-restore-") as td:
        stage=Path(td)/"data"; stage.mkdir()
        with tarfile.open(fileobj=io.BytesIO(payload),mode="r:gz") as tf:
            for m in tf.getmembers():
                p=Path(m.name)
                if p.is_absolute() or ".." in p.parts or m.issym() or m.islnk():
                    raise RuntimeError(f"unsafe archive member: {m.name}")
            tf.extractall(stage)
        for child in target.iterdir():
            shutil.rmtree(child) if child.is_dir() and not child.is_symlink() else child.unlink()
        for child in stage.iterdir(): shutil.move(str(child),str(target/child.name))

def upload(source:Path):
    payload,checksum=make_archive(source)
    try:
        if CACHE.read_text(encoding="ascii").strip()==checksum:
            write_status(reachable=True,last_upload="unchanged",last_error=None,checksum=checksum,size_bytes=len(payload))
            print(f"NEON PERSISTENCE UPLOAD SKIP: unchanged sha256={checksum}"); return
    except FileNotFoundError:
        pass
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""INSERT INTO es2_persistence_snapshots(slot,archive,checksum,size_bytes,updated_at)
VALUES (%s,%s,%s,%s,now())
ON CONFLICT (slot) DO UPDATE SET archive=EXCLUDED.archive,checksum=EXCLUDED.checksum,
size_bytes=EXCLUDED.size_bytes,updated_at=now()""",(SLOT,payload,checksum,len(payload)))
    CACHE.write_text(checksum+"\n",encoding="ascii")
    write_status(reachable=True,last_upload="success",last_error=None,checksum=checksum,size_bytes=len(payload))
    print(f"NEON PERSISTENCE UPLOAD PASS: slot={SLOT} bytes={len(payload)} sha256={checksum}")

def download(target:Path):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT archive,checksum,size_bytes FROM es2_persistence_snapshots WHERE slot=%s",(SLOT,))
            row=cur.fetchone()
    if row is None:
        write_status(reachable=True,last_restore="empty",last_error=None)
        print(f"NEON PERSISTENCE RESTORE EMPTY: slot={SLOT}"); return 3
    payload=bytes(row[0]); expected=row[1]; actual=hashlib.sha256(payload).hexdigest()
    if actual!=expected: raise RuntimeError("Neon snapshot checksum mismatch")
    safe_extract(payload,target); CACHE.write_text(actual+"\n",encoding="ascii")
    write_status(reachable=True,last_restore="success",last_error=None,checksum=actual,size_bytes=len(payload))
    print(f"NEON PERSISTENCE RESTORE PASS: slot={SLOT} bytes={len(payload)} sha256={actual}"); return 0

def status():
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT checksum,size_bytes,updated_at FROM es2_persistence_snapshots WHERE slot=%s",(SLOT,))
            row=cur.fetchone()
    out={"backend":"neon","configured":True,"reachable":True,"record_exists":row is not None,"slot":SLOT}
    if row: out.update(checksum=row[0],size_bytes=row[1],updated_at=row[2].isoformat())
    write_status(reachable=True,record_exists=row is not None,last_error=None); print(json.dumps(out))

def main():
    p=argparse.ArgumentParser(); sub=p.add_subparsers(dest="cmd",required=True)
    up=sub.add_parser("upload"); up.add_argument("--source",required=True,type=Path)
    down=sub.add_parser("download"); down.add_argument("--target",required=True,type=Path)
    sub.add_parser("status"); a=p.parse_args()
    try:
        if a.cmd=="upload": upload(a.source)
        elif a.cmd=="download": sys.exit(download(a.target))
        else: status()
    except Exception as e:
        write_status(reachable=False,last_error=type(e).__name__)
        print(f"NEON PERSISTENCE FAIL: {type(e).__name__}: {e}",file=sys.stderr); sys.exit(1)
if __name__=="__main__": main()
