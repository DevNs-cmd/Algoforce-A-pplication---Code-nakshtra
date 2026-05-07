package ai.algoforce.capitalos.venture;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
class VentureObjectService {
  private final Map<UUID, VentureObjectView> store = new HashMap<>();

  VentureObjectView create(VentureController.CreateVentureRequest request) {
    var id = UUID.randomUUID();
    var seed = request.idea().length() + request.problem().length() * 2 + request.industry().length();
    var viability = clamp(72 + request.problem().length() / 10 - seed % 18);
    var complexity = clamp(44 + seed % 36);
    var algoforceEquity = complexity > 70 ? 12.0 : request.launchBudget() > 120000 ? 5.0 : 8.0;
    var view = new VentureObjectView(
        id,
        request.founderId(),
        nameFromIdea(request.idea(), request.industry()),
        "IDEA_CAPTURED",
        Map.of("idea", request.idea(), "industry", request.industry(), "targetCustomer", request.targetCustomer(), "problem", request.problem()),
        Map.of("customerSegment", request.targetCustomer(), "problemSeverity", "high", "whyNow", "AI-native execution compression"),
        Map.of("model", request.businessModel(), "pricePoint", request.pricePoint(), "grossMarginPercent", 82),
        Map.of("coreFeatures", List.of("auth", "venture-object", "execution-state-machine", "equity-ledger"), "expectedWeeks", 8),
        Map.of("requiredRoles", List.of("product architect", "flutter engineer", "spring boot engineer", "growth operator")),
        Map.of("buildBudget", request.launchBudget(), "monthlyBurn", 25000, "fundingRequired", request.launchBudget() + 150000),
        Map.of("founderEquity", 100 - algoforceEquity, "algoforceEquity", algoforceEquity, "vestingMonths", 24, "cliffMonths", 6),
        Map.of("ventureViability", viability, "executionComplexityIndex", complexity, "fundingProbability", clamp(45 + viability / 2), "riskFailureProbability", clamp(100 - viability + complexity / 4)),
        List.of(event("VentureCreatedEvent", "Venture Object created.")),
        Instant.now());
    store.put(id, view);
    return view;
  }

  VentureObjectView fetch(UUID ventureId) {
    return store.getOrDefault(ventureId, prototype(ventureId));
  }

  Optional<VentureObjectView> validate(UUID ventureId) {
    var current = fetch(ventureId);
    if (((String) current.ideaMetadata().get("problem")).length() < 18) {
      return Optional.empty();
    }
    return Optional.of(withState(current, "VALIDATED", "VentureValidatedEvent", "Validation thresholds passed."));
  }

  Optional<VentureObjectView> blueprint(UUID ventureId) {
    var current = fetch(ventureId);
    if (!"VALIDATED".equals(current.currentState())) {
      return Optional.empty();
    }
    var scoped = new HashMap<>(current.mvpScope());
    scoped.put("architectureOutputs", List.of("Spring Boot services", "Flutter state-driven screens", "Kafka event contracts"));
    return Optional.of(withState(current, "BLUEPRINT_GENERATED", scoped, "BlueprintGeneratedEvent", "Blueprint generated."));
  }

  private VentureObjectView withState(VentureObjectView current, String state, String eventName, String message) {
    return withState(current, state, current.mvpScope(), eventName, message);
  }

  private VentureObjectView withState(VentureObjectView current, String state, Map<String, Object> scope, String eventName, String message) {
    var events = new ArrayList<>(current.events());
    events.add(0, event(eventName, message));
    var next = new VentureObjectView(
        current.ventureId(), current.founderId(), current.name(), state, current.ideaMetadata(),
        current.marketHypothesis(), current.businessModel(), scope, current.teamStructure(),
        current.capitalRequirement(), current.equityStructure(), current.genome(), events, Instant.now());
    store.put(current.ventureId(), next);
    return next;
  }

  private VentureObjectView prototype(UUID id) {
    var request = new VentureController.CreateVentureRequest(
        "prototype-founder",
        "CapitalOS venture execution system",
        "AI SaaS",
        "seed-stage founders",
        "Founders need deterministic startup execution with equity governance.",
        "Subscription",
        199,
        85000);
    var view = create(request);
    return new VentureObjectView(id, view.founderId(), view.name(), view.currentState(), view.ideaMetadata(), view.marketHypothesis(), view.businessModel(), view.mvpScope(), view.teamStructure(), view.capitalRequirement(), view.equityStructure(), view.genome(), view.events(), view.updatedAt());
  }

  private static Map<String, Object> event(String eventName, String message) {
    return Map.of("eventName", eventName, "message", message, "occurredAt", Instant.now().toString());
  }

  private static String nameFromIdea(String idea, String industry) {
    var words = idea.split("\\s+");
    if (words.length < 2) {
      return industry + " Venture";
    }
    return words[0] + " " + words[1];
  }

  private static int clamp(int value) {
    return Math.max(0, Math.min(100, value));
  }
}
