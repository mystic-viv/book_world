import 'package:flutter_test/flutter_test.dart';
import 'package:book_world/main.dart';

void main() {
  testWidgets('App loads properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const BookWorldApp(),
    );

    // Wait for any animations/rebuilds
    await tester.pumpAndSettle();

    // Verify if "BOOK WORLD" text appears in the UI
    expect(find.text("BOOK WORLD"), findsOneWidget);
  });
}