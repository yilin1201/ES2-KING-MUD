#!/usr/bin/env python3
"""Targeted tests for ordinary-shop non-stacking item persistence."""

import tempfile
import unittest
from pathlib import Path

from apply_shop_item_autoload_runtime import ITEMS, MARKER, apply


class ShopItemAutoloadTests(unittest.TestCase):
    def test_adapts_exact_items_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as root:
            mudlib = Path(root)
            for rel in ITEMS:
                target = mudlib / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("inherit ITEM;\n", encoding="utf-8")
            result = apply(mudlib)
            self.assertEqual(result["adapted"], list(ITEMS))
            for rel in ITEMS:
                text = (mudlib / rel).read_text(encoding="utf-8")
                self.assertIn(MARKER, text)
                self.assertIn("int query_autoload() { return 1; }", text)
            again = apply(mudlib)
            self.assertEqual(again["existing"], list(ITEMS))
            self.assertEqual(again["adapted"], [])

    def test_refuses_existing_unknown_contract(self):
        with tempfile.TemporaryDirectory() as root:
            mudlib = Path(root)
            for rel in ITEMS:
                target = mudlib / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("inherit ITEM;\n", encoding="utf-8")
            (mudlib / ITEMS[0]).write_text(
                "inherit ITEM;\nstring query_autoload() { return \"x\"; }\n",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(RuntimeError, "conflicts"):
                apply(mudlib)


if __name__ == "__main__":
    unittest.main()
