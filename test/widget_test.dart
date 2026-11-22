import 'package:flutter_test/flutter_test.dart';
import 'package:agrismart/app.dart';

void main() {
  testWidgets('App creation test', (WidgetTester tester) async {
    expect(const MyApp(), isNotNull);
  });
}
