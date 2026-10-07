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
E2E = ROOT / "scripts/test_player_open_alpha_e2e.mjs"

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
e2e = E2E.read_text(encoding="utf-8")

# Quantity validation and price calculation.
require(
    buy,
    'if( amount < 1 ) return notify_fail("購買數量必須至少是一個.\\n");'.replace(".", "。"),
    'if( amount > 100 ) return notify_fail("一次最多只能買一百個。\\n");',
    "price = owner->query_trading_price(handle) * amount;",
    "if( !(handle = owner->affirm_merchandise(me, item, amount)) ) return 0;",
)
before(buy, "me->can_afford(price)", "owner->deliver_merchandise(me, handle, amount, price)")
before(buy, "owner->deliver_merchandise(me, handle, amount, price)", "me->pay_money(price);")

# Atomic delivery: construct/move first, only then reduce stock; caller pays after success.
require(
    vendor,
    "if( stock[item] < amount )",
    "if( err = catch(ob = new(what)) ) return 0;",
    "foreach(ob in goods)",
    "if( !ob->move(me) )",
    "stock[what] -= amount;",
    "return 1;",
)
before(vendor, "foreach(ob in goods)", "stock[what] -= amount;")

# Delayed waiter settlement must re-check funds, deliver, then charge.
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

# Combined item persistence must restore only a positive integer amount.
require(
    autoload,
    "string query_autoload()",
    "void autoload(string param)",
    "sscanf(param, \"%d\", saved_amount) == 1",
    "saved_amount > 0",
    "set_amount(saved_amount);",
)

# Ordinary-player gameplay gate must exercise all required failure/success paths.
require(
    e2e,
    'buy mystery from waiter',
    'buy 0 manto from waiter',
    'buy -1 manto from waiter',
    'buy 101 manto from waiter',
    'buy 31 chicken from waiter',
    'buy 1 chicken from waiter',
    'buy 1 dumpling from waiter',
    'buy 3 manto from waiter',
    'PLAYER_ES2M_SHOP_ITEM_PERSISTENCE_PASS',
    'PLAYER_ES2M_SHOP_BALANCE_PERSISTENCE_PASS',
)

print("SHOP_TRANSACTION_STATIC_PASS")
