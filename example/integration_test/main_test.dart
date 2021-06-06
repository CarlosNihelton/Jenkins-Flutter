import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_info/device_info.dart';
import 'package:example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  testWidgets("Testing main widget", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final fab = find.byIcon(Icons.add);
    for (int i = 1; i <= 25; i++) {
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('$i'), findsOneWidget);
    }

    var info = await deviceInfo.androidInfo;
//    expect(false, info.version.sdkInt == 19);
  });
}
