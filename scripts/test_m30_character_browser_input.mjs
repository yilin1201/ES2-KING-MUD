import assert from "node:assert/strict";
import { characterMenuFor, prepareCharacterChoice } from "../webtelnet/public/character-input.mjs";

const race = "選擇你的角色所屬的種族：";
assert.equal(characterMenuFor(race).type, "race");
// Compatibility helper 仍保留 CR；Public form submit 對 human 另以 Original cursor_translate 明確支援的單鍵空白確認。\nassert.deepEqual(prepareCharacterChoice(race, "human"), { bytes: "\r", followup: null });
assert.deepEqual(prepareCharacterChoice(race, "avatar"), { bytes: "\x1b[B", followup: "\r" });

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

console.log("M30 CHARACTER BROWSER INPUT PASS（測試通過）：Race、Gender、Confirm 均只產生 Original get_char 所需單鍵序列。");

// Public form path regression marker：index.html 必須保留 human 單鍵空白 fallback；此處由部署前 static assertion 檢查。\n