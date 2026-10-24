#!/usr/bin/env python3
"""ES2M 冷梅莊武學隔離整合的靜態完整性閘門；不代表 LPC 編譯或實機玩法通過。"""
from pathlib import Path
import argparse
import hashlib
import sys

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--runtime", type=Path, help="可選：檢查已套用 Expansion 的 Runtime 根目錄")
ARGS = parser.parse_args()
SNAPSHOT = ROOT / "es2m_snapshot/mudlib"
FROZEN_BASELINE = ROOT / "es2m_snapshot/king_frozen_baseline"
OVERLAY = ROOT / "es2_king_expansion/runtime/mudlib"
RUNTIME = ARGS.runtime / "mudlib" if ARGS.runtime else None
# 僅覆蓋本次新增的技能；既有凍結武功保留 KDS／KING 原始檔，不以 ES2M 最新版整檔覆寫。
SKILL_FILES = ("mayin.c", "seven.c")
FROZEN_SKILLS = ("lunmay.c", "hainmay_force.c", "advance_lunmay.c")

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

errors = []
# 五門武學來源與 Expansion 覆蓋檔必須逐位元一致，避免證據與執行候選分叉。
for name in SKILL_FILES:
    source = SNAPSHOT / "daemon/skill" / name
    overlay = OVERLAY / "daemon/skill" / name
    if not source.is_file() or not overlay.is_file():
        errors.append(f"缺少來源或 Expansion 技能檔：{name}")
    elif digest(source) != digest(overlay):
        errors.append(f"來源快照與 Expansion 技能檔 SHA-256 不一致：{name}")

# 冷梅劍法、寒梅心法、傲梅暗劍訣屬既有凍結武功。
# pinned Original Runtime 沒有這三個技能檔，因此只帶入 KDS/KING 凍結基準，不採用 ES2M 最新改版。
for name in FROZEN_SKILLS:
    source = SNAPSHOT / "daemon/skill" / name
    baseline = FROZEN_BASELINE / "daemon/skill" / name
    overlay = OVERLAY / "daemon/skill" / name
    if not source.is_file():
        errors.append(f"缺少凍結武功的最新 ES2M 證據快照：{name}")
    if not baseline.is_file() or not overlay.is_file():
        errors.append(f"缺少凍結武功的 KING 基準或 Runtime overlay：{name}")
    elif digest(baseline) != digest(overlay):
        errors.append(f"凍結武功 Runtime overlay 不等於 KING 基準版本：{name}")
    if source.is_file() and overlay.is_file() and digest(source) == digest(overlay):
        errors.append(f"凍結武功不得被 ES2M 最新版本取代：{name}")

# 新版武功共用引擎需支援學成點數、學成等級及學成當級獎勵。
martial = OVERLAY / "std/martial_art.c"
if not martial.is_file():
    errors.append("缺少 Expansion std/martial_art.c")
else:
    text = martial.read_text(encoding="utf-8")
    for token in ("art_entry_threshold", "art_entry_reward", "query_entry_level",
                  "query_entry_threshold", "skill_completed", "is_faction"):
        if token not in text:
            errors.append(f"新版武功共用引擎缺少必要介面：{token}")

# KING 技能成長客製規則不可被整檔上游覆蓋；只擴充必要的入門等級／門檻介面。
skill = OVERLAY / "feature/char/skill.c"
if not skill.is_file():
    errors.append("缺少 KING Expansion feature/char/skill.c")
else:
    text = skill.read_text(encoding="utf-8")
    for token in ("es2_king_skill_cap", "restored_skill_entry_level",
                  "restored_skill_level_threshold", "skill_entry_level",
                  "skill_threshold", "skill_completed",
                  '"lunmay"', '"hainmay force"', '"advance_lunmay"', '"mayin"', '"seven"'):
        if token not in text:
            errors.append(f"KING 技能成長整合缺少必要保護或介面：{token}")

# 梅影風 NPC 與強度系統的隔離整合檢查。
npc = OVERLAY / "d/wutang/npc/may_yin_fong.c"
room = OVERLAY / "d/wutang/crossroad.c"
power = OVERLAY / "daemon/misc/npc_power.c"
npc_base = OVERLAY / "std/char/npc.c"
daemon_header = OVERLAY / "include/daemon.h"
for path in (npc, room, power, npc_base, daemon_header):
    if not path.is_file():
        errors.append(f"缺少梅影風／NPC 強度 Runtime 檔案：{path.relative_to(OVERLAY)}")
if npc.is_file():
    text = npc.read_text(encoding="utf-8")
    if 'set_power("S")' not in text or '"custom_faction", FACTION' not in text:
        errors.append("梅影風未設定 S 級強度或冷梅莊門派身分")
    if "skill_entry_level(skill)" not in text or "skill_threshold(skill, entry_level)" not in text:
        errors.append("梅影風傳授未依技能實際入門等級補足學成點數")
    if '"rainnar"' not in text or '"rainner"' in text:
        errors.append("梅影風拜師種族排除條件未對齊 KING 正式 race 代碼 rainnar")
if room.is_file() and 'npc/may_yin_fong" : 1' not in room.read_text(encoding="utf-8"):
    errors.append("五堂鎮交叉路口尚未生成梅影風")
if power.is_file() and "void apply_power" not in power.read_text(encoding="utf-8"):
    errors.append("NPC 強度 daemon 缺少 apply_power 介面")
if npc_base.is_file() and "void set_power(string tier)" not in npc_base.read_text(encoding="utf-8"):
    errors.append("NPC 基底缺少 set_power 強度介面")
if daemon_header.is_file() and "#define NPC_POWER_D" not in daemon_header.read_text(encoding="utf-8"):
    errors.append("daemon.h 缺少 NPC_POWER_D 定義")

# Docker 既有的技能匯入清單必須包含這五個來源檔案。
manifest = ROOT / "scripts/test_es2m_skill_import.py"
if not manifest.is_file():
    errors.append("缺少既有 ES2M 技能匯入清單")
else:
    text = manifest.read_text(encoding="utf-8")
    for name in ("advance_lunmay", "hainmay_force", "lunmay", "mayin", "seven"):
        if name not in text:
            errors.append(f"ES2M 技能匯入清單未納入：{name}")

# 可選 Runtime Gate：只檢查本次 Expansion overlay，不要求 M30 最小 Runtime 匯入全部 42 項技能快照。
if RUNTIME is not None:
    runtime_paths = [
        "std/martial_art.c",
        "std/martial_art.h",
        "feature/char/skill.c",
        "daemon/misc/npc_power.c",
        "std/char/npc.c",
        "include/daemon.h",
        "d/wutang/npc/may_yin_fong.c",
        "d/wutang/crossroad.c",
    ] + [f"daemon/skill/{name}" for name in SKILL_FILES + FROZEN_SKILLS]
    for rel in runtime_paths:
        expected = OVERLAY / rel
        actual = RUNTIME / rel
        if not actual.is_file():
            errors.append(f"生成 Runtime 缺少本輪 Expansion 檔案：{rel}")
        elif expected.is_file() and digest(expected) != digest(actual):
            errors.append(f"生成 Runtime 與 Expansion overlay 不一致：{rel}")

if errors:
    print("ES2M_COLD_PLUM_STATIC_FAIL")
    print("\n".join(errors))
    raise SystemExit(1)

print("ES2M_COLD_PLUM_STATIC_PASS new_skill_source_overlay_sha_match=2 frozen_KING_baseline_match=3 custom_entry_progression=present")
if RUNTIME is not None:
    print(f"ES2M_COLD_PLUM_RUNTIME_OVERLAY_PASS files_checked={8 + len(SKILL_FILES) + len(FROZEN_SKILLS)}")
print("STATUS=STATIC_AND_OPTIONAL_RUNTIME_FILE_INTEGRITY_ONLY; LPC_LOAD_AND_GAMEPLAY_REQUIRE_SEPARATE_GATES")
