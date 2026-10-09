#!/usr/bin/env python3
"""ES2-KING 生成 Runtime 的武學傷害參數相容補丁；不修改 Repository 內 Original ES2 原始來源。"""
from pathlib import Path
import sys


def replace_once(path: Path, source: str, old: str, new: str, label: str) -> str:
    """只在唯一錨點套用最小差異，避免靜默覆蓋上游改動。"""
    count = source.count(old)
    if count != 1:
        raise SystemExit(f"KING MARTIAL DAMAGE PATCH FAIL：{path} 的 {label} 錨點數量為 {count}，預期 1。")
    return source.replace(old, new, 1)


def patch_file(root: Path, relative: str, marker: str, transform) -> None:
    path = root / relative
    if not path.is_file():
        raise SystemExit(f"KING MARTIAL DAMAGE PATCH FAIL：缺少 Runtime 檔案 {path}")
    source = path.read_text(encoding="utf-8")
    if marker in source:
        print(f"KING MARTIAL DAMAGE PATCH ALREADY APPLIED：{relative}")
        return
    updated = transform(path, source)
    path.write_text(updated, encoding="utf-8")


def patch_combatd(path: Path, source: str) -> str:
    # 原始攻擊技巧、力道、閃躲與吸收邏輯保持不變，只在傷害換算前設定可選參數。
    source = replace_once(path, source, "        string absorb_msg;\n",
        "        string absorb_msg;\n        int damage_pct;\n", "combatd 傷害參數區域變數")
    old = """        /* 若力道未完全被吸收﹐則產生傷害。 */
        /* 產生傷害﹐則視攻擊方式給予少數精熟度 -Dragoon */
        if( strength > 0 ) {"""
    new = """        /* 若力道未完全被吸收﹐則產生傷害。 */
        /* ES2-KING MARTIAL DAMAGE PARAMS：倍率與不扣護甲只影響本次命中傷害換算。 */
        damage_pct = action["damage_pct"] > 0 ? action["damage_pct"] : 100;
        if( damage_pct != 100 ) me->set_temp("martial_damage_pct", damage_pct);
        if( action["no_armor"] ) me->set_temp("martial_no_armor", 1);
        /* 產生傷害﹐則視攻擊方式給予少數精熟度 -Dragoon */
        if( strength > 0 ) {"""
    source = replace_once(path, source, old, new, "combatd 傷害參數入口")
    old_end = """        else damage = 0;
    }

    /* 將傷害程度的訊息加入戰鬥訊息。 */"""
    new_end = """        else damage = 0;
        // ES2-KING MARTIAL DAMAGE PARAMS：清除暫存，避免倍率滲入下一次攻擊。
        me->delete_temp("martial_damage_pct");
        me->delete_temp("martial_no_armor");
    }

    /* 將傷害程度的訊息加入戰鬥訊息。 */"""
    return replace_once(path, source, old_end, new_end, "combatd 傷害參數清理")


def patch_character_combat(path: Path, source: str) -> str:
    old = """    damage += query_temp("apply/damage");

    // Call victim to resist this.
    damage -= victim->resist_damage(damage, this_object());"""
    new = """    damage += query_temp("apply/damage");

    // ES2-KING MARTIAL DAMAGE PCT：先套用倍率，再依招式決定是否扣一般護甲。
    if( query_temp("martial_damage_pct") > 0 )
        damage = damage * query_temp("martial_damage_pct") / 100;

    // Call victim to resist this unless the current move explicitly bypasses armor.
    if( !query_temp("martial_no_armor") )
        damage -= victim->resist_damage(damage, this_object());"""
    return replace_once(path, source, old, new, "角色徒手傷害與護甲區域")


def patch_equip(path: Path, source: str) -> str:
    old = """    damage += environment()->query_temp("apply/damage");

    damage -= random(victim->resist_damage(damage, this_object()));"""
    new = """    damage += environment()->query_temp("apply/damage");

    // ES2-KING MARTIAL DAMAGE PCT：武器與徒手共用倍率參數，但保留武器原有傷害骰。
    if( owner->query_temp("martial_damage_pct") > 0 )
        damage = damage * owner->query_temp("martial_damage_pct") / 100;

    // ES2-KING MARTIAL DAMAGE PCT：no_armor 只略過一般護甲減傷，不額外提高基礎傷害。
    if( !owner->query_temp("martial_no_armor") )
        damage -= random(victim->resist_damage(damage, this_object()));"""
    return replace_once(path, source, old, new, "武器傷害與護甲區域")


def patch_yijinjing(path: Path, source: str) -> str:
    old = """    damage += attacker->query_temp("apply/damage");
    damage -= victim->resist_damage(damage, attacker);"""
    new = """    damage += attacker->query_temp("apply/damage");

    // ES2-KING MARTIAL DAMAGE PCT：易筋經自訂 inflict_damage 也遵守同一參數契約。
    if( attacker->query_temp("martial_damage_pct") > 0 )
        damage = damage * attacker->query_temp("martial_damage_pct") / 100;
    if( !attacker->query_temp("martial_no_armor") )
        damage -= victim->resist_damage(damage, attacker);"""
    return replace_once(path, source, old, new, "易筋經自訂傷害區域")


def main() -> int:
    if len(sys.argv) != 2:
        raise SystemExit("用法：apply_king_martial_damage_formula.py <runtime-mudlib-root>")
    root = Path(sys.argv[1]).resolve()
    if not root.is_dir():
        raise SystemExit(f"KING MARTIAL DAMAGE PATCH FAIL：Runtime 目錄不存在：{root}")

    patch_file(root, "adm/daemons/combatd.c", "ES2-KING MARTIAL DAMAGE PARAMS", patch_combatd)
    patch_file(root, "feature/char/combat.c", "ES2-KING MARTIAL DAMAGE PCT", patch_character_combat)
    patch_file(root, "feature/equip.c", "ES2-KING MARTIAL DAMAGE PCT", patch_equip)
    patch_file(root, "d/arena/skill/yijinjing.c", "ES2-KING MARTIAL DAMAGE PCT", patch_yijinjing)
    print("KING_MARTIAL_DAMAGE_RUNTIME_PATCH_PASS: optional damage_pct/no_armor wired before armor reduction")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
