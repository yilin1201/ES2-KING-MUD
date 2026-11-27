#!/usr/bin/env python3
"""Apply the ES2M 2026-10-08 safe world delta to generated Runtime.

本程式只處理已確認、低衝突的 ES2M 世界資料：
- 雪亭鎮留言板
- 雪亭鎮廣場西側載入留言板
- 李家村小旅店非戰區

安全原則：
1. 新檔不存在才建立；同名不同內容必須符合留言板功能契約，否則 FAIL。
2. 既有房間只做精確字串插入，不做整檔覆蓋。
3. 已套用過的內容視為 PASS / NO-OP。
4. 不修改戰鬥、武功、裝備、Vendor、Save 或 WebSocket 核心。
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


BOARD = Path("daemon/board/snow_board.c")
SQUARE = Path("d/snow/square_w.c")
LEE_INN = Path("d/lee/inn.c")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_file(path: Path) -> str:
    if not path.is_file():
        raise SystemExit(f"ES2M_WORLD_DELTA_MISSING_RUNTIME: {path}")
    return path.read_text(encoding="utf-8")


def board_is_compatible(path: Path) -> bool:
    if not path.is_file():
        return False
    code = path.read_text(encoding="utf-8")
    required = (
        "inherit BULLETIN_BOARD;",
        'set_name("雪亭鎮留言板"',
        'set("location", "/d/snow/square_w");',
        'set("board_id", "snow");',
        'set("capacity", 100);',
        'query_id() { return "Snow Town Board"; }',
    )
    return all(token in code for token in required)


def write_if_missing(dst: Path, src: Path, result: dict) -> None:
    if dst.is_file():
        if digest(dst) == digest(src):
            result["identical"].append(str(dst))
        elif board_is_compatible(dst):
            # Runtime 已有同功能留言板；保留現有版本，不用僅註解／排版差異覆蓋。
            result["compatible_existing"].append(str(dst))
        else:
            raise SystemExit(f"ES2M_WORLD_DELTA_CONFLICT: {dst}")
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(src.read_bytes())
    result["created"].append(str(dst))


def patch_once(code: str, needle: str, replacement: str, path: Path, result: dict) -> str:
    if replacement in code:
        result["already_applied"].append(str(path))
        return code
    if needle not in code:
        raise SystemExit(f"ES2M_WORLD_DELTA_ANCHOR_MISSING: {path}")
    if code.count(needle) != 1:
        raise SystemExit(f"ES2M_WORLD_DELTA_ANCHOR_AMBIGUOUS: {path}")
    result["patched"].append(str(path))
    return code.replace(needle, replacement, 1)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--overlay", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    args = parser.parse_args()

    overlay = args.overlay.resolve()
    runtime = args.runtime.resolve()

    result = {
        "status": "STATIC_RUNTIME_OVERLAY_APPLIED",
        "created": [],
        "identical": [],
        "patched": [],
        "already_applied": [],
        "compatible_existing": [],
    }

    board_src = overlay / BOARD
    square_src = overlay / SQUARE
    lee_src = overlay / LEE_INN

    for src in (board_src, square_src, lee_src):
        if not src.is_file():
            raise SystemExit(f"ES2M_WORLD_DELTA_MISSING_OVERLAY: {src}")

    write_if_missing(runtime / BOARD, board_src, result)

    square = runtime / SQUARE
    code = require_file(square)
    if 'load_object("/daemon/board/snow_board")' in code:
        result["already_applied"].append(str(square))
    else:
        code = patch_once(
            code,
            '    // load_object("/daemon/board/common");',
            '    load_object("/daemon/board/snow_board");   // ES2M 2026-10-08 雪亭鎮留言板',
            square,
            result,
        )
        square.write_text(code, encoding="utf-8")

    lee = runtime / LEE_INN
    code = require_file(lee)
    if 'set("no_fight", 1);' in code:
        result["already_applied"].append(str(lee))
    else:
        code = patch_once(
            code,
            '    setup();',
            '    set("no_fight", 1);   // ES2M 2026-10-08：李家村小旅店為非戰區。\n    setup();',
            lee,
            result,
        )
        lee.write_text(code, encoding="utf-8")

    print("ES2M_WORLD_DELTA", result)


if __name__ == "__main__":
    main()
