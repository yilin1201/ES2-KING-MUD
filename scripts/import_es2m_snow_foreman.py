#!/usr/bin/env python3
"""ES2M 雪亭工頭與木箱：只補 Runtime 缺檔，不覆蓋 Original；依賴缺失即停止。"""
import argparse
import hashlib
import shutil
from pathlib import Path

PAIRS = (
    ("d/snow/npc/obj/crate.c", "ES2M crate／木箱"),
    ("d/snow/npc/foreman.c", "ES2M foreman／工頭"),
)

def import_foreman(snapshot: Path, runtime: Path):
    # 先完成整組來源檢查，避免複製到一半才發現缺檔。
    for rel, _ in PAIRS:
        if not (snapshot / rel).is_file():
            raise FileNotFoundError(f"ES2M_FOREMAN_SOURCE_MISSING: {rel}")
    # 保守策略：如果 Runtime 已有同名物件或 NPC，絕不覆蓋。
    result = []
    for rel, label in PAIRS:
        target = runtime / rel
        if target.exists():
            source_hash = hashlib.sha256((snapshot / rel).read_bytes()).hexdigest()
            runtime_hash = hashlib.sha256(target.read_bytes()).hexdigest()
            state = "IDENTICAL" if source_hash == runtime_hash else "DIFF_REVIEW"
            result.append(f"ES2M_FOREMAN_{state}: {rel} source_sha256={source_hash} runtime_sha256={runtime_hash}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(snapshot / rel, target)
        result.append(f"ES2M_FOREMAN_STAGED: {rel} ({label})")
    return result

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--snapshot", type=Path, required=True)
    p.add_argument("--runtime", type=Path, required=True)
    a = p.parse_args()
    if not a.runtime.is_dir():
        p.error("Runtime mudlib must exist")
    for message in import_foreman(a.snapshot, a.runtime):
        print(message)
    print("ES2M_FOREMAN_FILE_GATE_PASS: unchanged runtime preserved; DIFF_REVIEW requires source comparison; gameplay NOT verified")
