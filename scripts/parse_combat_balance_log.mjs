import fs from "node:fs";

function pct(sorted, q) {
  if (!sorted.length) return null;
  const i = Math.min(sorted.length - 1, Math.max(0, Math.ceil(sorted.length * q) - 1));
  return sorted[i];
}
export function parseBalanceLog(text) {
  const rows=[];
  for (const line of String(text).split(/\r?\n/)) {
    if (!line.includes("ES2BALANCE ")) continue;
    const m=line.match(/damage=(\d+) kill=(\d+) target=([^ ]+) attacker=([^ ]+) source=(.+)$/);
    if (m) rows.push({damage:+m[1],kill:+m[2],target:m[3],attacker:m[4],source:m[5]});
  }
  const d=rows.map(x=>x.damage).sort((a,b)=>a-b);
  const sum=d.reduce((a,b)=>a+b,0);
  return {
    samples:d.length,
    damage_mean:d.length ? sum/d.length : null,
    damage_p50:pct(d,.50),
    damage_p95:pct(d,.95),
    damage_min:d.length ? d[0] : null,
    damage_max:d.length ? d[d.length-1] : null,
    rows
  };
}
if (process.argv[1] && process.argv[1].endsWith("parse_combat_balance_log.mjs") && process.argv[2]) {
  const out=parseBalanceLog(fs.readFileSync(process.argv[2],"utf8"));
  console.log(JSON.stringify(out,null,2));
}
