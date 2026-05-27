// Headless screenshot capture: drives each demo programmatically and dumps
// 80 PNG frames per demo into build/screenshots/. Run with:
//
//   flutter test test/capture/capture_test.dart
//
// Then convert to animated WebP via tool/capture_webp.sh.
//
// Uses [LiveTestWidgetsFlutterBinding] so the real raster pipeline runs —
// the default [AutomatedTestWidgetsFlutterBinding] uses fake-async and does
// not flush frames, which causes `RenderRepaintBoundary.toImage` to hang
// after the first capture.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/demos/basic_tilt_demo.dart';
import 'package:example/demos/dialog_demo.dart';
import 'package:example/demos/gesture_demo.dart';
import 'package:example/demos/parallax_card_demo.dart';
import 'package:example/demos/shake_entry_demo.dart';
import 'package:example/theme/demo_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const int _kFrames = 80;
const Duration _kStep = Duration(milliseconds: 50);
const Size _kCanvas = Size(360, 480);
const double _kPixelRatio = 1.5;

class _Spec {
  const _Spec(this.name, this.builder);
  final String name;
  final Widget Function() builder;
}

final List<_Spec> _demos = <_Spec>[
  _Spec('basic_tilt', () => const BasicTiltDemo(autoPlay: true)),
  _Spec('gesture', () => const GestureDemo(autoPlay: true)),
  _Spec('shake', () => const ShakeEntryDemo(autoPlay: true)),
  _Spec('parallax', () => const ParallaxCardDemo(autoPlay: true)),
  _Spec('dialog', () => const DialogDemo(autoPlay: true)),
];

Future<void> _loadRealFonts() async {
  // flutter_tester boots with `--use-test-fonts --disable-asset-fonts`, which
  // renders every glyph (including MaterialIcons) as a white block. Pull the
  // real fonts off disk and feed them in via FontLoader so the screenshots
  // actually show text and icons.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      '/Users/CCCMAX/Applications/flutter';
  final fontsDir = '$flutterRoot/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('$fontsDir/$f').readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Roboto', <String>[
    'Roboto-Thin.ttf',
    'Roboto-Light.ttf',
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Black.ttf',
  ]);
  await load('MaterialIcons', <String>['MaterialIcons-Regular.otf']);
}

void main() {
  // Real vsync + real raster — the default automated binding deadlocks
  // `toImage` after the first frame.
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  Directory('build/screenshots').createSync(recursive: true);

  setUpAll(_loadRealFonts);

  for (final spec in _demos) {
    testWidgets('capture ${spec.name}', (tester) async {
      tester.view.physicalSize = _kCanvas * _kPixelRatio;
      tester.view.devicePixelRatio = _kPixelRatio;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: DemoPalette.bg),
              child: Center(
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox.fromSize(
                    size: _kCanvas,
                    child: Center(child: spec.builder()),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      for (var i = 0; i < _kFrames; i++) {
        await tester.pump(_kStep);
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final bytes = await tester.runAsync<Uint8List?>(() async {
          final image = await boundary.toImage(pixelRatio: _kPixelRatio);
          final data = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          image.dispose();
          return data?.buffer.asUint8List();
        });
        if (bytes == null) {
          fail('Failed to encode frame $i of ${spec.name}');
        }
        File(
          'build/screenshots/${spec.name}_'
          '${i.toString().padLeft(3, '0')}.png',
        ).writeAsBytesSync(bytes);
      }

      stdout.writeln('captured ${spec.name}: $_kFrames frames');
    });
  }
}
