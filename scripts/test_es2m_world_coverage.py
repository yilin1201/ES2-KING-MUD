#!/usr/bin/env python3
"""V13 ES2M 世界區域覆蓋率閘門。

目的：
1. 盤點 ES2M snapshot/mudlib/d 下所有第一層世界區域。
2. 確認每個區域都有明確的 Runtime 導入策略。
3. 防止未來 snapshot 新增地圖後，Docker 建置仍成功但資料被靜默漏掉。

本檔只做 Evidence/coverage audit，不修改 Runtime，也不代表 Gameplay PASS。
"""
from __future__ import annotations

import argparse
from pathlib import Path

# 每個已確認區域都必須有明確處理器；Snow 使用專用安全導入流程。
HANDLERS = {
    "lee": "scripts/import_es2m_world_zones_safe.py",
    "oldpine": "scripts/import_es2m_world_zones_safe.py",
    "wutang": "scripts/import_es2m_world_zones_safe.py",
    "snow": "scripts/import_es2m_snow_rooms_safe.py",
}

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot", type=Path, required=True)
    args = parser.parse_args()

    root = args.snapshot.resolve() / "d"
    if not root.is_dir():
        raise SystemExit("ES2M_WORLD_COVERAGE_FAIL: snapshot d/ missing")

    zones = sorted(p.name for p in root.iterdir() if p.is_dir())
    missing = sorted(set(zones) - set(HANDLERS))
    stale = sorted(set(HANDLERS) - set(zones))

    print("ES2M_WORLD_COVERAGE")
    print(f"zones={','.join(zones)}")
    print(f"handled={','.join(sorted(set(zones) & set(HANDLERS)))}")

    if missing:
        raise SystemExit(
            "ES2M_WORLD_COVERAGE_FAIL: unclassified zones: " + ", ".join(missing)
        )
    if stale:
        raise SystemExit(
            "ES2M_WORLD_COVERAGE_FAIL: handler has no source zone: " + ", ".join(stale)
        )

    for zone in zones:
        files = list((root / zone).rglob("*.c"))
        if not files:
            raise SystemExit(
                f"ES2M_WORLD_COVERAGE_FAIL: zone has no LPC source: {zone}"
            )
        print(f"{zone}: files={len(files)} handler={HANDLERS[zone]}")

    print("ES2M_WORLD_COVERAGE_STATIC_PASS")

if __name__ == "__main__":
    main()
