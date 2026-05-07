package ai.algoforce.capitalos.equity;

import jakarta.validation.Valid;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/equity")
class EquityController {
  private final EquityEngine equityEngine;

  EquityController(EquityEngine equityEngine) {
    this.equityEngine = equityEngine;
  }

  @GetMapping("/{ventureId}")
  EquityResponse fetch(@PathVariable UUID ventureId) {
    return equityEngine.calculate(ventureId, 64, 58, 85000);
  }

  @PostMapping("/{ventureId}/calculate")
  EquityResponse calculate(@PathVariable UUID ventureId, @Valid @RequestBody EquityRequest request) {
    return equityEngine.calculate(ventureId, request.executionComplexityIndex(), request.riskFailureProbability(), request.launchBudget());
  }

  @PostMapping("/{ventureId}/process-unlocks")
  EquityUnlockResponse processUnlocks(@PathVariable UUID ventureId, @RequestBody UnlockRequest request) {
    return equityEngine.processUnlocks(ventureId, request.elapsedMonths(), request.currentState(), request.algoforceEquity());
  }

  record EquityRequest(int executionComplexityIndex, int riskFailureProbability, double launchBudget) {}

  record UnlockRequest(int elapsedMonths, String currentState, double algoforceEquity) {}
}

record EquityResponse(
    UUID ventureId,
    double founderEquity,
    double algoforceEquity,
    int vestingMonths,
    int cliffMonths,
    List<UnlockRuleView> unlockRules,
    String eventName,
    Instant emittedAt) {}

record UnlockRuleView(String key, String trigger, double percent, String requiredState) {}

record EquityUnlockResponse(
    UUID ventureId,
    double unlockedAlgoforceEquity,
    String eventName,
    String decision,
    Instant emittedAt) {}
