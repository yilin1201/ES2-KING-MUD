#!/usr/bin/env python3
"""ES2M 冷梅莊武學隔離整合的靜態完整性閘門；不代表 LPC 編譯或實機玩法通過。"""
from pathlib import Path
import hashlib
import sys

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = ROOT / "es2m_snapshot/mudlib"
OVERLAY = ROOT / "es2_king_expansion/runtime/mudlib"
SKILL_FILES = (
    "lunmay.c",
    "hainmay_force.c",
    "advance_lunmay.c",
    "mayin.c",
    "seven.c",
)

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
                  "restored_skill_level_threshold", "skill_completed",
                  '"lunmay"', '"hainmay force"', '"advance_lunmay"', '"mayin"', '"seven"'):
        if token not in text:
            errors.append(f"KING 技能成長整合缺少必要保護或介面：{token}")

# Docker 既有的技能匯入清單必須包含這五個來源檔案。
manifest = ROOT / "scripts/test_es2m_skill_import.py"
if not manifest.is_file():
    errors.append("缺少既有 ES2M 技能匯入清單")
else:
    text = manifest.read_text(encoding="utf-8")
    for name in ("advance_lunmay", "hainmay_force", "lunmay", "mayin", "seven"):
        if name not in text:
            errors.append(f"ES2M 技能匯入清單未納入：{name}")

if errors:
    print("ES2M_COLD_PLUM_STATIC_FAIL")
    print("\n".join(errors))
    raise SystemExit(1)

print("ES2M_COLD_PLUM_STATIC_PASS source_overlay_sha_match=5 custom_entry_progression=present")
print("STATUS=STATIC_ONLY; LPC_COMPILE_AND_GAMEPLAY_NOT_CLAIMED")
