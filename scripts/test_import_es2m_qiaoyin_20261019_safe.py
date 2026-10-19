#!/usr/bin/env python3
"""隔離測試 2026-10-19 橋隱區安全匯入：SHA、衝突、相依與固定來源閘門。"""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import import_es2m_qiaoyin_20261019_safe as importer


def manifest_row(path: str, data: bytes, status: str = "NEW_TO_EXISTING_ES2M_SNAPSHOT") -> dict:
    return {"path": path, "sha": importer.git_blob_sha(data), "status": status}


class Qiaoyin20261019ImportTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / "source"
        self.runtime = self.root / "runtime"
        self.source.mkdir()
        self.runtime.mkdir()
        self.manifest_path = self.root / "manifest.json"
        self.output_path = self.root / "report.json"

    def tearDown(self) -> None:
        self.temp.cleanup()

    def write_source(self, rel: str, text: str) -> bytes:
        path = self.source / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        data = text.encode("utf-8")
        path.write_bytes(data)
        return data

    def write_manifest(self, rows: list[dict], commit: str = importer.EXPECTED_SOURCE_COMMIT) -> None:
        self.manifest_path.write_text(json.dumps({
            "source_commit": commit,
            "files": rows,
        }), encoding="utf-8")

    def test_stages_new_room_after_sha_validation(self) -> None:
        data = self.write_source("d/qiaoyin/inn.c", '#include <room.h>\nvoid create() {}\n')
        self.write_manifest([manifest_row("d/qiaoyin/inn.c", data)])
        report = importer.stage_import(self.source, self.runtime, self.manifest_path, self.output_path)
        self.assertEqual((self.runtime / "d/qiaoyin/inn.c").read_bytes(), data)
        self.assertEqual(report["staged"], ["d/qiaoyin/inn.c"])
        self.assertFalse(report["gameplay_runtime_pass"])

    def test_existing_conflicting_room_is_never_overwritten(self) -> None:
        data = self.write_source("d/qiaoyin/inn.c", "void create() { set(\"short\", \"upstream\"); }\n")
        target = self.runtime / "d/qiaoyin/inn.c"
        target.parent.mkdir(parents=True)
        target.write_text("void create() { set(\"short\", \"KING\"); }\n", encoding="utf-8")
        before = target.read_bytes()
        self.write_manifest([manifest_row("d/qiaoyin/inn.c", data)])
        with self.assertRaises(importer.ImportBlocked):
            importer.stage_import(self.source, self.runtime, self.manifest_path, self.output_path)
        self.assertEqual(target.read_bytes(), before)
        self.assertFalse(self.output_path.exists())

    def test_unresolved_external_dependency_blocks_without_partial_copy(self) -> None:
        data = self.write_source(
            "d/qiaoyin/inn.c",
            'void create() { set("north", "/d/missing/unknown"); }\n',
        )
        self.write_manifest([manifest_row("d/qiaoyin/inn.c", data)])
        with self.assertRaises(importer.ImportBlocked):
            importer.stage_import(self.source, self.runtime, self.manifest_path, self.output_path)
        self.assertFalse((self.runtime / "d/qiaoyin/inn.c").exists())

    def test_existing_runtime_dependency_wins_over_changed_upstream_dependency(self) -> None:
        room = self.write_source(
            "d/qiaoyin/inn.c",
            'void create() { set("keeper", __DIR__ "npc/keeper"); }\n',
        )
        npc = self.write_source("d/qiaoyin/npc/keeper.c", "void create() { /* upstream */ }\n")
        npc_runtime = self.runtime / "d/qiaoyin/npc/keeper.c"
        npc_runtime.parent.mkdir(parents=True)
        npc_runtime.write_text("void create() { /* KING-preserved */ }\n", encoding="utf-8")
        self.write_manifest([
            manifest_row("d/qiaoyin/inn.c", room),
            manifest_row("d/qiaoyin/npc/keeper.c", npc, "CHANGED_FROM_EXISTING_ES2M_SNAPSHOT"),
        ])
        report = importer.stage_import(self.source, self.runtime, self.manifest_path, self.output_path)
        self.assertEqual((self.runtime / "d/qiaoyin/inn.c").read_bytes(), room)
        self.assertIn("KING-preserved", npc_runtime.read_text(encoding="utf-8"))
        self.assertEqual(report["resolved_dependencies"][0]["location"], "existing_runtime_preserved")

    def test_wrong_source_pin_is_rejected(self) -> None:
        data = self.write_source("d/qiaoyin/inn.c", "void create() {}\n")
        self.write_manifest([manifest_row("d/qiaoyin/inn.c", data)], commit="71693beb")
        with self.assertRaises(importer.ImportBlocked):
            importer.stage_import(self.source, self.runtime, self.manifest_path, self.output_path)
        self.assertFalse((self.runtime / "d/qiaoyin/inn.c").exists())


if __name__ == "__main__":
    unittest.main()
