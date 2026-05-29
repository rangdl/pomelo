import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late JavascriptRuntime jsRuntime;

  setUp(() {
    jsRuntime = getJavascriptRuntime(xhr: true);
  });

  tearDown(() {
    try {
      jsRuntime.dispose();
    } on Error catch (_) {}
  });

  // test('evaluate javascript', () {
  //   final result = jsRuntime.evaluate('Math.pow(5,3)');
  //   print('${result.rawResult}, ${result.stringResult}');
  //   print(
  //     '${result.rawResult.runtimeType}, ${result.stringResult.runtimeType}',
  //   );
  //   expect(result.rawResult, equals(125));
  //   expect(result.stringResult, equals('125'));
  // });

  // test('leak test', () async {
  //   final jsRt = getJavascriptRuntime();
  //   jsRt.evaluate('''
  //   delay = (delayInms) => {
  //     return new Promise((resolve) => setTimeout(resolve, delayInms));
  //   }
  //   ''');
  //   jsRt.evaluate('''
  //   async function asyncTest(del = 30) {
  //     try {
  //       console.log(`Starting \$\{del\}...`);
  //       while (del > 0) {
  //         console.log(del);
  //         await delay(1000);
  //         del--;
  //       }
  //       console.log(`Done \$\{del\}`);
  //       return `Done \$\{del\}`;
  //     } catch (e) {
  //       console.log(`Error in asyncTest: \$\{e\}`);
  //       return "Error";
  //     }
  //   }
  //   ''');
  //   await jsRt.enableFetch();
  //   jsRt.enableHandlePromises();
  //   jsRt.enableXhr();
  //   final promise = await jsRt.evaluateAsync('asyncTest(2)');
  //   jsRt.executePendingJob();
  //   JsEvalResult asyncResult = await jsRt.handlePromise(promise);
  //   print('${asyncResult.stringResult}, ${asyncResult.stringResult}');
  //   jsRt.dispose();
  // });

  // test('evaluate call', () async {
  //   final javascriptRuntime = getJavascriptRuntime();
  //   javascriptRuntime.onMessage('getDataAsync', (args) async {
  //     await Future.delayed(const Duration(seconds: 1));
  //     final int count = args['count'];
  //     Random rnd = Random();
  //     final result = <Map<String, int>>[];
  //     for (int i = 0; i < count; i++) {
  //       result.add({'key$i': rnd.nextInt(100)});
  //     }
  //     return result;
  //   });
  //   javascriptRuntime.evaluate("""
  //       async function test() {
  //         var value = Math.trunc(Math.random() * 100).toString();
  //         var asyncResult = await sendMessage("getDataAsync", JSON.stringify({"count": Math.trunc(Math.random() * 10)}));
  //         return {"expression": value, "asyncResult": asyncResult};
  //       }
  //       """);
  //   var asyncResult = await javascriptRuntime.evaluateAsync('test()');
  //   javascriptRuntime.executePendingJob();
  //   JsEvalResult result = await javascriptRuntime.handlePromise(asyncResult);
  //   print(result);
  // });

  // test('evaluate fetch', () async {
  //   final javascriptRuntime = getJavascriptRuntime();

  //   final qjsPolyfill = await rootBundle.loadString(
  //     'assets/js/qjs-polyfill.js',
  //   );
  //   final cryptoJs = await rootBundle.loadString('assets/js/crypto-js.js');
  //   final pako = await rootBundle.loadString('assets/js/pako.js');
  //   final jsrsasign = await rootBundle.loadString(
  //     'assets/js/jsrsasign-all-min.js',
  //   );
  //   final preload = await rootBundle.loadString('assets/js/qjs-preload.js');
  //   javascriptRuntime.evaluate(qjsPolyfill);
  //   javascriptRuntime.evaluate(cryptoJs);
  //   javascriptRuntime.evaluate(pako);
  //   javascriptRuntime.evaluate(jsrsasign);
  //   javascriptRuntime.evaluate(preload);
  //   print('加载js');
  //   // setFetchDebug(true);
  //   // setXhrDebug(true);

  //   await javascriptRuntime.enableFetch();
  //   javascriptRuntime.evaluate("""
  //       async function test() {
  //         const text = await fetch('http://192.168.0.200/test/rang/flower.js')
  //           .then((response)=>{
  //             console.log('请求状态: ', response.ok)
  //             console.log('请求状态码: ', response.status)
  //             return response.text()
  //           })
  //         return text;
  //       }
  //       """);
  //   var asyncResult = await javascriptRuntime.evaluateAsync('test()');
  //   javascriptRuntime.executePendingJob();
  //   JsEvalResult result = await javascriptRuntime.handlePromise(asyncResult);
  //   print(result);
  //   print(2);
  // });

  test('evaluate flutter_js', () async {
    final jsRuntime = getJavascriptRuntime();
    // 加载js运行环境
    final polyfill = await rootBundle.loadString('assets/js/polyfill.umd.js');
    jsRuntime.evaluate(polyfill);

    jsRuntime.evaluate("""
function aesEncrypt(buffer, mode, key, iv){
return globalThis.crypto.aesEncrypt(buffer, mode, key, iv)
}
""");

    jsRuntime.onMessage('__lx_native__', (arguments) {
      print('宿主函数打印参数列表: $arguments');
      print(arguments['buffer'] is Map<String, dynamic>);
      final buffer = arguments['buffer'] as String;
      // Uint8List bytes = Uint8List.fromList(
      //   hex.values.map((v) => v as int).toList(),
      // );
      // print(utf8.decode(bytes));

      final key = encrypt.Key.fromBase64(arguments['key'] as String);
      final iv = encrypt.IV.fromBase64(arguments['iv'] as String);
      print('密钥长度: ${key.bytes.length}');
      print('IV长度: ${iv.bytes.length}');
      final encrypter = encrypt.AES(
        key,
        mode: encrypt.AESMode.cbc,
        // padding: null,
      );
      final encrypted = encrypt.Encrypted.fromBase64(buffer);
      try {
        final decrypted = encrypter.decrypt(encrypted, iv: iv);
        print('解密结果: $decrypted');
        final text = utf8.decode(decrypted);
        print('解密结果: $text');
      } catch (e) {
        print(e);
      }

      // final text = utf8.decode(decrypted);
      // print('解密结果: $decrypted');

      // encrypter.decrypt(bytes)
      return '从宿主返回的字符串';
    });

    final result = jsRuntime.evaluate("""
const key = globalThis.crypto.randomBytes(32);
const iv = globalThis.crypto.randomBytes(16);
const plainText = 'Hello, this is a secret message!';
const buffer = Buffer.from(plainText, 'utf8');
const aes = globalThis.crypto.aesEncrypt(buffer, 'aes-256-cbc', key, iv);

sendMessage('__lx_native__', JSON.stringify({
  buffer: Buffer.from(aes, 'binary').toString('base64'),
  key: Buffer.from(key, 'binary').toString('base64'),
  iv: Buffer.from(iv, 'binary').toString('base64')
}))
""");
    print('js运行出错:${result.isError}');
    //     final result = jsRuntime.evaluate("typeof sendMessage");
    //     print('打印 sendMessage 类型: ${result.toString()}');

    //     String str = "Hello 你好";
    //     Uint8List bytes = Uint8List.fromList(utf8.encode(str));
    //     final resultAsync = await jsRuntime.evaluateAsync(
    //       // "sendMessage('__lx_native__', JSON.stringify({a: 1}))",
    //       "sendMessage('__lx_native__', JSON.stringify({buffer: new Uint8Array([72, 101, 108, 108, 111, 32, 228, 189, 160, 229, 165, 189])}))",
    //     );
    //     jsRuntime.executePendingJob();
    //     print('调用quickjs中桥接的宿主函数结果: $resultAsync');

    //     jsRuntime.evaluate("""
    // function rrr(buffer){
    // return buffer;
    // }
    // """);
    //     final resultUnit8Array = jsRuntime.evaluate("rrr($bytes)");
    //     final aaa = resultUnit8Array.rawResult;

    //     print(aaa.toString());

    //     print(utf8.decode(bytes));

    print('测试结束');
  });
}
