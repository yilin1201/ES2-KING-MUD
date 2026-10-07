#!/usr/bin/env python3
"""為生成 Runtime 的 COMBINED_ITEM 加入數量 autoload；不改 ES2M 保存快照。"""

from __future__ import annotations
import argparse
from pathlib import Path

MARKER = "// ES2-KING COMBINED ITEM AUTOLOAD"
NEEDLE = "int query_amount() { return amount; }\n"
ADAPTER = r'''

// ES2-KING COMBINED ITEM AUTOLOAD
// Original/ES2M combined item 沒有保存數量；KING Runtime 只保存檔名與正整數 amount。
string query_autoload()
{
    return sprintf("%d", amount > 0 ? amount : 1);
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

def apply(mudlib: Path) -> int:
    target = mudlib / "std/item/combined.c"
    if not target.is_file():
        raise RuntimeError(f"Runtime 缺少 COMBINED_ITEM：{target}")
    text = target.read_text(encoding="utf-8")
    if MARKER in text:
        return 0
    if NEEDLE not in text:
        raise RuntimeError("COMBINED_ITEM 基準未知，停止套用 autoload adapter")
    target.write_text(text.replace(NEEDLE, NEEDLE + ADAPTER, 1), encoding="utf-8")
    (mudlib / "bin/std/item/combined.b").unlink(missing_ok=True)
    return 1

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", type=Path, required=True, help="Runtime mudlib")
    args = parser.parse_args()
    changed = apply(args.runtime.resolve())
    print(f"COMBINED_ITEM_AUTOLOAD_READY changed={changed}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
