import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perspective_space/perspective_space.dart';

import '../theme/demo_palette.dart';

/// Demo 3 — one-shot entry shake.
class ShakeEntryDemo extends StatefulWidget {
  const ShakeEntryDemo({super.key, this.autoPlay = false});

  final bool autoPlay;

  static const String title = 'Entry shake';
  static const String description =
      'Plays a one-shot 3D flip-and-settle when the widget appears.';

  @override
  State<ShakeEntryDemo> createState() => _ShakeEntryDemoState();
}

class _ShakeEntryDemoState extends State<ShakeEntryDemo> {
  // Keyed remount restarts the shake every 2.4 seconds, both for interactive
  // play and for screen capture.
  int _seed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 2400),
      (_) {
        if (!mounted) return;
        setState(() => _seed++);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PerspectiveShakeEntry(
      key: ValueKey<int>(_seed),
      child: _Card(seed: _seed),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 340,
      decoration: BoxDecoration(
        gradient: DemoPalette.sunset,
        borderRadius: BorderRadius.circular(28),
        boxShadow: DemoPalette.glow(DemoPalette.accentPink, blur: 56),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.celebration, size: 72, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'YOU GOT IT',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '#${seed.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
