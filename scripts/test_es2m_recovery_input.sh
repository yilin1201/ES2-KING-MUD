#!/usr/bin/env bash
set -euo pipefail
node - <<'NODE'
const fs=require("fs"); const j=JSON.parse(fs.readFileSync("docs/evidence/es2m/ES2M_RACE_CLASS_RECOVERY.json","utf8"));
if(j.classification!=="ES2M_REFERENCE") throw Error("classification");
if(j.races.length!==12) throw Error("race count");
if(j.classes.length!==8) throw Error("class count");
// Avatar／人類族：依使用者明確指令及 ES2M 證據，採新版顯示名稱。\nif(j.runtime_policy.preserve_es2_king_avatar_display!==false) throw Error("avatar policy");\nif(j.runtime_policy.avatar_display!=="人類族") throw Error("avatar display");\nif(j.runtime_policy.avatar_display_authority!=="USER_DIRECTIVE_PLUS_ES2M") throw Error("avatar evidence");\nif(j.runtime_policy.do_not_claim_pinned_original!==true) throw Error("original provenance");
console.log("ES2M_RECOVERY_INPUT_PASS:races12:classes8:original-first");
NODE
