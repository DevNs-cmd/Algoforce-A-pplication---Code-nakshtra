package ai.algoforce.capitalos.execution;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
class ExecutionStateMachine {
  ExecutionResponse startMvp(UUID ventureId) {
    return new ExecutionResponse(
        ventureId,
        "MVP_IN_BUILD",
        "MVPBuildStartedEvent",
        List.of("spring-auth"),
        Instant.now());
  }

  Optional<ExecutionResponse> submitEvidence(UUID ventureId, String taskKey, List<String> evidence) {
    if (evidence == null || evidence.size() < 3) {
      return Optional.empty();
    }
    var nextTask = switch (taskKey) {
      case "spring-auth" -> "venture-api";
      case "venture-api" -> "equity-ledger";
      case "equity-ledger" -> "mobile-flow";
      case "mobile-flow" -> "mvp-complete";
      default -> "blocked";
    };
    var state = "mvp-complete".equals(nextTask) ? "MVP_COMPLETED" : "MVP_IN_BUILD";
    var event = "mvp-complete".equals(nextTask) ? "MilestoneCompletedEvent" : "MilestoneEvidenceEvent";
    return Optional.of(new ExecutionResponse(
        ventureId,
        state,
        event,
        "mvp-complete".equals(nextTask) ? List.of() : List.of(nextTask),
        Instant.now()));
  }
}
