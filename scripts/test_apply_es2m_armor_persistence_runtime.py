#!/usr/bin/env python3
import csv
import tempfile
import unittest
from pathlib import Path

from apply_es2m_armor_persistence_runtime import MARKER, ORDINARY_MARKER, ORDINARY_EQUIPMENT, apply


class ArmorPersistenceRuntimeTests(unittest.TestCase):
    def test_adapts_exact_batch_without_touching_snapshot(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            matrix = root / "matrix.csv"
            runtime = root / "runtime"
            fieldnames = ["source_path", "note"]
            with matrix.open("w", encoding="utf-8", newline="") as handle:
                writer = csv.DictWriter(handle, fieldnames=fieldnames)
                writer.writeheader()
                for index in range(91):
                    rel = f"custom/armor/hand/test_{index}.c"
                    writer.writerow({"source_path": rel, "note": "來源SHA一致；custom overlay"})
                    target = runtime / rel
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_text("inherit F_HAND_EQ;\n", encoding="utf-8")
            for rel in ORDINARY_EQUIPMENT:
                target = runtime / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("inherit ITEM;\n", encoding="utf-8")
            # 現有 KING expansion 已為木劍提供相同的「物件保存、裝備不保存」契約。
            (runtime / ORDINARY_EQUIPMENT[0]).write_text(
                "inherit ITEM;\nint query_autoload() { return 1; }\n"
                "void autoload(string param) { }\n",
                encoding="utf-8",
            )
            result = apply(matrix, runtime)
            self.assertEqual(len(result["adapted"]), 91)
            self.assertEqual(len(result["ordinary_adapted"]), 1)
            self.assertEqual(len(result["ordinary_existing"]), 1)
            armor_text = (runtime / "custom/armor/hand/test_0.c").read_text()
            self.assertIn(MARKER, armor_text)
            self.assertIn('call_out("es2_king_restore_wear", 1, on_part);', armor_text)
            for rel in ORDINARY_EQUIPMENT:
                text = (runtime / rel).read_text()
                self.assertIn("int query_autoload() { return 1; }", text)
            self.assertIn(ORDINARY_MARKER, (runtime / ORDINARY_EQUIPMENT[1]).read_text())
            again = apply(matrix, runtime)
            self.assertEqual(len(again["existing"]), 91)
            self.assertEqual(len(again["adapted"]), 0)
            self.assertEqual(len(again["ordinary_existing"]), 2)
            self.assertEqual(len(again["ordinary_adapted"]), 0)


if __name__ == "__main__":
    unittest.main()
