// 基础占位测试：确保 test/ 目录非空且 flutter test 可通过。
// 具体业务逻辑的测试见 test/ 下其它文件（playback / scripts / shared 等）。
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('smoke', () {
    expect(1 + 1, 2);
  });
}
