#!/usr/bin/env python3
"""隔離驗證 ES2M 三方合併：合併非重疊修改，衝突時保留 KING。"""
import hashlib, json, subprocess, sys, tempfile, unittest
from pathlib import Path
SCRIPT = Path(__file__).with_name("merge_es2m_latest_changes_safe.py")
COMMIT = "71693beb79ced81d51719ea1ccf7c02c641ca9b0"
def blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()
class ThreeWayMergeTest(unittest.TestCase):
    def setup_case(self, root: Path, base: bytes, king: bytes, upstream: bytes, original_sha=None):
        original = root / "original"; source = root / "source"; runtime = root / "runtime"
        for p in (original / "d", source / "d", runtime / "d"): p.mkdir(parents=True, exist_ok=True)
        (original / "d/room.c").write_bytes(base); (source / "d/room.c").write_bytes(upstream); (runtime / "d/room.c").write_bytes(king)
        entry = {"path":"d/room.c", "sha":blob(upstream), "original_sha":original_sha or blob(base),
                 "original_status":"CHANGED_FROM_PINNED_ORIGINAL", "status":"CHANGED_FROM_EXISTING_ES2M_SNAPSHOT"}
        manifest = root / "manifest.json"; manifest.write_text(json.dumps({"source_commit":COMMIT,"files":[entry]}),encoding="utf-8")
        output = root / "report.json"
        proc = subprocess.run([sys.executable,str(SCRIPT),"--source-root",str(source),"--original-root",str(original),
                               "--runtime",str(runtime),"--manifest",str(manifest),"--output",str(output)],capture_output=True,text=True)
        return proc, runtime / "d/room.c", output
    def test_merges_non_overlapping_edits(self):
        with tempfile.TemporaryDirectory() as td:
            base=b"alpha\nbeta\n"; king=b"alpha\nKING\nbeta\n"; upstream=b"alpha\nbeta\nES2M\n"
            proc,target,report=self.setup_case(Path(td),base,king,upstream)
            self.assertEqual(proc.returncode,0,proc.stderr)
            self.assertEqual(target.read_bytes(),b"alpha\nKING\nbeta\nES2M\n")
            self.assertEqual(len(json.loads(report.read_text())["merged"]),1)
    def test_preserves_king_on_conflict(self):
        with tempfile.TemporaryDirectory() as td:
            base=b"value=1\n"; king=b"value=2\n"; upstream=b"value=3\n"
            proc,target,report=self.setup_case(Path(td),base,king,upstream)
            self.assertEqual(proc.returncode,0,proc.stderr)
            self.assertEqual(target.read_bytes(),king)
            self.assertEqual(len(json.loads(report.read_text())["preserved_conflicts"]),1)
    def test_preserves_king_when_git_reports_multiple_conflicts(self):
        with tempfile.TemporaryDirectory() as td:
            separator=b"".join(f"keep{i}\n".encode() for i in range(10))
            base=b"one=0\n"+separator+b"two=0\n"+separator+b"three=0\n"
            king=b"one=1\n"+separator+b"two=1\n"+separator+b"three=1\n"
            upstream=b"one=2\n"+separator+b"two=2\n"+separator+b"three=2\n"
            proc,target,report=self.setup_case(Path(td),base,king,upstream)
            self.assertEqual(proc.returncode,0,proc.stderr)
            self.assertEqual(target.read_bytes(),king)
            conflicts=json.loads(report.read_text())["preserved_conflicts"]
            self.assertEqual(len(conflicts),1)
            self.assertGreaterEqual(conflicts[0].get("conflict_count",0),2)

    def test_binary_nul_file_is_held_without_text_merge(self):
        with tempfile.TemporaryDirectory() as td:
            base=b"base=0\x00tail\n"
            king=b"king=1\x00tail\n"
            upstream=b"source=2\x00tail\n"
            proc,target,report=self.setup_case(Path(td),base,king,upstream)
            self.assertEqual(proc.returncode,0,proc.stderr)
            self.assertEqual(target.read_bytes(),king)
            conflicts=json.loads(report.read_text())["preserved_conflicts"]
            self.assertEqual(conflicts[0]["reason"],"binary_file_preserved_KING")

    def test_rejects_original_baseline_drift(self):
        with tempfile.TemporaryDirectory() as td:
            proc,target,report=self.setup_case(Path(td),b"base\n",b"king\n",b"upstream\n",original_sha="0"*40)
            self.assertNotEqual(proc.returncode,0)
            self.assertIn("Original ES2 baseline blob mismatch",proc.stderr)
if __name__ == "__main__": unittest.main(verbosity=2)
