import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalavadiya_wedding_app/main.dart';
import 'package:zalavadiya_wedding_app/services/guest_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Zalavadiya Wedding App loads dashboard test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = GuestRepository();

    // Pump app inside a standard test window
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(ZalavadiyaWeddingApp(repository: repository));
    await tester.pump();

    // Verify MaterialApp and core elements render
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.people_alt_rounded), findsWidgets);
  });

  testWidgets('Zalavadiya Wedding App loads on mobile phone screen test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = GuestRepository();

    // Pump app inside a mobile phone screen
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(ZalavadiyaWeddingApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
