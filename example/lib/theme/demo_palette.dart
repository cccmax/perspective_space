import 'package:flutter/material.dart';

/// Demo palette — purple→pink→cyan glassmorphism, kept far from any product
/// theme so it reads as a generic "showcase" look.
abstract final class DemoPalette {
  static const Color bg0 = Color(0xFF0B0418);
  static const Color bg1 = Color(0xFF1A0833);
  static const Color bg2 = Color(0xFF2B0E5A);

  static const Color accentPink = Color(0xFFFF5BAA);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF5BE5FF);
  static const Color accentYellow = Color(0xFFFFD96B);

  static const Gradient bg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[bg0, bg1, bg2],
  );

  static const Gradient pinkPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[accentPink, accentPurple],
  );

  static const Gradient cyanPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[accentCyan, accentPurple],
  );

  static const Gradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[accentYellow, accentPink, accentPurple],
  );

  static List<BoxShadow> glow(Color color, {double blur = 32}) => <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.45),
          blurRadius: blur,
          spreadRadius: -4,
          offset: const Offset(0, 12),
        ),
      ];
}
