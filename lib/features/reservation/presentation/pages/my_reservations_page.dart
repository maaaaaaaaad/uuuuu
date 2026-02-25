import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/reservation/domain/entities/reservation_status.dart';
import 'package:jellomark/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_card.dart';
import 'package:jellomark/shared/theme/app_colors.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class MyReservationsPage extends ConsumerStatefulWidget {
  const MyReservationsPage({super.key});

  @override
  ConsumerState<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends ConsumerState<MyReservationsPage> {
  static const _filterStatuses = [
    null,
    ReservationStatus.pending,
    ReservationStatus.confirmed,
    ReservationStatus.completed,
    ReservationStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myReservationsNotifierProvider.notifier).loadReservations();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(myReservationsNotifierProvider.notifier).refresh();
  }

  void _onFilterTap(ReservationStatus? status) {
    ref.read(myReservationsNotifierProvider.notifier).filterByStatus(status);
  }

  Future<void> _navigateToDetail(String reservationId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            ReservationDetailPage(reservationId: reservationId),
      ),
    );

    if (result == true && mounted) {
      ref.read(myReservationsNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myReservationsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundMedium,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('내 예약'),
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
          child: Column(
            children: [
              _buildFilterChips(state),
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(MyReservationsState state) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterStatuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filterStatus = _filterStatuses[index];
          final isSelected = state.filterStatus == filterStatus;
          final label = filterStatus?.label ?? '전체';

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => _onFilterTap(filterStatus),
            selectedColor: SemanticColors.background.chipSelected,
            backgroundColor: SemanticColors.background.chip,
            labelStyle: TextStyle(
              fontSize: 13,
              color: isSelected
                  ? SemanticColors.text.primary
                  : SemanticColors.text.secondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? SemanticColors.border.glass
                    : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(MyReservationsState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: SemanticColors.indicator.loading,
        ),
      );
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    if (state.filteredReservations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.filteredReservations.length,
        itemBuilder: (context, index) {
          final reservation = state.filteredReservations[index];
          return ReservationCard(
            reservation: reservation,
            onTap: () => _navigateToDetail(reservation.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppGradients.mintGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_note_outlined,
                      size: 48,
                      color: SemanticColors.text.onDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '예약 내역이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SemanticColors.text.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '원하는 샵에서 예약해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SemanticColors.background.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: SemanticColors.icon.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: TextStyle(
                      fontSize: 16,
                      color: SemanticColors.text.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _onRefresh,
                    style: TextButton.styleFrom(
                      foregroundColor: SemanticColors.button.textButton,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
