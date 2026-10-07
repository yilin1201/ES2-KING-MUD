#!/usr/bin/env python3
"""為已知商店 COMBINED_ITEM 加入數量 autoload；不改全域基底或玩家 save format。"""

from __future__ import annotations

import argparse
from pathlib import Path


MARKER = "// ES2-KING SHOP COMBINED ITEM AUTOLOAD 20261008"
ITEMS = (
    "obj/food/dumpling.c",
    "obj/food/manto.c",
    "obj/food/pork.c",
    "d/snow/npc/obj/roast_chicken.c",
    "d/lee/obj/salt.c",
    "d/lee/obj/sugar.c",
    "d/lee/obj/flour.c",
)
ADAPTER = r'''

// ES2-KING SHOP COMBINED ITEM AUTOLOAD 20261008
// 僅保存已知商店商品的正整數數量；不修改 COMBINED_ITEM 全域基底，避免影響 money 子類。
string query_autoload()
{
    return (query_amount() > 0 ? query_amount() : 1) + "";
}

void autoload(string param)
{
    int saved_amount;

    if( stringp(param)
    &&  sscanf(param, "%d", saved_amount) == 1
    &&  saved_amount > 0 )
        set_amount(saved_amount);
}
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
        if "inherit COMBINED_ITEM;" not in text:
            result["conflicts"].append(rel)
            continue
        if "query_autoload(" in text or "void autoload(" in text:
            result["conflicts"].append(rel)
            continue
        target.write_text(text.rstrip() + ADAPTER + "\n", encoding="utf-8")
        (mudlib / "bin" / Path(rel).with_suffix(".b")).unlink(missing_ok=True)
        result["adapted"].append(rel)
    if result["missing"] or result["conflicts"]:
        raise RuntimeError(
            "SHOP_COMBINED_AUTOLOAD_UNSAFE "
            f"missing={result['missing']} conflicts={result['conflicts']}"
        )
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="套用已知商店堆疊商品 autoload")
    parser.add_argument("--runtime", type=Path, required=True, help="Runtime mudlib")
    args = parser.parse_args()
    result = apply(args.runtime.resolve())
    print(
        "COMBINED_ITEM_AUTOLOAD_READY "
        f"adapted={len(result['adapted'])} existing={len(result['existing'])}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
