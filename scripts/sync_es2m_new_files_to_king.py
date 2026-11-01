#!/usr/bin/env python3
"""Sync latest ES2M source into the KING runtime overlay.

ES2M is authoritative for source paths, but the KING-only owner skill-cap
extension must remain intact until its changes are explicitly merged with
the newest ES2M progression implementation.

本工具將最新 ES2M Mudlib 同步至 KING Runtime Overlay：
同路徑覆蓋、缺少路徑新增、不刪除 KING-only 檔案。
唯一保留的同路徑核心檔案 feature/char/skill.c 含 KING Owner 300 級
專屬上限；先保留既有 KING 實作，待 ES2M 技能進度機制完成合併後再更新。
"""
from __future__ import annotations
import argparse, hashlib, json, shutil
from pathlib import Path

# KING 專屬核心檔：含唯一 admin KING 的 300 級上限，不能被 ES2M 原檔盲目取代。
PROTECTED_KING_PATHS = {
    "feature/char/skill.c",
    "daemon/skill/advance_lunmay.c",
    "daemon/skill/hainmay_force.c",
    "daemon/skill/lunmay.c",
}
FROZEN_KING_SKILLS = {
    "daemon/skill/advance_lunmay.c",
    "daemon/skill/hainmay_force.c",
    "daemon/skill/lunmay.c",
}

def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def verify_king_owner_guards(overlay: Path, repo_root: Path) -> None:
    """同步前後確認 KING Owner 與三項凍結冷梅武功仍完整。"""
    checks = {
        "feature/char/skill.c": ("es2_king_skill_cap", 'query("id") == "king"'),
        "adm/daemons/kadmind.c": ('query("id") == "king"', "is_owner"),
        "cmds/adm/kadmin.c": ("K->is_owner(me)", "KING Owner"),
        "cmds/adm/admin.c": ("ES2-KING Expansion", "管理員"),
    }
    for rel, markers in checks.items():
        path = overlay / rel
        if not path.is_file():
            raise SystemExit(f"FAIL: required KING owner guard missing: {rel}")
        raw = path.read_text(encoding="utf-8", errors="replace")
        for marker in markers:
            if marker not in raw:
                raise SystemExit(f"FAIL: KING owner guard marker missing in {rel}: {marker}")

    # 冷梅劍法、寒梅心法、傲梅暗劍訣：逐位元保留已確認 KING Frozen Baseline。
    for rel in FROZEN_KING_SKILLS:
        baseline = repo_root / "es2m_snapshot/king_frozen_baseline" / rel
        target = overlay / rel
        if not baseline.is_file() or not target.is_file():
            raise SystemExit(f"FAIL: frozen KING martial baseline missing: {rel}")
        if digest(baseline) != digest(target):
            raise SystemExit(f"FAIL: frozen KING martial baseline mismatch: {rel}")

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", required=True, type=Path, help="latest ES2M mirror mudlib")
    ap.add_argument("--original", required=True, type=Path, help="pinned Original ES2 mudlib, read-only comparison")
    ap.add_argument("--overlay", required=True, type=Path, help="KING runtime overlay destination")
    ap.add_argument("--report", required=True, type=Path)
    a = ap.parse_args()

    for p in (a.source, a.original):
        if not p.is_dir():
            raise SystemExit(f"FAIL: required directory missing: {p}")
    a.overlay.mkdir(parents=True, exist_ok=True)
    verify_king_owner_guards(a.overlay, Path(__file__).resolve().parents[1])

    source_files = sorted(p for p in a.source.rglob("*") if p.is_file())
    copied_new, overwritten, unchanged, original_conflicts, preserved_king = [], [], [], [], []

    for src in source_files:
        rel = src.relative_to(a.source)
        rel_name = rel.as_posix()
        original = a.original / rel
        dest = a.overlay / rel
        src_hash = digest(src)

        if original.exists() and src_hash != digest(original):
            original_conflicts.append({
                "path": rel_name,
                "status": "ES2M-differs-from-pinned-original",
                "source_sha256": src_hash,
                "original_sha256": digest(original),
            })

        # 唯一 KING Owner 的 300 級技能上限位於此檔；先保留 KING 版本。
        # 最新 ES2M 原始檔仍完整保存於 es2m_source_mirror，供後續逐段合併。
        if rel_name in PROTECTED_KING_PATHS:
            if not dest.is_file():
                raise SystemExit(f"FAIL: protected KING file missing: {rel_name}")
            if rel_name == "feature/char/skill.c":
                king_text = dest.read_text(encoding="utf-8", errors="replace")
                if "es2_king_skill_cap" not in king_text or 'query("id") == "king"' not in king_text:
                    raise SystemExit(f"FAIL: protected KING owner skill cap not verified: {rel_name}")
                status = "preserved-KING-owner-customization-pending-ES2M-merge"
            elif rel_name in FROZEN_KING_SKILLS:
                baseline = Path(__file__).resolve().parents[1] / "es2m_snapshot/king_frozen_baseline" / rel
                if not baseline.is_file() or digest(dest) != digest(baseline):
                    raise SystemExit(f"FAIL: frozen KING martial baseline mismatch: {rel_name}")
                status = "preserved-KING-frozen-martial-baseline"
            else:
                raise SystemExit(f"FAIL: unclassified protected KING path: {rel_name}")
            preserved_king.append({
                "path": rel_name,
                "status": status,
                "king_sha256": digest(dest),
                "es2m_sha256": src_hash,
            })
            continue

        if dest.exists():
            dest_hash = digest(dest)
            if dest_hash == src_hash:
                unchanged.append({
                    "path": rel_name,
                    "status": "already-matches-ES2M",
                    "sha256": src_hash,
                })
                continue
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            overwritten.append({
                "path": rel_name,
                "status": "overwritten-existing-KING-file",
                "previous_king_sha256": dest_hash,
                "source_sha256": src_hash,
            })
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            copied_new.append({
                "path": rel_name,
                "status": "copied-new-path",
                "sha256": src_hash,
            })

    # 寫入後再次驗證，確保 KING Owner 權限檔案仍存在。
    verify_king_owner_guards(a.overlay, Path(__file__).resolve().parents[1])

    report = {
        "policy": "ES2M-source-authoritative-for-matching-paths; overwrite same-path overlay files except protected KING owner skill-cap file; never delete KING-only files; pinned Original ES2 is read-only",
        "source_root": str(a.source),
        "original_reference_root": str(a.original),
        "overlay_root": str(a.overlay),
        "source_file_count": len(source_files),
        "copied_new_count": len(copied_new),
        "overwritten_existing_king_count": len(overwritten),
        "already_matching_count": len(unchanged),
        "preserved_king_custom_count": len(preserved_king),
        "source_differs_from_pinned_original_count": len(original_conflicts),
        "copied_new": copied_new,
        "overwritten_existing_king": overwritten,
        "already_matching": unchanged,
        "preserved_king_custom": preserved_king,
        "source_differs_from_pinned_original": original_conflicts,
    }
    a.report.parent.mkdir(parents=True, exist_ok=True)
    a.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in report.items() if not isinstance(v, list)}, ensure_ascii=False, indent=2))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
