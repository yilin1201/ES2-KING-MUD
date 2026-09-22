FROM ubuntu:24.04 AS builder

ARG ORIGINAL_ES2_COMMIT=cc45c06af4852380e5148dad3c9d53ff06854f2c

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bison build-essential ca-certificates cmake git libboost-dev \
       libc-ares-dev libcurl4-openssl-dev libjsoncpp-dev libssl-dev \
       ninja-build nodejs npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/repository
COPY . .

# Original ES2（原版天朝帝國）固定到已考證 commit；Expansion 只套入獨立 Runtime。
# 分段建置讓 Render Build Log 能直接指出失敗階段，避免單一長鏈只回報 exit code 1。
RUN echo "[M30 BUILD 1/5] Clone Original ES2" \
    && git clone --recurse-submodules https://github.com/taedlar/es2_mudlib.git /opt/es2-king/runtime
RUN echo "[M30 BUILD 2/5] Checkout verified Original commit" \
    && git -C /opt/es2-king/runtime checkout "$ORIGINAL_ES2_COMMIT"
RUN echo "[M30 BUILD 3/5] Update Original submodules" \
    && git -C /opt/es2-king/runtime submodule update --init --recursive
RUN echo "[M30 BUILD 4/5] Apply ES2-KING Expansion overlay" \
    && scripts/apply_es2_king_expansion.sh /opt/es2-king/runtime
RUN echo "[M30 BUILD 5/5] Assert final playable Runtime" \
    && bash scripts/assert_m30_final_runtime.sh /opt/es2-king/runtime

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
    && apt-get install -y --no-install-recommends ca-certificates libcurl4 libstdc++6 nodejs \
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
