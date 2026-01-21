import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/animation_extension.dart';

class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({Key? key}) : super(key: key);

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> fadeAnim;
  late Animation<double> scaleAnim;
  late Animation<double> rotateAnim;
  late Animation<Offset> slideAnim;
  late Animation<double> expandAnim;

  bool expanded = false;
  bool visible = true;
  Alignment alignment = Alignment.center;
  EdgeInsets padding = const EdgeInsets.all(8);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    fadeAnim = Tween(begin: 0.0, end: 1.0).animate(_controller);
    scaleAnim = Tween(begin: 0.7, end: 1.0).animate(_controller);
    rotateAnim = _controller.curved();
    slideAnim = _controller.slideTween();
    expandAnim = _controller.curved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ultimate Animation Demo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "🔥 Explicit Animations",
              style: TextStyle(fontSize: 18),
            ),

            // ⭐ Fade Animation
            Container(
              height: 50,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  "Fade Animation",
                  style: TextStyle(color: Colors.white),
                ),
              ).fade(anim: fadeAnim),
            ),
            const SizedBox(height: 16),

            // ⭐ Slide Animation
            Container(
              height: 50,
              color: Colors.green,
              child: const Center(
                child: Text(
                  "Slide Animation",
                  style: TextStyle(color: Colors.white),
                ),
              ).slide(anim: slideAnim),
            ),
            const SizedBox(height: 16),

            // ⭐ Scale Animation
            Container(
              height: 50,
              color: Colors.orange,
              child: const Center(
                child: Text(
                  "Scale Animation",
                  style: TextStyle(color: Colors.white),
                ),
              ).scale(anim: scaleAnim),
            ),
            const SizedBox(height: 16),

            // ⭐ Rotate Animation
            Container(
              height: 50,
              color: Colors.purple,
              child: const Center(
                child: Text(
                  "Rotate Animation",
                  style: TextStyle(color: Colors.white),
                ),
              ).rotate(anim: rotateAnim),
            ),
            const SizedBox(height: 16),

            // ⭐ ExpandY Animation
            Container(
              color: Colors.red,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: const Text(
                  "Expand Y Animation",
                  style: TextStyle(color: Colors.white),
                ),
              ).expandY(anim: expandAnim),
            ),
            const SizedBox(height: 16),

            const Divider(),
            const Text(
              "🎯 Implicit Animations",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            // ⭐ Animated Opacity Toggle
            SwitchListTile(
              value: visible,
              title: const Text("Toggle Opacity"),
              onChanged: (v) => setState(() => visible = v),
            ),
            Container(
              height: 50,
              color: Colors.blueGrey,
              child: const Center(
                child: Text(
                  "Implicit Opacity",
                  style: TextStyle(color: Colors.white),
                ),
              ).animatedOpacity(value: visible ? 1 : 0),
            ),
            const SizedBox(height: 16),

            // ⭐ Animated Size demo
            ElevatedButton(
              onPressed: () => setState(() => expanded = !expanded),
              child: const Text("Toggle Expand"),
            ),
            Container(
              color: Colors.teal,
              child:
                  Container(
                    height: expanded ? 140 : 60,
                    alignment: Alignment.center,
                    child: const Text(
                      "Implicit Animated Size",
                      style: TextStyle(color: Colors.white),
                    ),
                  ).animatedSize(),
            ),
            const SizedBox(height: 16),

            // ⭐ Animated Align demo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      () => setState(() => alignment = Alignment.centerLeft),
                  child: const Text("Left"),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed:
                      () => setState(() => alignment = Alignment.centerRight),
                  child: const Text("Right"),
                ),
              ],
            ),
            Container(
              height: 80,
              color: Colors.indigo,
              child: const Text(
                "Animated Align",
                style: TextStyle(color: Colors.white),
              ).animatedAlign(alignment: alignment),
            ),
            const SizedBox(height: 16),

            // ⭐ Animated Padding demo
            Slider(
              min: 8,
              max: 40,
              value: padding.left.toDouble(),
              onChanged: (v) => setState(() => padding = EdgeInsets.all(v)),
            ),
            Container(
              height: 70,
              color: Colors.brown,
              child: const Center(
                child: Text(
                  "Animated Padding",
                  style: TextStyle(color: Colors.white),
                ),
              ).animatedPadding(padding: padding),
            ),
            const SizedBox(height: 16),

            // ⭐ AnimatedContainer demo
            Container(child: AnimatedContainerBox(isBig: expanded)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AnimatedContainerBox extends StatelessWidget {
  final bool isBig;
  const AnimatedContainerBox({super.key, required this.isBig});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
    ).animatedContainer(
      width: isBig ? 200 : 100,
      height: isBig ? 200 : 100,
      color: isBig ? Colors.deepOrange : Colors.deepPurple,
      curve: Curves.easeInOutBack,
    );
  }
}
