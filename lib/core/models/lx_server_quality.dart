
/// 音质等级定义（全局）
///
/// 集中管理应用支持的音质标识、显示名与优先级。
/// 用户偏好存储为字符串标识（[LxServerQuality.id]），
/// 应用到各 MusicServer.getMusicUrl 时若不可用则按 [priority] 降级。
library;

/// 音质降级阶梯（高 → 低），全局唯一来源
///
/// [sourced_track.dart] 的降级遍历与 [LxServerMusicServer._selectQuality]
/// 都必须引用此常量，避免两处硬编码的阶梯数组漂移后行为不一致。
const List<String> kQualityLadder = ['flac24bit', 'flac', '320k', '128k'];

/// 音质等级
enum LxServerQuality {
  /// 无损 Hi-Res（24bit/192kHz）
  flac24bit('flac24bit', 'Hi-Res 无损'),

  /// 无损 FLAC（16bit/44.1kHz）
  flac('flac', '无损 FLAC'),

  /// 高品质 320kbps MP3
  high320k('320k', '高品质 320k'),

  /// 标准 128kbps MP3
  standard128k('128k', '标准 128k');

  /// 音质标识（与 lx_server API、LxSourceEngine 一致）
  final String id;

  /// 显示名
  final String label;

  const LxServerQuality(this.id, this.label);

  /// 优先级（高 → 低），用于不可用时降级回退
  static const priority = [
    LxServerQuality.flac24bit,
    LxServerQuality.flac,
    LxServerQuality.high320k,
    LxServerQuality.standard128k,
  ];

  /// 按 id 查找，未匹配返回 null
  static LxServerQuality? fromId(String? id) {
    if (id == null) return null;
    for (final q in LxServerQuality.values) {
      if (q.id == id) return q;
    }
    return null;
  }

  /// 按 id 查找，未匹配返回 [fallback]
  static LxServerQuality fromIdOrDefault(
    String? id, {
    LxServerQuality fallback = LxServerQuality.flac,
  }) {
    return fromId(id) ?? fallback;
  }
}
