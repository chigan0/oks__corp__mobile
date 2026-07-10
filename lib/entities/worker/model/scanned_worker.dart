class ScannedWorker {
  const ScannedWorker({
    required this.fullName,
    required this.company,
    required this.iin,
    required this.phone,
  });

  final String fullName;
  final String company;
  final String iin;
  final String phone;

  factory ScannedWorker.fromJson(Map<String, dynamic> json) {
    return ScannedWorker(
      fullName: json['fullName'] as String? ?? '',
      company: json['tooName'] as String? ?? '',
      iin: json['iin'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}
