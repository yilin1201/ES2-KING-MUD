#!/usr/bin/env python3
"""ES2M 雪亭鎮 Runtime baseline 隔離測試。"""
import tempfile
import unittest
from pathlib import Path
from check_es2m_snow_runtime_baseline import REQUIRED, check


class SnowBaselineTests(unittest.TestCase):
    def test_all_source_backed_paths(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name, needles in REQUIRED.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("\n".join(needles), encoding="utf-8")
            self.assertEqual(check(root), [])

    def test_missing_room(self):
        with tempfile.TemporaryDirectory() as temp:
            self.assertTrue(any("MISSING d/snow/bazar.c" in issue
                                for issue in check(Path(temp))))

    def test_changed_npc_vendor(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name, needles in REQUIRED.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("\n".join(needles), encoding="utf-8")
            path = root / "d/snow/npc/yu.c"
            path.write_text(path.read_text().replace("inherit F_VENDOR;", ""),
                            encoding="utf-8")
            self.assertTrue(any("CHANGED d/snow/npc/yu.c" in issue
                                for issue in check(root)))


if __name__ == "__main__":
    unittest.main()
