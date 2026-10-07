#!/usr/bin/env python3
"""只在生成 Runtime 為 ES2M 防具及普通世界裝備加入既有 autoload 介面。"""
import argparse
import csv
from pathlib import Path

MARKER = "// ES2-KING RUNTIME PERSISTENCE ADAPTER: ES2M ARMOR BATCH 20261003"
ORDINARY_MARKER = "// ES2-KING RUNTIME PERSISTENCE ADAPTER: ORDINARY EQUIPMENT 20261008"
ORDINARY_EQUIPMENT = (
    "d/snow/npc/obj/woodsword.c",
    "d/snow/npc/obj/blue_cloth.c",
)
ADAPTER = r'''

// ES2-KING RUNTIME PERSISTENCE ADAPTER: ES2M ARMOR BATCH 20261003
// 保存快照仍維持 ES2M 原始 SHA；此段只套入生成 Runtime。
string query_autoload()
{
    string equipped;

    equipped = query("equipped");
    return stringp(equipped) ? equipped : "inventory";
}

private void es2_king_restore_wear(string on_part)
{
    object owner;

    owner = environment();
    if( objectp(owner) && owner->is_character() ) wear(on_part);
}

void autoload(string param)
{
    string on_part;

    // Login setup 與多件 autoload 同時進行；延後一秒，避免登入 prompt 與 wear() 競速。
    if( stringp(param) && sscanf(param, "armor/%s", on_part) == 1 )
        call_out("es2_king_restore_wear", 1, on_part);
}
'''

ORDINARY_ADAPTER = r'''

// ES2-KING RUNTIME PERSISTENCE ADAPTER: ORDINARY EQUIPMENT 20261008
// Original／ES2M 的一般木劍與藍布長衫沒有 autoload，因此原本重登後會消失。
// 只沿用既有物件清單保存介面；不保存 equipped 暫態，重登後仍須玩家重新 wield／wear。
int query_autoload() { return 1; }
void autoload(string param) { }
'''


def batch_paths(matrix: Path) -> list[str]:
    with matrix.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    return sorted(
        row["source_path"] for row in rows
        if row["note"].startswith("來源SHA一致；custom overlay")
        and "/armor/" in row["source_path"]
    )


def apply(matrix: Path, runtime: Path) -> dict[str, list[str]]:
    paths = batch_paths(matrix)
    if len(paths) != 91:
        raise RuntimeError(f"ES2M_ARMOR_PERSISTENCE_BATCH_COUNT: {len(paths)}")
    result = {
        "adapted": [], "existing": [], "missing": [], "conflicts": [],
        "ordinary_adapted": [], "ordinary_existing": [],
    }
    for rel in paths:
        target = runtime / rel
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
        result["adapted"].append(rel)

    for rel in ORDINARY_EQUIPMENT:
        target = runtime / rel
        if not target.is_file():
            result["missing"].append(rel)
            continue
        text = target.read_text(encoding="utf-8")
        if ORDINARY_MARKER in text:
            result["ordinary_existing"].append(rel)
            continue
        # 木劍在既有 KING expansion 已使用相同的「只回背包、不恢復 equipped」契約；
        # 視為相容既有成果，不重複插入第二份函數。
        if "int query_autoload() { return 1; }" in text and "void autoload(string param) { }" in text:
            result["ordinary_existing"].append(rel)
            continue
        if "query_autoload(" in text or "void autoload(" in text:
            result["conflicts"].append(rel)
            continue
        target.write_text(text.rstrip() + ORDINARY_ADAPTER + "\n", encoding="utf-8")
        result["ordinary_adapted"].append(rel)
    if result["missing"] or result["conflicts"]:
        raise RuntimeError(
            f"ES2M_ARMOR_PERSISTENCE_UNSAFE missing={len(result['missing'])} "
            f"conflicts={len(result['conflicts'])}"
        )
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    args = parser.parse_args()
    result = apply(args.matrix, args.runtime)
    print(
        "ES2M_ARMOR_PERSISTENCE_RUNTIME_READY "
        f"adapted={len(result['adapted'])} existing={len(result['existing'])} "
        f"ordinary_adapted={len(result['ordinary_adapted'])} "
        f"ordinary_existing={len(result['ordinary_existing'])}"
    )


if __name__ == "__main__":
    main()
