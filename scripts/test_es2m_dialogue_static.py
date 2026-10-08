#!/usr/bin/env python3
"""Static contract for the V13 ES2M NPC dialogue reconstruction."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASK = ROOT / "source/es2m_updates/20261008_v13/runtime_overlay/mudlib/cmds/std/ask.c"
INQUIRYD = ROOT / "source/es2m_updates/20261008_v13/runtime_overlay/mudlib/adm/daemons/inquiryd.c"
VILLAGER = ROOT / "es2m_snapshot/mudlib/feature/npc/villager.c"
SNOW_SMITH = ROOT / "es2m_snapshot/mudlib/d/snow/npc/smith.c"

for path in (ASK, INQUIRYD, VILLAGER, SNOW_SMITH):
    if not path.is_file():
        raise SystemExit(f"ES2M_DIALOGUE_STATIC_FAIL: missing {path}")

ask = ASK.read_text(encoding="utf-8")
inquiryd = INQUIRYD.read_text(encoding="utf-8")
villager = VILLAGER.read_text(encoding="utf-8")
smith = SNOW_SMITH.read_text(encoding="utf-8")

for term in (
    '#define INQUIRY_D "/adm/daemons/inquiryd"',
    'query("inquiry")',
    'parse_inquiry(me, ob, topic)',
    'ask <someone> about <something>',
):
    if term not in ask:
        raise SystemExit(f"ES2M_DIALOGUE_STATIC_FAIL: ask missing {term}")

for term in (
    'int parse_inquiry(object me, object ob, string topic)',
    '"名字"', '"這裡"', '"傳聞"',
):
    if term not in inquiryd:
        raise SystemExit(f"ES2M_DIALOGUE_STATIC_FAIL: inquiryd missing {term}")

if "do_chat" not in villager:
    raise SystemExit("ES2M_DIALOGUE_STATIC_FAIL: existing NPC chat hook missing")
if 'set("chat_chance"' not in smith:
    raise SystemExit("ES2M_DIALOGUE_STATIC_FAIL: existing Snow NPC chat evidence missing")

print("ES2M DIALOGUE STATIC PASS／ask + inquiryd + existing NPC chat hooks preserved.")
