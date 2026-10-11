#!/usr/bin/env python3
"""ES2M 2026-10-09 最新武學更新的快照／King 相容層／生成 Runtime 稽核。"""

from pathlib import Path
import argparse
import hashlib

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = ROOT / "es2m_snapshot/mudlib"
OVERLAY = ROOT / "es2_king_expansion/runtime/mudlib"


def require(condition: bool, message: str) -> None:
    """用明確錯誤指出來源或 Runtime 更新缺口。"""
    if not condition:
        raise SystemExit("ES2M LATEST MARTIAL UPDATE FAIL：" + message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path: Path) -> str:
    require(path.is_file(), "缺少檔案：" + str(path.relative_to(ROOT)))
    return path.read_text(encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", type=Path, help="可選：已套用 ES2M 與 King Expansion 的 Runtime 根目錄")
    args = parser.parse_args()

    # 狻猊步法：只在實際閃避成功後，由戰鬥系統顯示 defend_message。
    steps_path = SNAPSHOT / "daemon/skill/tiger-steps.c"
    steps = read(steps_path)
    require(steps.count('"$n') == 5, "狻猊步法應使用最新五句閃避成功敘述。")
    require('set_temp("defend_message"' in steps, "狻猊步法沒有交由戰鬥系統在閃避成功後顯示敘述。")
    require('int query_entry_level() { return 10; }' in steps, "狻猊步法缺少 10 級學成設定。")
    require('gain_score("martial art", lv * 10)' in steps, "狻猊步法缺少每級武術造詣獎勵。")
    require('gain_score("martial mastery", (lv - 40) * 10)' in steps, "狻猊步法缺少 41 級起武學之道獎勵。")
    require("使出狻猊步法" not in steps, "狻猊步法仍殘留舊版攻擊嘗試敘述。")

    # King 保留自訂招式與瘋虎功屬性成長，只補入 ES2M 的分數成長規則。
    sanmeendo = read(SNAPSHOT / "daemon/skill/sanmeendo.c")
    require('gain_score("martial art", lv * 10)' in sanmeendo, "三門刀法缺少每級武術造詣獎勵。")
    require('gain_score("martial mastery", (lv - 29) * 10)' in sanmeendo, "三門刀法缺少 30 級起武學之道獎勵。")

    tiger_force = read(SNAPSHOT / "daemon/skill/tiger-force.c")
    require('me->gain_score("martial art", lv * 10)' in tiger_force, "瘋虎功缺少逐級武術造詣獎勵。")
    require('me->gain_score("martial mastery", (lv - 30) * 10)' in tiger_force, "瘋虎功缺少 31 級起武學之道獎勵。")
    require("User-provided Tiger Force growth table" in tiger_force,
            "瘋虎功 King 自訂精氣上限與屬性成長表遭到覆蓋。")

    # 高慎只修正訊息，不替換 King 的歷史重建拜師／授技邏輯。
    kao = read(SNAPSHOT / "d/oldpine/npc/kao_shen.c")
    require("你的瘋虎功火候未到，也敢妄學瘋虎刀法？" in kao,
            "高慎尚未同步 ES2M 最新門檻提示。")
    require("瘋虎功不到三十級" not in kao, "高慎仍顯示舊版等級直述訊息。")

    # 私塾：快照保存 ES2M 原始版本；King overlay 使用正式 race 代碼並修復 UTF-8 回答。
    teacher_snapshot = read(SNAPSHOT / "d/snow/npc/teacher.c")
    teacher = read(OVERLAY / "d/snow/npc/teacher.c")
    require('improve_skill_exact("literate"' in teacher_snapshot, "私塾快照缺少精確讀書點數更新。")
    require('set("chat_chance", 40);' in teacher_snapshot, "私塾快照未同步 40% 唸書機率。")
    require('"avatar", "human", "rainnar"' in teacher, "King 私塾未使用正式 race 代碼 rainnar。")
    require('"avatar", "human", "rainner"' not in teacher, "King 私塾仍使用錯誤的 rainner 代碼。")

    # 2026-10-11 ES2M updates: merge compatible fixes while preserving KING-only rules.
    hainmay = read(OVERLAY / "daemon/skill/hainmay_force.c")
    require('mm_minus = 29;' in hainmay, "寒梅心法武學之道應從 30 級按 (lv - 29) 計算。")
    require('int valid_learn(object me)' in hainmay and 'is_faction(me, "fighter.lunmay")' in hainmay,
            "寒梅心法缺少冷梅莊門派學習限制。")
    require('COMBAT_D->int_formula_exp(me)' in hainmay,
            "寒梅心法未同步 ES2M 標準內功修習點數公式。")

    skill = read(OVERLAY / "feature/char/skill.c")
    require('if( value <= 10 ) return 100;' in skill and 'if( value <= 25 ) return 60;' in skill,
            "人物技能屬性成長機率未同步 ES2M 分段表。")
    require('es2_king_skill_cap()' in skill and 'this_object()->query("id") == "king"' in skill,
            "技能成長更新不得移除 KING 專屬 300 級權限。")

    martial = read(OVERLAY / "std/martial_art.c")
    require(martial.count('if( !objectp(weapon) ) weapon = 0;') >= 2,
            "新版武功引擎缺少特殊攻擊／一般攻擊的武器物件型別防護。")

    pot = read(OVERLAY / "d/snow/npc/obj/pot.c")
    wine_pot = read(OVERLAY / "d/snow/npc/obj/wine_pot.c")
    require('if( !(liquid = present("water", this_object())) )' in pot and 'liquid->set_volume(100000);' in pot,
            "大水缸在水喝光後應能重新建立並補滿水。")
    require('if( !(liquid = present("red wine", this_object())) )' in wine_pot and 'liquid->set_volume(150000);' in wine_pot,
            "大酒缸在酒喝光後應能重新建立並補滿酒。")

    if args.runtime:
        runtime = args.runtime / "mudlib"
        # 這三個技能在 pinned Original ES2 不存在，由 ES2M 快照補入；因此必須逐位元相同。
        for rel in ("daemon/skill/tiger-steps.c",
                    "daemon/skill/tiger-force.c",
                    "daemon/skill/sanmeendo.c",
                    "d/oldpine/npc/kao_shen.c"):
            expected = SNAPSHOT / rel
            actual = runtime / rel
            require(actual.is_file(), "生成 Runtime 缺少 " + rel)
            require(digest(expected) == digest(actual), "生成 Runtime 與已核對快照不一致：" + rel)

        runtime_teacher = read(runtime / "d/snow/npc/teacher.c")
        require("ES2-KING ORIGINAL SCHOLAR UTF-8 COMPATIBILITY" in runtime_teacher,
                "生成 Runtime 私塾未套用 UTF-8 書生回答相容修正。")
        require('"avatar", "human", "rainnar"' in runtime_teacher,
                "生成 Runtime 私塾未套用 King 正式種族代碼。")

    print("ES2M_LATEST_MARTIAL_UPDATE_STATIC_PASS tiger_steps=latest sanmeendo=mastery tiger_force=mastery kao_shen=message teacher=king_race_compat")
    if args.runtime:
        print("ES2M_LATEST_MARTIAL_UPDATE_RUNTIME_PASS imported_skill_and_npc_hashes=4 teacher_utf8_and_race=verified")
    print("STATUS=SOURCE_AND_RUNTIME_FILE_CONTRACT; GAMEPLAY_REQUIRES_DRIVER_E2E")


if __name__ == "__main__":
    main()
