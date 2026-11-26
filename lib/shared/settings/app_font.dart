import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';
import 'settings_store.dart';

/// 内置字体在 pubspec.yaml 中注册的 family。
///
/// 与 loomy 使用的是同一款字体：Droid Sans Fallback（Apache 2.0），
/// 中英文观感统一，不会出现 Windows 默认回退字体忽粗忽细的问题。
const String bundledFontFamily = 'DroidSansFallback';
const String bundledFontLabel = 'Droid Sans Fallback';

/// 允许上传的字体扩展名。
const Set<String> _fontExtensions = {'.ttf', '.otf', '.ttc'};

/// 自定义字体大小上限（50MB），避免误选超大文件卡住界面。
const int _maxCustomFontBytes = 50 * 1024 * 1024;

/// 可选字体类型。
enum AppFontKind {
  system('system', '系统默认'),
  bundled('bundled', '内置字体'),
  custom('custom', '自定义字体');

  const AppFontKind(this.id, this.label);

  /// 持久化到 settings.json 的标识。
  final String id;

  /// 设置页展示名。
  final String label;
}

/// 当前生效的字体选择。
class AppFontSelection {
  const AppFontSelection._({
    required this.kind,
    this.customFamily,
    this.customName,
    this.customPath,
  });

  const AppFontSelection.system() : this._(kind: AppFontKind.system);

  const AppFontSelection.bundled() : this._(kind: AppFontKind.bundled);

  const AppFontSelection.custom({
    required String family,
    required String name,
    required String path,
  }) : this._(
         kind: AppFontKind.custom,
         customFamily: family,
         customName: name,
         customPath: path,
       );

  final AppFontKind kind;

  /// 自定义字体在引擎中注册的 family（每次加载唯一）。
  final String? customFamily;

  /// 用户上传时的原始文件名。
  final String? customName;

  /// 自定义字体在应用目录中的副本路径。
  final String? customPath;

  /// 传给 ThemeData 的字体 family；null 表示系统默认。
  String? get fontFamily => switch (kind) {
    AppFontKind.system => null,
    AppFontKind.bundled => bundledFontFamily,
    AppFontKind.custom => customFamily,
  };

  /// 设置页副标题。
  String get label => switch (kind) {
    AppFontKind.system => '系统默认',
    AppFontKind.bundled => '$bundledFontLabel（内置）',
    AppFontKind.custom => customName == null ? '自定义字体' : '自定义 · $customName',
  };
}

/// 字体初值，由 main() 从设置里读出（并完成自定义字体注册）后注入。
final appFontInitializerProvider = Provider<AppFontSelection>(
  (ref) => throw UnimplementedError('must be overridden at startup'),
);

final appFontProvider = NotifierProvider<AppFontNotifier, AppFontSelection>(
  AppFontNotifier.new,
);

class AppFontNotifier extends Notifier<AppFontSelection> {
  @override
  AppFontSelection build() => ref.watch(appFontInitializerProvider);

  /// 切回系统默认字体。
  Future<void> useSystem() async {
    if (state.kind == AppFontKind.system) return;
    state = const AppFontSelection.system();
    await _persist(kind: AppFontKind.system);
  }

  /// 使用内置字体（与 loomy 同款）。
  Future<void> useBundled() async {
    if (state.kind == AppFontKind.bundled) return;
    state = const AppFontSelection.bundled();
    await _persist(kind: AppFontKind.bundled);
  }

  /// 切回上次上传的自定义字体；没有可用文件时返回 false。
  Future<bool> useCustom() async {
    if (state.kind == AppFontKind.custom) return true;
    final store = ref.read(settingsStoreProvider);
    final path = store.read<String>('customFontPath');
    final name = store.read<String>('customFontName');
    if (path == null || name == null) return false;
    final file = File(path);
    if (!await file.exists()) return false;
    final family = await _registerFontFile(file);
    if (family == null) return false;
    state = AppFontSelection.custom(family: family, name: name, path: path);
    await _persist(kind: AppFontKind.custom);
    return true;
  }

  /// 导入并应用本地字体文件，成功返回 true。
  Future<bool> importFont(File source, {required String originalName}) async {
    final ext = _extensionOf(originalName);
    if (!_fontExtensions.contains(ext)) return false;

    File? target;
    try {
      final size = await source.length();
      if (size <= 0 || size > _maxCustomFontBytes) return false;
      final support = await getApplicationSupportDirectory();
      final dir = Directory('${support.path}${Platform.pathSeparator}fonts');
      await dir.create(recursive: true);
      target = File('${dir.path}${Platform.pathSeparator}custom$ext');
      // 只保留一份自定义字体，避免反复导入累积大文件。
      await for (final entity in dir.list()) {
        if (entity is File) {
          try {
            await entity.delete();
          } catch (_) {
            // 旧文件被占用时忽略。
          }
        }
      }
      await source.copy(target.path);
    } catch (e, s) {
      AppLogger.instance.error('font', '复制自定义字体失败', e, s);
      return false;
    }

    final file = target;
    final family = await _registerFontFile(file);
    if (family == null) {
      try {
        await file.delete();
      } catch (_) {
        // 忽略清理失败。
      }
      return false;
    }

    state = AppFontSelection.custom(
      family: family,
      name: originalName,
      path: file.path,
    );
    final store = ref.read(settingsStoreProvider);
    await store.patch({
      'fontKind': AppFontKind.custom.id,
      'customFontPath': file.path,
      'customFontName': originalName,
    });
    return true;
  }

  Future<void> _persist({required AppFontKind kind}) async {
    await ref.read(settingsStoreProvider).patch({'fontKind': kind.id});
  }
}

/// 启动时读取字体设置。
///
/// 未设置（旧版本）或自定义字体丢失时回退到内置字体，
/// 保证界面不会因缺字体而显示异常。
Future<AppFontSelection> loadAppFontSelection(SettingsStore store) async {
  final kind = store.read<String>('fontKind');
  if (kind == AppFontKind.system.id) return const AppFontSelection.system();
  if (kind == AppFontKind.custom.id) {
    final path = store.read<String>('customFontPath');
    final name = store.read<String>('customFontName');
    if (path != null && name != null) {
      final file = File(path);
      if (await file.exists()) {
        final family = await _registerFontFile(file);
        if (family != null) {
          return AppFontSelection.custom(
            family: family,
            name: name,
            path: path,
          );
        }
      }
    }
    AppLogger.instance.warn('font', '自定义字体不可用，已回退到内置字体');
    return const AppFontSelection.bundled();
  }
  return const AppFontSelection.bundled();
}

/// 把字体文件注册到 Flutter 引擎。
///
/// family 带时间戳：引擎的字体注册表只增不改，换字体时用新 family
/// 才能确保界面立即刷新。
Future<String?> _registerFontFile(File file) async {
  try {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    final family = 'PomeloCustom${DateTime.now().microsecondsSinceEpoch}';
    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
    return family;
  } catch (e, s) {
    AppLogger.instance.error('font', '注册字体失败: ${file.path}', e, s);
    return null;
  }
}

String _extensionOf(String name) {
  final dot = name.lastIndexOf('.');
  return dot < 0 ? '' : name.substring(dot).toLowerCase();
}
