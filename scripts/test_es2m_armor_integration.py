#!/usr/bin/env python3
"""91 件新增防具的結構、限制、依賴與引用檢查；不模擬 LPC Runtime。"""
import csv
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MUDLIB = ROOT / "es2m_snapshot/mudlib"
MATRIX = ROOT / "docs/migration/ES2M_IMPORT_MATRIX_20261003.csv"

with MATRIX.open(encoding="utf-8", newline="") as handle:
    rows = [
        row for row in csv.DictReader(handle)
        if row["note"].startswith("來源SHA一致；custom overlay")
        and "/armor/" in row["source_path"]
    ]
assert len(rows) == 91, f"ES2M_ARMOR_BATCH_COUNT: {len(rows)}"

expected_slots = {"hand": 17, "head": 28, "leg": 9, "neck": 15, "waist": 22}
slots = Counter(row["source_path"].split("/")[2] for row in rows)
assert slots == expected_slots, f"ES2M_ARMOR_BATCH_SLOTS: {slots}"

names = []
primary_ids = []
texts = {}
for row in rows:
    rel = row["source_path"]
    text = (MUDLIB / rel).read_text(encoding="utf-8")
    texts[rel] = text
    part = rel.split("/")[2]
    match = re.search(r'set_name\("([^"]+)"\s*,\s*\(\{\s*"([^"]+)"', text, re.S)
    assert match, f"ES2M_ARMOR_NAME_OR_ID: {rel}"
    names.append(match.group(1))
    primary_ids.append(match.group(2))
    assert 'set("unit",' in text, f"ES2M_ARMOR_UNIT: {rel}"
    assert 'set("value",' in text, f"ES2M_ARMOR_VALUE: {rel}"
    assert 'set("long",' in text, f"ES2M_ARMOR_LONG: {rel}"
    assert f'set("wear_as", "{part}_eq")' in text, f"ES2M_ARMOR_WEAR_AS: {rel}"
    assert f'set("apply_armor/{part}_eq",' in text, f"ES2M_ARMOR_APPLY: {rel}"
    for forbidden in ('set("no_save"', 'set("autoload"', 'set("prevent_save"'):
        assert forbidden not in text, f"ES2M_ARMOR_SAVE_OPTOUT: {rel}"

assert len(set(names)) == 91, "ES2M_ARMOR_DUPLICATE_DISPLAY_NAME"
assert len(set(primary_ids)) == 91, "ES2M_ARMOR_DUPLICATE_PRIMARY_ID"

restrictions = {
    "custom/armor/hand/dark_bracers.c": ('query_class() != "thief"',),
    "custom/armor/hand/royal_gloves.c": ('query_class() != "soldier"',),
    "custom/armor/hand/yenhold_gauntlets.c": ('query_race() != "yenhold"',),
    "custom/armor/head/royal_helmet.c": ('query_class() != "soldier"',),
    "custom/armor/leg/dingling_legs.c": ('query_race() != "dingling"',),
    "custom/armor/neck/dark_necklace.c": ('query_class() != "thief"',),
    "custom/armor/neck/malik_necklace.c": ('query_race() != "malik"',),
    "custom/armor/waist/girdle_of_headless.c": ('query_race() != "headless"',),
    "custom/armor/waist/girdle_of_mighty_lord.c": ('query_class() != "soldier"',),
}
actual_restrictions = {rel for rel, text in texts.items() if "varargs int wear" in text}
assert actual_restrictions == set(restrictions), f"ES2M_ARMOR_RESTRICTIONS: {actual_restrictions}"
for rel, needles in restrictions.items():
    assert all(needle in texts[rel] for needle in needles)
    assert "return ::wear(on_part);" in texts[rel]

unique_files = {rel for rel, text in texts.items() if "F_UNIQUE" in text}
assert unique_files == {
    "custom/armor/head/lion_helmet.c",
    "custom/armor/neck/tiger_necklace.c",
    "custom/armor/waist/white_girth.c",
}
specials = {rel for rel, text in texts.items() if "void init()" in text}
assert specials == {"custom/armor/hand/corrosive_hands.c"}
corrosive = texts["custom/armor/hand/corrosive_hands.c"]
for evidence in ('add_action("do_corrupt", "corrupt")', 'new("/obj/money/silver")',
                 'query("player_corpse")', 'query("equipped")'):
    assert evidence in corrosive
assert (MUDLIB / "obj/money/silver.c").is_file()

# 只計算其他物件對這 91 個完整絕對路徑的直接引用；0 表示取得途徑仍無證據。
all_other_sources = []
batch_paths = {MUDLIB / row["source_path"] for row in rows}
for source in MUDLIB.rglob("*.c"):
    if source not in batch_paths:
        all_other_sources.append(source.read_text(encoding="utf-8", errors="replace"))
haystack = "\n".join(all_other_sources)
direct_refs = [row["source_path"] for row in rows if f'/{row["source_path"][:-2]}' in haystack]
assert not direct_refs, f"ES2M_ARMOR_UNEXPECTED_ACQUISITION_REFS: {direct_refs}"

print(
    "ES2M_ARMOR_INTEGRATION_STATIC_PASS imported=91 names=91 ids=91 "
    "restrictions=9 unique=3 special=1 acquisition_refs=0 persistence=UNKNOWN"
)
