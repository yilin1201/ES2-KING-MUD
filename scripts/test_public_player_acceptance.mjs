import { spawn } from "node:child_process";

const base = new URL(process.argv[2] || "");
const expected = process.argv[3] || process.env.ES2_EXPECT_BUILD_COMMIT || "";
if (base.protocol !== "https:" || ["127.0.0.1", "localhost"].includes(base.hostname)) {
  throw new Error("PUBLIC acceptance 必須使用外部 https:// URL，localhost 不得升級為 PUBLIC。");
}
if (!expected || !/^[0-9a-f]{40}$/i.test(expected)) {
  throw new Error("PUBLIC acceptance 必須指定完整 40-char expected build commit。");
}

function run(file, args, env = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [file, ...args], {
      stdio: ["ignore", "pipe", "pipe"],
      env: { ...process.env, ...env }
    });
    let out = "", err = "";
    child.stdout.on("data", d => { out += d; process.stdout.write(d); });
    child.stderr.on("data", d => { err += d; process.stderr.write(d); });
    child.on("exit", code => code === 0 ? resolve(out) : reject(new Error(`${file} failed (${code})\n${out}\n${err}`)));
  });
}

const deploy = await run(
  new URL("./test_m30_deployment_smoke.mjs", import.meta.url).pathname,
  [base.href],
  { ES2_EXPECT_BUILD_COMMIT: expected }
);
if (!deploy.includes("M30 DEPLOYMENT SMOKE PASS")) throw new Error("缺少 deployment smoke marker");

const player = await run(
  new URL("./test_public_player_session_smoke.mjs", import.meta.url).pathname,
  [base.href]
);
if (!player.includes("PUBLIC_PLAYER_SESSION_PASS:external-wss-new-player-confirmation:no-account-created")) {
  throw new Error("普通玩家 session 未取得真正 external WSS marker");
}

console.log(`PUBLIC_PLAYER_SMOKE_PASS:build=${expected}:https+wss+ordinary-player-confirmation:no-account-created`);
