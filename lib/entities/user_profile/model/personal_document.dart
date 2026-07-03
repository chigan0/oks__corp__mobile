class PersonalDocument {
  const PersonalDocument({
    required this.id,
    required this.fileName,
    required this.uploadedAt,
  });

  final String id;
  final String fileName;
  final DateTime uploadedAt;
}
