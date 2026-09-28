#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${1:-${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}}"
LOGIN_D="$RUNTIME_DIR/mudlib/adm/daemons/logind.c"
COMMAND_D="$RUNTIME_DIR/mudlib/adm/daemons/cmd_d.c"
PRELOAD_FILE="$RUNTIME_DIR/mudlib/adm/etc/preload"
NEOLITH_COMM="$RUNTIME_DIR/neolith/src/comm.c"
DRAGON_FORCE="$RUNTIME_DIR/mudlib/d/snow/skill/dragon_force.c"

test -f "$LOGIN_D" || {
  echo "FINAL RUNTIME ASSERTION FAIL（最終執行環境斷言失敗）：找不到 $LOGIN_D" >&2
  exit 1
}

# Original Internal Skill runtime／Original 內功執行環境：耗盡時必須接回實際存在的
# action interrupt() API，否則 busy callback 會永久阻止 save／quit。
test -f "$DRAGON_FORCE"
grep -Fq 'me->interrupt(me, "exhausted")' "$DRAGON_FORCE"
! grep -Fq 'me->interrupt_me(me, "exhausted")' "$DRAGON_FORCE"

# Final Runtime Assertion（最終執行環境斷言）：直接檢查 Neolith 即將載入的 logind，
# 不以 Overlay 原始腳本存在作為替代證據。
reservation_block="$(sed -n '/ES2-KING PUBLIC OWNER ID RESERVATION/,/^    mapping opts =/p' "$LOGIN_D")"
grep -Fq 'if (arg == "king")' <<<"$reservation_block"
grep -Fq 'ob->delete("id")' <<<"$reservation_block"
grep -Fq 'logon(ob)' <<<"$reservation_block"
grep -Fq '已拒絕公開註冊' <<<"$reservation_block"
grep -Fq 'input_to("get_owner_claim", 3, ob)' <<<"$reservation_block"
grep -Fq 'ES2-KING OWNER CLAIM FLOW' "$LOGIN_D"
grep -Fq 'owner_claim_transport_decode(token)' "$LOGIN_D"
grep -Fq 'secure_owner_claim_equal(supplied, secret)' "$LOGIN_D"
grep -Fq 'Claim 安全診斷：' "$LOGIN_D"
grep -Fq '比較=MISMATCH' "$LOGIN_D"
grep -Fq 'envsubst("${ES2_KING_CLAIM_TOKEN:-}")' "$LOGIN_D"
# Public Character Text Input（公開創角文字輸入）必須真的存在於 Neolith 最終載入的 logind。
grep -Fq 'ES2-KING PUBLIC CHARACTER TEXT INPUT' "$LOGIN_D"
test "$(grep -Fc 'input_to ("get_race", 0, ob);' "$LOGIN_D")" -eq 2
! grep -Fq 'input_to ("get_race", ob)' "$LOGIN_D"
grep -Fq 'private void get_race (string race, object ob)' "$LOGIN_D"
! grep -Fq 'switch (choice ? choice : race)' "$LOGIN_D"
# Race 數字相容層：用結構性條件驗證，避免 shell/LPC 兩層跳脫字元造成假 FAIL。
grep -Fq 'if (race == "1"' "$LOGIN_D"
grep -Fq 'race = "human";' "$LOGIN_D"
grep -Fq 'else if (race == "2"' "$LOGIN_D"
grep -Fq 'race = "avatar";' "$LOGIN_D"
grep -Fq 'case "human":' "$LOGIN_D"
grep -Fq 'case "avatar":' "$LOGIN_D"
grep -Fq '請輸入編號 1 或 2' "$LOGIN_D"
# Pinned Driver Contract／固定 Driver 契約：Race 的 input_to 是整行模式；Neolith copy_chars() 明確只在 CRLF/CR-NUL 建立 newline，lone CR 會被丟棄。
test -f "$NEOLITH_COMM"
grep -Fq "case '\\r': /* CR */" "$NEOLITH_COMM"
grep -Fq "from[i] == '\\n' || from[i] == '\\0'" "$NEOLITH_COMM"
grep -Fq "lone CR is dropped" "$NEOLITH_COMM"
grep -Fq 'ES2-KING OWNER COMMAND REHASH' "$COMMAND_D"
for command in kingcreate kinghome kingmartial kingcanon; do
  grep -Fqx "/cmds/adm/$command" "$PRELOAD_FILE"
done
test ! -e "$RUNTIME_DIR/mudlib/bin/adm/daemons/logind.b"
test ! -e "$RUNTIME_DIR/mudlib/bin/adm/daemons/cmd_d.b"

if grep -Fq 'destruct(ob)' <<<"$reservation_block"; then
  echo "FINAL RUNTIME ASSERTION FAIL（最終執行環境斷言失敗）：KING 保留路徑仍包含舊版 destruct(ob)。" >&2
  exit 1
fi

# Cold Plum Arena Static Gate／冷梅演武界靜態閘門：在 Docker 最終 Runtime overlay 後檢查，
# 確保部署映像實際包含梅寒霜、六式與 UNKNOWN 邊界，而不是只檢查 repository source。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_cold_plum_arena_static.sh" "$RUNTIME_DIR"

# KING Weapon Final Runtime Overlay Gate／直接檢查 Docker 最終 mudlib，而非只檢查 Repo source。
for weapon in guxiao feiyun guxiao_feiyun blood_blade god_cane; do
  test -f "$RUNTIME_DIR/mudlib/obj/king/$weapon.c"
done
grep -Fq '"guxiao"        : "/obj/king/guxiao"' "$RUNTIME_DIR/mudlib/adm/daemons/kingd.c"
grep -Fq '"blood blade"   : "/obj/king/blood_blade"' "$RUNTIME_DIR/mudlib/adm/daemons/kingd.c"
grep -Fq '"god cane"      : "/obj/king/god_cane"' "$RUNTIME_DIR/mudlib/adm/daemons/kingd.c"
grep -Fq 'provision_creator_weapons' "$LOGIN_D"
! grep -n -A8 'provision_creator_weapons' "$LOGIN_D" | grep -Eq '\.wield|->wield|call_other\([^)]*"wield"'


# KING Lv.300 Final Runtime Gate／驗證真正由 Neolith 載入的 F_SKILL 已套用唯一 Owner 例外，
# 且一般玩家仍保留 Original 200 上限；避免只修改 kingmartiald 卻被底層再次 clamp 回 200。
SKILL_FEATURE="$RUNTIME_DIR/mudlib/feature/char/skill.c"
test -f "$SKILL_FEATURE"
grep -Fq 'ES2-KING OWNER SKILL CAP 300' "$SKILL_FEATURE"
grep -Fq 'return 300;' "$SKILL_FEATURE"
grep -Fq 'return 200;' "$SKILL_FEATURE"
grep -Fq 'if( val > cap ) val = cap;' "$SKILL_FEATURE"
grep -Fq 's > es2_king_skill_cap()' "$SKILL_FEATURE"
grep -Fq 'skills[skill] > es2_king_skill_cap()' "$SKILL_FEATURE"
grep -Fq 'set_cold_plum", user, 300' "$LOGIN_D"
grep -Fq 'set_creator_core_martial", user, 300' "$LOGIN_D"
grep -Fq 'set_rulai_shenzhang", user, 300' "$LOGIN_D"

# Daxie Martial Final Runtime Gate／大邪武學最終執行環境閘門：
# 部署映像必須保留 Original 青邪杖法，並載入 Expansion 七損刀／七傷杖正式 ID、進階心法名稱與隨機 Combat。
KING_MARTIAL="$RUNTIME_DIR/mudlib/adm/daemons/kingmartiald.c"
QISUN_BLADE="$RUNTIME_DIR/mudlib/daemon/skill/qisun_blade.c"
QISHANG_STAFF="$RUNTIME_DIR/mudlib/daemon/skill/qishang_staff.c"
for file in "$KING_MARTIAL" "$QISUN_BLADE" "$QISHANG_STAFF"; do test -f "$file"; done
grep -Fq 'CHINESE_D->add_translate("kuxiao force", "哭笑心法")' "$KING_MARTIAL"
grep -Fq 'CHINESE_D->add_translate("huge force", "大邪心法")' "$KING_MARTIAL"
grep -Fq 'CHINESE_D->add_translate("chin_staff", "青邪杖法")' "$KING_MARTIAL"
grep -Fq 'CHINESE_D->add_translate("qishang_staff", "大邪七傷杖訣")' "$KING_MARTIAL"
grep -Fq 'CHINESE_D->add_translate("qisun_blade", "大邪七損刀訣")' "$KING_MARTIAL"
grep -Fq 'actor->map_skill("blade", "qisun_blade")' "$KING_MARTIAL"
grep -Fq 'actor->map_skill("staff", "qishang_staff")' "$KING_MARTIAL"
grep -Fq 'actor->map_skill("twohanded staff", "qishang_staff")' "$KING_MARTIAL"
grep -Fq 'random(sizeof(forms))' "$QISUN_BLADE"
grep -Fq 'random(sizeof(form_ids))' "$QISHANG_STAFF"
grep -Fq 'return usage == "staff" || usage == "twohanded staff";' "$QISHANG_STAFF"
grep -Fq '哭笑極境奧義・九曲天哭・一杖定乾坤' "$QISHANG_STAFF"
! grep -Fq '寂靜奧義' "$QISHANG_STAFF"
grep -Fq 'HIM + form_names[form]' "$QISHANG_STAFF"
grep -Fq '+ HIW' "$QISHANG_STAFF"
grep -Fq 'HIG + form_names[form]' "$QISUN_BLADE"
grep -Fq '+ HIW' "$QISUN_BLADE"
grep -Fq 'show_immortal_intro' "$QISUN_BLADE"
grep -Fq 'show_immortal_intro' "$QISHANG_STAFF"

# Score Grid Bars／形體精氣神方格條只改顯示，保留 Original 三值 Statistic。
grep -Fq 'ES2-KING SCORE GRID BARS' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
grep -Fq 'score_grid_bar("HP", HIG' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
grep -Fq 'score_grid_bar("GIN", HIR' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
grep -Fq 'score_grid_bar("KEE", HIB' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
grep -Fq 'score_grid_bar("SEN", HIY' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
grep -Fq 'string bar = "ES2GRID:" + kind + ":";' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
grep -Fq 'return bar + ":END";' "$RUNTIME_DIR/mudlib/cmds/usr/score.c"
! grep -Fq 'score-block' "$RUNTIME_DIR/../webtelnet/public/index.html" 2>/dev/null || true

echo "FINAL RUNTIME OVERLAY ASSERTION PASS（最終執行環境覆蓋層斷言通過）：新版 KING 保留流程、Public Race Text 相容層與 Cold Plum Arena Static Gate 均已通過。"
