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

    def test_compatible_martial_engine_and_soldier_runtime_match_es2m(self):
        # ES2M-first policy：這兩個已確認相容的 Runtime 檔案須與保存的 ES2M 來源逐字一致。
        pairs = [
            ("std/martial_art.c",
             ROOT / "es2_king_expansion/runtime/mudlib/std/martial_art.c"),
            ("std/martial_art.h",
             ROOT / "es2_king_expansion/runtime/mudlib/std/martial_art.h"),
            ("daemon/class/soldier.c",
             ROOT / "es2_king_expansion/runtime/mudlib/daemon/class/soldier.c"),
        ]
        for relative, runtime_path in pairs:
            with self.subTest(path=relative):
                snapshot_path = SNAPSHOT / relative
                self.assertTrue(snapshot_path.is_file(), f"ES2M snapshot 缺少 {relative}")
                self.assertTrue(runtime_path.is_file(), f"KING Runtime overlay 缺少 {relative}")
                self.assertEqual(
                    snapshot_path.read_text(encoding="utf-8"),
                    runtime_path.read_text(encoding="utf-8"),
                    f"KING Runtime 的 {relative} 必須與 ES2M 快照一致；差異需先審核，不可直接覆蓋。",
                )

    def test_martial_engine_dependency_contract_is_visible(self):
        # 武學引擎與戰鬥精靈互相依賴；未確認 action 契約前不得單獨替換 combatd。
        martial = (SNAPSHOT / "std/martial_art.c").read_text(encoding="utf-8")
        combat = (SNAPSHOT / "adm/daemons/combatd.c").read_text(encoding="utf-8")
        for token in ['"damage_pct"', '"must_hit"', '"no_armor"', '"silent"']:
            self.assertIn(token, martial)
        for token in ['action["damage_pct"]', 'action["must_hit"]', 'action["no_armor"]', 'action["silent"]']:
            self.assertIn(token, combat)
        # 這是相容性契約檢查，不宣告 KING Runtime combatd 已完成同步。
        self.assertTrue((ROOT / "es2_king_expansion/runtime/mudlib/std/martial_art.c").is_file())

    def test_combat_progression_source_contract(self):
        # combatd.c 的成長規則：成功閃躲／格擋有 combat 經驗，普通基本攻擊不給 martial art。
        combat = (SNAPSHOT / "adm/daemons/combatd.c").read_text(encoding="utf-8")
        self.assertIn("void restored_dodge_gain(object me, object opponent)", combat)
        self.assertIn("void restored_parry_gain(object me, object opponent)", combat)
        self.assertIn('gain_score("combat"', combat)
        self.assertIn('gain_score("martial art", 1)', combat)
        self.assertIn('member_array(skill, basic_attack_skills) < 0', combat)
        self.assertIn('if( damage > 0 ) restored_hit_gain(me, victim, skill, weapon);', combat)

    def test_gain_triggered_level_up_is_installed_in_king_runtime_overlay(self):
        # 來源快照不等於 Runtime：明確確認兩個必要檔案已納入 Expansion overlay。
        gain_path = ROOT / "es2_king_expansion/runtime/mudlib/cmds/usr/gain.c"
        score_path = ROOT / "es2_king_expansion/runtime/mudlib/feature/char/score.c"
        self.assertTrue(gain_path.is_file(), "KING Runtime overlay 缺少 gain.c")
        self.assertTrue(score_path.is_file(), "KING Runtime overlay 缺少 score.c")
        gain = gain_path.read_text(encoding="utf-8")
        score = score_path.read_text(encoding="utf-8")

        # 玩家技能成長與人物升級均在 gain 指令觸發；經驗累積本身不會立即升級。
        self.assertIn("me->apply_gain_progression(skill_g)", gain)
        self.assertIn("me->try_level_up();", gain)
        gain_score_body = score.split("gain_score(string course, int xp)", 1)[1].split("int try_level_up()", 1)[0]
        self.assertNotIn("advance_level(this_object())", gain_score_body)
        self.assertIn("int try_level_up()", score)
        self.assertIn('query("target_score")', score)
        self.assertIn('query("class_level_cap/" + query_class())', score)
        self.assertIn("this_object()->save();", score)

    def test_king_skill_growth_table_matches_es2m_20261011(self):
        # KING 的技能上限與升級機制維持自訂；僅核對使用者已確認的屬性成長分段。
        skill = (ROOT / "es2_king_expansion/runtime/mudlib/feature/char/skill.c").read_text(encoding="utf-8")
        for line in [
            "if( value <= 10 ) return 100;",
            "if( value <= 15 ) return 90;",
            "if( value <= 20 ) return 80;",
            "if( value <= 25 ) return 60;",
            "if( value <= 30 ) return 40;",
            "if( value <= 40 ) return 30;",
            "if( value <= 45 ) return 15;",
            "return 10;",
        ]:
            self.assertIn(line, skill)
        self.assertIn("es2_king_skill_cap()", skill)


if __name__ == "__main__":
    unittest.main(verbosity=2)
