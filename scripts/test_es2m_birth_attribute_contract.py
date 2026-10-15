#!/usr/bin/env python3
"""Verify the E2E birth-attribute ranges exactly match the vendored ES2M race daemons.

This is a static source-contract test only; it does not prove LPC runtime behavior.
Run from repository root:
  python3 scripts/test_es2m_birth_attribute_contract.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RACE_DIR = ROOT / "es2m_snapshot/mudlib/daemon/race"
E2E = ROOT / "scripts/test_original_player_creation_e2e.mjs"
RACES = (
    "human", "avatar", "blackteeth", "yenhold", "woochan", "dingling",
    "jiaojao", "rainner", "ashura", "headless", "yaksa", "malik",
)
ATTRIBUTES = ("str", "cor", "int", "spi", "cps", "dex", "con", "wis")


def fail(message: str) -> None:
    print(f"ES2M_BIRTH_ATTRIBUTE_CONTRACT_FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def source_ranges(race: str) -> dict[str, tuple[int, int]]:
    path = RACE_DIR / f"{race}.c"
    if not path.is_file():
        fail(f"missing race source: {path.relative_to(ROOT)}")
    source = path.read_text(encoding="utf-8")
    init = re.search(r"init_attribute\s*\(\s*\(\s*\[(.*?)\]\s*\)\s*\)", source, re.S)
    if not init:
        fail(f"{race}: cannot locate init_attribute mapping")
    result = {}
    for attr, base, span in re.findall(
        r'"(str|cor|int|spi|cps|dex|con|wis)"\s*:\s*(\d+)\s*\+\s*random\s*\(\s*(\d+)\s*\)',
        init.group(1),
    ):
        result[attr] = (int(base), int(base) + int(span) - 1)
    if set(result) != set(ATTRIBUTES):
        fail(f"{race}: source attributes found {sorted(result)}, expected {sorted(ATTRIBUTES)}")
    return result


def expected_ranges(script: str, race: str) -> dict[str, tuple[int, int]]:
    block = re.search(rf"\b{re.escape(race)}\s*:\s*\{{([^}}]*)\}}", script, re.S)
    if not block:
        fail(f"E2E birthRanges is missing race {race}")
    result = {
        attr: (int(low), int(high))
        for attr, low, high in re.findall(
            r"\b(str|cor|int|spi|cps|dex|con|wis)\s*:\s*\[\s*(\d+)\s*,\s*(\d+)\s*\]",
            block.group(1),
        )
    }
    if set(result) != set(ATTRIBUTES):
        fail(f"{race}: E2E attributes found {sorted(result)}, expected {sorted(ATTRIBUTES)}")
    return result


def main() -> None:
    script = E2E.read_text(encoding="utf-8")
    errors = []
    for race in RACES:
        actual = source_ranges(race)
        expected = expected_ranges(script, race)
        for attr in ATTRIBUTES:
            if actual[attr] != expected[attr]:
                errors.append(
                    f"{race}.{attr}: source={actual[attr][0]}..{actual[attr][1]}, "
                    f"E2E={expected[attr][0]}..{expected[attr][1]}"
                )
    if errors:
        for error in errors:
            print(f"MISMATCH: {error}", file=sys.stderr)
        fail(f"{len(errors)} source/E2E range mismatch(es)")
    print(
        "ES2M_BIRTH_ATTRIBUTE_CONTRACT_STATIC_PASS: "
        f"{len(RACES)} races x {len(ATTRIBUTES)} attributes; NOT RUNTIME PASS"
    )


if __name__ == "__main__":
    main()
