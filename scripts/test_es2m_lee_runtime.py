#!/usr/bin/env python3
"""Runtime topology gate for the ES2M Lee village snapshot.

出口解析需兼容 LPC 中的不同空白格式、引号與 __DIR__/絕對路徑；
Runtime gate 同時回報來源與生成檔案 SHA，避免把 parser 未命中誤判為出口不存在。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


def sha256(path: Path) -> str:
    """回報檔案 SHA256，協助確認 snapshot 是否真正進入生成 Runtime。"""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def exits(path: Path) -> dict[str, str]:
    """讀取靜態 exits mapping，並把 /d/lee/room.c 正規化為 room。"""
    code = path.read_text(encoding="utf-8")
    # LPC／支援 set("exits", ([...])) 的空白差異，不綁定單一格式。
    match = re.search(
        r'set\s*\(\s*["\']exits["\']\s*,\s*\(\s*\[(.*?)\]\s*\)\s*\)\s*;',
        code,
        re.S,
    )
    if not match:
        return {}
    found = re.findall(
        r'["\']([a-z]+)["\']\s*:\s*(?:__DIR__\s*)?["\']([^"\']+)["\']',
        match.group(1),
    )
    result: dict[str, str] = {}
    for direction, raw_target in found:
        target = raw_target.rstrip("/")
        if target.startswith("/"):
            target = target.rsplit("/", 1)[-1]
        if target.endswith(".c"):
            target = target[:-2]
        result[direction] = target
    return result


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
    source_runtime_mismatch = []
    for name, record in rooms.items():
        source_path = snapshot_area / f"{name}.c"
        path = runtime_area / f"{name}.c"
        if not path.is_file():
            missing.append(name)
            continue
        actual = exits(path)
        if source_path.is_file() and sha256(source_path) != sha256(path):
            source_runtime_mismatch.append(
                f"{name}: snapshot_sha256={sha256(source_path)} runtime_sha256={sha256(path)}"
            )
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
            re.findall(r'__DIR__\s*["\']npc/([a-zA-Z0-9_]+)["\']', code)
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

    if missing or broken or missing_npcs or source_runtime_mismatch:
        print("ES2M_LEE_RUNTIME_FAIL")
        # Forensic diagnostics／根因診斷：失敗時列出六個已確認出口房間的實際路徑、
        # 檔案 SHA256、解析器結果與檔案開頭，區分檔案不存在、舊版檔案、parser 未命中。
        # 只讀取與回報，不修改 Runtime。
        diagnostic_rooms = {
            "square_s", "square_c", "watermelon_n1",
            "pawnshop", "watermelon_s3", "creek",
        }
        for room_name in sorted(diagnostic_rooms):
            source_path = snapshot_area / f"{room_name}.c"
            runtime_path = runtime_area / f"{room_name}.c"
            if not runtime_path.is_file():
                print(f"ROOM_DIAGNOSTIC: {room_name} runtime=MISSING path={runtime_path}")
                continue
            runtime_text = runtime_path.read_text(encoding="utf-8", errors="replace")
            source_hash = sha256(source_path) if source_path.is_file() else "SNAPSHOT_MISSING"
            print(
                "ROOM_DIAGNOSTIC:",
                json.dumps({
                    "room": room_name,
                    "runtime_path": str(runtime_path),
                    "runtime_sha256": sha256(runtime_path),
                    "snapshot_sha256": source_hash,
                    "same_bytes": source_hash == sha256(runtime_path),
                    "parsed_exits": exits(runtime_path),
                    "runtime_bytes": runtime_path.stat().st_size,
                    "runtime_head": runtime_text[:320],
                }, ensure_ascii=False, sort_keys=True),
            )
        for item in missing:
            print("MISSING_ROOM:", item)
        for item in broken:
            print("BROKEN_EXIT:", item)
        for item in source_runtime_mismatch:
            print("SNAPSHOT_RUNTIME_FILE_MISMATCH:", item)
        for item in missing_npcs:
            print("MISSING_NPC:", item)
        raise SystemExit(1)

    print(
        "ES2M LEE RUNTIME TOPOLOGY PASS／"
        f"rooms={len(rooms)} runtime_npcs={len(list(npc_dir.glob('*.c')))}"
    )


if __name__ == "__main__":
    main()
