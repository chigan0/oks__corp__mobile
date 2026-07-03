import '../model/personal_document.dart';
import '../model/user_profile.dart';

class MockUserRepository {
  MockUserRepository._();

  static final MockUserRepository instance = MockUserRepository._();

  final UserProfile workerProfile = UserProfile(
    id: 'worker-001',
    fullName: 'Паргалы Ибрагим-паша',
    company: 'Muhteşem Yüzyıl',
    iin: '0103892003040',
    phone: '+7 771 123 45 67',
    documents: [
      PersonalDocument(
        id: 'p-doc-1',
        fileName: 'udostoverenie_lichnosti.pdf',
        uploadedAt: DateTime(2026, 1, 10, 14, 0),
      ),
      PersonalDocument(
        id: 'p-doc-2',
        fileName: 'medknizhka.pdf',
        uploadedAt: DateTime(2026, 2, 20, 11, 30),
      ),
    ],
  );
}
