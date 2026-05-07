import 'user.dart';

class AuthState {
  const AuthState._({
    required this.status,
    this.user,
    this.message,
    this.pendingPhone,
  });

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.loading({String? message})
    : this._(status: AuthStatus.loading, message: message);

  const AuthState.authenticated(AlgoUser user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.error(String message)
    : this._(status: AuthStatus.error, message: message);

  const AuthState.otpSent(String phone)
    : this._(status: AuthStatus.otpSent, pendingPhone: phone);

  final AuthStatus status;
  final AlgoUser? user;
  final String? message;
  final String? pendingPhone;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  AlgoUser? get currentUser => user;

  T maybeWhen<T>({
    T Function(AlgoUser user)? authenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (status) {
      AuthStatus.authenticated when user != null =>
        authenticated?.call(user!) ?? orElse(),
      AuthStatus.error when message != null =>
        error?.call(message!) ?? orElse(),
      _ => orElse(),
    };
  }
}

enum AuthStatus { unauthenticated, loading, authenticated, error, otpSent }
