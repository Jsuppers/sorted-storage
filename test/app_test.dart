// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/app/app.dart';
import 'package:sorted_storage/presentation/landing/view/lading_page.dart';

void main() {
  group('App', () {
    testWidgets('renders LandingPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(LandingPage), findsOneWidget);
    });
  });
}
