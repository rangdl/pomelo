/// Lx 音源脚本模型
///
/// 对应 drift `lx_source_scripts` 表的业务模型。
/// 存储用户添加的 Lx 音源插件脚本内容与解析后的元信息。
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';

/// Lx 音源脚本
@immutable
class LxSourceScript {
  /// 脚本唯一标识（基于脚本内容 hash 生成）
  final String id;

  /// 脚本名称（解析自 @name）
  final String name;

  /// 描述（解析自 @description）
  final String? description;

  /// 作者（解析自 @author）
  final String? author;

  /// 主页（解析自 @homepage）
  final String? homepage;

  /// 版本（解析自 @version）
  final String? version;

  /// 完整脚本内容
  final String script;

  /// 注册的库与音质列表
  final List<LxSourceLibrary> libraries;

  /// 添加时间
  final DateTime createdAt;

  /// 是否启用
  final bool enabled;

  const LxSourceScript({
    required this.id,
    required this.name,
    this.description,
    this.author,
    this.homepage,
    this.version,
    required this.script,
    required this.libraries,
    required this.createdAt,
    this.enabled = true,
  });

  /// 从 drift 实体构造
  ///
  /// [librariesJson] 是表中存储的 JSON 字符串。
  factory LxSourceScript.fromEntity({
    required String id,
    required String name,
    String? description,
    String? author,
    String? homepage,
    String? version,
    required String script,
    required String librariesJson,
    required DateTime createdAt,
    required bool enabled,
  }) {
    return LxSourceScript(
      id: id,
      name: name,
      description: description,
      author: author,
      homepage: homepage,
      version: version,
      script: script,
      libraries: _parseLibrariesJson(librariesJson),
      createdAt: createdAt,
      enabled: enabled,
    );
  }

  /// 解析库列表 JSON
  ///
  /// 格式：`[{"id":"kw","name":"kw","qualitys":["128k","320k","flac"]}]`
  static List<LxSourceLibrary> _parseLibrariesJson(String json) {
    if (json.isEmpty) return const [];
    try {
      return _decodeLibraries(json);
    } catch (_) {
      return const [];
    }
  }

  /// 库列表转 JSON 字符串
  static String librariesToJson(List<LxSourceLibrary> libraries) {
    final list = libraries
        .map(
          (l) => {
            'id': l.id,
            'name': l.name,
            'qualitys': l.qualitys,
          },
        )
        .toList();
    return jsonEncode(list);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LxSourceScript && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 解析库列表 JSON
List<LxSourceLibrary> _decodeLibraries(String json) {
  final dynamic decoded = jsonDecode(json);
  if (decoded is! List) return const [];
  final result = <LxSourceLibrary>[];
  for (final item in decoded) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    final id = m['id'] as String?;
    if (id == null || id.isEmpty) continue;
    result.add(
      LxSourceLibrary(
        id: id,
        name: (m['name'] as String?) ?? id,
        qualitys:
            (m['qualitys'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
      ),
    );
  }
  return result;
}
