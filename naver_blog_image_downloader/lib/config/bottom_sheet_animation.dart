import 'package:flutter/material.dart';

/// 平台特定的 modal bottom sheet 動畫配置。
abstract final class BottomSheetAnimation {
  /// 建立平台特定的 AnimationController，用於 showModalBottomSheet 的
  /// transitionAnimationController 參數。
  static AnimationController createController({
    required TickerProvider vsync,
    required TargetPlatform platform,
  }) {
    final (duration, reverseDuration) = switch (platform) {
      TargetPlatform.iOS => (
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 350),
      ),
      _ => (
        const Duration(milliseconds: 400),
        const Duration(milliseconds: 250),
      ),
    };

    return AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
    );
  }
}
