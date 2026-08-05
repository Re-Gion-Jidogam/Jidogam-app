import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';

/// 지도 시트 상단 검색바 (표시 전용, 탭 시 검색 진입 예정).
class MapSearchField extends StatelessWidget {
  const MapSearchField({super.key, required this.hint, this.onTap});

  final String hint;
  final VoidCallback? onTap;

  static const Color _placeholder = Color(0xFF808080);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xCCFFFFFF),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFF2F4ED)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            AppSvg(AppIcons.search, size: 18, color: _placeholder),
            const SizedBox(width: 8),
            Text(
              hint,
              style: AppTextStyles.fieldTrailing.copyWith(color: _placeholder),
            ),
          ],
        ),
      ),
    );
  }
}
