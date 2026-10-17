#!/usr/bin/env python3
"""Unit tests for ES2M additive/three-way conflict classification."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from classify_es2m_latest_conflicts import SOURCE_COMMIT, classify

PIN = SOURCE_COMMIT


class ConflictClassificationTests(unittest.TestCase):
    def setUp(self):
        self.manifest = {
            "source_commit": PIN,
            "files": [
                {"path": "adm/replaced.c", "sha": "new", "original_sha": "old",
                 "original_status": "CHANGED_FROM_PINNED_ORIGINAL"},
                {"path": "d/king_custom.c", "sha": "same-as-original", "original_sha": "same-as-original",
                 "original_status": "SAME_AS_PINNED_ORIGINAL"},
                {"path": "adm/unaccounted.c", "sha": "changed-source", "original_sha": "old-source",
                 "original_status": "CHANGED_FROM_PINNED_ORIGINAL"},
                {"path": "adm/conflict.c", "sha": "changed-conflict", "original_sha": "old-conflict",
                 "original_status": "CHANGED_FROM_PINNED_ORIGINAL"},
            ],
        }
        self.additive = {
            "source_commit": PIN,
            "preserved_conflicts": [
                {"path": "adm/replaced.c", "source_git_blob_sha": "new", "runtime_git_blob_sha": "king"},
                {"path": "d/king_custom.c", "source_git_blob_sha": "same-as-original", "runtime_git_blob_sha": "king-custom"},
                {"path": "adm/unaccounted.c", "source_git_blob_sha": "changed-source", "runtime_git_blob_sha": "king"},
                {"path": "adm/conflict.c", "source_git_blob_sha": "changed-conflict", "runtime_git_blob_sha": "king"},
            ],
        }
        self.merge = {
            "source_commit": PIN,
            "source_replaced": [{"path": "adm/replaced.c"}],
            "already_source": [],
            "merged": [],
            "preserved_conflicts": [{"path": "adm/conflict.c"}],
            "added_missing_runtime": [],
        }

    def test_distinguishes_resolved_king_custom_and_real_holds(self):
        result = classify(self.manifest, self.additive, self.merge)
        by_path = {item["path"]: item["category"] for item in result["entries"]}
        self.assertEqual(by_path["adm/replaced.c"], "COVERED_BY_THREE_WAY_RESULT")
        self.assertEqual(by_path["d/king_custom.c"], "KING_DIVERGENCE_SOURCE_UNCHANGED")
        self.assertEqual(by_path["adm/unaccounted.c"], "HOLD_CHANGED_SOURCE_NOT_ACCOUNTED")
        self.assertEqual(by_path["adm/conflict.c"], "HOLD_THREE_WAY_CONFLICT")
        self.assertEqual(result["additive_conflict_count"], 4)

    def test_rejects_mismatched_source_pin(self):
        bad = dict(self.additive, source_commit="wrong")
        with self.assertRaises(SystemExit):
            classify(self.manifest, bad, self.merge)


if __name__ == "__main__":
    unittest.main()
