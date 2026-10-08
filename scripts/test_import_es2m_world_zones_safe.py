#!/usr/bin/env python3
import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("import_es2m_world_zones_safe.py")


def load_module():
    spec = importlib.util.spec_from_file_location(
        "import_es2m_world_zones_safe", SCRIPT
    )
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class SafeWorldImportTest(unittest.TestCase):
    def run_main(self, module, snapshot, runtime, output):
        old = sys.argv
        try:
            sys.argv = [
                "import_es2m_world_zones_safe.py",
                "--snapshot", str(snapshot),
                "--runtime", str(runtime),
                "--output", str(output),
                "--zones", "d/lee",
            ]
            module.main()
        finally:
            sys.argv = old

    def test_stage_missing_files_and_literal_dependency(self):
        module = load_module()
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            snapshot = root / "snapshot"
            runtime = root / "runtime"
            output = root / "report.json"
            (snapshot / "d/lee/npc").mkdir(parents=True)
            (snapshot / "d/lee/entrance.c").write_text(
                'set("exits", (["north": __DIR__"npc/guard"]));\n',
                encoding="utf-8",
            )
            (snapshot / "d/lee/npc/guard.c").write_text(
                "inherit F_VILLAGER;\n", encoding="utf-8"
            )
            runtime.mkdir()
            self.run_main(module, snapshot, runtime, output)
            self.assertTrue((runtime / "d/lee/entrance.c").is_file())
            self.assertTrue((runtime / "d/lee/npc/guard.c").is_file())
            self.assertTrue(output.is_file())

    def test_conflict_is_blocked(self):
        module = load_module()
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            snapshot = root / "snapshot"
            runtime = root / "runtime"
            output = root / "report.json"
            (snapshot / "d/lee").mkdir(parents=True)
            (runtime / "d/lee").mkdir(parents=True)
            (snapshot / "d/lee/entrance.c").write_text("source\n", encoding="utf-8")
            (runtime / "d/lee/entrance.c").write_text("different\n", encoding="utf-8")
            with self.assertRaises(SystemExit):
                self.run_main(module, snapshot, runtime, output)


if __name__ == "__main__":
    unittest.main()
