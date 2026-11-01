#!/usr/bin/env python3
"""Safely stage ES2M recovered world zones into the generated Runtime.

Evidence-first rules:
- Never overwrite a Runtime file with different bytes.
- Copy only source files present in the ES2M snapshot.
- Follow literal LPC file references and require their targets to exist in
  either the snapshot or the Runtime.
- External/unknown dynamic references are reported, not invented.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import posixpath
import shutil
from pathlib import Path

ZONE_DIRS = (
    Path("d/lee"),
    Path("d/oldpine"),
    Path("d/wutang"),
)

# 已知存在於 KING Runtime 的同名覆蓋：只保留現有版本並記錄雙方 SHA256。
# 這不是內容相同或遊戲通過的宣告；其他未列出的衝突仍必須阻止建置。
PRESERVE_EXISTING_CONFLICTS = {
    # 已依 LEE_TOPOLOGY.json 校正的六條 KING Runtime 路線；保留拓樸修正，不回退到 ES2M 舊出口。
    Path("d/lee/creek.c"),
    Path("d/lee/pawnshop.c"),
    Path("d/lee/square_c.c"),
    Path("d/lee/square_s.c"),
    Path("d/lee/watermelon_n1.c"),
    Path("d/lee/watermelon_s3.c"),
    # 高慎的拜師／授技門檻採用使用者提供的歷史教師表，不能回退到 ES2M 上游不同技能代碼。
    Path("d/oldpine/npc/kao_shen.c"),
    Path("d/lee/obj/brow_staff.c"),
    Path("d/lee/obj/flour.c"),
    Path("d/lee/obj/salt.c"),
    Path("d/lee/obj/sugar.c"),
    Path("d/lee/obj/waterskin.c"),
    Path("d/wutang/npc/may_yin_fong.c"),
}

LITERAL_LOCAL = __import__("re").compile(r'__DIR__\s*"([^"]+)"')
LITERAL_ABSOLUTE = __import__("re").compile(r'"(/(?:d|custom|obj)/[^"\s]+)"')


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def normalize_target(source_rel: Path, raw: str) -> Path | None:
    raw = raw.strip()
    if not raw or raw.endswith("/"):
        return None
    if raw.startswith("/"):
        rel = Path(raw.lstrip("/"))
    else:
        rel = source_rel.parent / raw
    if rel.suffix == "":
        rel = rel.with_suffix(".c")
    rel = Path(*posixpath.normpath(rel.as_posix()).split("/"))
    if rel.is_absolute() or any(part == ".." for part in rel.parts):
        return None
    return rel


def literal_dependencies(rel: Path, code: str) -> set[Path]:
    deps: set[Path] = set()
    for raw in LITERAL_LOCAL.findall(code):
        target = normalize_target(rel, raw)
        if target:
            deps.add(target)
    for raw in LITERAL_ABSOLUTE.findall(code):
        target = normalize_target(rel, raw)
        if target:
            deps.add(target)
    return deps


def seed_files(snapshot: Path, zones: tuple[Path, ...]) -> set[Path]:
    result: set[Path] = set()
    for zone in zones:
        root = snapshot / zone
        if not root.is_dir():
            raise FileNotFoundError(f"ES2M zone missing: {zone}")
        for path in root.rglob("*.c"):
            result.add(path.relative_to(snapshot))
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--base", type=Path, help="Pinned Original ES2 mudlib baseline for three-way reconciliation")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument(
        "--zones",
        nargs="+",
        default=[str(p) for p in ZONE_DIRS],
        help="snapshot mudlib zone directories, e.g. d/lee d/oldpine d/wutang",
    )
    args = parser.parse_args()

    snapshot = args.snapshot.resolve()
    runtime = args.runtime.resolve()
    base = args.base.resolve() if args.base else None
    zones = tuple(Path(z) for z in args.zones)

    queue = list(sorted(seed_files(snapshot, zones)))
    planned: set[Path] = set(queue)
    result = {
        "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS",
        "zones": [str(z) for z in zones],
        "staged": [],
        "identical": [],
        "conflicts_review": [],
        "preserved_existing": [],
        "replaced_original": [],
        "resolved_dependencies": [],
        "unresolved_dependencies": [],
    }

    while queue:
        rel = queue.pop(0)
        src = snapshot / rel
        dst = runtime / rel
        if not src.is_file():
            result["unresolved_dependencies"].append(
                {"source": str(rel), "target": str(rel), "reason": "snapshot_missing"}
            )
            continue

        if dst.is_file():
            source_sha = sha256(src)
            runtime_sha = sha256(dst)
            if source_sha == runtime_sha:
                result["identical"].append(str(rel))
            elif rel in PRESERVE_EXISTING_CONFLICTS:
                # 已確認的 KING 專屬覆蓋一律保留，不以 ES2M 檔案覆蓋。
                result["preserved_existing"].append({
                    "path": str(rel),
                    "snapshot_sha256": source_sha,
                    "runtime_sha256": runtime_sha,
                    "status": "PRESERVED_KING_OVERLAY_NOT_GAMEPLAY_PASS",
                })
            elif base is not None and (base / rel).is_file():
                base_sha = sha256(base / rel)
                if runtime_sha == base_sha:
                    # Runtime 尚未修改，仍等於 Pinned Original；可安全更新為 ES2M 最新來源。
                    result["replaced_original"].append({
                        "path": str(rel),
                        "base_sha256": base_sha,
                        "snapshot_sha256": source_sha,
                        "runtime_sha256": runtime_sha,
                        "status": "SAFE_REPLACE_UNMODIFIED_ORIGINAL",
                    })
                elif source_sha == base_sha:
                    # ES2M 來源等於 Original，但 Runtime 已有差異；視為 KING overlay，保留。
                    result["preserved_existing"].append({
                        "path": str(rel),
                        "snapshot_sha256": source_sha,
                        "runtime_sha256": runtime_sha,
                        "base_sha256": base_sha,
                        "status": "PRESERVED_RUNTIME_OVERLAY_NOT_GAMEPLAY_PASS",
                    })
                else:
                    # 三方皆不同：不能判定哪一方應勝出，必須人工審核。
                    result["conflicts_review"].append(str(rel))
            else:
                # 沒有 Original 基準可證明安全時，不自動覆蓋未知差異。
                result["conflicts_review"].append(str(rel))
        else:
            result["staged"].append(str(rel))

        code = src.read_text(encoding="utf-8", errors="strict")
        for dep in sorted(literal_dependencies(rel, code)):
            dep_src = snapshot / dep
            dep_dst = runtime / dep
            if dep_dst.is_file():
                result["resolved_dependencies"].append(
                    {"source": str(rel), "target": str(dep), "location": "runtime"}
                )
                continue
            if dep_src.is_file():
                if dep not in planned:
                    planned.add(dep)
                    queue.append(dep)
                result["resolved_dependencies"].append(
                    {"source": str(rel), "target": str(dep), "location": "snapshot"}
                )
            else:
                result["unresolved_dependencies"].append(
                    {"source": str(rel), "target": str(dep), "reason": "not_found"}
                )

    if result["conflicts_review"]:
        raise SystemExit(
            "ES2M_WORLD_CONFLICT_REVIEW: "
            + ", ".join(result["conflicts_review"])
        )
    if result["unresolved_dependencies"]:
        raise SystemExit(
            "ES2M_WORLD_UNRESOLVED_DEPENDENCIES: "
            + ", ".join(
                f'{row["source"]}->{row["target"]}'
                for row in result["unresolved_dependencies"]
            )
        )

    replace_original = {Path(row["path"]) for row in result["replaced_original"]}
    for rel in sorted(planned):
        src = snapshot / rel
        dst = runtime / rel
        if dst.is_file() and rel not in replace_original:
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        "ES2M_WORLD_ZONE_STAGE",
        json.dumps(
            {
                "zones": [str(z) for z in zones],
                "planned_files": len(planned),
                "staged": len(result["staged"]),
                "identical": len(result["identical"]),
                "dependencies": len(result["resolved_dependencies"]),
            },
            ensure_ascii=False,
        ),
    )


if __name__ == "__main__":
    main()
