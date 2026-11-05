#!/usr/bin/env python3
"""ES2M enable/disable/abandon 的來源快照與 Expansion 一致性檢查；不取代遊戲內 E2E。"""
from pathlib import Path
import argparse
import hashlib
import sys

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = ROOT / "es2m_snapshot/mudlib/cmds/usr"
OVERLAY = ROOT / "es2_king_expansion/runtime/mudlib/cmds/usr"
parser = argparse.ArgumentParser()
parser.add_argument("--runtime", type=Path, help="可選：已套用 Expansion 的 Runtime 根目錄")
args = parser.parse_args()
RUNTIME = args.runtime / "mudlib/cmds/usr" if args.runtime else None
errors = []

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

# 三個命令必須逐位元保留 ES2M 最新來源，避免來源快照與 Runtime 候選分叉。
for name in ("disable.c", "enable.c", "abandon.c"):
    source, overlay = SNAPSHOT / name, OVERLAY / name
    if not source.is_file() or not overlay.is_file():
        errors.append(f"缺少 ES2M 技能指令來源或 Expansion：{name}")
    elif digest(source) != digest(overlay):
        errors.append(f"來源快照與 Expansion 指令不一致：{name}")

checks = {
    "disable.c": ("query_skill_map", "me->map_skill(arg, \"none\")",
                  "query_skill(arg, 1)", "停止使用所學有關"),
    "enable.c": ("skill_mapped(arg)", "me->map_skill(arg)",
                 "valid_enable(ski)", "恢復使用所學有關"),
    "abandon.c": ("query_learned()", "query_skill_flags()",
                  "SKILL_FLAG_ABANDONED", "abandon_skill(arg, 1)",
                  "恢復學習"),
}
for name, tokens in checks.items():
    path = OVERLAY / name
    if path.is_file():
        text = path.read_text(encoding="utf-8")
        for token in tokens:
            if token not in text:
                errors.append(f"{name} 缺少預期行為：{token}")

if RUNTIME is not None:
    for name in ("disable.c", "enable.c", "abandon.c"):
        source, actual = OVERLAY / name, RUNTIME / name
        if not actual.is_file():
            errors.append(f"生成 Runtime 缺少技能指令：{name}")
        elif digest(source) != digest(actual):
            errors.append(f"生成 Runtime 與 Expansion 指令不一致：{name}")

if errors:
    print("ES2M_SKILL_COMMANDS_FAIL")
    print("\n".join(errors))
    raise SystemExit(1)

print("ES2M_SKILL_COMMANDS_PASS commands=disable,enable,abandon source_overlay_consistent=true")
if RUNTIME is not None:
    print("ES2M_SKILL_COMMANDS_RUNTIME_PASS generated_overlay_files=3")
print("STATUS=STATIC_AND_FILE_INTEGRITY; COMMAND_BEHAVIOR_E2E_REPORTED_SEPARATELY")
