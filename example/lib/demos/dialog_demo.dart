import 'package:flutter/material.dart';
import 'package:perspective_space/perspective_space.dart';

import '../theme/demo_palette.dart';
import '_auto_player.dart';

/// Demo 5 — perspective parallax inside a centered dialog surface.
///
/// Mirrors the layout pattern of a "reward unlocked" modal without lifting
/// anything domain-specific from the original project.
class DialogDemo extends StatelessWidget {
  const DialogDemo({super.key, this.autoPlay = false});

  final bool autoPlay;

  static const String title = 'Dialog';
  static const String description =
      'Drop a parallax card into a centered modal surface.';

  @override
  Widget build(BuildContext context) {
    final dialog = _DialogSurface(autoPlay: autoPlay);
    return Center(child: dialog);
  }
}

class _DialogSurface extends StatelessWidget {
  const _DialogSurface({required this.autoPlay});

  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    final card = _Card();
    final inner = autoPlay
        ? AutoDriver(
            builder: (context, rx, ry) => PerspectiveSpace(
              rotateX: rx,
              rotateY: ry,
              child: PerspectiveLayer(elevation: 70, child: card),
            ),
          )
        : PerspectiveSpace(
            enableGesture: true,
            entryShake: true,
            maxRotation: 28,
            child: PerspectiveLayer(elevation: 70, child: card),
          );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: inner,
      ),
    );
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: DemoPalette.glow(DemoPalette.accentPink, blur: 48),
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'UNLOCKED',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Perspective\nDialog',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.1,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A modal surface that pops in 3D.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
