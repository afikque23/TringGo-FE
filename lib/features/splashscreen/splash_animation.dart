import 'package:flutter/material.dart';

class SplashAnimation {
  final AnimationController controller;

  late final Animation<double> bounce;

  SplashAnimation({required this.controller}) {
    // Animasi memantul seperti bola basket - 5 pantulan dalam 4.5 detik
    bounce = TweenSequence<double>([
      // Pantulan pertama (paling tinggi)
      TweenSequenceItem(
        tween: Tween(
          begin: -120.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -120.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 8,
      ),
      // Pantulan kedua (tinggi)
      TweenSequenceItem(
        tween: Tween(
          begin: -120.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -90.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 6,
      ),
      // Pantulan ketiga (sedang)
      TweenSequenceItem(
        tween: Tween(
          begin: -90.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 4,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -60.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 4,
      ),
      // Pantulan keempat (kecil)
      TweenSequenceItem(
        tween: Tween(
          begin: -60.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -30.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 2,
      ),
      // Pantulan kelima (sangat kecil)
      TweenSequenceItem(
        tween: Tween(
          begin: -30.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 2,
      ),
      // Diam di posisi 0 selama 2.5 detik
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
    ]).animate(controller);
  }

  void start() {
    controller.forward();
  }

  void dispose() => controller.dispose();
}

mixin SplashAnimationMixin {
  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 7000), // Total 7 detik
    );
  }

  static const Duration delayBeforeNavigation = Duration(milliseconds: 7000);
}
