package ai.algoforce.capitalos.execution;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/execution")
class ExecutionController {
  private final ExecutionStateMachine stateMachine;

  ExecutionController(ExecutionStateMachine stateMachine) {
    this.stateMachine = stateMachine;
  }

  @PostMapping("/{ventureId}/start-mvp")
  ExecutionResponse startMvp(@PathVariable UUID ventureId) {
    return stateMachine.startMvp(ventureId);
  }

  @PostMapping("/{ventureId}/tasks/{taskKey}/evidence")
  ExecutionResponse evidence(
      @PathVariable UUID ventureId,
      @PathVariable String taskKey,
      @RequestBody EvidenceRequest request) {
    return stateMachine.submitEvidence(ventureId, taskKey, request.evidence())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "Task evidence incomplete or transition blocked"));
  }

  record EvidenceRequest(List<String> evidence) {}
}

record ExecutionResponse(
    UUID ventureId,
    String state,
    String eventName,
    List<String> unblockedTaskKeys,
    Instant emittedAt) {}
