#!/usr/bin/env python3
"""雪亭鎮世界切片依賴檢查測試。"""
import unittest
from check_es2m_snow_slice_dependencies import inspect_slice


class SnowSliceTests(unittest.TestCase):
    def setUp(self):
        self.data = {
            "rooms": [{"path": "/d/snow/bazar", "inherit": "BANK",
                       "exits": {"west": "/d/snow/sstreet1"},
                       "spawns": {"/d/snow/npc/yu": 1}},
                      {"path": "/d/snow/sstreet1", "inherit": "ROOM",
                       "exits": {"east": "/d/snow/bazar"}, "spawns": {}}],
            "npcs": [{"path": "/d/snow/npc/yu",
                      "inherits": ["F_VILLAGER", "F_VENDOR"],
                      "merchandise": {"/obj/bottle": 5},
                      "worn_object": "/obj/jacket"}],
        }
        self.paths = ["/d/snow/bazar", "/d/snow/sstreet1",
                      "/d/snow/npc/yu", "/obj/bottle", "/obj/jacket"]
        self.symbols = ["BANK", "ROOM", "F_VILLAGER", "F_VENDOR"]

    def test_closed_slice(self):
        self.assertEqual(inspect_slice(self.data, self.paths, self.symbols), [])

    def test_missing_exit(self):
        self.paths.remove("/d/snow/sstreet1")
        self.assertTrue(any("BROKEN_EXIT" in x for x in
                            inspect_slice(self.data, self.paths, self.symbols)))

    def test_missing_vendor_dependency(self):
        self.paths.remove("/obj/bottle")
        self.assertTrue(any("MISSING_MERCHANDISE" in x for x in
                            inspect_slice(self.data, self.paths, self.symbols)))

    def test_missing_inherit(self):
        self.symbols.remove("F_VENDOR")
        self.assertTrue(any("MISSING_INHERIT F_VENDOR" in x for x in
                            inspect_slice(self.data, self.paths, self.symbols)))


if __name__ == "__main__":
    unittest.main()
