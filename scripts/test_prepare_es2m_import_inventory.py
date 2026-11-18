#!/usr/bin/env python3
"""ES2M 全流程導入清冊隔離測試；不使用遊戲 Runtime。"""
import csv
import json
import tempfile
import unittest
from pathlib import Path

from prepare_es2m_import_inventory import prepare


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.out = self.root / "candidates.csv"
        self.rows = [
            {"path": "/d/snow/road", "type": "room"},
            {"path": "/d/snow/npc/girl", "type": "npc"},
            {"path": "/obj/sword", "type": "item"},
            {"path": "/skill/sword", "type": "skill"},
        ]
        self.manifest = {
            "source": "https://github.com/taedlar/es2_mudlib",
            "git": {"commit": "a" * 40},
            "total_files": 4,
            "counts": {"room": 1, "npc": 1, "item": 1, "skill": 1},
        }
        self.write()

    def write(self):
        (self.root / "manifest.json").write_text(json.dumps(self.manifest), encoding="utf-8")
        (self.root / "all.json").write_text(json.dumps(self.rows), encoding="utf-8")

    def test_verified_pipeline(self):
        result = prepare(self.root, self.out)
        self.assertEqual(len(result), 4)
        with self.out.open(newline="", encoding="utf-8") as stream:
            rows = list(csv.DictReader(stream))
        self.assertEqual([r["category"] for r in rows],
                         ["World/Map", "NPC", "Weapon/Equipment", "Skill"])
        self.assertTrue(all(r["decision"] == "REFERENCE_ONLY" for r in rows))
        self.assertTrue(all(r["es2m_source_commit"] == "a" * 40 for r in rows))

    def test_reject_count_mismatch_before_writing(self):
        self.manifest["total_files"] = 5
        self.write()
        with self.assertRaises(ValueError):
            prepare(self.root, self.out)
        self.assertFalse(self.out.exists())

    def test_reject_duplicate_before_writing(self):
        self.rows.append(self.rows[0])
        self.manifest["total_files"] = 5
        self.manifest["counts"]["room"] = 2
        self.write()
        with self.assertRaises(ValueError):
            prepare(self.root, self.out)
        self.assertFalse(self.out.exists())


if __name__ == "__main__":
    unittest.main()
