/// 收藏模块 - 数据模型
class FavoriteItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  const FavoriteItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.icon = 'heart',
  });
}
