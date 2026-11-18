#!/usr/bin/env python3
"""雪亭房間補檔隔離測試。"""
import tempfile
import unittest
from pathlib import Path
from import_es2m_snow_rooms_safe import stage

class RoomStageTest(unittest.TestCase):
    def test_preserve_original_and_reject_missing_exit(self):
        with tempfile.TemporaryDirectory() as temp:
            src, dst = (Path(temp)/name for name in ("snapshot","runtime"))
            for base in (src,dst):
                (base/"d/snow").mkdir(parents=True)
            (src/"d/snow/known.c").write_text('inherit ROOM;')
            (src/"d/snow/new.c").write_text('inherit ROOM; __DIR__"known"')
            (src/"d/snow/bad.c").write_text('inherit ROOM; __DIR__"unknown"')
            (dst/"d/snow/known.c").write_text('Original')
            report=stage(src,dst)
            self.assertEqual(report["staged"],["d/snow/new.c"])
            self.assertEqual(len(report["unresolved_exits"]),1)
            self.assertEqual((dst/"d/snow/known.c").read_text(),"Original")
            self.assertFalse((dst/"d/snow/bad.c").exists())
if __name__=="__main__":
    unittest.main()
