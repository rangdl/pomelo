/// 我的模块 - 数据模型
///
/// 遵循 JSON 零迁移规则：
/// - 新增字段 → 构造器给默认值，fromJson 用 ?? 兜底
/// - 删除字段 → 直接移除，旧数据的 key 会被忽略
class MyProfile {
  final String id;
  final String name;
  final String avatar;
  final String bio;

  /// 新增字段示例：用户偏好的主题模式
  /// 旧数据没有此字段 → json['theme'] 为 null → 'system'
  final String theme;

  const MyProfile({
    required this.id,
    this.name = '',
    this.avatar = '',
    this.bio = '',
    this.theme = 'system',
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) => MyProfile(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    avatar: json['avatar'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    theme: json['theme'] as String? ?? 'system',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'bio': bio,
    'theme': theme,
  };
}
