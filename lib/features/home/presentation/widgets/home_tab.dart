import 'package:flutter/material.dart';
import 'package:jellomark/features/beautishop/domain/entities/beauty_shop.dart';
import 'package:jellomark/features/beautishop/presentation/pages/shop_detail_page.dart';
import 'package:jellomark/shared/widgets/sections/category_section.dart';
import 'package:jellomark/shared/widgets/sections/search_section.dart';
import 'package:jellomark/shared/widgets/sections/shop_section.dart';
import 'package:jellomark/shared/widgets/units/banner_carousel.dart';

class HomeTab extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  const HomeTab({super.key, this.onRefresh});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingSearchIcon = false;
  static const double _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > _scrollThreshold;
    if (shouldShow != _showFloatingSearchIcon) {
      setState(() {
        _showFloatingSearchIcon = shouldShow;
      });
    }
  }

  void _navigateToShopDetail(String shopId, List<BeautyShop> shops) {
    final shop = shops.firstWhere(
      (s) => s.id == shopId,
      orElse: () => shops.first,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopDetailPage.fromBeautyShop(shop: shop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFFFFB5BA),
            onRefresh: widget.onRefresh ?? () async {},
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SearchSection(locationText: '현재 위치'),
                  const SizedBox(height: 20),
                  CategorySection(categories: _mockCategories),
                  const SizedBox(height: 20),
                  BannerCarousel(banners: _mockBanners),
                  const SizedBox(height: 24),
                  HorizontalShopSection(
                    title: '내 주변 인기 샵',
                    shops: _mockNearbyShops,
                    showMore: true,
                    onShopTap: (id) => _navigateToShopDetail(id, _mockNearbyShops),
                  ),
                  const SizedBox(height: 24),
                  HorizontalShopSection(
                    title: '할인 중인 샵',
                    shops: _mockDiscountShops,
                    showMore: true,
                    onShopTap: (id) => _navigateToShopDetail(id, _mockDiscountShops),
                  ),
                  const SizedBox(height: 24),
                  VerticalShopSection(
                    title: '추천 샵',
                    shops: _mockRecommendedShops,
                    showMore: true,
                    onShopTap: (id) => _navigateToShopDetail(id, _mockRecommendedShops),
                  ),
                  const SizedBox(height: 24),
                  VerticalShopSection(
                    title: '새로 입점한 샵',
                    shops: _mockNewShops,
                    showMore: true,
                    onShopTap: (id) => _navigateToShopDetail(id, _mockNewShops),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_showFloatingSearchIcon)
            Positioned(
              top: 8,
              right: 16,
              child: _FloatingSearchButton(
                key: const Key('floating_search_icon'),
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<CategoryData> get _mockCategories => const [
    CategoryData(id: '1', label: '네일', icon: Icons.brush),
    CategoryData(id: '2', label: '속눈썹', icon: Icons.visibility),
    CategoryData(id: '3', label: '왁싱', icon: Icons.spa),
    CategoryData(id: '4', label: '피부관리', icon: Icons.face),
    CategoryData(id: '5', label: '태닝', icon: Icons.wb_sunny),
    CategoryData(id: '6', label: '발관리', icon: Icons.directions_walk),
  ];

  List<BannerItem> get _mockBanners => const [
    BannerItem(
      id: '1',
      title: '신규 회원 20% 할인',
      subtitle: '첫 방문 고객 한정 특별 혜택',
      imageUrl: 'https://picsum.photos/400/200?random=1',
    ),
    BannerItem(
      id: '2',
      title: '봄맞이 네일 이벤트',
      subtitle: '젤네일 전 메뉴 10% 할인',
      imageUrl: 'https://picsum.photos/400/200?random=2',
    ),
    BannerItem(
      id: '3',
      title: '친구 추천 이벤트',
      subtitle: '친구와 함께 오면 둘 다 5천원 할인',
      imageUrl: 'https://picsum.photos/400/200?random=3',
    ),
  ];

  List<BeautyShop> get _mockNearbyShops => const [
    BeautyShop(
      id: '1',
      name: '블루밍 네일',
      address: '강남구 역삼동',
      rating: 4.8,
      reviewCount: 234,
      distance: 0.3,
      tags: ['네일', '젤네일'],
    ),
    BeautyShop(
      id: '2',
      name: '러블리 래쉬',
      address: '강남구 논현동',
      rating: 4.6,
      reviewCount: 156,
      distance: 0.5,
      tags: ['속눈썹', '펌'],
    ),
    BeautyShop(
      id: '3',
      name: '스파 가든',
      address: '강남구 청담동',
      rating: 4.9,
      reviewCount: 89,
      distance: 0.8,
      tags: ['왁싱', '피부관리'],
    ),
    BeautyShop(
      id: '10',
      name: '네일 아뜰리에',
      address: '강남구 압구정동',
      rating: 4.7,
      reviewCount: 312,
      distance: 0.4,
      tags: ['네일', '아트'],
    ),
    BeautyShop(
      id: '11',
      name: '뷰티풀 래쉬',
      address: '강남구 신사동',
      rating: 4.5,
      reviewCount: 98,
      distance: 0.6,
      tags: ['속눈썹'],
    ),
    BeautyShop(
      id: '12',
      name: '로즈 스파',
      address: '강남구 삼성동',
      rating: 4.8,
      reviewCount: 187,
      distance: 0.7,
      tags: ['피부관리', '마사지'],
    ),
    BeautyShop(
      id: '13',
      name: '글램 네일',
      address: '서초구 서초동',
      rating: 4.6,
      reviewCount: 256,
      distance: 0.9,
      tags: ['네일', '패디큐어'],
    ),
    BeautyShop(
      id: '14',
      name: '아이래쉬 바',
      address: '강남구 대치동',
      rating: 4.9,
      reviewCount: 143,
      distance: 1.0,
      tags: ['속눈썹', '펌'],
    ),
    BeautyShop(
      id: '15',
      name: '힐링 스파',
      address: '송파구 잠실동',
      rating: 4.4,
      reviewCount: 78,
      distance: 1.1,
      tags: ['왁싱', '태닝'],
    ),
    BeautyShop(
      id: '16',
      name: '프렌치 네일',
      address: '강남구 논현동',
      rating: 4.7,
      reviewCount: 201,
      distance: 1.2,
      tags: ['네일'],
    ),
  ];

  List<BeautyShop> get _mockDiscountShops => const [
    BeautyShop(
      id: '4',
      name: '네일 하우스',
      address: '서초구 서초동',
      rating: 4.5,
      reviewCount: 312,
      distance: 1.2,
      tags: ['네일'],
      discountRate: 30,
    ),
    BeautyShop(
      id: '5',
      name: '뷰티 스튜디오',
      address: '강남구 대치동',
      rating: 4.7,
      reviewCount: 178,
      distance: 1.5,
      tags: ['피부관리', '태닝'],
      discountRate: 20,
    ),
    BeautyShop(
      id: '20',
      name: '썸머 네일',
      address: '강남구 역삼동',
      rating: 4.3,
      reviewCount: 89,
      distance: 0.8,
      tags: ['네일', '젤네일'],
      discountRate: 50,
    ),
    BeautyShop(
      id: '21',
      name: '래쉬 퀸',
      address: '서초구 반포동',
      rating: 4.6,
      reviewCount: 234,
      distance: 1.3,
      tags: ['속눈썹'],
      discountRate: 25,
    ),
    BeautyShop(
      id: '22',
      name: '스킨 랩',
      address: '강남구 청담동',
      rating: 4.8,
      reviewCount: 456,
      distance: 1.0,
      tags: ['피부관리'],
      discountRate: 15,
    ),
    BeautyShop(
      id: '23',
      name: '왁싱 전문점',
      address: '송파구 방이동',
      rating: 4.4,
      reviewCount: 123,
      distance: 2.1,
      tags: ['왁싱'],
      discountRate: 40,
    ),
    BeautyShop(
      id: '24',
      name: '골드 네일',
      address: '강남구 논현동',
      rating: 4.5,
      reviewCount: 287,
      distance: 0.9,
      tags: ['네일', '아트'],
      discountRate: 35,
    ),
    BeautyShop(
      id: '25',
      name: '아이뷰티',
      address: '강남구 삼성동',
      rating: 4.7,
      reviewCount: 198,
      distance: 1.4,
      tags: ['속눈썹', '눈썹'],
      discountRate: 20,
    ),
  ];

  List<BeautyShop> get _mockRecommendedShops => const [
    BeautyShop(
      id: '6',
      name: '젤로 네일샵',
      address: '송파구 잠실동',
      rating: 4.9,
      reviewCount: 567,
      distance: 2.1,
      tags: ['네일', '아트'],
    ),
    BeautyShop(
      id: '7',
      name: '글로우 스킨',
      address: '강남구 삼성동',
      rating: 4.8,
      reviewCount: 423,
      distance: 1.8,
      tags: ['피부관리'],
    ),
    BeautyShop(
      id: '30',
      name: '더 네일바',
      address: '강남구 청담동',
      rating: 4.9,
      reviewCount: 789,
      distance: 1.5,
      tags: ['네일', '젤네일', '아트'],
    ),
    BeautyShop(
      id: '31',
      name: '래쉬 스튜디오',
      address: '서초구 서초동',
      rating: 4.8,
      reviewCount: 345,
      distance: 2.0,
      tags: ['속눈썹', '펌'],
    ),
    BeautyShop(
      id: '32',
      name: '스파 블리스',
      address: '강남구 논현동',
      rating: 4.7,
      reviewCount: 512,
      distance: 1.2,
      tags: ['피부관리', '마사지'],
    ),
    BeautyShop(
      id: '33',
      name: '프리미엄 왁싱',
      address: '송파구 가락동',
      rating: 4.9,
      reviewCount: 234,
      distance: 2.5,
      tags: ['왁싱'],
    ),
    BeautyShop(
      id: '34',
      name: '아트 네일',
      address: '강남구 대치동',
      rating: 4.8,
      reviewCount: 678,
      distance: 1.7,
      tags: ['네일', '3D아트'],
    ),
    BeautyShop(
      id: '35',
      name: '클래시 래쉬',
      address: '강남구 압구정동',
      rating: 4.7,
      reviewCount: 289,
      distance: 0.8,
      tags: ['속눈썹'],
    ),
    BeautyShop(
      id: '36',
      name: '에스테틱 센터',
      address: '서초구 반포동',
      rating: 4.9,
      reviewCount: 890,
      distance: 1.9,
      tags: ['피부관리', '리프팅'],
    ),
    BeautyShop(
      id: '37',
      name: '선샤인 태닝',
      address: '강남구 역삼동',
      rating: 4.6,
      reviewCount: 156,
      distance: 1.0,
      tags: ['태닝'],
    ),
    BeautyShop(
      id: '38',
      name: '네일 팩토리',
      address: '송파구 문정동',
      rating: 4.8,
      reviewCount: 432,
      distance: 2.3,
      tags: ['네일', '패디큐어'],
    ),
    BeautyShop(
      id: '39',
      name: '뷰티 하우스',
      address: '강남구 신사동',
      rating: 4.7,
      reviewCount: 567,
      distance: 0.7,
      tags: ['피부관리', '왁싱'],
    ),
  ];

  List<BeautyShop> get _mockNewShops => const [
    BeautyShop(
      id: '8',
      name: '핑크 래쉬',
      address: '강남구 신사동',
      rating: 5.0,
      reviewCount: 12,
      distance: 0.9,
      tags: ['속눈썹'],
      isNew: true,
    ),
    BeautyShop(
      id: '9',
      name: '소프트 왁싱',
      address: '서초구 반포동',
      rating: 4.8,
      reviewCount: 8,
      distance: 1.1,
      tags: ['왁싱'],
      isNew: true,
    ),
    BeautyShop(
      id: '40',
      name: '모던 네일',
      address: '강남구 역삼동',
      rating: 5.0,
      reviewCount: 5,
      distance: 0.5,
      tags: ['네일', '젤네일'],
      isNew: true,
    ),
    BeautyShop(
      id: '41',
      name: '퓨어 스킨',
      address: '강남구 청담동',
      rating: 4.9,
      reviewCount: 15,
      distance: 1.2,
      tags: ['피부관리'],
      isNew: true,
    ),
    BeautyShop(
      id: '42',
      name: '래쉬 플러스',
      address: '송파구 잠실동',
      rating: 5.0,
      reviewCount: 3,
      distance: 1.8,
      tags: ['속눈썹', '펌'],
      isNew: true,
    ),
    BeautyShop(
      id: '43',
      name: '브론즈 태닝',
      address: '강남구 논현동',
      rating: 4.7,
      reviewCount: 9,
      distance: 0.7,
      tags: ['태닝'],
      isNew: true,
    ),
    BeautyShop(
      id: '44',
      name: '엘레강스 네일',
      address: '서초구 서초동',
      rating: 4.8,
      reviewCount: 18,
      distance: 1.5,
      tags: ['네일', '아트'],
      isNew: true,
    ),
    BeautyShop(
      id: '45',
      name: '실크 왁싱',
      address: '강남구 대치동',
      rating: 5.0,
      reviewCount: 7,
      distance: 1.0,
      tags: ['왁싱'],
      isNew: true,
    ),
    BeautyShop(
      id: '46',
      name: '글로리 스파',
      address: '강남구 삼성동',
      rating: 4.9,
      reviewCount: 22,
      distance: 1.3,
      tags: ['피부관리', '마사지'],
      isNew: true,
    ),
    BeautyShop(
      id: '47',
      name: '프레시 래쉬',
      address: '강남구 압구정동',
      rating: 5.0,
      reviewCount: 11,
      distance: 0.6,
      tags: ['속눈썹'],
      isNew: true,
    ),
  ];
}

class _FloatingSearchButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FloatingSearchButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB5BA).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.search, color: Color(0xFFFFB5BA), size: 24),
      ),
    );
  }
}
