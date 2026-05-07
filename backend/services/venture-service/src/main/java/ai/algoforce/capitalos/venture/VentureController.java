package ai.algoforce.capitalos.venture;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/ventures")
class VentureController {
  private final VentureObjectService ventureObjectService;

  VentureController(VentureObjectService ventureObjectService) {
    this.ventureObjectService = ventureObjectService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  VentureObjectView create(@Valid @RequestBody CreateVentureRequest request) {
    return ventureObjectService.create(request);
  }

  @GetMapping("/{ventureId}")
  VentureObjectView fetch(@PathVariable UUID ventureId) {
    return ventureObjectService.fetch(ventureId);
  }

  @PostMapping("/{ventureId}/validate")
  VentureObjectView validate(@PathVariable UUID ventureId) {
    return ventureObjectService.validate(ventureId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "Venture validation failed"));
  }

  @PostMapping("/{ventureId}/blueprint")
  VentureObjectView blueprint(@PathVariable UUID ventureId) {
    return ventureObjectService.blueprint(ventureId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "Venture must be VALIDATED first"));
  }

  record CreateVentureRequest(
      @NotBlank String founderId,
      @NotBlank String idea,
      @NotBlank String industry,
      @NotBlank String targetCustomer,
      @NotBlank String problem,
      @NotBlank String businessModel,
      @Positive double pricePoint,
      @Positive double launchBudget) {}
}

record VentureObjectView(
    UUID ventureId,
    String founderId,
    String name,
    String currentState,
    Map<String, Object> ideaMetadata,
    Map<String, Object> marketHypothesis,
    Map<String, Object> businessModel,
    Map<String, Object> mvpScope,
    Map<String, Object> teamStructure,
    Map<String, Object> capitalRequirement,
    Map<String, Object> equityStructure,
    Map<String, Object> genome,
    List<Map<String, Object>> events,
    Instant updatedAt) {}
