import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
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
