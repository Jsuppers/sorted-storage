// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:sorted_storage/presentation/about/view/about_page.dart';
import '../../../helpers/helpers.dart';

void main() {
  testWidgets('renders about page', (tester) async {
    await tester.pumpApp(const AboutPage());
    expect(find.byType(CustomScrollView), findsOneWidget);
  });
}
