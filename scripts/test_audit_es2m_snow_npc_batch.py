#!/usr/bin/env python3
"""雪亭 NPC 靜態盤點回歸測試；不代表 Driver / Gameplay PASS。"""
import tempfile
import unittest
from pathlib import Path
from audit_es2m_snow_npc_batch import audit


class SnowNpcAuditTests(unittest.TestCase):
    def test_missing_and_staged_and_existing(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            source, runtime = root / "snapshot", root / "runtime"
            npc = Path("d/snow/npc")
            (source / npc).mkdir(parents=True)
            (runtime / npc).mkdir(parents=True)
            for name in ("alchemist", "child", "foreman", "gammer", "garrison",
                         "girl", "guard", "herbalist", "innkeeper", "junkman"):
                (source / npc / (name + ".c")).write_text("void create() {}\n")
            (source / npc / "alchemist.c").write_text(
                '__DIR__"obj/silversword"; "/obj/area/obj/cloth";\n')
            (source / npc / "obj").mkdir()
            (source / npc / "obj/silversword.c").write_text("void create() {}\n")
            (runtime / npc / "child.c").write_text("void create() {}\n")
            rows = {row["npc"]: row for row in audit(source, runtime)["records"]}
            self.assertEqual(rows["alchemist"]["decision"], "DEPENDENCY_REVIEW")
            self.assertIn("d/snow/npc/obj/silversword.c",
                          rows["alchemist"]["staged_dependencies"])
            self.assertIn("obj/area/obj/cloth.c",
                          rows["alchemist"]["missing_dependencies"])
            self.assertEqual(rows["child"]["decision"], "REVIEW_EXISTING")
            self.assertEqual(rows["foreman"]["decision"], "SOURCE_PRESENT_RUNTIME_ABSENT")


if __name__ == "__main__":
    unittest.main()
