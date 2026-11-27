#!/usr/bin/env python3
"""Targeted tests for source-backed shop COMBINED_ITEM persistence."""

import tempfile
import unittest
from pathlib import Path

from apply_combined_item_autoload_runtime import ITEMS, MARKER, apply


class CombinedItemAutoloadTests(unittest.TestCase):
    def test_current_lee_vendor_paths_are_included(self):
        # 李忠最新 merchandise 指向 d/npc 與 d/lee/npc；舊 d/lee 別名不能代替實際販售檔。
        for rel in (
            "d/npc/obj/sugar.c",
            "d/npc/obj/salt.c",
            "d/lee/npc/obj/flour.c",
            "d/npc/obj/bait.c",
        ):
            self.assertIn(rel, ITEMS)

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
