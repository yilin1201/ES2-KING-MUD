#!/usr/bin/env python3
"""ES2M 導入清冊驗證器的隔離單元測試；不啟動遊戲 Driver。"""
import csv
import importlib.util
import tempfile
import unittest
from pathlib import Path

MODULE = Path(__file__).with_name("validate_es2m_import_inventory.py")
spec = importlib.util.spec_from_file_location("es2m_validator", MODULE)
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class InventoryTests(unittest.TestCase):
    def check_row(self, **changes):
        row = dict.fromkeys(validator.FIELDS, "")
        row.update(category="World/Map", es2m_source_path="d/sample.c",
                   es2m_source_commit="source-sha", target_path="d/sample.c",
                   target_source_commit="target-sha", evidence_class="Confirmed",
                   compatibility="same-version", manual_review="false",
                   decision="IMPORT", targeted_test="targeted-driver-test")
        row.update(changes)
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / "inventory.csv"
            with file.open("w", newline="", encoding="utf-8") as stream:
                writer = csv.DictWriter(stream, fieldnames=validator.FIELDS)
                writer.writeheader()
                writer.writerow(row)
            return validator.validate(file)

    def test_valid_import(self):
        self.assertEqual(self.check_row(), [])

    def test_missing_source_blocks_import(self):
        self.assertTrue(self.check_row(es2m_source_commit=""))

    def test_manual_review_blocks_import(self):
        self.assertTrue(self.check_row(manual_review="true"))

    def test_unresolved_reference_blocks_import(self):
        self.assertTrue(self.check_row(missing_refs="d/missing.c"))

    def test_incompatible_version_blocks_import(self):
        self.assertTrue(self.check_row(compatibility="unknown"))

    def test_blocked_candidate_can_remain_pending(self):
        self.assertEqual(self.check_row(decision="BLOCKED", manual_review="true",
                                        compatibility="unknown", missing_refs="d/missing.c"), [])


if __name__ == "__main__":
    unittest.main()
