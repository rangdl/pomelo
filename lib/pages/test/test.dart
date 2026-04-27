import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType, ListTile;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:pomelo/collections/routes.gr.dart';
import 'package:pomelo/components/titlebar/titlebar.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

@RoutePage()
class TestPage extends HookConsumerWidget {
  static const name = "test";
  const TestPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();

    final file = File('C:/Users/admin/Downloads/新建文件夹/周杰伦 - 晴天.mp3');

    return Scaffold(
      headers: const [TitleBar(title: Text('测试'))],
      child: Scrollbar(
        controller: controller,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1366),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: Material(
                type: MaterialType.transparency,
                child: ListView(
                  controller: controller,
                  children: [
                    TextButton(
                      onPressed: () async {
                        print(await file.exists());
                        final track = SpotubeTrackObject.localTrackFromFile(
                          file,
                          metadata: await MetadataGod.readMetadata(
                            file: file.path,
                          ),
                        );
                        ref.read(audioPlayerProvider.notifier).load([
                          track,
                        ], autoPlay: true);
                      },
                      child: const Text('播放'),
                    ),
                    TextButton(
                      onPressed: () async {
                        audioPlayer.pause();
                      },
                      child: const Text('暂停'),
                    ),
                    TextButton(
                      onPressed: () async {
                        audioPlayer.resume();
                      },
                      child: const Text('继续播放'),
                    ),
                    TextButton(
                      onPressed: () async {
                        context.router.push(
                          const CupertinoSliverRefreshDemoRoute(),
                        );
                      },
                      child: const Text('刷新demo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@RoutePage()
class CupertinoSliverRefreshDemoPage extends StatelessWidget {
  static const name = "testSliverRefresh";
  const CupertinoSliverRefreshDemoPage({super.key});

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    // 更新数据逻辑
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('My App'), floating: true),
        // iOS 风格的下拉刷新，直接作为第一个 sliver
        CupertinoSliverRefreshControl(
          onRefresh: _onRefresh,
          refreshTriggerPullDistance: 100.0,
          refreshIndicatorExtent: 60.0,
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(title: Text('Item $index')),
            childCount: 100,
          ),
        ),
      ],
    );
  }
}
