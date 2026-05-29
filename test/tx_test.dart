import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/services/dio/dio.dart';
import 'package:pomelo/services/source/tx/searcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {});

  test('tx search', () async {
    // print('tx test');
    // final txSearcher = TxSearcher(dio: globalDio);
    // final search = await txSearcher.search('周杰伦');
    // print(search);
    // print('1');
    String str = 'tx-0039MnYb0qxYhV';
    RegExp regExp = RegExp(r"(.*?)-(.*)");
    // 获取第一个匹配结果
    Match? match = regExp.firstMatch(str);

    if (match != null) {
      // group(0) 是整个匹配的文本
      print("完整匹配: ${match.group(0)}");
      // group(1) 是第一个捕获组
      print("姓名: ${match.group(1)}");
      // group(2) 是第二个捕获组
      print("年龄: ${match.group(2)}");
      // group(3) 是第三个捕获组
      print("邮箱: ${match.group(3)}");
    } else {
      print("未匹配到内容");
    }
  });
}
