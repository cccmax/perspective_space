// Renders the square showcase as an animated frame sequence for the README /
// pub.dev gallery. The tilt gently sways (multi-layer parallax drifts with it);
// frame 0 is the hero pose, so the static pub.dev search thumbnail still reads
// as a 3D-tilted layered card.
//
//   flutter test test/capture/showcase_test.dart
//   # then encode (render at 1200px, downscale to 512 for crisp text; 20fps):
//   #   ffmpeg -y -framerate 20 -i build/screenshots/showcase_%03d.png \
//   #     -vf "scale=512:512:flags=lanczos" -loop 0 -compression_level 6 \
//   #     -q:v 92 ../screenshots/showcase.webp
//
// Output: build/screenshots/showcase_###.png  (72 frames @ 1200px source)
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perspective_space/perspective_space.dart';

import 'package:example/theme/demo_palette.dart';

const Size _kSize = Size(600, 600); // logical layout; downscaled to 512 on encode
const double _kPixelRatio = 2.0; // render at 1200px so the 512 downscale is crisp
const int _kFrames = 72;

// Orbital sway center.
const double _baseRotX = -0.15;
const double _baseRotY = 0.24;
// Orbit radius (radians). Quadrature (sin/cos) = constant-speed gyration, no
// stop-and-reverse, so it reads smoother than a back-and-forth sway.
const double _ampX = 0.08;
const double _ampY = 0.09;

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

    for (var i = 0; i < _kFrames; i++) {
      // Full period over the sequence -> seamless loop. Quadrature sin/cos
      // traces a circle in (rx, ry) -> constant-speed orbital tilt.
      final t = 2 * math.pi * i / _kFrames;
      final rx = _baseRotX + _ampX * math.sin(t);
      final ry = _baseRotY + _ampY * math.cos(t);

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
                child: SizedBox.fromSize(
                  size: _kSize,
                  child: _Showcase(rotateX: rx, rotateY: ry),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final bytes = await tester.runAsync<Uint8List?>(() async {
        final image = await boundary.toImage(pixelRatio: _kPixelRatio);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        return data?.buffer.asUint8List();
      });
      if (bytes == null) fail('Failed to encode showcase frame $i');
      File('build/screenshots/showcase_${i.toString().padLeft(3, '0')}.png')
          .writeAsBytesSync(bytes);
    }
    stdout.writeln('wrote $_kFrames showcase frames');
  });
}

class _Showcase extends StatelessWidget {
  const _Showcase({required this.rotateX, required this.rotateY});

  final double rotateX;
  final double rotateY;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: DemoPalette.bg),
      child: Center(
        child: PerspectiveSpace(
          rotateX: rotateX,
          rotateY: rotateY,
          perspective: 0.0018,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              PerspectiveLayer(elevation: 0, child: _backGlow()),
              PerspectiveLayer(elevation: 55, child: _card()),
              PerspectiveLayer(elevation: 120, child: _foreground()),
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
                    child:
                        const Icon(Icons.layers, color: Colors.white, size: 26),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
}
