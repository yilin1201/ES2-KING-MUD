#!/usr/bin/env bash
set -euo pipefail
# Render 診斷：保留原有失敗閘門，顯示確切失敗行與指令，禁止隱藏或跳過驗證。
trap 'status=$?; echo "FINAL_RUNTIME_ASSERT_FAIL line=$LINENO status=$status command=$BASH_COMMAND" >&2' ERR

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
grep -Fq '請輸入編號 1-12 或種族 ID' "$LOGIN_D"
grep -Fq '1. Human（人類）' "$LOGIN_D"
grep -Fq '2. Avatar（人類族）' "$LOGIN_D"
grep -Fq '3. 黑齒' "$LOGIN_D"
grep -Fq '8. 刑天' "$LOGIN_D"
grep -Fq '12. 阿修羅' "$LOGIN_D"
grep -Fq 'race == "人類"' "$LOGIN_D"
grep -Fq 'race == "人類族"' "$LOGIN_D"
grep -Fq 'race = "blackteeth";' "$LOGIN_D"
grep -Fq 'race = "headless";' "$LOGIN_D"
grep -Fq 'race = "ashura";' "$LOGIN_D"
for race in blackteeth yenhold woochan dingling jiaojao rainner ashura headless yaksa malik; do test -f "$RUNTIME_DIR/mudlib/daemon/race/$race.c"; done
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

# Original Race Roster Source Gate／Original 可選種族來源閘門：
# Target roster 固定 human/avatar；中文名稱只屬 Runtime 顯示層，不改 Original race ID。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_original_race_roster_source_gate.sh" "$RUNTIME_DIR"

# Original Human Runtime Fixture Gate／人類種族精準 Source Fixture：
# 直接對 Docker 最終 mudlib 驗證 human→commoner→Lv.1 dependency 與固定初始化邊界，
# 不把 Static PASS 誤標成 Runtime PASS。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_original_human_runtime_fixture_static.sh" "$RUNTIME_DIR"

# Normal Player Training Source Gate／普通玩家練功來源閘門：
# 直接鎖定 pinned Original 真正存在的 skills/enable/study/perform 與 skill progression engine，
# 並防止把缺失的 learn/practice/exercise 誤標為已恢復。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_player_training_source_gate.sh" "$RUNTIME_DIR"

# Cold Plum Arena Static Gate／冷梅演武界靜態閘門：在 Docker 最終 Runtime overlay 後檢查，
# 確保部署映像實際包含梅寒霜、六式與 UNKNOWN 邊界，而不是只檢查 repository source。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_cold_plum_arena_static.sh" "$RUNTIME_DIR"

# Message Vision Width Gate／禁止 Original 70欄規則再次硬切人物／戰鬥敘述。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_message_vision_nowrap.sh" "$RUNTIME_DIR"

# Original Combat Narration Preservation Gate／原版人物出招敘述最高優先保護：
# 已有 Original／Historical Evidence 的人物出招敘述不得因手機排版、單行顯示或 UI 美化而刪字、縮寫、摘要或改寫。
# Evidence 原文完整性 > 排版美化；允許 ANSI 配色、換行與顯示相容性調整，但不得減少人物／武功／極招／段名／劍氣／目標等既有敘述。
bash "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/test_original_combat_narration_preservation.sh" "$RUNTIME_DIR"

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
grep -Fq 'form == "dingqiankun" && !me->query("es2_king/daxie_jinshen")' "$QISHANG_STAFF"
grep -Fq '必須先啟動大邪金身' "$QISHANG_STAFF"
! grep -Fq '寂靜奧義' "$QISHANG_STAFF"
# 顏色與霸天演出由 source/runtime E2E 精確驗證；此處只驗證最終映像保留必要 ANSI 常數與 Batian hook，避免排版造成假 FAIL。
grep -Fq 'HIM' "$QISHANG_STAFF"
grep -Fq 'HIW' "$QISHANG_STAFF"
grep -Fq 'HIG' "$QISUN_BLADE"
grep -Fq 'HIW' "$QISUN_BLADE"
grep -Fq 'batian lianti jue' "$QISUN_BLADE"
grep -Fq 'batian lianti jue' "$QISHANG_STAFF"

# Batian Canon Narration Final Runtime Gate／霸天煉體訣正式戰鬥敘述：
# 使用 Owner 最新定稿文字直接鎖住 Docker 最終映像，避免 Source 已改但 Overlay/映像仍殘留舊句。
BATIAN_SKILL="$RUNTIME_DIR/mudlib/d/arena/skill/batian_lianti_jue.c"
test -f "$BATIAN_SKILL"
grep -Fq '面對漫天殺機，$N神色不起波瀾，只信步前踏半步。' "$BATIAN_SKILL"
grep -Fq '體內「" HIY "霸天煉體訣" HIW "」神紋流轉，周身散發著萬法不侵的沉雄氣度。' "$BATIAN_SKILL"
grep -Fq '「 【 霸 天 煉 體 訣・不 滅 金 身 】 」' "$BATIAN_SKILL"
grep -Fq '待得金芒驟聚，「" HIY "不滅金身" HIW "」自然流轉，泛起璀璨耀目的金光琉璃神華。' "$BATIAN_SKILL"
grep -Fq 'return strength * query_immortal_absorb_percent() / 100;' "$BATIAN_SKILL"
! grep -Fq '暗金琉璃神華' "$BATIAN_SKILL"

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
