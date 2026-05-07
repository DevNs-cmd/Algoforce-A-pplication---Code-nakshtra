package ai.algoforce.capitalos.events;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record IntelligenceRecomputedEvent(
    UUID ventureId,
    int ventureViability,
    Instant occurredAt,
    Map<String, Object> payload) implements CapitalOsEvent {
  @Override
  public String eventName() {
    return "IntelligenceRecomputedEvent";
  }
}
