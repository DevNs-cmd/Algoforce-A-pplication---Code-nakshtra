package ai.algoforce.capitalos.finance;

import java.time.Instant;
import java.util.UUID;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/finance")
class FinancialModelingController {
  private final FinancialModelingEngine engine;

  FinancialModelingController(FinancialModelingEngine engine) {
    this.engine = engine;
  }

  @PostMapping("/{ventureId}/model")
  FinancialModelResponse model(@PathVariable UUID ventureId, @RequestBody FinancialModelRequest request) {
    return engine.project(ventureId, request);
  }

  @PostMapping("/{ventureId}/valuation")
  FinancialModelResponse valuation(@PathVariable UUID ventureId, @RequestBody FinancialModelRequest request) {
    return engine.project(ventureId, request);
  }
}

record FinancialModelRequest(
    double pricePoint,
    double grossMarginPercent,
    double launchBudget,
    int expectedCustomers,
    int runwayMonths,
    int ventureViability) {}

record FinancialModelResponse(
    UUID ventureId,
    double projectedMonthlyRevenue,
    double monthlyBurn,
    int breakEvenMonth,
    double fundingRequirement,
    double valuationEstimate,
    String eventName,
    Instant emittedAt) {}
