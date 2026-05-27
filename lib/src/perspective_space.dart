import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'perspective_data.dart';

/// Imperative handle for a [PerspectiveSpace].
///
/// Attach a controller to drive the entry shake from outside the widget
/// subtree (for example, from a button press handler):
///
/// ```dart
/// final controller = PerspectiveSpaceController();
///
/// PerspectiveSpace(
///   controller: controller,
///   child: ...,
/// );
///
/// // Later:
/// controller.shake();
/// ```
///
/// A controller can only be attached to one [PerspectiveSpace] at a time.
class PerspectiveSpaceController {
  VoidCallback? _onShake;

  void _attach(VoidCallback onShake) {
    _onShake = onShake;
  }

  void _detach(VoidCallback onShake) {
    if (identical(_onShake, onShake)) {
      _onShake = null;
    }
  }

  /// Triggers the entry-shake animation on the attached space.
  ///
  /// Safe to call when no space is attached — the call is silently ignored.
  void shake() => _onShake?.call();
}

/// A 3D perspective container.
///
/// [PerspectiveSpace] is the root of a perspective hierarchy. It declares a
/// shared rotation and perspective strength that descendant
/// [PerspectiveLayer]s read to compute their own 3D transform.
///
/// On its own, `PerspectiveSpace` does not draw anything — it simply
/// publishes rotation values. Wrap a [Stack] (or any other layout) full of
/// [PerspectiveLayer]s to see the effect.
///
/// ```dart
/// PerspectiveSpace(
///   rotateX: 0.05,
///   rotateY: -0.08,
///   enableGesture: true,
///   child: Stack(
///     children: [
///       PerspectiveLayer(elevation: 0,  child: background),
///       PerspectiveLayer(elevation: 40, child: card),
///       PerspectiveLayer(elevation: 90, child: content),
///     ],
///   ),
/// )
/// ```
class PerspectiveSpace extends StatefulWidget {
  /// Creates a perspective container.
  const PerspectiveSpace({
    required this.child,
    super.key,
    this.rotateX = 0,
    this.rotateY = 0,
    this.perspective = 0.0015,
    this.enableGesture = false,
    this.sensitivity = 0.005,
    this.maxRotation = 60,
    this.resetOnRelease = true,
    this.resetDuration = const Duration(milliseconds: 800),
    this.resetCurve = Curves.elasticOut,
    this.entryShake = false,
    this.controller,
  })  : assert(perspective > 0, 'perspective must be positive'),
        assert(sensitivity >= 0, 'sensitivity cannot be negative'),
        assert(maxRotation >= 0, 'maxRotation cannot be negative');

  /// Rotation around the X axis, in radians.
  ///
  /// Positive values tilt the top of the scene away from the viewer; negative
  /// values tilt the bottom away.
  final double rotateX;

  /// Rotation around the Y axis, in radians.
  ///
  /// Positive values push the left edge away from the viewer; negative
  /// values push the right edge away.
  final double rotateY;

  /// Perspective strength.
  ///
  /// This is equivalent to `1 / cameraDistance`. Recommended range:
  /// `0.001`–`0.002`.
  /// - `0.002` ≈ camera 500 logical pixels away (strong foreshortening).
  /// - `0.001` ≈ camera 1000 logical pixels away (subtle foreshortening).
  ///
  /// Conceptually identical to CSS `perspective: 500px`.
  final double perspective;

  /// If true, dragging on the space updates [rotateX] / [rotateY] in real
  /// time.
  final bool enableGesture;

  /// Drag sensitivity, in radians per logical pixel.
  ///
  /// Higher values produce faster rotation. Defaults to `0.005`.
  final double sensitivity;

  /// Maximum rotation, in degrees, that the gesture can reach.
  ///
  /// Prevents the scene from flipping past a useful range.
  final double maxRotation;

  /// If true, the rotation springs back to the configured ([rotateX],
  /// [rotateY]) when the pointer is released.
  final bool resetOnRelease;

  /// Duration of the spring-back animation.
  final Duration resetDuration;

  /// Curve of the spring-back animation.
  ///
  /// Defaults to [Curves.elasticOut] for a tactile, bouncy feel.
  final Curve resetCurve;

  /// If true, the space plays an entry shake when it first mounts.
  final bool entryShake;

  /// Optional controller for triggering a shake imperatively.
  final PerspectiveSpaceController? controller;

  /// Subtree to render inside the perspective space.
  final Widget child;

  /// Triggers a one-shot shake on the nearest [PerspectiveSpace] ancestor.
  ///
  /// Falls back silently if no ancestor exists.
  static void shakeOf(BuildContext context) {
    context.findAncestorStateOfType<_PerspectiveSpaceState>()?.shake();
  }

  @override
  State<PerspectiveSpace> createState() => _PerspectiveSpaceState();
}

class _PerspectiveSpaceState extends State<PerspectiveSpace>
    with TickerProviderStateMixin {
  late double _rotateX;
  late double _rotateY;
  AnimationController? _resetController;
  AnimationController? _shakeController;
  double _startX = 0;
  double _startY = 0;

  @override
  void initState() {
    super.initState();
    _rotateX = widget.rotateX;
    _rotateY = widget.rotateY;
    widget.controller?._attach(shake);
    if (widget.entryShake) {
      _startEntryShake();
    }
  }

  @override
  void didUpdateWidget(PerspectiveSpace old) {
    super.didUpdateWidget(old);
    if (!identical(old.controller, widget.controller)) {
      old.controller?._detach(shake);
      widget.controller?._attach(shake);
    }
    if (!widget.enableGesture) {
      _rotateX = widget.rotateX;
      _rotateY = widget.rotateY;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(shake);
    _resetController?.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  /// Public hook used by both [PerspectiveSpaceController] and
  /// [PerspectiveSpace.shakeOf].
  void shake() => _startEntryShake();

  void _startEntryShake() {
    _shakeController?.dispose();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // Y-axis flip-in: starts at ~25° from one side, oscillates back to 0.
    const amp = 0.35;
    final shakeAnim = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -amp, end: amp * 0.35),
        weight: 3,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: amp * 0.35, end: -amp * 0.12),
        weight: 2.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -amp * 0.12, end: amp * 0.03),
        weight: 2,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: amp * 0.03, end: 0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.easeOutCubic),
    );

    shakeAnim.addListener(() {
      if (!mounted) return;
      setState(() {
        _rotateY = widget.rotateY + shakeAnim.value;
        _rotateX = widget.rotateX + shakeAnim.value * 0.15;
      });
    });
    _shakeController!.forward();
  }

  void _startResetAnimation() {
    _resetController?.dispose();
    _resetController = null;
    _startX = _rotateX;
    _startY = _rotateY;
    _resetController = AnimationController(
      duration: widget.resetDuration,
      vsync: this,
    )..addListener(() {
        final t = widget.resetCurve.transform(_resetController!.value);
        if (!mounted) return;
        setState(() {
          _rotateX = _startX + (widget.rotateX - _startX) * t;
          _rotateY = _startY + (widget.rotateY - _startY) * t;
        });
      });
    _resetController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = PerspectiveData(
      rotateX: _rotateX,
      rotateY: _rotateY,
      perspective: widget.perspective,
      child: widget.child,
    );

    if (widget.enableGesture) {
      child = GestureDetector(
        onPanUpdate: (details) {
          _resetController?.stop();
          setState(() {
            _rotateY -= details.delta.dx * widget.sensitivity;
            _rotateX += details.delta.dy * widget.sensitivity;
            final maxRad = widget.maxRotation * math.pi / 180;
            _rotateX = _rotateX.clamp(-maxRad, maxRad);
            _rotateY = _rotateY.clamp(-maxRad, maxRad);
          });
        },
        onPanEnd: (_) {
          if (widget.resetOnRelease) {
            _startResetAnimation();
          }
        },
        child: child,
      );
    }

    return child;
  }
}
