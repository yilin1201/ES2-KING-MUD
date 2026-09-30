# ES2-KING Player Open Alpha Status

## Verified

- `PLAYER_FULL_JOURNEY_E2E_PASS` — isolated real Neolith Driver, empty `data/`, ordinary-player authority only.
- Human（人類）and Avatar（克隆人）both complete account creation, `save`, `quit`, and `relogin` from zero state.
- Human ordinary-player journey completes world movement, NPC inspection, Source-backed item/equipment, non-lethal combat, and the Original Chen Weixia alchemist path.
- A second Human ordinary-player journey completes the Original food → comb → thief path and persists `improve_skill()` progress.
- A display name of `KING` does not grant owner, creator, admin, or wizard commands.
- Render deploy `e9183b23deaddf17d57418272dfc52662c53b6c5` reached `LIVE` and its startup logs recorded `PLAYER_SESSION_SMOKE_PASS`: localhost WebSocket → Original login prompt → unused ordinary-player ID → new-character confirmation → answer N. It creates no account and grants no owner/admin/wizard authority. This remains a deployment-local gate, not external `PUBLIC_PLAYER_SMOKE_PASS`.

## Release gate still open

- `PUBLIC_PLAYER_SMOKE_PASS` is not yet recorded. The Work terminal could not resolve the public Render hostname, while browser credential-safety policy prevents automated password creation in the cloud browser.
- Physical iPhone Safari has not been executed by this environment. Cloud Chrome evidence must not be reported as iPhone Safari evidence.
- Therefore `PLAYER_OPEN_ALPHA_READY` is **not yet verified**.

## Required final acceptance

Run the committed ordinary-player journey against the deployed `/mud` endpoint from an authorized environment with public DNS, using unique isolated account IDs. Then execute the same new-account flow once in physical iPhone Safari and record the resulting public runtime evidence. No KING/Admin/Wizard shortcut is permitted.

## Evidence boundary

Taoist, Bonze, Soldier, Random Quest, Snowkeep, and unrecovered historical races remain post-alpha `SOURCE_REQUIRED` where already documented. They do not authorize invented Original content and do not invalidate the verified basic player journey.
