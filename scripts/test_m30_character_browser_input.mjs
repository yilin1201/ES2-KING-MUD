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

// 路線 B：本批只驗證 Original 提示；ES2M 數字選單留待獨立 UI 協定批次。\nconst confirm = "您確定要創造這個角色嗎? ";
assert.equal(characterMenuFor(confirm).type, "confirm");
assert.deepEqual(prepareCharacterChoice(confirm, "是"), { bytes: "Y", followup: null });
assert.deepEqual(prepareCharacterChoice(confirm, "no"), { bytes: "N", followup: null });
assert.equal(prepareCharacterChoice("您的顯示名稱: ", "human"), null);

console.log("M30 CHARACTER BROWSER INPUT PASS（測試通過）：Race 使用整行文字；Gender、Confirm 保留 Original 單鍵序列。");
