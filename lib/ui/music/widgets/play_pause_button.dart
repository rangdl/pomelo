import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/audio_player/model/audio_player.dart';
import 'package:pomelo/modules/audio_player/providers/audio_player.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PlayPauseButton extends HookConsumerWidget {
  final Song? song;
  const PlayPauseButton({this.song, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);

    return song == null
        ? IconButton.text(
            icon: Icon(
              audioPlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow_outlined,
            ),
            onPressed: () {
              audioPlayerState.playing
                  ? audioPlayer.pause()
                  : audioPlayer.resume();
            },
          )
        : IconButton.text(
            icon: Icon(
              audioPlayerState.activeTrack?.id == song!.id &&
                      audioPlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow_outlined,
            ),
            onPressed: () {
              if (audioPlayerState.activeTrack?.id == song!.id) {
                audioPlayerState.playing
                    ? audioPlayer.pause()
                    : audioPlayer.resume();
              } else {
                notifier.load([song!], autoPlay: true);
              }
            },
          );
  }
}
