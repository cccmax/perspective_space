import 'package:flutter/widgets.dart';

import '../perspective_layer.dart';
import '../perspective_space.dart';

/// A drop-in tilting card.
///
/// Combines a [PerspectiveSpace] (with gestures enabled by default) and a
/// single [PerspectiveLayer], so you don't have to wire the pair up
/// yourself.
///
/// ```dart
/// PerspectiveTiltCard(
///   child: Container(
///     width: 280,
///     height: 200,
///     decoration: BoxDecoration(
///       gradient: LinearGradient(colors: [Colors.purple, Colors.pink]),
///       borderRadius: BorderRadius.circular(24),
///     ),
///     alignment: Alignment.center,
///     child: const Text('Tilt me'),
///   ),
/// )
/// ```
class PerspectiveTiltCard extends StatelessWidget {
  /// Creates a tilting card.
  const PerspectiveTiltCard({
    required this.child,
    super.key,
    this.enableGesture = true,
    this.elevation = 60,
    this.perspective = 0.0015,
    this.sensitivity = 0.005,
    this.maxRotation = 25,
    this.resetOnRelease = true,
    this.entryShake = false,
    this.controller,
  });

  /// If true, dragging on the card tilts it in real time.
  final bool enableGesture;

  /// Z-axis height of the card's single layer. Higher values produce
  /// stronger parallax during tilt.
  final double elevation;

  /// Perspective strength, forwarded to [PerspectiveSpace.perspective].
  final double perspective;

  /// Drag sensitivity, forwarded to [PerspectiveSpace.sensitivity].
  final double sensitivity;

  /// Maximum tilt, in degrees, forwarded to
  /// [PerspectiveSpace.maxRotation].
  final double maxRotation;

  /// If true, the card springs back when released.
  final bool resetOnRelease;

  /// If true, the card plays an entry shake when first mounted.
  final bool entryShake;

  /// Optional controller for triggering a shake imperatively.
  final PerspectiveSpaceController? controller;

  /// The card's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PerspectiveSpace(
      enableGesture: enableGesture,
      perspective: perspective,
      sensitivity: sensitivity,
      maxRotation: maxRotation,
      resetOnRelease: resetOnRelease,
      entryShake: entryShake,
      controller: controller,
      child: PerspectiveLayer(elevation: elevation, child: child),
    );
  }
}
