import 'package:flutter_test/flutter_test.dart';
import 'package:substack_app/app.dart';

void main() {
  testWidgets('Substack app dapat ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const SubstackApp());

    expect(find.byType(SubstackApp), findsOneWidget);
  });
}