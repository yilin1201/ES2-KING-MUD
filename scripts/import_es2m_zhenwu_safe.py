#!/usr/bin/env python3
"""ES2M 振武軍營：保守補入已考證來源；同名衝突不覆蓋。"""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

# 已人工逐檔合併的 KING／ES2M 振武軍營內容；只在全部必要標記吻合時視為相容。
KING_ZHENWU_MERGED = {
    "custom/zhenwu/npc/lu_xinien.c": (
        'set("nickname","徵兵官")', 'set_level(25)', 'set_power("B")',
        '/custom/weapon/blade/steelblade', 'CYN + "魯熙年花了',
    ),
    "custom/zhenwu/npc/mee_pei.c": (
        'set_attr("str", 40)', 'set_stat_maximum("gin", 600)',
        'set_skill("berserk", 180)', 'set_skill("twohanded axe", 150)',
        'set_power("A")', 'HEAVY_PARRY_MERIT 100000',
        'improve_skill_exact("heavy_parry", 1)', '/obj/books/book_of_assault',
        'set("chat_msg_combat"',
    ),
    "custom/zhenwu/npc/soldier.c": (
        'set_level(5)', 'set_power("B")', 'set_stat_maximum("gin", 120)',
        'set_stat_maximum("kee", 100)', 'set_stat_maximum("sen", 40)',
    ),
    "custom/zhenwu/npc/zhenwu_soldier.c": (
        'set_level(15)', 'set_power("C")', 'set_attr("str", 25)',
        'set_attr("cor", 22)', 'set_attr("con", 20)',
        'set_skill("twohanded pike", 60)', 'set_skill("unarmed", 60)',
    ),
    "custom/zhenwu/obj/recruit_stone.c": (
        'set("custom_faction", "soldier.ber")',
        'set("soldier/from_fighter", 1)',
        '強力格擋改由米沛傳授',
    ),
}
KING_ZHENWU_FORBIDDEN = {
    # 強力格擋不可在徵兵時直接授予；必須由米沛依軍人身分、等級與戰功傳授。
    "custom/zhenwu/obj/recruit_stone.c": (
        'me->set_skill("heavy_parry", 1);',
        'me->set_learn("heavy_parry", 1);',
    ),
}

def stage(snapshot, runtime):
    source = snapshot / "custom/zhenwu"
    if not source.is_dir() or not runtime.is_dir():
        raise FileNotFoundError("ZHENWU_STAGE_ROOT_MISSING")
    report = {"staged": [], "identical": [], "overlay_compatible": [], "conflicts_review": [],
              "conflict_details": [],
              "external_gate": "PENDING", "status": "FILE_STAGE_ONLY_NOT_GAMEPLAY_PASS"}
    for file in sorted(source.rglob("*.c")):
        rel = file.relative_to(snapshot)
        target = runtime / rel
        if target.exists():
            if sha(file) == sha(target):
                report["identical"].append(str(rel))
            elif str(rel) in KING_ZHENWU_MERGED:
                # 已完成逐檔合併：確認 ES2M 新增基礎資料與 KING 專屬規則同時存在。
                content = target.read_text(encoding="utf-8")
                required = KING_ZHENWU_MERGED[str(rel)]
                forbidden = KING_ZHENWU_FORBIDDEN.get(str(rel), ())
                if all(token in content for token in required) and not any(token in content for token in forbidden):
                    report["overlay_compatible"].append(str(rel))
                else:
                    report["conflicts_review"].append(str(rel))
            elif str(rel) == "custom/zhenwu/npc/target_stake.c":
                # ES2-KING overlay 只新增 accept_kill()，讓假人不喊救命；
                # 以精確文字比對確認此已知相容差異，不覆寫任一來源檔。
                original = file.read_text()
                expected = original.replace(
                    'int accept_fight(object who) { return 1; }\n',
                    'int accept_fight(object who) { return 1; }\n\n'
                    '/* 假人是死物：被 kill 時不會喊救命。 */\n'
                    'void accept_kill(object ob) { }\n',
                    1,
                )
                if expected != original and target.read_text() == expected:
                    report["overlay_compatible"].append(str(rel))
                else:
                    report["conflicts_review"].append(str(rel))
                    report["conflict_details"].append({
                        "path": str(rel), "source_sha256": sha(file), "runtime_sha256": sha(target)
                    })
            else:
                report["conflicts_review"].append(str(rel))
                report["conflict_details"].append({
                    "path": str(rel), "source_sha256": sha(file), "runtime_sha256": sha(target)
                })
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file, target)
            report["staged"].append(str(rel))
    # 雪亭南門若已有 west，僅在相同目的地時承認連接；
    # 未知 Original 出口不得自動覆蓋或改寫。
    gate = runtime / "d/snow/sgate.c"
    if gate.is_file():
        text = gate.read_text()
        if '"/custom/zhenwu/room/gate"' in text:
            report["external_gate"] = "LINK_PRESENT"
        elif '"/d/newcamp/gate"' in text and '"north" : __DIR__"sstreet1"' in text:
            # Original 西向軍營出口仍為註解；只啟用這條有 ES2M 證據的連接。
            import re
            patched, count = re.subn(
                r'^([ \\t]*)//[ \\t]*"west" : "/d/newcamp/gate",',
                r'\\1"west" : "/custom/zhenwu/room/gate",',
                text, count=1, flags=re.MULTILINE)
            if count == 1:
                gate.write_text(patched)
                report["external_gate"] = "LINK_STAGED_FROM_ORIGINAL_COMMENT"
            else:
                report["external_gate"] = "REVIEW_REQUIRED"
        else:
            report["external_gate"] = "REVIEW_REQUIRED"
    return report

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--snapshot", type=Path, required=True)
    p.add_argument("--runtime", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    result = stage(a.snapshot, a.runtime)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n")
    print("ES2M_ZHENWU_STAGE", json.dumps({k: len(v) if isinstance(v,list) else v for k,v in result.items()},ensure_ascii=False))
    if result["conflicts_review"]:
        print("ES2M_ZHENWU_CONFLICT_DETAILS", json.dumps(result["conflict_details"], ensure_ascii=False))
    if result["conflicts_review"] or result["external_gate"] != "LINK_PRESENT":
        raise SystemExit("ZHENWU_REVIEW_REQUIRED: source preserved; no gameplay claim")

if __name__ == "__main__":
    main()
