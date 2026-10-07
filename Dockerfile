FROM ubuntu:24.04 AS builder

ARG ORIGINAL_ES2_COMMIT=cc45c06af4852380e5148dad3c9d53ff06854f2c

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bison build-essential ca-certificates cmake git libboost-dev \
       libc-ares-dev libcurl4-openssl-dev libjsoncpp-dev libssl-dev \
       ninja-build nodejs npm python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/repository
COPY . .

# WebTelnet Browser Static Gate：Render 建置前先解析瀏覽器 module，避免 HTML 可開啟但 JavaScript 未執行而永久停在「連線中」。
RUN node scripts/test_m30_webtelnet_display.mjs \
    && bash scripts/test_webtelnet_mobile_nowrap.sh webtelnet/public/index.html

# Original ES2（原版天朝帝國）固定到已考證 commit；Expansion 只套入獨立 Runtime。
# 分段建置讓 Render Build Log 能直接指出失敗階段，避免單一長鏈只回報 exit code 1。
RUN echo "[M30 BUILD 1/5] Clone Original ES2" \
    && git clone --recurse-submodules https://github.com/taedlar/es2_mudlib.git /opt/es2-king/runtime
RUN echo "[M30 BUILD 2/5] Checkout verified Original commit" \
    && git -C /opt/es2-king/runtime checkout "$ORIGINAL_ES2_COMMIT"
RUN echo "[M30 BUILD 3/5] Update Original submodules" \
    && git -C /opt/es2-king/runtime submodule update --init --recursive
# ES2M 主體基準：套用 KING 前先封存原始 mudlib，供三方差異盤點。
RUN cp -a /opt/es2-king/runtime/mudlib /build/es2m-original-mudlib
RUN echo "[M30 BUILD 4/5] Apply ES2M Race overlay" \
    && bash scripts/apply_race_phase2_runtime.sh /opt/es2-king/runtime

# Fighter 升級鏈來源契約必須在 KING 戰鬥成長擴充前驗證：
# ES2M class/score 已套入，但 combatd.c 此時仍不得含 KING generic hit gain。
RUN python3 scripts/test_es2m_fighter_level_contract.py /opt/es2-king/runtime/mudlib

RUN echo "[M30 BUILD 4/5] Apply ES2-KING Expansion overlay" \
    && bash scripts/apply_es2_king_expansion.sh /opt/es2-king/runtime

# KING 戰鬥成長 Runtime Gate：Expansion 套用後確認實際正傷害會增加 combat score。
# martial art 不由基本木劍命中偽造，另由正式映射武學的既有路徑驗證。
RUN grep -q 'ES2-KING COMBAT DAMAGE SCORE GROWTH' /opt/es2-king/runtime/mudlib/feature/char/combat.c \
    && grep -q 'attacker->gain_score("combat", 1 + random(3))' /opt/es2-king/runtime/mudlib/feature/char/combat.c

# KING 雙劍法契約：冷梅預設，傲劍訣可透過 Original enable 切換。
RUN python3 scripts/test_king_aojian_dual_skill.py
# V4 武學閘門：單次驗證 V0 數值、正式招式、技能路由及生成 Runtime 檔案一致性。
RUN python3 scripts/test_king_martial_damage_v0.py --runtime /opt/es2-king/runtime/mudlib
# 不滅金身 30% 攻擊強度吸收：核對正式生成 Runtime，非實戰傷害 PASS。
RUN python3 scripts/test_king_batian_immortal_30.py /opt/es2-king/runtime/mudlib
# 易筋經傷害修復閘門：檢查實際生成 Runtime，非單純來源檔。
RUN python3 scripts/test_king_yijinjing_damage.py /opt/es2-king/runtime/mudlib
# Validate NPC audit decisions before auditing generated runtime.
RUN cd scripts && python3 -m unittest -v test_audit_es2m_snow_npc_batch
# ES2M Snow NPC source and dependency audit (static evidence, not gameplay PASS).
RUN python3 scripts/audit_es2m_snow_npc_batch.py \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-snow-npc-inventory.json
# 工頭與木箱採 ES2M 來源，僅補入缺檔；先以隔離測試確認不覆蓋 Original。
RUN cd scripts && python3 -m unittest -v test_import_es2m_snow_foreman
RUN python3 scripts/import_es2m_snow_foreman.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --runtime /opt/es2-king/runtime/mudlib

# ES2M 雪亭地圖缺檔補入：只加入出口有來源證據的房間，不覆蓋 Original。
RUN cd scripts && python3 -m unittest -v test_import_es2m_snow_rooms_safe
RUN python3 scripts/import_es2m_snow_rooms_safe.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-snow-rooms-stage.json

# ES2M 雪亭 NPC：缺檔且依賴已滿足時保守導入；同名 Original 保留。
RUN cd scripts && python3 -m unittest -v test_import_es2m_snow_npc_safe
RUN python3 scripts/import_es2m_snow_npc_safe.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-snow-npc-stage.json

# ES2M 雪亭鎮整合檢查：先跑隔離單元測試，再核對真正生成的 Runtime 檔案。
# 不將原始碼隔離區誤當成可玩的遊戲資料。
RUN cd scripts && python3 -m unittest -v test_check_es2m_snow_runtime_baseline
RUN python3 scripts/check_es2m_snow_runtime_baseline.py /opt/es2-king/runtime
# 檔案層完整性：缺失原始檔阻止發布；同名覆蓋另產生清冊，待 Owner 決策。
RUN cd scripts && python3 -m unittest -v test_audit_es2m_full_runtime_overlay
RUN python3 scripts/audit_es2m_full_runtime_overlay.py \
    /build/es2m-original-mudlib /opt/es2-king/runtime/mudlib \
    /build/es2m-full-runtime-inventory.json \
    --snapshot /build/repository/es2m_snapshot/mudlib

# ES2M 裝備安全補檔：隔離測試後只加入獨立且缺少的物件，不覆蓋同名 Original。
RUN cd scripts && python3 -m unittest -v test_import_es2m_equipment_missing
RUN python3 scripts/import_es2m_equipment_missing.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-equipment-stage.json

# ES2M 武器裝備三方清冊：盤點候選、缺檔與同名衝突，不自動覆蓋或誤報可玩。
RUN cd scripts && python3 -m unittest -v test_audit_es2m_equipment_import
RUN python3 scripts/audit_es2m_equipment_import.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --original /build/es2m-original-mudlib \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-equipment-import-inventory.json

# 91 件 ES2M 防具的保存快照維持原始 SHA；只在生成 Runtime 加入背包與穿戴狀態 autoload。
# 先完成三方原始碼稽核再套用 adapter，避免把 KING Runtime 行為誤認成 ES2M 原始證據。
RUN cd scripts && python3 -m unittest -v test_apply_es2m_armor_persistence_runtime
RUN python3 scripts/apply_es2m_armor_persistence_runtime.py \
    --matrix docs/migration/ES2M_IMPORT_MATRIX_20261003.csv \
    --runtime /opt/es2-king/runtime/mudlib

# 振武軍營完整程式導入：補入房間／NPC／道具，僅在 Original 註解舊出口時安全連接。
# 同名衝突或未知外部出口會阻止建置，保留原始檔與衝突清冊。
RUN python3 scripts/import_es2m_zhenwu_safe.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-zhenwu-stage.json
RUN python3 scripts/test_es2m_zhenwu_topology.py /opt/es2-king/runtime/mudlib \
    && python3 scripts/test_es2m_zhenwu_recruitment.py /opt/es2-king/runtime/mudlib

# 振武軍營 ES2M 原始資料閘門：地圖連結、NPC/裝備檔案及徵兵條件缺失即阻止建置。
# 靜態來源驗證不代表遊戲內徵兵 Runtime PASS。
RUN python3 scripts/test_es2m_zhenwu_topology.py es2m_snapshot/mudlib \
    && python3 scripts/test_es2m_zhenwu_recruitment.py es2m_snapshot/mudlib

# ES2M 技能三方 SHA 稽核：將同名 Original／ES2M 衝突明列，絕不直接覆蓋。
RUN cd scripts && python3 -m unittest -v test_audit_es2m_skill_three_way
RUN python3 scripts/audit_es2m_skill_three_way.py \
    --snapshot /build/repository/es2m_snapshot/mudlib \
    --original /build/es2m-original-mudlib \
    --runtime /opt/es2-king/runtime/mudlib \
    --output /build/es2m-skill-three-way.json

# ES2M skill inventory: fail build if any of the 36 recovered daemons is absent from generated Runtime.
RUN python3 scripts/test_es2m_skill_import.py /opt/es2-king/runtime

RUN echo "[M30 BUILD 5/5] Assert final playable Runtime" \
    && bash scripts/assert_m30_final_runtime.sh /opt/es2-king/runtime \
    && bash scripts/test_king_omega_static.sh /opt/es2-king/runtime

# 與既有 Bootstrap 相同：只在生成的 ES2-KING Runtime 關閉歷史 anti-spam，
# 不回寫或污染 Original ES2 保存來源。
RUN bash -euo pipefail -c '\
  while IFS= read -r file; do \
    sed -i "s/^[[:space:]]*#define[[:space:]]\\+ENABLE_ANTISPAM.*/\\/\\/ ES2-KING: ENABLE_ANTISPAM disabled/" "$file"; \
  done < <(grep -RIl "^[[:space:]]*#define[[:space:]]\\+ENABLE_ANTISPAM" \
    /opt/es2-king/runtime/mudlib/include /opt/es2-king/runtime/mudlib/adm 2>/dev/null || true); \
  ! grep -R "^[[:space:]]*#define[[:space:]]\\+ENABLE_ANTISPAM" \
    /opt/es2-king/runtime/mudlib/include /opt/es2-king/runtime/mudlib/adm 2>/dev/null'

RUN cmake -S /opt/es2-king/runtime/neolith -B /build/neolith -G Ninja \
      -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /build/neolith --parallel \
    && install -D /build/neolith/src/neolith /opt/es2-king/bin/neolith

RUN cd webtelnet && npm ci --omit=dev

# Release Candidate Gameplay Gates／候選版本實際玩法閘門：
# 直接使用剛編譯完成的 Driver，在全新隔離 data 上執行 12 種族創角與普通玩家完整旅程。
# 這不是 Static PASS；任一創角、移動、NPC、物品、裝備、戰鬥、轉職、練功、save/quit/relogin 失敗都阻止部署。
RUN ES2_DRIVER_BIN=/opt/es2-king/bin/neolith \
    bash scripts/test_original_player_creation_e2e.sh /opt/es2-king/runtime
RUN ES2_DRIVER_BIN=/opt/es2-king/bin/neolith \
    bash scripts/test_player_open_alpha_e2e.sh /opt/es2-king/runtime

# Image 內保存唯讀初始資料；啟動時才複製至 ES2_SAVE_DIR（持久存檔目錄）。
RUN mv /opt/es2-king/runtime/mudlib/data /opt/es2-king/data-seed \
    && mkdir -p /opt/es2-king/runtime/mudlib/data \
    && mkdir -p /opt/es2-king/runtime/mudlib/log

FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    ES2_RUNTIME_DIR=/opt/es2-king/runtime \
    ES2_DRIVER_BIN=/opt/es2-king/bin/neolith \
    ES2_DATA_SEED_DIR=/opt/es2-king/data-seed \
    ES2_SAVE_DIR=/var/lib/es2-king/data \
    ES2_HOST=127.0.0.1 \
    ES2_PORT=4000 \
    PORT=8080

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libcurl4 libstdc++6 nodejs python3 python3-psycopg2 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 es2king \
    && mkdir -p /var/lib/es2-king

COPY --from=builder /opt/es2-king /opt/es2-king
COPY --from=builder /build/repository/webtelnet /opt/es2-king/webtelnet
COPY --from=builder /build/repository/scripts /opt/es2-king/scripts

# Original Git tree 不保存執行時產生的 mudlib/bin；必須在 chown 前建立，
# 同時再次保證 data／log 掛載點存在，避免 Runtime 初始化順序造成部署失敗。
# data 會在啟動時改成符號連結；只開放 mudlib 父目錄的目錄項目變更權限，
# 不遞迴改寫 Original ES2 保存檔案的擁有者。
RUN mkdir -p \
      /opt/es2-king/runtime/mudlib/bin \
      /opt/es2-king/runtime/mudlib/data \
      /opt/es2-king/runtime/mudlib/log \
    && chown es2king:es2king /opt/es2-king/runtime/mudlib \
    && chown -R es2king:es2king \
      /var/lib/es2-king \
      /opt/es2-king/runtime/mudlib/bin \
      /opt/es2-king/runtime/mudlib/data \
      /opt/es2-king/runtime/mudlib/log

USER es2king
WORKDIR /opt/es2-king

# 只宣告 HTTPS/WSS 反向代理要轉入的 Web port；絕不宣告 Telnet 4000。
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
  CMD node /opt/es2-king/scripts/healthcheck_es2_king.mjs

CMD ["/opt/es2-king/scripts/start_es2_king_web.sh"]
