#!/usr/bin/env python3
"""讓已由普通商店販售的非堆疊商品沿用既有 user autoload 保存。"""

from __future__ import annotations

import argparse
from pathlib import Path


MARKER = "// ES2-KING SHOP ITEM AUTOLOAD 20261008"
ITEMS = (
    "obj/armor/fur_hat.c",
    "d/lee/obj/waterskin.c",
)
ADAPTER = r'''

// ES2-KING SHOP ITEM AUTOLOAD 20261008
// 只保存物件路徑；不改玩家 save format，也不保存穿戴暫態。
int query_autoload() { return 1; }
void autoload(string param) { }
'''


def apply(mudlib: Path) -> dict[str, list[str]]:
    result = {"adapted": [], "existing": [], "missing": [], "conflicts": []}
    for rel in ITEMS:
        target = mudlib / rel
        if not target.is_file():
            result["missing"].append(rel)
            continue
        text = target.read_text(encoding="utf-8")
        if MARKER in text:
            result["existing"].append(rel)
            continue
        if "query_autoload(" in text or "void autoload(" in text:
            result["conflicts"].append(rel)
            continue
        target.write_text(text.rstrip() + ADAPTER + "\n", encoding="utf-8")
        (mudlib / "bin" / Path(rel).with_suffix(".b")).unlink(missing_ok=True)
        result["adapted"].append(rel)
    if result["missing"] or result["conflicts"]:
        raise RuntimeError(
            "SHOP_ITEM_AUTOLOAD_UNSAFE "
            f"missing={result['missing']} conflicts={result['conflicts']}"
        )
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="套用普通商店非堆疊商品 autoload")
    parser.add_argument("--runtime", type=Path, required=True, help="Runtime mudlib")
    args = parser.parse_args()
    result = apply(args.runtime.resolve())
    print(
        "SHOP_ITEM_AUTOLOAD_READY "
        f"adapted={len(result['adapted'])} existing={len(result['existing'])}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
