import tempfile
import unittest
from pathlib import Path
from import_es2m_equipment_missing import stage


class EquipmentImportTests(unittest.TestCase):
    def test_stage_only_missing_standalone_objects(self):
        with tempfile.TemporaryDirectory() as tmp:
            src, dst = Path(tmp) / "source", Path(tmp) / "runtime"
            src.mkdir()
            dst.mkdir()
            def write(root, name, content):
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
            write(src, "d/camp/obj/sword.c", "inherit WEAPON;\nsource")
            write(src, "d/camp/obj/shield.c", "inherit ARMOR;\nsource")
            write(src, "d/camp/obj/custom.c", 'inherit "/custom/unknown";\n')
            write(src, "d/camp/obj/identical.c", "inherit ITEM;\nsame")
            write(src, "d/camp/npc/guard.c", "inherit NPC;\n")
            write(dst, "d/camp/obj/shield.c", "inherit ARMOR;\noriginal")
            write(dst, "d/camp/obj/identical.c", "inherit ITEM;\nsame")
            result = stage(src, dst)
            self.assertEqual(result["staged"], ["d/camp/obj/sword.c"])
            self.assertEqual(result["conflicts_review"], ["d/camp/obj/shield.c"])
            self.assertEqual(result["identical"], ["d/camp/obj/identical.c"])
            self.assertEqual(result["dependency_review"], ["d/camp/obj/custom.c"])
            self.assertEqual((dst / "d/camp/obj/shield.c").read_text(), "inherit ARMOR;\noriginal")
            self.assertFalse((dst / "d/camp/npc/guard.c").exists())


if __name__ == "__main__":
    unittest.main()
