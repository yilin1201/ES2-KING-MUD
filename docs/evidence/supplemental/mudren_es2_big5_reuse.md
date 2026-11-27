# MudRen ES2-big5 — historical cross-check and safe reuse registry

- Evidence type: `HISTORICAL_EVIDENCE` / early ES2 variant; **not** a runtime overlay.
- Upstream: https://github.com/MudRen/ES2-big5
- Audited immutable revision: `ec567210d84907f89a8566ffa5f8ce807873fb22` (`master`, checked 2026-10-05).
- Repository description: 東方故事２ mudlib v1.3b / FluffOS v2017.
- KING comparison revision: `4c8de7a1d3307c19a1a54d204da8bc4d77d5256e`.
- Priority: pinned Original ES2 > current ES2M supplemental source > MudRen historical cross-check > reconstruction. A historical document can explain design intent but cannot override a different version's actual code.

## Verified usable references and next action

| Scope | Exact historical source | Confirmed reference value | KING usage / decision |
| --- | --- | --- | --- |
| Autoload / item persistence | [doc/mudlib/feature/autoload](https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib/feature/autoload) | Documents `clean_up_autoload`, `save_autoload`, `restore_autoload`; on restore failure describes logging to `/log/AUTOLOAD`. | Use as a diagnosis checklist for ordinary-player inventory/equipment save→quit→relogin; check current KING implementation and actual Driver logs before changing persistence. No historical code imported. |
| Character save / restore | [doc/mudlib/feature/save](https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib/feature/save) | Documents `save()` and `restore()` responsibilities. | Distinguish player data save from item autoload and from external Neon sync; require isolated Driver evidence for each. |
| [Combat and security adoption decision](../../design/MUDREN_COMBAT_SECURITY_ADOPTION_DECISION.md) | Re-evaluated against historical implementations and KING's current source. | **Preserve existing combat and Owner code; reuse current isolated tests; no legacy overlay.** | See linked implementation decision and evidence boundaries. |
| Combat architecture | [doc/mudlib/daemon/combatd](https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib/daemon/combatd) | Documents heart_beat combat actions and why combat is isolated in a daemon. | Use for architecture/diagnostics only; no damage formula inferred and no changes to frozen KING martial arts. |
| Permissions | [doc/mudlib/security](https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib/security) | Describes uid/euid security model. | Cross-check normal-player vs `king` Owner boundary in isolated Runtime. Do not copy admin/wizlist settings from historical installation instructions. |
| Taoist historical plans | [doc/wiz/taoism-spells](https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/wiz/taoism-spells) | Lists named Taoist spell families including 天師、茅山、閣皂. | Historical **plan**, not proof of implemented spells, damage or acquisition conditions. Candidate list only; validate each against pinned Original and ES2M before proposing runtime import. |
| Snow town world | [d/snow](https://github.com/MudRen/ES2-big5/tree/ec567210d84907f89a8566ffa5f8ce807873fb22/d/snow) | Historical room/NPC/item snapshot for source-level topology comparison. | Compare only actual missing exits, NPC interactions and items; preserve KING/ES2M behavior unless evidence and isolated Runtime prove a safe improvement. |
| LPC design | [doc/build](https://github.com/MudRen/ES2-big5/tree/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/build), [doc/mudlib](https://github.com/MudRen/ES2-big5/tree/ec567210d84907f89a8566ffa5f8ce807873fb22/doc/mudlib) | Historical room, NPC, item, equipment, skill and feature documentation. | Use as developer reference when diagnosing confirmed gameplay FAIL; version-dependent FluffOS/MudOS APIs must be verified against KING's Neolith. |

## Audited overlap (not a missing-content claim)

At the compared revisions, MudRen contains 1,005 tracked files, including 457 under `doc/` and 97 under `d/snow/`. The KING `es2m_snapshot/mudlib/` does not contain the 457 historical `doc/` paths; 96 of 97 `d/snow/` paths match by relative path, but their Git blob SHA values differ. One Snow-only README is absent from the ES2M snapshot. **Different SHA does not imply newer, better, or missing gameplay.** KING's generated Original Runtime is built separately, so snapshot absence is not runtime absence.

## Licensing and import boundary

[Copyright.ES2](https://github.com/MudRen/ES2-big5/blob/ec567210d84907f89a8566ffa5f8ce807873fb22/Copyright.ES2) names Annihilator as copyright holder, limits monetary use, requires preserving specified files/attributions, version identification at login, and notices for modified/distributed versions. This registry links to documentation and summarizes concepts; it **does not copy, vendor, or execute** MudRen source or imply a permissive open-source license. Review license compatibility and attribution before any source-code import or public redistribution.

## P0 playability application (no new test framework)

1. Reuse existing `scripts/test_player_open_alpha_e2e.sh`, `scripts/test_original_player_creation_e2e.sh`, and `scripts/test_game_playability_completion_e2e.sh` on existing isolated Driver.
2. If ordinary-player save/restore FAIL occurs, inspect KING autoload/save implementation and Driver logs; compare the historical documented lifecycle above to identify a specific, independently verifiable defect.
3. If Snow navigation or NPC interaction FAIL occurs, compare affected **specific** files against pinned Original, ES2M and this historical snapshot; no blanket overlay.
4. If owner/ordinary-player privilege isolation FAIL occurs, compare current security model against historical uid/euid design; never grant `king` privileges by display name.
5. Fix a confirmed defect in a separate gameplay batch owned by Work, rerun existing isolated Driver journey, and preserve exact HEAD-bound evidence. Until then all potential improvements remain `CANDIDATE / NOT RUNTIME VERIFIED`.

**This commit adds reusable historical references and an actionable comparison plan only. It adds zero playable features, changes no Runtime/Neon/Render behavior, and makes no new PASS claim.**
