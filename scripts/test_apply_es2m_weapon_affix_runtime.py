#!/usr/bin/env python3
"""武器詞綴 Runtime 覆蓋器的來源鎖定與衝突停止測試。"""

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("apply_es2m_weapon_affix_runtime.py")
SPEC = importlib.util.spec_from_file_location("weapon_affix_overlay", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class WeaponAffixOverlayTest(unittest.TestCase):
    def test_saved_sources_are_complete_and_pinned(self):
        self.assertEqual(19, len(MODULE.OVERLAYS))
        paths = {item.path for item in MODULE.OVERLAYS}
        self.assertEqual(19, len(paths))
        for item in MODULE.OVERLAYS:
            self.assertTrue(item.source.is_file(), item.path)
            self.assertEqual(item.source_sha256, MODULE.digest(item.source), item.path)

    def test_unknown_runtime_file_stops_before_any_write(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            good_source = root / "source-good.c"
            bad_source = root / "source-bad.c"
            good_source.write_text("new-good\n", encoding="utf-8")
            bad_source.write_text("new-bad\n", encoding="utf-8")
            (root / "good.c").write_text("old-good\n", encoding="utf-8")
            (root / "bad.c").write_text("unexpected\n", encoding="utf-8")
            overlays = (
                MODULE.Overlay("good.c", good_source, MODULE.digest(good_source),
                               (MODULE.digest(root / "good.c"),)),
                MODULE.Overlay("bad.c", bad_source, MODULE.digest(bad_source),
                               ("0" * 64,)),
            )
            with self.assertRaisesRegex(RuntimeError, "Runtime 衝突"):
                MODULE.apply(root, overlays)
            self.assertEqual("old-good\n", (root / "good.c").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
