import assert from "node:assert/strict";
import { MINIMUM_OWNER_CLAIM_BYTES, prepareOwnerClaim } from "../webtelnet/public/claim-input.mjs";

// Safari-equivalent Paste／Safari 等價貼上：input.value 取得完整值後才進行 UTF-8 編碼。
const asciiToken = "A".repeat(32);
const ascii = prepareOwnerClaim(asciiToken);
assert.equal(MINIMUM_OWNER_CLAIM_BYTES, 32);
assert.equal(ascii.byteLength, 32);
assert.equal(ascii.acceptable, true);
assert.equal(ascii.transport.length, "es2claim1:".length + 64);

// UTF-8 以位元組而非 JavaScript 字元數量判斷，避免 Unicode 字元造成長度誤判。
const unicode = prepareOwnerClaim("王".repeat(11));
assert.equal(unicode.byteLength, 33);
assert.equal(unicode.acceptable, true);

// Render 遮蔽顯示常呈現短字串；5-byte 輸入必須留在 Browser，不得送往 Runtime。
const masked = prepareOwnerClaim("*****");
assert.equal(masked.byteLength, 5);
assert.equal(masked.acceptable, false);

console.log("M30 CLAIM BROWSER INPUT PASS（測試通過）：32-byte／UTF-8 輸入完整，5-byte 遮蔽值由 Browser 阻擋且未輸出秘密。");
