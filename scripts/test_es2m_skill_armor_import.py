#!/usr/bin/env python3
"""本批 ES2M 技能、防具與雪亭出口的離線證據閘門；不代表 Gameplay PASS。"""
import csv
import hashlib
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MUDLIB = ROOT / "es2m_snapshot/mudlib"
MATRIX = ROOT / "docs/migration/ES2M_IMPORT_MATRIX_20261003.csv"


def blob_sha(path: Path) -> str:
    """計算 Git blob SHA，讓保存檔可直接與來源清冊比對。"""
    data = path.read_bytes()
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


with MATRIX.open(encoding="utf-8", newline="") as handle:
    rows = list(csv.DictReader(handle))
by_path = {row["source_path"]: row for row in rows}

armor_rows = [
    row for row in rows
    if row["category"] == "武器與裝備"
    and any(f"custom/armor/{part}/" in row["source_path"]
            for part in ("hand", "head", "leg", "neck", "waist"))
]
new_armor_rows = [row for row in armor_rows if row["note"].startswith("來源SHA一致；custom overlay")]
assert len(new_armor_rows) == 91, f"ES2M_ARMOR_IMPORTED_COUNT: {len(new_armor_rows)}"
expected_parts = {"hand": 25, "head": 31, "leg": 9, "neck": 16, "waist": 23}
actual_parts = Counter(row["source_path"].split("/")[2] for row in armor_rows)
assert actual_parts == expected_parts, f"ES2M_ARMOR_PART_COUNTS: {actual_parts}"

seen_blobs = defaultdict(list)
inherit_for = {
    "hand": "F_HAND_EQ", "head": "F_HEAD_EQ", "leg": "F_LEG_EQ",
    "neck": "F_NECK_EQ", "waist": "F_WAIST_EQ",
}
absolute_refs = Counter()
for row in armor_rows:
    rel = row["source_path"]
    path = MUDLIB / rel
    assert path.is_file(), f"ES2M_ARMOR_MISSING: {rel}"
    sha = blob_sha(path)
    assert sha == row["source_sha"] == row["target_sha"], f"ES2M_ARMOR_SHA: {rel}"
    assert row["status"] == "已導入", f"ES2M_ARMOR_STATUS: {rel}"
    seen_blobs[sha].append(rel)
    text = path.read_text(encoding="utf-8")
    part = rel.split("/")[2]
    assert "#include <ansi.h>" in text and "#include <armor.h>" in text
    assert f"inherit {inherit_for[part]};" in text, f"ES2M_ARMOR_INHERIT: {rel}"
    absolute_refs.update(re.findall(r'"(/[^"\n]+)"', text))

duplicates = [paths for paths in seen_blobs.values() if len(paths) > 1]
assert not duplicates, f"ES2M_ARMOR_DUPLICATE_CONTENT: {duplicates}"
assert set(absolute_refs) <= {"/obj/money/silver"}, f"ES2M_ARMOR_DEPENDENCY: {absolute_refs}"
assert (MUDLIB / "obj/money/silver.c").is_file(), "ES2M_ARMOR_SILVER_DEPENDENCY"
for feature in ("hand_eq", "head_eq", "leg_eq", "neck_eq", "waist_eq"):
    assert (MUDLIB / f"feature/armor/{feature}.c").is_file(), f"ES2M_ARMOR_FEATURE: {feature}"
assert (MUDLIB / "feature/unique.c").is_file(), "ES2M_ARMOR_UNIQUE_FEATURE"

beast = MUDLIB / "daemon/skill/beast.c"
beast_row = by_path["daemon/skill/beast.c"]
assert blob_sha(beast) == beast_row["source_sha"] == beast_row["target_sha"]
assert beast_row["status"] == "部分導入"
beast_text = beast.read_text(encoding="utf-8")
assert 'register_skill_daemon("beast")' in beast_text
assert 'return usage == "unarmed"' in beast_text
assert 'RACE_D(me->query_race())->query_action(me)' in beast_text

example = MUDLIB / "obj/example/skill/fonxansword.c"
example_row = by_path["obj/example/skill/fonxansword.c"]
assert blob_sha(example) == example_row["source_sha"] == example_row["target_sha"]
assert example_row["status"] == "部分導入"
example_text = example.read_text(encoding="utf-8")
assert 'register_skill_daemon("fonxansword")' in example_text
assert 'return usage=="sword" || usage=="parry"' in example_text
# 原始範例含 damae 拼字；保存層必須原樣保留，不為了測試而改寫證據。
assert '"damae"' in example_text

sgate = MUDLIB / "d/snow/sgate.c"
sgate_row = by_path["d/snow/sgate.c"]
assert blob_sha(sgate) == sgate_row["source_sha"] == sgate_row["target_sha"]
assert sgate_row["status"] == "已導入"
sgate_text = sgate.read_text(encoding="utf-8")
assert '"west" : "/custom/zhenwu/room/gate"' in sgate_text
assert '"southeast" : "/d/oldpine/entrance"' in sgate_text

unknown = [row for row in rows if row["status"] == "UNKNOWN"]
assert [row["source_path"] for row in unknown] == ["daemon/skill/taoism-spells.c"]
assert "傷害公式" in unknown[0]["note"] and "維持 UNKNOWN" in unknown[0]["note"]

print(
    "ES2M_SKILL_ARMOR_IMPORT_STATIC_PASS "
    f"armor_imported={len(new_armor_rows)} armor_total={len(armor_rows)} "
    "beast=1 fonxansword=1 sgate=1 unknown=1"
)
