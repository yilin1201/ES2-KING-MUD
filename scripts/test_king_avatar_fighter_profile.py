#!/usr/bin/env python3
"""KING avatar/fighter/50 static regression: source checks, not Driver PASS."""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "es2_king_expansion/runtime/mudlib"


class KingProfileTests(unittest.TestCase):
    def test_owner_race_class_and_attributes(self):
        src = (ROOT / "adm/daemons/kingd.c").read_text()
        self.assertIn('actor->set_race("avatar")', src)
        self.assertIn('actor->set_class("fighter")', src)
        self.assertIn('actor->set_attr(attr, 50) != 50', src)
        self.assertIn('creator_attribute", 50', src)
        self.assertIn('creator_statistic", 999', src)
        self.assertIn('if (!authorized(actor)) return 0;', src)

    def test_attribute_ceiling_matches_original(self):
        src = (ROOT / "feature/attribute.c").read_text()
        self.assertIn('value > ATTRVAL_MAX', src)
        self.assertNotIn('query("id") == "king"', src)


if __name__ == "__main__":
    unittest.main()
