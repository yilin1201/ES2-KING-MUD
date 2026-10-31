#!/usr/bin/env python3
"""ES2M 鬼魂來源／Runtime 相依完整性靜態檢查；不宣稱 Gameplay PASS。"""
from pathlib import Path
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("es2m_snapshot/mudlib")
ghost = root / "custom/ghost"
names = ("hungry_ghost", "mountain_sprite", "tiger_thrall",
         "wandering_soul", "water_goblin", "wronged_ghost")
base = ghost / "std_ghost.c"
errors = []
if not base.is_file():
    errors.append("missing custom/ghost/std_ghost.c")
else:
    content = base.read_text()
    for required in ("inherit NPC;", "void setup_ghost(", "int accept_fight("):
        if required not in content:
            errors.append(f"std_ghost.c missing {required}")
for name in names:
    p = ghost / "npc" / (name + ".c")
    if not p.is_file():
        errors.append(f"missing {p}")
        continue
    content = p.read_text()
    if 'inherit "/custom/ghost/std_ghost";' not in content:
        errors.append(f"{name}: missing original ghost base inheritance")
    if "setup_ghost(" not in content:
        errors.append(f"{name}: missing ghost setup")
if errors:
    print("ES2M_GHOST_INTEGRITY_FAIL\\n" + "\\n".join(errors))
    sys.exit(1)
print(f"ES2M_GHOST_INTEGRITY_PASS files={len(names)+1}")
