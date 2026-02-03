import 'dart:convert';

import 'package:jellomark/features/recent_shops/domain/entities/recent_shop.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RecentShopsLocalDataSource {
  Future<void> addRecentShop(RecentShop shop);

  Future<List<RecentShop>> getRecentShops();

  Future<void> clearRecentShops();
}

class RecentShopsLocalDataSourceImpl implements RecentShopsLocalDataSource {
  static const String _recentShopsKey = 'recent_shops';
  static const int _maxShopsCount = 20;

  @override
  Future<void> addRecentShop(RecentShop shop) async {
    final prefs = await SharedPreferences.getInstance();
    final shopsList = await _getShopsList(prefs);

    shopsList.removeWhere((item) => item['shopId'] == shop.shopId);

    shopsList.insert(0, {
      'shopId': shop.shopId,
      'shopName': shop.shopName,
      'thumbnailUrl': shop.thumbnailUrl,
      'address': shop.address,
      'rating': shop.rating,
      'viewedAt': shop.viewedAt.toIso8601String(),
      'latitude': shop.latitude,
      'longitude': shop.longitude,
    });

    if (shopsList.length > _maxShopsCount) {
      shopsList.removeRange(_maxShopsCount, shopsList.length);
    }

    await prefs.setString(_recentShopsKey, jsonEncode(shopsList));
  }

  @override
  Future<List<RecentShop>> getRecentShops() async {
    final prefs = await SharedPreferences.getInstance();
    final shopsList = await _getShopsList(prefs);

    return shopsList
        .map(
          (item) => RecentShop(
            shopId: item['shopId'] as String,
            shopName: item['shopName'] as String,
            thumbnailUrl: item['thumbnailUrl'] as String?,
            address: item['address'] as String?,
            rating: (item['rating'] as num?)?.toDouble(),
            viewedAt: DateTime.parse(item['viewedAt'] as String),
            latitude: (item['latitude'] as num?)?.toDouble(),
            longitude: (item['longitude'] as num?)?.toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<void> clearRecentShops() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentShopsKey);
  }

  Future<List<Map<String, dynamic>>> _getShopsList(
    SharedPreferences prefs,
  ) async {
    final jsonString = prefs.getString(_recentShopsKey);
    if (jsonString == null) {
      return [];
    }

    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }
}
