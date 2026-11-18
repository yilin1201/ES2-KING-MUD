# Snow service and learning expansion

Discovery aid: wolfer168/es2-webmud catalogs.
Runtime authority: Pinned Original taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c.

Added ordinary-player coverage:
- 打鐵鋪子: reachable Original room and room details.
- 魚記小鋪: 魚天 vendor list plus BANK sign commands (deposit/withdraw/convert/open account surface).
- 私塾王懷芝: `sit` enters Original literate-learning state.

No money, object, level, INT, class, or skill is injected. Scholar promotion is intentionally not asserted because Original teacher.c requires natural literate progress plus random/INT/class/race conditions.

Markers:
- PLAYER_SNOW_SERVICES_PASS
- PLAYER_LITERATE_SOURCE_PASS
