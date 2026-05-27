import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Example app boots and lists demos', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('perspective_space'), findsOneWidget);
  });
}
