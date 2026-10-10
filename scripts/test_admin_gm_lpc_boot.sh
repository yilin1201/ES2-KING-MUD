#!/usr/bin/env bash
set -euo pipefail

# ADMIN GM LPC Load Gate／使用真實 Neolith Driver 啟動生成 Runtime，
# 讓 preload 實際載入 /cmds/adm/admin；只檢查編譯／載入與服務啟動，不冒充玩家指令 E2E。
ROOT="${1:-.runtime/es2-king}"
LOG="$(mktemp)"
DRIVER=""
PID=""

cleanup() {
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
  rm -f "$LOG"
}
trap cleanup EXIT

test -d "$ROOT/mudlib" || { echo "ADMIN GM LPC LOAD FAIL：缺少生成 Runtime $ROOT/mudlib" >&2; exit 1; }
test -f "$ROOT/mudlib/cmds/adm/admin.c" || { echo "ADMIN GM LPC LOAD FAIL：缺少 admin.c" >&2; exit 1; }
test -f "$ROOT/mudlib/adm/etc/preload" || { echo "ADMIN GM LPC LOAD FAIL：缺少 preload" >&2; exit 1; }
grep -Fqx '/cmds/adm/admin' "$ROOT/mudlib/adm/etc/preload" || {
  echo "ADMIN GM LPC LOAD FAIL：admin 未加入 preload" >&2; exit 1;
}

# 測試帳號只寫入 CI 的暫存 Runtime，不提交到 Repository 或正式環境。
WIZLIST="$ROOT/mudlib/adm/etc/wizlist"
grep -Fqx 'gmtest (admin)' "$WIZLIST" || printf '%s\n' 'gmtest (admin)' >> "$WIZLIST"

DRIVER="$(find "$ROOT/neolith/out" -type f -name neolith -perm -111 | head -n 1)"
test -n "$DRIVER" || { echo "ADMIN GM LPC LOAD FAIL：找不到已建置的 Neolith Driver" >&2; exit 1; }
# 轉成絕對路徑，再切換到 Runtime 根目錄，避免相對路徑被重複拼接。
DRIVER="$(realpath "$DRIVER")"

cd "$ROOT"
"$DRIVER" -f neolith.conf -c >"$LOG" 2>&1 &
PID=$!

# Wait for the actual TCP listener; a live process alone does not prove boot completed.
python3 - "$PID" "$LOG" <<'PY'
import os, socket, sys, time
pid, log = int(sys.argv[1]), sys.argv[2]
for _ in range(45):
    try:
        os.kill(pid, 0)
    except OSError:
        print(open(log, errors="replace").read())
        raise SystemExit("ADMIN GM LPC LOAD FAIL：Neolith 在開啟服務前退出。")
    sock = socket.socket()
    sock.settimeout(0.5)
    try:
        sock.connect(("127.0.0.1", 4000))
        sock.close()
        break
    except OSError:
        sock.close()
        time.sleep(1)
else:
    print(open(log, errors="replace").read())
    raise SystemExit("ADMIN GM LPC LOAD FAIL：45 秒內未監聽 TCP 4000。")
PY

# Neolith may continue boot after a preload compile error, so inspect the boot log explicitly.
if grep -Eiq 'Error in loading object: /cmds/adm/admin|/cmds/adm/admin(\.c)?.*(compile error|syntax error|failed to load)|admin\.c.*(compile error|syntax error)' "$LOG"; then
  cat "$LOG"
  echo "ADMIN GM LPC LOAD FAIL：admin.c 發生 LPC 編譯／載入錯誤。" >&2
  exit 1
fi

# Admin command E2E／建立臨時最高管理員帳號，實際執行指令與數值邊界檢查。
python3 - <<'PY'
import re, sys, telnetlib, time

ANSI = re.compile(r'\x1b\[[0-9;?]*[ -/]*[@-~]')

def session():
    return telnetlib.Telnet('127.0.0.1', 4000, timeout=5)

def read(tn, buf, seconds=0.8):
    end = time.time() + seconds
    while time.time() < end:
        try:
            data = tn.read_very_eager()
            if data:
                buf.extend(data)
        except (EOFError, ConnectionResetError, BrokenPipeError, OSError):
            return
        time.sleep(0.05)

def line(tn, buf, value, seconds=0.8):
    try:
        tn.write(value.encode() + b'\r\n')
    except OSError:
        return ''
    start = len(buf)
    read(tn, buf, seconds)
    return ANSI.sub('', bytes(buf[start:]).decode(errors='replace'))

def key(tn, buf, value, seconds=0.8):
    try:
        tn.write(value.encode())
    except OSError:
        return ''
    start = len(buf)
    read(tn, buf, seconds)
    return ANSI.sub('', bytes(buf[start:]).decode(errors='replace'))

def text(buf):
    return ANSI.sub('', bytes(buf).decode(errors='replace'))

def attrs_from(output):
    return dict((k, int(v)) for k, v in re.findall(
        r'^\s*(str|cor|int|spi|cps|dex|con|wis)\s*:\s*(\d+)\s*',
        output, re.M))

def require(condition, message, output=''):
    if not condition:
        if output:
            print(output)
        raise SystemExit('ADMIN GM E2E FAIL：' + message)

tn = session()
buf = bytearray()
read(tn, buf, 1.0)
line(tn, buf, 'gmtest', 1.0)
key(tn, buf, 'Y', 0.6)
line(tn, buf, 'gmtestpass', 0.6)
line(tn, buf, 'gmtestpass', 0.6)
line(tn, buf, 'none', 0.6)
key(tn, buf, '\r', 0.6)
key(tn, buf, 'M', 0.6)
line(tn, buf, 'GM測試', 0.6)
key(tn, buf, 'Y', 1.5)

probe = line(tn, buf, 'admin probe', 1.0)
require('ADMIN PROBE: main() reached' in probe,
        '管理員帳號無法呼叫 admin probe，或命令未正確派送。', text(buf))

set_attrs = line(tn, buf, 'admin attrs 50', 0.8)
require('八大屬性已驗證設定為 50' in set_attrs,
        'admin attrs 50 未成功回報。', set_attrs)
inspect = line(tn, buf, 'admin inspect', 0.8)
require(attrs_from(inspect) == dict((k, 50) for k in
        ('str','cor','int','spi','cps','dex','con','wis')),
        '八大屬性設定 50 後讀回不一致。', inspect)

bad_attrs = line(tn, buf, 'admin attrs 51', 0.8)
require('屬性數值須介於 1～50' in bad_attrs,
        'admin attrs 51 未被原版屬性上限拒絕。', bad_attrs)
inspect = line(tn, buf, 'admin inspect', 0.8)
require(attrs_from(inspect) == dict((k, 50) for k in
        ('str','cor','int','spi','cps','dex','con','wis')),
        '拒絕 attrs 51 後既有屬性發生變動。', inspect)

set_skill = line(tn, buf, 'admin skill blade 200', 0.8)
require('blade = 200' in set_skill, '技能等級 200 未成功設定。', set_skill)
inspect = line(tn, buf, 'admin inspect', 0.8)
require(re.search(r'blade\s*:\s*200', inspect) is not None,
        '技能等級 200 讀回不一致。', inspect)

bad_skill = line(tn, buf, 'admin skill blade 201', 0.8)
require('技能等級須介於 0～200' in bad_skill,
        'admin skill 201 未被原版技能上限拒絕。', bad_skill)
inspect = line(tn, buf, 'admin inspect', 0.8)
require(re.search(r'blade\s*:\s*200', inspect) is not None,
        '拒絕技能等級 201 後技能值發生變動。', inspect)

bad_level = line(tn, buf, 'admin level 1000', 0.8)
require('角色等級須介於 1～999' in bad_level,
        'admin level 1000 未被原版角色等級上限拒絕。', bad_level)

print('ADMIN GM E2E PASS：admin probe、屬性 50/51、技能 200/201、等級 1000 邊界均通過。')
line(tn, buf, 'quit', 0.4)
tn.close()
PY

echo "ADMIN GM LPC LOAD PASS／Neolith 啟動、admin.c 預載及管理員指令 E2E 全部通過。"
