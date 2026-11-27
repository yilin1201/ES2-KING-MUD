#!/usr/bin/env python3
"""雪亭 NPC 保守導入隔離測試。"""
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from import_es2m_snow_npc_safe import stage

class StageTest(unittest.TestCase):
    def test_missing_only_and_dependency_review(self):
        with tempfile.TemporaryDirectory() as tmp:
            src, dst = Path(tmp)/"snapshot", Path(tmp)/"runtime"
            for base in (src,dst):
                (base/"d/snow/npc").mkdir(parents=True)
            (src/"d/snow/npc/a.c").write_text("source a")
            (src/"d/snow/npc/b.c").write_text("source b")
            (src/"d/snow/npc/c.c").write_text("source c")
            (dst/"d/snow/npc/a.c").write_text("Original a")
            rows=[{"source":f"d/snow/npc/{name}.c","source_present":True,
                   "missing_dependencies":missing,"staged_dependencies":[]}
                  for name,missing in (("a",[]),("b",[]),("c",["unknown.c"]))]
            with patch("import_es2m_snow_npc_safe.audit",return_value={"records":rows}):
                result=stage(src,dst)
            self.assertEqual(len(result["staged"]),1)
            self.assertEqual(len(result["preserved_existing"]),1)
            self.assertEqual(len(result["dependency_review"]),1)
            self.assertEqual((dst/"d/snow/npc/a.c").read_text(),"Original a")
            self.assertFalse((dst/"d/snow/npc/c.c").exists())
if __name__ == "__main__":
    unittest.main()
