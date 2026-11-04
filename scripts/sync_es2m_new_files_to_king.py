#!/usr/bin/env python3
"""Sync latest ES2M source into the KING runtime overlay.

ES2M is authoritative for source paths, but the KING-only owner skill-cap
extension must remain intact until its changes are explicitly merged with
the newest ES2M progression implementation.

本工具將最新 ES2M Mudlib 同步至 KING Runtime Overlay：
同路徑覆蓋、缺少路徑新增、不刪除 KING-only 檔案。
保留 KING Owner 300 級技能上限、三項凍結冷梅武功、teacher.c 的 Original race ID rainnar 修正、梅影風 NPC 的入門門檻與種族相容邏輯，以及潛行的 Original API 相容公式；
ES2M 原始版本仍完整保存在來源鏡像，保護檔案逐項記錄於同步報告。
"""
from __future__ import annotations
import argparse, hashlib, json, shutil
from pathlib import Path

# KING 專屬核心檔：含唯一 admin KING 的 300 級上限，不能被 ES2M 原檔盲目取代。
PROTECTED_KING_PATHS = {
    "feature/char/skill.c",
    "daemon/skill/advance_lunmay.c",
    "daemon/skill/hainmay_force.c",
    "daemon/skill/lunmay.c",
    "d/snow/npc/teacher.c",
    "d/wutang/npc/may_yin_fong.c",
    "cmds/std/sneak.c",
    "custom/zhenwu/npc/lu_xinien.c",
    "custom/zhenwu/npc/mee_pei.c",
    "custom/zhenwu/npc/soldier.c",
    "custom/zhenwu/npc/zhenwu_soldier.c",
    "custom/zhenwu/obj/recruit_stone.c",
    # 李家村路網：保留 KING 已確認的拓樸修正，避免上游房間程式缺少 LEE_TOPOLOGY 已登錄出口。
    "d/lee/square_s.c",
    "d/lee/square_c.c",
    "d/lee/watermelon_n1.c",
    "d/lee/pawnshop.c",
    "d/lee/watermelon_s3.c",
    "d/lee/creek.c",
    "d/lee/wroad3.c",
    "d/lee/square_w.c",
    # KING WebTelnet 內部 MUD listener 使用 4000；上游 globals.h 的 4001 不可直接覆蓋 Runtime。
    "include/globals.h",
}
KING_ZHENWU_GUARDS = {
    "custom/zhenwu/npc/lu_xinien.c": (
        'set("nickname","徵兵官")', 'set_level(25)', 'set_power("B")',
        '/custom/weapon/blade/steelblade',
    ),
    "custom/zhenwu/npc/mee_pei.c": (
        'set_attr("str", 40)', 'set_stat_maximum("gin", 600)',
        'set_skill("berserk", 180)', 'set_skill("twohanded axe", 150)',
        'set_power("A")', 'HEAVY_PARRY_MERIT 100000',
        'improve_skill_exact("heavy_parry", 1)', '/obj/books/book_of_assault',
    ),
    "custom/zhenwu/npc/soldier.c": (
        'set_level(5)', 'set_power("B")', 'set_stat_maximum("gin", 120)',
        'set_stat_maximum("kee", 100)', 'set_stat_maximum("sen", 40)',
    ),
    "custom/zhenwu/npc/zhenwu_soldier.c": (
        'set_level(15)', 'set_power("C")', 'set_attr("str", 25)',
        'set_attr("cor", 22)', 'set_attr("con", 20)',
        'set_skill("twohanded pike", 60)', 'set_skill("unarmed", 60)',
    ),
    "custom/zhenwu/obj/recruit_stone.c": (
        'set("custom_faction", "soldier.ber")',
        'set("soldier/from_fighter", 1)',
        '強力格擋改由米沛傳授',
    ),
}
KING_RUNTIME_PORT_GUARDS = {
    "include/globals.h": "#define MUD_PORT 4000",
}
KING_LEE_TOPOLOGY_GUARDS = {
    "d/lee/square_s.c": '"south" : __DIR__"pawnshop"',
    "d/lee/square_c.c": '"east" : __DIR__"watermelon_n1"',
    "d/lee/watermelon_n1.c": '"west" : __DIR__"square_c"',
    "d/lee/pawnshop.c": '"north" : __DIR__"square_s"',
    "d/lee/watermelon_s3.c": '"east" : __DIR__"creek"',
    "d/lee/creek.c": '"west" : __DIR__"watermelon_s3"',
    "d/lee/wroad3.c": '"east" : __DIR__"square_w"',
    "d/lee/square_w.c": '"west" : __DIR__"wroad3"',
}
KING_RACE_COMPAT_PATHS = {"d/snow/npc/teacher.c"}
KING_NPC_COMPAT_PATHS = {"d/wutang/npc/may_yin_fong.c"}
KING_SNEAK_COMPAT_PATHS = {"cmds/std/sneak.c"}
FROZEN_KING_SKILLS = {
    "daemon/skill/advance_lunmay.c",
    "daemon/skill/hainmay_force.c",
    "daemon/skill/lunmay.c",
}

def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def verify_king_owner_guards(overlay: Path, repo_root: Path) -> None:
    """同步前後確認 KING Owner、凍結武功、種族相容及 NPC 技能門檻仍完整。"""
    checks = {
        "feature/char/skill.c": ("es2_king_skill_cap", 'query("id") == "king"'),
        "adm/daemons/kadmind.c": ('query("id") == "king"', "is_owner"),
        "cmds/adm/kadmin.c": ("K->is_owner(me)", "KING Owner"),
        "cmds/adm/admin.c": ("ES2-KING Expansion", "管理員"),
    }
    for rel, markers in checks.items():
        path = overlay / rel
        if not path.is_file():
            raise SystemExit(f"FAIL: required KING owner guard missing: {rel}")
        raw = path.read_text(encoding="utf-8", errors="replace")
        for marker in markers:
            if marker not in raw:
                raise SystemExit(f"FAIL: KING owner guard marker missing in {rel}: {marker}")

    # 冷梅劍法、寒梅心法、傲梅暗劍訣：逐位元保留已確認 KING Frozen Baseline。
    for rel in FROZEN_KING_SKILLS:
        baseline = repo_root / "es2m_snapshot/king_frozen_baseline" / rel
        target = overlay / rel
        if not baseline.is_file() or not target.is_file():
            raise SystemExit(f"FAIL: frozen KING martial baseline missing: {rel}")
        if digest(baseline) != digest(target):
            raise SystemExit(f"FAIL: frozen KING martial baseline mismatch: {rel}")

    # Original ES2 種族代碼 rainnar：ES2M teacher.c 的 rainner 拼字不能覆蓋正式代碼。
    for rel in KING_RACE_COMPAT_PATHS:
        target = overlay / rel
        if not target.is_file():
            raise SystemExit(f"FAIL: KING race compatibility file missing: {rel}")
        raw = target.read_text(encoding="utf-8", errors="replace")
        if '"avatar", "human", "rainnar", "malik"' not in raw or '"rainner"' in raw:
            raise SystemExit(f"FAIL: KING Original race ID correction missing: {rel}")

    # 梅影風傳授：依技能真正入門等級補足門檻，並使用 Original race ID rainnar。
    for rel in KING_NPC_COMPAT_PATHS:
        target = overlay / rel
        if not target.is_file():
            raise SystemExit(f"FAIL: KING Cold Plum NPC compatibility file missing: {rel}")
        raw = target.read_text(encoding="utf-8", errors="replace")
        required = ('set_power("S");', '"custom_faction", FACTION',
                    "skill_entry_level(skill)", "skill_threshold(skill, entry_level)",
                    '"rainnar"')
        if any(token not in raw for token in required) or '"rainner"' in raw:
            raise SystemExit(f"FAIL: KING Cold Plum NPC progression/race guard missing: {rel}")

    # ES2M 潛行保留原始悟性公式；KING Runtime 使用本地 helper，避免呼叫 Original 不存在的 COMBAT_D API。
    for rel in KING_SNEAK_COMPAT_PATHS:
        target = overlay / rel
        if not target.is_file():
            raise SystemExit(f"FAIL: KING sneak compatibility file missing: {rel}")
        raw = target.read_text(encoding="utf-8", errors="replace")
        required = ("private int es2_king_sneak_int_formula_exp(object me)",
                    'me->improve_skill("sneak", me->query_attr("int"));',
                    "return (random(i) + 1) * (random(i) + 1) + random(i);",
                    "me->improve_skill(\"sneak\", es2_king_sneak_int_formula_exp(me));")
        if any(token not in raw for token in required) or "COMBAT_D->int_formula_exp(me)" in raw:
            raise SystemExit(f"FAIL: KING sneak compatibility formula missing: {rel}")

    # 振武軍營五個檔案已完成 ES2M／KING 逐檔合併，未來同步只保留此已驗證合併版本。
    for rel, required in KING_ZHENWU_GUARDS.items():
        target = overlay / rel
        if not target.is_file():
            raise SystemExit(f"FAIL: merged KING Zhenwu file missing: {rel}")
        raw = target.read_text(encoding="utf-8", errors="replace")
        if any(token not in raw for token in required):
            raise SystemExit(f"FAIL: merged KING Zhenwu guard missing in {rel}")
    stone = (overlay / "custom/zhenwu/obj/recruit_stone.c").read_text(encoding="utf-8", errors="replace")
    if 'me->set_skill("heavy_parry", 1);' in stone or 'me->set_learn("heavy_parry", 1);' in stone:
        raise SystemExit("FAIL: recruit stone must not bypass Mee Pei heavy_parry teaching")

    # KING WebTelnet listener／上游 MUD_PORT 4001 與 KING neolith.conf Port 4000 不一致，Runtime 必須固定 4000。
    for rel, marker in KING_RUNTIME_PORT_GUARDS.items():
        path = overlay / rel
        if not path.is_file():
            raise SystemExit(f"FAIL: KING Runtime port header missing: {rel}")
        raw = path.read_text(encoding="utf-8", errors="replace")
        if marker not in raw:
            raise SystemExit(f"FAIL: KING Runtime port contract missing in {rel}: {marker}")

    # 李家村出口相容：依最新 ES2M LEE_TOPOLOGY.json 保留已修正的雙向路線。
    for rel, marker in KING_LEE_TOPOLOGY_GUARDS.items():
        path = overlay / rel
        if not path.is_file():
            raise SystemExit(f"FAIL: KING Lee topology compatibility file missing: {rel}")
        raw = path.read_text(encoding="utf-8", errors="replace")
        if marker not in raw:
            raise SystemExit(f"FAIL: KING Lee topology route missing in {rel}: {marker}")

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", required=True, type=Path, help="latest ES2M mirror mudlib")
    ap.add_argument("--original", required=True, type=Path, help="pinned Original ES2 mudlib, read-only comparison")
    ap.add_argument("--overlay", required=True, type=Path, help="KING runtime overlay destination")
    ap.add_argument("--report", required=True, type=Path)
    a = ap.parse_args()

    for p in (a.source, a.original):
        if not p.is_dir():
            raise SystemExit(f"FAIL: required directory missing: {p}")
    a.overlay.mkdir(parents=True, exist_ok=True)
    verify_king_owner_guards(a.overlay, Path(__file__).resolve().parents[1])

    source_files = sorted(p for p in a.source.rglob("*") if p.is_file())
    copied_new, overwritten, unchanged, original_conflicts, preserved_king = [], [], [], [], []

    for src in source_files:
        rel = src.relative_to(a.source)
        rel_name = rel.as_posix()
        original = a.original / rel
        dest = a.overlay / rel
        src_hash = digest(src)

        if original.exists() and src_hash != digest(original):
            original_conflicts.append({
                "path": rel_name,
                "status": "ES2M-differs-from-pinned-original",
                "source_sha256": src_hash,
                "original_sha256": digest(original),
            })

        # KING Owner、凍結武學、種族代碼與 NPC 成長保護檔；先保留已驗證 KING 版本。
        # 最新 ES2M 原始檔仍完整保存於 es2m_source_mirror，供後續逐段合併。
        if rel_name in PROTECTED_KING_PATHS:
            if not dest.is_file():
                raise SystemExit(f"FAIL: protected KING file missing: {rel_name}")
            if rel_name == "feature/char/skill.c":
                king_text = dest.read_text(encoding="utf-8", errors="replace")
                if "es2_king_skill_cap" not in king_text or 'query("id") == "king"' not in king_text:
                    raise SystemExit(f"FAIL: protected KING owner skill cap not verified: {rel_name}")
                status = "preserved-KING-owner-customization-pending-ES2M-merge"
            elif rel_name in FROZEN_KING_SKILLS:
                baseline = Path(__file__).resolve().parents[1] / "es2m_snapshot/king_frozen_baseline" / rel
                if not baseline.is_file() or digest(dest) != digest(baseline):
                    raise SystemExit(f"FAIL: frozen KING martial baseline mismatch: {rel_name}")
                status = "preserved-KING-frozen-martial-baseline"
            elif rel_name in KING_RACE_COMPAT_PATHS:
                raw = dest.read_text(encoding="utf-8", errors="replace")
                if '"avatar", "human", "rainnar", "malik"' not in raw or '"rainner"' in raw:
                    raise SystemExit(f"FAIL: KING Original race ID correction missing: {rel_name}")
                status = "preserved-KING-original-race-id-correction"
            elif rel_name in KING_NPC_COMPAT_PATHS:
                raw = dest.read_text(encoding="utf-8", errors="replace")
                required = ('set_power("S");', '"custom_faction", FACTION',
                            "skill_entry_level(skill)", "skill_threshold(skill, entry_level)",
                            '"rainnar"')
                if any(token not in raw for token in required) or '"rainner"' in raw:
                    raise SystemExit(f"FAIL: KING Cold Plum NPC progression/race guard missing: {rel_name}")
                status = "preserved-KING-cold-plum-NPC-progression-and-race"
            elif rel_name in KING_SNEAK_COMPAT_PATHS:
                raw = dest.read_text(encoding="utf-8", errors="replace")
                required = ("private int es2_king_sneak_int_formula_exp(object me)",
                            'me->improve_skill("sneak", me->query_attr("int"));',
                            "return (random(i) + 1) * (random(i) + 1) + random(i);",
                            "me->improve_skill(\"sneak\", es2_king_sneak_int_formula_exp(me));")
                if any(token not in raw for token in required) or "COMBAT_D->int_formula_exp(me)" in raw:
                    raise SystemExit(f"FAIL: KING sneak compatibility formula missing: {rel_name}")
                status = "preserved-KING-ES2M-sneak-progression-adapter"
            elif rel_name in KING_ZHENWU_GUARDS:
                raw = dest.read_text(encoding="utf-8", errors="replace")
                required = KING_ZHENWU_GUARDS[rel_name]
                if any(token not in raw for token in required):
                    raise SystemExit(f"FAIL: merged KING Zhenwu guard missing: {rel_name}")
                if rel_name == "custom/zhenwu/obj/recruit_stone.c" and (
                    'me->set_skill("heavy_parry", 1);' in raw
                    or 'me->set_learn("heavy_parry", 1);' in raw
                ):
                    raise SystemExit("FAIL: recruit stone must not bypass Mee Pei heavy_parry teaching")
                status = "preserved-KING-ES2M-Zhenwu-merged"
            elif rel_name in KING_RUNTIME_PORT_GUARDS:
                status = "preserved-KING-WebTelnet-port-compatibility"
            elif rel_name in KING_LEE_TOPOLOGY_GUARDS:
                status = "preserved-KING-LEE-topology-compatibility"
            else:
                raise SystemExit(f"FAIL: unclassified protected KING path: {rel_name}")
            preserved_king.append({
                "path": rel_name,
                "status": status,
                "king_sha256": digest(dest),
                "es2m_sha256": src_hash,
            })
            continue

        if dest.exists():
            dest_hash = digest(dest)
            if dest_hash == src_hash:
                unchanged.append({
                    "path": rel_name,
                    "status": "already-matches-ES2M",
                    "sha256": src_hash,
                })
                continue
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            overwritten.append({
                "path": rel_name,
                "status": "overwritten-existing-KING-file",
                "previous_king_sha256": dest_hash,
                "source_sha256": src_hash,
            })
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            copied_new.append({
                "path": rel_name,
                "status": "copied-new-path",
                "sha256": src_hash,
            })

    # 寫入後再次驗證，確保 KING Owner 權限檔案仍存在。
    verify_king_owner_guards(a.overlay, Path(__file__).resolve().parents[1])

    report = {
        "policy": "ES2M-source-authoritative-for-matching-paths; overwrite same-path overlay files except protected KING owner skill-cap file; never delete KING-only files; pinned Original ES2 is read-only",
        "source_root": str(a.source),
        "original_reference_root": str(a.original),
        "overlay_root": str(a.overlay),
        "source_file_count": len(source_files),
        "copied_new_count": len(copied_new),
        "overwritten_existing_king_count": len(overwritten),
        "already_matching_count": len(unchanged),
        "preserved_king_custom_count": len(preserved_king),
        "source_differs_from_pinned_original_count": len(original_conflicts),
        "copied_new": copied_new,
        "overwritten_existing_king": overwritten,
        "already_matching": unchanged,
        "preserved_king_custom": preserved_king,
        "source_differs_from_pinned_original": original_conflicts,
    }
    a.report.parent.mkdir(parents=True, exist_ok=True)
    a.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in report.items() if not isinstance(v, list)}, ensure_ascii=False, indent=2))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
