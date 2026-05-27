import 'package:flutter/material.dart';
import 'package:perspective_space/perspective_space.dart';

import '../theme/demo_palette.dart';
import '_auto_player.dart';

/// Demo 4 — three-layer parallax stack via [PerspectiveParallax].
class ParallaxCardDemo extends StatelessWidget {
  const ParallaxCardDemo({super.key, this.autoPlay = false});

  final bool autoPlay;

  static const String title = 'Multi-layer parallax';
  static const String description =
      'Background, card, content — three Z-depths drifting at different speeds.';

  @override
  Widget build(BuildContext context) {
    final layers = <PerspectiveLayerSpec>[
      PerspectiveLayerSpec(elevation: 0, child: _bg()),
      PerspectiveLayerSpec(elevation: 40, child: _card()),
      PerspectiveLayerSpec(elevation: 100, child: _foreground()),
    ];

    if (autoPlay) {
      return AutoDriver(
        builder: (context, rx, ry) => PerspectiveSpace(
          rotateX: rx,
          rotateY: ry,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              for (final l in layers)
                PerspectiveLayer(elevation: l.elevation, child: l.child),
            ],
          ),
        ),
      );
    }
    return PerspectiveParallax(layers: layers);
  }

  Widget _bg() => Container(
        width: 320,
        height: 420,
        decoration: BoxDecoration(
          color: DemoPalette.accentPurple.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(32),
        ),
      );

  Widget _card() => Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1A0833),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: DemoPalette.accentPurple,
            width: 2,
          ),
          boxShadow: DemoPalette.glow(DemoPalette.accentPurple, blur: 40),
        ),
      );

  Widget _foreground() => SizedBox(
        width: 300,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Icon(Icons.layers, color: Colors.white, size: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PARALLAX',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '3 layers · different depths',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: DemoPalette.cyanPurple,
                  shape: BoxShape.circle,
                  boxShadow: DemoPalette.glow(DemoPalette.accentCyan),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      );
}
