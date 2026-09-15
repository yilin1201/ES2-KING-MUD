# M3 — Character Persistence / Relogin Result

Status: **PASS**

## Goal
Verify a real Original ES2 character can be created, saved, quit, recognized on a second connection, restored, and continue normal gameplay.

## Verified runtime chain
1. Boot Original ES2 Mudlib with Neolith and open TCP port 4000.
2. Create account `mthree` and Human / Commoner / Level 1 character `持久測試`.
3. Verify live `look`, `score`, and M2 attribute probe.
4. Execute `quit` and close the first Telnet session.
5. Verify both persistence files exist:
   - `mudlib/data/user/m/mthree.o` — character data
   - `mudlib/data/login/m/mthree.o` — login/account data
6. Open a second Telnet session with the same account.
7. Confirm the server recognizes the account and asks for the password instead of character creation.
8. Restore the same character and verify identity, class, race, level and all eight base attributes.
9. Execute `look`, `score`, `inventory`, `help`, `west`, `east`, and the M2 regression probe after relogin.

## Live evidence — Run #52
- Workflow run: `34998031095`
- Job: `104479124541`
- Result: `success`
- Character save: `mudlib/data/user/m/mthree.o` (712 bytes in this run)
- Login save: `mudlib/data/login/m/mthree.o` (259 bytes in this run)
- Second connection returned `請輸入密碼`, proving the persisted login account was recognized.
- Restored identity: `【 平民 】持久測試 (Mthree)`
- Restored state: male Human, Level 1 Commoner, spawn at `客棧大堂`.
- Movement after relogin: `客棧大堂` → west → `廚房` → east → `客棧大堂`.
- Eight base attributes before and after relogin were identical in the passing run:
  - str 13
  - cor 13
  - int 15
  - spi 13
  - cps 14
  - dex 13
  - con 16
  - wis 17
- Runtime resources remained valid: HP 80/80, Gin 30/30, Kee 30/30, Sen 30/30.

Passing workflow messages:
- `M3 PASS PERSISTENCE: same account and character recognized after quit and relogin.`
- `M3 PASS ATTRIBUTES: ...`
- `M3 PASS COMMANDS: look, score, inventory, help, west/east movement executed after relogin.`
- `M3 PASS: account + character persisted through quit/relogin with identity and attributes intact; core commands and movement remained usable.`

## Root cause fixed during M3
Original ES2 persists login/account data and character/body data separately. A clean bootstrap must provide both `mudlib/data/login/a..z` and `mudlib/data/user/a..z`. Creating only the character-data directories allowed the character object to save but prevented the login account from being recognized on the next connection.

The ES2-KING bootstrap now prepares both directory trees and applies the project decision to disable `ENABLE_ANTISPAM` in the prepared runtime.

## Regression status
- M0: PASS
- M1: PASS
- M2: PASS
- M3: **PASS**

PR #12 remains unmerged pending explicit approval.
