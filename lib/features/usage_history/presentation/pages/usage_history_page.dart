import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/usecases/get_shop_services.dart';
import 'package:jellomark/features/reservation/presentation/pages/create_reservation_page.dart';
import 'package:jellomark/features/usage_history/presentation/providers/usage_history_provider.dart';
import 'package:jellomark/features/usage_history/presentation/widgets/usage_history_card.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

final getShopServicesUseCaseProvider = Provider<GetShopServices>((ref) {
  return sl<GetShopServices>();
});

class UsageHistoryPage extends ConsumerStatefulWidget {
  const UsageHistoryPage({super.key});

  @override
  ConsumerState<UsageHistoryPage> createState() => _UsageHistoryPageState();
}

class _UsageHistoryPageState extends ConsumerState<UsageHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usageHistoryNotifierProvider.notifier).load();
    });
  }

  Future<void> _handleRebook(String shopId) async {
    final useCase = ref.read(getShopServicesUseCaseProvider);
    final result = await useCase(shopId: shopId);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (treatments) {
        if (treatments.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 샵의 시술 정보를 찾을 수 없습니다')),
          );
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateReservationPage(
              shopId: shopId,
              treatments: treatments,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usageHistoryNotifierProvider);

    return Scaffold(
      backgroundColor: SemanticColors.special.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('이용기록'),
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

  Widget _buildBody(UsageHistoryState state) {
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
              onPressed: () =>
                  ref.read(usageHistoryNotifierProvider.notifier).load(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: SemanticColors.icon.disabled,
            ),
            const SizedBox(height: 16),
            Text(
              '이용기록이 없습니다',
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
          ref.read(usageHistoryNotifierProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.histories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final history = state.histories[index];
          return UsageHistoryCard(
            history: history,
            onRebook: () => _handleRebook(history.shopId),
          );
        },
      ),
    );
  }
}
