import 'package:flutter_test/flutter_test.dart';

import 'package:oks_qr_mobile/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AppBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('Войти'), findsOneWidget);
  });
}
