import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/domain/repositories/beauty_shop_repository.dart';

final beautyShopRepositoryProvider = Provider<BeautyShopRepository>((ref) {
  return sl<BeautyShopRepository>();
});

final shopByIdProvider =
    FutureProvider.family<BeautyShop, String>((ref, shopId) async {
  final repository = ref.watch(beautyShopRepositoryProvider);
  final result = await repository.getBeautyShopById(shopId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (shop) => shop,
  );
});
