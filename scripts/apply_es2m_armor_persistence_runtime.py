#!/usr/bin/env python3
"""只在生成 Runtime 為本批 91 件 ES2M 防具加入背包／穿戴狀態保存介面。"""
import argparse
import csv
from pathlib import Path

MARKER = "// ES2-KING RUNTIME PERSISTENCE ADAPTER: ES2M ARMOR BATCH 20261003"
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

    if( stringp(param) && sscanf(param, "armor/%s", on_part) == 1 )
        call_out("es2_king_restore_wear", 0, on_part);
}
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
    result = {"adapted": [], "existing": [], "missing": [], "conflicts": []}
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
        f"adapted={len(result['adapted'])} existing={len(result['existing'])}"
    )


if __name__ == "__main__":
    main()
