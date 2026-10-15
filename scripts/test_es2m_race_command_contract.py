#!/usr/bin/env python3
"""Static contract for ES2M race-command snapshot, overlay wiring, and E2E probes."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "scripts/apply_race_phase2_runtime.sh"
REGRESSION = ROOT / "scripts/test_race_phase2_regression.sh"
E2E = ROOT / "scripts/test_original_player_creation_e2e.mjs"
RACE_DIR = ROOT / "es2m_snapshot/mudlib/daemon/race"

EXPECTED = {
    "human": "resurge",
    "avatar": "radiate",
    "blackteeth": "gnaw",
    "yenhold": "breathe",
    "woochan": "replete",
    "dingling": "hoof",
    "jiaojao": "hide",
    "rainner": "feed",
    "headless": "dance",
    "yaksa": "devour",
}


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    overlay = OVERLAY.read_text(encoding="utf-8")
    regression = REGRESSION.read_text(encoding="utf-8")
    e2e = E2E.read_text(encoding="utf-8")

    block = re.search(r"declare -A race_commands=\(\s*(.*?)\s*\)", overlay, re.S)
    if not block:
        fail("could not parse race_commands map from runtime overlay")

    actual = dict(re.findall(r"\[([a-z0-9_]+)\]=([a-z0-9_]+)", block.group(1)))
    if actual != EXPECTED:
        fail(f"overlay map mismatch: actual={actual}, expected={EXPECTED}")

    for race, command in EXPECTED.items():
        source = RACE_DIR / race / f"{command}.c"
        if not source.is_file():
            fail(f"missing ES2M command source: {source.relative_to(ROOT)}")
        if f"{race}:{command}" not in regression:
            fail(f"regression test does not cover {race}:{command}")
        if not re.search(rf"{race}\s*:\s*\[\"{re.escape(command)}(?:\s|\")", e2e):
            fail(f"E2E command probe missing for {race}:{command}")

    if 'test -f "$CMD_DIR/$command.c"' not in regression:
        fail("regression test does not verify player command path file")
    if 'cmp -s "$ES2M_RACE_DIR/$race/$command.c" "$CMD_DIR/$command.c"' not in regression:
        fail("regression test does not verify player command file matches ES2M snapshot")

    print(
        "ES2M_RACE_COMMAND_CONTRACT_STATIC_PASS: "
        f"{len(EXPECTED)} command mappings, source files, regression checks and E2E probes"
    )


if __name__ == "__main__":
    main()
