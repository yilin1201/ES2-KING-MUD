#!/usr/bin/env bash
set -euo pipefail
F="${1:-docs/evidence/supplemental/wolfer168_es2_webmud_registry.json}"
node - "$F" <<'NODE'
const fs=require("fs"); const j=JSON.parse(fs.readFileSync(process.argv[2],"utf8"));
if(j.upstream.commit!=="cc45c06af4852380e5148dad3c9d53ff06854f2c") throw Error("upstream mismatch");
if(j.upstream.matches_es2_king_pinned_target!==true) throw Error("not pinned");
if(j.policy.original_lpc_required_for_runtime_canon!==true) throw Error("unsafe promotion");
if(j.observed.snow_room_area_count!==43) throw Error("snow manifest mismatch");
console.log("WOLFER_ES2_WEBMUD_SUPPLEMENT_PASS:pinned-upstream:derived-not-original:snow43");
NODE
