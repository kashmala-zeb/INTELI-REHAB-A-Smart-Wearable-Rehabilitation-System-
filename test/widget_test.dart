import 'package:flutter_test/flutter_test.dart';

import 'package:inteli_rehab/app.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the header containing the name is rendered.
    expect(find.text('Kashmala'), findsOneWidget);
    expect(find.text('👋'), findsOneWidget);
  });
}
