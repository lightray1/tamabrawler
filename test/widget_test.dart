// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:tamabrawler/main.dart';
import 'package:tamabrawler/widgets/pixel_button.dart';
import 'package:tamabrawler/widgets/stat_bar.dart';

void main() {
  testWidgets('App starts with default Tamabrawler pet', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TamabrawlerApp());

    // Verify that the pet name is visible
    expect(find.text('Tamabrawler'), findsOneWidget);

    // Verify that the stats are visible
    expect(find.byType(StatBar), findsNWidgets(4));

    // Verify that the buttons are visible
    expect(find.byType(PixelButton), findsNWidgets(5)); // FEED, PLAY, SLEEP, PVE, PVP
  });
}
