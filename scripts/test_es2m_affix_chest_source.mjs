#!/usr/bin/env node
// ES2M 儲物箱與詞綴來源相容性閘門。僅證明來源及儲物箱呼叫路徑；不等於存檔 Runtime PASS。
import assert from "node:assert/strict";
import fs from "node:fs";
import { createHash } from "node:crypto";
const root = "source/es2m_updates/20261004/mudlib/";
const chest = fs.readFileSync(root + "custom/home/obj/storage_chest.c");
const blob = createHash("sha1").update(Buffer.from("blob " + chest.length + String.fromCharCode(0))).update(chest).digest("hex");
assert.equal(blob, "2a6fcab2584841f38571d7b6462b025a7c43ff7b", "更新來源必須與 ES2M 鎖定 SHA 相同");
const latest = chest.toString("utf8");
const old = fs.readFileSync("es2m_snapshot/mudlib/custom/home/obj/storage_chest.c", "utf8");
const daemon = fs.readFileSync(root + "adm/daemons/enhanced.c", "utf8");
assert.ok(!old.includes('data["affix"]'), "KING 舊快照結構已變更，必須重新評估");
assert.ok(latest.includes('data["affix"] = mapp(ob->query("affix"))'), "必須記錄普通及帶詞綴武器");
assert.ok(latest.includes('if (mapp(data["affix"]))'), "必須有帶詞綴還原條件");
assert.ok(latest.includes('ENHANCE_D->apply_affix(ob, data["affix"])'), "取出時必須套用原有詞綴");
assert.ok(daemon.includes('void apply_affix(object ob, mapping affix)'), "還原依賴的 daemon 必須同批保存");
assert.ok(daemon.includes('affix_base_apply/'), "必須保留原武器能力的合併入口");

const mustAppearInOrder = (source, snippets, label) => {
  let start = 0;
  for (const part of snippets) {
    const index = source.indexOf(part, start);
    assert.notEqual(index, -1, label + ": missing/out-of-order " + part);
    start = index + part.length;
  }
};
// 普通武器的空 mapping 同樣必須儲存：取出時覆蓋 new() 產生的隨機詞綴。
assert.ok(latest.includes('data["affix"] = mapp(ob->query("affix")) ? copy(ob->query("affix")) : ([])'));
mustAppearInOrder(latest, [
  'items += ({ pack_object(ob) });',
  'me->save();',
  'destruct(ob);'
], "存放必須先保存角色資料才銷毀原物件");
mustAppearInOrder(latest, [
  'ob = new(data["file"]);',
  'if (mapp(data["affix"]))',
  'ENHANCE_D->apply_affix(ob, data["affix"]);',
  'if (!ob->move(me))',
  'items[n - 1] = 0;'
], "取出時先套用既存詞綴且成功移動後才移除儲物格");
assert.ok(latest.includes('if (!ob->move(me)) {\n        destruct(ob);'), "移動失敗不可刪除儲物格");
assert.ok(daemon.includes('affix_base_name') && daemon.includes('affix_base_apply/'),
  "反覆套用已存詞綴必須從武器原始名稱及屬性重算");
assert.ok(daemon.includes('if( r >= 60 )') && daemon.includes('if( r >= 90 )'),
  "來源標示的 60/30/10 機率分界必須存在");

console.log("ES2M_AFFIX_CHEST_SOURCE_STATIC_PASS (source gate only; Runtime/save-relogin UNKNOWN)");
