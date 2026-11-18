#!/usr/bin/env python3
"""Static contract for the ES2M 2026-10-08 safe world delta."""

from pathlib import Path
import ast

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/apply_es2m_20261008_world_delta.py"


def test_script_is_valid_python() -> None:
    ast.parse(SCRIPT.read_text(encoding="utf-8"))


def test_delta_scope_is_restricted() -> None:
    tree = ast.parse(SCRIPT.read_text(encoding="utf-8"))
    configured_paths = {}
    for node in ast.walk(tree):
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id in {"BOARD", "SQUARE", "LEE_INN"}:
                    value = node.value
                    assert isinstance(value, ast.Call) and isinstance(value.func, ast.Name) and value.func.id == "Path"
                    assert len(value.args) == 1
                    configured_paths[target.id] = ast.literal_eval(value.args[0])
    assert configured_paths == {
        "BOARD": "daemon/board/snow_board.c",
        "SQUARE": "d/snow/square_w.c",
        "LEE_INN": "d/lee/inn.c",
    }
    forbidden_paths = ("combatd.c", "feature/char/skill.c", "feature/equip.c",
                       "vendor.c", "websocket", "save_format")
    for path in configured_paths.values():
        assert not any(token in path.lower() for token in forbidden_paths)

if __name__ == "__main__":
    test_script_is_valid_python()
    test_delta_scope_is_restricted()
    print("PASS: ES2M 2026-10-08 world delta contract")
