// Character Creation Compatibility／角色建立相容：把網頁文字或按鈕轉成 Original get_char 單鍵。
// 不變更 Original 種族、性別或確認邏輯；只避免表單 CRLF 與多餘文字污染下一個輸入狀態。
export const RACE_PROMPT = /選擇你的角色所屬的種族[：:]?\s*$/;
export const GENDER_PROMPT = /您要扮演的哪種性別\(外觀\)的角色[?？]?\s*$/;
export const CONFIRM_PROMPT = /(?:使用 .+ 這個代號將會創造一個新的人物﹐您確定嗎|您確定要創造這個角色嗎|您要重新創造這個角色嗎|您要將另一個連線中的相同人物趕出去﹐取而代之嗎)[?？]?\s*$/;

const menus = {
  race: [
    { value: "human", label: "human 人類" },
    { value: "avatar", label: "avatar" }
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
  if (RACE_PROMPT.test(outputTail)) return { type: "race", options: menus.race };
  if (GENDER_PROMPT.test(outputTail)) return { type: "gender", options: menus.gender };
  if (CONFIRM_PROMPT.test(outputTail)) return { type: "confirm", options: menus.confirm };
  return null;
}

export function prepareCharacterChoice(outputTail, rawValue) {
  const menu = characterMenuFor(outputTail);
  if (!menu) return null;
  const value = rawValue.trim().toLowerCase();

  if (menu.type === "race") {
    if (value === "human" || value === "人類") return { bytes: " ", followup: null };
    if (value === "avatar") return { bytes: "\x1b[B", followup: " " };
  }
  if (menu.type === "gender") {
    if (["female", "f", "女性", "女"].includes(value)) return { bytes: "F", followup: null };
    if (["male", "m", "男性", "男"].includes(value)) return { bytes: "M", followup: null };
    if (["unknown", "n", "無法判斷", "未知"].includes(value)) return { bytes: "N", followup: null };
  }
  if (menu.type === "confirm") {
    if (["yes", "y", "是"].includes(value)) return { bytes: "Y", followup: null };
    if (["no", "n", "否"].includes(value)) return { bytes: "N", followup: null };
  }
  return null;
}
