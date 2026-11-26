import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/shared/storage/json_file_store.dart';

void main() {
  late Directory dir;
  late File file;
  late JsonFileStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pomelo_store_test');
    file = File('${dir.path}/data.json');
    store = JsonFileStore(file);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('文件不存在时读取返回 null', () async {
    expect(await store.read(), isNull);
  });

  test('写入后能原样读回，并带 schemaVersion 包装', () async {
    await store.write({
      'a': 1,
      'list': [1, 2, 3],
    });
    expect(await store.read(), {
      'a': 1,
      'list': [1, 2, 3],
    });
    final raw = jsonDecode(await file.readAsString()) as Map;
    expect(raw['schemaVersion'], JsonFileStore.schemaVersion);
  });

  test('兼容旧版裸 JSON', () async {
    await file.writeAsString('{"legacy":true}');
    expect(await store.read(), {'legacy': true});
  });

  test('主文件损坏时回退到备份', () async {
    await store.write({'v': 1});
    await store.write({'v': 2}); // 此时 .bak 是 {"v":1}
    await file.writeAsString('{ 坏了');
    expect(await store.read(), {'v': 1});
  });

  test('来自更高版本的数据视为不可用', () async {
    await file.writeAsString(
      jsonEncode({
        'schemaVersion': 99,
        'data': {'x': 1},
      }),
    );
    expect(await store.read(), isNull);
  });

  test('连续写入按顺序落盘，最后写入生效', () async {
    await Future.wait([
      store.write({'n': 1}),
      store.write({'n': 2}),
      store.write({'n': 3}),
    ]);
    expect(await store.read(), {'n': 3});
  });
}
