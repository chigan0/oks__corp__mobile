enum ApprovalStatusType {
  pending,
  approved,
  denied,
}

class ApprovalStatusResponse {
  const ApprovalStatusResponse({
    required this.status,
    this.reason,
  });

  factory ApprovalStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    if (rawStatus is! String) {
      throw FormatException('Missing approval status in response');
    }

    final status = switch (rawStatus) {
      'pending' => ApprovalStatusType.pending,
      'approved' => ApprovalStatusType.approved,
      'denied' => ApprovalStatusType.denied,
      _ => throw FormatException('Unknown approval status: $rawStatus'),
    };

    return ApprovalStatusResponse(
      status: status,
      reason: json['reason'] as String?,
    );
  }

  final ApprovalStatusType status;
  final String? reason;
}
