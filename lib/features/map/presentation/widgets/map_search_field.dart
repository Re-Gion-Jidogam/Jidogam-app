import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';

/// 지도 시트 상단 검색바 (표시 전용, 탭 시 검색 진입 예정).
///
/// [onClose]를 주면(가이드북 브라우징 화면의 "검색" 진입처럼, 이미 검색
/// 상태로 들어온 화면에서) 오른쪽에 닫기(X) 버튼이 붙는다 — 실제 검색
/// 기능은 아직 없어서, 탭하면 그냥 이 검색 화면을 벗어난다.
class MapSearchField extends StatelessWidget {
  const MapSearchField({
    super.key,
    required this.hint,
    this.onTap,
    this.onClose,
  });

  final String hint;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  static const Color _placeholder = Color(0xFF808080);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(27, 15, onClose == null ? 27 : 15, 15),
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
            Expanded(
              child: Text(
                hint,
                style: AppTextStyles.fieldTrailing.copyWith(color: _placeholder),
              ),
            ),
            if (onClose != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.close, size: 12, color: AppColors.sheetTitle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
