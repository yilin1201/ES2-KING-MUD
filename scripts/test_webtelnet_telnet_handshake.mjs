import assert from "node:assert/strict";
import { initialTelnetResponse, TelnetTextFilter } from "../webtelnet/telnet.mjs";

// Neolith 會要求 TTYPE、NAWS、LINEMODE；文字橋接明確拒絕三項終端功能。
assert.deepEqual([...initialTelnetResponse()], [255, 252, 24, 255, 252, 31, 255, 252, 34]);

// TelnetTextFilter 應丟棄控制協商，並在下一個資料區段恢復正常文字。
const filter = new TelnetTextFilter();
assert.equal(filter.push(Buffer.from([255, 253, 24])).length, 0);
assert.equal(filter.push(Buffer.from("login prompt", "utf8")).toString("utf8"), "login prompt");

console.log("WEBTELNET_INITIAL_TELNET_NEGOTIATION_PASS");
