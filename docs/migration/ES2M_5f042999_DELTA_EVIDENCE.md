# ES2M 5f042999 delta evidence

Upstream moved from 88b7f883e43049700392fd083de2a05f1fae8e07 to 5f042999e0d884ab35808a1c48a9e70bea46667f: 7 commits, 13 changed files. This batch preserves the 10 changed mudlib gameplay/source files for isolated KING integration.

Key candidates: quantity buy/vendor/waiter; new Celestial Empire board plus bboard permission gate; WebHUD-safe edit/more; Lee village waterskin/well. d/snow/inn_hall.c also contains a custom infinite-gold test object, so it must not be blindly overlaid.

Excluded from KING preservation: deploy/oracle/setup.sh, web/app.js, web/index.html because KING has independent deployment/web paths.

Decision: PRESERVED / NOT RUNTIME OVERLAID. Stage buy+vendor+waiter together and Driver-test quantity, money, stock and delivery; stage board chain without the infinite-gold test object and verify ordinary-player read/post denial; treat Lee water objects as supplemental reconstruction, not Original ES2 canon. No Runtime or Gameplay PASS is claimed.
