#!/usr/bin/env python3
"""Tests for the pinned ES2M account/display-name policy adapter."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import apply_es2m_login_policy_runtime as policy


ORIGINAL = r"""
int check_legal_id (string id) {
    int i;
    i = strlen (id);
    if ((i < 3) || (i > 12 )) {
        write ("您的使用者代號必須是 3 到 12 個英文字母。\n");
        return 0;
    }
    while (i--)
        if ((id[i]<'a') || (id[i]>'z')) {
            write("您的使用者代號只能由 a 到 z 的英文字母組成。\n");
            return 0;
        }
    return 1;
}
int check_legal_name(string name) {
    int i;
    string* mbcs = explode(name, "");
    i = sizeof(mbcs);
    if ((i < 3) || (i > 18 )) {
        write("您的顯示名稱必須使用長度 3 到 18 的合法 UTF-8 文字。\n");
        return 0;
    }
    return 1;
}
"""


class Es2mLoginPolicyTests(unittest.TestCase):
    def test_applies_es2m_alphanumeric_account_and_single_character_name(self):
        updated = policy.apply(ORIGINAL)
        self.assertIn(policy.ID_CHAR_ES2M, updated)
        self.assertIn(policy.ID_ERROR_ES2M, updated)
        self.assertIn(policy.ID_MARKER, updated)
        self.assertIn(policy.NAME_CONDITION_ES2M, updated)
        self.assertIn(policy.NAME_ERROR_ES2M, updated)
        self.assertIn(policy.NAME_MARKER, updated)
        self.assertNotIn(policy.ID_CHAR_ORIGINAL, updated)
        self.assertNotIn(policy.NAME_CONDITION_ORIGINAL, updated)

    def test_is_idempotent(self):
        updated = policy.apply(ORIGINAL)
        self.assertEqual(policy.apply(updated), updated)

    def test_refuses_unknown_or_drifted_original_policy(self):
        with self.assertRaises(SystemExit):
            policy.apply("int check_legal_id(string id) { return 1; }")


if __name__ == "__main__":
    unittest.main()
