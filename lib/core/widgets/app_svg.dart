import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma에서 내보낸 SVG 아이콘 렌더러.
///
/// SVG에 색이 박혀 있어도 [color]가 주어지면 `srcIn` 블렌드로 전체를
/// 지정 색으로 덧칠한다. [size]는 정사각형 한 변(px).
class AppSvg extends StatelessWidget {
  const AppSvg(
    this.asset, {
    super.key,
    required this.size,
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double size;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
