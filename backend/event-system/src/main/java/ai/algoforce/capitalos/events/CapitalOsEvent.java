package ai.algoforce.capitalos.events;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public sealed interface CapitalOsEvent permits
    VentureCreatedEvent,
    MVPBuildStartedEvent,
    MilestoneCompletedEvent,
    EquityUpdatedEvent,
    IntelligenceRecomputedEvent,
    FinancialModelUpdatedEvent {
  UUID ventureId();

  String eventName();

  Instant occurredAt();

  Map<String, Object> payload();
}
