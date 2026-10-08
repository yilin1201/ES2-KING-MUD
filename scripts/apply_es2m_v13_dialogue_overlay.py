#!/usr/bin/env python3
"""Safely apply the V13 ES2M NPC dialogue runtime overlay."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--overlay", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    overlay = args.overlay.resolve()
    runtime = args.runtime.resolve()
    if not overlay.is_dir():
        raise FileNotFoundError(f"dialogue overlay missing: {overlay}")

    result = {
        "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS",
        "staged": [],
        "identical": [],
        "conflicts_review": [],
    }

    for src in sorted(overlay.rglob("*")):
        if not src.is_file():
            continue
        rel = src.relative_to(overlay)
        dst = runtime / rel
        if dst.is_file():
            if digest(src) == digest(dst):
                result["identical"].append(str(rel))
            else:
                result["conflicts_review"].append(str(rel))
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        result["staged"].append(str(rel))

    if result["conflicts_review"]:
        raise SystemExit(
            "ES2M_DIALOGUE_OVERLAY_CONFLICT: "
            + ", ".join(result["conflicts_review"])
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        "ES2M_DIALOGUE_OVERLAY",
        json.dumps(
            {
                "staged": len(result["staged"]),
                "identical": len(result["identical"]),
            },
            ensure_ascii=False,
        ),
    )


if __name__ == "__main__":
    main()
