#!/usr/bin/env python3
"""ES2M 雪亭 NPC 缺檔保守導入：只補缺檔，外部依賴待審不覆蓋。"""
import argparse
import json
import re
import shutil
from pathlib import Path
from audit_es2m_snow_npc_batch import NPCS, audit

def stage(snapshot, runtime):
    review = audit(snapshot, runtime)
    result = {"staged": [], "preserved_existing": [], "dependency_review": [],
              "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS"}
    for row in review["records"]:
        rel = Path(row["source"])
        source, target = snapshot / rel, runtime / rel
        if not row["source_present"]:
            raise FileNotFoundError(str(source))
        if target.exists():
            result["preserved_existing"].append(str(rel))
        elif row["missing_dependencies"] or row["staged_dependencies"]:
            result["dependency_review"].append({
                "file": str(rel),
                "missing": row["missing_dependencies"],
                "staged_dependencies": row["staged_dependencies"]})
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            result["staged"].append(str(rel))
    return result

def main():
    p = argparse.ArgumentParser()
    for name in ("snapshot", "runtime", "output"):
        p.add_argument("--" + name, required=True, type=Path)
    a = p.parse_args()
    result = stage(a.snapshot, a.runtime)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
    print("ES2M_SNOW_NPC_SAFE_STAGE", json.dumps({
        k: len(v) for k,v in result.items() if isinstance(v,list)},ensure_ascii=False))
if __name__ == "__main__":
    main()
