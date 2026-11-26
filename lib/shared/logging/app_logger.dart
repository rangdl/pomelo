import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 应用运行日志：把错误与关键运行记录落盘，方便事后排查。
///
/// 设计取舍：
/// - 位置：`<应用支持目录>/logs/app.log`；
/// - 单文件超过 [maxBytes] 自动滚动为 app.1.log…，最多保留 [maxFiles] 个文件，
///   避免长期运行把磁盘写满；
/// - 写入串行 + flush：进程被强杀时最多丢正在写的一行；
/// - 日志本身出错不影响主流程（静默降级到控制台）。
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  /// 单个日志文件大小上限（2MB）。
  static const int maxBytes = 2 * 1024 * 1024;

  /// 连同当前文件最多保留的文件数。
  static const int maxFiles = 5;

  /// 单条堆栈最多记录的长度，避免一条异常写爆日志。
  static const int maxStackChars = 4000;

  Directory? _dir;
  File? _file;
  int _written = 0;
  Future<void> _queue = Future<void>.value();
  bool _installed = false;

  /// 日志目录（初始化完成前为 null）。
  Directory? get directory => _dir;

  /// 初始化日志目录并挂接全局错误采集，越早调用越好。
  Future<void> init() async {
    // 即使日志目录不可用，也要先接管全局错误，至少能看到控制台信息。
    installErrorHandlers();
    try {
      final support = await getApplicationSupportDirectory();
      final dir = Directory('${support.path}${Platform.pathSeparator}logs');
      await dir.create(recursive: true);
      _dir = dir;
      final file = File('${dir.path}${Platform.pathSeparator}app.log');
      _file = file;
      _written = await file.exists() ? await file.length() : 0;
      await _rotate(incoming: 0);
      info('app', '日志已启动');
    } catch (e) {
      // 日志目录不可用时只保留控制台输出。
      debugPrint('[pomelo] 日志初始化失败: $e');
    }
  }

  /// 挂接 Flutter / 平台 / debugPrint 三类错误来源。
  ///
  /// debugPrint 桥接后，代码里已有的 `debugPrint('[pomelo] …失败')` 分支
  /// 无需逐处修改即可进入日志文件。
  void installErrorHandlers() {
    if (_installed) return;
    _installed = true;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      error(
        'flutter',
        details.exceptionAsString(),
        details.exception,
        details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (exception, stack) {
      error('platform', '$exception', exception, stack);
      // 已记录，吞掉异常避免桌面端直接退出。
      return true;
    };

    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      original(message, wrapWidth: wrapWidth);
      if (message == null || message.trim().isEmpty) return;
      _append('I', 'app', message);
    };
  }

  void info(String tag, String message) => _append('I', tag, message);

  void warn(
    String tag,
    String message, [
    Object? exception,
    StackTrace? stack,
  ]) => _append('W', tag, message, exception, stack);

  void error(
    String tag,
    String message, [
    Object? exception,
    StackTrace? stack,
  ]) => _append('E', tag, message, exception, stack);

  /// 读取最近日志，返回时间正序（旧 → 新）。
  Future<List<String>> readRecent({int maxLines = 500}) async {
    final dir = _dir;
    if (dir == null) return const [];
    final files = <File>[];
    for (var i = 0; i < maxFiles; i++) {
      final f = File('${dir.path}${Platform.pathSeparator}${_fileName(i)}');
      if (await f.exists()) files.add(f);
    }

    final collected = <String>[];
    for (final file in files) {
      if (collected.length >= maxLines) break;
      try {
        final lines = const LineSplitter().convert(await file.readAsString());
        collected.addAll(lines.reversed.take(maxLines - collected.length));
      } catch (_) {
        // 单个文件读失败（被占用等）跳过，其它文件仍可查看。
      }
    }
    return collected.reversed.toList();
  }

  /// 导出最近的日志到指定文件，返回导出的行数。
  Future<int> exportTo(File target) async {
    final lines = await readRecent(maxLines: 10000);
    final buffer = StringBuffer()
      ..writeln('Pomelo 运行日志')
      ..writeln('导出时间：${_formatTime(DateTime.now())}')
      ..writeln(
        '系统：${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      )
      ..writeln('日志目录：${_dir?.path ?? '未初始化'}')
      ..writeln('-' * 60)
      ..writeln(lines.join('\n'));
    await target.parent.create(recursive: true);
    await target.writeAsString(buffer.toString(), flush: true);
    return lines.length;
  }

  /// 清空所有日志文件。
  Future<void> clear() async {
    final dir = _dir;
    if (dir == null) return;
    _queue = _queue.then((_) async {
      for (var i = 0; i < maxFiles; i++) {
        try {
          final f = File('${dir.path}${Platform.pathSeparator}${_fileName(i)}');
          if (await f.exists()) await f.delete();
        } catch (_) {
          // 单个文件删不掉时忽略，不影响其它文件。
        }
      }
      _written = 0;
    });
    await _queue;
  }

  String _fileName(int index) => index == 0 ? 'app.log' : 'app.$index.log';

  void _append(
    String level,
    String tag,
    String message, [
    Object? exception,
    StackTrace? stack,
  ]) {
    final file = _file;
    if (file == null) return; // 未初始化：控制台已由 debugPrint 输出。

    final buffer = StringBuffer()
      ..write('${_formatTime(DateTime.now())} [$level] $tag: $message');
    final detail = exception?.toString();
    if (detail != null && detail != message) buffer.write('\n  $detail');
    if (stack != null) {
      final text = stack.toString();
      buffer.write(
        '\n  ${text.length > maxStackChars ? text.substring(0, maxStackChars) : text}',
      );
    }
    final line = '${buffer.toString().replaceAll('\r\n', '\n')}\n';
    final bytes = utf8.encode(line).length;
    _queue = _queue.then((_) => _writeNow(file, line, bytes));
  }

  Future<void> _writeNow(File file, String line, int bytes) async {
    try {
      await _rotate(incoming: bytes);
      await file.writeAsString(line, mode: FileMode.append, flush: true);
      _written += bytes;
    } catch (_) {
      // 日志写失败不能影响主流程。
    }
  }

  /// 当前文件放不下时滚动：app.log → app.1.log → …，超出上限的最旧文件删除。
  Future<void> _rotate({required int incoming}) async {
    final dir = _dir;
    final file = _file;
    if (dir == null || file == null) return;
    if (_written + incoming <= maxBytes) return;
    try {
      final oldest = File(
        '${dir.path}${Platform.pathSeparator}${_fileName(maxFiles - 1)}',
      );
      if (await oldest.exists()) await oldest.delete();
      for (var i = maxFiles - 2; i >= 1; i--) {
        final from = File(
          '${dir.path}${Platform.pathSeparator}${_fileName(i)}',
        );
        if (await from.exists()) {
          await from.rename(
            '${dir.path}${Platform.pathSeparator}${_fileName(i + 1)}',
          );
        }
      }
      if (await file.exists()) {
        await file.rename(
          '${dir.path}${Platform.pathSeparator}${_fileName(1)}',
        );
      }
      _written = 0;
    } catch (e) {
      debugPrint('[pomelo] 日志滚动失败: $e');
    }
  }

  static String _formatTime(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    String three(int v) => v.toString().padLeft(3, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}:${two(time.second)}.'
        '${three(time.millisecond)}';
  }
}
