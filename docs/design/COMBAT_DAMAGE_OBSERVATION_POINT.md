# Combat Damage Observation Point

Pinned Target checked: taedlar/es2_mudlib @ cc45c06af4852380e5148dad3c9d53ff06854f2c

Canonical observation point:
`mudlib/feature/char/combat.c::receive_damage(int damage, object from, object attacker)`

Why:
- Original unarmed damage reaches `victim->receive_damage(...)` after resistance.
- weapon/equipment damage also reaches `victim->receive_damage(...)` after resistance.
- Original comments define this function as applying actual damage and returning actual damage received.

ES2-KING instrumentation policy:
- patch generated isolated Runtime only
- enabled only by `ES2_COMBAT_BALANCE_OBSERVER=1`
- log the incoming post-resistance damage plus kill mode, target, attacker and source
- no changes to damage, RNG, consume_stat, damage_stat, combat narration, or production persistence
- Production remains observer-off

This observation is the basis for damage mean/P50/P95/min/max. Hit-rate instrumentation remains a separate later step because `receive_damage` only sees damage that reached the damage boundary.
