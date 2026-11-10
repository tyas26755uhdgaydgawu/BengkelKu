
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkelku/main.dart';
import 'package:bengkelku/app_state.dart';

void main() {
  group('BengkelKu AppState Tests', () {
    test('Initial data is loaded correctly', () {
      final state = AppState();

      expect(state.services.isNotEmpty, true);
      expect(state.montir.isNotEmpty, true);
      expect(state.screen, Screen.welcome);
    });

    test('Customer demo login works correctly', () {
      final state = AppState();

      state.demo('customer');

      expect(state.user, isNotNull);
      expect(state.screen, Screen.home);
    });

    test('Owner demo login works correctly', () {
      final state = AppState();

      state.demo('owner');

      expect(state.user, isNotNull);
      expect(state.screen, Screen.oHome);
    });
  });

  group('BengkelKu Widget Tests', () {
    testWidgets('BengkelKu application can be displayed',
        (WidgetTester tester) async {
      final state = AppState();

      await tester.pumpWidget(BengkelKuApp(state));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
