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
