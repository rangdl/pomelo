import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';

/// 歌单引用 — 用于在 Home Tab 内联打开歌单详情
@immutable
class PlaylistRef {
  final String playlistId;
  final String sourceId;
  final String playlistName;
  final String? coverUrl;
  final String creator;

  const PlaylistRef({
    required this.playlistId,
    required this.sourceId,
    required this.playlistName,
    this.coverUrl,
    this.creator = '',
  });
}

/// Home Tab 内联导航状态
///
/// 通过 [homeNavProvider] 统一管理 Home Tab 的视图切换，
/// 桌面端侧边栏按钮、移动端首页顶部卡片按钮以及歌单网格点击均通过此状态驱动。
sealed class HomeNav {
  const HomeNav();
}

/// 默认视图（排行榜/歌单 tabs）
class HomeNavNormal extends HomeNav {
  const HomeNavNormal();
}

/// 默认列表视图
class HomeNavDefaultList extends HomeNav {
  const HomeNavDefaultList();
}

/// 我的收藏视图
class HomeNavFavorites extends HomeNav {
  const HomeNavFavorites();
}

/// 歌单详情视图
class HomeNavPlaylist extends HomeNav {
  final PlaylistRef ref;
  const HomeNavPlaylist(this.ref);
}

/// Home Tab 导航状态管理
///
/// 切换音乐来源/库时自动重置为默认视图，避免 stale 状态导致 UI 错配。
final homeNavProvider = NotifierProvider<HomeNavNotifier, HomeNav>(
  HomeNavNotifier.new,
);

class HomeNavNotifier extends Notifier<HomeNav> {
  @override
  HomeNav build() {
    // 切换来源/库时重置为默认视图
    ref.watch(selectedSourceProvider);
    return const HomeNavNormal();
  }

  void showNormal() => state = const HomeNavNormal();
  void showDefaultList() => state = const HomeNavDefaultList();
  void showFavorites() => state = const HomeNavFavorites();
  void showPlaylist(PlaylistRef ref) => state = HomeNavPlaylist(ref);
}
