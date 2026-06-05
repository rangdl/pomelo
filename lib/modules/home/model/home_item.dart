/// Home 模块 - 数据模型层
class HomeItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  const HomeItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.icon = 'home',
  });

  HomeItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? icon,
  }) {
    return HomeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HomeItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
