// Claim Input／認領輸入：Runtime Secret 至少需要 32 個 UTF-8 位元組。
// 此模組只回傳長度與送往 Telnet 的 HEX-V1 傳輸值；不記錄、不顯示、不保存秘密。
export const MINIMUM_OWNER_CLAIM_BYTES = 32;

const encoder = new TextEncoder();

export function prepareOwnerClaim(value) {
  const bytes = encoder.encode(value);
  return {
    byteLength: bytes.length,
    acceptable: bytes.length >= MINIMUM_OWNER_CLAIM_BYTES,
    transport: "es2claim1:" + Array.from(bytes, byte => byte.toString(16).padStart(2, "0")).join("")
  };
}
