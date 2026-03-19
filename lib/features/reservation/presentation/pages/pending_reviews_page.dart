import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/presentation/providers/pending_review_provider.dart';
import 'package:jellomark/features/review/presentation/providers/review_provider.dart';
import 'package:jellomark/features/review/presentation/widgets/edit_review_bottom_sheet.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class PendingReviewsPage extends ConsumerStatefulWidget {
  const PendingReviewsPage({super.key});

  @override
  ConsumerState<PendingReviewsPage> createState() =>
      _PendingReviewsPageState();
}

class _PendingReviewsPageState extends ConsumerState<PendingReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pendingReviewNotifierProvider.notifier).loadPendingReviews();
    });
  }

  Future<void> _writeReview(Reservation reservation) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditReviewBottomSheet(
        onSubmit: ({int? rating, String? content}) async {
          final useCase = ref.read(createReviewUseCaseProvider);
          final result = await useCase(
            shopId: reservation.shopId,
            rating: rating,
            content: content,
          );
          return result.fold((_) => false, (_) => true);
        },
      ),
    );

    if (result == true && mounted) {
      ref
          .read(pendingReviewNotifierProvider.notifier)
          .removeByShopId(reservation.shopId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingReviewNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundMedium,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('리뷰 작성 대기'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.special.transparent,
        foregroundColor: SemanticColors.text.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(PendingReviewState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loading,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: SemanticColors.icon.disabled,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(
                fontSize: 14,
                color: SemanticColors.text.secondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref
                  .read(pendingReviewNotifierProvider.notifier)
                  .loadPendingReviews(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: SemanticColors.icon.disabled,
            ),
            const SizedBox(height: 16),
            Text(
              '작성할 리뷰가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: SemanticColors.text.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(pendingReviewNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.reservations.length,
        itemBuilder: (context, index) {
          final reservation = state.reservations[index];
          return _buildReservationCard(reservation);
        },
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SemanticColors.background.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SemanticColors.border.glass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reservation.shopName ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.treatmentName ?? '',
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.reservationDate,
            style: TextStyle(
              fontSize: 13,
              color: SemanticColors.text.secondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _writeReview(reservation),
              style: ElevatedButton.styleFrom(
                backgroundColor: SemanticColors.button.primary,
                foregroundColor: SemanticColors.button.primaryText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('리뷰 쓰기'),
            ),
          ),
        ],
      ),
    );
  }
}
