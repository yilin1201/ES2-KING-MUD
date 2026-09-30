#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-.runtime/es2-king}"
SOURCE="es2_king_expansion/runtime/mudlib"
test -d "$TARGET/mudlib" || { echo "EXPANSION APPLY FAIL：缺少 $TARGET/mudlib，請先建立獨立 Runtime。" >&2; exit 1; }
test -d "$SOURCE"
cp -a "$SOURCE/." "$TARGET/mudlib/"

# ES2M Headless Dance Routing／Expansion 會覆蓋 cmd_d，因此同名指令路由必須在 Expansion 套用後保留。
# 刑天 dance 走 ES2M 戰舞；其他玩家仍使用 Original EMOTED 通用表情。
COMMAND_D="$TARGET/mudlib/adm/daemons/cmd_d.c"
python3 - "$COMMAND_D" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
marker='''    if( !pointerp(path) ) return 0;\n\n'''
patch='''    if( !pointerp(path) ) return 0;\n\n    // ES2M HEADLESS DANCE COMMAND ROUTING／刑天 dance 優先使用種族戰舞；其他種族保留 Original 表情。\n    if( verb == "dance" && objectp(this_player())\n    &&  this_player()->query_race() == "headless"\n    &&  file_size("/cmds/usr/dance.c") > 0 )\n        return "/cmds/usr/dance";\n\n'''
if 'ES2M HEADLESS DANCE COMMAND ROUTING' not in s:
    if marker not in s: raise SystemExit('EXPANSION APPLY FAIL：找不到 COMMAND_D find_command path guard。')
    s=s.replace(marker,patch,1)
p.write_text(s)
PY

# Message Vision No Hard Wrap／人物敘述不得被固定 70 欄硬切：
# Pinned Original message_vision() 對 first/second/third-person 全部使用 cjk_wrap(..., 70, -1)。
# ES2-KING 保留原字串作者明確寫入的 \n，只移除這個顯示寬度造成的額外換行。
# 不修改 Pinned Original repository；只 patch 生成 Runtime。
MESSAGE_EFUN="$TARGET/mudlib/adm/simul_efun/message.c"
MESSAGE_NOWRAP_MARKER='ES2-KING MESSAGE VISION NO HARD WRAP'
if ! grep -Fq "$MESSAGE_NOWRAP_MARKER" "$MESSAGE_EFUN"; then
  python3 - "$MESSAGE_EFUN" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
replacements = {
    'message("vision", cjk_wrap (str2, 70, -1), you); // second-person':
    'message("vision", str2, you); // second-person — ES2-KING MESSAGE VISION NO HARD WRAP',
    'message ("vision", cjk_wrap (str1, 70, -1), me); // first-person':
    'message ("vision", str1, me); // first-person — ES2-KING MESSAGE VISION NO HARD WRAP',
    'message ("vision", cjk_wrap (str3, 70, -1),  environment(me), ({ me, you }) ); // third-person':
    'message ("vision", str3, environment(me), ({ me, you }) ); // third-person — ES2-KING MESSAGE VISION NO HARD WRAP',
}
for old, new in replacements.items():
    if old not in text:
        raise SystemExit("EXPANSION APPLY FAIL：找不到 Original message_vision 70欄 cjk_wrap anchor。")
    text = text.replace(old, new, 1)
path.write_text(text)
PY
fi

# KING Skill Cap Exception／KING 創世神 Lv.300 技能上限：
# Original ES2 的 F_SKILL 對所有角色固定 clamp 200；Project Canon 只允許唯一 admin KING 到 300。
# 這個 patch 只套用生成 Runtime，不修改 Original 保存來源；一般玩家仍完整保留 Original 200 上限。
SKILL_FEATURE="$TARGET/mudlib/feature/char/skill.c"
KING_SKILL_CAP_MARKER='ES2-KING OWNER SKILL CAP 300'
if ! grep -Fq "$KING_SKILL_CAP_MARKER" "$SKILL_FEATURE"; then
  python3 - "$SKILL_FEATURE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
needle = 'string best_skill = "";\n'
replacement = '''string best_skill = "";

// ES2-KING OWNER SKILL CAP 300／只允許唯一 admin KING 使用 Project Canon 300。
// 一般玩家與非 admin 的同名物件仍回到 Original 200。
private int es2_king_skill_cap()
{
    if (this_object()->query("id") == "king"
    &&  wiz_level(this_object()) >= wiz_level("(admin)"))
        return 300;
    return 200;
}
'''
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original F_SKILL best_skill anchor。")
text = text.replace(needle, replacement, 1)

needle = '''void set_skill(string skill, int val)
{
    if( val > 200 ) val = 200;
    skills[skill] = val;
}
'''
replacement = '''void set_skill(string skill, int val)
{
    int cap = es2_king_skill_cap();
    if( val > cap ) val = cap;
    skills[skill] = val;
}
'''
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original set_skill 200 clamp。")
text = text.replace(needle, replacement, 1)

needle = '    return (s > 200) ? 200 : s;\n'
replacement = '    return (s > es2_king_skill_cap()) ? es2_king_skill_cap() : s;\n'
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original query_skill 200 clamp。")
text = text.replace(needle, replacement, 1)

needle = '    if( skills[skill] > 200 ) skills[skill] = 200;\n'
replacement = '''    if( skills[skill] > es2_king_skill_cap() )
        skills[skill] = es2_king_skill_cap();
'''
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original advance_skill 200 clamp。")
text = text.replace(needle, replacement, 1)
path.write_text(text)
PY
fi

# Original Scholar UTF-8 Compatibility／Original 私塾書生回答相容：
# 舊 Big5 Runtime 以 msg[0..1] 擷取一個中文字；UTF-8 下中文字是三個 bytes，
# 因此玩家回答 Original 明列的「想／是／好」永遠無法觸發 set_class("scholar")。
# 只改成等價的字首搜尋，不增加回答、條件、機率或職業內容。
SCHOLAR_TEACHER="$TARGET/mudlib/d/snow/npc/teacher.c"
SCHOLAR_UTF8_MARKER='ES2-KING ORIGINAL SCHOLAR UTF-8 COMPATIBILITY'
if ! grep -Fq "$SCHOLAR_UTF8_MARKER" "$SCHOLAR_TEACHER"; then
  python3 - "$SCHOLAR_TEACHER" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
needle = '''    if( member_array(msg[0..1], ({"想", "是", "好"})) != -1 ) {
'''
replacement = '''    // ES2-KING ORIGINAL SCHOLAR UTF-8 COMPATIBILITY
    if( strsrch(msg, "想")==0 || strsrch(msg, "是")==0 || strsrch(msg, "好")==0 ) {
'''
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original Scholar 回答判斷，無法套用 UTF-8 相容修復。")
path.write_text(text.replace(needle, replacement, 1))
PY
fi

# Public KING Reservation／公開 KING 帳號保留：既有 login/k/king.o 仍走 Original 密碼登入；
# 只有存檔不存在時才拒絕公開建立，避免無持久磁碟重建後被陌生訪客搶註冊。
# 這是生成 Runtime 的相容層，不回寫或修改 Original ES2 保存來源。
LOGIN_D="$TARGET/mudlib/adm/daemons/logind.c"
RESERVATION_MARKER='ES2-KING PUBLIC OWNER ID RESERVATION'
CLAIM_MARKER='ES2-KING OWNER CLAIM FLOW'

# 舊 Runtime 已有單純 Reservation 時，先移除舊區塊，再加入一次性 Owner Claim 相容層。
if grep -Fq "$RESERVATION_MARKER" "$LOGIN_D" && ! grep -Fq "$CLAIM_MARKER" "$LOGIN_D"; then
  temp_login="$(mktemp)"
  awk -v marker="$RESERVATION_MARKER" '
    index($0, marker) { removing=1; next }
    removing && /^    }$/ { removing=0; skip_blank=1; next }
    removing { next }
    skip_blank && /^$/ { skip_blank=0; next }
    { skip_blank=0; print }
  ' "$LOGIN_D" > "$temp_login"
  chmod --reference="$LOGIN_D" "$temp_login"
  mv "$temp_login" "$LOGIN_D"
fi

if ! grep -Fq "$CLAIM_MARKER" "$LOGIN_D"; then
  # Prototype（函式宣告）維持 LPC 在函式定義前的呼叫相容性。
  prototype_line="$(grep -n -m1 '^private void get_id(string arg, object ob);' "$LOGIN_D" | cut -d: -f1)"
  test -n "$prototype_line" || {
    echo 'EXPANSION APPLY FAIL：找不到 Original get_id 宣告，無法加入 Owner Claim。' >&2
    exit 1
  }
  temp_login="$(mktemp)"
  head -n "$prototype_line" "$LOGIN_D" > "$temp_login"
  printf '%s\n' 'private void get_owner_claim(string token, object ob);' >> "$temp_login"
  tail -n "+$((prototype_line + 1))" "$LOGIN_D" >> "$temp_login"
  chmod --reference="$LOGIN_D" "$temp_login"
  mv "$temp_login" "$LOGIN_D"

  # Claim Session（認領工作階段）只保存在 logind 記憶體，不寫入玩家資料或任何 Log。
  definition_line="$(grep -n -m1 '^private void get_id (string arg, object ob) {' "$LOGIN_D" | cut -d: -f1)"
  test -n "$definition_line" || {
    echo 'EXPANSION APPLY FAIL：找不到 Original get_id 定義，無法加入 Owner Claim。' >&2
    exit 1
  }
  temp_login="$(mktemp)"
  head -n "$((definition_line - 1))" "$LOGIN_D" > "$temp_login"
  cat >> "$temp_login" <<'LPC'
// ES2-KING OWNER CLAIM FLOW／Owner 一次性安全初始化流程。
// Token 只從 Runtime Secret 讀取；不保存、不記錄，也不授予遊戲外基礎設施權限。
private object owner_claim_link;
private int owner_claim_deadline;

private void clear_stale_owner_claim()
{
    if (!objectp(owner_claim_link)
    ||  !interactive(owner_claim_link)
    ||  time() > owner_claim_deadline) {
        owner_claim_link = 0;
        owner_claim_deadline = 0;
    }
}

// Constant-time comparison／固定時間比較：迴圈次數只依兩者最大長度，
// 不在第一個錯誤字元提前返回，也不向 Client 洩漏長度或差異位置。
private int secure_owner_claim_equal(string supplied, string expected)
{
    int i, supplied_length, expected_length, compare_length;
    int supplied_byte, expected_byte, difference;

    supplied_length = strlen(supplied);
    expected_length = strlen(expected);
    compare_length = supplied_length > expected_length ? supplied_length : expected_length;
    difference = supplied_length ^ expected_length;

    for (i = 0; i < compare_length; i++) {
        supplied_byte = i < supplied_length ? supplied[i] : 0;
        expected_byte = i < expected_length ? expected[i] : 0;
        difference |= supplied_byte ^ expected_byte;
    }
    return difference == 0;
}

private int owner_claim_hex_nibble(int value)
{
    if (value >= '0' && value <= '9') return value - '0';
    if (value >= 'a' && value <= 'f') return value - 'a' + 10;
    if (value >= 'A' && value <= 'F') return value - 'A' + 10;
    return -1;
}

// Claim Transport Decode／認領傳輸解碼：WebTelnet 只傳送 ASCII hex，避開 Telnet 控制字元。
// 解碼值只存在本次 LPC 呼叫記憶體；不保存、不記錄、不回傳 Client。
private string owner_claim_transport_decode(string value)
{
    int high, i, low;
    string decoded, payload;

    if (strlen(value) < 10 || value[0..9] != "es2claim1:") return 0;
    payload = value[10..];
    if (strlen(payload) % 2) return 0;

    decoded = "";
    for (i = 0; i < strlen(payload); i += 2) {
        high = owner_claim_hex_nibble(payload[i]);
        low = owner_claim_hex_nibble(payload[i + 1]);
        if (high < 0 || low < 0) return 0;
        decoded += sprintf("%c", high * 16 + low);
    }
    return decoded;
}

private void reject_owner_claim(object ob, string diagnostic)
{
    write("\nOwner 初始化驗證失敗。\n\n");
    // Safe Observability／安全可觀測性：只顯示傳輸狀態與長度，不顯示 Token、片段或 Hash。
    if (stringp(diagnostic) && strlen(diagnostic))
        write("Claim 安全診斷：" + diagnostic + "\n\n");
    ob->delete("id");
    logon(ob);
}

private void get_owner_claim(string token, object ob)
{
    int encoded_mode, format_valid, supplied_length;
    string diagnostic, secret, supplied;
    mapping opts;

    write("\n");
    clear_stale_owner_claim();

    // 注意：送出 Claim 後的同一個 Session 可能已經建立 king.o。
    // 這時不能把玩家踢回 logon，否則會形成「Claim → Welcome → ID」輪迴。
    // king.o 是否存在只在 get_id() 決定走既有帳號密碼登入或首次 Claim；
    // 已進入 get_owner_claim() 就完成本次驗證，再直接接 Original confirm_id 流程。

    // 同一時間只允許一個已驗證 Session 進入創角，其他連線一律使用相同失敗訊息。
    if (objectp(owner_claim_link) && owner_claim_link != ob) {
        reject_owner_claim(ob, "狀態=SESSION-BUSY；未執行秘密比較。");
        return;
    }

    secret = envsubst("${ES2_KING_CLAIM_TOKEN:-}");
    encoded_mode = strlen(token) >= 10 && token[0..9] == "es2claim1:";
    supplied = encoded_mode ? owner_claim_transport_decode(token) : token;
    format_valid = stringp(supplied);
    supplied_length = format_valid ? strlen(supplied) : -1;

    if (strlen(secret) < 32 || !format_valid || !secure_owner_claim_equal(supplied, secret)) {
        diagnostic = sprintf(
            "協定=%s；格式=%s；輸入位元組=%d；Runtime 位元組=%d；長度=%s；比較=MISMATCH。",
            encoded_mode ? "HEX-V1" : "RAW",
            format_valid ? "VALID" : "INVALID",
            supplied_length,
            strlen(secret),
            supplied_length == strlen(secret) ? "MATCH" : "MISMATCH"
        );
        token = "";
        supplied = "";
        secret = "";
        reject_owner_claim(ob, diagnostic);
        diagnostic = "";
        return;
    }

    owner_claim_link = ob;
    owner_claim_deadline = time() + LOGIN_TIMEOUT;
    token = "";
    supplied = "";
    secret = "";

    // 驗證成功後直接重用 Original confirm_id → password → character creation 全流程。
    opts = ([
        "prompt": "",
        "options": ({ "Y) 是", "N) 否" }),
        "cursor": 0
    ]);
    confirm_id("Y", opts, ob);
}

LPC
  tail -n "+$definition_line" "$LOGIN_D" >> "$temp_login"
  chmod --reference="$LOGIN_D" "$temp_login"
  mv "$temp_login" "$LOGIN_D"

  insertion_line="$(grep -n -m1 '^    mapping opts = (\[$' "$LOGIN_D" | cut -d: -f1)"
  test -n "$insertion_line" || {
    echo 'EXPANSION APPLY FAIL：找不到 Original 新帳號確認流程，無法安全保留 KING ID。' >&2
    exit 1
  }
  temp_login="$(mktemp)"
  head -n "$((insertion_line - 1))" "$LOGIN_D" > "$temp_login"
  cat >> "$temp_login" <<'LPC'
    // ES2-KING PUBLIC OWNER ID RESERVATION／公開 Owner 帳號保留。
    // 重要：既有 king.o 必須在此之前已被 Original file_size(login_data(arg)) 分支接走。
    // 只有「檔案不存在」的首次 king 才能進 Claim，避免既有帳號被送回初始化輪迴。
    if (arg == "king") {
        if (strlen(envsubst("${ES2_KING_CLAIM_TOKEN:-}")) >= 32) {
            write("\nKING Owner 一次性初始化權杖: ");
            // I_NOECHO | I_NOESC：遮蔽輸入，且禁止 Token 開頭的 ! 被當成命令逃逸。
            input_to("get_owner_claim", 3, ob);
        } else {
            write("\nKING Owner 帳號尚未在此 Runtime 初始化，已拒絕公開註冊。\n\n");
            ob->delete("id");
            logon(ob);
        }
        return;
    }

LPC
  tail -n "+$insertion_line" "$LOGIN_D" >> "$temp_login"
  # mktemp（建立暫存檔）預設為 600；取代 Runtime 原檔前必須保留原有唯讀／穿越安全邊界，
  # 否則 Docker 建置的 root 可讀、非 root 的 es2king 啟動時卻無法載入 logind.c。
  chmod --reference="$LOGIN_D" "$temp_login"
  mv "$temp_login" "$LOGIN_D"
fi

# 舊版 Reservation 會立即 destruct 登入物件並留下 Driver 預設「>」；重複套用新版時就地升級。
legacy_destruct_line="$(awk -v marker="$RESERVATION_MARKER" '
  index($0, marker) { in_reservation=1; next }
  in_reservation && /destruct\(ob\)/ { print NR; exit }
  in_reservation && /^    }/ { exit }
' "$LOGIN_D")"
if [[ -n "$legacy_destruct_line" ]]; then
  temp_login="$(mktemp)"
  head -n "$((legacy_destruct_line - 1))" "$LOGIN_D" > "$temp_login"
  cat >> "$temp_login" <<'LPC'
        // 不銷毀互動登入物件；清除暫存 ID 後回到 Original 登入流程，
        // 讓拒絕訊息與下一個安全提示完整送達 Telnet／WebSocket Client。
        ob->delete("id");
        logon(ob);
LPC
  tail -n "+$((legacy_destruct_line + 1))" "$LOGIN_D" >> "$temp_login"
  chmod --reference="$LOGIN_D" "$temp_login"
  mv "$temp_login" "$LOGIN_D"
fi

# KING Login Provisioning／正式 KING 登入配置：
# 舊版只在 kinghome 指令中套用 8×99 與冷梅武學，造成「測試先執行 kinghome 才 PASS」、
# 但正式既有 KING 正常登入仍保留舊存檔能力。現在在 Original enter_world 完成 exec + setup 後，
# 對唯一已通過 admin 身分的 king 套用同一正式 API，再由 Original SAVE_USER 流程保存。
KING_LOGIN_MARKER='ES2-KING OWNER LOGIN PROVISIONING'
if ! grep -Fq "$KING_LOGIN_MARKER" "$LOGIN_D"; then
  python3 - "$LOGIN_D" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
needle = '''    user->setup();
    increment_visitor_count();

#ifdef SAVE_USER
    // save newly created user
    user->save();
#endif
'''
replacement = '''    user->setup();
    increment_visitor_count();

    // ES2-KING OWNER LOGIN PROVISIONING／只有正式互動 admin KING 會進入此分支。
    // 使用與 kinghome 相同的 daemon API；一般玩家完全不受影響。
    if (user->query("id") == "king"
    &&  wiz_level(user) >= wiz_level("(admin)")) {
        if (!call_other("/adm/daemons/kingd", "apply_creator_profile", user)
        ||  !call_other("/adm/daemons/kingd", "provision_creator_weapons", user)
        ||  !call_other("/adm/daemons/kingmartiald", "set_cold_plum", user, 300)
        ||  !call_other("/adm/daemons/kingmartiald", "set_creator_core_martial", user, 300)
        ||  !call_other("/adm/daemons/kingmartiald", "set_rulai_shenzhang", user, 300)
        ||  !call_other("/adm/daemons/kingmartiald", "set_daxie", user, 300)) {
            write("KING 正式能力配置失敗，已中止登入以避免錯誤狀態。\\n");
            destruct(ob);
            destruct(user);
            return;
        }
        write("KING 創世神配置已同步：八項屬性 99、六項狀態 999、五件武器已置入物品欄且不自動裝備、冷梅莊武學 300、易筋經 300、霸天煉體訣 300、如來神掌 300、大邪七損刀 300；可用 khome 前往天神殿・無極之境。\\n");
    }

#ifdef SAVE_USER
    // save newly created user；KING 正式配置也在此寫回 Original save data。
    user->save();
#endif
'''
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original enter_world setup/save 區段，無法加入 KING Login Provisioning。")
path.write_text(text.replace(needle, replacement, 1))
PY
fi

# 已生成過的舊 Runtime 可能沿用 mktemp 的 600；只補讀取權限，不授予任何 group／other 寫入權。
chmod go+r "$LOGIN_D"

# Public Character Creation Compatibility／公開創角相容層：
# WebSocket/Telnet 對 get_char 的 CR（回車）傳輸在 Public iPhone 上不可靠。
# 保留 Original 種族資料與後續 get_gender 流程，只把 Race 入口改成 input_to 文字輸入；
# human/avatar 因此以完整一行傳入，避免再次依賴單鍵 CR／方向鍵。
CHARACTER_COMPAT_MARKER='ES2-KING PUBLIC CHARACTER TEXT INPUT'
if ! grep -Fq "$CHARACTER_COMPAT_MARKER" "$LOGIN_D"; then
  python3 - "$LOGIN_D" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = '''    mapping opts = ([
        "prompt": "選擇你的角色所屬的種族: ",
        "options": user_race,
        "option_hints": (: call_other, CHAR_D, "hint_user_race" :),
        "cursor": 0
    ]);
    get_char ("get_race", 1, opts, ob);
}

private void get_race (string race, mixed opts, object ob) {
    string choice = cursor_translate (race, opts);
    switch (choice ? choice : race) {'''
new = '''    write ("選擇你的角色所屬的種族：\\n  1. Human（人類）\\n  2. Avatar（人類族）\\n  3. 黑齒\\n  4. 厭火\\n  5. 焦僥\\n  6. 無腸\\n  7. 釘靈\\n  8. 刑天\\n  9. 雨師妾\\n  10. 巫首\\n  11. 夜叉\\n  12. 阿修羅\\n請輸入編號 1-12 或種族 ID: ");
    input_to ("get_race", 0, ob);
}

// ES2-KING PUBLIC CHARACTER TEXT INPUT／Public WebTelnet Race 使用完整文字行，避開 get_char 的 CR 傳輸差異。
private void get_race (string race, object ob) {
    // Numeric Race／數字種族：Public WebTelnet 固定提交 1 或 2；Runtime 再映射回 Original human/avatar。
    // Neolith input_to 第二參數是 flags；要把 ob 傳給 callback 必須使用第三參數。先前 input_to("get_race", ob) 把 object 誤當 flags，造成 Public Race callback 無法取得正確 ob。
    // input_to 回呼取得的是已完成的一行文字；只接受 Public 定義的數字或 Original ID，不把 Telnet 行尾當成角色資料。
    if (race == "1" || race == "人類") race = "human";
    else if (race == "2" || race == "人類族") race = "avatar";
    else if (race == "3" || race == "黑齒") race = "blackteeth";
    else if (race == "4" || race == "厭火") race = "yenhold";
    else if (race == "5" || race == "焦僥") race = "jiaojao";
    else if (race == "6" || race == "無腸") race = "woochan";
    else if (race == "7" || race == "釘靈") race = "dingling";
    else if (race == "8" || race == "刑天") race = "headless";
    else if (race == "9" || race == "雨師妾") race = "rainner";
    else if (race == "10" || race == "巫首") race = "malik";
    else if (race == "11" || race == "夜叉") race = "yaksa";
    else if (race == "12" || race == "阿修羅") race = "ashura";
    switch (race) {'''
if old not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original get_email → get_race Race 區段。")
text = text.replace(old, new, 1)
old_retry = '''        default:
            get_char ("get_race", 1, opts, ob);
            return;
    }

    int kar'''
new_retry = '''        default:
            write ("請輸入編號 1-12 或種族 ID: ");
            input_to ("get_race", 0, ob);
            return;
    }

    int kar'''
start = text.index("// ES2-KING PUBLIC CHARACTER TEXT INPUT")
tail = text[start:]
if old_retry not in tail:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original get_race retry 區段。")
tail = tail.replace(old_retry, new_retry, 1)
text = text[:start] + tail
text = text.replace('write ("\\r" CLR HIY "選擇 " + choice + " 這個種族會累積 " + kar + " 點業力。\\n" NOR);',
                    'write ("\\r" CLR HIY "選擇 " + (race == "human" ? "Human（人類）" : "Avatar（人類族）") + " 這個種族會累積 " + kar + " 點業力。\\n" NOR);', 1)
path.write_text(text)
PY
fi

# Race Label Migration／種族標籤遷移：已套用舊版 compatibility marker 的 Runtime
# 不會再進入上方區塊；只更新玩家顯示名，不改 Original avatar ID 或初始化規則。
python3 - "$LOGIN_D" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = '  2. Avatar\\n請輸入編號 1-12 或種族 ID: '
new = '  2. Avatar（人類族）\\n請輸入編號 1-12 或種族 ID: '
if old in text:
    text = text.replace(old, new, 1)
old_mapping = '''    if (race == "1") race = "human";
    else if (race == "2") race = "avatar";'''
new_mapping = '''    if (race == "1" || race == "人類") race = "human";
    else if (race == "2" || race == "人類族") race = "avatar";'''
if old_mapping in text:
    text = text.replace(old_mapping, new_mapping, 1)
path.write_text(text)
PY

# KING Score Grid Bars／KING score 方格狀態條：只修改 Expansion Runtime 顯示層。
# Current／Effective／Maximum 仍沿用 Original tribar_graph 三值語意；不改 Statistic 或 Combat。
SCORE_CMD="$TARGET/mudlib/cmds/usr/score.c"
SCORE_GRID_MARKER='ES2-KING SCORE GRID BARS'
if ! grep -Fq "$SCORE_GRID_MARKER" "$SCORE_CMD"; then
  python3 - "$SCORE_CMD" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = text.replace(
    'string tribar_graph (string fill_char, string sep, string empty_char, int val, int eff, int max);',
    'string tribar_graph (string fill_char, string sep, string empty_char, int val, int eff, int max);\nstring score_grid_bar (string kind, string color, int val, int eff, int max); // ES2-KING SCORE GRID BARS'
)
text = text.replace(
    'NOR BGRN "%s" NOR "\\n\\n", line,\n        status_color(ob->query_stat("HP"), ob->query_stat_maximum("HP")),\n        ob->query_stat("HP"), ob->query_stat_maximum("HP"),\n        tribar_graph(" ", BRED, " ", ob->query_stat("HP"), ob->query_stat_effective("HP"), ob->query_stat_maximum("HP"))',
    'NOR "%s" NOR "\\n\\n", line,\n        status_color(ob->query_stat("HP"), ob->query_stat_maximum("HP")),\n        ob->query_stat("HP"), ob->query_stat_maximum("HP"),\n        score_grid_bar("HP", HIG, ob->query_stat("HP"), ob->query_stat_effective("HP"), ob->query_stat_maximum("HP"))'
)
text = text.replace(
    'NOR HIY "%s" NOR "\\n", line,\n            status_color (ob->query_stat("gin"), ob->query_stat_maximum ("gin")),\n            ob->query_stat ("gin"), ob->query_stat_maximum ("gin"),\n            tribar_graph ("%", YEL, ">",ob->query_stat ("gin"), ob->query_stat_effective ("gin"), ob->query_stat_maximum ("gin"))',
    'NOR "%s" NOR "\\n", line,\n            status_color (ob->query_stat("gin"), ob->query_stat_maximum ("gin")),\n            ob->query_stat ("gin"), ob->query_stat_maximum ("gin"),\n            score_grid_bar("GIN", HIR, ob->query_stat("gin"), ob->query_stat_effective("gin"), ob->query_stat_maximum("gin"))'
)
text = text.replace(
    'NOR HIR "%s" NOR "\\n", line,\n            status_color (ob->query_stat("kee"), ob->query_stat_maximum ("kee")),\n            ob->query_stat ("kee"), ob->query_stat_maximum ("kee"),\n            tribar_graph ("%", RED, ">", ob->query_stat ("kee"), ob->query_stat_effective ("kee"), ob->query_stat_maximum ("kee"))',
    'NOR "%s" NOR "\\n", line,\n            status_color (ob->query_stat("kee"), ob->query_stat_maximum ("kee")),\n            ob->query_stat ("kee"), ob->query_stat_maximum ("kee"),\n            score_grid_bar("KEE", HIB, ob->query_stat("kee"), ob->query_stat_effective("kee"), ob->query_stat_maximum("kee"))'
)
text = text.replace(
    'NOR HIB "%s" NOR "\\n", line,\n            status_color (ob->query_stat("sen"), ob->query_stat_maximum ("sen")),\n            ob->query_stat ("sen"), ob->query_stat_maximum ("sen"),\n            tribar_graph ("%", BLU, ">", ob->query_stat ("sen"), ob->query_stat_effective ("sen"), ob->query_stat_maximum ("sen"))',
    'NOR "%s" NOR "\\n", line,\n            status_color (ob->query_stat("sen"), ob->query_stat_maximum ("sen")),\n            ob->query_stat ("sen"), ob->query_stat_maximum ("sen"),\n            score_grid_bar("SEN", HIY, ob->query_stat("sen"), ob->query_stat_effective("sen"), ob->query_stat_maximum("sen"))'
)
needle='string tribar_graph (string fill_char, string sep, string empty_char, int val, int eff, int max) {'
helper=r'''// ES2-KING SCORE GRID BARS／純文字單 glyph 獨立方格；保留 Original current/effective/maximum 三值。
string score_grid_bar (string kind, string color, int val, int eff, int max) {
    int i, n_filled, n_effective;
    string bar = "ES2GRID:" + kind + ":";

    if (max <= 0) return "";

    n_filled = val * 28 / max;
    n_effective = eff * 28 / max;
    if (n_filled < 0) n_filled = 0;
    if (n_filled > 28) n_filled = 28;
    if (n_effective < n_filled) n_effective = n_filled;
    if (n_effective > 28) n_effective = 28;

    for (i = 0; i < 28; i++) {
        if (i < n_filled)
            bar += "F";
        else if (i < n_effective)
            bar += "E";
        else
            bar += "M";
    }
    return bar + ":END";
}

'''
if needle not in text:
    raise SystemExit("EXPANSION APPLY FAIL：找不到 Original tribar_graph，無法加入 score 方格條。")
text=text.replace(needle,helper+needle,1)
path.write_text(text)
PY
fi

# Command Reindex Compatibility／指令重索引相容層：只有實際管理員搜尋路徑包含
# /cmds/adm/ 且指令檔存在時，才補入四個已定稿 KING 指令的 Runtime 記憶體索引。
COMMAND_D="$TARGET/mudlib/adm/daemons/cmd_d.c"
COMMAND_REHASH_MARKER='ES2-KING OWNER COMMAND REHASH'
if ! grep -Fq "$COMMAND_REHASH_MARKER" "$COMMAND_D"; then
  temp_command="$(mktemp)"
  awk -v marker="$COMMAND_REHASH_MARKER" '
    /^    if\( !pointerp\(path\) \) return 0;/ && !inserted {
      print
      print ""
      print "    // " marker "／不擴張一般玩家搜尋路徑。"
      print "    if (member_array(\"/cmds/adm/\", path) >= 0"
      print "    && member_array(verb, ({ \"kingcreate\", \"kinghome\", \"kingmartial\", \"kingcanon\" })) >= 0"
      print "    && file_size(\"/cmds/adm/\" + verb + \".c\") >= 0)"
      print "        cache[verb + \".c\"] = ({ \"/cmds/adm/\" });"
      inserted=1
      next
    }
    { print }
  ' "$COMMAND_D" > "$temp_command"
  chmod --reference="$COMMAND_D" "$temp_command"
  mv "$temp_command" "$COMMAND_D"
fi

# Selective Binary Cache Invalidation／選擇性二進位快取失效：只移除會遮蔽新版 logind、
# 指令索引或本次 Expansion 武學的特定舊 .b；其餘 Original binary cache 完整保留。
# 下一次 Boot 會重新編譯，COMMAND_D 則沿用 Original 的首次路徑自動 rehash。
for cached_binary in \
  "$TARGET/mudlib/bin/adm/daemons/logind.b" \
  "$TARGET/mudlib/bin/adm/daemons/cmd_d.b" \
  "$TARGET/mudlib/bin/std/race/humanoid.b" \
  "$TARGET/mudlib/bin/feature/attribute.b" \
  "$TARGET/mudlib/bin/adm/daemons/kingmartiald.b" \
  "$TARGET/mudlib/bin/adm/daemons/kadmind.b" \
  "$TARGET/mudlib/bin/cmds/std/perform.b" \
  "$TARGET/mudlib/bin/daemon/skill/kuxiao_force.b" \
  "$TARGET/mudlib/bin/daemon/skill/qisun_blade.b" \
  "$TARGET/mudlib/bin/daemon/skill/qishang_staff.b" \
  "$TARGET/mudlib/bin/d/arena/skill/lunmay.b" \
  "$TARGET/mudlib/bin/d/arena/npc/mei_hanshuang.b"
do
  if [[ -e "$cached_binary" ]]; then
    unlink "$cached_binary"
  fi
done

# Command Warm Load／指令預先載入：Neolith 第一次 call_other 新增 command object 時可能只完成載入；
# 將四個既有 Owner 指令加入 Generated Runtime preload，確保首次玩家輸入即可執行且無需手動 reload。
PRELOAD_FILE="$TARGET/mudlib/adm/etc/preload"
# Expansion Skill Warm Load／擴充技能預先載入：先註冊哭笑門心法與大邪七損刀，
# 讓第一次 perform 即可載入正確 daemon，不需要 Owner 手動 update／rehash。
for expansion_skill in kuxiao_force qisun_blade qishang_staff; do
  grep -Fqx "/daemon/skill/$expansion_skill" "$PRELOAD_FILE" \
    || printf '%s\n' "/daemon/skill/$expansion_skill" >> "$PRELOAD_FILE"
done
for arena_preload in /d/arena/skill/lunmay /d/arena/npc/mei_hanshuang; do
  grep -Fqx "$arena_preload" "$PRELOAD_FILE" || printf '%s\n' "$arena_preload" >> "$PRELOAD_FILE"
done
for owner_command in kingcreate kinghome kingmartial kingcanon kadmin kcreate khome kmartial kcanon; do
  grep -Fqx "/cmds/adm/$owner_command" "$PRELOAD_FILE" \
    || printf '%s\n' "/cmds/adm/$owner_command" >> "$PRELOAD_FILE"
done

# Owner provisioning／擁有者授權配置：只在獨立 Expansion Runtime 登錄帳號 ID；密碼仍由 Original 登入系統建立、雜湊與驗證。
WIZLIST="$TARGET/mudlib/adm/etc/wizlist"
touch "$WIZLIST"
grep -Fqx 'king (admin)' "$WIZLIST" || printf '%s\n' 'king (admin)' >> "$WIZLIST"
echo "ES2-KING EXPANSION APPLY PASS／Expansion 已套用至獨立 Runtime：$TARGET"
