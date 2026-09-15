# M4 Combat and Skills — PASS

Status: **PASS**

## Verified runtime

- Branch: `build/executable-mud-phase1`
- Verification commit: `b4cc6db6cec41dd051d612a49e3cb42c956e5fe0`
- Workflow: `Original ES2 M4 Combat and Skills`
- Run: `35001281111` (Run #11)
- Job: `104489996385` (`m4-combat-skills`)
- M0–M3 regression workflow: `Original ES2 Driver Build`, Run `35001281071` (Run #60), conclusion `success`

## Live evidence

The workflow booted the Original ES2 Mudlib through Neolith and created a fresh Human/Commoner/Lv.1 character named `戰鬥測試`.

### Skills

The live `skills` command returned:

> 你目前並沒有學會任何技能。

This confirms the fresh Lv.1 character's actual Original ES2 skill state was read through the running game.

### Combat

The character moved from `客棧大堂` to `廚房`, where a runtime-only test NPC `木樁武者 (M4dummy)` was temporarily injected for verification. This fixture exists only in the GitHub Actions runtime and is not Original ES2 canon.

The live `fight m4dummy` command was accepted:

> M4FIGHT ACCEPTED: 木樁武者接受切磋。

The runtime then produced genuine Original ES2 combat exchange text, including player attacks against 木樁武者. The tightened M4 test requires real combat sentence patterns rather than merely matching the word `戰鬥`.

### Resources

After combat started, the live `hp` command returned actual character resources. In Run #11 the observed values included:

- 形體 75/75
- 精 28/30
- 氣 30/30
- 神 30/30

The exact fresh-character values may vary because Original ES2 Human attributes are randomized within their allowed initializer range.

## Result

Run #11 completed successfully with all workflow steps passing and emitted:

- `M4 PASS SKILLS`
- `M4 PASS COMBAT`
- `M4 PASS RESOURCES`
- `M4 PASS: Original ES2 live skills command, fight command, genuine bilateral combat text, and resource command verified.`

M4 therefore verifies the executable roadmap's initial **combat/skills** milestone without permanently modifying Original ES2 world content.
