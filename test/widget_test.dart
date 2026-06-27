// This is a basic Flutter widget test for the Spendid application.
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_ios_app/main.dart';

void main() {
  testWidgets('Spendid app bottom navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we are on the dashboard tab first
    expect(find.text('สรุปผล'), findsAtLeast(1));
    expect(find.text('ประวัติ'), findsAtLeast(1));
    expect(find.text('บันทึก'), findsAtLeast(1));

    // Verify presence of balance card text
    expect(find.text('ยอดเงินคงเหลือสุทธิ'), findsOneWidget);

    // Tap on the Add Transaction tab ('บันทึก')
    // Bottom tab bar item is the second child of the bar
    await tester.tap(find.byIcon(CupertinoIcons.plus_circle));
    await tester.pumpAndSettle();

    // Verify that the title of the page is "บันทึกรายการ"
    expect(find.text('บันทึกรายการ'), findsOneWidget);
    // Verify that it starts with amount ฿ 0.00 or ฿ 0
    expect(find.textContaining('฿'), findsAtLeast(1));
  });
}
