import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'plugin_manager_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.app});

  final AppState app;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        if (!app.ready) {
          return Scaffold(
            body: Center(
              child: app.initError == null
                  ? const CircularProgressIndicator()
                  : Text('初始化失败: ${app.initError}'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pomelo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.extension),
                tooltip: '插件管理',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PluginManagerScreen(app: app),
                    ),
                  );
                  // 插件可能在管理页被增删/启停，返回后必须重建
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
          body: app.pluginStore.plugins.isEmpty
              ? const _EmptyPlugins()
              : SearchScreen(app: app),
          bottomNavigationBar: _NowPlayingBar(app: app),
        );
      },
    );
  }
}

class _EmptyPlugins extends StatelessWidget {
  const _EmptyPlugins();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.extension_off, size: 56),
            const SizedBox(height: 12),
            const Text('还没有安装插件', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              '点右上角进入插件管理，粘贴 JS 插件源码即可安装。',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    if (app.nowPlaying == null) return const SizedBox.shrink();
    final item = app.nowPlaying!;
    return StreamBuilder<bool>(
      stream: app.player.playingStream,
      initialData: app.player.playing,
      builder: (context, snap) {
        final playing = snap.data ?? false;
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.music_note),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item['title'] ?? '未知歌曲'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item['artist'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<Duration>(
                    stream: app.player.positionStream,
                    builder: (context, pos) {
                      return Text(
                        _fmt(pos.data ?? Duration.zero),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () => playing ? app.player.pause() : app.player.play(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
