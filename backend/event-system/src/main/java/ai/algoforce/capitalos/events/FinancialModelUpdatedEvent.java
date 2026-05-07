package ai.algoforce.capitalos.events;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record FinancialModelUpdatedEvent(
    UUID ventureId,
    double valuation,
    Instant occurredAt,
    Map<String, Object> payload) implements CapitalOsEvent {
  @Override
  public String eventName() {
    return "FinancialModelUpdatedEvent";
  }
}
