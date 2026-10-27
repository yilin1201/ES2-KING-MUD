#!/usr/bin/env python3
"""Copy only ES2M files that are new relative to pinned Original ES2 and KING overlay.

Never overwrite an Original ES2 path or an existing KING overlay path.
"""
from __future__ import annotations
import argparse, hashlib, json, shutil
from pathlib import Path

def digest(path: Path) -> str:
    h=hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda:f.read(1024*1024), b""):
            h.update(block)
    return h.hexdigest()

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument("--source", required=True, type=Path, help="latest ES2M mirror mudlib")
    ap.add_argument("--original", required=True, type=Path, help="pinned Original ES2 mudlib")
    ap.add_argument("--overlay", required=True, type=Path, help="KING runtime overlay destination")
    ap.add_argument("--report", required=True, type=Path)
    a=ap.parse_args()
    for p in (a.source,a.original):
        if not p.is_dir(): raise SystemExit(f"FAIL: required directory missing: {p}")
    a.overlay.mkdir(parents=True,exist_ok=True)
    source_files=sorted(p for p in a.source.rglob("*") if p.is_file())
    copied=[]; already=[]; original_conflicts=[]; king_conflicts=[]
    for src in source_files:
        rel=src.relative_to(a.source)
        original=a.original/rel
        dest=a.overlay/rel
        if original.exists():
            if digest(src)==digest(original): already.append({"path":rel.as_posix(),"status":"already-in-original","sha256":digest(src)})
            else: original_conflicts.append({"path":rel.as_posix(),"status":"same-path-original-differs","source_sha256":digest(src),"original_sha256":digest(original)})
            continue
        if dest.exists():
            king_conflicts.append({"path":rel.as_posix(),"status":"preserved-existing-king-overlay","source_sha256":digest(src),"king_sha256":digest(dest)})
            continue
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(src,dest)
        copied.append({"path":rel.as_posix(),"status":"copied-new-path","sha256":digest(dest)})
    report={
      "policy":"copy-only-new-paths; never overwrite pinned Original ES2 or existing KING overlay",
      "source_root":str(a.source),"original_root":str(a.original),"overlay_root":str(a.overlay),
      "source_file_count":len(source_files),"copied_count":len(copied),
      "already_in_original_count":len(already),"original_same_path_conflict_count":len(original_conflicts),
      "existing_king_overlay_preserved_count":len(king_conflicts),
      "copied":copied,"already_in_original":already,
      "original_same_path_conflicts":original_conflicts,
      "existing_king_overlay_preserved":king_conflicts,
    }
    a.report.parent.mkdir(parents=True,exist_ok=True)
    a.report.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({k:v for k,v in report.items() if not isinstance(v,list)},ensure_ascii=False,indent=2))
    if len(copied)==0: print("No new files to copy.")
    return 0
if __name__=="__main__": raise SystemExit(main())
