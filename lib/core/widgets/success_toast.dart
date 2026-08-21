import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 성공 알림 토스트(Figma `toast`) — 화면 상단 중앙에 잠깐 떴다 사라진다.
/// 다이얼로그와 달리 응답을 기다리지 않는 액션(도장찍기/도장 지우기 확정
/// 직후 등)의 결과를 짧게 알려줄 때 쓴다.
///
/// 메시지는 [emphasis](장소명처럼 길이가 들쭉날쭉한 부분) + [suffix](고정
/// 문구, 예: "에 도장을 찍었어요")로 나눠 받는다. 좁은 화면에서 다 안
/// 들어가면 [suffix]는 항상 그대로 두고 [emphasis]만 말줄임한다 — 반대로
/// 하나의 문자열을 통째로 말줄임하면 정작 어떤 액션이었는지 알려주는
/// [suffix]가 잘려나가서 안 된다.
void showSuccessToast(
  BuildContext context, {
  required String emphasis,
  required String suffix,
}) {
  final OverlayState overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _SuccessToastOverlay(
      emphasis: emphasis,
      suffix: suffix,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _SuccessToastOverlay extends StatefulWidget {
  const _SuccessToastOverlay({
    required this.emphasis,
    required this.suffix,
    required this.onDone,
  });

  final String emphasis;
  final String suffix;
  final VoidCallback onDone;

  @override
  State<_SuccessToastOverlay> createState() => _SuccessToastOverlayState();
}

class _SuccessToastOverlayState extends State<_SuccessToastOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // 삽입된 첫 프레임에 바로 opacity 1로 시작하면 AnimatedOpacity가
    // 페이드인을 그릴 기회가 없다 — 한 프레임 미뤄서 켠다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    Future<void>.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _visible = false);
    });
    Future<void>.delayed(const Duration(milliseconds: 2300), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: _SuccessToast(
              emphasis: widget.emphasis,
              suffix: widget.suffix,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessToast extends StatelessWidget {
  const _SuccessToast({required this.emphasis, required this.suffix});

  final String emphasis;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 311),
      child: Container(
        height: 64,
        padding: const EdgeInsets.fromLTRB(16, 12, 32, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          // Figma gray/50(#F5F5F5) — AppColors.background와 같은 값이라
          // 별도 토큰을 늘리지 않고 재사용한다.
          border: Border.all(color: AppColors.background),
          boxShadow: AppColors.commonShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary300, width: 2),
              ),
              child: const Icon(
                Icons.check,
                size: 18,
                color: AppColors.primary300,
              ),
            ),
            const SizedBox(width: 20),
            // 바깥 Flexible로 (emphasis+suffix) 전체를 토스트 너비에 맞게
            // 줄이고, 그 안에서 다시 emphasis만 Flexible로 줘서 suffix보다
            // 먼저 줄어들게 한다 — suffix는 항상 통째로 보인다.
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      emphasis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.field,
                    ),
                  ),
                  Text(suffix, maxLines: 1, style: AppTextStyles.field),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
