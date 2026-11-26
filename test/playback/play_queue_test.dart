import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/playback/domain/play_queue.dart';
import 'package:pomelo/features/playback/presentation/playback_providers.dart';

Map<String, dynamic> _track(String id) => {'id': id, 'title': id};

void main() {
  late ProviderContainer container;
  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  PlayQueue queue() => container.read(playQueueProvider.notifier);
  List<String> ids() =>
      container.read(playQueueProvider).map((e) => '${e['id']}').toList();
  String? currentId() => '${queue().current?['id']}';

  test('appendAll 追加到末尾且不改变当前曲目', () {
    queue().setAll([_track('a'), _track('b')], index: 1);
    queue().appendAll([_track('c'), _track('d')]);
    expect(ids(), ['a', 'b', 'c', 'd']);
    expect(currentId(), 'b');
  });

  test('队列为空时 appendAll 直接成为当前队列', () {
    queue().appendAll([_track('x')]);
    expect(ids(), ['x']);
    expect(queue().index, 0);
  });

  test('insertNext 插到当前曲目之后', () {
    queue().setAll([_track('a'), _track('b'), _track('c')], index: 0);
    queue().insertNext([_track('n1'), _track('n2')]);
    expect(ids(), ['a', 'n1', 'n2', 'b', 'c']);
    expect(currentId(), 'a');
  });

  test('move 拖动后当前播放曲目不变', () {
    queue().setAll([
      _track('a'),
      _track('b'),
      _track('c'),
      _track('d'),
    ], index: 2);
    // 把第一首拖到末尾：c 的索引从 2 变成 1。
    queue().move(0, 3);
    expect(ids(), ['b', 'c', 'd', 'a']);
    expect(currentId(), 'c');
    expect(queue().index, 1);
  });

  test('move 拖动当前曲目时索引跟随', () {
    queue().setAll([_track('a'), _track('b'), _track('c')], index: 1);
    queue().move(1, 0);
    expect(ids(), ['b', 'a', 'c']);
    expect(currentId(), 'b');
    expect(queue().index, 0);
  });

  test('removeAt 删除当前曲目后回退到前一首', () {
    queue().setAll([_track('a'), _track('b'), _track('c')], index: 2);
    expect(queue().removeAt(2), 1);
    expect(ids(), ['a', 'b']);
    expect(currentId(), 'b');
  });

  test('removeAt 删除当前曲目之前的项只前移索引', () {
    queue().setAll([_track('a'), _track('b'), _track('c')], index: 2);
    final index = queue().removeAt(0);
    expect(index, 1);
    expect(currentId(), 'c');
  });

  test('shuffle 打乱后仍指向原来播放的曲目', () {
    final items = List.generate(20, (i) => _track('t$i'));
    queue().setAll(items, index: 7);
    queue().shuffle();
    expect(container.read(playQueueProvider).length, 20);
    expect(currentId(), 't7');
  });

  test('setAll 越界索引会被夹到合法范围', () {
    queue().setAll([_track('a'), _track('b')], index: 99);
    expect(queue().index, 1);
    queue().setAll(const [], index: 5);
    expect(queue().index, 0);
    expect(queue().current, isNull);
  });
}
