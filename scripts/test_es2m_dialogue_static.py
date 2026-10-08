#!/usr/bin/env python3
"""Static contract for the V13 Original ES2 NPC dialogue interface."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASK = ROOT / "source/es2m_updates/20261008_v13/runtime_overlay/mudlib/cmds/std/ask.c"

if not ASK.is_file():
    raise SystemExit(f"ES2_DIALOGUE_STATIC_FAIL: missing {ASK}")

ask = ASK.read_text(encoding="utf-8")

# V13 必須保持 Original ES2 ask.c 的 NPC callback 介面，不自行重建缺失的 daemon。
for term in (
    'sscanf(arg, "%s about %s"',
    'target->accept_inquiry(me, key);',
    'sscanf(arg, "%s for %s"',
    'target->accept_negotiation(me, key);',
    'target->query("no_fight")',
    'rank("respectful")',
):
    if term not in ask:
        raise SystemExit(f"ES2_DIALOGUE_STATIC_FAIL: ask missing {term}")

if 'query("inquiry")' in ask or "INQUIRY_D" in ask:
    raise SystemExit("ES2_DIALOGUE_STATIC_FAIL: unverified inquiry daemon coupling detected")

print("ES2 DIALOGUE STATIC PASS / Original ask + NPC callback contract preserved.")
