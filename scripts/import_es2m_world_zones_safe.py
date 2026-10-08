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
    zones = tuple(Path(z) for z in args.zones)

    queue = list(sorted(seed_files(snapshot, zones)))
    planned: set[Path] = set(queue)
    result = {
        "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS",
        "zones": [str(z) for z in zones],
        "staged": [],
        "identical": [],
        "conflicts_review": [],
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
            if sha256(src) == sha256(dst):
                result["identical"].append(str(rel))
            else:
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

    for rel in sorted(planned):
        src = snapshot / rel
        dst = runtime / rel
        if dst.is_file():
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
