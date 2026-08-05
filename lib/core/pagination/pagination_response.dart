/// 分页查询结果
///
/// 所有分页接口统一使用此模型返回。
class PaginationResponse<T> {
  /// 当前页码，从 1 开始
  final int page;

  /// 每页数量
  final int limit;

  /// 符合条件的总条数（服务器已知时）
  final int total;

  /// 是否还有更多数据
  final bool hasMore;

  /// 当前页数据
  final List<T> items;

  const PaginationResponse({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.hasMore = false,
    this.items = const [],
  });

  /// 服务端已返回总条数时创建分页结果
  ///
  /// 适用于 lx-server 一类会在响应体里带 `total` 的接口，
  /// [hasMore] 由「已取条数是否小于总数」推出，无需额外试探请求。
  factory PaginationResponse.fromTotal({
    required List<T> items,
    required int page,
    required int limit,
    required int total,
  }) {
    return PaginationResponse(
      page: page,
      limit: limit,
      total: total,
      hasMore: page * limit < total,
      items: items,
    );
  }

  /// 服务端未返回总条数时，按「本页是否取满」推断分页结果
  ///
  /// 适用于 Subsonic 一类只返回当前页数据的接口：
  /// 取满一页即假定后面还有（[hasMore] 为 true），此时 [total] 只是
  /// 「至少这么多」的下界估计，不可当作精确总数展示。
  factory PaginationResponse.fromPageSize({
    required List<T> items,
    required int page,
    required int limit,
  }) {
    final isFullPage = items.length == limit;
    return PaginationResponse(
      page: page,
      limit: limit,
      total: isFullPage
          ? page * limit + 1
          : (page - 1) * limit + items.length,
      hasMore: isFullPage,
      items: items,
    );
  }

  /// 一次性返回全部数据、不存在后续页时的结果
  ///
  /// [page] / [limit] 仅用于回显调用方传入的请求参数，
  /// 不影响 [hasMore]（恒为 false）；省略时按单页全量处理。
  factory PaginationResponse.complete(
    List<T> items, {
    int? page,
    int? limit,
  }) {
    return PaginationResponse(
      page: page ?? 1,
      limit: limit ?? items.length,
      total: items.length,
      hasMore: false,
      items: items,
    );
  }

  /// 从完整列表创建分页结果
  factory PaginationResponse.fromList(
    List<T> allItems, {
    int page = 1,
    int limit = 20,
  }) {
    final start = (page - 1) * limit;
    final end = start + limit;
    final hasMore = end < allItems.length;
    final items = allItems.sublist(start, end.clamp(0, allItems.length));
    return PaginationResponse(
      page: page,
      limit: limit,
      total: allItems.length,
      hasMore: hasMore,
      items: items,
    );
  }

  /// 空结果
  factory PaginationResponse.empty({int page = 1, int limit = 20}) {
    return PaginationResponse(page: page, limit: limit);
  }
}
