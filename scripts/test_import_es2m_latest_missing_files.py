#!/usr/bin/env python3
"""隔離測試 ES2M 最新來源缺檔補入器：只複製缺檔、永不覆蓋同名 KING 檔。"""
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("import_es2m_latest_missing_files.py")
COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"

def git_blob_sha(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\\0" + data).hexdigest()

class LatestAdditiveImportTest(unittest.TestCase):
    def run_import(self, root: Path, entries):
        source = root / "source"; runtime = root / "runtime"; source.mkdir(); runtime.mkdir()
        for entry, data in entries:
            p = source / entry["path"]; p.parent.mkdir(parents=True, exist_ok=True); p.write_bytes(data)
        manifest = root / "manifest.json"
        manifest.write_text(json.dumps({"source_commit": COMMIT, "files": [e for e, _ in entries]}), encoding="utf-8")
        output = root / "report.json"
        proc = subprocess.run([sys.executable, str(SCRIPT), "--source-root", str(source), "--runtime", str(runtime),
                               "--manifest", str(manifest), "--output", str(output)], capture_output=True, text=True)
        return proc, runtime, output

    def test_copies_missing_and_preserves_conflict(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            a = b"new source\n"; b = b"upstream version\n"
            entries = [
                ({"path": "d/new_room.c", "sha": git_blob_sha(a)}, a),
                ({"path": "d/king_room.c", "sha": git_blob_sha(b)}, b),
            ]
            proc, runtime, output = self.run_import(root, entries)
            (runtime / "d/king_room.c").write_bytes(b"KING custom\n")
            # Re-run with the same source and a KING-specific conflicting file.
            manifest = root / "manifest.json"; manifest.write_text(json.dumps({"source_commit": COMMIT, "files": [e for e, _ in entries]}), encoding="utf-8")
            proc = subprocess.run([sys.executable, str(SCRIPT), "--source-root", str(root / "source"), "--runtime", str(runtime),
                                   "--manifest", str(manifest), "--output", str(output)], capture_output=True, text=True)
            self.assertEqual(proc.returncode, 0, proc.stderr)
            self.assertEqual((runtime / "d/new_room.c").read_bytes(), a)
            self.assertEqual((runtime / "d/king_room.c").read_bytes(), b"KING custom\n")
            report = json.loads(output.read_text(encoding="utf-8"))
            self.assertIn("d/king_room.c", [x["path"] for x in report["preserved_conflicts"]])

    def test_skips_runtime_state_and_timestamped_backups(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            entries = []
            for path, data in [("data/player.o", b"state"), ("log/runtime.log", b"log"),
                               ("custom/room.c.1789329689", b"backup"), ("d/room.c", b"room")]:
                entries.append(({"path": path, "sha": git_blob_sha(data)}, data))
            proc, runtime, output = self.run_import(root, entries)
            self.assertEqual(proc.returncode, 0, proc.stderr)
            report = json.loads(output.read_text(encoding="utf-8"))
            self.assertTrue((runtime / "d/room.c").is_file())
            self.assertFalse((runtime / "data/player.o").exists())
            self.assertFalse((runtime / "log/runtime.log").exists())
            self.assertFalse((runtime / "custom/room.c.1789329689").exists())
            self.assertEqual(len(report["excluded"]), 3)

    def test_source_hash_mismatch_fails(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); data = b"real bytes"
            entries = [({"path": "d/room.c", "sha": "0" * 40}, data)]
            proc, runtime, output = self.run_import(root, entries)
            self.assertNotEqual(proc.returncode, 0)
            self.assertIn("source SHA mismatch", proc.stderr)

if __name__ == "__main__":
    unittest.main(verbosity=2)
