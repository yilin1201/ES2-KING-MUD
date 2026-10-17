#!/usr/bin/env python3
"""Apply the pinned ES2M login/name policy to generated KING Runtime only.

此適配器只修改建置產生的 Runtime，不改寫 Original ES2 保存來源。
政策依據 wolfer168/es2-webmud@71693beb：帳號 3–12 位小寫英文字母／數字；
顯示名稱 1–18 個合法 UTF-8 字元。
"""
from __future__ import annotations

import argparse
from pathlib import Path

ID_MARKER = "ES2M LOGIN POLICY ID／帳號允許英數字"
NAME_MARKER = "ES2M LOGIN POLICY DISPLAY NAME／顯示名稱允許單字"
ID_LENGTH_ORIGINAL = 'write ("您的使用者代號必須是 3 到 12 個英文字母。\\n");'
ID_LENGTH_ES2M = 'write ("您的使用者代號必須是 3 到 12 個英文字母或數字。\\n");'
ID_CHAR_ORIGINAL = "if ((id[i]<'a') || (id[i]>'z')) {"
ID_CHAR_ES2M = "if (!(((id[i]>='a') && (id[i]<='z')) || ((id[i]>='0') && (id[i]<='9')))) {"
ID_ERROR_ORIGINAL = 'write("您的使用者代號只能由 a 到 z 的英文字母組成。\\n");'
ID_ERROR_ES2M = 'write("您的使用者代號只能由 a 到 z 的英文字母或 0 到 9 的數字組成。\\n");'
NAME_CONDITION_ORIGINAL = "if ((i < 3) || (i > 18 )) {"
NAME_CONDITION_ES2M = "if ((i < 1) || (i > 18 )) {"
NAME_ERROR_ORIGINAL = 'write("您的顯示名稱必須使用長度 3 到 18 的合法 UTF-8 文字。\\n");'
NAME_ERROR_ES2M = 'write("您的顯示名稱必須使用長度 1 到 18 的合法 UTF-8 文字。\\n");'


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"ES2M_LOGIN_POLICY_FAIL: expected one {label} anchor, found {count}")
    return text.replace(old, new, 1)


def locate_logind(runtime: Path) -> Path:
    found = [runtime / "adm" / "daemons" / f"logind{suffix}" for suffix in (".c", ".lpc")
             if (runtime / "adm" / "daemons" / f"logind{suffix}").is_file()]
    if len(found) != 1:
        raise SystemExit(f"ES2M_LOGIN_POLICY_FAIL: expected exactly one logind.c/.lpc, found {len(found)}")
    return found[0]


def apply(text: str) -> str:
    if ID_MARKER not in text:
        text = replace_once(text, ID_LENGTH_ORIGINAL, ID_LENGTH_ES2M, "account length message")
        text = replace_once(text, ID_CHAR_ORIGINAL, ID_CHAR_ES2M, "account character rule")
        text = replace_once(text, ID_ERROR_ORIGINAL, ID_ERROR_ES2M, "account character message")
        text = text.replace(ID_LENGTH_ES2M, "// " + ID_MARKER + "\n    " + ID_LENGTH_ES2M, 1)
    if NAME_MARKER not in text:
        text = replace_once(text, NAME_CONDITION_ORIGINAL, NAME_CONDITION_ES2M, "display-name length rule")
        text = replace_once(text, NAME_ERROR_ORIGINAL, NAME_ERROR_ES2M, "display-name length message")
        text = text.replace(NAME_CONDITION_ES2M, "// " + NAME_MARKER + "\n    " + NAME_CONDITION_ES2M, 1)

    required = (ID_MARKER, NAME_MARKER, ID_CHAR_ES2M, ID_ERROR_ES2M, NAME_CONDITION_ES2M, NAME_ERROR_ES2M)
    missing = [marker for marker in required if marker not in text]
    if missing:
        raise SystemExit("ES2M_LOGIN_POLICY_FAIL: postcondition missing: " + ", ".join(missing))
    return text


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", type=Path, required=True, help="Generated Runtime mudlib root")
    args = parser.parse_args()
    runtime = args.runtime.resolve()
    if not runtime.is_dir():
        raise SystemExit(f"ES2M_LOGIN_POLICY_FAIL: runtime directory missing: {runtime}")
    path = locate_logind(runtime)
    before = path.read_text(encoding="utf-8")
    after = apply(before)
    if after != before:
        path.write_text(after, encoding="utf-8")
        print(f"ES2M_LOGIN_POLICY_APPLIED: {path}")
    else:
        print(f"ES2M_LOGIN_POLICY_ALREADY_APPLIED: {path}")
    print("ES2M_LOGIN_POLICY_RUNTIME_PASS: account=3-12-lowercase-alphanumeric display_name=1-18-UTF8")


if __name__ == "__main__":
    main()
