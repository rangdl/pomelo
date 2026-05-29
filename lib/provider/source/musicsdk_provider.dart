import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MusicsdkNotifier extends Notifier<JavascriptRuntime> {
  @override
  JavascriptRuntime build() {
    Future.microtask(() => init());
    return getJavascriptRuntime(xhr: false);
  }

  Future<void> init() async {
    // 加载 sdk
    final musicsdk = await rootBundle.loadString('assets/js/musicsdk.umd.js');
    final result = state.evaluate(musicsdk);
    if (result.isError) {
      print('js: ${result.toString()}');
    } else {
      print('musicsdk加载成功');
    }
  }
}

final musicsdkProvider = NotifierProvider<MusicsdkNotifier, JavascriptRuntime>(
  MusicsdkNotifier.new,
);
