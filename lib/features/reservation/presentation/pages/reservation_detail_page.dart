import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_status_badge.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ReservationDetailPage extends ConsumerWidget {
  final String reservationId;

  const ReservationDetailPage({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myReservationsNotifierProvider);
    final reservation = _findReservation(state);

    return Scaffold(
      backgroundColor: SemanticColors.special.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('예약 상세'),
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
          child: reservation == null
              ? _buildNotFound()
              : _buildDetail(context, ref, reservation),
        ),
      ),
    );
  }

  Reservation? _findReservation(MyReservationsState state) {
    final matches = state.reservations.where((r) => r.id == reservationId);
    return matches.isEmpty ? null : matches.first;
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: SemanticColors.icon.disabled,
          ),
          const SizedBox(height: 16),
          Text(
            '예약을 찾을 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: SemanticColors.text.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(
      BuildContext context, WidgetRef ref, Reservation reservation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(reservation),
          const SizedBox(height: 24),
          _buildInfoSection(reservation),
          if (reservation.memo != null && reservation.memo!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildMemoSection(reservation),
          ],
          if (reservation.rejectionReason != null &&
              reservation.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildRejectionSection(reservation),
          ],
          if (reservation.status.isCancellable) ...[
            const SizedBox(height: 32),
            _buildCancelButton(context, ref, reservation),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection(Reservation reservation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ReservationStatusBadge(status: reservation.status),
          const SizedBox(height: 12),
          Text(
            reservation.treatmentName ?? '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.shopName ?? '',
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Reservation reservation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            '날짜',
            reservation.reservationDate,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            '시간',
            '${reservation.startTime} - ${reservation.endTime}',
          ),
          if (reservation.treatmentDuration != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.timer_outlined,
              '소요시간',
              '${reservation.treatmentDuration}분',
            ),
          ],
          if (reservation.treatmentPrice != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.payments_outlined,
              '가격',
              '${_formatPrice(reservation.treatmentPrice!)}원',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: SemanticColors.icon.secondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: SemanticColors.text.secondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SemanticColors.text.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoSection(Reservation reservation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '메모',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SemanticColors.text.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reservation.memo!,
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionSection(Reservation reservation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: SemanticColors.state.error,
              ),
              const SizedBox(width: 8),
              Text(
                '거절 사유',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SemanticColors.state.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reservation.rejectionReason!,
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.primary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(
      BuildContext context, WidgetRef ref, Reservation reservation) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => _showCancelDialog(context, ref, reservation),
        style: OutlinedButton.styleFrom(
          foregroundColor: SemanticColors.state.error,
          side: BorderSide(color: SemanticColors.state.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '예약 취소',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(
      BuildContext context, WidgetRef ref, Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('예약을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: SemanticColors.state.error,
            ),
            child: const Text('취소하기'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(myReservationsNotifierProvider.notifier)
          .cancelReservation(reservation.id);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
