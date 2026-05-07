package ai.algoforce.capitalos.events;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record VentureCreatedEvent(
    UUID ventureId,
    String ventureName,
    Instant occurredAt,
    Map<String, Object> payload) implements CapitalOsEvent {
  @Override
  public String eventName() {
    return "VentureCreatedEvent";
  }
}
