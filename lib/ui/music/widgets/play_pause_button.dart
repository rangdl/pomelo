import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PlayPauseButton extends HookConsumerWidget {
  final Track? track;
  const PlayPauseButton({this.track, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerServiceProvider);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);

    return track == null
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
              audioPlayerState.activeTrack?.id == track!.id &&
                      audioPlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow_outlined,
            ),
            onPressed: () {
              if (audioPlayerState.activeTrack?.id == track!.id) {
                audioPlayerState.playing
                    ? audioPlayer.pause()
                    : audioPlayer.resume();
              } else {
                notifier.load([track!], autoPlay: true);
              }
            },
          );
  }
}
