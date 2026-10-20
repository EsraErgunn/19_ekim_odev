import 'package:damla/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DamlaApp smoke test and navigation across 3 main modules', (WidgetTester tester) async {
    await tester.pumpWidget(const DamlaApp());
    await tester.pump();

    // 1. Sekme: Bağış Akışı (G1)
    expect(find.text('Bağış Süreci (Modül G1)'), findsOneWidget);
    expect(find.text('Uygunluk Testi'), findsOneWidget);

    // 2. Sekmeye geç: Stok Takibi
    await tester.tap(find.text('Stok Takibi'));
    await tester.pump();
    expect(find.text('Kan Grubu Stok Takibi'), findsOneWidget);

    // 3. Sekmeye geç: Acil Talepler
    await tester.tap(find.text('Acil Talepler'));
    await tester.pump();
    expect(find.text('Acil Kan Talepleri'), findsOneWidget);
  });
}
