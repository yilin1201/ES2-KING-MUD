// Character Creation Compatibility／角色建立相容：Race 由 Bridge 轉整行；Gender／Confirm 使用 input_to，需 CRLF 結束。
// 不變更 Original 種族資料與後續創角邏輯；只避開 Public iPhone 對 Race 單鍵輸入的不穩定。
export const RACE_PROMPT = /(?:您的選擇\(用.*<種族名>.*可查閱說明\)|請輸入選項數字|請輸入編號 1-12 或種族 ID|請輸入編號 1 或 2)[：﹕:]?[\s\S]*$/;
export const GENDER_PROMPT = /您要扮演的哪種性別(?:\(外觀\))?的角色[?？]?[\s\S]*$/;
export const CONFIRM_PROMPT = /(?:使用 .+ 這個代號將會創造一個新的人物﹐您確定嗎|您確定要創造這個角色嗎|您要重新創造這個角色嗎|您要將另一個連線中的相同人物趕出去﹐取而代之嗎)[?？]?[\s\S]*$/;

const menus = {
  race: [
    { value: "1", label: "1. Human（人類）" },
    { value: "2", label: "2. 黑齒" },
    { value: "3", label: "3. 厭火" },
    { value: "4", label: "4. 焦僥" },
    { value: "5", label: "5. 無腸" },
    { value: "6", label: "6. 釘靈" },
    { value: "7", label: "7. 刑天" },
    { value: "8", label: "8. 雨師妾" },
    { value: "9", label: "9. 巫首" },
    { value: "10", label: "10. 夜叉" },
    { value: "11", label: "11. 阿修羅" }
  ],
  gender: [
    { value: "female", label: "女性" },
    { value: "male", label: "男性" },
    { value: "unknown", label: "無法判斷" }
  ],
  confirm: [
    { value: "yes", label: "是" },
    { value: "no", label: "否" }
  ]
};

export function characterMenuFor(outputTail) {
  // 依輸出中最後出現的提示判斷目前選單，避免舊種族提示蓋過新性別／確認提示。
  const lastIndex = markers => Math.max(-1, ...markers.map(marker => outputTail.lastIndexOf(marker)));
  const latest = [
    { type: "race", index: lastIndex(["您的選擇(用", "請輸入選項數字", "請輸入編號 1-12 或種族 ID", "請輸入編號 1 或 2"]) },
    { type: "gender", index: outputTail.lastIndexOf("您要扮演的哪種性別") },
    { type: "confirm", index: lastIndex(["使用 ", "您確定要創造這個角色嗎", "您要重新創造這個角色嗎", "您要將另一個連線中的相同人物趕出去﹐取而代之嗎"]) }
  ].sort((a, b) => b.index - a.index)[0];
  if (!latest || latest.index < 0) return null;
  if (latest.type === "race" && RACE_PROMPT.test(outputTail)) return { type: "race", options: menus.race };
  if (latest.type === "gender" && GENDER_PROMPT.test(outputTail)) return { type: "gender", options: menus.gender };
  if (latest.type === "confirm" && CONFIRM_PROMPT.test(outputTail)) return { type: "confirm", options: menus.confirm };
  return null;
}

export function prepareCharacterChoice(outputTail, rawValue) {
  const menu = characterMenuFor(outputTail);
  if (!menu) return null;
  const value = rawValue.trim().toLowerCase();

  if (menu.type === "race") {
    // Race Line Input／種族整行輸入：Public iPhone 不再依賴 get_char 的 CR 或方向鍵。
    if (["1", "human", "人類"].includes(value)) return { bytes: "ES2RACE:1", followup: null };
    const extra = { "2":"2", "blackteeth":"2", "黑齒":"2", "3":"3", "yenhold":"3", "厭火":"3", "4":"4", "jiaojao":"4", "焦僥":"4", "5":"5", "woochan":"5", "無腸":"5", "6":"6", "dingling":"6", "釘靈":"6", "7":"7", "headless":"7", "刑天":"7", "8":"8", "rainner":"8", "雨師妾":"8", "9":"9", "malik":"9", "巫首":"9", "10":"10", "yaksa":"10", "夜叉":"10", "11":"11", "ashura":"11", "阿修羅":"11" };
    if (extra[value]) return { bytes: `ES2RACE:${extra[value]}`, followup: null };
  }
  if (menu.type === "gender") {
    if (["female", "f", "女性", "女"].includes(value)) return { bytes: "F\r\n", followup: null };
    if (["male", "m", "男性", "男"].includes(value)) return { bytes: "M\r\n", followup: null };
    if (["unknown", "n", "無法判斷", "未知"].includes(value)) return { bytes: "N\r\n", followup: null };
  }
  if (menu.type === "confirm") {
    if (["yes", "y", "是"].includes(value)) return { bytes: "Y\r\n", followup: null };
    if (["no", "n", "否"].includes(value)) return { bytes: "N\r\n", followup: null };
  }
  return null;
}
