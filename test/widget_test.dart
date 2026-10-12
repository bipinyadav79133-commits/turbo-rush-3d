import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_rush_3d/app/app.dart';
import 'package:turbo_rush_3d/models/player_profile.dart';

void main() {
  testWidgets('Turbo Rush 3D smoke test', (WidgetTester tester) async {
    // Set widescreen landscape phone dimensions
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final profile = PlayerProfile();
    await tester.pumpWidget(TurboRushApp(profile: profile));
    await tester.pump();

    // Verify main menu branding and buttons render cleanly
    expect(find.text('TURBO RUSH 3D'), findsOneWidget);
    expect(find.text('START RACE'), findsOneWidget);
    expect(find.text('GARAGE & TUNING'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
