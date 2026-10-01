#!/usr/bin/env python3
"""ES2M 世界引用審計隔離測試。"""
import unittest
from audit_es2m_world_references import inspect, resolve


class WorldReferenceTests(unittest.TestCase):
    def test_relative_exit(self):
        self.assertEqual(resolve("/d/snow/bazar", {"target": "sstreet1", "relative": True}),
                         "/d/snow/sstreet1")

    def test_existing_exit_and_spawn(self):
        rows = [{"path": "/d/snow/bazar", "type": "room",
                 "exits": {"west": {"target": "sstreet1", "relative": True}},
                 "objects": [{"target": "npc/yu", "relative": True}]},
                {"path": "/d/snow/sstreet1", "type": "room"},
                {"path": "/d/snow/npc/yu", "type": "npc"}]
        self.assertEqual(inspect(rows), [])

    def test_missing_exit_reported(self):
        findings = inspect([{"path": "/d/snow/bazar", "type": "room",
                             "exits": {"west": {"target": "sstreet1", "relative": True}}}])
        self.assertEqual(findings[0]["target"], "/d/snow/sstreet1")

    def test_dynamic_reference_requires_review(self):
        findings = inspect([{"path": "/d/snow/bazar", "type": "room",
                             "objects": [{"target": "NPC_DYNAMIC"}]}])
        self.assertEqual(findings[0]["status"], "UNRESOLVED_OR_DYNAMIC")

    def test_missing_npc_equipment_reported(self):
        findings = inspect([{"path": "/d/snow/npc/yu", "type": "npc",
                             "equipment": [{"target": "/obj/weapon/sword"}]}])
        self.assertEqual(findings[0]["relation"], "equipment")


if __name__ == "__main__":
    unittest.main()
