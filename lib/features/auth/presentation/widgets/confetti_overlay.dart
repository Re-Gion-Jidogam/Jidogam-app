import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';

/// 가입 완료 화면 위로 한 번 재생되는 confetti Lottie.
///
/// 재생이 끝나면 페이드아웃해 잔상이 문구를 가리지 않게 한다. 탭은 통과.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this);
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _finished ? 0 : 1,
        duration: const Duration(milliseconds: 400),
        child: Lottie.asset(
          AppLottie.confetti,
          controller: _controller,
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (LottieComposition composition) {
            _controller
              ..duration = composition.duration
              ..forward(from: 0).whenComplete(() {
                if (mounted) setState(() => _finished = true);
              });
          },
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
