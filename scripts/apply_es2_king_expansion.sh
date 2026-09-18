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
if ! grep -Fq "$RESERVATION_MARKER" "$LOGIN_D"; then
  insertion_line="$(grep -n -m1 '^    mapping opts = (\[$' "$LOGIN_D" | cut -d: -f1)"
  test -n "$insertion_line" || {
    echo 'EXPANSION APPLY FAIL：找不到 Original 新帳號確認流程，無法安全保留 KING ID。' >&2
    exit 1
  }
  temp_login="$(mktemp)"
  head -n "$((insertion_line - 1))" "$LOGIN_D" > "$temp_login"
  cat >> "$temp_login" <<'LPC'
    // ES2-KING PUBLIC OWNER ID RESERVATION／公開 Owner 帳號保留。
    // 既有 KING 存檔已在前段載入；走到這裡代表帳號不存在，禁止公開訪客建立。
    if (arg == "king") {
        write("\nKING Owner 帳號尚未在此 Runtime 初始化，已拒絕公開註冊。\n\n");
        // 不銷毀互動登入物件；清除暫存 ID 後回到 Original 登入流程，
        // 讓拒絕訊息與下一個安全提示完整送達 Telnet／WebSocket Client。
        ob->delete("id");
        logon(ob);
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

# Owner provisioning／擁有者授權配置：只在獨立 Expansion Runtime 登錄帳號 ID；密碼仍由 Original 登入系統建立、雜湊與驗證。
WIZLIST="$TARGET/mudlib/adm/etc/wizlist"
touch "$WIZLIST"
grep -Fqx 'king (admin)' "$WIZLIST" || printf '%s\n' 'king (admin)' >> "$WIZLIST"
echo "ES2-KING EXPANSION APPLY PASS／Expansion 已套用至獨立 Runtime：$TARGET"
