import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authServiceProvider)),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._service) : super(const AuthState.unauthenticated()) {
    unawaited(_checkExistingSession());
  }

  final AuthService _service;

  bool get isAuthenticated => state.isAuthenticated;
  AlgoUser? get currentUser => state.currentUser;

  Future<void> _checkExistingSession() async {
    final user = await _service.currentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else if (mounted) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    state = const AuthState.loading(message: 'Signing in...');
    final result = await _service.login(
      email,
      password,
      rememberMe: rememberMe,
    );
    if (!mounted) {
      return;
    }
    state = result.ok && result.user != null
        ? AuthState.authenticated(result.user!)
        : AuthState.error(result.message ?? 'Unable to sign in');
  }

  Future<void> loginWithGoogle({bool rememberMe = true}) async {
    state = const AuthState.loading(message: 'Connecting Google...');
    final result = await _service.loginWithGoogle(rememberMe: rememberMe);
    if (!mounted) {
      return;
    }
    state = result.ok && result.user != null
        ? AuthState.authenticated(result.user!)
        : AuthState.error(result.message ?? 'Google sign-in failed');
  }

  Future<void> register(RegisterRequest req) async {
    state = const AuthState.loading(message: 'Creating account...');
    final result = await _service.register(req);
    if (!mounted) {
      return;
    }
    state = result.ok && result.user != null
        ? AuthState.authenticated(result.user!)
        : AuthState.error(result.message ?? 'Unable to create account');
  }

  Future<void> logout() async {
    await _service.logout();
    if (mounted) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> sendOtp(String phone) async {
    state = const AuthState.loading(message: 'Sending OTP...');
    final result = await _service.sendOtp(phone);
    if (!mounted) {
      return;
    }
    state = result.ok
        ? AuthState.otpSent(phone)
        : AuthState.error(result.message ?? 'Unable to send OTP');
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    final previous = state;
    state = const AuthState.loading(message: 'Verifying OTP...');
    final result = await _service.verifyOtp(phone, otp);
    if (!mounted) {
      return false;
    }
    if (result.ok) {
      state = previous.status == AuthStatus.authenticated
          ? previous
          : AuthState.otpSent(phone);
      return true;
    }
    state = AuthState.error(result.message ?? 'Invalid OTP');
    return false;
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthState.loading(message: 'Sending reset link...');
    await _service.forgotPassword(email);
    if (mounted) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> updateUser(AlgoUser user) async {
    await _service.saveUser(user);
    if (mounted) {
      state = AuthState.authenticated(user);
    }
  }

  Future<void> extendSession({bool rememberMe = true}) async {
    await _service.extendSession(rememberMe: rememberMe);
  }

  Future<void> deleteAccount() async {
    await _service.deleteAccount();
    if (mounted) {
      state = const AuthState.unauthenticated();
    }
  }
}
