#!/usr/bin/env python3
"""檢查生成 Runtime 的 logind.c 實際帳號驗證規則；不是比對 E2E 測試文字。"""
from __future__ import annotations
import argparse
import re
from pathlib import Path

def extract_function(source: str, name: str) -> str:
    match = re.search(r"\\bint\\s+" + re.escape(name) + r"\\s*\\([^)]*\\)\\s*\\{", source)
    if not match:
        raise SystemExit(f"NUMERIC ID POLICY FAIL：Runtime 找不到 {name}()")
    start = source.find("{", match.start())
    depth = 0
    for i in range(start, len(source)):
        if source[i] == "{":
            depth += 1
        elif source[i] == "}":
            depth -= 1
            if depth == 0:
                return source[start + 1:i]
    raise SystemExit(f"NUMERIC ID POLICY FAIL：{name}() 大括號不完整")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime", required=True, help="已套用 overlays 的 Runtime 根目錄")
    args = parser.parse_args()
    path = Path(args.runtime) / "mudlib/adm/daemons/logind.c"
    if not path.is_file():
        raise SystemExit(f"NUMERIC ID POLICY FAIL：Runtime 缺少 {path}")
    body = extract_function(path.read_text(encoding="utf-8", errors="replace"), "check_legal_id")
    # KING 當前政策：帳號只接受英文字母；任何數字都不應被合法字元條件接受。
    accepts_digits = bool(re.search(r"id\\s*\\[[^]]+\\]\\s*>?=??\\s*['\"]0['\"].{0,160}?id\\s*\\[[^]]+\\]\\s*< =?\\s*['\"]9['\"]", body, re.S))
    mentions_digit_range = bool(re.search(r"['\"]0['\"].{0,200}?['\"]9['\"]", body, re.S))
    letters_only_message = "只能由 a 到 z 的英文字母組成" in body
    if accepts_digits or (mentions_digit_range and not letters_only_message):
        raise SystemExit("NUMERIC ID POLICY FAIL：生成 Runtime 的 check_legal_id() 看起來接受數字；與目前 KING「拒絕數字帳號」政策不一致。")
    if not letters_only_message:
        raise SystemExit("NUMERIC ID POLICY FAIL：Runtime 未呈現明確的英文字母限定規則，需人工審查 check_legal_id()。")
    print("NUMERIC ID POLICY RUNTIME SOURCE PASS：生成 Runtime 的 check_legal_id() 限定英文字母；E2E 仍須驗證實際拒絕數字帳號。")

if __name__ == "__main__":
    main()
