#!/usr/bin/env python3
"""ES2M catalog 候選產生器隔離測試，不接觸遊戲 Runtime。"""
import unittest
from build_es2m_reference_candidates import build_candidates


class CandidateTests(unittest.TestCase):
    def test_order_and_no_auto_import(self):
        rows = [{"path": "/obj/weapon.c", "type": "weapon"},
                {"path": "/d/snow/room.c", "type": "room"},
                {"path": "/d/snow/npc/girl.c", "type": "npc"},
                {"path": "/skills/example.c", "type": "skill"}]
        result = build_candidates(rows, "pinned-source-commit")
        self.assertEqual([r["category"] for r in result],
                         ["World/Map", "NPC", "Weapon/Equipment", "Skill"])
        self.assertTrue(all(r["decision"] == "REFERENCE_ONLY" for r in result))
        self.assertTrue(all(r["manual_review"] == "true" for r in result))
        self.assertTrue(all(r["es2m_source_commit"] == "pinned-source-commit"
                            for r in result))

    def test_missing_source_commit_rejected(self):
        with self.assertRaises(ValueError):
            build_candidates([], "")

    def test_duplicate_paths_rejected(self):
        with self.assertRaises(ValueError):
            build_candidates([{"path": "/d/a.c", "type": "room"},
                              {"path": "/d/a.c", "type": "npc"}], "pinned")

    def test_unknown_types_and_relative_paths_ignored(self):
        self.assertEqual(build_candidates([
            {"path": "/d/a.c", "type": "unknown"},
            {"path": "d/a.c", "type": "room"},
        ], "pinned"), [])


if __name__ == "__main__":
    unittest.main()
