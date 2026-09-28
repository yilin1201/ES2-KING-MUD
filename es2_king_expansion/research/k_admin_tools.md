# ES2-KING K Admin Tools

- KING Owner: khome, kcreate, kcanon, kmartial, kadmin.
- Wizard: kroom, kexit, kmap, kact, kwhere, knpc, kitem.
- Arch: Wizard set + kgoto, kobj, ktrace, kbroken, kmiss.
- Player command `k` remains untouched; this change does not create or replace `k`.
- Existing `kinghome/kingcreate/kingcanon/kingmartial` remain as compatibility commands.
- K-team roles are intentionally separate from Original ES2 `wiz_status`; only KING Owner may change K-team roles through kadmin.
- Runtime inspection never claims that add_action/conditional source can be reconstructed from object state. Such cases are marked STATIC SOURCE ANALYSIS REQUIRED.
