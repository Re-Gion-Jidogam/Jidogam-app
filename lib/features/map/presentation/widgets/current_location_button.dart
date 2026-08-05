import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 현위치로 이동 버튼 (우하단, 지도 위).
class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppColors.commonShadow,
        ),
        child: const Icon(
          Icons.my_location,
          size: 22,
          color: AppColors.sheetTitle,
        ),
      ),
    );
  }
}
