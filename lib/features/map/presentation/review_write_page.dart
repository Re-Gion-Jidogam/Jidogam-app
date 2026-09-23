import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/primary_button.dart';
import 'widgets/stamp_dialogs.dart';

/// 리뷰쓰기 입력값(별점·본문).
class ReviewDraft {
  const ReviewDraft({required this.rating, required this.content});

  final int rating;
  final String content;
}

/// 리뷰 본문 최대 글자 수.
const int reviewMaxLength = 200;

/// 본문 입력 박스 고정 높이.
const double _textBoxHeight = 200;

/// 리뷰쓰기 화면. "등록"하면 [ReviewDraft], 나가면 null로 pop한다.
/// 입력이 있으면 뒤로가기 시 이탈 확인 다이얼로그를 띄운다.
class ReviewWritePage extends StatefulWidget {
  const ReviewWritePage({super.key, required this.guidebookTitle});

  final String guidebookTitle;

  @override
  State<ReviewWritePage> createState() => _ReviewWritePageState();
}

class _ReviewWritePageState extends State<ReviewWritePage> {
  final TextEditingController _controller = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasInput => _rating > 0 || _controller.text.trim().isNotEmpty;

  bool get _canSubmit => _rating > 0 && _controller.text.trim().isNotEmpty;

  void _submit() {
    // pop은 PopScope와 무관하게 닫힌다.
    Navigator.of(context).pop(
      ReviewDraft(rating: _rating, content: _controller.text.trim()),
    );
  }

  Future<void> _confirmDiscardAndPop() async {
    final NavigatorState navigator = Navigator.of(context);
    final bool discard = await showReviewDiscardDialog(context);
    if (discard) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasInput,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;
        _confirmDiscardAndPop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(onBack: () => Navigator.of(context).maybePop()),
              // 입력 영역은 스크롤, "등록" 버튼은 하단 고정.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.guidebookTitle,
                        style: AppTextStyles.placeTitle14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '가이드북은 어떠셨나요?',
                        style: AppTextStyles.bannerSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _StarRatingInput(
                        rating: _rating,
                        onChanged: (int r) => setState(() => _rating = r),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: _textBoxHeight,
                        child: _ReviewTextBox(controller: _controller),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: PrimaryButton(
                  label: '등록',
                  onPressed: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 뒤로가기 + "리뷰쓰기" 타이틀 헤더.
class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // 전체 폭을 줘야 뒤로가기 버튼이 타이틀과 겹치지 않는다.
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Text('리뷰쓰기', style: AppTextStyles.title18),
          Positioned(
            left: 4,
            child: GestureDetector(
              key: const ValueKey<String>('review-write-back'),
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 탭으로 고르는 별점(1~5).
class _StarRatingInput extends StatelessWidget {
  const _StarRatingInput({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            key: ValueKey<String>('review-star-$i'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppSvg(
                AppIcons.star,
                size: 36,
                color: i <= rating ? AppColors.primary300 : AppColors.gray400,
              ),
            ),
          ),
      ],
    );
  }
}

/// 여러 줄 본문 입력 박스 + 글자 수 카운터.
class _ReviewTextBox extends StatelessWidget {
  const _ReviewTextBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: reviewMaxLength,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              cursorColor: AppColors.primary400,
              style: AppTextStyles.field,
              buildCounter: (_,
                      {required int currentLength,
                      required bool isFocused,
                      int? maxLength}) =>
                  null, // 카운터는 아래에 직접 표시
              decoration: const InputDecoration.collapsed(
                hintText: '다른 여행자에게 도움이 되는 리뷰를 남겨주세요.',
              ).copyWith(
                hintStyle: AppTextStyles.fieldHint,
                hintMaxLines: 3,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller.text.characters.length}/$reviewMaxLength',
              style: AppTextStyles.fieldTrailing,
            ),
          ),
        ],
      ),
    );
  }
}
