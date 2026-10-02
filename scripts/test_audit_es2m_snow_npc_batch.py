#!/usr/bin/env python3
"""Isolated tests for the conservative ES2M Snow NPC source audit."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "snow_gate", Path(__file__).with_name("audit_es2m_snow_npc_batch.py"))
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


class SnowGateTests(unittest.TestCase):
    def test_missing_source_blocks(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            result = gate.audit(root / "source", root / "runtime")
            self.assertEqual(result["npc_count"], 10)
            self.assertTrue(all(r["decision"] == "BLOCKED" for r in result["records"]))

    def test_missing_dependency_is_reported_without_copying(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            npc = root / "source/d/snow/npc/alchemist.c"
            npc.parent.mkdir(parents=True)
            npc.write_text('void create(){ new(__DIR__"obj/missing"); }', encoding="utf-8")
            result = gate.audit(root / "source", root / "runtime")
            row = result["records"][0]
            self.assertIn("d/snow/npc/obj/missing.c", row["missing_dependencies"])
            self.assertEqual(row["decision"], "DEPENDENCY_REVIEW")
            self.assertFalse((root / "runtime/d/snow/npc/alchemist.c").exists())


if __name__ == "__main__":
    unittest.main()
