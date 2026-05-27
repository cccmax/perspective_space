import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'perspective_data.dart';

/// A layer inside a [PerspectiveSpace], rendered with depth-aware 3D
/// transform.
///
/// The layer's [elevation] sets how far it floats above the base plane.
/// Higher elevation = closer to the camera = larger parallax offset when the
/// surrounding space tilts.
///
/// ```dart
/// PerspectiveSpace(
///   enableGesture: true,
///   child: Stack(
///     children: [
///       PerspectiveLayer(elevation: 0,  child: Image.asset('bg.png')),
///       PerspectiveLayer(elevation: 40, child: cardSurface),
///       PerspectiveLayer(elevation: 90, child: titleAndButtons),
///     ],
///   ),
/// )
/// ```
///
/// If you nest a [PerspectiveLayer] inside another [PerspectiveLayer], only
/// the additional Z offset is applied to the inner one — the outer layer
/// already applied the perspective + rotation, so re-applying them would
/// double-stack the transform.
class PerspectiveLayer extends StatelessWidget {
  /// Creates a perspective layer.
  const PerspectiveLayer({
    required this.child,
    super.key,
    this.elevation = 0,
    this.alignment = Alignment.center,
  });

  /// Z-axis height of this layer.
  ///
  /// Higher values float closer to the camera, producing a larger parallax
  /// offset when the parent space tilts. Negative values push the layer
  /// behind the base plane.
  final double elevation;

  /// Anchor point for the underlying `Transform`.
  ///
  /// Defaults to [Alignment.center].
  final Alignment alignment;

  /// Subtree to render inside this layer.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = PerspectiveData.maybeOf(context);
    if (data == null) return child;

    final nested = PerspectiveLayerScope.exists(context);

    final Matrix4 matrix;
    if (nested) {
      // Inner layer: just contribute parallax offset + Z depth growth.
      // While the space is static (rotation ~= 0) Z stays 0 so we don't
      // double-scale the layer; as rotation grows we lift the layer along Z
      // up to its full elevation at 90°.
      final rotMag = math
          .sqrt(data.rotateX * data.rotateX + data.rotateY * data.rotateY)
          .clamp(0.0, 1.0);
      matrix = Matrix4.identity()
        ..translateByDouble(
          -data.rotateY * elevation,
          data.rotateX * elevation,
          -elevation * rotMag,
          1,
        );
    } else {
      // Outermost layer: own the full perspective + rotation + Z stack.
      matrix = Matrix4.identity()
        ..setEntry(3, 2, data.perspective)
        ..rotateX(data.rotateX)
        ..rotateY(data.rotateY)
        ..translateByDouble(0, 0, -elevation, 1);
    }

    return Transform(
      transform: matrix,
      alignment: alignment,
      child: PerspectiveLayerScope(child: child),
    );
  }
}
