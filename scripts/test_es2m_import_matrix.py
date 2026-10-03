#!/usr/bin/env python3
"""ES2M 導入差異清單離線一致性檢查；不代表 Runtime／Gameplay PASS。"""
import csv
import re
from collections import Counter, defaultdict
from pathlib import Path

CSV_PATH = Path("docs/migration/ES2M_IMPORT_MATRIX_20261003.csv")
MD_PATH = Path("docs/migration/ES2M_IMPORT_MATRIX_20261003.md")
EXPECTED = {
    "地圖與出口": {"已導入": 163, "部分導入": 41, "未導入": 1, "UNKNOWN": 1},
    "NPC與互動": {"已導入": 70, "部分導入": 75, "未導入": 1, "UNKNOWN": 0},
    "武功及招式": {"已導入": 0, "部分導入": 36, "未導入": 2, "UNKNOWN": 1},
    "武器與裝備": {"已導入": 424, "部分導入": 0, "未導入": 91, "UNKNOWN": 0},
}
VALID_STATUS = {"已導入", "部分導入", "未導入", "UNKNOWN"}
SHA = re.compile(r"^[0-9a-f]{40}$")

with CSV_PATH.open(encoding="utf-8", newline="") as handle:
    rows = list(csv.DictReader(handle))
assert len(rows) == 906, f"ES2M_MATRIX_ROW_COUNT: {len(rows)}"
assert len({row["source_path"] for row in rows}) == len(rows), "ES2M_MATRIX_DUPLICATE_SOURCE_PATH"

counts = defaultdict(Counter)
for row in rows:
    assert row["category"] in EXPECTED, f"ES2M_MATRIX_CATEGORY: {row['category']}"
    assert row["status"] in VALID_STATUS, f"ES2M_MATRIX_STATUS: {row['status']}"
    assert SHA.fullmatch(row["source_sha"]), f"ES2M_MATRIX_SOURCE_SHA: {row['source_path']}"
    assert row["target_path"] == "es2m_snapshot/mudlib/" + row["source_path"]
    if row["status"] == "未導入":
        assert not row["target_sha"], f"ES2M_MATRIX_MISSING_HAS_SHA: {row['source_path']}"
    else:
        assert SHA.fullmatch(row["target_sha"]), f"ES2M_MATRIX_TARGET_SHA: {row['source_path']}"
    if row["status"] == "UNKNOWN":
        assert row["source_sha"] != row["target_sha"]
    counts[row["category"]][row["status"]] += 1

for category, wanted in EXPECTED.items():
    for status, count in wanted.items():
        assert counts[category][status] == count, f"ES2M_MATRIX_COUNT: {category}:{status}"

unknown = {row["source_path"] for row in rows if row["status"] == "UNKNOWN"}
assert unknown == {"d/snow/sgate.c", "daemon/skill/taoism-spells.c"}
document = MD_PATH.read_text(encoding="utf-8")
assert "**657**" in document and "**152**" in document and "**95**" in document and "**2**" in document
assert "不把 Static 結果宣稱為 Runtime 或 Gameplay PASS" in document
print("ES2M_IMPORT_MATRIX_STATIC_PASS rows=906")
