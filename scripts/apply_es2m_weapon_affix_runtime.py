#!/usr/bin/env python3
"""將已保存的 ES2M 武器詞綴來源套用到隔離 Runtime；不改寫證據快照。"""

from __future__ import annotations

import argparse
import hashlib
import shutil
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PINNED = ROOT / "source/es2m_updates/20261004/mudlib"
CURRENT = ROOT / "source/es2m_updates/20261004_087c1736/source/upstream/mudlib"


@dataclass(frozen=True)
class Overlay:
    """單一 Runtime 覆蓋檔：來源雜湊固定，目標只接受已知基準或已套用版本。"""

    path: str
    source: Path
    source_sha256: str
    allowed_target_sha256: tuple[str, ...]


def overlay(path: str, source_root: Path, source_sha: str, baseline_sha: str) -> Overlay:
    return Overlay(path, source_root / path, source_sha, (baseline_sha, source_sha))


OVERLAYS = (
    overlay("adm/daemons/enhanced.c", CURRENT,
            "5a6f428670cb9d930c46fc75f5806e38aaa72cd66bffbb5825714b9f9b7a60d8",
            "d9a3326aec4a6cbcad28e822929b8623807eb78520278b8a261d40c2a6622db5"),
    overlay("custom/home/obj/storage_chest.c", CURRENT,
            "65fdc95d2cdc3a366c083a6c07a3e3e5a468ecb2bb96d1d858825ba678fb1bd9",
            "847378d7245df29bffca72870f43b95561a400810563dda0bc6346888e4726ac"),
    overlay("custom/weapon/staff/long_staff.c", CURRENT,
            "1edf61b394e9a4c8ce6724c040ca01ade338b084145408417dfe09a6ca5ba909",
            "246d64f0ba1cb48834f25841baff3425a41f41023c1267c7ab436706aa5c7993"),
    overlay("custom/weapon/staff/zenstaff.c", CURRENT,
            "f7679ca75ac1dc25ca665894a708395944f6e0c50a656ddb6dfa224db9830373",
            "98ad6c87bee539bd9b1375751b13612f528a8ab9d15e2659e9045a42fc5b7c4d"),
    overlay("custom/weapon/whip/bamboo_fishing_rod.c", CURRENT,
            "f5f40385682b0b4af5dcb75cf446036b4e4dd60a91323b9c24a49bf864966a0a",
            "1db4228a842b890f03620b90e8d54da13eec680092e5fb763b9de9210ee7c691"),
    overlay("d/lee/obj/brow_staff.c", CURRENT,
            "b5564038ded60e537d1dc47398a7d6578e50b3836f77ac63ada52bf699aae01e",
            "0f9002ed3f14681468fa6bf7a989dac34275812d57d0fe8aad2fb9ba502462da"),
    overlay("obj/area/obj/dagger.c", CURRENT,
            "b49767ac17e4d35795d46900c65a0b2abf87ec32ca4fb1e2d74552631dbea776",
            "bd5831f68f68da80e9588121d54b8268ed811d43852381f02cc953b5d9e5db02"),
    overlay("obj/area/obj/rod.c", CURRENT,
            "8e8a30a1441d4cdd89836406ec75efc74ce6b6e80bf26989213f6cc67b12dba2",
            "e66a13befa151261bec1799a9d731f33a2dc61a2a7f06363e1952c9b6b059927"),
    overlay("obj/area/obj/bastardsword.c", PINNED,
            "8d327415f9a68ab675a0c7cb8a5599da33dd8f113561351fb8202096ad11f179",
            "09f94cb8024152842b8204ce814cceccf20f6215153e41245e3bf770722ef543"),
    overlay("obj/area/obj/blade.c", PINNED,
            "038668e4b2527a717677275bcf9e256e5d4706f7c5228bb4c58f3b34628c8a04",
            "16c568f811cd338bb32e615b178a2d3aa9c3b84de651c76a8fb849292ffaa6c8"),
    overlay("obj/area/obj/broadaxe.c", PINNED,
            "b555237de85e1db832e31178f0c008becb21aa75e277a862b5ed16898ba56943",
            "a132663641adffec2d97dba0e889cf851bc1e57d2849a2733bc07bebbb93658b"),
    overlay("obj/area/obj/broadsword.c", PINNED,
            "3f90a46bc47d348d25d10b3773d9044c1dcd10f80f91bfa3652bc6f850c5b5a4",
            "8ec61beab0612d318d3bf4e71dd74e26df500fcdcb4af1118bc1ea0b699ad2d2"),
    overlay("obj/area/obj/curved_blade.c", PINNED,
            "67bb43c9f5cbf3765c3ca3d8cf910b2ce537dbbabd8747c73dd5a9ba8d639831",
            "1c5f17eea181c60f388e856424582bb07a9aff3d3c4c30d33535559f23963bc6"),
    overlay("obj/area/obj/glaive.c", PINNED,
            "40a2d4d8123c577447589d5c884d4b0f1b847fd2ed3f1082ebad35da26aac628",
            "d352792f0663032d4441e47a07fdf5595c8fceac3a42379825a73d95fd808752"),
    overlay("obj/area/obj/greatsword.c", PINNED,
            "943cfc4502b99fa419dcfc348555afc8b7dc14a5c4929f94c6ae4a8d4d6872dc",
            "539f9b00227ce34f1ce3983ee95ddfeccd5e4f3453c5e5445109ca479bf5971b"),
    overlay("obj/area/obj/longsword.c", PINNED,
            "4a2bdcaa67f972969463e2a3d332a5a2e732bacc7e830c935ba2839ca1b7f656",
            "22e1a5f3e4a6684fcd31342b10e841a02ee04790dd2810e3fafbb2c95fb7fbb9"),
    overlay("obj/area/obj/pike.c", PINNED,
            "0559ed89f3e24e22d2acafa2a2f76f37d3b54306c00c274b88782048f390f16c",
            "45745bf42f0dfdf6565f92df5955f48d20fa6e55ff2c031fdae65d8c8c34dd04"),
    overlay("obj/area/obj/shortsword.c", PINNED,
            "0bb87fca9868b2702ef94ecc4e17ba4db53fb238ca863d4d73c408c9f9f7e74d",
            "30bbf994281971f81d3db52f39799218374556dad9a4d1bcc1ff9d9948011e0d"),
    overlay("obj/area/obj/weirblade.c", PINNED,
            "0ee68db498410bdcc69cfadd0b4669f18a93198245fdf8d4f34527a554351d48",
            "8fea0677fb96f4cc66a1459578aff17f30d8865760ced48bb8fb250aec18e22e"),
)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(runtime_mudlib: Path, overlays: tuple[Overlay, ...] = OVERLAYS) -> None:
    """先完成全部檢查，任何差異都在寫入前停止，避免半套 Runtime。"""

    for item in overlays:
        if not item.source.is_file():
            raise RuntimeError(f"缺少已保存來源：{item.source}")
        actual_source = digest(item.source)
        if actual_source != item.source_sha256:
            raise RuntimeError(f"來源 SHA 不符：{item.path} {actual_source}")
        target = runtime_mudlib / item.path
        if not target.is_file():
            raise RuntimeError(f"Runtime 缺少相依檔：{item.path}")
        actual_target = digest(target)
        if actual_target not in item.allowed_target_sha256:
            raise RuntimeError(f"Runtime 衝突，停止覆蓋：{item.path} {actual_target}")


def apply(runtime_mudlib: Path, overlays: tuple[Overlay, ...] = OVERLAYS) -> int:
    validate(runtime_mudlib, overlays)
    changed = 0
    for item in overlays:
        target = runtime_mudlib / item.path
        if digest(target) != item.source_sha256:
            shutil.copy2(item.source, target)
            changed += 1
        # Neolith 的舊編譯快取若存在會遮蔽新 LPC；只刪除本批同路徑快取。
        cache = runtime_mudlib / "bin" / Path(item.path).with_suffix(".b")
        cache.unlink(missing_ok=True)
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description="套用 ES2M 武器詞綴到隔離 Runtime")
    parser.add_argument("--runtime", type=Path, required=True,
                        help="隔離 Runtime 的 mudlib 目錄")
    args = parser.parse_args()
    changed = apply(args.runtime.resolve())
    print(f"ES2M_WEAPON_AFFIX_RUNTIME_READY files={len(OVERLAYS)} changed={changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
