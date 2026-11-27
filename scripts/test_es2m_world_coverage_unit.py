#!/usr/bin/env python3
"""V13 ES2M 世界區域 coverage gate 的離線單元測試。"""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/test_es2m_world_coverage.py"


class TestES2MWorldCoverage(unittest.TestCase):
    """驗證已分類區域可通過，新增未分類區域會被拒絕。"""

    def setUp(self):
        # 每個測試使用獨立快照，避免測試間互相污染。
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        self.snapshot = Path(self.tempdir.name) / "mudlib"

        for zone in ("lee", "oldpine", "wutang", "snow"):
            room = self.snapshot / "d" / zone / "entry.c"
            room.parent.mkdir(parents=True)
            room.write_text("inherit ROOM;\n", encoding="utf-8")

    def run_coverage(self):
        # 使用目前 Python 執行器執行正式 coverage gate。
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--snapshot", str(self.snapshot)],
            capture_output=True,
            text=True,
        )

    def test_classified_zones_pass(self):
        result = self.run_coverage()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("ES2M_WORLD_COVERAGE_STATIC_PASS", result.stdout)

    def test_unclassified_zone_fails(self):
        room = self.snapshot / "d" / "newzone" / "entry.c"
        room.parent.mkdir(parents=True)
        room.write_text("inherit ROOM;\n", encoding="utf-8")

        result = self.run_coverage()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unclassified zones: newzone", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
