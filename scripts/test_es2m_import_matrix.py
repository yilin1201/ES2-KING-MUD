#!/usr/bin/env python3
"""ES2M 導入差異清單離線一致性檢查；不代表 Runtime／Gameplay PASS。"""
import csv
import re
from collections import Counter, defaultdict
from pathlib import Path

CSV_PATH = Path("docs/migration/ES2M_IMPORT_MATRIX_20261003.csv")
MD_PATH = Path("docs/migration/ES2M_IMPORT_MATRIX_20261003.md")
EXPECTED = {
    "地圖與出口": {"已導入": 164, "部分導入": 42, "未導入": 0, "UNKNOWN": 0},
    "NPC與互動": {"已導入": 70, "部分導入": 76, "未導入": 0, "UNKNOWN": 0},
    "武功及招式": {"已導入": 0, "部分導入": 38, "未導入": 0, "UNKNOWN": 1},
    "武器與裝備": {"已導入": 515, "部分導入": 0, "未導入": 0, "UNKNOWN": 0},
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
    expected_target = "es2m_snapshot/mudlib/" + row["source_path"]
    # 完全同 SHA 的來源別名可指向已保存的標準位置，避免複製缺依賴的 custom 路徑。
    if row["target_path"] != expected_target:
        assert row["source_path"] == "custom/wizroom/w/windstory/npc/gammer.c"
        assert row["target_path"] == "es2m_snapshot/mudlib/d/snow/npc/gammer.c"
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
assert unknown == {"daemon/skill/taoism-spells.c"}
document = MD_PATH.read_text(encoding="utf-8")
assert "**749**" in document and "**156**" in document and "**0**" in document and "**1**" in document
assert "不把 Static 結果宣稱為 Runtime 或 Gameplay PASS" in document
print("ES2M_IMPORT_MATRIX_STATIC_PASS rows=906")
