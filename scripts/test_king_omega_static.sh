#!/usr/bin/env bash
set -euo pipefail
# 失敗時顯示實際指令與行號，避免 Render 只留下 exit code 1。
trap 'echo "KING_OMEGA_STATIC_FAIL line=$LINENO command=$BASH_COMMAND" >&2' ERR
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
grep -Fq 'HIY "神靴神焰熄滅' "$M/cmds/adm/seal.c"
grep -Fq 'HIY "神盔" HIW' "$M/cmds/adm/kring.c"
grep -Fq 'HIY "\n>>> 超級Ω神聖衣・完全著裝 <<<\n"' "$M/cmds/adm/kring.c"
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

# Recall 敘述名稱與配色回歸：白色前綴、黃色部件、兩句宣言同一行。
grep -Fq '「神聖Ω，榮耀永存！」 「諸神之力，歸於永恆！」' "$M/cmds/adm/seal.c"
for part in 神盔 神甲 神翼 神鎖 拳套 腿甲 神靴; do
  grep -Fq '" HIW "超級Ω神聖衣。" HIY "'"$part" "$M/cmds/adm/seal.c"
done

# ES2M 第一批新增裝備：原始來源檔必須隨 Runtime 複製，不替 NPC 設定掉落。
for item in armor/armor/battle_armor.c armor/armor/ring_mail.c armor/cloth/cyan_cloth.c \
  armor/armor/tiger_armor.c armor/armor/wolf_armor.c \
  armor/cloth/suncat_skin.c armor/cloth/umber_robe.c armor/cloth/worn_robe.c \
  armor/feet/boots_of_heroism.c armor/feet/jiaojao_boots.c armor/feet/runners_boots.c; do
  test -f "$M/custom/$item"
done

# ES2M 第三批：五件武器原始碼必須進入 Runtime，不新增未證實取得途徑。
for item in blade/butterfly_kris.c blade/golden_blade.c staff/flower_cane.c sword/ironsword.c sword/rapid_sword.c; do
  test -f "$M/custom/weapon/$item"
done

# ES2M 追加十二件武器：檢查生成 Runtime 與原始資料保持同步。
for item in blade/green_blade.c blade/thunderfurry_blade.c blade/warlord_blade.c \
  blunt/black_iron_hammer.c dagger/ancient_dagger.c dagger/coldblood_dagger.c \
  dagger/dagger_of_fate.c dagger/digested_holy_sword.c dagger/dimensional_dagger.c \
  needle/tailors_needle.c pike/golden_beast_lance.c staff/black_spark.c; do
  test -f "$M/custom/weapon/$item"
done

# ES2M custom/weapon 其餘十一件：完成本輪未導入武器補齊。
for item in staff/cane_of_spirit.c staff/celestial_bull_cane.c staff/staff_of_judgement.c \
  sword/charm_sword.c sword/flurry_sword.c sword/godness_sword.c \
  sword/jeweled_shortsword.c sword/loving_sword.c sword/royal_sword_of_honor.c \
  sword/storm_chasers_sword.c whip/silk_fishing_stick.c; do
  test -f "$M/custom/weapon/$item"
done

# ES2M 第四批：十二件戒指，保留獨立裝備物件，不改 KING 神之戒。
for item in freeze_ring.c frost_frog_ring.c gold_ring.c golden_ring.c han_jade_ring.c jade_ring.c lapis_ring.c leopard_ring.c lightning_ring.c magicians_ring.c meditation_ring.c pearl_ring.c; do
  test -f "$M/custom/armor/finger/$item"
done

# ES2M 書籍補入 Runtime，不得覆蓋同名 Original。
for item in anthology_of_classical_prose.c canon_of_true_words.c compendium_of_translations.c manual_of_six_yin_and_eight_trigrams.c nameless_ancient_tome.c simple_guide_to_words.c strange_tales_of_the_celestial_court.c studies_of_famous_mountains.c the_five_numbers.c the_literary_mind_and_carving_of_dragons.c travel_notes.c treatise_on_words.c verses_of_the_thirteen_spirits.c water_dragon_canon.c yellow_mountain_chess_manual.c yin_yang_canon.c; do
  test -f "$M/obj/books/$item"
done

# 建置前先驗證保存的 ES2M 區域拓樸與 NPC／物件引用。
python3 "$(dirname "$0")/test_es2m_zhenwu_topology.py" "$(cd "$(dirname "$0")/.." && pwd)/es2m_snapshot/mudlib"

# ES2M 振武軍營完整區域：五 NPC、六物件、十七房間均需進入 Runtime。
for item in npc/lu_xinien.c npc/mee_pei.c npc/soldier.c npc/target_stake.c npc/zhenwu_soldier.c \
  obj/fire_gauntlets.c obj/great_axe_of_mighty.c obj/recruit_stone.c \
  obj/short_pike.c obj/steel_armor.c obj/steel_boots.c \
  room/big_tent.c room/camp.c room/gate.c room/shed.c; do
  test -f "$M/custom/zhenwu/$item"
done
for n in $(seq -w 2 14); do
  test -f "$M/custom/zhenwu/room/yard$n.c"
done

# ES2M 原始道具：龍麟袋與四類可堆疊符紙，保留原檔不新增取得途徑。
for item in dragon_skin_bag.c scroll/blank.c scroll/nature.c scroll/yang.c scroll/yin.c; do
  test -f "$M/custom/item/$item"
done

# ES2M WebMUD 家園擴充：只保存獨立來源資產，不與 KING khome 權限或世界混用。
for item in npc/butler.c obj/bed.c obj/development_board.c obj/storage_chest.c \
  room/bedroom.c room/future_room.c room/home_hall.c room/study_room.c; do
  test -f "$M/custom/home/$item"
done

# 振武軍營正式連線：雙向出口與徵兵規則須存在於生成 Runtime。
grep -Fq '"west" : "/custom/zhenwu/room/gate"' "$M/d/snow/sgate.c"
grep -Fq '"east" : "/d/snow/sgate"' "$M/custom/zhenwu/room/gate.c"
grep -Fq '"/custom/zhenwu/obj/recruit_stone" : 1' "$M/custom/zhenwu/room/yard10.c"
python3 "$(dirname "$0")/test_es2m_zhenwu_recruitment.py" "$M"

echo 'KING_OMEGA_STATIC_PASS:ring-release-kring-seven-piece-original-wear-armor300'
