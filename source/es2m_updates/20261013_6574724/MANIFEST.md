# ES2M Update Snapshot — 2026-10-13

- Source repository: https://github.com/wolfer168/es2-webmud
- Source branch: `main`
- Source HEAD reviewed: `6574724aeac69c3f353fad5b2da90ccfab3714b1`
- Previous KING source snapshot: `b05f52591d7df60f90305d88d271b59086117397` (2026-10-12)
- Upstream delta: 5 commits, 6 changed paths.
- Scope: 1 LPC runtime source file, 1 source test, 4 WebMUD UI files.
- Evidence rule: preserve exact ES2M sources; WebMUD UI is archived as evidence only because KING does not contain the ES2M web client. This archive does not imply all changes are active in KING Runtime.
- The updated LPC file is also staged in `es2m_snapshot/mudlib/cmds/std/sneak.c` for source-based tests and future adapter integration.

## Changed files and source blob SHA

| ES2M source path | Status | Source blob SHA | KING handling |
|---|---|---|---|
| `source/upstream/mudlib/cmds/std/sneak.c` | modified | `6d9d5e6ddff340b56abb87882a2acb22d9459738` | Archived; snapshot staged; KING Expansion adapter added at `es2_king_expansion/runtime/mudlib/cmds/std/sneak.c`; Docker targeted gate added, execution pending |
| `tests/test_v32069_interaction_priority.py` | modified | `249d8de349aa7982fca270c87d700c60ef9a691d` | Archived as source evidence; not run as KING test because it asserts ES2M WebMUD UI |
| `web/app.js` | modified | `cdb13df40e38201a65ca8ff6db871808d8315ee5` | Archived; KING has no matching ES2M WebMUD client |
| `web/automation.js` | modified | `35aab1fc85d4911353382e2a589279f09b8243f3` | Archived; KING has no matching ES2M WebMUD client |
| `web/bg_timer.js` | added | `9e50190fac65abc8517c0d428d09a62f804f63c3` | Archived; KING has no matching ES2M WebMUD client |
| `web/index.html` | modified | `b46bb9cb07c5b5adaf1132a60c260c61ba6be2d4` | Archived; KING has no matching ES2M WebMUD client |

## Runtime compatibility finding

The ES2M `sneak.c` update changes progression during the cautious preparation phase to use the player's INT attribute and changes successful sneak progression to `COMBAT_D->int_formula_exp(me)`. The pinned Original ES2 Runtime does not provide `int_formula_exp()` in its combat daemon. KING therefore adds a minimal Expansion adapter implementing the identical formula locally; the Original source remains unchanged. A targeted test is wired into the Docker build, but its execution result is still pending.

## Verification boundary

- Upstream compare: 5 commits / 6 changed paths — confirmed.
- Source archive: captured.
- ES2M source snapshot: updated.
- KING Expansion adapter and targeted Docker gate: written; execution pending.
- Docker build / Oracle gameplay: not validated by this snapshot operation.
- PR #13 remains OPEN / NOT MERGED.

## KING synchronization follow-up — 2026-10-13

- Added `scripts/test_es2m_sneak_adapter.py` to check that the preserved ES2M source retains `COMBAT_D->int_formula_exp(me)`, while the KING Expansion adapter uses its local compatibility formula and keeps the Original ES2 combat daemon unchanged.
- Updated `.github/workflows/es2m-update-snapshot.yml` so push and pull-request changes to the ES2M sneak snapshot, KING adapter, and regression test trigger the targeted static contract gate.
- Validation boundary: GitHub file writes confirmed; the Python regression test and GitHub Actions run have not yet been executed/verified in this operation. This does not establish LPC runtime or Oracle gameplay PASS.
