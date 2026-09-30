#!/usr/bin/env bash
set -euo pipefail
node - <<'NODE'
const fs=require("fs"); const j=JSON.parse(fs.readFileSync("docs/evidence/es2m/ES2M_RACE_CLASS_RECOVERY.json","utf8"));
if(j.classification!=="ES2M_REFERENCE") throw Error("classification");
if(j.races.length!==12) throw Error("race count");
if(j.classes.length!==8) throw Error("class count");
if(!j.runtime_policy.preserve_es2_king_avatar_display) throw Error("avatar canon");
console.log("ES2M_RECOVERY_INPUT_PASS:races12:classes8:original-first");
NODE
