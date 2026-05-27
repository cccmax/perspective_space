import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:perspective_space/perspective_space.dart';

/// Programmatic driver for the rotation values inside a [PerspectiveSpace].
///
/// Used both by the visual demos (when the user toggles "auto play") and by
/// `integration_test` for screen capture — integration_test cannot simulate
/// real drag gestures reliably enough to record buttery webps, so we drive
/// the rotation deterministically instead.
class AutoDriver extends StatefulWidget {
  const AutoDriver({
    required this.builder,
    super.key,
    this.period = const Duration(milliseconds: 4000),
    this.amplitudeDeg = 18,
    this.perspective = 0.0015,
  });

  /// Renders the perspective tree from the current ([rotateX], [rotateY]).
  final Widget Function(
    BuildContext context,
    double rotateX,
    double rotateY,
  ) builder;

  /// Length of one full rotation loop.
  final Duration period;

  /// Peak tilt, in degrees, on each axis.
  final double amplitudeDeg;

  /// Forwarded to children that build their own `PerspectiveSpace`.
  final double perspective;

  @override
  State<AutoDriver> createState() => _AutoDriverState();
}

class _AutoDriverState extends State<AutoDriver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amp = widget.amplitudeDeg * math.pi / 180;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value * 2 * math.pi;
        // Lissajous-style figure-eight tilt — both axes excited at different
        // frequencies so the motion never feels like a metronome.
        final rotateX = math.sin(t) * amp;
        final rotateY = math.sin(t * 2) * amp;
        return widget.builder(context, rotateX, rotateY);
      },
    );
  }
}
