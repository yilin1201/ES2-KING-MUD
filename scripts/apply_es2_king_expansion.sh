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
        write("KING Owner 帳號尚未在此 Runtime 初始化，已拒絕公開註冊。\n");
        destruct(ob);
        return;
    }

LPC
  tail -n "+$insertion_line" "$LOGIN_D" >> "$temp_login"
  mv "$temp_login" "$LOGIN_D"
fi

# Owner provisioning／擁有者授權配置：只在獨立 Expansion Runtime 登錄帳號 ID；密碼仍由 Original 登入系統建立、雜湊與驗證。
WIZLIST="$TARGET/mudlib/adm/etc/wizlist"
touch "$WIZLIST"
grep -Fqx 'king (admin)' "$WIZLIST" || printf '%s\n' 'king (admin)' >> "$WIZLIST"
echo "ES2-KING EXPANSION APPLY PASS／Expansion 已套用至獨立 Runtime：$TARGET"
