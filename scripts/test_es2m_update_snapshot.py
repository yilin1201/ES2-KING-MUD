#!/usr/bin/env python3
"""ES2M 更新來源快照的靜態契約；不代表遊戲內交易流程已通過。"""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = ROOT / "es2m_snapshot/mudlib"


class TestES2MUpdateSnapshot(unittest.TestCase):
    """確認 ES2M 商店與戰鬥成長資料已保存，並標出非同步交易風險。"""

    def test_batch_buy_source_contract(self):
        # buy.c 必須保留數量上限、按數量計價，以及交貨呼叫先於扣款。
        buy = (SNAPSHOT / "cmds/std/buy.c").read_text(encoding="utf-8")
        self.assertIn('sscanf(item, "%d %s", amount, rest)', buy)
        self.assertIn("amount > 100", buy)
        self.assertIn("owner->query_trading_price(handle) * amount", buy)
        deliver = buy.find("owner->deliver_merchandise(me, handle, amount)")
        pay = buy.find("me->pay_money(price)")
        self.assertGreaterEqual(deliver, 0)
        self.assertGreater(pay, deliver)

    def test_vendor_inventory_and_quantity_contract(self):
        # vendor.c 應驗證庫存、支援堆疊品與多件交貨，最後按數量扣庫存。
        vendor = (SNAPSHOT / "feature/npc/vendor.c").read_text(encoding="utf-8")
        self.assertIn("if( stock[item] < amount )", vendor)
        self.assertIn("function_exists(\"set_amount\", ob)", vendor)
        self.assertIn("for( i = 0; i < amount; i++ )", vendor)
        self.assertIn("stock[what] -= amount", vendor)

    def test_waiter_quantity_passthrough_and_async_risk_is_visible(self):
        # waiter.c 把購買數量帶進延遲交貨；離開房間會直接中止交貨。
        waiter = (SNAPSHOT / "d/snow/npc/waiter.c").read_text(encoding="utf-8")
        self.assertIn("affirm_merchandise (object customer, string item_name, int amount)", waiter)
        self.assertIn("deliver_merchandise (object customer, mixed item, int amount)", waiter)
        self.assertIn("do_chat ((: handover, customer, item, amount :))", waiter)
        self.assertIn("environment(customer)!=environment()", waiter)
        self.assertIn("return;", waiter)
        # 這是已知非同步交易風險：buy.c 的 catch 無法捕捉稍後 call_out 內的交貨失敗。
        self.assertIn("catch(owner->deliver_merchandise(me, handle, amount))", 
                      (SNAPSHOT / "cmds/std/buy.c").read_text(encoding="utf-8"))

    def test_combat_progression_source_contract(self):
        # combatd.c 的成長規則：成功閃躲／格擋有 combat 經驗，普通基本攻擊不給 martial art。
        combat = (SNAPSHOT / "adm/daemons/combatd.c").read_text(encoding="utf-8")
        self.assertIn("void restored_dodge_gain(object me, object opponent)", combat)
        self.assertIn("void restored_parry_gain(object me, object opponent)", combat)
        self.assertIn('gain_score("combat"', combat)
        self.assertIn('gain_score("martial art", 1)', combat)
        self.assertIn('member_array(skill, basic_attack_skills) < 0', combat)
        self.assertIn('if( damage > 0 ) restored_hit_gain(me, victim, skill, weapon);', combat)


if __name__ == "__main__":
    unittest.main(verbosity=2)
