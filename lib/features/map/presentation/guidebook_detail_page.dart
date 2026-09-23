import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/resizable_bottom_sheet.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/success_toast.dart';
import '../../auth/application/session.dart';
import '../../cta/cta_page.dart';
import '../../home/models/guidebook.dart';
import '../../home/models/guidebook_review.dart';
import '../../home/widgets/guidebook_card.dart' show ProgressBadge;
import '../data/map_repository.dart';
import '../map_view.dart';
import '../models/place.dart';
import 'guidebook_browse_page.dart';
import 'review_write_page.dart';
import 'widgets/current_location_button.dart';
import 'widgets/guidebook_filter_chip.dart';
import 'widgets/guidebook_place_card.dart';
import 'widgets/guidebook_review_card.dart';
import 'widgets/stamp_dialogs.dart';

/// 가이드북 상세 화면 — 지도 위 리사이즈 바텀시트로 타이틀, CTA, 리뷰,
/// 장소 리스트를 보여준다.
///
/// 작성자 관리, 완주 축하, 도전 한도 초과, 구독/찜은 후속 작업.
class GuidebookDetailPage extends ConsumerStatefulWidget {
  const GuidebookDetailPage(this.guidebook, {super.key});

  final Guidebook guidebook;

  @override
  ConsumerState<GuidebookDetailPage> createState() =>
      _GuidebookDetailPageState();
}

class _GuidebookDetailPageState extends ConsumerState<GuidebookDetailPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ValueNotifier<double> _extent = ValueNotifier<double>(0.45);

  /// 도전 상태 — 서버 연동 전까지 화면 로컬 상태.
  GuidebookProgress? _progress;

  /// "방문완료"/"미방문" 필터. null이면 전체, 같은 칩 재탭 시 해제.
  bool? _visitedFilter;

  /// 리뷰 목록/개수 — 새 리뷰는 맨 앞에 붙는다(화면 로컬 상태).
  late List<GuidebookReview> _reviews;
  late int _reviewCount;

  @override
  void initState() {
    super.initState();
    _progress = widget.guidebook.progress;
    _reviews = widget.guidebook.reviews;
    _reviewCount = widget.guidebook.reviewCount;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _extent.dispose();
    super.dispose();
  }

  /// 도전 시작은 즉시, 취소는 확인 후. 확정되면 토스트.
  Future<void> _toggleChallenge() async {
    final String title = widget.guidebook.title;
    if (_progress == null) {
      // 이미 방문한 장소는 진행률에 포함.
      final int visited = widget.guidebook.places
          .where((Place p) => p.visitedDate != null)
          .length;
      setState(() {
        _progress = GuidebookProgress(
          completed: visited,
          total: widget.guidebook.placeCount,
        );
      });
      showSuccessToast(context, emphasis: title, suffix: ' 도전을 시작했어요');
      return;
    }

    final bool confirmed =
        await showChallengeCancelDialog(context, guidebookTitle: title);
    if (!confirmed || !mounted) return;
    setState(() => _progress = null);
    showSuccessToast(context, emphasis: title, suffix: ' 도전을 취소했어요');
  }

  Future<void> _writeReview() async {
    final String title = widget.guidebook.title;
    final ReviewDraft? draft = await Navigator.of(context).push<ReviewDraft>(
      MaterialPageRoute<ReviewDraft>(
        builder: (_) => ReviewWritePage(guidebookTitle: title),
      ),
    );
    if (draft == null || !mounted) return;
    final String nickname = ref.read(sessionProvider)?.nickname ?? '';
    setState(() {
      _reviews = <GuidebookReview>[
        GuidebookReview(
          rating: draft.rating.toDouble(),
          timeAgo: '방금 전',
          authorName: nickname,
          // 유저 레벨 API 연동 전 더미.
          authorLevel: 1,
          content: draft.content,
        ),
        ..._reviews,
      ];
      _reviewCount++;
    });
    showSuccessToast(context, emphasis: title, suffix: '에 리뷰를 남겼어요');
  }

  void _toggleVisitedFilter(bool visited) {
    setState(() {
      _visitedFilter = _visitedFilter == visited ? null : visited;
    });
  }

  void _openPlaceGuidebooks(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GuidebookBrowsePage(
          title: '${place.name}이 포함된 가이드북',
          guidebooks: ref.read(browsableGuidebooksProvider),
          resultCountLabel:
              '${_formatCount(place.guidebookCount)}개의 가이드북을 찾았어요',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: KakaoMapView()),
          // 시트가 거의 펼쳐지면 페이드인되는 dimmer.
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: _extent,
              builder: (BuildContext context, double extent, _) {
                final double t =
                    ((extent - 0.7) / (0.95 - 0.7)).clamp(0.0, 1.0);
                return IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.2 * t),
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: _extent,
            builder: (BuildContext context, double extent, _) {
              return Positioned(
                right: 16,
                bottom: extent * screenHeight + 16,
                child: CurrentLocationButton(onTap: () {}),
              );
            },
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (DraggableScrollableNotification n) {
              _extent.value = n.extent;
              return false;
            },
            child: ResizableBottomSheet(
              controller: _sheetController,
              onBack: () => Navigator.of(context).pop(),
              contentBuilder:
                  (BuildContext context, ScrollController scrollController) {
                return _buildContent(context, scrollController);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScrollController scrollController) {
    final Guidebook guidebook = widget.guidebook;
    final List<Place> visiblePlaces = _visitedFilter == null
        ? guidebook.places
        : guidebook.places
            .where((Place p) => (p.visitedDate != null) == _visitedFilter)
            .toList();
    final TextStyle sectionTitle =
        AppTextStyles.sheetTitle.copyWith(color: AppColors.textPrimary);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: <Widget>[
        Padding(
          // 좌상단 뒤로가기 버튼과 겹치지 않게 위쪽 여백.
          padding: const EdgeInsets.fromLTRB(12, 30, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(guidebook.title, style: AppTextStyles.ctaTitle24),
              const SizedBox(height: 8),
              Text(
                'Lv. ${guidebook.level} · ${guidebook.authorName}',
                style: AppTextStyles.bannerSubtitle,
              ),
              // 출판일 (Figma 3387:8518).
              Text(
                '출판일 ${guidebook.publishedDate.replaceAll(' ', '')}',
                style: AppTextStyles.bannerSubtitle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _CtaRow(
          progress: _progress,
          onChallengeTap: _toggleChallenge,
          onReviewWriteTap: _writeReview,
        ),
        const SizedBox(height: 24),
        // 리뷰가 없으면 "리뷰".
        Text(
          _reviews.isEmpty ? '리뷰' : '${_formatCount(_reviewCount)}개의 리뷰',
          style: sectionTitle,
        ),
        const SizedBox(height: 8),
        // 리뷰가 없으면 안내 문구.
        if (_reviews.isEmpty)
          const _EmptyReviews()
        else
          SizedBox(
            height: GuidebookReviewCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _reviews.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int i) =>
                  GuidebookReviewCard(_reviews[i]),
            ),
          ),
        const SizedBox(height: 24),
        Text('${_formatCount(guidebook.placeCount)}개의 장소', style: sectionTitle),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            GuidebookFilterChip(
              icon: const Icon(Icons.check, size: 14, color: AppColors.gray900),
              label: '방문완료',
              selected: _visitedFilter == true,
              onTap: () => _toggleVisitedFilter(true),
            ),
            const SizedBox(width: 8),
            GuidebookFilterChip(
              icon: AppSvg(
                AppIcons.filterPrivate,
                size: 14,
                color: AppColors.gray900,
              ),
              label: '미방문',
              selected: _visitedFilter == false,
              onTap: () => _toggleVisitedFilter(false),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < visiblePlaces.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 10),
          GuidebookPlaceCard(
            visiblePlaces[i],
            onGuidebookTap: () => _openPlaceGuidebooks(visiblePlaces[i]),
          ),
        ],
      ],
    );
  }
}

/// 리뷰 없음 안내 — 배경 없이 연한 문구만.
class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      alignment: Alignment.center,
      child: Text(
        '아직 등록된 리뷰가 없어요',
        style: AppTextStyles.placeMeta
            .copyWith(fontSize: 14, color: AppColors.textMuted),
      ),
    );
  }
}

/// CTA 영역(Figma 365:10430) — 도전 전엔 "도전하기"만, 도전 중엔
/// "도전 취소" + "리뷰쓰기" + 진행률 바.
class _CtaRow extends ConsumerWidget {
  const _CtaRow({
    required this.progress,
    required this.onChallengeTap,
    required this.onReviewWriteTap,
  });

  final GuidebookProgress? progress;
  final VoidCallback onChallengeTap;
  final VoidCallback onReviewWriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggedIn = ref.watch(sessionProvider) != null;

    // 비로그인 또는 도전 전.
    if (!isLoggedIn || progress == null) {
      return PrimaryButton(
        label: isLoggedIn ? '도전하기' : '나도 도전하기',
        onPressed: isLoggedIn
            ? onChallengeTap
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CtaPage()),
                ),
      );
    }

    // 도전 중.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SecondaryButton(
                label: '도전 취소',
                borderColor: AppColors.red300,
                textColor: AppColors.red400,
                // "리뷰쓰기"보다 덜 강조되게 배경 투명, 테두리 1px(Figma).
                backgroundColor: Colors.transparent,
                borderWidth: 1,
                onPressed: onChallengeTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryButton(label: '리뷰쓰기', onPressed: onReviewWriteTap),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProgressBadge(
          progress!,
          outerShadow: AppColors.raisedShadow,
          trackColor: AppColors.gray300,
        ),
      ],
    );
  }
}

String _formatCount(int n) {
  final String s = n.toString();
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
