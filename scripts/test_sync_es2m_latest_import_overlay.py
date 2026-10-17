#!/usr/bin/env python3
"""Unit tests for persistent ES2M import overlay safety."""
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("sync_es2m_latest_import_overlay.py")
PIN = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class PersistentOverlayTests(unittest.TestCase):
    def run_cli(self, *args, ok=True):
        proc = subprocess.run([sys.executable, str(SCRIPT), *map(str, args)],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if ok:
            self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)
        else:
            self.assertNotEqual(proc.returncode, 0, proc.stdout + proc.stderr)
        return proc

    def fixture(self, root):
        runtime = root / "runtime"
        runtime.mkdir()
        (runtime / "zone.c").write_text("merged-safe\n", encoding="utf-8")
        (runtime / "new.c").write_text("new-safe\n", encoding="utf-8")
        additive = root / "additive.json"
        additive.write_text(json.dumps({
            "source_commit": PIN,
            "status": "ADDITIVE_IMPORT_ONLY_NOT_FULL_MIGRATION_OR_GAMEPLAY_PASS",
            "copied": ["new.c"], "identical": [], "preserved_conflicts": [], "excluded": []
        }), encoding="utf-8")
        merge = root / "merge.json"
        merge.write_text(json.dumps({
            "source_commit": PIN,
            "status": "THREE_WAY_MERGE_WITH_CONFLICTS_HELD_NOT_FULL_MIGRATION_OR_GAMEPLAY_PASS",
            "source_replaced": [], "merged": ["zone.c"], "added_missing_runtime": [],
            "preserved_conflicts": [{"path": "conflict.c", "reason": "three_way_conflict_preserved_KING"}]
        }), encoding="utf-8")
        return runtime, additive, merge

    def test_exports_only_successful_paths_and_persists_them(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            runtime, additive, merge = self.fixture(root)
            export = root / "export"
            overlay = root / "repo" / "es2m_snapshot/latest_import_overlay/71693beb/mudlib"
            self.run_cli("export", "--runtime", runtime, "--additive-report", additive,
                         "--merge-report", merge, "--output", export)
            manifest = json.loads((export / "manifest.json").read_text(encoding="utf-8"))
            self.assertEqual({x["path"] for x in manifest["files"]}, {"new.c", "zone.c"})
            self.assertEqual(manifest["excluded_conflict_count"], 1)
            self.run_cli("persist", "--export-root", export, "--overlay-root", overlay)
            self.assertEqual((overlay / "new.c").read_text(encoding="utf-8"), "new-safe\n")
            self.assertEqual((overlay / "zone.c").read_text(encoding="utf-8"), "merged-safe\n")
            self.run_cli("apply", "--overlay-root", overlay, "--runtime", runtime)

    def test_persist_refuses_to_overwrite_existing_king_overlay(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            runtime, additive, merge = self.fixture(root)
            export = root / "export"
            overlay = root / "repo" / "es2m_snapshot/latest_import_overlay/71693beb/mudlib"
            self.run_cli("export", "--runtime", runtime, "--additive-report", additive,
                         "--merge-report", merge, "--output", export)
            overlay.mkdir(parents=True)
            (overlay / "new.c").write_text("different-king-content\n", encoding="utf-8")
            self.run_cli("persist", "--export-root", export, "--overlay-root", overlay, ok=False)

    def test_apply_holds_if_fresh_runtime_differs_from_persisted_file(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            runtime, additive, merge = self.fixture(root)
            export = root / "export"
            overlay = root / "repo" / "es2m_snapshot/latest_import_overlay/71693beb/mudlib"
            self.run_cli("export", "--runtime", runtime, "--additive-report", additive,
                         "--merge-report", merge, "--output", export)
            self.run_cli("persist", "--export-root", export, "--overlay-root", overlay)
            (runtime / "zone.c").write_text("changed runtime\n", encoding="utf-8")
            self.run_cli("apply", "--overlay-root", overlay, "--runtime", runtime, ok=False)


if __name__ == "__main__":
    unittest.main()
