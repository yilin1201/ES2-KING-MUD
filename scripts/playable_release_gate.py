#!/usr/bin/env python3
"""ES2-KING：僅核對證據日誌與版本，不自動部署。"""
import argparse
import re
from pathlib import Path

SHA = re.compile(r"^[a-f0-9]{40}$")
REQUIRED = {
    "offline": ("ES2_INDEPENDENT_OFFLINE_TESTS_PASS",),
    "armor": ("ES2_ARMOR_PLAYER_SECURITY_PASS", "ES2_ARMOR_LOAD_PASS",
              "ES2_ARMOR_FIVE_SLOTS_PASS", "ES2_ARMOR_RESTRICTIONS_PASS",
              "ES2_ARMOR_UNIQUE_PASS", "ES2_ARMOR_CORROSIVE_HANDS_PASS",
              "ES2_ARMOR_PERSISTENCE_PASS", "ES2M_ARMOR_RUNTIME_E2E_PASS"),
    "affix": ("ES2_AFFIX_PLAYER_SECURITY_PASS", "ES2_AFFIX_LOAD_PASS",
              "ES2_AFFIX_EQUIP_PASS", "ES2_AFFIX_STORAGE_PERSISTENCE_PASS",
              "ES2M_WEAPON_AFFIX_RUNTIME_E2E_PASS"),
}

def audit(head, evidence, live_sha=None, public_log=None):
    problems = []
    if not SHA.fullmatch(head):
        return ["HEAD 必須是完整 40 字元 SHA"]
    for label, markers in REQUIRED.items():
        file = evidence.get(label)
        if not file or not file.is_file():
            problems.append(f"{label}: 缺少實測日誌")
            continue
        lines = file.read_text(encoding="utf-8").splitlines()
        if f"TESTED_HEAD={head}" not in lines:
            problems.append(f"{label}: 實測 SHA 與 HEAD 不一致")
        for marker in markers:
            if marker not in lines:
                problems.append(f"{label}: 缺少 {marker}")
    if public_log is not None or live_sha is not None:
        if live_sha != head:
            problems.append("Render Live SHA 與驗證 HEAD 不一致")
        if public_log is None or not public_log.is_file():
            problems.append("缺少公開普通玩家實測日誌")
        else:
            lines = public_log.read_text(encoding="utf-8").splitlines()
            for marker in (f"DEPLOYED_SHA={head}", "PUBLIC_ORDINARY_PLAYER_GAMEPLAY_PASS"):
                if marker not in lines:
                    problems.append(f"public: 缺少 {marker}")
    return problems

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--head", required=True)
    for label in REQUIRED:
        p.add_argument(f"--{label}-log", type=Path, required=True)
    p.add_argument("--live-sha")
    p.add_argument("--public-log", type=Path)
    a = p.parse_args()
    problems = audit(a.head, {label: getattr(a, label + "_log") for label in REQUIRED},
                     a.live_sha, a.public_log)
    if problems:
        for reason in problems:
            print("BLOCKED:", reason)
        raise SystemExit(1)
    print("RELEASE_EVIDENCE_READY" if a.public_log is not None
          else "PREDEPLOY_EVIDENCE_READY (not public gameplay PASS)")

if __name__ == "__main__":
    main()
