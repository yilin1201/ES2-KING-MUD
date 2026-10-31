#!/usr/bin/env python3
"""剩餘 ES2M 地圖、NPC 與技能證據的離線閘門；不代表 Runtime PASS。"""
import csv
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MUDLIB = ROOT / "es2m_snapshot/mudlib"
MATRIX = ROOT / "docs/migration/ES2M_IMPORT_MATRIX_20261003.csv"
REPORT = ROOT / "docs/architecture/ES2M_REMAINING_IMPORT_AND_ARMOR_VALIDATION_20261003.md"


def blob_sha(path: Path) -> str:
    data = path.read_bytes()
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


with MATRIX.open(encoding="utf-8", newline="") as handle:
    rows = {row["source_path"]: row for row in csv.DictReader(handle)}

bug = rows["d/snow/bug_room.c"]
bug_path = MUDLIB / "d/snow/bug_room.c"
assert bug["status"] == "部分導入"
assert blob_sha(bug_path) == bug["source_sha"] == bug["target_sha"]
bug_text = bug_path.read_text(encoding="utf-8")
assert '"south" : "/d/snow/square_w"' in bug_text
assert 'set("no_fight", 1)' in bug_text
assert 'load_object("/daemon/board/bug_board")' in bug_text
assert 'set("map/area", "雪亭鎮")' in bug_text
square_w = (MUDLIB / "d/snow/square_w.c").read_text(encoding="utf-8")
assert '"north" : __DIR__"bug_room"' in square_w

custom_gammer = rows["custom/wizroom/w/windstory/npc/gammer.c"]
snow_gammer = MUDLIB / "d/snow/npc/gammer.c"
assert custom_gammer["status"] == "部分導入"
assert custom_gammer["target_path"] == "es2m_snapshot/mudlib/d/snow/npc/gammer.c"
assert blob_sha(snow_gammer) == custom_gammer["source_sha"] == custom_gammer["target_sha"]
gammer_text = snow_gammer.read_text(encoding="utf-8")
for evidence in (
    'set_class("thief")', 'query_temp("try/fon")', 'id("annatto comb")',
    '__DIR__"obj/cane"', '__DIR__"obj/syndicator"', '__DIR__"obj/coin"',
):
    assert evidence in gammer_text
for dependency in ("cane.c", "syndicator.c", "coin.c"):
    assert (MUDLIB / "d/snow/npc/obj" / dependency).is_file()
assert not (MUDLIB / "custom/wizroom/w/windstory/npc/gammer.c").exists()

for source_path in ("daemon/skill/beast.c", "obj/example/skill/fonxansword.c"):
    assert rows[source_path]["status"] == "部分導入"
taoism = rows["daemon/skill/taoism-spells.c"]
assert taoism["status"] == "UNKNOWN"
assert "2026-09-23" in taoism["note"] and "2026-10-01" in taoism["note"]
assert "Claude" in taoism["note"] and "Original無此檔" in taoism["note"]

report = REPORT.read_text(encoding="utf-8")
for sha in (
    "cc45c06af4852380e5148dad3c9d53ff06854f2c",
    "e5365ba025135b3bc06e60b074ee6d54e3a1b202",
    "a2f0fad4be6986c13f2451840007750d855d0258",
    "ddf49aafa94a65e760797e0a6210c0b7fa595edf",
):
    assert sha in report

print("ES2M_REMAINING_IMPORT_STATIC_PASS bug_room=1 gammer_dedup=1 partial_skills=2 unknown=1")
