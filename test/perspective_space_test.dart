import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perspective_space/perspective_space.dart';

void main() {
  group('PerspectiveSpace', () {
    testWidgets('builds with default parameters', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveSpace(child: SizedBox(width: 100, height: 100)),
        ),
      );
      expect(find.byType(PerspectiveSpace), findsOneWidget);
    });

    testWidgets('wraps in GestureDetector when enableGesture is true',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveSpace(
            enableGesture: true,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('plays entry shake then settles', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveSpace(
            entryShake: true,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(PerspectiveSpace), findsOneWidget);
    });

    testWidgets('controller.shake() does not throw', (tester) async {
      final controller = PerspectiveSpaceController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveSpace(
            controller: controller,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      controller.shake();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      expect(tester.takeException(), isNull);
    });
  });

  group('PerspectiveLayer', () {
    testWidgets('renders child without ancestor PerspectiveSpace',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveLayer(child: Text('hi')),
        ),
      );
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('participates in a PerspectiveSpace', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveSpace(
            rotateX: 0.1,
            rotateY: -0.1,
            child: PerspectiveLayer(
              elevation: 40,
              child: Text('layered'),
            ),
          ),
        ),
      );
      expect(find.text('layered'), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });
  });

  group('Presets', () {
    testWidgets('PerspectiveTiltCard builds', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveTiltCard(child: Text('card')),
        ),
      );
      expect(find.text('card'), findsOneWidget);
    });

    testWidgets('PerspectiveParallax stacks layers', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveParallax(
            layers: <PerspectiveLayerSpec>[
              PerspectiveLayerSpec(elevation: 0, child: Text('a')),
              PerspectiveLayerSpec(elevation: 40, child: Text('b')),
              PerspectiveLayerSpec(elevation: 90, child: Text('c')),
            ],
          ),
        ),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('PerspectiveShakeEntry runs without exception', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: PerspectiveShakeEntry(child: Text('shake')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      expect(tester.takeException(), isNull);
      expect(find.text('shake'), findsOneWidget);
    });
  });
}
