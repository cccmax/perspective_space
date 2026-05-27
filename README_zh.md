# perspective_space

> 给 Flutter 加 3D 透视与多层视差的轻量组件 —— 倾斜、抖动、堆叠，
> 支持手势驱动或自动播放。

[![pub package](https://img.shields.io/pub/v/perspective_space.svg)](https://pub.dev/packages/perspective_space)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.10-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue)](#%E5%B9%B3%E5%8F%B0%E6%94%AF%E6%8C%81)

<p align="center">
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/basic_tilt.webp" width="160" alt="基础倾斜"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/gesture.webp"    width="160" alt="手势倾斜"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/shake.webp"      width="160" alt="入场抖动"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/parallax.webp"   width="160" alt="多层视差"/>
  <img src="https://raw.githubusercontent.com/cccmax/perspective_space/main/screenshots/dialog.webp"     width="160" alt="对话框"/>
</p>

两个基础组件 + 三个预设，**零第三方依赖**，6 大平台全支持。

[English →](README.md)

---

## 特性

- **`PerspectiveSpace`** + **`PerspectiveLayer`** —— 一对儿基础组件，
  父级声明共享的旋转/透视，子层各自按 `elevation` 算自己的视差偏移。
- **手势倾斜** —— 拖动旋转，灵敏度可调，最大角度可限，松手弹簧回位。
- **入场抖动** —— widget 首次挂载时做一次 3D 翻转 + 衰减摆动。
- **三个开箱即用的预设**：
  - `PerspectiveTiltCard` —— 单卡片倾斜，一行搞定。
  - `PerspectiveParallax`   —— 多层视差堆叠，从 list 构造。
  - `PerspectiveShakeEntry` —— 包一层，自动播抖动。
- **控制器** —— 在子树外触发抖动。
- **零依赖**，纯 Dart + Flutter SDK。

## 安装

```yaml
dependencies:
  perspective_space: ^0.1.0
```

或者：

```bash
flutter pub add perspective_space
```

## 快速上手

### 一个会倾斜的卡片

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

直接在任何 Flutter 平台拖它，无胶水代码。

### 多层视差

```dart
PerspectiveParallax(
  layers: [
    PerspectiveLayerSpec(elevation: 0,  child: 背景),
    PerspectiveLayerSpec(elevation: 40, child: 中间卡片),
    PerspectiveLayerSpec(elevation: 90, child: 前景内容),
  ],
)
```

`elevation` 越大，离相机越近，倾斜时视差偏移越明显。

### 入场抖动

```dart
PerspectiveShakeEntry(
  delay: const Duration(milliseconds: 200),
  child: 你的卡片,
)
```

### 直接用基础组件

预设不够用时，掉到基础组件层自己组合：

```dart
PerspectiveSpace(
  enableGesture: true,
  maxRotation: 30,
  child: Stack(
    children: [
      PerspectiveLayer(elevation: 0,  child: 背景),
      PerspectiveLayer(elevation: 50, child: 卡片),
      PerspectiveLayer(elevation: 90, child: 内容),
    ],
  ),
);
```

### 主动触发抖动

```dart
final controller = PerspectiveSpaceController();

PerspectiveSpace(
  controller: controller,
  child: ...,
);

// 任意时机：
controller.shake();
```

## API 速览

| Widget | 用途 |
| --- | --- |
| `PerspectiveSpace` | 根容器，发布旋转 + 透视到子树。 |
| `PerspectiveLayer` | 子层，按 `elevation` 应用深度感变换。 |
| `PerspectiveSpaceController` | 控制器（`controller.shake()`）。 |
| `PerspectiveTiltCard` | 预设：单卡片倾斜。 |
| `PerspectiveParallax` | 预设：多层视差堆叠。 |
| `PerspectiveShakeEntry` | 预设：入场抖动一次。 |

### `PerspectiveSpace` 关键参数

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `rotateX` / `rotateY` | `0` | 初始倾斜（弧度）。 |
| `perspective` | `0.0015` | `1 / 相机距离`；越大近大远小越夸张（推荐 `0.001`–`0.002`）。 |
| `enableGesture` | `false` | 拖动倾斜。 |
| `sensitivity` | `0.005` | 每像素拖动对应的旋转弧度。 |
| `maxRotation` | `60` | 手势倾斜的最大角度（度）。 |
| `resetOnRelease` | `true` | 松手回弹到 `(rotateX, rotateY)`。 |
| `resetDuration` | `800ms` | 回弹动画时长。 |
| `resetCurve` | `Curves.elasticOut` | 回弹动画曲线。 |
| `entryShake` | `false` | 首次挂载时做一次 3D 抖动。 |

## 平台支持

| iOS | Android | Web | macOS | Windows | Linux |
| --- | --- | --- | --- | --- | --- |
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

纯 Dart，所有效果都跑在 Flutter 自己的 3D `Transform` 上，没有 plugin
channel 也没有原生代码。

## 常见问题

**Q. `PerspectiveSpace` 和直接用 `Transform` 有啥区别？**
它把旋转向子树发布，让每个 `PerspectiveLayer` 单独按 `elevation` 贡献
自己的 Z 轴偏移。结果是一个统一的透视相机 + 多层独立视差，而不是嵌套
`Transform` 把矩阵反复叠加。

**Q. 嵌套 `PerspectiveLayer` 看起来很弱？**
设计如此 —— 内层只追加视差偏移，不重复施加 perspective + rotation 矩阵。
如果想要更明显的效果，把它提升到和外层同级的 Stack 里，或者调大 `elevation`。

**Q. 入场抖动能改参数吗？**
0.1 版本写死了振幅和时序保证手感统一。需要可调的话欢迎提 PR。

## 示例工程

完整 demo（也就是上面那 5 张 GIF 的来源）在 [`example/`](example/) 目录。
本地跑：

```bash
cd example
flutter run            # 任意平台
```

## 参与贡献

欢迎 issue / PR —— 尤其是新预设、平台专项优化、golden test。跑测试：

```bash
flutter test
cd example && flutter test
```

## 协议

[MIT](LICENSE) © 2026 cccmax。
