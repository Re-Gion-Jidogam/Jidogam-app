import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 입력 필드 상태 — 테두리·헬퍼 색을 결정.
enum FieldStatus { normal, valid, error }

/// 지도감 공용 텍스트 입력 필드.
///
/// 흰 배경·라운드12·높이54 박스 + (선택)우측 트레일링(카운터/타이머/상태라벨)
/// 아래에 상태별 헬퍼 텍스트를 배치한다.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.focusNode,
    this.status = FieldStatus.normal,
    this.helper,
    this.maxLength,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final FieldStatus status;

  /// 박스 아래 헬퍼/에러 문구.
  final String? helper;

  /// 글자 수 카운터 상한. [trailing]이 없을 때만 노출.
  final int? maxLength;

  /// 우측 커스텀 위젯(예: `인증완료`, `03:47`). [maxLength] 카운터보다 우선.
  final Widget? trailing;

  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {}); // 카운터 갱신
  }

  Color get _borderColor => switch (widget.status) {
        FieldStatus.error => AppColors.fieldError,
        FieldStatus.valid => AppColors.fieldFocus,
        FieldStatus.normal => AppColors.border,
      };

  Color get _helperColor => switch (widget.status) {
        FieldStatus.error => AppColors.errorText,
        FieldStatus.valid => AppColors.primary400,
        FieldStatus.normal => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    Widget? trailing = widget.trailing;
    if (trailing == null && widget.maxLength != null) {
      trailing = Text(
        '${widget.controller.text.characters.length}/${widget.maxLength}',
        style: AppTextStyles.fieldTrailing,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLength: widget.maxLength,
                  cursorColor: AppColors.primary400,
                  style: AppTextStyles.field,
                  buildCounter: (_,
                          {required int currentLength,
                          required bool isFocused,
                          int? maxLength}) =>
                      null, // 카운터는 trailing으로 직접 표시
                  decoration: InputDecoration.collapsed(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.fieldHint,
                  ).copyWith(isDense: true),
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ),
        if (widget.helper != null && widget.helper!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.helper!,
              style: AppTextStyles.helper.copyWith(color: _helperColor),
            ),
          ),
        ],
      ],
    );
  }
}
