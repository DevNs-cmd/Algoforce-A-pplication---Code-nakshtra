package ai.algoforce.capitalos.events;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record MVPBuildStartedEvent(
    UUID ventureId,
    Instant occurredAt,
    Map<String, Object> payload) implements CapitalOsEvent {
  @Override
  public String eventName() {
    return "MVPBuildStartedEvent";
  }
}
