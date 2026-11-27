#!/usr/bin/env python3
"""ES2M 雪亭地圖缺檔補入：保留 Original，未解決的本區出口不導入。"""
import argparse
import hashlib
import json
import re
import shutil
from pathlib import Path

def stage(snapshot, runtime):
    area = Path("d/snow")
    if not (snapshot / area).is_dir() or not (runtime / area).is_dir():
        raise FileNotFoundError("ES2M_SNOW_MAP_ROOT_MISSING")
    result = {"staged": [], "identical": [], "conflicts_review": [],
              "unresolved_exits": [], "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS"}
    for src in sorted((snapshot / area).glob("*.c")):
        rel = area / src.name
        dst = runtime / rel
        if dst.is_file():
            sh = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
            result["identical" if sh(src) == sh(dst) else "conflicts_review"].append(str(rel))
            continue
        code = src.read_text()
        # __DIR__ 本區房間必須能在來源或 Runtime 找到；不臆造出口。
        targets = re.findall(r'__DIR__\s*"([a-zA-Z0-9_]+)"', code)
        missing = sorted({name for name in targets if not
                          (snapshot / area / (name+".c")).is_file() and not
                          (runtime / area / (name+".c")).is_file()})
        if missing:
            result["unresolved_exits"].append({"file": str(rel), "targets": missing})
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        result["staged"].append(str(rel))
    return result

def main():
    p = argparse.ArgumentParser()
    for name in ("snapshot", "runtime", "output"):
        p.add_argument("--"+name, required=True, type=Path)
    a = p.parse_args()
    report = stage(a.snapshot, a.runtime)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(report, ensure_ascii=False, indent=2)+"\n")
    print("ES2M_SNOW_ROOM_STAGE",json.dumps({
        k:len(v) for k,v in report.items() if isinstance(v,list)},ensure_ascii=False))
    if report["unresolved_exits"]:
        raise SystemExit("ES2M_SNOW_ROOM_UNRESOLVED_EXITS")
if __name__=="__main__":
    main()
