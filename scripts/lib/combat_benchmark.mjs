// Combat Benchmark Parser／戰鬥量測解析器：只解析可觀測輸出，不猜測 HP 傷害。
export function summarizeCombatTranscript(text, elapsedMs, recovered) {
  const source = String(text || "");
  const eventPatterns = [
    /攻擊/g, /擊中/g, /砍/g, /刺/g, /劈/g, /掌/g, /拳/g,
    /閃躲/g, /招架/g, /躲開/g, /避開/g
  ];
  let observableEvents = 0;
  for (const pattern of eventPatterns) observableEvents += (source.match(pattern) || []).length;

  return {
    observable_events: observableEvents,
    ttk_seconds: Number((elapsedMs / 1000).toFixed(3)),
    post_combat_recovery: Boolean(recovered),
    // Damage Unknown／目前玩家文字輸出沒有可靠 HP delta；禁止從敘述推算。
    attempts: null,
    landed_hits: null,
    hit_rate: null,
    damage_mean: null,
    damage_p50: null,
    damage_p95: null,
    damage_min: null,
    damage_max: null,
    resource_cost: null,
    damage_per_resource: null,
    evidence: "ordinary-player-runtime-output",
    damage_evidence: "UNOBSERVED"
  };
}
