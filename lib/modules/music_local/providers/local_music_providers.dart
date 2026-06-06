import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/local_music_provider.dart';

/// 本地音乐提供者实例
final localMusicProviderProvider = Provider<LocalMusicProvider>((ref) {
  return LocalMusicProvider();
});
