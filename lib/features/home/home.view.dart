// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = Fluxy.find<HomeController>();
    // return Fx(
    //   () => RxLayout(currentIndex: controller.currentIndex, tabs: tabs),
    // );
    // final file = File('assets/mp3/test.mp3');
    final file = File('C:/Users/admin/Downloads/新建文件夹/周杰伦 - 晴天.mp3');

    return Column(
      children: [
        TextButton(
          onPressed: () async {
            print(await file.exists());
            final track = SpotubeTrackObject.localTrackFromFile(file);
            ref.read(audioPlayerProvider.notifier).load([
              track,
            ], autoPlay: true);
          },
          child: Text('播放'),
        ),
        TextButton(
          onPressed: () async {
            audioPlayer.pause();
          },
          child: Text('暂停'),
        ),
        TextButton(
          onPressed: () async {
            audioPlayer.resume();
          },
          child: Text('继续播放'),
        ),
        Text(
          '在 Flutter 中实现毛玻璃效果，主要使用 BackdropFilter 组件结合 ImageFilter.blur 来实现。在 Flutter 中实现毛玻璃效果，主要使用 BackdropFilter 组件结合 ImageFilter.blur 来实现。',
        ),
      ],
    );
  }
}
