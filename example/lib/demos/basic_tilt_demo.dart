import 'package:flutter/material.dart';
import 'package:perspective_space/perspective_space.dart';

import '../theme/demo_palette.dart';
import '_auto_player.dart';

/// Demo 1 — a static tilt with `PerspectiveTiltCard`.
class BasicTiltDemo extends StatelessWidget {
  const BasicTiltDemo({super.key, this.autoPlay = false});

  final bool autoPlay;

  static const String title = 'Basic tilt';
  static const String description =
      'Single-card tilt. Use PerspectiveTiltCard for one-liner setup.';

  @override
  Widget build(BuildContext context) {
    if (autoPlay) {
      return AutoDriver(
        builder: (context, rx, ry) => PerspectiveSpace(
          rotateX: rx,
          rotateY: ry,
          child: PerspectiveLayer(
            elevation: 60,
            child: _Card(),
          ),
        ),
      );
    }
    return const PerspectiveTiltCard(child: _Card());
  }
}

class _Card extends StatelessWidget {
  const _Card();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        gradient: DemoPalette.pinkPurple,
        borderRadius: BorderRadius.circular(28),
        boxShadow: DemoPalette.glow(DemoPalette.accentPink),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.bolt, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'TILT',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Drag to feel the depth',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
