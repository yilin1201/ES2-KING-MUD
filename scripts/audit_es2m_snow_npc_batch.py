#!/usr/bin/env python3
"""ES2M Snow NPC batch gate: source inventory and conservative dependency audit.

Read-only: never copies NPCs into the pinned Original runtime or marks gameplay PASS.
"""
import argparse
import json
import re
from pathlib import Path

NPCS = ("alchemist", "child", "foreman", "gammer", "garrison",
        "girl", "guard", "herbalist", "innkeeper", "junkman")
ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = ROOT / "es2m_snapshot/mudlib"


def audit(snapshot: Path, runtime: Path):
    records = []
    for name in NPCS:
        rel = Path("d/snow/npc") / (name + ".c")
        src, dst = snapshot / rel, runtime / rel
        row = {"npc": name, "source": str(rel), "source_present": src.is_file(),
               "runtime_present": dst.is_file(), "missing_dependencies": [],
               "decision": "BLOCKED"}
        if src.is_file():
            code = src.read_text(encoding="utf-8")
            # Only literal dependencies can be proved by this audit.
            local = re.findall(r'__DIR__\\s*"([^"]+)"', code)
            absolute = re.findall(r'(?<![\\w/])"(/(?:obj|d|custom)/[\\w/]+)"', code)
            deps = set()
            for item in local:
                if not item.startswith("../"):
                    deps.add(rel.parent / (item + ".c"))
            for item in absolute:
                deps.add(Path(item.lstrip("/") + ".c"))
            row["missing_dependencies"] = sorted(
                str(p) for p in deps if not (runtime / p).is_file()
                and not (snapshot / p).is_file()
            )
            row["literal_dependencies"] = sorted(str(p) for p in deps)
            row["decision"] = ("REVIEW_EXISTING" if dst.is_file() else
                               "DEPENDENCY_REVIEW" if row["missing_dependencies"] else
                               "SOURCE_PRESENT_RUNTIME_ABSENT")
        records.append(row)
    return {"status": "STATIC_INVENTORY_ONLY_NOT_RUNTIME_PASS",
            "npc_count": len(NPCS), "records": records}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, default=SNAPSHOT)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if not args.runtime.is_dir():
        parser.error("runtime mudlib directory must exist")
    result = audit(args.snapshot, args.runtime)
    data = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(data, encoding="utf-8")
    print(data)
    if any(not row["source_present"] for row in result["records"]):
        raise SystemExit("ES2M_SNOW_NPC_SOURCE_INCOMPLETE")


if __name__ == "__main__":
    main()
