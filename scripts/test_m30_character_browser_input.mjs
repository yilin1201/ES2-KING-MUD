import assert from "node:assert/strict";
import { characterMenuFor, prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const race = "選擇你的角色所屬的種族：";
assert.equal(characterMenuFor(race).type, "race");
assert.equal(characterMenuFor("選擇你的角色所屬的種族 (human/avatar): ").type, "race");
// Race Line Input／種族整行輸入：Public 與 E2E 使用同一條文字輸入路徑。
assert.deepEqual(prepareCharacterChoice(race, "human"), { bytes: "human\r\n", followup: null });
assert.deepEqual(prepareCharacterChoice(race, "avatar"), { bytes: "avatar\r\n", followup: null });

const gender = "您要扮演的哪種性別(外觀)的角色? ";
assert.equal(characterMenuFor(gender).type, "gender");
assert.deepEqual(prepareCharacterChoice(gender, "女性"), { bytes: "F", followup: null });
assert.deepEqual(prepareCharacterChoice(gender, "male"), { bytes: "M", followup: null });
assert.deepEqual(prepareCharacterChoice(gender, "unknown"), { bytes: "N", followup: null });

const confirm = "您確定要創造這個角色嗎? ";
assert.equal(characterMenuFor(confirm).type, "confirm");
assert.deepEqual(prepareCharacterChoice(confirm, "是"), { bytes: "Y", followup: null });
assert.deepEqual(prepareCharacterChoice(confirm, "no"), { bytes: "N", followup: null });
assert.equal(prepareCharacterChoice("您的顯示名稱: ", "human"), null);

console.log("M30 CHARACTER BROWSER INPUT PASS（測試通過）：Race 使用整行文字；Gender、Confirm 保留 Original 單鍵序列。");
