import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 테마. 색상·폰트 토큰을 Material 테마에 연결한다.
abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary400,
      primary: AppColors.primary400,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      splashFactory: NoSplashFactory.instance,
      highlightColor: Colors.transparent,
    );
  }
}

/// 리스트/카드 탭 시 잉크 스플래시를 제거하기 위한 팩토리.
class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory._();
  static const NoSplashFactory instance = NoSplashFactory._();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return NoSplash.splashFactory.create(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      textDirection: textDirection,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
    );
  }
}
