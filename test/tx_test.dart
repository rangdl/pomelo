import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/services/dio/dio.dart';
import 'package:pomelo/services/source/searcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {});

  test('tx search', () async {
    print('tx test');
    final txSearcher = TxSearcher(dio: globalDio);
    final search = await txSearcher.search('周杰伦');
    print(search);
    print('1');
  });
}
