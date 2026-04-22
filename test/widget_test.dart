import 'package:flutter_test/flutter_test.dart';

import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/main.dart';

void main() {
  testWidgets('App boots and shows auth flow', (WidgetTester tester) async {
    await initDependencyInjections();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
