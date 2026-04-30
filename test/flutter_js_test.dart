import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/xhr.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pomelo/services/dio/dio.dart';

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

  test('evaluate fetch', () async {
    final javascriptRuntime = getJavascriptRuntime();

    final qjsPolyfill = await rootBundle.loadString(
      'assets/js/qjs-polyfill.js',
    );
    final cryptoJs = await rootBundle.loadString('assets/js/crypto-js.js');
    final pako = await rootBundle.loadString('assets/js/pako.js');
    final jsrsasign = await rootBundle.loadString(
      'assets/js/jsrsasign-all-min.js',
    );
    final preload = await rootBundle.loadString('assets/js/qjs-preload.js');
    javascriptRuntime.evaluate(qjsPolyfill);
    javascriptRuntime.evaluate(cryptoJs);
    javascriptRuntime.evaluate(pako);
    javascriptRuntime.evaluate(jsrsasign);
    javascriptRuntime.evaluate(preload);
    print('加载js');
    // setFetchDebug(true);
    // setXhrDebug(true);

    await javascriptRuntime.enableFetch();
    javascriptRuntime.evaluate("""
        async function test() {
          const text = await fetch('http://192.168.0.200/test/rang/flower.js')
            .then((response)=>{
              console.log('请求状态: ', response.ok)
              console.log('请求状态码: ', response.status)
              return response.text()
            })
          return text;
        }
        """);
    var asyncResult = await javascriptRuntime.evaluateAsync('test()');
    javascriptRuntime.executePendingJob();
    JsEvalResult result = await javascriptRuntime.handlePromise(asyncResult);
    print(result);
    print(2);
  });
}
