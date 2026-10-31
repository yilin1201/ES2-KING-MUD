#!/usr/bin/env python3
"""Sync ES2M source files into the KING runtime overlay, overwriting same-path KING files.

The pinned Original ES2 checkout is read-only reference data; this script only writes
inside the dedicated KING runtime overlay. ES2M is authoritative for every path it has.

本工具將已測試的最新 ES2M Mudlib 同步至 KING 執行覆蓋層：同路徑直接更新、缺少路徑新增，
但不刪除 ES2M 沒有的 KING 專屬檔案，也絕不修改唯讀的 Original ES2 基準。
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
    ap.add_argument("--original", required=True, type=Path, help="pinned Original ES2 mudlib, read-only comparison")
    ap.add_argument("--overlay", required=True, type=Path, help="KING runtime overlay destination")
    ap.add_argument("--report", required=True, type=Path)
    a=ap.parse_args()
    # 來源與 Original ES2 參考目錄都必須存在；Original ES2 僅供比對，不可寫入。
    for p in (a.source,a.original):
        if not p.is_dir(): raise SystemExit(f"FAIL: required directory missing: {p}")
    a.overlay.mkdir(parents=True,exist_ok=True)
    source_files=sorted(p for p in a.source.rglob("*") if p.is_file())
    copied_new=[]; overwritten=[]; unchanged=[]; original_conflicts=[]
    # 逐檔同步：ES2M 同路徑內容為本次更新依據，舊 KING 檔可依授權覆蓋。
    for src in source_files:
        rel=src.relative_to(a.source)
        original=a.original/rel
        dest=a.overlay/rel
        src_hash=digest(src)
        # 記錄與 Original ES2 的差異，僅作證據追蹤，不回寫 Original ES2。
        if original.exists() and src_hash!=digest(original):
            original_conflicts.append({"path":rel.as_posix(),"status":"ES2M-differs-from-pinned-original","source_sha256":src_hash,"original_sha256":digest(original)})
        if dest.exists():
            # 同名舊檔以最新 ES2M 覆蓋；相同內容則略過，避免不必要寫入。
            dest_hash=digest(dest)
            if dest_hash==src_hash:
                unchanged.append({"path":rel.as_posix(),"status":"already-matches-ES2M","sha256":src_hash})
                continue
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(src,dest)
            overwritten.append({"path":rel.as_posix(),"status":"overwritten-existing-KING-file","previous_king_sha256":dest_hash,"source_sha256":src_hash})
        else:
            # KING 尚無此路徑時新增檔案。
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(src,dest)
            copied_new.append({"path":rel.as_posix(),"status":"copied-new-path","sha256":src_hash})
    # 匯出逐檔結果，讓新增、覆蓋、相同與 Original ES2 差異都可追溯。
    report={
      "policy":"ES2M-source-authoritative-for-all-matching-paths-in-KING-runtime-overlay; overwrite same-path overlay files; pinned Original ES2 checkout is never modified",
      "source_root":str(a.source),"original_reference_root":str(a.original),"overlay_root":str(a.overlay),
      "source_file_count":len(source_files),"copied_new_count":len(copied_new),
      "overwritten_existing_king_count":len(overwritten),"already_matching_count":len(unchanged),
      "source_differs_from_pinned_original_count":len(original_conflicts),
      "copied_new":copied_new,"overwritten_existing_king":overwritten,
      "already_matching":unchanged,"source_differs_from_pinned_original":original_conflicts,
    }
    a.report.parent.mkdir(parents=True,exist_ok=True)
    a.report.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({k:v for k,v in report.items() if not isinstance(v,list)},ensure_ascii=False,indent=2))
    return 0
if __name__=="__main__": raise SystemExit(main())
