#!/usr/bin/env python3
"""ES2M 技能三方稽核隔離測試。"""
import tempfile
import unittest
from pathlib import Path
from audit_es2m_skill_three_way import audit

class SkillAuditTest(unittest.TestCase):
    def test_identical_original_and_variant(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            src, org, run = (root / name for name in ("source", "original", "runtime"))
            for base in (src, org, run):
                (base / "daemon/skill").mkdir(parents=True)
            def write(base, name, content):
                (base / "daemon/skill" / name).write_text(content)
            write(src, "new.c", "ES2M")
            write(run, "new.c", "ES2M")
            write(src, "shared.c", "ES2M")
            write(org, "shared.c", "ORIGINAL")
            write(run, "shared.c", "ORIGINAL")
            write(src, "variant.c", "ES2M")
            write(org, "variant.c", "ORIGINAL")
            write(run, "variant.c", "KING")
            write(src, "missing.c", "ES2M")
            result = audit(src, org, run)
            statuses = {row["skill"]: row["status"] for row in result["records"]}
            self.assertEqual(statuses, {
                "missing.c": "MISSING_RUNTIME",
                "new.c": "ES2M_IDENTICAL",
                "shared.c": "ORIGINAL_PRESERVED_ES2M_CONFLICT_REVIEW",
                "variant.c": "RUNTIME_VARIANT_REVIEW",
            })
if __name__ == "__main__":
    unittest.main()
