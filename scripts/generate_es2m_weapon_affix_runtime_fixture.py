#!/usr/bin/env python3
"""產生只存在 mktemp Runtime 的普通玩家武器詞綴驗證指令。"""

import argparse
from pathlib import Path


WEAPONS = (
    "/obj/area/obj/bastardsword", "/obj/area/obj/blade",
    "/obj/area/obj/broadaxe", "/obj/area/obj/broadsword",
    "/obj/area/obj/curved_blade", "/obj/area/obj/dagger",
    "/obj/area/obj/glaive", "/obj/area/obj/greatsword",
    "/obj/area/obj/longsword", "/obj/area/obj/pike",
    "/obj/area/obj/rod", "/obj/area/obj/shortsword",
    "/obj/area/obj/weirblade", "/custom/weapon/staff/long_staff",
    "/custom/weapon/staff/zenstaff", "/custom/weapon/whip/bamboo_fishing_rod",
    "/d/lee/obj/brow_staff",
)


def generate(output: Path) -> None:
    entries = ",\n".join(f'    "{path}"' for path in WEAPONS)
    source = rf'''// 由 generate_es2m_weapon_affix_runtime_fixture.py 產生；只存在隔離 Runtime。
string *weapons = ({{
{entries}
}});

private void create() {{ seteuid(getuid()); }}

private object find_test_weapon(object me)
{{
    object ob;

    foreach(ob in all_inventory(me))
        if( base_name(ob) == "/obj/area/obj/dagger" ) return ob;
    return 0;
}}

private void audit_weapon(object ob)
{{
    mapping affix, apply;

    affix = ob->query("affix");
    apply = ob->query("apply_weapon/dagger");
    write(sprintf(
        "ES2_AFFIX_AUDIT prefix=%s suffix=%s attack=%d damage=%d str=%d value=%d equipped=%s\n",
        affix["prefix"], affix["suffix"], apply["attack"], apply["damage"],
        apply["str"], ob->query("value"),
        stringp(ob->query("equipped")) ? ob->query("equipped") : "none"));
}}

int main(object me, string arg)
{{
    object ob, chest;
    string path;
    int count;

    if( !userp(me) || wizardp(me) )
        return notify_fail("ES2_AFFIX_FIXTURE_DENIED: ordinary-player-only\n");

    if( arg == "loadall" ) {{
        foreach(path in weapons) {{
            ob = new(path);
            if( !objectp(ob) )
                return notify_fail("ES2_AFFIX_LOAD_FAIL:" + path + "\n");
            count++;
            destruct(ob);
        }}
        write("ES2_AFFIX_LOADALL count=" + count + "\n");
        return 1;
    }}

    if( arg == "give" ) {{
        ob = new("/obj/area/obj/dagger");
        if( !objectp(ob) ) return notify_fail("ES2_AFFIX_GIVE_FAIL:new\n");
        ENHANCE_D->apply_affix(ob, ([ "prefix": "黑鋼", "suffix": "火炎" ]));
        if( !ob->move(me) ) {{ destruct(ob); return notify_fail("ES2_AFFIX_GIVE_FAIL:move\n"); }}
        write("ES2_AFFIX_GIVE deterministic=黑鋼火炎\n");
        return 1;
    }}

    if( arg == "audit" ) {{
        ob = find_test_weapon(me);
        if( !objectp(ob) ) return notify_fail("ES2_AFFIX_AUDIT_FAIL:missing\n");
        audit_weapon(ob);
        return 1;
    }}

    if( arg == "store" ) {{
        ob = find_test_weapon(me);
        if( !objectp(ob) ) return notify_fail("ES2_AFFIX_STORE_FAIL:missing\n");
        chest = new("/custom/home/obj/storage_chest");
        if( !objectp(chest) ) return notify_fail("ES2_AFFIX_STORE_FAIL:chest\n");
        chest->set_home_owner(me);
        if( !chest->do_store("dagger") ) {{ destruct(chest); return 0; }}
        destruct(chest);
        write("ES2_AFFIX_STORE_PASS\n");
        return 1;
    }}

    if( arg == "retrieve" ) {{
        chest = new("/custom/home/obj/storage_chest");
        if( !objectp(chest) ) return notify_fail("ES2_AFFIX_RETRIEVE_FAIL:chest\n");
        chest->set_home_owner(me);
        if( !chest->do_retrieve("1") ) {{ destruct(chest); return 0; }}
        destruct(chest);
        ob = find_test_weapon(me);
        if( !objectp(ob) ) return notify_fail("ES2_AFFIX_RETRIEVE_FAIL:missing\n");
        audit_weapon(ob);
        write("ES2_AFFIX_RETRIEVE_PASS\n");
        return 1;
    }}

    return notify_fail("用法：es2affix loadall|give|audit|store|retrieve\n");
}}
'''
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(source, encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    generate(args.output)
    print(f"ES2M_WEAPON_AFFIX_FIXTURE_READY count={len(WEAPONS)}")


if __name__ == "__main__":
    main()
