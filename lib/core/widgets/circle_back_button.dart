import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import 'app_svg.dart';

/// 반투명 원형 뒤로가기 버튼(흰 좌향 chevron). 지도/시트 상단 공용.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x33000000),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33FFFFFF)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: AppSvg(
                  AppIcons.chevronRight,
                  size: 14,
                  width: 14,
                  height: 14 * 8 / 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
