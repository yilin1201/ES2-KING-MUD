#!/usr/bin/env python3
"""ES2M pinned source manifest gate／驗證固定上游版本與全檔盤點，不代表 Runtime 已移植。"""

from __future__ import annotations

import json
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261017.json"
SUBMODULE_PATH = "source/es2m_updates/20261017_71693beb/upstream-es2-webmud"
EXPECTED_COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"


class TestES2MSourceSyncManifest(unittest.TestCase):
    """防止 ES2M 來源版本、全量檔案清單或保護性匯入閘門悄悄漂移。"""

    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))

    def test_upstream_commit_is_pinned(self):
        self.assertEqual(self.manifest["source_commit"], EXPECTED_COMMIT)
        self.assertEqual(self.manifest["source_repository"], "https://github.com/wolfer168/es2-webmud")

    def test_all_upstream_mudlib_paths_are_accounted_for(self):
        files = self.manifest["files"]
        counts = self.manifest["counts"]
        self.assertEqual(len(files), counts["upstream_files"])
        self.assertEqual(len({entry["path"] for entry in files}), len(files))
        self.assertEqual(counts["upstream_files"], 1678)
        for entry in files:
            self.assertTrue(re.fullmatch(r"[0-9a-f]{40}", entry["sha"]), entry["path"])
            self.assertFalse(entry["path"].startswith("/"), entry["path"])
            self.assertNotIn("..", Path(entry["path"]).parts)
            self.assertIn(entry["status"], {
                "SAME_AS_EXISTING_ES2M_SNAPSHOT",
                "CHANGED_FROM_EXISTING_ES2M_SNAPSHOT",
                "NEW_TO_EXISTING_ES2M_SNAPSHOT",
            })

    def test_snapshot_difference_counts_are_consistent(self):
        files = self.manifest["files"]
        actual = {
            "same_as_snapshot": sum(x["status"] == "SAME_AS_EXISTING_ES2M_SNAPSHOT" for x in files),
            "changed_from_snapshot": sum(x["status"] == "CHANGED_FROM_EXISTING_ES2M_SNAPSHOT" for x in files),
            "new_to_snapshot": sum(x["status"] == "NEW_TO_EXISTING_ES2M_SNAPSHOT" for x in files),
        }
        for key, value in actual.items():
            self.assertEqual(self.manifest["counts"][key], value)
        self.assertEqual(actual, {
            "same_as_snapshot": 981,
            "changed_from_snapshot": 160,
            "new_to_snapshot": 537,
        })
        self.assertEqual(len(self.manifest["snapshot_only_files"]), 3)
        self.assertEqual(self.manifest["counts"]["requires_review"], 700)

    def test_nonidentical_files_are_not_auto_imported(self):
        # 新增／修改來源一律先審核；不可因來源更新就直接覆蓋 KING Runtime。
        for entry in self.manifest["files"]:
            if entry["status"] == "SAME_AS_EXISTING_ES2M_SNAPSHOT":
                self.assertEqual(entry["runtime_import"], "NO_CHANGE_REQUIRED", entry["path"])
            else:
                self.assertEqual(entry["runtime_import"], "HOLD_REVIEW", entry["path"])
        self.assertTrue(all(x["status"] == "KING_SNAPSHOT_ONLY_REVIEW"
                            for x in self.manifest["snapshot_only_files"]))

    def test_git_submodule_pin_matches_manifest(self):
        gitmodules = (ROOT / ".gitmodules").read_text(encoding="utf-8")
        self.assertIn(f"path = {SUBMODULE_PATH}", gitmodules)
        self.assertIn("url = https://github.com/wolfer168/es2-webmud.git", gitmodules)
        # git ls-tree 讀取提交中的 gitlink；不需要把 submodule 工作目錄展開。
        result = subprocess.run(
            ["git", "ls-tree", "HEAD", "--", SUBMODULE_PATH],
            cwd=ROOT, check=True, text=True, capture_output=True,
        ).stdout.strip()
        self.assertTrue(result, "Git tree 缺少固定 ES2M submodule")
        match = re.search(r"^160000 commit ([0-9a-f]{40})\s+", result)
        self.assertIsNotNone(match, result)
        self.assertEqual(match.group(1), EXPECTED_COMMIT)


if __name__ == "__main__":
    unittest.main(verbosity=2)
