// Renders a single square showcase frame for the pub.dev thumbnail / README.
// The scene is statically tilted (no animation) so the very first frame already
// shows the multi-layer parallax depth — which is what pub.dev displays.
//
//   flutter test test/capture/showcase_test.dart
//
// Output: build/screenshots/showcase.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perspective_space/perspective_space.dart';

import 'package:example/theme/demo_palette.dart';

const Size _kSize = Size(760, 760);
const double _kPixelRatio = 2.0;

Future<void> _loadRealFonts() async {
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
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Black.ttf',
  ]);
  await load('MaterialIcons', <String>['MaterialIcons-Regular.otf']);
}

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  Directory('build/screenshots').createSync(recursive: true);
  setUpAll(_loadRealFonts);

  testWidgets('capture showcase', (tester) async {
    await tester.binding.setSurfaceSize(_kSize);
    tester.view.devicePixelRatio = _kPixelRatio;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        home: DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: 'Roboto'),
          child: Material(
            type: MaterialType.transparency,
            child: RepaintBoundary(
              key: key,
              child: SizedBox.fromSize(size: _kSize, child: const _Showcase()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final bytes = await tester.runAsync<Uint8List?>(() async {
      final image = await boundary.toImage(pixelRatio: _kPixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data?.buffer.asUint8List();
    });
    if (bytes == null) fail('Failed to encode showcase frame');
    File('build/screenshots/showcase.png').writeAsBytesSync(bytes);
    stdout.writeln('wrote build/screenshots/showcase.png');
  });
}

class _Showcase extends StatelessWidget {
  const _Showcase();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: DemoPalette.bg),
      child: Center(
        child: PerspectiveSpace(
          // Static tilt so the first (and only) frame shows the depth.
          rotateX: -0.16,
          rotateY: 0.30,
          perspective: 0.0018,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 0 — back glow plane (the "ground shadow").
              PerspectiveLayer(elevation: 0, child: _backGlow()),
              // 1 — the card surface.
              PerspectiveLayer(elevation: 55, child: _card()),
              // 2 — foreground content.
              PerspectiveLayer(elevation: 120, child: _foreground()),
              // 3 — a badge popping out for extra depth.
              PerspectiveLayer(
                elevation: 185,
                child: Align(
                  alignment: const Alignment(0.92, -0.92),
                  child: _badge(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backGlow() => Container(
        width: 390,
        height: 510,
        decoration: BoxDecoration(
          gradient: DemoPalette.pinkPurple,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: DemoPalette.accentPink.withValues(alpha: 0.5),
              blurRadius: 80,
              spreadRadius: 0,
              offset: const Offset(0, 30),
            ),
          ],
        ),
      );

  Widget _card() => Container(
        width: 360,
        height: 480,
        decoration: BoxDecoration(
          color: const Color(0xFF160630),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: DemoPalette.accentPurple, width: 2),
          boxShadow: DemoPalette.glow(DemoPalette.accentPurple, blur: 50),
        ),
      );

  Widget _foreground() => SizedBox(
        width: 360,
        height: 480,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(Icons.layers, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'perspective_space',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'PARALLAX',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tilt layers with depth.\nGesture-driven or auto-animated.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _dot(DemoPalette.accentPink),
                      _dot(DemoPalette.accentPurple),
                      _dot(DemoPalette.accentCyan),
                    ],
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: DemoPalette.cyanPurple,
                      shape: BoxShape.circle,
                      boxShadow: DemoPalette.glow(DemoPalette.accentCyan),
                    ),
                    child: const Icon(
                      Icons.arrow_outward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _dot(Color c) => Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _badge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: DemoPalette.sunset,
          borderRadius: BorderRadius.circular(999),
          boxShadow: DemoPalette.glow(DemoPalette.accentYellow, blur: 24),
        ),
        child: const Text(
          '3D',
          style: TextStyle(
            color: Color(0xFF2B0E5A),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      );
}
