#!/usr/bin/env bash
set -euo pipefail

# Developer Bootstrap／開發者測試角色種子。
# 目的：讓 Game Completion Track 的 Runtime 測試不再依賴 Public WebTelnet 創角。
# 邊界：只允許明確指定的測試資料目錄；不修改 Original source，也不接受正式 ES2_SAVE_DIR。
TARGET="${1:-.runtime/game-completion-data}"
FIXTURE="${2:-.runtime/game-completion-fixture/king}"

case "$TARGET" in
  .runtime/game-completion-data|.runtime/game-completion-data/*) ;;
  *) echo "GAME COMPLETION BOOTSTRAP FAIL：只允許 .runtime/game-completion-data 測試路徑。" >&2; exit 1 ;;
esac

test -d "$FIXTURE" || {
  echo "GAME COMPLETION BOOTSTRAP BLOCKED：缺少經 Runtime 產生並去除秘密的 KING fixture：$FIXTURE" >&2
  echo "不得猜測 Original ES2 save_object 格式；請先由本機 Runtime 建立一次 fixture。" >&2
  exit 2
}

rm -rf "$TARGET"
mkdir -p "$TARGET/login/k" "$TARGET/user/k"
for f in "$FIXTURE"/login/king.o "$FIXTURE"/user/king.o; do
  test -f "$f" || { echo "GAME COMPLETION BOOTSTRAP FAIL：缺少 fixture $f" >&2; exit 1; }
done

# Secret Guard／秘密防護：Fixture 不得保存 Claim Token、明文 password 或 Web transport。
if grep -Eiq 'ES2_KING_CLAIM_TOKEN|es2claim1:|password[[:space:]]*[:=]' "$FIXTURE"/login/king.o "$FIXTURE"/user/king.o; then
  echo "GAME COMPLETION BOOTSTRAP FAIL：fixture 疑似包含秘密資料，拒絕複製。" >&2
  exit 1
fi

cp "$FIXTURE/login/king.o" "$TARGET/login/k/king.o"
cp "$FIXTURE/user/king.o" "$TARGET/user/k/king.o"
echo "GAME COMPLETION BOOTSTRAP PASS：已建立隔離 Test Character data；正式 Original/Public 創角流程未修改。"
