import 'dart:convert';

enum UserRole { founder, builder, investor, admin }

extension UserRoleLabel on UserRole {
  String get label {
    return switch (this) {
      UserRole.founder => 'Founder',
      UserRole.builder => 'Builder',
      UserRole.investor => 'Investor',
      UserRole.admin => 'Admin',
    };
  }

  static UserRole fromName(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.founder,
    );
  }
}

class AlgoUser {
  const AlgoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.preferences,
    this.avatarUrl,
    this.companyName,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final String? companyName;
  final DateTime createdAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final Map<String, dynamic> preferences;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'AF';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  AlgoUser copyWith({
    String? name,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? companyName,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? preferences,
  }) {
    return AlgoUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      companyName: companyName ?? this.companyName,
      createdAt: createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'companyName': companyName,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'preferences': preferences,
    };
  }

  factory AlgoUser.fromJson(Map<String, dynamic> json) {
    return AlgoUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'AlgoForce User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRoleLabel.fromName(json['role'] as String? ?? ''),
      avatarUrl: json['avatarUrl'] as String?,
      companyName: json['companyName'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(
        json['preferences'] as Map? ?? const {},
      ),
    );
  }

  String encode() => jsonEncode(toJson());

  static AlgoUser decode(String raw) {
    return AlgoUser.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }
}
