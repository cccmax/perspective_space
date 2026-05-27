import 'package:flutter/widgets.dart';

/// Inherited data shared by a [PerspectiveSpace] with its descendant
/// [PerspectiveLayer]s.
///
/// This class is intentionally library-private; consumers should never need
/// to touch it directly.
@immutable
class PerspectiveData extends InheritedWidget {
  /// Creates inherited perspective data.
  const PerspectiveData({
    required this.rotateX,
    required this.rotateY,
    required this.perspective,
    required super.child,
    super.key,
  });

  /// Current rotation around the X axis, in radians.
  final double rotateX;

  /// Current rotation around the Y axis, in radians.
  final double rotateY;

  /// Strength of the perspective foreshortening. Equivalent to
  /// `1 / cameraDistance` in CSS perspective.
  final double perspective;

  /// Looks up the nearest [PerspectiveData] ancestor, or `null` if none
  /// exists.
  static PerspectiveData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PerspectiveData>();
  }

  @override
  bool updateShouldNotify(PerspectiveData old) {
    return rotateX != old.rotateX ||
        rotateY != old.rotateY ||
        perspective != old.perspective;
  }
}

/// Marker that signals a [PerspectiveLayer] already sits somewhere above us
/// in the tree. Used to avoid composing two `Transform` matrices on top of
/// each other (which would double-apply perspective).
@immutable
class PerspectiveLayerScope extends InheritedWidget {
  /// Creates the marker.
  const PerspectiveLayerScope({required super.child, super.key});

  /// Returns true if a [PerspectiveLayer] exists in the ancestor chain.
  static bool exists(BuildContext context) {
    return context.getInheritedWidgetOfExactType<PerspectiveLayerScope>() !=
        null;
  }

  @override
  bool updateShouldNotify(PerspectiveLayerScope old) => false;
}
