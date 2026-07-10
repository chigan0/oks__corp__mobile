class FacilityCodeResponse {
  const FacilityCodeResponse({required this.code, required this.expiresIn});

  static const _defaultExpiresIn = 30;

  final String code;
  final int expiresIn;

  factory FacilityCodeResponse.fromJson(Map<String, dynamic> json) {
    return FacilityCodeResponse(
      code: json['code'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? _defaultExpiresIn,
    );
  }
}
