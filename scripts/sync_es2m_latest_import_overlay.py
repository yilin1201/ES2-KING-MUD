#!/usr/bin/env python3
"""Export, persist and apply conflict-free files from the pinned ES2M import.

此工具只持久化加法補檔與無衝突三方合併結果；衝突檔案永遠不會寫入 overlay。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path

SOURCE_COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def safe(root: Path, relative: str) -> Path:
    p = Path(relative)
    if not relative or p.is_absolute() or ".." in p.parts:
        raise SystemExit(f"ES2M_OVERLAY_FAIL: unsafe path {relative!r}")
    result = (root / p).resolve()
    if not result.is_relative_to(root.resolve()):
        raise SystemExit(f"ES2M_OVERLAY_FAIL: path escaped root: {relative}")
    return result


def read_report(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("source_commit") != SOURCE_COMMIT:
        raise SystemExit(f"ES2M_OVERLAY_FAIL: unexpected source commit in {path}")
    return data


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="mode", required=True)
    ex = sub.add_parser("export")
    ex.add_argument("--runtime", type=Path, required=True)
    ex.add_argument("--additive-report", type=Path, required=True)
    ex.add_argument("--merge-report", type=Path, required=True)
    ex.add_argument("--output", type=Path, required=True)
    pe = sub.add_parser("persist")
    pe.add_argument("--export-root", type=Path, required=True)
    pe.add_argument("--overlay-root", type=Path, required=True)
    ap = sub.add_parser("apply")
    ap.add_argument("--overlay-root", type=Path, required=True)
    ap.add_argument("--runtime", type=Path, required=True)
    args = parser.parse_args()

    if args.mode == "export":
        additive = read_report(args.additive_report)
        merge = read_report(args.merge_report)
        if not str(additive.get("status", "")).startswith("ADDITIVE_IMPORT_ONLY"):
            raise SystemExit("ES2M_OVERLAY_FAIL: additive import report status mismatch")
        if not str(merge.get("status", "")).startswith("THREE_WAY_MERGE_WITH_CONFLICTS_HELD"):
            raise SystemExit("ES2M_OVERLAY_FAIL: three-way report status mismatch")
        paths: dict[str, str] = {}
        for item in additive.get("copied", []):
            if not isinstance(item, str):
                raise SystemExit("ES2M_OVERLAY_FAIL: malformed additive copied entry")
            paths[item] = "additive_copy"
        for key in ("source_replaced", "merged", "added_missing_runtime"):
            for item in merge.get(key, []):
                relative = item if isinstance(item, str) else item.get("path", "")
                if not relative:
                    raise SystemExit(f"ES2M_OVERLAY_FAIL: malformed {key} entry")
                paths[relative] = key
        out = args.output.resolve()
        if out.exists():
            shutil.rmtree(out)
        mudlib = out / "mudlib"
        mudlib.mkdir(parents=True)
        files = []
        runtime = args.runtime.resolve()
        for relative, origin in sorted(paths.items()):
            source = safe(runtime, relative)
            if not source.is_file() or source.is_symlink():
                raise SystemExit(f"ES2M_OVERLAY_FAIL: imported runtime file missing/unsafe: {relative}")
            target = safe(mudlib, relative)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            files.append({"path": relative, "origin": origin, "sha256": digest(target)})
        manifest = {
            "source_commit": SOURCE_COMMIT,
            "status": "CONFLICT_FREE_IMPORTS_ONLY",
            "file_count": len(files),
            "files": files,
            "excluded_conflict_count": len(merge.get("preserved_conflicts", []))
                + len(additive.get("preserved_conflicts", [])),
        }
        (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print("ES2M_OVERLAY_EXPORTED", json.dumps({"files": len(files), "excluded_conflicts": manifest["excluded_conflict_count"]}, ensure_ascii=False))
        return

    root = args.overlay_root.resolve()
    manifest_path = root.parent / "manifest.json"
    if args.mode == "persist":
        export_root = args.export_root.resolve()
        manifest_path = export_root / "manifest.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        if manifest.get("source_commit") != SOURCE_COMMIT or manifest.get("status") != "CONFLICT_FREE_IMPORTS_ONLY":
            raise SystemExit("ES2M_OVERLAY_FAIL: export manifest pin/status mismatch")
        root.mkdir(parents=True, exist_ok=True)
        for item in manifest.get("files", []):
            relative = item["path"]
            src = safe(export_root / "mudlib", relative)
            dst = safe(root, relative)
            if not src.is_file() or digest(src) != item.get("sha256"):
                raise SystemExit(f"ES2M_OVERLAY_FAIL: export SHA mismatch: {relative}")
            if dst.exists():
                if not dst.is_file() or digest(dst) != item["sha256"]:
                    raise SystemExit(f"ES2M_OVERLAY_HOLD: persisted KING overlay differs; manual review required: {relative}")
            else:
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
        # 允許安全擴充既有 overlay：舊檔必須仍與既有 manifest hash 相符；
        # 新增路徑可追加，但同一路徑內容不同時立即 HOLD，絕不覆寫 KING。
        persisted_manifest = root.parent / "manifest.json"
        combined = {item["path"]: item for item in manifest.get("files", [])}
        if persisted_manifest.exists():
            old = json.loads(persisted_manifest.read_text(encoding="utf-8"))
            if old.get("source_commit") != SOURCE_COMMIT or old.get("status") != "CONFLICT_FREE_IMPORTS_ONLY":
                raise SystemExit("ES2M_OVERLAY_HOLD: existing overlay manifest pin/status mismatch")
            for item in old.get("files", []):
                relative = item["path"]
                dst = safe(root, relative)
                if not dst.is_file() or digest(dst) != item.get("sha256"):
                    raise SystemExit(f"ES2M_OVERLAY_HOLD: existing persisted file hash mismatch: {relative}")
                fresh = combined.get(relative)
                if fresh and fresh.get("sha256") != item.get("sha256"):
                    raise SystemExit(f"ES2M_OVERLAY_HOLD: existing path changed in new export: {relative}")
                combined.setdefault(relative, item)
        manifest["files"] = [combined[key] for key in sorted(combined)]
        manifest["file_count"] = len(manifest["files"])
        persisted_manifest.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print("ES2M_OVERLAY_PERSISTED", manifest.get("file_count", 0))
        return

    # Apply is intentionally strict: the persisted file set and hashes must match this build's fresh export.
    fresh_manifest = args.overlay_root.parent / "manifest.json"
    if not fresh_manifest.is_file():
        print("ES2M_OVERLAY_APPLY_SKIP: no persisted overlay for first import pass")
        return
    manifest = json.loads(fresh_manifest.read_text(encoding="utf-8"))
    if manifest.get("source_commit") != SOURCE_COMMIT or manifest.get("status") != "CONFLICT_FREE_IMPORTS_ONLY":
        raise SystemExit("ES2M_OVERLAY_FAIL: persisted overlay pin/status mismatch")
    runtime = args.runtime.resolve()
    for item in manifest.get("files", []):
        relative = item["path"]
        src = safe(root, relative)
        dst = safe(runtime, relative)
        if not src.is_file() or digest(src) != item.get("sha256"):
            raise SystemExit(f"ES2M_OVERLAY_FAIL: persisted overlay SHA mismatch: {relative}")
        if not dst.is_file() or digest(dst) != item["sha256"]:
            raise SystemExit(f"ES2M_OVERLAY_HOLD: fresh build result differs; refusing stale overlay overwrite: {relative}")
        # 內容相同時不需要覆寫，避免破壞檔案時間戳或權限。
    print("ES2M_OVERLAY_APPLY_PASS", manifest.get("file_count", 0))


if __name__ == "__main__":
    main()
