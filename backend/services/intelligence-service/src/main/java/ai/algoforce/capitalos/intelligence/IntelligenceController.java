package ai.algoforce.capitalos.intelligence;

import java.time.Instant;
import java.util.UUID;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/intelligence")
class IntelligenceController {
  private final StartupGenomeEngine genomeEngine;

  IntelligenceController(StartupGenomeEngine genomeEngine) {
    this.genomeEngine = genomeEngine;
  }

  @PostMapping("/{ventureId}/genome")
  GenomeResponse genome(@PathVariable UUID ventureId, @RequestBody GenomeRequest request) {
    return genomeEngine.compute(ventureId, request);
  }
}

record GenomeRequest(
    String idea,
    String industry,
    String targetCustomer,
    String problem,
    String businessModel,
    int coreFeatureCount,
    double launchBudget) {}

record GenomeResponse(
    UUID ventureId,
    int ventureViability,
    int marketSaturationIndex,
    int executionComplexityIndex,
    int fundingProbability,
    int expectedTimeToMvpWeeks,
    int riskFailureProbability,
    String scopeDirective,
    String eventName,
    Instant emittedAt) {}
