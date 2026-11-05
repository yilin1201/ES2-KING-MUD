#!/usr/bin/env python3
"""驗證 ES2M 三方盤點：不自動覆蓋衝突、缺失原始檔阻止發布。"""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("audit_es2m_full_runtime_overlay.py")


class FullInventoryTest(unittest.TestCase):
    def test_snapshot_conflict_requires_review(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            original, runtime, snapshot = [root / name for name in ("original", "runtime", "snapshot")]
            for path in (original, runtime, snapshot):
                path.mkdir()
            (original / "room.c").write_text("base", encoding="utf-8")
            (runtime / "room.c").write_text("king", encoding="utf-8")
            (snapshot / "room.c").write_text("es2m", encoding="utf-8")
            report = root / "report.json"
            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(original), str(runtime), str(report),
                 "--snapshot", str(snapshot)], capture_output=True, text=True
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            data = json.loads(report.read_text(encoding="utf-8"))
            self.assertEqual(data["overridden"], ["room.c"])
            self.assertEqual(data["snapshot_conflicts_base"], ["room.c"])
            self.assertEqual(data["snapshot_conflicts_runtime"], ["room.c"])
            self.assertTrue(data["owner_review_required"])
            self.assertEqual(data["priority_conflict_review"][0]["path"], "room.c")
            self.assertEqual(data["priority_conflict_review"][0]["decision"], "REVIEW_ONLY_NO_OVERWRITE")
            self.assertEqual(len(data["priority_conflict_review"][0]["es2m_sha256"]), 64)
            self.assertEqual(len(data["priority_conflict_review"][0]["runtime_sha256"]), 64)
            self.assertEqual(data["owner_review_queue"], {"other": ["room.c"]})
            self.assertEqual((runtime / "room.c").read_text(), "king")

    def test_missing_base_fails_release(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            original, runtime = root / "original", root / "runtime"
            original.mkdir()
            runtime.mkdir()
            (original / "npc.c").write_text("base", encoding="utf-8")
            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(original), str(runtime), str(root / "report.json")],
                capture_output=True, text=True
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("ES2M_RUNTIME_MISSING_ORIGINAL_FILES", result.stderr)


if __name__ == "__main__":
    unittest.main()
