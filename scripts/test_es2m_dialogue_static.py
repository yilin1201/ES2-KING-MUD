#!/usr/bin/env python3
"""V13 ES2M NPC dialogue static evidence gate."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASK = ROOT / "source/es2m_updates/20261008_v13/runtime_overlay/mudlib/cmds/std/ask.c"
INQUIRYD = ROOT / "source/es2m_updates/20261008_v13/runtime_overlay/mudlib/adm/daemons/inquiryd.c"

if not ASK.is_file() or not INQUIRYD.is_file():
    raise SystemExit("ES2_DIALOGUE_STATIC_FAIL: V13 dialogue evidence files missing")

ask = ASK.read_text(encoding="utf-8")
daemon = INQUIRYD.read_text(encoding="utf-8")

# V13 同時保存兩條已取得來源證據的 ES2 lineage：
# taedlar Original ask.c 的 NPC callback，以及 ES2M/Annihilator 1995 inquiry daemon。
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

for term in (
    "int parse_inquiry(object me, object ob, string topic)",
    'case "name":',
    'case "here":',
    'case "rumors":',
    'return 0;',
):
    if term not in daemon:
        raise SystemExit(f"ES2_DIALOGUE_STATIC_FAIL: inquiryd missing {term}")

print("ES2 DIALOGUE STATIC PASS / verified ask callback + 1995 inquiryd evidence present.")
