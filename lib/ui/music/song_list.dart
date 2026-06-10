import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌曲列表组件
class SongList extends ConsumerWidget {
  final List<Song> songs;

  const SongList({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Card(
            child: ListTile(
              leading: Icon(Icons.music_note, color: colorScheme.primary, size: 24),
              title: Text(song.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${song.artist}  ·  ${song.formattedDuration}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                song.source.name,
                style: const TextStyle(fontSize: 12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        );
      },
    );
  }
}
