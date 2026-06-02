import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:pomelo/models/database/database.dart';
import 'package:pomelo/services/logger/logger.dart';

class JsEngine {
  final Dio _dio;
  late final JavascriptRuntime _jsRuntime;
  JavascriptRuntime get jsRuntime => _jsRuntime;
  JsEngine({JavascriptRuntime? jsRuntime, Dio? dio})
    : _dio = dio ?? Dio(),
      _jsRuntime = jsRuntime ?? getJavascriptRuntime(xhr: false) {
    init();
  }
  void init() {
    _setupFetch();
  }

  void _setupFetch() {
    _jsRuntime.evaluate("""
var __native_fetch_callback = {};
var __native_fetch_id = -1;
function fetch(url, options) {
  __native_fetch_id += 1;
  options = options || {};
  var method=(options.method||'GET').toUpperCase();
  var reqHeaders={};
  if(options.headers){
    if(options.headers instanceof Map){options.headers.forEach(function(v,k){reqHeaders[k]=v})}
    else if(typeof options.headers==='object'){reqHeaders=options.headers}
  }
  if(method==='GET'&&reqHeaders['Content-Type'])delete reqHeaders['Content-Type'];
  return new Promise(function(resolve,reject){
    __native_fetch_callback[__native_fetch_id] = {
      callback: function(err, resp) {
        delete __native_fetch_callback[__native_fetch_id];
        if (err){
          reject(new Error('fetch error: '+(err.message||String(err))));
          return
        }
        var body = resp.body ?? ''
        resolve({
          ok: resp&&resp.statusCode>=200&&resp.statusCode<300,
          status:resp?resp.statusCode:0,
          statusText:resp?(resp.statusMessage||''):'',
          headers:resp.headers,
          url:url,
          text:function(){return Promise.resolve(body)},
          json:function(){return Promise.resolve(JSON.parse(body))},
          arrayBuffer:function(){var bytes=new Uint8Array(body.length);for(var i=0;i<body.length;i++)bytes[i]=body.charCodeAt(i);return Promise.resolve(bytes.buffer);}
        });
      }
    };
    var args = [];
    args[0] = method;
    args[1] = url;
    args[2] = options.body??null;
    args[3] = {headers: reqHeaders};
    args[4] = __native_fetch_id;
    sendMessage('__native_fetch__', JSON.stringify(args));
  });
}
    """);

    _jsRuntime.onMessage('__native_fetch__', (arguments) {
      String method = arguments[0] as String;
      String url = arguments[1] as String;
      Object? body = arguments[2];
      Map? options = arguments[3];
      int nativeFetchId = arguments[4] as int;
      Map<String, dynamic> headers = options?['headers'] ?? {};
      if (headers['User-Agent'] == null) {
        headers['User-Agent'] =
            'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36';
      }
      int timeout = options?['response_timeout'] ?? 60000;
      _dio
          .request(
            url,
            data: body,
            options: Options(
              method: method,
              headers: headers,
              connectTimeout: const Duration(seconds: 5),
              sendTimeout: Duration(milliseconds: timeout),
              receiveTimeout: Duration(milliseconds: timeout),
              // responseType: ResponseType.bytes,
            ),
          )
          .then((response) {
            Map<String, String> headersMap = {};
            response.headers.forEach((name, values) {
              headersMap[name] = values.join(', ');
            });

            final resp = {
              'status': response.statusCode,
              'statusCode': response.statusCode,
              'statusMessage': response.statusMessage,
              'headers': headersMap,
              'body': response.data,
            };
            final respText = jsonEncode(resp);
            _jsRuntime.evaluate(
              "globalThis.__native_fetch_callback[$nativeFetchId].callback(null,$respText)",
            );
          })
          .catchError((err) {
            _jsRuntime.evaluate(
              "globalThis.__native_xhrRequests[$nativeFetchId].callback(`${err.response.toString()}`,null)",
            );
          });
    });
  }

  void dispose() {
    _jsRuntime.dispose();
  }
}

const Map<String, int> _infoNames = {
  'name': 24,
  'description': 256,
  'author': 56,
  'homepage': 1024,
  'version': 36,
};

class AudioSourceJsEngine {
  final Dio _dio;
  late final JavascriptRuntime jsRuntime;
  Map<String, dynamic>? sources; // 初始化完成
  final SourceTableData sourceInfo;

  Timer? _timer;
  late final Map<String, Completer> _completers;

  String get name => sourceInfo.name;
  List<String> get platforms => [...(sources?.keys) ?? []];
  List<String> qualities(String platform) => [
    ...(sources?[platform]?['qualitys'] ?? []),
  ];

  AudioSourceJsEngine(
    this.sourceInfo, {
    required this.jsRuntime,
    Dio? dio,
    Map<String, Completer>? completers,
  }) : _dio = dio ?? Dio(),
       _completers = completers ?? {};
  AudioSourceJsEngine.source(
    this.sourceInfo, {
    Dio? dio,
    Map<String, Completer>? completers,
  }) : _dio = dio ?? Dio(),
       _completers = completers ?? {} {
    // sourceInfo = parseLxMusicScriptInfo(script);
    // sourceInfo['rawScript'] = script;
    jsRuntime = getJavascriptRuntime();
  }
  static Future<AudioSourceJsEngine> formScript(SourceTableData source) async {
    final jsEngine = AudioSourceJsEngine.source(source);
    await jsEngine.loadPolyfill();
    return jsEngine;
  }

  Future<bool> init() async {
    String script = sourceInfo.rawScript;
    final completer = Completer<bool>();
    if (script.isEmpty) {
      completer.complete(false);
      return await completer.future;
    }
    try {
      _completers['init'] = completer;
      // inited
      // request
      // updateAlert
      // dispatchResult
      // dispatchError
      // 桥接 事件监听 inited
      jsRuntime.onMessage('inited', (arguments) {
        sources = (arguments['sources'] ?? {}) as Map<String, dynamic>;
        _completers.remove('init');
        completer.complete(true);
      });
      // 桥接 事件监听 request
      jsRuntime.onMessage('request', (arguments) {
        print('事件: request');
        print(arguments);
      });
      // 桥接 事件监听 updateAlert
      jsRuntime.onMessage('updateAlert', (arguments) {
        // log = arguments['log'] ?? '';
        final updateUrl = arguments['updateUrl'] ?? '';
        print('需要更新: $updateUrl');
        // _getCompleter('init')?.completeError('error');
        _completers.remove('init');
        completer.complete(false);
      });
      // 桥接 事件监听 dispatchResult
      jsRuntime.onMessage('dispatchResult', (arguments) {
        final requestKey = arguments['id'] ?? '';
        final url = arguments['result'] ?? '';
        _getCompleter(requestKey)?.complete(url);
      });
      // 桥接 事件监听 dispatchError
      jsRuntime.onMessage('dispatchError', (arguments) {
        final requestKey = arguments['id'] ?? '';
        final error = arguments['error'] ?? '';
        _getCompleter(requestKey)?.completeError(error);
      });
      // 桥接http
      jsRuntime.onMessage('nativeSendRequest', (arguments) {
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
          _dio
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
                  'status': response.statusCode,
                  'statusCode': response.statusCode,
                  'statusMessage': response.statusMessage,
                  'headers': headersMap,
                  // 'bytes': responseBody,
                  // 'raw': responseBody,
                  'body': responseBody,
                };
                final respText = jsonEncode(resp);
                jsRuntime.evaluate(
                  "globalThis.__native_xhrRequests[$idRequest].callback(null,$respText)",
                );
              })
              .catchError((err) {
                jsRuntime.evaluate(
                  "globalThis.__native_xhrRequests[$idRequest].callback(`${err.response.toString()}`,null)",
                );
              });
        } catch (e) {
          AppLogger.reportError(e, StackTrace.current);
        }
      });

      final infoText = jsonEncode(sourceInfo);
      // String rawScript = base64.encode(utf8.encode(script));
      // _jsRuntime.evaluate('setup(`$infoText`, `$rawScript`)');
      jsRuntime.evaluate('initEnv($infoText)');
      jsRuntime.evaluate('!(function (){$script})();');

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_completers.isNotEmpty) {
          jsRuntime.executePendingJob();
        }
      });
    } catch (e) {
      _completers.remove('init');
      completer.complete(false);
    }
    return await completer.future;
  }

  // musicInfo = {'source': 'tx', 'songmid': '0039MnYb0qxYhV'}
  Future<String> musicUrl(
    Map<String, dynamic> musicInfo, {
    quality = '128k',
  }) async {
    final source = musicInfo['source'] ?? '';
    if (sources == null || sources?[source] == null) {
      return '';
    }
    print('从 $name 获取');
    final requestKey =
        "request__${Random().nextDouble().toString().substring(2)}";
    final completer = _addCompleter(requestKey);
    final data = {
      'source': source,
      'action': 'musicUrl',
      'info': {'type': quality, 'musicInfo': musicInfo},
    };
    final dataText = jsonEncode(data);
    // final dataTextBase64 = base64.encode(utf8.encode(dataText));
    // _jsRuntime.evaluate('jsCall(`$dataTextBase64`)');
    final result = jsRuntime.evaluate(
      'globalThis.lx._dispatch(`$requestKey`, `request`, $dataText)',
    );
    if (result.isError) {
      print(result.stringResult);
    }
    return await completer.future;
  }

  Completer<String> _addCompleter(String key) {
    final completer = Completer<String>();
    _completers[key] = completer;
    return completer;
  }

  Completer? _getCompleter(String key) {
    return _completers.remove(key);
  }

  void dispose() {
    _timer?.cancel(); // 核心：取消定时器
    jsRuntime.dispose();
  }

  static Map<String, String> parseLxMusicScriptInfo(String script) {
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

  Future<void> loadPolyfill() async {
    final polyfill = await rootBundle.loadString('assets/js/polyfill.umd.js');
    jsRuntime.evaluate(polyfill);
    final preload = await rootBundle.loadString('assets/js/qjs-preload.js');
    jsRuntime.evaluate(preload);
    jsRuntime.evaluate("""
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
  }
}
