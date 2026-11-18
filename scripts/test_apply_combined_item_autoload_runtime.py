#!/usr/bin/env python3
"""Targeted tests for source-backed shop COMBINED_ITEM persistence."""

import tempfile
import unittest
from pathlib import Path

from apply_combined_item_autoload_runtime import ITEMS, MARKER, apply


class CombinedItemAutoloadTests(unittest.TestCase):
    def test_adapts_only_known_shop_items(self):
        with tempfile.TemporaryDirectory() as root:
            mudlib = Path(root)
            for rel in ITEMS:
                target = mudlib / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("inherit COMBINED_ITEM;\n", encoding="utf-8")
            base = mudlib / "std/item/combined.c"
            base.parent.mkdir(parents=True, exist_ok=True)
            base.write_text("int query_amount() { return 1; }\n", encoding="utf-8")

            result = apply(mudlib)
            self.assertEqual(result["adapted"], list(ITEMS))
            self.assertNotIn(MARKER, base.read_text(encoding="utf-8"))
            for rel in ITEMS:
                text = (mudlib / rel).read_text(encoding="utf-8")
                self.assertIn(MARKER, text)
                self.assertIn("saved_amount > 0", text)

            again = apply(mudlib)
            self.assertEqual(again["existing"], list(ITEMS))
            self.assertEqual(again["adapted"], [])


if __name__ == "__main__":
    unittest.main()
