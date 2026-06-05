/// 我的模块 - 数据模型
class MyProfile {
  final String id;
  final String name;
  final String avatar;
  final String bio;

  const MyProfile({
    required this.id,
    this.name = '',
    this.avatar = '',
    this.bio = '',
  });
}
