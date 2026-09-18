#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/m30/.runtime/es2-king}"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT

mkdir -p "$TEMP_ROOT/runtime"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/runtime/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/runtime/neolith.conf"

# Container Path（容器路徑）模擬：Docker 的 /opt 與 Runtime parent 可被非 root 使用者穿越。
chmod 755 "$TEMP_ROOT" "$TEMP_ROOT/runtime" "$TEMP_ROOT/runtime/mudlib"
bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT/runtime"

LOGIN_D="$TEMP_ROOT/runtime/mudlib/adm/daemons/logind.c"
COMMAND_D="$TEMP_ROOT/runtime/mudlib/adm/daemons/cmd_d.c"
bash "$REPO_ROOT/scripts/assert_m30_final_runtime.sh" "$TEMP_ROOT/runtime"

# Work 隔離環境禁止 setuid；改以 Unix mode（Unix 權限模式）逐層證明非 owner 使用者可穿越、
# logind.c 可讀且不可寫。Render 真實非 root 執行仍由下一次容器部署驗證。
for directory in "$TEMP_ROOT" "$TEMP_ROOT/runtime" "$TEMP_ROOT/runtime/mudlib" \
                 "$TEMP_ROOT/runtime/mudlib/adm" "$TEMP_ROOT/runtime/mudlib/adm/daemons"; do
  mode="$(stat -c '%a' "$directory")"
  permissions=$((8#$mode))
  (( (permissions & 0001) != 0 )) || {
    echo "FINAL RUNTIME PERMISSION FAIL（最終執行環境權限失敗）：非 owner 無法穿越 $directory。" >&2
    exit 1
  }
done

for runtime_source in "$LOGIN_D" "$COMMAND_D"; do
  mode="$(stat -c '%a' "$runtime_source")"
  permissions=$((8#$mode))
  (( (permissions & 0004) != 0 )) || {
    echo "FINAL RUNTIME PERMISSION FAIL（最終執行環境權限失敗）：非 owner 無法讀取 $runtime_source。" >&2
    exit 1
  }
  (( (permissions & 0022) == 0 )) || {
    echo "FINAL RUNTIME PERMISSION FAIL（最終執行環境權限失敗）：group／other 不應寫入 $runtime_source。" >&2
    exit 1
  }
done

echo "FINAL RUNTIME PERMISSION PASS（最終執行環境權限測試通過）：mode 證據確認非 root 使用者可穿越並讀取 logind.c／cmd_d.c、不可寫入；安全斷言內容亦通過。"
