import 'package:flutter_test/flutter_test.dart';

import 'package:inteli_rehab/main.dart';

void main() {
  testWidgets('InteliRehabApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InteliRehabApp());

    // Verify that the header containing the name is rendered.
    expect(find.text('Kashmala'), findsOneWidget);
    expect(find.text('👋'), findsOneWidget);
  });
}
