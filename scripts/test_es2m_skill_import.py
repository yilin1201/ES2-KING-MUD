#!/usr/bin/env python3
"""ES2M skill snapshot and generated Runtime static integrity check; not gameplay proof."""
from pathlib import Path
import sys

snapshot = Path("es2m_snapshot/mudlib/daemon/skill")
runtime = Path(sys.argv[1]) / "mudlib/daemon/skill" if len(sys.argv) > 1 else None
expected = (
    "archaic_attainment axe blade blunt dagger literate mysticism needle pike sanmeendo "
    "secondhand_axe secondhand_blade secondhand_blunt secondhand_dagger secondhand_needle "
    "secondhand_pike secondhand_staff secondhand_sword staff sword taoism-fire taoism-freeze "
    "taoism-spells taoism-storm taoism-thunder tiger-blade tiger-force tiger-steps "
    "twohanded_axe twohanded_blade twohanded_blunt twohanded_pike twohanded_staff "
    "twohanded_sword unarmed whip"
).split()
errors = []
for skill in expected:
    source = snapshot / (skill + ".c")
    if not source.is_file() or not source.read_text().strip():
        errors.append("missing or empty ES2M skill source: " + skill)
    if runtime is not None:
        target = runtime / (skill + ".c")
        if not target.is_file() or not target.read_text().strip():
            errors.append("missing or empty runtime skill: " + skill)
if errors:
    raise SystemExit("ES2M_SKILL_IMPORT_FAIL\n" + "\n".join(errors))
print(f"ES2M_SKILL_IMPORT_STATIC_PASS count={len(expected)} runtime_checked={runtime is not None}")
