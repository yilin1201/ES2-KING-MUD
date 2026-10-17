#!/usr/bin/env python3
"""Classify ES2M import conflicts without overwriting KING content.

將補檔衝突與三方合併結果交叉比對，分清已由三方合併處理的重複項、
相對 Original 未改動但 KING 有自訂差異的檔案，以及真正仍待適配的來源差異。
"""
from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path

SOURCE_COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"


def paths_from(data: dict, key: str) -> set[str]:
    result = set()
    for item in data.get(key, []):
        path = item if isinstance(item, str) else item.get("path", "")
        if path:
            result.add(path)
    return result


def classify(manifest: dict, additive: dict, merge: dict) -> dict:
    for label, data in (("manifest", manifest), ("additive", additive), ("merge", merge)):
        if data.get("source_commit") != SOURCE_COMMIT:
            raise SystemExit(f"ES2M_CONFLICT_CLASSIFY_FAIL: {label} source pin mismatch")

    by_path = {item["path"]: item for item in manifest.get("files", [])}
    replaced = paths_from(merge, "source_replaced")
    already_source = paths_from(merge, "already_source")
    merged = paths_from(merge, "merged")
    merge_conflicts = paths_from(merge, "preserved_conflicts")
    added = paths_from(merge, "added_missing_runtime")
    resolved_by_merge = replaced | already_source | merged | merge_conflicts | added

    entries = []
    for item in additive.get("preserved_conflicts", []):
        path = item.get("path", "")
        source_sha = item.get("source_git_blob_sha", "")
        original_sha = by_path.get(path, {}).get("original_sha", "")
        original_status = by_path.get(path, {}).get("original_status", "")
        if not path or path not in by_path:
            category = "HOLD_MANIFEST_PATH_MISSING"
            reason = "Conflict path is absent from the pinned source manifest."
        elif path in resolved_by_merge:
            if path in merge_conflicts:
                category = "HOLD_THREE_WAY_CONFLICT"
                reason = "Three-way merge reported a conflict; KING content was preserved."
            else:
                category = "COVERED_BY_THREE_WAY_RESULT"
                reason = "The additive conflict is already accounted for by the three-way merge report."
        elif source_sha and original_sha and source_sha == original_sha:
            category = "KING_DIVERGENCE_SOURCE_UNCHANGED"
            reason = "Pinned ES2M bytes equal pinned Original bytes; the runtime difference is KING-side and must not be overwritten as an ES2M update."
        elif original_status == "CHANGED_FROM_PINNED_ORIGINAL":
            category = "HOLD_CHANGED_SOURCE_NOT_ACCOUNTED"
            reason = "ES2M differs from Original but is not represented in the three-way result; review the manifest eligibility/exclusion."
        else:
            category = "HOLD_BASELINE_UNVERIFIED"
            reason = "The Original baseline cannot safely explain this runtime divergence."
        entries.append({
            "path": path,
            "category": category,
            "reason": reason,
            "source_git_blob_sha": source_sha or None,
            "original_git_blob_sha": original_sha or None,
            "runtime_git_blob_sha": item.get("runtime_git_blob_sha"),
            "original_status": original_status or None,
        })

    counts = Counter(entry["category"] for entry in entries)
    return {
        "source_commit": SOURCE_COMMIT,
        "status": "CONFLICTS_CLASSIFIED_NOT_FULL_MIGRATION_OR_GAMEPLAY_PASS",
        "additive_conflict_count": len(entries),
        "three_way_conflict_count": len(merge_conflicts),
        "summary": dict(sorted(counts.items())),
        "entries": entries,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--additive-report", type=Path, required=True)
    parser.add_argument("--merge-report", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    data = classify(
        json.loads(args.manifest.read_text(encoding="utf-8")),
        json.loads(args.additive_report.read_text(encoding="utf-8")),
        json.loads(args.merge_report.read_text(encoding="utf-8")),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("ES2M_LATEST_CONFLICT_CLASSIFICATION", json.dumps({
        "status": data["status"],
        "additive_conflict_count": data["additive_conflict_count"],
        "three_way_conflict_count": data["three_way_conflict_count"],
        "summary": data["summary"],
        "output": str(args.output),
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
