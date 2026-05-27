import 'package:flutter/widgets.dart';

import '../perspective_layer.dart';
import '../perspective_space.dart';

/// Declarative spec for a single layer inside [PerspectiveParallax].
@immutable
class PerspectiveLayerSpec {
  /// Creates a layer spec.
  const PerspectiveLayerSpec({
    required this.child,
    this.elevation = 0,
    this.alignment = Alignment.center,
  });

  /// Z-axis height of this layer.
  final double elevation;

  /// Alignment for the underlying `Transform`.
  final Alignment alignment;

  /// Subtree to render inside this layer.
  final Widget child;
}

/// A stack of parallax layers without the boilerplate.
///
/// Wraps a [PerspectiveSpace] around a [Stack] of [PerspectiveLayer]s, each
/// configured from a [PerspectiveLayerSpec]:
///
/// ```dart
/// PerspectiveParallax(
///   layers: [
///     PerspectiveLayerSpec(elevation: 0,  child: Background()),
///     PerspectiveLayerSpec(elevation: 40, child: Card()),
///     PerspectiveLayerSpec(elevation: 90, child: Content()),
///   ],
/// )
/// ```
///
/// Layers later in the list paint on top.
class PerspectiveParallax extends StatelessWidget {
  /// Creates a parallax stack.
  const PerspectiveParallax({
    required this.layers,
    super.key,
    this.enableGesture = true,
    this.perspective = 0.0015,
    this.sensitivity = 0.005,
    this.maxRotation = 25,
    this.resetOnRelease = true,
    this.entryShake = false,
    this.controller,
    this.clipBehavior = Clip.none,
  });

  /// Layers to stack, ordered back-to-front.
  final List<PerspectiveLayerSpec> layers;

  /// If true, dragging tilts the whole stack in real time.
  final bool enableGesture;

  /// Perspective strength, forwarded to [PerspectiveSpace.perspective].
  final double perspective;

  /// Drag sensitivity, forwarded to [PerspectiveSpace.sensitivity].
  final double sensitivity;

  /// Maximum tilt, in degrees, forwarded to
  /// [PerspectiveSpace.maxRotation].
  final double maxRotation;

  /// If true, the stack springs back when released.
  final bool resetOnRelease;

  /// If true, the stack plays an entry shake when first mounted.
  final bool entryShake;

  /// Optional controller for triggering a shake imperatively.
  final PerspectiveSpaceController? controller;

  /// Clipping behaviour for the inner [Stack].
  ///
  /// Defaults to [Clip.none] so that floating layers can paint outside the
  /// box bounds.
  final Clip clipBehavior;

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
      child: Stack(
        clipBehavior: clipBehavior,
        alignment: Alignment.center,
        children: <Widget>[
          for (final layer in layers)
            PerspectiveLayer(
              elevation: layer.elevation,
              alignment: layer.alignment,
              child: layer.child,
            ),
        ],
      ),
    );
  }
}
