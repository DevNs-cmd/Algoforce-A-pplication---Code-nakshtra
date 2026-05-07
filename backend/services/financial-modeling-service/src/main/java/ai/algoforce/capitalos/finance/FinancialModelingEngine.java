package ai.algoforce.capitalos.finance;

import java.time.Instant;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
class FinancialModelingEngine {
  FinancialModelResponse project(UUID ventureId, FinancialModelRequest request) {
    double projectedRevenue = request.pricePoint() * Math.max(30, request.expectedCustomers());
    double monthlyBurn = 14000 + request.launchBudget() * 0.12;
    double grossProfit = Math.max(1, projectedRevenue * request.grossMarginPercent() / 100);
    int breakEvenMonth = Math.max(3, (int) Math.ceil(monthlyBurn / grossProfit));
    double funding = request.launchBudget() + monthlyBurn * Math.max(4, request.runwayMonths());
    double valuation = Math.max(500000, projectedRevenue * 12 * 5 * request.ventureViability() / 100);
    return new FinancialModelResponse(
        ventureId,
        projectedRevenue,
        monthlyBurn,
        breakEvenMonth,
        funding,
        valuation,
        "FinancialModelUpdatedEvent",
        Instant.now());
  }
}
