// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import 'package:pomelo/services/dio/dio.dart';
import 'package:pomelo/services/logger/logger.dart';

const Map<String, int> _infoNames = {
  'name': 24,
  'description': 256,
  'author': 56,
  'homepage': 1024,
  'version': 36,
};

class SourceManager {
  late final String _id;
  final bool enable;
  final String script;
  Map<String, dynamic>? sources; // 初始化完成
  late final Map<String, String> _sourceInfo;
  late final JavascriptRuntime _jsRuntime;
  Timer? _timer;
  late final Map<String, Completer> _completers;

  String get id => _id;
  String get name => _sourceInfo['name'] ?? '';

  List<String> get platforms => [...(sources?.keys) ?? []];
  List<String> qualities(String platform) => [
    ...(sources?[platform]?['qualitys'] ?? []),
  ];

  SourceManager(
    this.script, {
    String? id,
    this.enable = false,
    Map<String, String>? sourceInfo,
    JavascriptRuntime? jsRuntime,
    Timer? timer,
    Map<String, Completer>? completers,
  }) {
    // setFetchDebug(true);
    // setXhrDebug(true);
    _id = id ?? "source__${Random().nextDouble().toString().substring(2)}";
    _jsRuntime = jsRuntime ?? getJavascriptRuntime();
    _sourceInfo = sourceInfo ?? parseLxMusicScriptInfo(script);
    _timer = timer;
    _completers = completers ?? {};
  }

  init() async {
    // _completers['init'] = Completer<String>();
    final completer = _addCompleter('init');
    final cryptoJs = await rootBundle.loadString('assets/js/crypto-js.js');
    final qjsPolyfill = await rootBundle.loadString(
      'assets/js/qjs-polyfill.js',
    );
    final pako = await rootBundle.loadString('assets/js/pako.js');
    final jsrsasign = await rootBundle.loadString(
      'assets/js/jsrsasign-all-min.js',
    );
    final preload = await rootBundle.loadString('assets/js/qjs-preload.js');
    _jsRuntime.evaluate(cryptoJs);
    _jsRuntime.evaluate(qjsPolyfill);
    _jsRuntime.evaluate(pako);
    _jsRuntime.evaluate(jsrsasign);
    _jsRuntime.evaluate(preload);
    _jsRuntime.evaluate("""
    var __native_xhrRequests = {};
    var __native_idRequest = -1;
    function __native_send_request() {
      __native_idRequest += 1;
      var cb = arguments[4];
      __native_xhrRequests[__native_idRequest] = {
        callback: function(error, responseInfo) {
        if (error){
          cb(error, null, null);
          return
        }
        const raw = globalThis.lx.utils.buffer.from(responseInfo.body)
        responseInfo.body = JSON.parse(responseInfo.body)
        cb(error, {
          raw: raw,
          bytes: raw,
          ...responseInfo
          }, responseInfo.body);
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
    // 桥接 事件监听 init
    _jsRuntime.onMessage('init', (arguments) {
      final status = arguments['status'] ?? false;
      if (status is bool && status) {
        sources = arguments['data']['sources'] as Map<String, dynamic>;
      }
      _completeCompleter('init', '');
    });
    // 桥接 事件监听 showUpdateAlert
    _jsRuntime.onMessage('showUpdateAlert', (arguments) {
      print(arguments);
    });
    // 桥接 事件监听 request
    _jsRuntime.onMessage('request', (arguments) {
      print(arguments);
    });
    // 桥接 事件监听 cancelRequest
    _jsRuntime.onMessage('cancelRequest', (arguments) {
      print(arguments);
    });
    // 桥接 事件监听 response
    _jsRuntime.onMessage('response', (arguments) {
      final status = arguments['status'] ?? false;
      final requestKey = arguments['data']['requestKey'] as String;
      if (status is bool && status) {
        try {
          final url = arguments['data']['data']['url'] as String;
          _completeCompleter(requestKey, url);
        } catch (e, stack) {
          AppLogger.reportError(e, stack);
        }
      } else {
        _completeCompleter(requestKey, '');
      }
    });
    // 桥接http
    _jsRuntime.onMessage('nativeSendRequest', (arguments) {
      try {
        String? method = arguments[0];
        String? url = arguments[1];
        Object? body = arguments[2];
        Map? options = arguments[3];
        int? idRequest = arguments[4];
        Map<String, dynamic> headers = options?['headers'] ?? {};
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
        if (headers['User-Agent'] == null) {
          headers['User-Agent'] =
              'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36';
        }
        int timeout = options?['response_timeout'] ?? 60000;
        globalDio
            .request(
              url!,
              data: body,
              options: Options(
                method: method,
                headers: headers,
                connectTimeout: const Duration(seconds: 5),
                sendTimeout: Duration(milliseconds: timeout),
                receiveTimeout: Duration(milliseconds: timeout),
              ),
            )
            .then((response) {
              final responseBody = jsonEncode(response.data);
              Map<String, String> headersMap = {};
              response.headers.forEach((name, values) {
                headersMap[name] = values.join(', ');
              });

              final resp = {
                'statusCode': response.statusCode,
                'statusMessage': response.statusMessage,
                'headers': headersMap,
                // 'bytes': responseBody,
                // 'raw': responseBody,
                'body': responseBody,
              };
              final respText = jsonEncode(resp);
              _jsRuntime.evaluate(
                "globalThis.__native_xhrRequests[$idRequest].callback(null,$respText)",
              );
            })
            .catchError((err) {
              _jsRuntime.evaluate(
                "globalThis.__native_xhrRequests[$idRequest].callback(`$err.message`,null)",
              );
            });
      } catch (e) {
        print(e);
      }
    });
    print('加载框架');

    final infoText = jsonEncode(_sourceInfo);
    String rawScript = base64.encode(utf8.encode(script));
    _jsRuntime.evaluate('setup(`$infoText`, `$rawScript`)');

    _timer?.cancel(); // 核心：取消定时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_completers.isNotEmpty) {
        print('定时刷新 quickjs 的Promise状态...');
        _jsRuntime.executePendingJob();
      }
    });
    await completer.future;
  }

  Future<String> musicUrl(
    Map<String, String> musicInfo, {
    quality = '128k',
  }) async {
    print('从 $name 获取');
    final requestKey =
        "request__${Random().nextDouble().toString().substring(2)}";
    final completer = _addCompleter(requestKey);
    final data = {
      'requestKey': requestKey,
      'data': {
        'source': musicInfo['source'],
        'action': 'musicUrl',
        'info': {'type': quality, 'musicInfo': musicInfo},
      },
    };
    final dataText = jsonEncode(data);
    final dataTextBase64 = base64.encode(utf8.encode(dataText));
    _jsRuntime.evaluate('jsCall(`$dataTextBase64`)');
    return await completer.future;
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

  Completer<String> _addCompleter(String key) {
    final completer = Completer<String>();
    _completers[key] = completer;
    return completer;
  }

  void _completeCompleter(String key, String value) {
    _completers.remove(key)?.complete(value);
  }

  void dispose() {
    _timer?.cancel(); // 核心：取消定时器
    _jsRuntime.dispose();
  }

  SourceManager copyWith({
    String? id,
    bool? enable,
    String? script,
    Map<String, String>? sourceInfo,
    JavascriptRuntime? jsRuntime,
    Timer? timer,
    Map<String, Completer>? completers,
  }) {
    return SourceManager(
      id: id ?? _id,
      script ?? this.script,
      enable: enable ?? this.enable,
      sourceInfo: sourceInfo ?? _sourceInfo,
      jsRuntime: jsRuntime ?? _jsRuntime,
      timer: _timer ?? timer,
      completers: completers,
    );
  }
}
