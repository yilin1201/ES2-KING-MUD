#!/usr/bin/env python3
"""ES2M 振武軍營：保守補入已考證來源；同名衝突不覆蓋。"""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def stage(snapshot, runtime):
    source = snapshot / "custom/zhenwu"
    if not source.is_dir() or not runtime.is_dir():
        raise FileNotFoundError("ZHENWU_STAGE_ROOT_MISSING")
    report = {"staged": [], "identical": [], "conflicts_review": [],
              "external_gate": "PENDING", "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS"}
    for file in sorted(source.rglob("*.c")):
        rel = file.relative_to(snapshot)
        target = runtime / rel
        if target.exists():
            report["identical" if sha(file) == sha(target) else "conflicts_review"].append(str(rel))
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file, target)
            report["staged"].append(str(rel))
    # 雪亭南門若已有 west，僅在相同目的地時承認連接；
    # 未知 Original 出口不得自動覆蓋或改寫。
    gate = runtime / "d/snow/sgate.c"
    if gate.is_file():
        text = gate.read_text()
        if '"/custom/zhenwu/room/gate"' in text:
            report["external_gate"] = "LINK_PRESENT"
        else:
            report["external_gate"] = "REVIEW_REQUIRED"
    return report

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--snapshot", type=Path, required=True)
    p.add_argument("--runtime", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    result = stage(a.snapshot, a.runtime)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
    print("ES2M_ZHENWU_STAGE", json.dumps({k: len(v) if isinstance(v,list) else v for k,v in result.items()},ensure_ascii=False))
    if result["conflicts_review"] or result["external_gate"] != "LINK_PRESENT":
        raise SystemExit("ZHENWU_REVIEW_REQUIRED: source preserved; no gameplay claim")

if __name__ == "__main__":
    main()
