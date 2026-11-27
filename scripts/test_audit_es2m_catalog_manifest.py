#!/usr/bin/env python3
"""ES2M 索引來源與內容完整性隔離測試。"""
import unittest
from audit_es2m_catalog_manifest import audit, EXPECTED_SOURCE


class ManifestAuditTests(unittest.TestCase):
    def setUp(self):
        self.rows = [{"path": "/d/test/room", "type": "room"},
                     {"path": "/d/test/npc/keeper", "type": "npc"}]
        self.manifest = {
            "source": EXPECTED_SOURCE,
            "git": {"commit": "a" * 40},
            "total_files": 2,
            "counts": {"room": 1, "npc": 1},
        }

    def test_valid_catalog(self):
        self.assertEqual(audit(self.manifest, self.rows), [])

    def test_reject_unpinned_source(self):
        self.manifest["git"]["commit"] = ""
        self.assertTrue(audit(self.manifest, self.rows))

    def test_reject_wrong_source(self):
        self.manifest["source"] = "https://example.invalid"
        self.assertTrue(audit(self.manifest, self.rows))

    def test_reject_count_mismatch(self):
        self.manifest["total_files"] = 3
        self.assertTrue(audit(self.manifest, self.rows))

    def test_reject_duplicate_paths(self):
        self.rows.append(dict(self.rows[0]))
        self.manifest["total_files"] = 3
        self.manifest["counts"]["room"] = 2
        self.assertTrue(any("duplicate" in issue for issue in audit(self.manifest, self.rows)))

    def test_reject_type_mismatch(self):
        self.manifest["counts"] = {"room": 2}
        self.assertTrue(audit(self.manifest, self.rows))


if __name__ == "__main__":
    unittest.main()
