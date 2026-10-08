#!/usr/bin/env python3
"""Runtime topology gate for the ES2M Lee village snapshot."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def exits(path: Path) -> dict[str, str]:
    code = path.read_text(encoding="utf-8")
    match = re.search(r'set\("exits", \(\[(.*?)\]\)\);', code, re.S)
    if not match:
        return {}
    return dict(
        re.findall(
            r'"([a-z]+)"\s*:\s*(?:__DIR__\s*)?"([^"]+)"',
            match.group(1),
        )
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot", type=Path, default=Path("es2m_snapshot/mudlib"))
    parser.add_argument("--runtime", type=Path, required=True)
    args = parser.parse_args()

    snapshot_area = args.snapshot / "d/lee"
    runtime_area = args.runtime / "d/lee"
    topology = json.loads(
        (snapshot_area / "LEE_TOPOLOGY.json").read_text(encoding="utf-8")
    )
    rooms = topology["rooms"]

    missing = []
    broken = []
    for name, record in rooms.items():
        path = runtime_area / f"{name}.c"
        if not path.is_file():
            missing.append(name)
            continue
        actual = exits(path)
        for direction, target in record.get("exits", {}).items():
            if actual.get(direction) != target:
                broken.append(
                    f"{name}.{direction}->{actual.get(direction)} expected {target}"
                )

    npc_dir = runtime_area / "npc"
    referenced_npcs = set()
    for path in runtime_area.glob("*.c"):
        code = path.read_text(encoding="utf-8")
        referenced_npcs.update(
            re.findall(r'__DIR__"npc/([a-zA-Z0-9_]+)"', code)
        )

    missing_npcs = sorted(
        name for name in referenced_npcs
        if not (npc_dir / f"{name}.c").is_file()
    )

    critical = {
        "wroad3": {"east": "wroad4"},
        "wroad4": {"west": "wroad3", "east": "square_w"},
        "square_w": {"west": "wroad4"},
        "shrine": {"in": "nie_backroom"},
        "nie_backroom": {"out": "shrine"},
    }
    for room, links in critical.items():
        path = runtime_area / f"{room}.c"
        actual = exits(path) if path.is_file() else {}
        for direction, target in links.items():
            if actual.get(direction) != target:
                broken.append(
                    f"critical:{room}.{direction}->{actual.get(direction)} expected {target}"
                )

    if missing or broken or missing_npcs:
        print("ES2M_LEE_RUNTIME_FAIL")
        for item in missing:
            print("MISSING_ROOM:", item)
        for item in broken:
            print("BROKEN_EXIT:", item)
        for item in missing_npcs:
            print("MISSING_NPC:", item)
        raise SystemExit(1)

    print(
        "ES2M LEE RUNTIME TOPOLOGY PASS／"
        f"rooms={len(rooms)} runtime_npcs={len(list(npc_dir.glob('*.c')))}"
    )


if __name__ == "__main__":
    main()
