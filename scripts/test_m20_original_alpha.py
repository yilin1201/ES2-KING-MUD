#!/usr/bin/env python3
"""M20 Original ES2 Alpha 真實 Telnet（文字連線協定）驗收。"""
import re
import sys
import telnetlib
import time

ANSI = re.compile(r"\x1b\[[0-9;?]*[ -/]*[@-~]")


def read(tn, output, seconds=0.8):
    """在有限時間內收集伺服器輸出，避免測試永久等待。"""
    end = time.time() + seconds
    while time.time() < end:
        try:
            data = tn.read_very_eager()
            if data:
                output.extend(data)
        except (EOFError, OSError):
            break
        time.sleep(0.05)


def line(tn, output, value, seconds=0.8):
    tn.write(value.encode() + b"\r\n")
    read(tn, output, seconds)


def key(tn, output, value, seconds=0.8):
    tn.write(value.encode())
    read(tn, output, seconds)


def clean(output):
    return re.sub(r"\s+", " ", ANSI.sub("", output.decode(errors="replace")))


tn = telnetlib.Telnet("127.0.0.1", 4000, timeout=5)
buf = bytearray()
read(tn, buf, 1)
line(tn, buf, "malpha")
key(tn, buf, "Y")
line(tn, buf, "m20pass")
line(tn, buf, "m20pass")
line(tn, buf, "none")
key(tn, buf, "\r")
key(tn, buf, "M")
line(tn, buf, "阿法驗收")
key(tn, buf, "Y", 1.5)
for command in ("look", "score", "inventory", "west", "look", "east", "look"):
    line(tn, buf, command)
first = clean(buf)
print(first)
required = ["【 平民 】阿法驗收 (Malpha)", "目前是等級 1 的平民", "男性人類", "客棧大堂", "廚房"]
missing = [item for item in required if item not in first]
if missing:
    sys.exit("M20 ALPHA FAIL／首次連線旅程缺少：" + repr(missing))
line(tn, buf, "quit", 1.0)
tn.close()
time.sleep(1)

# Persistence／持久化：重新登入同一帳號，必須辨識既有角色。
tn = telnetlib.Telnet("127.0.0.1", 4000, timeout=5)
buf = bytearray()
read(tn, buf, 1)
line(tn, buf, "malpha")
before_password = clean(buf)
if "創造一個新的人物" in before_password or "請輸入密碼" not in before_password:
    sys.exit("M20 ALPHA FAIL／帳號或角色未保存")
line(tn, buf, "m20pass", 1.5)
line(tn, buf, "look")
line(tn, buf, "score")
second = clean(buf)
print(second)
if "【 平民 】阿法驗收 (Malpha)" not in second or "客棧大堂" not in second:
    sys.exit("M20 ALPHA FAIL／重新登入後角色或房間不正確")
print("M20 ALPHA PASS／連線、創角、房間、基本指令、移動與重新登入全部通過。")
line(tn, buf, "quit", 0.3)
tn.close()
