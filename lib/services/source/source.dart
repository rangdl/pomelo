import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:pomelo/services/dio/dio.dart';

const Map<String, int> _infoNames = {
  'name': 24,
  'description': 256,
  'author': 56,
  'homepage': 1024,
  'version': 36,
};

class SourceManager {
  late final JavascriptRuntime jsRuntime;

  SourceManager() {
    // setFetchDebug(true);
    // setXhrDebug(true);
    jsRuntime = getJavascriptRuntime();
  }
  init() async {
    final qjsPolyfill = await rootBundle.loadString(
      'assets/js/qjs-polyfill.js',
    );
    final cryptoJs = await rootBundle.loadString('assets/js/crypto-js.js');
    final pako = await rootBundle.loadString('assets/js/pako.js');
    final jsrsasign = await rootBundle.loadString(
      'assets/js/jsrsasign-all-min.js',
    );
    final preload = await rootBundle.loadString('assets/js/qjs-preload.js');
    jsRuntime.evaluate(qjsPolyfill);
    jsRuntime.evaluate(cryptoJs);
    jsRuntime.evaluate(pako);
    jsRuntime.evaluate(jsrsasign);
    jsRuntime.evaluate(preload);
    jsRuntime.evaluate("""
    var __native_xhrRequests = {};
    var __native_idRequest = -1;
    function __native_send_request() {
      __native_idRequest += 1;
      var cb = arguments[4];
      __native_xhrRequests[__native_idRequest] = {
        callback: function(responseInfo, responseText, error) {
          cb(error, responseInfo, responseText);
        }
      };
      var args = [];
      args[0] = arguments[0];
      args[1] = arguments[1];
      args[2] = arguments[2];
      args[3] = arguments[3];
      args[4] = __native_idRequest;
      sendMessage('nativeSendRequest', JSON.stringify(args));
      return {request: {}}
    }
    """);
    jsRuntime.onMessage('nativeSendRequest', (arguments) {
      print('native_request');
      print(arguments);
      try {
        String? method = arguments[0];
        String? url = arguments[1];
        Object? body = arguments[2];
        Map? options = arguments[3];
        int? idRequest = arguments[4];
        Map<String, String> headers = {};
        // headersList.forEach((header) {
        //   // final headerMatch = regexpHeader.allMatches(value).first;
        //   // String? headerName = headerMatch.group(0);
        //   // String? headerValue = headerMatch.group(1);
        //   // if (headerName != null) {
        //   //   headers[headerName] = headerValue ?? '';
        //   // }
        //   String headerKey = header[0];
        //   headers[headerKey] = header[1];
        // });
        globalDio.request(url!, data: body).then((response) {
          final body = jsonEncode(response.data);
          Map<String, String> headersMap = {};
          response.headers.forEach((name, values) {
            headersMap[name] = values.join(', ');
          });

          final resp = {
            'statusCode': response.statusCode,
            'statusMessage': response.statusMessage,
            'headers': headersMap,
            'raw': body,
            'body': body,
            // 'bytes': body,
          };
          final respText = jsonEncode(resp);
          jsRuntime.evaluate(
            "globalThis.__native_xhrRequests[$idRequest].callback($respText,$body, null)",
          );
        });
      } catch (e) {
        print(e);
      }
    });
    print('加载框架');
  }

  // 加载url
  loadUrl(String url) async {
    final response = await globalDio.get(url);
    final script = response.toString();
    final info = parseLxMusicScriptInfo(script);
    final infoText = jsonEncode(info);
    String rawScript = base64.encode(utf8.encode(script));

    var result = jsRuntime.evaluate('setup(`$infoText`, `$rawScript`)');
    print(result);
    print('加载源');
  }

  loadAssets() async {
    final script = await rootBundle.loadString('assets/js/juhe.js');
    final info = parseLxMusicScriptInfo(script);
    final infoText = jsonEncode(info);
    String rawScript = base64.encode(utf8.encode(script));

    var result = jsRuntime.evaluate('setup(`$infoText`, `$rawScript`)');
    print(result);
    print('加载本地源');
  }

  musicUrl() {
    final requestKey =
        "request__${Random().nextDouble().toString().substring(2)}";
    final data = {
      'requestKey': requestKey,
      'data': {
        'source': 'tx',
        'action': 'musicUrl',
        'info': {
          'type': '128k',
          'musicInfo': {"songmid": "0039MnYb0qxYhV"},
        },
      },
    };
    final dataText = jsonEncode(data);
    final dataTextBase64 = base64.encode(utf8.encode(dataText));
    jsRuntime.evaluate('jsCall(`$dataTextBase64`)');
    print('从源获取');
  }

  Map<String, String> parseLxMusicScriptInfo(String script) {
    final RegExp headerRegex = RegExp(r'/\*[\s\S]+?\*/');
    final Match? headerMatch = headerRegex.firstMatch(script.trim());
    final Map<String, String> infos = {};

    if (headerMatch != null) {
      String header = headerMatch.group(0)!;
      List<String> lines = header.split(RegExp(r'\r?\n'));
      final RegExp lineRegex = RegExp(r'^\s?\*\s?@(\w+)\s(.+)$');

      for (String line in lines) {
        final Match? match = lineRegex.firstMatch(line);
        if (match == null) continue;
        final String key = match.group(1)!;
        if (!_infoNames.containsKey(key)) continue;
        final String value = match.group(2)!.trim();
        infos[key] = value;
      }
    }

    for (final MapEntry<String, int> entry in _infoNames.entries) {
      final String key = entry.key;
      final int maxLen = entry.value;
      infos.putIfAbsent(key, () => '');
      if (infos[key]!.length > maxLen) {
        infos[key] = infos[key]!.substring(0, maxLen) + '...';
      }
    }
    return infos;
  }
}
