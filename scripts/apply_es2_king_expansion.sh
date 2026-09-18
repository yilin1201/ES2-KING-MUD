#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-.runtime/es2-king}"
SOURCE="es2_king_expansion/runtime/mudlib"
test -d "$TARGET/mudlib" || { echo "EXPANSION APPLY FAIL：缺少 $TARGET/mudlib，請先建立獨立 Runtime。" >&2; exit 1; }
test -d "$SOURCE"
cp -a "$SOURCE/." "$TARGET/mudlib/"

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

    // king.o 一旦存在，Claim 永久退出；之後只能走 Original 密碼驗證。
    if (file_size(login_data("king")) != -1) {
        ob->delete("id");
        logon(ob);
        return;
    }

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
    // 只有 Runtime Secret 已安全設定時才顯示 Claim Prompt；未設定仍維持公開拒絕。
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

# 已生成過的舊 Runtime 可能沿用 mktemp 的 600；只補讀取權限，不授予任何 group／other 寫入權。
chmod go+r "$LOGIN_D"

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
      print "    && member_array(verb, ({ \"kingcreate\", \"kingrealm\", \"kingmartial\", \"kingcanon\" })) >= 0"
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

# Selective Binary Cache Invalidation／選擇性二進位快取失效：只移除會遮蔽新版 logind，
# 或會保存 Expansion 套用前指令索引的兩個舊 .b；其餘 Original binary cache 完整保留。
# 下一次 Boot 會重新編譯，COMMAND_D 則沿用 Original 的首次路徑自動 rehash。
for cached_binary in \
  "$TARGET/mudlib/bin/adm/daemons/logind.b" \
  "$TARGET/mudlib/bin/adm/daemons/cmd_d.b"
do
  if [[ -e "$cached_binary" ]]; then
    unlink "$cached_binary"
  fi
done

# Command Warm Load／指令預先載入：Neolith 第一次 call_other 新增 command object 時可能只完成載入；
# 將四個既有 Owner 指令加入 Generated Runtime preload，確保首次玩家輸入即可執行且無需手動 reload。
PRELOAD_FILE="$TARGET/mudlib/adm/etc/preload"
for owner_command in kingcreate kingrealm kingmartial kingcanon; do
  grep -Fqx "/cmds/adm/$owner_command" "$PRELOAD_FILE" \
    || printf '%s\n' "/cmds/adm/$owner_command" >> "$PRELOAD_FILE"
done

# Owner provisioning／擁有者授權配置：只在獨立 Expansion Runtime 登錄帳號 ID；密碼仍由 Original 登入系統建立、雜湊與驗證。
WIZLIST="$TARGET/mudlib/adm/etc/wizlist"
touch "$WIZLIST"
grep -Fqx 'king (admin)' "$WIZLIST" || printf '%s\n' 'king (admin)' >> "$WIZLIST"
echo "ES2-KING EXPANSION APPLY PASS／Expansion 已套用至獨立 Runtime：$TARGET"
