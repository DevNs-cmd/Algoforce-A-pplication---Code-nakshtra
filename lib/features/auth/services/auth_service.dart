import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';
import '../models/user.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(preferencesServiceProvider)),
);

class AuthService {
  AuthService(this._prefs);

  final PreferencesService _prefs;

  static const userKey = 'auth_user';
  static const tokenKey = 'auth_token';
  static const sessionKey = 'auth_session_expires';
  static const registeredEmailsKey = 'auth_registered_emails';
  static const otpKey = 'auth_otp';
  static const resetTokenKey = 'auth_reset_token';

  Future<AuthResult> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isEmail(normalizedEmail)) {
      return AuthResult.error('Enter a valid email address');
    }
    if (password.length < 8) {
      return AuthResult.error('Password too short');
    }
    final user =
        await currentUser() ??
        _demoUser(
          email: normalizedEmail,
          name: _nameFromEmail(normalizedEmail),
          role: _roleFromEmail(normalizedEmail),
        );
    await _persistSession(user, normalizedEmail, rememberMe: rememberMe);
    return AuthResult.success(user);
  }

  Future<AuthResult> register(RegisterRequest req) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final validation = req.validate();
    if (validation != null) {
      return AuthResult.error(validation);
    }
    final email = req.email.trim().toLowerCase();
    final registered = _registeredEmails();
    if (registered.contains(email)) {
      return AuthResult.error('This email is already registered');
    }
    final user = AlgoUser(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      name: req.name.trim(),
      email: email,
      phone: req.phone.trim(),
      role: req.role,
      companyName: req.companyName?.trim().isEmpty ?? true
          ? null
          : req.companyName!.trim(),
      createdAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: req.phoneVerified,
      preferences: {
        'primaryInterest': req.primaryInterest,
        'roleDetails': req.roleDetails,
        'updatesOptIn': req.updatesOptIn,
      },
    );
    registered.add(email);
    await _prefs.setString(registeredEmailsKey, jsonEncode(registered));
    await _persistSession(user, email, rememberMe: req.rememberMe);
    return AuthResult.success(user);
  }

  Future<AuthResult> loginWithGoogle({bool rememberMe = true}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final user = _demoUser(
      email: 'demo@algoforce.ai',
      name: 'AlgoForce Demo',
      role: UserRole.admin,
    );
    await _persistSession(user, user.email, rememberMe: rememberMe);
    return AuthResult.success(user);
  }

  Future<void> logout() async {
    await _prefs.remove(userKey);
    await _prefs.remove(tokenKey);
    await _prefs.remove(sessionKey);
  }

  Future<bool> isSessionValid() async {
    final expiry = _prefs.getString(sessionKey);
    if (expiry == null) {
      return false;
    }
    return DateTime.tryParse(expiry)?.isAfter(DateTime.now()) ?? false;
  }

  Future<AlgoUser?> currentUser() async {
    final raw = _prefs.getString(userKey);
    if (raw == null || !await isSessionValid()) {
      return null;
    }
    try {
      return AlgoUser.decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AlgoUser user) async {
    await _prefs.setString(userKey, user.encode());
  }

  Future<void> extendSession({bool rememberMe = true}) async {
    final user = await currentUser();
    if (user == null) {
      return;
    }
    await _persistSession(user, user.email, rememberMe: rememberMe);
  }

  Future<AuthResult> sendOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _prefs.setString('$otpKey:$phone', '1234');
    return AuthResult.success(null);
  }

  Future<AuthResult> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final stored = _prefs.getString('$otpKey:$phone');
    if (otp == '1234' && stored == '1234') {
      await _prefs.remove('$otpKey:$phone');
      return AuthResult.success(null);
    }
    return AuthResult.error('Invalid OTP');
  }

  Future<void> forgotPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    final token = _tokenFor(email.trim().toLowerCase());
    await _prefs.setString(resetTokenKey, token);
  }

  Future<void> deleteAccount() async {
    await logout();
    await _prefs.remove(registeredEmailsKey);
  }

  Future<void> _persistSession(
    AlgoUser user,
    String email, {
    required bool rememberMe,
  }) async {
    await _prefs.setString(userKey, user.encode());
    await _prefs.setString(tokenKey, _tokenFor(email));
    final expiry = DateTime.now().add(Duration(days: rememberMe ? 30 : 7));
    await _prefs.setString(sessionKey, expiry.toIso8601String());
  }

  List<String> _registeredEmails() {
    final raw = _prefs.getString(registeredEmailsKey);
    if (raw == null) {
      return <String>[];
    }
    try {
      return (jsonDecode(raw) as List).whereType<String>().toList();
    } catch (_) {
      return <String>[];
    }
  }

  String _tokenFor(String email) {
    final input = '$email:${DateTime.now().millisecondsSinceEpoch}';
    final digest = sha256.convert(utf8.encode(input));
    return base64UrlEncode(utf8.encode(digest.toString()));
  }

  AlgoUser _demoUser({
    required String email,
    required String name,
    required UserRole role,
  }) {
    return AlgoUser(
      id: 'demo-${sha1.convert(utf8.encode(email)).toString().substring(0, 8)}',
      name: name,
      email: email,
      phone: '9876543210',
      role: role,
      companyName: role == UserRole.founder ? 'AlgoForce Labs' : null,
      createdAt: DateTime.now(),
      isEmailVerified: true,
      isPhoneVerified: true,
      preferences: const {
        'primaryInterest': ['Academy', 'Studio', 'Verified'],
        'notifications': true,
      },
    );
  }

  String _nameFromEmail(String email) {
    final raw = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    return raw
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  UserRole _roleFromEmail(String email) {
    if (email.contains('admin')) {
      return UserRole.admin;
    }
    if (email.contains('investor')) {
      return UserRole.investor;
    }
    if (email.contains('builder')) {
      return UserRole.builder;
    }
    return UserRole.founder;
  }

  bool _isEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    required this.confirmPassword,
    required this.termsAccepted,
    required this.phoneVerified,
    required this.roleDetails,
    required this.primaryInterest,
    this.companyName,
    this.updatesOptIn = true,
    this.rememberMe = true,
  });

  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;
  final bool phoneVerified;
  final Map<String, dynamic> roleDetails;
  final List<String> primaryInterest;
  final String? companyName;
  final bool updatesOptIn;
  final bool rememberMe;

  String? validate() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return 'Enter your full name';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'Enter a valid email address';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone.trim())) {
      return 'Enter a valid 10-digit Indian phone number';
    }
    if (!phoneVerified) {
      return 'Verify your phone number';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password)) {
      return 'Password needs 8 characters, 1 uppercase letter, and 1 number';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    if (!termsAccepted) {
      return 'Accept the Terms of Service and Privacy Policy';
    }
    return null;
  }
}

class AuthResult {
  const AuthResult._({required this.ok, this.user, this.message});

  final bool ok;
  final AlgoUser? user;
  final String? message;

  factory AuthResult.success(AlgoUser? user) {
    return AuthResult._(ok: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(ok: false, message: message);
  }
}
