import 'dart:convert';

class NexusBuild {
  const NexusBuild({
    required this.prompt,
    required this.filename,
    required this.code,
    required this.deployUrl,
    required this.createdAt,
    this.framework = 'React',
  });

  final String prompt;
  final String filename;
  final String code;
  final String deployUrl;
  final DateTime createdAt;
  final String framework;

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'filename': filename,
      'code': code,
      'deployUrl': deployUrl,
      'createdAt': createdAt.toIso8601String(),
      'framework': framework,
    };
  }

  factory NexusBuild.fromJson(Map<String, dynamic> json) {
    return NexusBuild(
      prompt: json['prompt'] as String? ?? '',
      filename: json['filename'] as String? ?? 'component.jsx',
      code: json['code'] as String? ?? '',
      deployUrl: json['deployUrl'] as String? ?? 'nexus.algoforceai.com/demo',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      framework: json['framework'] as String? ?? 'React',
    );
  }

  static List<NexusBuild> listFromJson(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) => NexusBuild.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static String listToJson(List<NexusBuild> builds) {
    return jsonEncode(builds.map((item) => item.toJson()).toList());
  }
}
