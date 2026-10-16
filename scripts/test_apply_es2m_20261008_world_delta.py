#!/usr/bin/env python3
"""Static contract for the ES2M 2026-10-08 safe world delta."""

from pathlib import Path
import ast

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/apply_es2m_20261008_world_delta.py"


def executable_source_without_module_docstring(source: str) -> str:
    """Keep executable source in the scope check; explanatory module docs are not code."""
    tree = ast.parse(source)
    if not tree.body:
        return source
    first = tree.body[0]
    if (
        isinstance(first, ast.Expr)
        and isinstance(first.value, (ast.Str, ast.Constant))
        and isinstance(getattr(first.value, "value", None), str)
    ):
        lines = source.splitlines(keepends=True)
        start = first.lineno - 1
        end = first.end_lineno
        # Preserve line numbers while excluding the module docstring from token checks.
        lines[start:end] = ["\n" if line.endswith("\n") else "" for line in lines[start:end]]
        return "".join(lines)
    return source


def test_script_is_valid_python() -> None:
    ast.parse(SCRIPT.read_text(encoding="utf-8"))


def test_delta_scope_is_restricted() -> None:
    source = SCRIPT.read_text(encoding="utf-8")
    ast.parse(source)
    # Scope restrictions apply to executable code, not a docstring that describes
    # what the script intentionally does not modify (e.g. "WebSocket core").
    code = executable_source_without_module_docstring(source).lower()
    for token in ("snow_board.c", "square_w.c", "d/lee/inn.c"):
        assert token in code
    for forbidden in ("combatd.c", "feature/char/skill.c", "feature/equip.c",
                      "vendor.c", "websocket", "save_format"):
        assert forbidden not in code, f"forbidden scope token in executable source: {forbidden}"


if __name__ == "__main__":
    test_script_is_valid_python()
    test_delta_scope_is_restricted()
    print("PASS: ES2M 2026-10-08 world delta contract")
