#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-/opt/es2-king/runtime}"
M="$ROOT/mudlib"
files=(
  "$M/obj/king/god_ring.c" "$M/obj/king/omega_crown.c"
  "$M/obj/king/omega_plate.c" "$M/obj/king/omega_wings.c"
  "$M/obj/king/omega_girth.c" "$M/obj/king/omega_gloves.c"
  "$M/obj/king/omega_leggings.c" "$M/obj/king/omega_boots.c"
  "$M/cmds/adm/kring.c" "$M/cmds/adm/release.c" "$M/cmds/adm/seal.c" "$M/cmds/adm/recall.c" "$M/cmds/adm/mring.c"
)
for f in "${files[@]}"; do test -r "$f" || { echo "KING OMEGA STATIC FAIL: missing $f"; exit 1; }; done

# Authorization／普通同名玩家不可繞過唯一 KING 帳號與 Original admin 授權。
grep -Fq 'KING_D->authorized(me)' "$M/cmds/adm/kring.c"
grep -Fq 'present("god ring", me)' "$M/cmds/adm/kring.c"
grep -Fq 'ring->query("es2_king/owner_relic") != 1' "$M/cmds/adm/kring.c"
grep -Fq 'provision_creator_relics' "$M/adm/daemons/kingd.c"

# God Ring State／神戒初始封印，release 解封、seal 回收。
grep -Fq 'set("es2_king/omega_sealed",1)' "$M/obj/king/god_ring.c"
grep -Fq 'seal omega' "$M/obj/king/god_ring.c"

# Commands／release omega 是正式指令，kring 是共用同一著裝流程的快捷指令。
grep -Fq 'arg != "omega"' "$M/cmds/adm/release.c"
grep -Fq '"/cmds/adm/kring", "main", me, 0' "$M/cmds/adm/release.c"
grep -Fq '正式解封指令：release omega' "$M/cmds/adm/kring.c"

# V2／神戒預設 V2，舊版戒指未標記版本亦採 V2；保留原版演出回退。
grep -Fq 'set("es2_king/omega_narrative_version",2)' "$M/obj/king/god_ring.c"
grep -Fq 'ring->query("es2_king/omega_narrative_version") != 1' "$M/cmds/adm/kring.c"
grep -Fq 'ring->query("es2_king/omega_narrative_version") != 1' "$M/cmds/adm/seal.c"
grep -Fq '"/cmds/adm/seal", "main", me, "omega"' "$M/cmds/adm/recall.c"
grep -Fq 'inherit "/cmds/adm/seal";' "$M/cmds/adm/mring.c"
grep -Fq 'return ::main(me, "omega");' "$M/cmds/adm/mring.c"
grep -Fq '超級Ω神聖衣。' "$M/cmds/adm/kring.c"
grep -Fq 'HIY "神翼" HIW' "$M/cmds/adm/kring.c"
grep -Fq '「燃燒吧！我的小宇宙！」 「以八十八星座之名' "$M/cmds/adm/kring.c"
grep -Fq '神聖Ω神靴神焰熄滅' "$M/cmds/adm/seal.c"
grep -Fq 'HIY "神盔" HIW' "$M/cmds/adm/kring.c"
grep -Fq 'HIY "\\n>>> 超級Ω神聖衣・完全著裝 <<<\\n"' "$M/cmds/adm/kring.c"
grep -Fq '十二黃金神環浮現！神聖小宇宙吞沒星河' "$M/cmds/adm/kring.c"
grep -Fq '神衣雖歸，神威永存' "$M/cmds/adm/seal.c"

# Slots／七件使用互不衝突且 Original 人形種族允許的裝備槽。
grep -Fq 'set("wear_as","head_eq")' "$M/obj/king/omega_crown.c"
grep -Fq 'set("wear_as","armor")' "$M/obj/king/omega_plate.c"
grep -Fq 'set("wear_as","neck_eq")' "$M/obj/king/omega_wings.c"
grep -Fq 'set("wear_as","waist_eq")' "$M/obj/king/omega_girth.c"
grep -Fq 'set("wear_as","hand_eq")' "$M/obj/king/omega_gloves.c"
grep -Fq 'set("wear_as","leg_eq")' "$M/obj/king/omega_leggings.c"
grep -Fq 'set("wear_as","feet_eq")' "$M/obj/king/omega_boots.c"

# Actual Defense／七件 armor 合計 300；三狀態綁定裝備，卸下時由 Original unapply 同步解除。
python3 - "$M/obj/king" <<'PY'
import pathlib,re,sys
root=pathlib.Path(sys.argv[1]); total=0
for name in ["omega_crown","omega_plate","omega_wings","omega_girth","omega_gloves","omega_leggings","omega_boots"]:
    total += int(re.search(r'"armor":(\d+)', (root/f"{name}.c").read_text()).group(1))
assert total == 300, total
PY
grep -Fq '"omega_god_protection":1' "$M/obj/king/omega_plate.c"
grep -Fq '"omega_absolute_body":1' "$M/obj/king/omega_girth.c"
grep -Fq '"omega_lightspeed_realm":1' "$M/obj/king/omega_wings.c"
! grep -Fq 'set_temp("es2_king/omega/' "$M/cmds/adm/kring.c"

# Runtime State Gate／解封成功前必須確認七個 Original armor slot 與三個 Ω apply 狀態真的存在。
grep -Fq 'private int omega_equipped(object me)' "$M/cmds/adm/kring.c"
grep -Fq 'item->query("equipped") != "armor/" + omega_slots[i]' "$M/cmds/adm/kring.c"
grep -Fq 'me->query_temp("armor/" + omega_slots[i]) != item' "$M/cmds/adm/kring.c"
grep -Fq 'query_temp("apply/omega_god_protection") >= 1' "$M/cmds/adm/kring.c"
grep -Fq 'query_temp("apply/omega_absolute_body") >= 1' "$M/cmds/adm/kring.c"
grep -Fq 'query_temp("apply/omega_lightspeed_realm") >= 1' "$M/cmds/adm/kring.c"
grep -Fq 'if (!omega_equipped(me))' "$M/cmds/adm/kring.c"

# Duplicate Protection／再次解封重用同 ID 物件，不重複生成。
grep -Fq 'item = present(omega_ids[i], me);' "$M/cmds/adm/kring.c"
grep -Fq 'if (!objectp(item)) {' "$M/cmds/adm/kring.c"
# Seal／卸裝必須走 Original unequip()，解除 apply 後七件回歸神戒（Inventory 不留實體）。
grep -Fq 'item->query("equipped") && !item->unequip()' "$M/cmds/adm/seal.c"
grep -Fq 'destruct(item);' "$M/cmds/adm/seal.c"
grep -Fq 'ring->set("es2_king/omega_sealed", 1)' "$M/cmds/adm/seal.c"
grep -Fq 'ring->set("es2_king/omega_sealed", 0)' "$M/cmds/adm/kring.c"
# ANSI Display／共同前綴白色、部件名稱黃色。
for f in "$M"/obj/king/omega_{crown,plate,wings,girth,gloves,leggings,boots}.c; do
  grep -Fq 'set_name(HIW "超級Ω神聖衣。" HIY "' "$f"
done

# KING 專屬顯示排序：生成 Runtime 的 i / look 共用七件排序。
test -f "$M/adm/daemons/omega_sortd.c"
grep -Fq 'ES2-KING OMEGA CANONICAL DISPLAY ORDER' "$M/cmds/usr/inventory.c"
grep -Fq 'ES2-KING OMEGA CANONICAL DISPLAY ORDER' "$M/cmds/std/look.c"
grep -Fq '"omega crown", "omega plate", "omega wings", "omega girth"' "$M/adm/daemons/omega_sortd.c"
grep -Fq '"omega gloves", "omega leggings", "omega boots"' "$M/adm/daemons/omega_sortd.c"

echo 'KING_OMEGA_STATIC_PASS:ring-release-kring-seven-piece-original-wear-armor300'
