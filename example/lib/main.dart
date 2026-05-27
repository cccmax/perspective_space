import 'package:flutter/material.dart';

import 'demos/basic_tilt_demo.dart';
import 'demos/dialog_demo.dart';
import 'demos/gesture_demo.dart';
import 'demos/parallax_card_demo.dart';
import 'demos/shake_entry_demo.dart';
import 'theme/demo_palette.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'perspective_space showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: DemoPalette.bg0,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DemoPalette.accentPurple,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        useMaterial3: true,
      ),
      home: const _Home(),
    );
  }
}

class _DemoEntry {
  const _DemoEntry({
    required this.title,
    required this.description,
    required this.build,
    required this.gradient,
  });

  final String title;
  final String description;
  final Widget Function({bool autoPlay}) build;
  final Gradient gradient;
}

final List<_DemoEntry> _demos = <_DemoEntry>[
  _DemoEntry(
    title: BasicTiltDemo.title,
    description: BasicTiltDemo.description,
    build: ({bool autoPlay = false}) => BasicTiltDemo(autoPlay: autoPlay),
    gradient: DemoPalette.pinkPurple,
  ),
  _DemoEntry(
    title: GestureDemo.title,
    description: GestureDemo.description,
    build: ({bool autoPlay = false}) => GestureDemo(autoPlay: autoPlay),
    gradient: DemoPalette.cyanPurple,
  ),
  _DemoEntry(
    title: ShakeEntryDemo.title,
    description: ShakeEntryDemo.description,
    build: ({bool autoPlay = false}) => ShakeEntryDemo(autoPlay: autoPlay),
    gradient: DemoPalette.sunset,
  ),
  _DemoEntry(
    title: ParallaxCardDemo.title,
    description: ParallaxCardDemo.description,
    build: ({bool autoPlay = false}) => ParallaxCardDemo(autoPlay: autoPlay),
    gradient: DemoPalette.pinkPurple,
  ),
  _DemoEntry(
    title: DialogDemo.title,
    description: DialogDemo.description,
    build: ({bool autoPlay = false}) => DialogDemo(autoPlay: autoPlay),
    gradient: DemoPalette.cyanPurple,
  ),
];

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: DemoPalette.bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverToBoxAdapter(child: _Header()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final cols = width > 900
                        ? 3
                        : width > 560
                            ? 2
                            : 1;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.05,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _DemoTile(entry: _demos[i]),
                        childCount: _demos.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: DemoPalette.pinkPurple,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: DemoPalette.glow(DemoPalette.accentPink),
                ),
                child: const Icon(
                  Icons.view_in_ar,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'perspective_space',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '3D perspective + parallax widgets for Flutter.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap any tile to open the full demo.',
            style: TextStyle(fontSize: 13, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.entry});

  final _DemoEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _DemoPage(entry: entry),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 0.78,
                      child: FittedBox(child: entry.build(autoPlay: true)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.entry});

  final _DemoEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: DemoPalette.bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(entry.title),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(child: Center(child: entry.build())),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Text(
                  entry.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
