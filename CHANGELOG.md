# Changelog

## 0.1.0 — initial release

- `PerspectiveSpace` container with shared rotation and perspective.
- `PerspectiveLayer` child with `elevation`-based parallax offset.
- Gesture-driven tilt with configurable sensitivity, clamping, and spring-back.
- Optional entry shake animation with a custom `TweenSequence`.
- `PerspectiveSpaceController` for imperatively triggering shakes.
- Three presets: `PerspectiveTiltCard`, `PerspectiveParallax`,
  `PerspectiveShakeEntry`.
- Zero third-party dependencies. Runs on iOS, Android, Web, macOS, Windows,
  and Linux.
