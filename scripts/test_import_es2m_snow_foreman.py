#!/usr/bin/env python3
"""工頭／木箱來源匯入隔離測試。"""
import tempfile
import unittest
from pathlib import Path
from import_es2m_snow_foreman import import_foreman, PAIRS

class ForemanImportTests(unittest.TestCase):
    def test_stage_preserve_and_missing_source(self):
        with tempfile.TemporaryDirectory() as folder:
            source = Path(folder) / "source"
            runtime = Path(folder) / "runtime"
            runtime.mkdir()
            for rel, _ in PAIRS:
                f = source / rel
                f.parent.mkdir(parents=True, exist_ok=True)
                f.write_text("ES2M SOURCE", encoding="utf-8")
            existing = runtime / PAIRS[0][0]
            existing.parent.mkdir(parents=True, exist_ok=True)
            existing.write_text("ORIGINAL", encoding="utf-8")
            result = import_foreman(source, runtime)
            self.assertTrue(any("DIFF_REVIEW" in x for x in result))
            self.assertTrue(any("STAGED" in x for x in result))
            self.assertEqual(existing.read_text(), "ORIGINAL")
            self.assertEqual((runtime / PAIRS[1][0]).read_text(), "ES2M SOURCE")
            again = import_foreman(source, runtime)
            self.assertTrue(all("IDENTICAL" in x or "DIFF_REVIEW" in x for x in again))
            self.assertTrue(any("IDENTICAL" in x for x in again))
            (source / PAIRS[1][0]).unlink()
            with self.assertRaises(FileNotFoundError):
                import_foreman(source, runtime)

if __name__ == "__main__":
    unittest.main()
