#!/usr/bin/env python3
"""將固定版本的 ES2M 原始 Mudlib 複製到獨立鏡像目錄，保留 KING 工作快照。"""

from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

# 此鏡像只保存上游原始碼，不覆寫 KING Runtime 或工作快照。
SOURCE_ROOT = Path("source/upstream/mudlib")
MIRROR_ROOT = Path("es2m_source_mirror/mudlib")
SOURCE_REPO = "wolfer168/es2-webmud"
SOURCE_COMMIT = "d013a64cc9e5e5a9e148732bc58f6f7264219fcc"


def sha256_file(path: Path) -> str:
    """計算檔案 SHA-256，供後續逐檔比對與追溯。"""
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    # workflow 必須先 checkout 與 SOURCE_COMMIT 相同的固定來源版本。
    if not SOURCE_ROOT.is_dir():
        raise SystemExit(f"找不到 ES2M 來源目錄：{SOURCE_ROOT}")

    if MIRROR_ROOT.exists():
        shutil.rmtree(MIRROR_ROOT)

    shutil.copytree(SOURCE_ROOT, MIRROR_ROOT)

    files = sorted(path for path in MIRROR_ROOT.rglob("*") if path.is_file())
    entries = []
    for path in files:
        entries.append({
            "path": path.relative_to(MIRROR_ROOT).as_posix(),
            "size": path.stat().st_size,
            "sha256": sha256_file(path),
        })

    manifest = {
        "purpose": "ES2M 原始 Mudlib 完整唯讀鏡像；不得直接當成 KING runtime overlay。",
        "source_repository": SOURCE_REPO,
        "source_commit": SOURCE_COMMIT,
        "source_path": "source/upstream/mudlib/",
        "mirror_path": "es2m_source_mirror/mudlib/",
        "file_count": len(entries),
        "hash_algorithm": "SHA-256",
        "files": entries,
        "policy": [
            "原始來源鏡像與 es2m_snapshot 工作快照分開保存。",
            "先逐檔比較、分類與驗證，再選擇性採用到 KING runtime。",
            "不得以全目錄覆蓋方式取代 KING 專屬修改。",
        ],
    }
    manifest_path = MIRROR_ROOT.parent / "MANIFEST.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"ES2M mirror files: {len(entries)}")
    print(f"Source commit: {SOURCE_COMMIT}")
    print(f"Manifest: {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
