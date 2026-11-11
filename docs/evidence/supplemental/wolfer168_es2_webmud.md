# wolfer168/es2-webmud — Supplemental Source Registry

Source: https://github.com/wolfer168/es2-webmud

## Classification
DERIVED SOURCE-BACKED CATALOG / REFERENCE IMPLEMENTATION.

It is not promoted above Original LPC. Its `catalog/source_status.json` declares:
- expected origin: `taedlar/es2_mudlib`
- pinned upstream commit: `cc45c06af4852380e5148dad3c9d53ff06854f2c`
- source policy: `taedlar/es2_mudlib only`

That commit is the same Pinned Target used by ES2-KING, so catalog facts may accelerate indexing and cross-checking. Any gameplay implementation still resolves back to Original LPC before changing Runtime Canon.

## Safe supplemental surfaces
- world graph / room exits
- Snow area manifest (43 room/area files)
- NPC index and combat profiles
- item/equipment index
- skill and skill-contract index
- damage/combat-core contracts
- interaction/reference/dependency graphs

## Confirmed useful gaps
The derived world graph explicitly exposes unresolved exits from Snow to:
`/d/snowkeep/entrance`, `/d/lee/r1`, `/d/goat/sroad1`, `/d/month/a1`,
`/d/chixiao/river2`, `/d/oldpine/road1`, `/d/newcamp/gate`, and
`/d/graveyard/grave1`.

These are evidence of references in the pinned Snow world, NOT evidence that the missing target files exist.

## Integration rule
1. Catalog finds candidate.
2. Verify candidate against Pinned Original LPC.
3. Mark SOURCE_BACKED only after LPC verification.
4. If only catalog/derived implementation exists, keep DERIVED_REFERENCE.
5. Never overwrite existing ES2-KING Canon, combat narration, KING rules, persistence or privilege boundaries from derived data.
