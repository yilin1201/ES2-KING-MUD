#!/usr/bin/env python3
"""V13 ES2M 世界區域 coverage gate 的離線單元測試。"""
from pathlib import Path
import subprocess, sys, tempfile

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/test_es2m_world_coverage.py"

with tempfile.TemporaryDirectory() as td:
    snapshot = Path(td) / "mudlib"
    for zone in ("lee", "oldpine", "wutang", "snow"):
        p = snapshot / "d" / zone
        p.mkdir(parents=True)
        (p / "entry.c").write_text("inherit ROOM;\n", encoding="utf-8")

    ok = subprocess.run(
        [sys.executable, str(SCRIPT), "--snapshot", str(snapshot)],
        capture_output=True, text=True,
    )
    assert ok.returncode == 0, ok.stdout + ok.stderr
    assert "ES2M_WORLD_COVERAGE_STATIC_PASS" in ok.stdout

    p = snapshot / "d" / "newzone"
    p.mkdir()
    (p / "entry.c").write_text("inherit ROOM;\n", encoding="utf-8")
    bad = subprocess.run(
        [sys.executable, str(SCRIPT), "--snapshot", str(snapshot)],
        capture_output=True, text=True,
    )
    assert bad.returncode != 0
    assert "unclassified zones: newzone" in bad.stderr

print("ES2M WORLD COVERAGE TEST PASS")
