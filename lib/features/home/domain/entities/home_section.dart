enum ShopSortOption {
  distance('거리순', 'DISTANCE', 'ASC'),
  rating('평점순', 'RATING', 'DESC'),
  reviewCount('리뷰순', 'REVIEW_COUNT', 'DESC'),
  latest('최신순', 'CREATED_AT', 'DESC');

  const ShopSortOption(this.label, this.sortBy, this.sortOrder);

  final String label;
  final String sortBy;
  final String sortOrder;

  bool get requiresLocation => this == ShopSortOption.distance;
}

enum HomeSection {
  nearbyPopular('내 주변 인기 샵', ShopSortOption.distance, 4.0),
  recommended('추천 샵', ShopSortOption.rating, null),
  newShops('새로 입점한 샵', ShopSortOption.latest, null);

  const HomeSection(this.title, this.defaultSort, this.minRating);

  final String title;
  final ShopSortOption defaultSort;
  final double? minRating;
}
