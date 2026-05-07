package ai.algoforce.capitalos.events;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record EquityUpdatedEvent(
    UUID ventureId,
    double unlockedEquity,
    Instant occurredAt,
    Map<String, Object> payload) implements CapitalOsEvent {
  @Override
  public String eventName() {
    return "EquityUpdatedEvent";
  }
}
