#!/usr/bin/env python3
"""V13 ES2M 對話 overlay 安全套用器。

規則：
1. 只加入 Runtime 尚不存在的檔案。
2. 同路徑存在不同內容時只記錄 CONFLICT_REVIEW，絕不覆蓋 Original。
3. 不把來源快照直接視為 Gameplay PASS。
"""

from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path

def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--overlay", required=True)
    p.add_argument("--runtime", required=True)
    p.add_argument("--output", required=True)
    a = p.parse_args()

    overlay = Path(a.overlay)
    runtime = Path(a.runtime)
    report = {"status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS", "staged": [], "conflicts": [], "missing": []}

    if not overlay.is_dir():
        raise SystemExit(f"ES2_DIALOGUE_OVERLAY_FAIL: missing overlay {overlay}")

    for src in sorted(x for x in overlay.rglob("*") if x.is_file()):
        rel = src.relative_to(overlay)
        dst = runtime / rel
        if not dst.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes(src.read_bytes())
            report["staged"].append({"path": str(rel), "sha256": sha256(dst)})
        elif sha256(src) != sha256(dst):
            report["conflicts"].append({
                "path": str(rel),
                "overlay_sha256": sha256(src),
                "runtime_sha256": sha256(dst),
                "action": "CONFLICT_REVIEW_NO_OVERWRITE",
            })
        else:
            report["staged"].append({"path": str(rel), "sha256": sha256(dst), "action": "ALREADY_IDENTICAL"})

    Path(a.output).write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
