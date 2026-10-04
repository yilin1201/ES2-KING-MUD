import tempfile
import unittest
from pathlib import Path
from playable_release_gate import REQUIRED, audit

HEAD = "a" * 40

class GateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.logs = {}
        for label, markers in REQUIRED.items():
            file = Path(self.temp.name) / (label + ".log")
            file.write_text("\n".join([f"TESTED_HEAD={HEAD}", *markers]) + "\n",
                            encoding="utf-8")
            self.logs[label] = file

    def test_predeploy_does_not_claim_public(self):
        self.assertEqual(audit(HEAD, self.logs), [])

    def test_missing_playability_blocks(self):
        del self.logs["playability"]
        self.assertIn("playability: 缺少實測日誌", audit(HEAD, self.logs))

    def test_incomplete_gameplay_blocks(self):
        self.logs["playability"].write_text(
            f"TESTED_HEAD={HEAD}\\nGAME_PLAYABILITY_COMPLETION_RUNTIME_PASS\\n", encoding="utf-8")
        self.assertTrue(any("PLAYABILITY_PASS:" in x for x in audit(HEAD, self.logs)))

    def test_wrong_sha_blocks(self):
        self.assertTrue(audit("b"*40, self.logs))

    def test_missing_marker_blocks(self):
        self.logs["affix"].write_text(f"TESTED_HEAD={HEAD}\n", encoding="utf-8")
        self.assertTrue(audit(HEAD, self.logs))

    def test_public_needs_matching_live_sha(self):
        pub = Path(self.temp.name) / "public.log"
        pub.write_text(f"DEPLOYED_SHA={HEAD}\nPUBLIC_ORDINARY_PLAYER_GAMEPLAY_PASS\n")
        self.assertTrue(audit(HEAD, self.logs, "b"*40, pub))
        self.assertEqual(audit(HEAD, self.logs, HEAD, pub), [])

    def test_invalid_sha_blocks(self):
        self.assertTrue(audit("short", self.logs))

if __name__ == "__main__":
    unittest.main()
