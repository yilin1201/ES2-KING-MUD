#!/usr/bin/env python3
"""載入單一 ES2M UI 協定排除清單，供補檔、三方合併與 Overlay 共用。

本清單只阻止指定檔案寫入 KING Runtime；不刪除 ES2M 原始快照或證據。
"""
from __future__ import annotations

import json
from pathlib import Path

CONFIG_PATH = Path(__file__).with_name("es2m_latest_import_exclusions.json")


def load_exclusions() -> dict[str, dict[str, str]]:
    """讀取並驗證唯一的排除設定，避免各匯入路徑各自維護清單。"""
    data = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    batch = data.get("batch")
    items = data.get("excluded")
    if data.get("schema_version") != 1 or not isinstance(batch, str) or not isinstance(items, list):
        raise SystemExit("ES2M_EXCLUSION_CONFIG_FAIL: invalid schema/batch/excluded")
    result: dict[str, dict[str, str]] = {}
    for item in items:
        path = item.get("path")
        reason = item.get("reason")
        if not isinstance(path, str) or not path or not isinstance(reason, str) or not reason:
            raise SystemExit("ES2M_EXCLUSION_CONFIG_FAIL: every exclusion needs path and reason")
        if path in result:
            raise SystemExit(f"ES2M_EXCLUSION_CONFIG_FAIL: duplicate path {path}")
        result[path] = {"batch": batch, "reason": reason}
    return result


ES2M_LATEST_IMPORT_EXCLUSIONS = load_exclusions()
