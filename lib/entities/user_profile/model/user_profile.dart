import 'personal_document.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.company,
    required this.iin,
    required this.phone,
    required this.documents,
  });

  final String id;
  final String fullName;
  final String company;
  final String iin;
  final String phone;
  final List<PersonalDocument> documents;
}
