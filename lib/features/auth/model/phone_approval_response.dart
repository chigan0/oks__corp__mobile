class PhoneApprovalResponse {
  const PhoneApprovalResponse({
    required this.code,
    required this.authMethod,
  });

  factory PhoneApprovalResponse.fromJson(Map<String, dynamic> json) {
    final code = json['code'];
    final authMethod = json['authMethod'];

    if (code is! String || code.isEmpty) {
      throw FormatException('Missing approval code in response');
    }

    return PhoneApprovalResponse(
      code: code,
      authMethod: authMethod is String ? authMethod : 'phone',
    );
  }

  final String code;
  final String authMethod;
}
