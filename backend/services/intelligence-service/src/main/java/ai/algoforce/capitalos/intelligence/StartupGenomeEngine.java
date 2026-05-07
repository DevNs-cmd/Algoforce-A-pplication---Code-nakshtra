package ai.algoforce.capitalos.intelligence;

import java.time.Instant;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
class StartupGenomeEngine {
  GenomeResponse compute(UUID ventureId, GenomeRequest request) {
    int seed = request.idea().length() + request.problem().length() * 2 + request.targetCustomer().length();
    int saturation = clamp(36 + seed % 52);
    int complexity = clamp(38 + request.coreFeatureCount() * 7 + (request.launchBudget() < 40000 ? 12 : 0));
    int viability = clamp(76 + request.problem().length() / 8 - saturation / 4 - complexity / 6);
    int funding = clamp(42 + viability / 2 - saturation / 7);
    int failure = clamp(100 - viability + complexity / 4);
    String directive = failure > 58 || complexity > 68
        ? "Reduce MVP to one monetizable wedge before build starts."
        : "Proceed after evidence gates.";
    return new GenomeResponse(
        ventureId,
        viability,
        saturation,
        complexity,
        funding,
        Math.max(4, 8 + complexity / 20),
        failure,
        directive,
        "IntelligenceRecomputedEvent",
        Instant.now());
  }

  private int clamp(int value) {
    return Math.max(0, Math.min(100, value));
  }
}
