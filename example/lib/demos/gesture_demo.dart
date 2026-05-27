import 'package:flutter/material.dart';
import 'package:perspective_space/perspective_space.dart';

import '../theme/demo_palette.dart';
import '_auto_player.dart';

/// Demo 2 — large-amplitude gesture tilt with spring-back.
class GestureDemo extends StatelessWidget {
  const GestureDemo({super.key, this.autoPlay = false});

  final bool autoPlay;

  static const String title = 'Gesture + spring-back';
  static const String description =
      'High-amplitude drag; elastic spring-back on release.';

  @override
  Widget build(BuildContext context) {
    if (autoPlay) {
      return AutoDriver(
        amplitudeDeg: 28,
        builder: (context, rx, ry) => PerspectiveSpace(
          rotateX: rx,
          rotateY: ry,
          child: PerspectiveLayer(elevation: 80, child: _Card()),
        ),
      );
    }
    return const PerspectiveTiltCard(
      maxRotation: 35,
      elevation: 80,
      child: _Card(),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        gradient: DemoPalette.cyanPurple,
        borderRadius: BorderRadius.circular(32),
        boxShadow: DemoPalette.glow(DemoPalette.accentCyan, blur: 48),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const _Grid(),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Text(
              'DRAG ME',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: Icon(Icons.touch_app, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
