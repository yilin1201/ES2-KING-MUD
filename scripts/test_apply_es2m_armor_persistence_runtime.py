#!/usr/bin/env python3
import csv
import tempfile
import unittest
from pathlib import Path

from apply_es2m_armor_persistence_runtime import MARKER, apply


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
            result = apply(matrix, runtime)
            self.assertEqual(len(result["adapted"]), 91)
            self.assertIn(MARKER, (runtime / "custom/armor/hand/test_0.c").read_text())
            again = apply(matrix, runtime)
            self.assertEqual(len(again["existing"]), 91)
            self.assertEqual(len(again["adapted"]), 0)


if __name__ == "__main__":
    unittest.main()
