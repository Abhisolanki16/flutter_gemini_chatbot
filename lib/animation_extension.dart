import 'dart:ui';

import 'package:flutter/material.dart';

// 🌟 Base Extension for Animations
extension AnimateX on Widget {
  // ⭐ Fade Animation
  Widget fade({required Animation<double> anim}) =>
      FadeTransition(opacity: anim, child: this);

  // ⭐ Scale Animation
  Widget scale({
    required Animation<double> anim,
    Alignment alignment = Alignment.center,
  }) => ScaleTransition(alignment: alignment, scale: anim, child: this);

  // ⭐ Rotation Animation
  Widget rotate({
    required Animation<double> anim,
    Alignment alignment = Alignment.center,
  }) => RotationTransition(turns: anim, alignment: alignment, child: this);

  // ⭐ Slide Animation
  Widget slide({required Animation<Offset> anim}) =>
      SlideTransition(position: anim, child: this);

  // ⭐ Size Animation (Height/Width)
  Widget animatedSize({
    Key? key,
    Alignment alignment = Alignment.topCenter,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) => AnimatedSize(
    key: key,
    alignment: alignment,
    duration: duration,
    curve: curve,
    child: this,
  );

  // ⭐ Animated Opacity (Implicit)
  Widget animatedOpacity({
    required double value,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) => AnimatedOpacity(
    opacity: value,
    duration: duration,
    curve: curve,
    child: this,
  );

  // ⭐ Animated Padding (Implicit)
  Widget animatedPadding({
    required EdgeInsets padding,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) => AnimatedPadding(
    padding: padding,
    duration: duration,
    curve: curve,
    child: this,
  );

  // ⭐ Animated Align (Implicit)
  Widget animatedAlign({
    required Alignment alignment,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) => AnimatedAlign(
    alignment: alignment,
    duration: duration,
    curve: curve,
    child: this,
  );

  // ⭐ Animated Container (Implicit)
  Widget animatedContainer({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    BoxConstraints? constraints,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxDecoration? boxDecoration,
  }) => AnimatedContainer(
    duration: duration,
    curve: curve,
    alignment: alignment,
    padding: padding,
    constraints: constraints,
    decoration: decoration ?? boxDecoration,
    width: width,
    height: height,
    foregroundDecoration: foregroundDecoration,
    child: this,
  );

  // ⭐ Blur Animation (Implicit)
  /// Use opacity animation outside for fade blur
  Widget blur({
    required double sigma,
    Duration duration = const Duration(milliseconds: 300),
  }) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: sigma),
    duration: duration,
    builder:
        (context, val, _) => ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: val, sigmaY: val),
            child: this,
          ),
        ),
  );

  // ⭐ Shake Animation (Explicit)
  Widget shake({required AnimationController controller, double offset = 8}) {
    final animation = Tween(
      begin: 0.0,
      end: offset,
    ).chain(CurveTween(curve: Curves.elasticIn));

    return AnimatedBuilder(
      animation: controller,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(animation.evaluate(controller), 0),
            child: this,
          ),
    );
  }

  // ⭐ Expand Animation (Height)
  Widget expandY({required Animation<double> anim}) => SizeTransition(
    axisAlignment: 1,
    sizeFactor: anim,
    axis: Axis.vertical,
    child: this,
  );

  // ⭐ Expand Animation (Width)
  Widget expandX({required Animation<double> anim}) => SizeTransition(
    axisAlignment: 1,
    sizeFactor: anim,
    axis: Axis.horizontal,
    child: this,
  );
}

// 🌟 Animation Controller Helper
extension ControllerX on AnimationController {
  Animation<double> curved({Curve curve = Curves.easeInOut}) =>
      CurvedAnimation(parent: this, curve: curve);

  Animation<Offset> slideTween({
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) => Tween<Offset>(
    begin: begin,
    end: end,
  ).animate(CurvedAnimation(parent: this, curve: curve));
}
