#!/usr/bin/env python3
"""ES2M 裝備三方盤點隔離測試：缺檔、相同、衝突與非裝備排除。"""
import tempfile
import unittest
from pathlib import Path
from audit_es2m_equipment_import import audit, candidates


class EquipmentAuditTests(unittest.TestCase):
    def test_three_way_inventory(self):
        with tempfile.TemporaryDirectory() as tmp:
            roots = [Path(tmp) / name for name in ("snapshot", "original", "runtime")]
            for root in roots:
                root.mkdir()
            snapshot, original, runtime = roots

            def write(root, name, value):
                file = root / name
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text(value, encoding="utf-8")

            write(snapshot, "d/camp/obj/sword.c", "inherit WEAPON;\nsource")
            write(snapshot, "d/camp/obj/armor.c", "inherit ARMOR;\nsource")
            write(snapshot, "d/camp/obj/boots.c", "inherit ARMOR;\nsource")
            write(snapshot, "d/camp/npc/guard.c", "inherit NPC;\n")
            write(original, "d/camp/obj/sword.c", "inherit WEAPON;\noriginal")
            write(runtime, "d/camp/obj/sword.c", "inherit WEAPON;\nsource")
            write(runtime, "d/camp/obj/armor.c", "inherit ARMOR;\nchanged")
            report = audit(snapshot, original, runtime)
            self.assertEqual(report["source_candidates"], 3)
            self.assertEqual([x["path"] for x in report["source_only_missing_runtime"]], ["d/camp/obj/boots.c"])
            self.assertEqual([x["path"] for x in report["source_identical_runtime"]], ["d/camp/obj/sword.c"])
            self.assertEqual([x["path"] for x in report["source_conflicts_runtime"]], ["d/camp/obj/armor.c"])
            self.assertEqual(report["source_conflicts_runtime"][0]["decision"], "OWNER_REVIEW_NO_OVERWRITE")
            self.assertNotIn("d/camp/npc/guard.c", candidates(snapshot))

    def test_missing_root_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "snapshot").mkdir()
            (root / "runtime").mkdir()
            with self.assertRaises(FileNotFoundError):
                audit(root / "snapshot", root / "missing", root / "runtime")


if __name__ == "__main__":
    unittest.main()
