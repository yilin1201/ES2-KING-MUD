#!/usr/bin/env python3
"""將 ES2M 93e796d9 的容器修復套用到隔離 Runtime。"""

from __future__ import annotations

import argparse
import hashlib
import shutil
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source/es2m_updates/20261006_93e796d9/source/upstream/mudlib"


@dataclass(frozen=True)
class Overlay:
    """只允許已知基準或本次來源 SHA，避免覆蓋其他工作階段。"""

    path: str
    source_sha256: str
    baseline_sha256: str


OVERLAYS = (
    Overlay("std/item/container.c",
            "9f8120b89a0f971875f9c915906478ed39356216c8feb87a39da99665ed0ba1b",
            "1f17ce138d484243ede66d404d494e4055b5482a42209c45952fedcb715ea618"),
    Overlay("d/lee/obj/waterskin.c",
            "07e9fc505ee6543ece13053859d3ddcdb4d551699838bbd3066df39e6626a3e8",
            "07440b5e4f6b01c26764f5a8b0c428a75e8d275acb52a7e132529f6883ff1148"),
)


def digest(path: Path) -> str:
    """計算 SHA-256 作為低流量增量與衝突閘門。"""

    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(runtime_mudlib: Path) -> None:
    """先驗證全部來源及目標，再開始任何寫入。"""

    for item in OVERLAYS:
        source = SOURCE / item.path
        target = runtime_mudlib / item.path
        if not source.is_file() or digest(source) != item.source_sha256:
            raise RuntimeError(f"ES2M 容器來源缺失或 SHA 不符：{item.path}")
        if not target.is_file():
            raise RuntimeError(f"Runtime 缺少容器相依檔：{item.path}")
        actual = digest(target)
        if actual not in (item.baseline_sha256, item.source_sha256):
            raise RuntimeError(f"Runtime 容器檔衝突，停止覆蓋：{item.path} {actual}")


def apply(runtime_mudlib: Path) -> int:
    """套用兩個已確認檔案，並只清除相同路徑的 LPC 快取。"""

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
    parser = argparse.ArgumentParser(description="套用 ES2M 容器與牛皮水袋修復")
    parser.add_argument("--runtime", type=Path, required=True,
                        help="隔離 Runtime 的 mudlib 目錄")
    args = parser.parse_args()
    changed = apply(args.runtime.resolve())
    print(f"ES2M_CONTAINER_RUNTIME_READY files={len(OVERLAYS)} changed={changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
