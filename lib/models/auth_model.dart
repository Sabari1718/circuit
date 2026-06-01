class AuthModel {
  final int authId;
  final int sessionCode;
  final List<int> options;

  AuthModel({
    required this.authId,
    required this.sessionCode,
    required this.options,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      authId: json['auth_id'] ?? 0,
      sessionCode: json['session_code'] ?? 0,
      options: List<int>.from(json['options'] ?? []),
    );
  }
}
