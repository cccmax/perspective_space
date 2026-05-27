import 'dart:async';

import 'package:flutter/widgets.dart';

import '../perspective_layer.dart';
import '../perspective_space.dart';

/// Plays a one-shot 3D shake when the widget first appears.
///
/// Useful for highlighting newly inserted content — a freshly delivered
/// reward, a just-saved card, the first item in a list.
///
/// ```dart
/// PerspectiveShakeEntry(
///   delay: Duration(milliseconds: 200),
///   child: RewardCard(...),
/// )
/// ```
///
/// Internally wraps a [PerspectiveSpace] with `entryShake: true` plus a
/// single [PerspectiveLayer]. After the shake finishes, the widget settles
/// at rest and stops consuming animation frames.
class PerspectiveShakeEntry extends StatefulWidget {
  /// Creates a one-shot shake-on-entry wrapper.
  const PerspectiveShakeEntry({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.elevation = 50,
    this.perspective = 0.0015,
  });

  /// Wait time before the shake starts.
  final Duration delay;

  /// Z-axis height of the layer that hosts [child].
  final double elevation;

  /// Perspective strength, forwarded to [PerspectiveSpace.perspective].
  final double perspective;

  /// Subtree to shake.
  final Widget child;

  @override
  State<PerspectiveShakeEntry> createState() => _PerspectiveShakeEntryState();
}

class _PerspectiveShakeEntryState extends State<PerspectiveShakeEntry> {
  final PerspectiveSpaceController _controller = PerspectiveSpaceController();
  Timer? _delayTimer;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _ready = true;
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (!mounted) return;
        setState(() => _ready = true);
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PerspectiveSpace(
      perspective: widget.perspective,
      entryShake: _ready,
      controller: _controller,
      child: PerspectiveLayer(
        elevation: widget.elevation,
        child: widget.child,
      ),
    );
  }
}
