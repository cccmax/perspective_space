<!-- This README is rendered on pub.dev. All image links must be absolute -->
<!-- (pub.dev rewrites relative paths and breaks them), so raw.githubusercontent -->
<!-- URLs are used throughout. -->

# perspective_space

> Buttery-smooth 3D perspective and parallax widgets for Flutter — tilt,
> shake, and stack layers with depth. Gesture-driven or auto-animated.

[![pub package](https://img.shields.io/pub/v/perspective_space.svg)](https://pub.dev/packages/perspective_space)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.10-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue)](#platform-support)

<p align="center">
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/basic_tilt.webp" width="160" alt="Basic tilt"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/gesture.webp"    width="160" alt="Gesture tilt"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/shake.webp"      width="160" alt="Entry shake"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/parallax.webp"   width="160" alt="Parallax stack"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/dialog.webp"     width="160" alt="Dialog"/>
</p>

`perspective_space` gives you depth on every Flutter platform with two
primitives and three presets — and **zero third-party dependencies**.

🌐 **[Live demo →](https://cccmax.github.io/perspective_space/)** &nbsp;·&nbsp;
[中文文档 →](https://github.com/cccmax/perspective_space/blob/main/README_zh.md)

---

## Features

- **`PerspectiveSpace`** + **`PerspectiveLayer`** — a tiny pair of widgets
  that publish a shared rotation/perspective and let descendant layers
  render with depth-aware parallax.
- **Gesture-driven tilt** — drag to rotate, configurable sensitivity,
  clamped max angle, elastic spring-back on release.
- **Entry shake** — one-shot 3D flip-and-settle when the widget mounts.
- **Presets** for the 90% case:
  - `PerspectiveTiltCard` — single tilting card, one-line setup.
  - `PerspectiveParallax`   — multi-layer parallax stack from a list.
  - `PerspectiveShakeEntry` — wrap any widget, play a shake on entry.
- **Controller** for triggering shakes from outside the subtree.
- **Zero dependencies**, pure Dart + Flutter SDK.

## Install

```yaml
dependencies:
  perspective_space: ^0.1.0
```

```bash
flutter pub add perspective_space
```

## Quick start

### A tilting card

```dart
import 'package:perspective_space/perspective_space.dart';

PerspectiveTiltCard(
  child: Container(
    width: 280,
    height: 360,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF5BAA), Color(0xFF8B5CF6)],
      ),
      borderRadius: BorderRadius.circular(28),
    ),
    alignment: Alignment.center,
    child: const Text('TILT'),
  ),
);
```

Drag it — every Flutter platform, no glue code.

### Multi-layer parallax

```dart
PerspectiveParallax(
  layers: [
    PerspectiveLayerSpec(elevation: 0,  child: backgroundCard),
    PerspectiveLayerSpec(elevation: 40, child: middleCard),
    PerspectiveLayerSpec(elevation: 90, child: foregroundContent),
  ],
)
```

Higher `elevation` = closer to the camera = stronger parallax offset.

### One-shot entry shake

```dart
PerspectiveShakeEntry(
  delay: const Duration(milliseconds: 200),
  child: yourRewardCard,
)
```

### Hand-rolled with the primitives

When you outgrow the presets, drop straight to `PerspectiveSpace` +
`PerspectiveLayer`:

```dart
PerspectiveSpace(
  enableGesture: true,
  maxRotation: 30,
  child: Stack(
    children: [
      PerspectiveLayer(elevation: 0,  child: background),
      PerspectiveLayer(elevation: 50, child: card),
      PerspectiveLayer(elevation: 90, child: content),
    ],
  ),
);
```

### Imperative shake

```dart
final controller = PerspectiveSpaceController();

PerspectiveSpace(
  controller: controller,
  child: ...,
);

// Later, from a button handler:
controller.shake();
```

## API at a glance

| Widget | Purpose |
| --- | --- |
| `PerspectiveSpace` | Root container; publishes rotation + perspective. |
| `PerspectiveLayer` | Child layer; applies a depth-aware transform. |
| `PerspectiveSpaceController` | Imperative handle (`controller.shake()`). |
| `PerspectiveTiltCard` | Preset: a single tilting card. |
| `PerspectiveParallax` | Preset: a parallax stack from `PerspectiveLayerSpec`s. |
| `PerspectiveShakeEntry` | Preset: shake on first mount, then rest. |

### Useful `PerspectiveSpace` parameters

| Parameter | Default | Notes |
| --- | --- | --- |
| `rotateX`, `rotateY` | `0` | Initial tilt, in radians. |
| `perspective` | `0.0015` | `1 / cameraDistance`; bigger = stronger foreshortening (`0.001`–`0.002` is the sweet spot). |
| `enableGesture` | `false` | Drag to tilt in real time. |
| `sensitivity` | `0.005` | Radians per logical pixel of drag. |
| `maxRotation` | `60` | Hard cap on the gesture-driven tilt, in degrees. |
| `resetOnRelease` | `true` | Spring back to `(rotateX, rotateY)` on pointer up. |
| `resetDuration` | `800ms` | Spring-back duration. |
| `resetCurve` | `Curves.elasticOut` | Spring-back curve. |
| `entryShake` | `false` | Play a one-shot shake on first mount. |

## Platform support

| iOS | Android | Web | macOS | Windows | Linux |
| --- | --- | --- | --- | --- | --- |
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

`perspective_space` is pure Dart; everything renders through Flutter's own
3D `Transform`. There are no plugin channels and no native code.

## FAQ

**Q. How does `PerspectiveSpace` differ from a plain `Transform`?**
It publishes its rotation to descendants and lets `PerspectiveLayer`s
contribute their own Z offset. The result is a single, coherent perspective
camera with independent parallax depth per layer — instead of nested
`Transform`s that double-stack matrices.

**Q. Why does my nested `PerspectiveLayer` look subtle?**
By design — an inner `PerspectiveLayer` only contributes additional
parallax offset, never re-applies the perspective + rotation matrices.
Increase its `elevation`, or move it up to the same Stack as the outer
layer if you want a stronger effect.

**Q. Is the entry shake configurable?**
Today the shake amplitude and timing are fixed for snappy feel. PRs
welcome if you need it tunable.

## Example

A full showcase app (the source of the GIFs above) lives in
[`example/`](example/). To run it locally:

```bash
cd example
flutter run            # any platform
```

## Contributing

Issues and PRs welcome — particularly around new presets, platform-specific
tuning, and golden tests. Run the test suite with:

```bash
flutter test
cd example && flutter test
```

## License

[MIT](LICENSE) © 2026 cccmax.
