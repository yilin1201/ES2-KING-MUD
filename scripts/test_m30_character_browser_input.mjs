import assert from "node:assert/strict";
import { characterMenuFor, prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const race = "選擇你的角色所屬的種族：\n  1. Human（人類）\n  2. Avatar（克隆人）\n請輸入編號 1 或 2: ";
assert.equal(characterMenuFor(race).type, "race");
assert.equal(characterMenuFor("請輸入編號 1 或 2: ").type, "race");
// Race Line Input／種族整行輸入：Public 與 E2E 使用同一條文字輸入路徑。
assert.deepEqual(prepareCharacterChoice(race, "1"), { bytes: "ES2RACE:1", followup: null });
assert.deepEqual(prepareCharacterChoice(race, "2"), { bytes: "ES2RACE:2", followup: null });
assert.deepEqual(prepareCharacterChoice(race, "human"), { bytes: "ES2RACE:1", followup: null });
assert.deepEqual(prepareCharacterChoice(race, "克隆人"), { bytes: "ES2RACE:2", followup: null });

const gender = "您要扮演的哪種性別(外觀)的角色? ";
assert.equal(characterMenuFor(gender).type, "gender");
assert.deepEqual(prepareCharacterChoice(gender, "女性"), { bytes: "F", followup: null });
assert.deepEqual(prepareCharacterChoice(gender, "male"), { bytes: "M", followup: null });
assert.deepEqual(prepareCharacterChoice(gender, "unknown"), { bytes: "N", followup: null });

const es2mNumberedGender = "您要扮演的哪種性別(外觀)的角色?\\n1. 女性\\n2. 男性\\n3. 無法判斷\\n請輸入選項數字:";
assert.equal(characterMenuFor(es2mNumberedGender).type, "gender");
assert.deepEqual(prepareCharacterChoice(es2mNumberedGender, "female"), { bytes: "1\\r\\n", followup: null });
assert.deepEqual(prepareCharacterChoice(es2mNumberedGender, "male"), { bytes: "2\\r\\n", followup: null });
assert.deepEqual(prepareCharacterChoice(es2mNumberedGender, "unknown"), { bytes: "3\\r\\n", followup: null });

// ES2M yes/no suffix must not break the Original confirmation prompt parser.
const es2mConfirm = "使用 7probe 這個代號將會創造一個新的人物﹐您確定嗎? (Yes / No)";
assert.equal(characterMenuFor(es2mConfirm).type, "confirm");
assert.deepEqual(prepareCharacterChoice(es2mConfirm, "yes"), { bytes: "Y", followup: null });
assert.deepEqual(prepareCharacterChoice(es2mConfirm, "no"), { bytes: "N", followup: null });

const confirm = "您確定要創造這個角色嗎? ";
assert.equal(characterMenuFor(confirm).type, "confirm");
assert.deepEqual(prepareCharacterChoice(confirm, "是"), { bytes: "Y", followup: null });
assert.deepEqual(prepareCharacterChoice(confirm, "no"), { bytes: "N", followup: null });
assert.equal(prepareCharacterChoice("您的顯示名稱: ", "human"), null);

console.log("M30 CHARACTER BROWSER INPUT PASS（測試通過）：Race 使用整行文字；Gender、Confirm 保留 Original 單鍵序列。");
