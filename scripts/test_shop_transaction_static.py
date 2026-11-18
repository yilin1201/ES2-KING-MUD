#!/usr/bin/env python3
"""Static regression checks for ordinary-player shop transaction safety.

This test intentionally does not boot Oracle/Render/Docker. It verifies the
checked-in KING integration contract and the ordinary-player E2E coverage.
Static PASS is not Runtime or Gameplay PASS.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

BUY = ROOT / "source/es2m_updates/20261005_5f042999/runtime_overlay/mudlib/cmds/std/buy.c"
VENDOR = ROOT / "source/es2m_updates/20261005_5f042999/runtime_overlay/mudlib/feature/npc/vendor.c"
WAITER = ROOT / "source/es2m_updates/20261005_5f042999/runtime_overlay/mudlib/d/snow/npc/waiter.c"
AUTOLOAD = ROOT / "scripts/apply_combined_item_autoload_runtime.py"
SHOP_AUTOLOAD = ROOT / "scripts/apply_shop_item_autoload_runtime.py"
E2E = ROOT / "scripts/test_player_open_alpha_e2e.mjs"
E2E_RUNNER = ROOT / "scripts/test_player_open_alpha_e2e.sh"
RUNTIME_APPLY = ROOT / "scripts/apply_race_phase2_runtime.sh"
SNOW_WAITER = ROOT / "es2m_snapshot/mudlib/d/snow/npc/waiter.c"
SNOW_FISH = ROOT / "es2m_snapshot/mudlib/d/snow/npc/yu.c"
LEE_GROCERY = ROOT / "es2m_snapshot/mudlib/d/lee/npc/lee_zhong.c"
LEE_WAITER = ROOT / "es2m_snapshot/mudlib/d/lee/npc/waiter.c"
LEE_PAWNSHOP = ROOT / "es2m_snapshot/mudlib/d/lee/pawnshop.c"
WATERSKIN = ROOT / "es2m_snapshot/mudlib/d/lee/obj/waterskin.c"
SUGAR = ROOT / "es2m_snapshot/mudlib/d/lee/obj/sugar.c"

def require(text: str, *markers: str) -> None:
    missing = [m for m in markers if m not in text]
    if missing:
        raise AssertionError("missing markers: " + repr(missing))

def before(text: str, first: str, second: str) -> None:
    a = text.find(first)
    b = text.find(second)
    if a < 0 or b < 0 or a >= b:
        raise AssertionError(f"expected order: {first!r} before {second!r}")

buy = BUY.read_text(encoding="utf-8")
vendor = VENDOR.read_text(encoding="utf-8")
waiter = WAITER.read_text(encoding="utf-8")
autoload = AUTOLOAD.read_text(encoding="utf-8")
shop_autoload = SHOP_AUTOLOAD.read_text(encoding="utf-8")
e2e = E2E.read_text(encoding="utf-8")
e2e_runner = E2E_RUNNER.read_text(encoding="utf-8")
runtime_apply = RUNTIME_APPLY.read_text(encoding="utf-8")

require(
    buy,
    'if( amount < 1 ) return notify_fail("購買數量必須至少是一個。\\n");',
    'if( amount > 100 ) return notify_fail("一次最多只能買一百個。\\n");',
    "unit_price = owner->query_trading_price(handle);",
    "unit_price > 2147483647 / amount",
    "price = unit_price * amount;",
    "if( !(handle = owner->affirm_merchandise(me, item, amount)) ) return 0;",
)
before(buy, "me->can_afford(price)", "owner->deliver_merchandise(me, handle, amount, price)")
before(buy, "owner->deliver_merchandise(me, handle, amount, price)", "me->pay_money(price);")

require(
    vendor,
    "if( stock[item] < amount )",
    "if( undefinedp(stock[what]) || stock[what] < amount ) return 0;",
    "if( err = catch(ob = new(what)) ) return 0;",
    "foreach(ob in goods)",
    "if( !ob->move(me) )",
    "stock[what] -= amount;",
    "foreach(item, count in stock)",
    "return 1;",
)
before(vendor, "foreach(ob in goods)", "stock[what] -= amount;")

require(
    waiter,
    "if( customer->can_afford(price) != 1 )",
    "delivered = ::deliver_merchandise(customer, item, amount, price)",
    "if( !delivered )",
    "customer->pay_money(price);",
    "return 2;",
)
before(waiter, "customer->can_afford(price)", "::deliver_merchandise(customer, item, amount, price)")
before(waiter, "::deliver_merchandise(customer, item, amount, price)", "customer->pay_money(price);")

require(
    autoload,
    "string query_autoload()",
    "void autoload(string param)",
    "sscanf(param, \"%d\", saved_amount) == 1",
    "saved_amount > 0",
    "set_amount(saved_amount);",
)

# Non-stacking shop items retain their object path through the existing user autoload field.
require(
    shop_autoload,
    '"obj/armor/fur_hat.c"',
    '"d/lee/obj/waterskin.c"',
    "int query_autoload() { return 1; }",
    "void autoload(string param) { }",
)

# Multi-shop SOURCE inventory and item-type evidence. These are snapshot facts, not Runtime claims.
source_contracts = {
    SNOW_WAITER: ('"waiter"', '"snow_inn_waiter"', '"/obj/food/dumpling": 50', '"/obj/food/manto": 50'),
    SNOW_FISH: ('"yu"', '"/d/snow/npc/obj/blue_jacket": 5', '"/obj/armor/fur_hat": 5', '"/obj/bottle": 5'),
    LEE_GROCERY: ('"zhong"', '"/d/lee/obj/waterskin" : 20', '"/obj/area/obj/bag" : 10', '"/d/lee/obj/sugar" : 100'),
    LEE_WAITER: ('"lee waiter"', '"/obj/food/pork" : 30', '"/obj/food/dumpling" : 50'),
    LEE_PAWNSHOP: ("inherit HOCKSHOP;", 'set("short", "李記當鋪")'),
    WATERSKIN: ("inherit CONTAINER_ITEM;", 'set("value", 50)', 'set("liquid_container", 1)'),
    SUGAR: ("inherit COMBINED_ITEM;", 'set("base_value", 5)', 'set("value", 5)'),
}
for source, markers in source_contracts.items():
    require(source.read_text(encoding="utf-8"), *markers)

require(
    e2e,
    'buy mystery from waiter',
    'buy 0 manto from waiter',
    'buy -1 manto from waiter',
    'buy 101 manto from waiter',
    'buy 31 chicken from waiter',
    'buy 1 chicken from waiter',
    'buy 1 dumpling from waiter',
    'buy 1 fur hat from yu',
    'buy 1 sugar from zhong',
    'buy 3 sugar from zhong',
    'buy 10 sugar from zhong',
    'buy 1 waterskin from zhong',
    '正忙著招呼其他客人',
    'PLAYER_ES2M_SHOP_ITEM_PERSISTENCE_PASS',
    'PLAYER_ES2M_SHOP_BALANCE_PERSISTENCE_PASS',
    'PLAYER_ES2M_SHOP_MULTI_VENDOR_PASS',
    'PLAYER_ES2M_SHOP_NONSTACK_PERSISTENCE_PASS',
)

# The ordinary-player runner must invalidate stale Neolith binaries whenever
# the simul-efun interface changes; otherwise old .b indexes can dispatch
# log_file/seteuid calls into cjk_align before any shop journey starts.
require(
    runtime_apply,
    'SIMUL_EFUN_CHANGED=0',
    'cmp -s "$src" "$dst"',
    'find "$ROOT/mudlib/bin" -type f -name \'*.b\' -delete',
    'ES2M SIMUL_EFUN CACHE INVALIDATED',
)

# Repeatable Gameplay matrix: emitted only after the runner verifies every
# required ordinary-player Runtime marker in the E2E log.
require(
    e2e_runner,
    'SHOP_ACCEPTANCE:NPC_REACHABLE:PASS',
    'SHOP_ACCEPTANCE:LIST:PASS',
    'SHOP_ACCEPTANCE:BUY:PASS',
    'SHOP_ACCEPTANCE:BULK_BUY:PASS',
    'SHOP_ACCEPTANCE:INVENTORY:PASS',
    'SHOP_ACCEPTANCE:SAVE_QUIT_RELOGIN:PASS',
    'SHOP_ACCEPTANCE:INVALID_QUANTITY:PASS',
    'SHOP_ACCEPTANCE:INSUFFICIENT_MONEY:PASS',
    'SHOP_ACCEPTANCE:INSUFFICIENT_STOCK:PASS',
    'SHOP_ACCEPTANCE:DELIVERY_FAILURE:PASS',
    'SHOP_ACCEPTANCE:NO_DUPLICATE_NONSTACK:PASS',
    'SHOP_ACCEPTANCE:BALANCE_PERSISTENCE:PASS',
)

print("SHOP_TRANSACTION_STATIC_PASS")
