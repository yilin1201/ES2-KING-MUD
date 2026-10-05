#!/usr/bin/env python3
"""套用 ES2M 批量交易的 KING 安全整合版；不改寫上游證據來源。"""

from __future__ import annotations

import argparse
import hashlib
import shutil
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source/es2m_updates/20261005_5f042999/runtime_overlay/mudlib"


@dataclass(frozen=True)
class Overlay:
    """Runtime 覆蓋項目：來源及可接受的舊版目標都以 SHA-256 鎖定。"""

    path: str
    source_sha256: str
    baseline_sha256: str


OVERLAYS = (
    Overlay("cmds/std/buy.c",
            "e53157c553678fac87be4bf76604a4cc355e870e06eaf2eacb5d754e2b85f71f",
            "f087bd029bc84ab92b0fc9fdb84dfa61aa0efc2574ebd7ff80cfc5e52ffeccb4"),
    Overlay("feature/npc/vendor.c",
            "e37b58a489a57a28cf82a682475368fa9eca7097de355bcd419cd74fd3f8536a",
            "2871cd5edcea2c300ac668e38d901f8e9a7ac21219ff878d2e4943844f29ea8b"),
    Overlay("d/snow/npc/waiter.c",
            "a5c3a0d2b99ecdc977d05695bbe4009b0cd756d5b130d0854a84a1e1716a14f8",
            "10b35ac582e2c36b20e58737e308fc2113e71cad37b618a8e94e2e91a702dddb"),
)


def digest(path: Path) -> str:
    """計算固定 SHA-256，避免未知 Runtime 被靜默覆蓋。"""

    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(runtime_mudlib: Path) -> None:
    """寫入前一次檢查全部檔案，防止只套用半筆交易功能。"""

    for item in OVERLAYS:
        source = SOURCE / item.path
        target = runtime_mudlib / item.path
        if not source.is_file():
            raise RuntimeError(f"缺少 KING 交易整合來源：{source}")
        if digest(source) != item.source_sha256:
            raise RuntimeError(f"交易整合來源 SHA 不符：{item.path}")
        if not target.is_file():
            raise RuntimeError(f"Runtime 缺少交易相依檔：{item.path}")
        actual = digest(target)
        if actual not in (item.baseline_sha256, item.source_sha256):
            raise RuntimeError(f"Runtime 交易檔衝突，停止覆蓋：{item.path} {actual}")


def apply(runtime_mudlib: Path) -> int:
    """只更新三個交易檔並清除同路徑 LPC 編譯快取。"""

    validate(runtime_mudlib)
    changed = 0
    for item in OVERLAYS:
        source = SOURCE / item.path
        target = runtime_mudlib / item.path
        if digest(target) != item.source_sha256:
            shutil.copy2(source, target)
            changed += 1
        (runtime_mudlib / "bin" / Path(item.path).with_suffix(".b")).unlink(missing_ok=True)
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description="套用 ES2M 批量交易安全整合版")
    parser.add_argument("--runtime", type=Path, required=True,
                        help="隔離 Runtime 的 mudlib 目錄")
    args = parser.parse_args()
    changed = apply(args.runtime.resolve())
    print(f"ES2M_SHOP_QUANTITY_RUNTIME_READY files={len(OVERLAYS)} changed={changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
