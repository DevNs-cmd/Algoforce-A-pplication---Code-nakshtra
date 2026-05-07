package ai.algoforce.capitalos.auth;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.UUID;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
class AuthController {
  @PostMapping("/sign-in")
  FounderSession signIn(@Valid @RequestBody SignInRequest request) {
    var founderId = UUID.nameUUIDFromBytes(request.email().toLowerCase().getBytes());
    return new FounderSession(
        founderId,
        request.email(),
        request.displayName().isBlank() ? "Founder" : request.displayName(),
        "capitalos-access-" + founderId,
        "capitalos-refresh-" + founderId,
        Instant.now().plusSeconds(900));
  }

  record SignInRequest(@Email String email, @NotBlank String displayName, String password) {}
}

record FounderSession(
    UUID founderId,
    String email,
    String displayName,
    String accessToken,
    String refreshToken,
    Instant accessExpiresAt) {}
