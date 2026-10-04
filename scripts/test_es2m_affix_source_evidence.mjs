#!/usr/bin/env node
// ES2M 更新來源獨立證據閘門；僅驗證 SHA 與呼叫位置，不宣稱 Runtime PASS。
import assert from "node:assert/strict";
import fs from "node:fs";
import { createHash } from "node:crypto";
const root = "source/es2m_updates/20261004/mudlib/";
const expected = new Map([
  [
    "adm/daemons/enhanced.c",
    "cdbecfcc2464046efb1a813148aae21009713d3c"
  ],
  [
    "obj/area/obj/bastardsword.c",
    "d12cba9d7ff76ddd1d89f385dda83f4fbe58b847"
  ],
  [
    "obj/area/obj/blade.c",
    "b0f93def2ccbd8b6e1b0d1b262bd79c1ca0201ee"
  ],
  [
    "obj/area/obj/broadaxe.c",
    "427dd9bd85a30eb08448b821e6f9d0ccd658adaa"
  ],
  [
    "obj/area/obj/broadsword.c",
    "96ec86a37fe721bb2becb31b94c642e82823bf40"
  ],
  [
    "obj/area/obj/curved_blade.c",
    "5586650b19794bd859f10af0bf7d4dc472d0bbc2"
  ],
  [
    "obj/area/obj/glaive.c",
    "9a0c134489fd32c3049e4c1a6844f3d940852559"
  ],
  [
    "obj/area/obj/greatsword.c",
    "a6b92055d60d7ce0a7e123e4776b120eafe710c9"
  ],
  [
    "obj/area/obj/longsword.c",
    "2b823f8fb99ff1606e497fbeb4f74345f6a3ce13"
  ],
  [
    "obj/area/obj/pike.c",
    "cf8bb5ec73e8b8af5b4caa84dcf384e2dbb039bd"
  ],
  [
    "obj/area/obj/rod.c",
    "cf713c245594f46a921ebc7c962e8abaffd792ae"
  ],
  [
    "obj/area/obj/shortsword.c",
    "f0d2c4a95b7dd75a296226c04d0b519b3ecbb72e"
  ],
  [
    "obj/area/obj/weirblade.c",
    "2fea001993b1e95785b688e03474ff2cc93ffd99"
  ]
]);
for (const [path, sha] of expected) {
  const bytes = fs.readFileSync(root + path);
  const header = Buffer.from("blob " + bytes.length + String.fromCharCode(0));
  const actual = createHash("sha1").update(header).update(bytes).digest("hex");
  assert.equal(actual, sha, "ES2M source blob changed: " + path);
  const source = bytes.toString("utf8");
  if (path.endsWith("enhanced.c")) {
    assert.ok(source.includes("void apply_affix(object ob, mapping affix)"));
    assert.ok(source.includes("void roll_affix(object ob)"));
    assert.ok(source.includes("affix_base_apply/"));
  } else {
    assert.ok(source.includes("set_name("), "missing weapon name: " + path);
    assert.ok(source.includes("ENHANCE_D->roll_affix(this_object())"), "missing affix call: " + path);
    assert.ok(source.includes("clonep()"), "missing clone-only gate: " + path);
  }
}
const report = fs.readFileSync("docs/migration/ES2M_UPDATE_EVIDENCE_20261004.md", "utf8");
assert.ok(report.includes("taoism-spells.c") && report.includes("UNKNOWN"));
console.log("ES2M_AFFIX_SOURCE_EVIDENCE_STATIC_PASS (pinned blobs, entrypoints only; Runtime UNKNOWN)");
