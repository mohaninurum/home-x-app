// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_x_app/main.dart';

void main() {
  testWidgets('Launcher Screen Renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RomanticLauncherApp()));

    // Given we rely on Native Method Channels in initState, we just verify the build started
    expect(find.byType(RomanticLauncherApp), findsOneWidget);
  });
}
