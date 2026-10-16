#!/usr/bin/env bash
set -euo pipefail

# Race Regression／種族回歸測試：以 ES2M 快照為準，驗證 KING Runtime 種族相容性。
ROOT="${1:-.runtime/original-es2}"
RACE_DIR="$ROOT/mudlib/daemon/race"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ES2M_RACE_DIR="$REPO_ROOT/es2m_snapshot/mudlib/daemon/race"
CMD_DIR="$ROOT/mudlib/cmds/usr"

# ES2M source contract／來源契約：三個優先 Runtime daemon 必須存在。
for race in human avatar headless; do
  test -f "$RACE_DIR/$race.c" || {
    echo "FAIL／Runtime 缺少優先種族檔案：$race.c" >&2
    exit 1
  }
done

# ES2M karma contract／明確鎖定第三方重建快照的 karma，不能只依賴檔案一致性。
# ES2M 的 human/avatar karma 均為 5；Original Avatar karma=100 由獨立 Original source gate 驗證。
grep -Fq 'set("karma", 5);' "$ES2M_RACE_DIR/human.c"
grep -Fq 'set("karma", 5);' "$ES2M_RACE_DIR/avatar.c"
grep -Fq 'set("karma", 5);' "$RACE_DIR/human.c"
grep -Fq 'set("karma", 5);' "$RACE_DIR/avatar.c"

# Human／人類：13–18 屬性、精氣神 35、自然護甲 +10、來源指定的 0.01% 化身轉換。
grep -Fq '13 + random(6)' "$RACE_DIR/human.c"
grep -Fq '"gin":35, "kee":35, "sen":35' "$RACE_DIR/human.c"
grep -Fq '"apply/armor", 10' "$RACE_DIR/human.c"
grep -Fq 'random(10000) == 9999' "$RACE_DIR/human.c"

# Avatar／化身：15–20 屬性、精氣神 30、自然護甲 +10。
grep -Fq '15 + random(6)' "$RACE_DIR/avatar.c"
grep -Fq '"gin":30, "kee":30, "sen":30' "$RACE_DIR/avatar.c"
grep -Fq '"apply/armor", 10' "$RACE_DIR/avatar.c"

# Headless／刑天：ES2M 隨機屬性、資源、自然護甲、攻防及裝備限制。
for token in '25+random(6)' '"cor":15+random(6)' '"int":8+random(6)' '"cps":11+random(6)' '"gin":80, "kee":100, "sen":30' '"apply/armor", 50' '"apply/attack", 30' '"apply/defense", 20' '"armor", "cloth", "head_eq", "neck_eq"'; do
  grep -Fq "$token" "$RACE_DIR/headless.c" || {
    echo "FAIL／刑天 ES2M 契約缺少：$token" >&2
    exit 1
  }
done

# Login registry／登入種族清單及接受邏輯均須包含所有 12 個種族。
ALL_RACES=(human avatar blackteeth yenhold woochan dingling jiaojao rainner ashura headless yaksa malik)
for race in "${ALL_RACES[@]}"; do
  test -f "$ES2M_RACE_DIR/$race.c" || {
    echo "FAIL／缺少 ES2M 種族快照：$race.c" >&2
    exit 1
  }
  test -f "$RACE_DIR/$race.c" || {
    echo "FAIL／Runtime 缺少種族檔案：$race.c" >&2
    exit 1
  }
  cmp -s "$ES2M_RACE_DIR/$race.c" "$RACE_DIR/$race.c" || {
    echo "FAIL／Runtime 種族檔與 ES2M 快照不一致：$race.c" >&2
    diff -u "$ES2M_RACE_DIR/$race.c" "$RACE_DIR/$race.c" | head -n 80 || true
    exit 1
  }
  grep -q "\"$race\"" "$LOGIN" || {
    echo "FAIL／登入種族清單缺少：$race" >&2
    exit 1
  }
  grep -q "case \"$race\":" "$LOGIN" || {
    echo "FAIL／登入接受邏輯缺少種族：$race" >&2
    exit 1
  }
done

# Race command reachability／所有映射種族指令必須真正複製至玩家 command path，且與快照一致。
# 只檢查 daemon/race/<race> 下的來源檔不足以證明玩家可執行。
for pair in human:resurge avatar:radiate blackteeth:gnaw yenhold:breathe woochan:replete dingling:hoof jiaojao:hide rainner:feed headless:dance yaksa:devour; do
  race="${pair%%:*}"
  command="${pair#*:}"
  test -f "$ES2M_RACE_DIR/$race/$command.c" || {
    echo "FAIL／ES2M 缺少種族指令：$race/$command.c" >&2
    exit 1
  }
  test -f "$RACE_DIR/$race/$command.c" || {
    echo "FAIL／Runtime 缺少種族指令：$race/$command.c" >&2
    exit 1
  }
  cmp -s "$ES2M_RACE_DIR/$race/$command.c" "$RACE_DIR/$race/$command.c" || {
    echo "FAIL／Runtime 種族指令與快照不一致：$race/$command.c" >&2
    exit 1
  }
  test -f "$CMD_DIR/$command.c" || {
    echo "FAIL／玩家指令路徑缺少：cmds/usr/$command.c" >&2
    exit 1
  }
  cmp -s "$ES2M_RACE_DIR/$race/$command.c" "$CMD_DIR/$command.c" || {
    echo "FAIL／玩家指令與 ES2M 快照不一致：cmds/usr/$command.c" >&2
    exit 1
  }
done
grep -Fq '[human]=resurge' "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh"
grep -Fq '[avatar]=radiate' "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh"
grep -Fq '[yenhold]=breathe' "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh"

echo 'RACE ES2M REGRESSION PASS／12 個 Runtime 種族檔與 ES2M 快照一致，登入清單及優先種族、10 個玩家指令來源及實際 command path 契約通過；不代表 LPC 編譯或 Runtime E2E 已通過。'
