package ai.algoforce.capitalos.equity;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
class EquityEngine {
  EquityResponse calculate(UUID ventureId, int complexity, int failureProbability, double launchBudget) {
    double algoforceEquity = complexity > 70 ? 12.0 : failureProbability > 55 ? 10.0 : launchBudget > 120000 ? 5.0 : 8.0;
    return new EquityResponse(
        ventureId,
        100.0 - algoforceEquity,
        algoforceEquity,
        24,
        6,
        List.of(
            new UnlockRuleView("mvp_complete", "MVP complete", algoforceEquity * 0.40, "MVP_COMPLETED"),
            new UnlockRuleView("users_acquired", "User acquisition milestone", algoforceEquity * 0.30, "TRACTION_ACTIVE"),
            new UnlockRuleView("revenue_validated", "Revenue milestone", algoforceEquity * 0.30, "FUNDRAISING_READY")),
        "EquityUpdatedEvent",
        Instant.now());
  }

  EquityUnlockResponse processUnlocks(UUID ventureId, int elapsedMonths, String state, double algoforceEquity) {
    if (elapsedMonths < 6) {
      return new EquityUnlockResponse(ventureId, 0, "TransitionBlockedEvent", "6-month cliff not reached", Instant.now());
    }
    double unlocked = switch (state) {
      case "MVP_COMPLETED", "LAUNCHED" -> algoforceEquity * 0.40;
      case "TRACTION_ACTIVE" -> algoforceEquity * 0.70;
      case "FUNDRAISING_READY", "SCALING" -> algoforceEquity;
      default -> 0;
    };
    return new EquityUnlockResponse(ventureId, unlocked, "EquityUpdatedEvent", "unlock rules processed", Instant.now());
  }
}
