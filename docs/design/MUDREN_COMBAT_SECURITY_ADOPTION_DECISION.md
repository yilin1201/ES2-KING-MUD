# MudRen combat and security re-evaluation — ES2-KING safe adoption

Decision: **retain current KING/ES2M implementation; adopt historical design checks, not historical executable code**.

Evidence pins:
- KING branch comparison: `8414806b2f6a70acb461b61b60d99a791a0c8f55`.
- MudRen historical revision: `ec567210d84907f89a8566ffa5f8ce807873fb22`.
- Historical combat design: https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib/daemon/combatd
- Historical combat implementation: https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/adm/daemons/combatd.c
- Historical security design: https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib/security
- Historical security implementation: https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/adm/daemons/securityd.c
- Existing KING reference implementation: `es2m_snapshot/mudlib/feature/char/combat.c` and `es2_king_expansion/runtime/mudlib/adm/daemons/kingd.c`.

## 1. Combat: exact source-backed comparison

Historical documentation explains that `heart_beat()` drives combat rounds and common arbitration is centralized in a Combat Daemon for hot-update and shared-memory reasons. The historical `combatd.c` contains `fight(me, victim, skill, action, weapon)` and reads the action mapping (including `action["action"]`, `action["force"]`, `action["attack"]`, `action["damage_type"]`). **It does not establish a universal damage formula for the current KING Runtime.**

The KING-pinned ES2M snapshot also has character-side responsibilities: `feature/char/attack.c` tracks opponents/guarding and starts heartbeat; `feature/char/combat.c` defines `query_strength`, `query_ability`, `defend`, and `absorb`. Hence "all combat happens only in the daemon" would be false. Keep the split between character state, combat arbitration, and specific skill/action definitions. The snapshot is not proof that the currently generated isolated Runtime is identical.

**Adoption:** no legacy daemon overlay, no martial-arts formula or narration changes. If an isolated ordinary-player combat FAIL is reproduced, trace `attack → combat daemon → character defend/absorb → receive_damage` in the *actual generated Runtime*, then patch only the demonstrated defect. Reuse `scripts/test_player_open_alpha_e2e.sh` and existing combat-balance instrumentation; require actual nonempty Driver damage samples before claiming damage/balance PASS. The Lv.50/100/150/200 balance matrix remains separately pending.

## 2. Security: exact source-backed comparison

Historical `securityd.c` uses uid/euid and a WIZLIST-backed `wiz_status` mapping; the reserved status labels include `(player)`, `(wizard)`, `(arch)`, and `(admin)`. Its `valid_write` uses directory-level trust/exclusion checks. Its source explicitly distinguishes reserved `(admin)` from a player-chosen name. These are **historical architectural facts**, not proof that the KING Runtime has identical filesystem policies.

Current KING Expansion `kingd.c` requires all three: `interactive(actor)`, `actor->query("id") == "king"`, and `wiz_level(actor) >= wiz_level("(admin)")`. The exact ID must be established through authenticated Original login; display name must never confer Owner authority. The historical UID/EUID model complements, but cannot replace, KING's Owner identity boundary.

**Adoption:** retain `kingd.c` and existing owner reservation. Reuse `scripts/test_king_owner_authorization_static.sh`, `scripts/test_m30_final_runtime_permissions.sh`, and fresh-player security checks. Runtime must demonstrate (a) a regular account displayed as KING cannot call Owner-only commands; (b) an ordinary player cannot read/write protected files through game commands; (c) `king` only obtains Owner authority after authenticated login. Do not infer OS/Render/GitHub credentials from in-game authority. A source-level check alone is STATIC, not Runtime PASS.

## 3. Implementation and release boundary

| Item | Decision | Evidence status |
| --- | --- | --- |
| Legacy combat daemon | Do not copy/replace | Historical source reviewed |
| Existing character/daemon combat split | Preserve and diagnose actual failures | Source-level comparison; latest Runtime unverified |
| Original UID/EUID and WIZLIST design | Use as security review reference | Historical source reviewed |
| Existing KING Owner triple check | Preserve | Current KING source reviewed; latest Runtime unverified |
| New game mechanics / damage formula | None in this decision | Not claimed |
| Fresh ordinary-player journey | Reuse existing isolated Driver tests | **BLOCKED** until latest-HEAD Driver logs exist |
| Production Render / Hero MUD | No action | Explicitly excluded |

**Acceptance gate:** no gameplay PASS from this document or GitHub commit. Use matching `TESTED_HEAD` logs and the existing `scripts/playable_release_gate.py` before calling the current HEAD release-ready. If Work is concurrently editing Runtime, coordinate via fresh HEAD and avoid editing the same files.
