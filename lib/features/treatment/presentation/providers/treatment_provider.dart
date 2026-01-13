import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/treatment/domain/usecases/get_shop_treatments_usecase.dart';

final getShopTreatmentsUseCaseProvider = Provider<GetShopTreatmentsUseCase>((
  ref,
) {
  return sl<GetShopTreatmentsUseCase>();
});

final shopTreatmentsProvider = FutureProvider.family<List<ServiceMenu>, String>(
  (ref, shopId) async {
    final useCase = ref.watch(getShopTreatmentsUseCaseProvider);
    final result = await useCase(shopId: shopId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (treatments) => treatments,
    );
  },
);
