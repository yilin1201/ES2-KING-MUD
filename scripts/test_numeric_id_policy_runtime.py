#!/usr/bin/env python3
"""驗證生成 Runtime 已採用 ES2M 英數帳號與單字顯示名稱政策；僅屬來源契約檢查。"""
from __future__ import annotations

import argparse
import re
from pathlib import Path


def extract_function(source: str, name: str) -> str:
    # 使用真正的正規表示式字元類別，避免把反斜線誤當成來源文字。
    match = re.search(r"\bint\s+" + re.escape(name) + r"\s*\([^)]*\)\s*\{", source)
    if not match:
        raise SystemExit(f"ES2M LOGIN POLICY FAIL：Runtime 找不到 {name}()")
    start = source.find("{", match.start())
    depth = 0
    for i in range(start, len(source)):
        if source[i] == "{":
            depth += 1
        elif source[i] == "}":
            depth -= 1
            if depth == 0:
                return source[start + 1:i]
    raise SystemExit(f"ES2M LOGIN POLICY FAIL：{name}() 大括號不完整")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", required=True, help="已套用 overlays 的 Runtime 根目錄")
    args = parser.parse_args()
    runtime = Path(args.runtime)
    candidates = [
        runtime / "mudlib/adm/daemons/logind.c",
        runtime / "mudlib/adm/daemons/logind.lpc",
    ]
    paths = [path for path in candidates if path.is_file()]
    if len(paths) != 1:
        raise SystemExit(
            "ES2M LOGIN POLICY FAIL：預期唯一一個 Runtime logind.c/.lpc，"
            f"實際找到 {len(paths)} 個"
        )

    source = paths[0].read_text(encoding="utf-8", errors="replace")
    id_body = extract_function(source, "check_legal_id")
    name_body = extract_function(source, "check_legal_name")
    # 去除空白後比對實際條件，確認小寫字母與數字範圍都存在。
    id_compact = re.sub(r"\s+", "", id_body)
    required_id_tokens = ("id[i]>='a'", "id[i]<='z'", "id[i]>='0'", "id[i]<='9'")
    missing = [token for token in required_id_tokens if token not in id_compact]
    if missing:
        raise SystemExit(
            "ES2M LOGIN POLICY FAIL：check_legal_id() 缺少英數驗證條件："
            + ", ".join(missing)
        )
    if not re.search(r"i\s*<\s*3", id_body) or not re.search(r"i\s*>\s*12", id_body):
        raise SystemExit("ES2M LOGIN POLICY FAIL：帳號長度未維持 3–12 字元。")
    if "英文字母或數字" not in id_body:
        raise SystemExit("ES2M LOGIN POLICY FAIL：帳號錯誤訊息未反映 ES2M 英數規則。")

    if not re.search(r"i\s*<\s*1", name_body) or not re.search(r"i\s*>\s*18", name_body):
        raise SystemExit("ES2M LOGIN POLICY FAIL：顯示名稱未允許 1–18 個 UTF-8 字元。")
    if "長度 1 到 18" not in name_body:
        raise SystemExit("ES2M LOGIN POLICY FAIL：顯示名稱錯誤訊息未反映 1–18 字元規則。")

    print(
        "ES2M LOGIN POLICY RUNTIME SOURCE PASS："
        "account=3-12-lowercase-alphanumeric display_name=1-18-UTF8"
    )
    print("提醒：此為生成 Runtime 原始碼契約檢查；數字帳號與單字中文名稱仍須通過實際 E2E。")


if __name__ == "__main__":
    main()
