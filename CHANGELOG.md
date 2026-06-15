# Changelog

## 0.1.2

- Added a pub.dev gallery screenshot (`screenshots/showcase.webp`) so the
  package shows a thumbnail in search results — a statically tilted multi-layer
  parallax card.

## 0.1.1

- Switched README cross-links (`中文文档`, `English`) to absolute GitHub URLs
  so they are clickable on pub.dev (pub.dev does not resolve relative
  markdown links).
- Added a live web demo at <https://cccmax.github.io/perspective_space>,
  auto-deployed via GitHub Actions on every push to `main`.

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
