
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkelku/main.dart';
import 'package:bengkelku/app_state.dart';

void main() {
  testWidgets('BengkelKu app smoke test', (WidgetTester tester) async {
    final state = AppState();

    await tester.pumpWidget(BengkelKuApp(state));
    await tester.pumpAndSettle();

    expect(find.text('BengkelKu'), findsWidgets);
  });
}
