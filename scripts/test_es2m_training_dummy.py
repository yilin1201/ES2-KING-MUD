#!/usr/bin/env python3
"""ES2M 練武假人整合閘門：確認 Expansion 補丁已套用至獨立 Runtime。"""

from pathlib import Path
import argparse

# 此測試只讀取檔案，不啟動遊戲、不修改 Original ES2 保存來源。
ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "es2_king_expansion" / "runtime" / "mudlib"
APPLY = ROOT / "scripts" / "apply_es2_king_expansion.sh"


def require(condition: bool, message: str) -> None:
    """以清楚錯誤訊息取代容易被忽略的裸 assert。"""
    if not condition:
        raise SystemExit("ES2M TRAINING DUMMY FAIL：" + message)


def source_file(root: Path, stem: str) -> Path:
    """兼容 Original／Neolith 使用 .c 或 .lpc 的不同版本。"""
    for suffix in (".c", ".lpc"):
        candidate = root / (stem + suffix)
        if candidate.is_file():
            return candidate
    raise SystemExit("ES2M TRAINING DUMMY FAIL：Runtime 缺少 " + stem + "（.c/.lpc）。")


def main() -> None:
    parser = argparse.ArgumentParser(description="驗證 ES2M 練武假人 Expansion 整合。")
    parser.add_argument("--runtime", help="已套用 Expansion 的 Runtime 根目錄（包含 mudlib/）。")
    args = parser.parse_args()

    # 來源快照與 Expansion 物件必須存在，防止只加指令而漏掉假人本體。
    stake = OVERLAY / "custom" / "zhenwu" / "npc" / "target_stake.c"
    teacher = OVERLAY / "d" / "snow" / "npc" / "teacher.c"
    apply_text = APPLY.read_text(encoding="utf-8")
    require(stake.is_file(), "Expansion 缺少 target_stake.c。")
    require('set("training_dummy", 1);' in stake.read_text(encoding="utf-8"),
            "target_stake 沒有標記 training_dummy。")
    require(teacher.is_file(), "Expansion 缺少 ES2M 私塾 teacher.c。")
    teacher_text = teacher.read_text(encoding="utf-8")
    require('improve_skill_exact("literate"' in teacher_text,
            "私塾未採用 ES2M 精確讀書識字點數。")
    require('set_power("B");' in teacher_text,
            "私塾未保留 ES2M NPC 強度設定。")

    # Apply script 必須逐項修補生成 Runtime，且每項都有冪等標記。
    for marker in (
        "ES2M TRAINING DUMMY COMBAT",
        "ES2M TRAINING DUMMY FIGHT",
        "ES2M TRAINING DUMMY KILL",
        "ES2M TRAINING DUMMY LOOK",
    ):
        require(marker in apply_text, "套用腳本缺少標記：" + marker)

    if args.runtime:
        # Dockerfile 傳入 Runtime 根目錄；實際程式都應位於其 mudlib/ 子目錄。
        runtime = Path(args.runtime) / "mudlib"
        combat = source_file(runtime, "adm/daemons/combatd").read_text(encoding="utf-8")
        fight = source_file(runtime, "cmds/std/fight").read_text(encoding="utf-8")
        kill = source_file(runtime, "cmds/std/kill").read_text(encoding="utf-8")
        look = source_file(runtime, "cmds/std/look").read_text(encoding="utf-8")
        runtime_stake = runtime / "custom" / "zhenwu" / "npc" / "target_stake.c"
        runtime_teacher = (runtime / "d" / "snow" / "npc" / "teacher.c").read_text(encoding="utf-8")

        require("ES2M TRAINING DUMMY COMBAT" in combat, "生成 Runtime combatd 未套用假人戰鬥規則。")
        require("if( !dummy ) ability -= random( victim->query_skill(skill) );" in combat,
                "假人仍會以自身技能降低攻擊命中率。")
        require("if( !dummy && !victim->is_busy()" in combat,
                "假人仍可閃躲或格擋。")
        require("if( damage > 0 && !dummy ) report_status(victim);" in combat,
                "假人仍顯示體力傷勢敘述。")
        require("ES2M TRAINING DUMMY FIGHT" in fight, "生成 Runtime fight 未套用假人分流。")
        require("ES2M TRAINING DUMMY KILL" in kill, "生成 Runtime kill 未套用假人分流。")
        require("ES2M TRAINING DUMMY LOOK" in look and '!obj->query("training_dummy")' in look,
                "生成 Runtime look 仍顯示假人外貌／年齡。")
        require(runtime_stake.is_file() and 'set("training_dummy", 1);' in runtime_stake.read_text(encoding="utf-8"),
                "生成 Runtime 缺少假人物件。")
        require("ES2-KING ORIGINAL SCHOLAR UTF-8 COMPATIBILITY" in runtime_teacher,
                "生成 Runtime 私塾未套用 UTF-8 回答相容修正。")

    print("ES2M TRAINING DUMMY PASS／來源物件、私塾更新及 Runtime 套用契約均符合。")


if __name__ == "__main__":
    main()
