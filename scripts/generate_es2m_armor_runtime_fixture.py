#!/usr/bin/env python3
"""由既有 91 件防具清冊產生只存在隔離 Runtime 的普通玩家測試指令。"""
import argparse
import csv
from pathlib import Path


def armor_rows(matrix: Path) -> list[dict[str, str]]:
    with matrix.open(encoding="utf-8", newline="") as handle:
        rows = [
            row for row in csv.DictReader(handle)
            if row["note"].startswith("來源SHA一致；custom overlay")
            and "/armor/" in row["source_path"]
        ]
    if len(rows) != 91:
        raise RuntimeError(f"ES2M_ARMOR_FIXTURE_BATCH_COUNT: {len(rows)}")
    return sorted(rows, key=lambda row: row["source_path"])


def generate(matrix: Path, output: Path) -> None:
    rows = armor_rows(matrix)
    pairs = []
    for row in rows:
        rel = row["source_path"]
        key = Path(rel).stem
        pairs.append((key, "/" + rel[:-2]))
    if len({key for key, _ in pairs}) != len(pairs):
        raise RuntimeError("ES2M_ARMOR_FIXTURE_DUPLICATE_KEY")
    entries = ",\n".join(f'    "{key}" : "{path}"' for key, path in pairs)
    source = rf'''// 由 generate_es2m_armor_runtime_fixture.py 產生；只複製進 mktemp Runtime。
mapping armors = ([
{entries}
]);

private void create() {{ seteuid(getuid()); }}

private int is_batch_armor(object ob)
{{
    return objectp(ob) && member_array(base_name(ob), values(armors)) >= 0;
}}

private object find_path(object me, string path)
{{
    object ob;

    foreach(ob in all_inventory(me))
        if( base_name(ob) == path ) return ob;
    return 0;
}}

int main(object me, string arg)
{{
    object ob, duplicate, corpse;
    object *inventory;
    string key, path, equipped, class_name, race_name;
    int count, equipped_count, hand, head, leg, neck, waist, unique_ok;

    if( !userp(me) || wizardp(me) )
        return notify_fail("ES2_ARMOR_FIXTURE_DENIED: ordinary-player-only\n");

    if( arg == "loadall" ) {{
        foreach(key, path in armors) {{
            ob = new(path);
            if( !objectp(ob) )
                return notify_fail("ES2_ARMOR_FIXTURE_LOAD_FAIL:" + key + "\n");
            count++;
            destruct(ob);
        }}
        write("ES2_ARMOR_LOADALL count=" + count + " total=" + sizeof(armors) + "\n");
        return 1;
    }}

    if( sscanf(arg, "give %s", key) == 1 ) {{
        path = armors[key];
        if( !stringp(path) ) return notify_fail("ES2_ARMOR_FIXTURE_UNKNOWN:" + key + "\n");
        ob = find_path(me, path);
        if( !objectp(ob) ) ob = new(path);
        if( !objectp(ob) || (!environment(ob) && !ob->move(me)) )
            return notify_fail("ES2_ARMOR_FIXTURE_GIVE_FAIL:" + key + "\n");
        write("ES2_ARMOR_GIVE key=" + key + "\n");
        return 1;
    }}

    if( sscanf(arg, "purge %s", key) == 1 ) {{
        path = armors[key];
        ob = stringp(path) ? find_path(me, path) : 0;
        if( objectp(ob) ) destruct(ob);
        write("ES2_ARMOR_PURGE key=" + key + "\n");
        return 1;
    }}

    if( arg == "audit" ) {{
        inventory = all_inventory(me);
        foreach(ob in inventory) {{
            if( !is_batch_armor(ob) ) continue;
            count++;
            equipped = ob->query("equipped");
            if( !stringp(equipped) ) continue;
            equipped_count++;
            if( equipped == "armor/hand_eq" ) hand++;
            if( equipped == "armor/head_eq" ) head++;
            if( equipped == "armor/leg_eq" ) leg++;
            if( equipped == "armor/neck_eq" ) neck++;
            if( equipped == "armor/waist_eq" ) waist++;
        }}
        write(sprintf("ES2_ARMOR_AUDIT count=%d equipped=%d hand=%d head=%d leg=%d neck=%d waist=%d class=%s race=%s\n",
            count, equipped_count, hand, head, leg, neck, waist,
            me->query_class(), me->query_race()));
        return 1;
    }}

    if( sscanf(arg, "identity %s %s", class_name, race_name) == 2 ) {{
        me->set_race(race_name);
        me->set_class(class_name);
        write("ES2_ARMOR_IDENTITY class=" + me->query_class()
            + " race=" + me->query_race() + "\n");
        return 1;
    }}

    if( arg == "unique" ) {{
        foreach(path in ({{
            "/custom/armor/head/lion_helmet",
            "/custom/armor/neck/tiger_necklace",
            "/custom/armor/waist/white_girth"
        }})) {{
            ob = new(path);
            duplicate = new(path);
            if( objectp(ob) && objectp(duplicate) && duplicate->violate_unique() ) unique_ok++;
            if( objectp(ob) ) destruct(ob);
            if( objectp(duplicate) ) destruct(duplicate);
        }}
        write("ES2_ARMOR_UNIQUE_CHECK count=" + unique_ok + "\n");
        return 1;
    }}

    if( arg == "corpse" ) {{
        corpse = new("/obj/corpse");
        corpse->set_name("隔離測試屍體", ({{ "fixture corpse", "corpse" }}));
        corpse->move(environment(me));
        write("ES2_ARMOR_CORPSE_READY\n");
        return 1;
    }}

    return notify_fail("用法：es2armor loadall|give <key>|purge <key>|audit|identity <class> <race>|unique|corpse\n");
}}
'''
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(source, encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    generate(args.matrix, args.output)
    print("ES2M_ARMOR_RUNTIME_FIXTURE_READY count=91")


if __name__ == "__main__":
    main()
