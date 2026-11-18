const IAC = 255;
const SE = 240;
const SB = 250;
const WILL = 251;
const WONT = 252;
const DO = 253;
const DONT = 254;

// TelnetTextFilter（Telnet 文字過濾器）：移除協定控制位元組，只把 UTF-8 遊戲文字送往瀏覽器。
// 狀態必須跨 TCP 資料塊保存，避免控制序列被分段時把 0xff 誤解成文字而產生亂碼。
export class TelnetTextFilter {
  constructor() {
    this.state = "data";
  }

  push(chunk) {
    const output = [];
    for (const byte of chunk) {
      if (this.state === "data") {
        if (byte === IAC) this.state = "iac";
        else output.push(byte);
        continue;
      }

      if (this.state === "iac") {
        if (byte === IAC) {
          // Telnet 的 IAC IAC 代表單一 0xff，但 0xff 不可能是合法 UTF-8 文字；
          // 此 Bridge 僅傳送文字，必須略過它，避免瀏覽器產生替代字元 �。
          this.state = "data";
        } else if (byte === WILL || byte === WONT || byte === DO || byte === DONT) {
          this.state = "negotiation-option";
        } else if (byte === SB) {
          this.state = "subnegotiation";
        } else {
          // GA、NOP 等雙位元組命令沒有文字內容，讀完命令即可回到資料狀態。
          this.state = "data";
        }
        continue;
      }

      if (this.state === "negotiation-option") {
        this.state = "data";
        continue;
      }

      if (this.state === "subnegotiation") {
        if (byte === IAC) this.state = "subnegotiation-iac";
        continue;
      }

      if (this.state === "subnegotiation-iac") {
        if (byte === SE) this.state = "data";
        else if (byte !== IAC) this.state = "subnegotiation";
      }
    }
    return Buffer.from(output);
  }
}
