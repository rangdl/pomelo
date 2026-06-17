final preloadJS = """
(function (){
  const _eventHandlers = {}
  const _scriptInfo = {
    name: '',
    description: '',
    version: '',
    author: '',
    homepage: '',
    rawScript: ''
  };

  const allSources = ['kw', 'kg', 'tx', 'wy', 'mg', 'local']
  const supportQualitys = {
    kw: ['128k', '320k', 'flac', 'flac24bit'],
    kg: ['128k', '320k', 'flac', 'flac24bit'],
    tx: ['128k', '320k', 'flac', 'flac24bit'],
    wy: ['128k', '320k', 'flac', 'flac24bit'],
    mg: ['128k', '320k', 'flac', 'flac24bit'],
    local: [],
  }
  const supportActions = {
    kw: ['musicUrl'],
    kg: ['musicUrl'],
    tx: ['musicUrl'],
    wy: ['musicUrl'],
    mg: ['musicUrl'],
    xm: ['musicUrl'],
    local: ['musicUrl', 'lyric', 'pic'],
  }

  globalThis.lx = {
    sources: [],
    version: '2.0.0',
    env: 'desktop',
    EVENT_NAMES: {
      request: 'request',
      inited: 'inited',
      updateAlert: 'updateAlert',
    },
    request(url, { method = 'get', timeout, headers, body, form, formData }, callback) {
      const self = this
      let options = {
        headers,
        // agent: getRequestAgent(url, {...proxy, ...userApi.proxy}),
      }
      let data
      if (body) {
        data = body
      } else if (form) {
        data = form
        // data.content_type = 'application/x-www-form-urlencoded'
        options.json = false
      } else if (formData) {
        data = formData
        // data.content_type = 'multipart/form-data'
        options.json = false
      }
      options.response_timeout = typeof timeout == 'number' && timeout > 0 ? Math.min(timeout, 60_000) : 60_000
      // let request = needle.request(method, url, data, options, (err, resp, body) => {
      // let request = fetchRequest(method, url, data, options, (err, resp, body) => {

      var aborted = false;
      var callbackCalled = false;

      function safeCallback(err, response, body) {
        if (callbackCalled || aborted) return;
        callbackCalled = true;
        if (typeof callback === 'function') {
          try {
            callback.call(self, err, response, body)
          } catch (callbackError) {
            console.error('[lx.request] callback threw:', callbackError);
          }
        }
      }
      fetch(url, {method: method, body: data, headers: options.headers})
      .then(async resp => {
        if (aborted) return;
        console.error('[lx.request] fetch resolved, status=' + resp.status + ' url=' + url.substring(0, 100));
        try {
          body = options.json?await resp.json():await resp.text()
          var response = {
            statusCode: resp.status,
            statusMessage: resp.statusText,
            headers: resp.headers,
            // bytes: resp.arrayBuffer(),
            // raw: resp.arrayBuffer(),
            body,
          };
          console.error('[lx.request] calling safeCallback, statusCode=' + response.statusCode);
          safeCallback(null, response, body);
          console.error('[lx.request] safeCallback returned');
        } catch (err) {
          if (aborted) return;
          var errMsg = (err && err.message) ? err.message : String(err);
          console.error('[lx.request2] fetch/text catch: ' + errMsg);
          safeCallback(new Error(errMsg), null, null);
        }
      }).catch((err)=>{
        if (aborted) return;
        var errMsg = (err && err.message) ? err.message : String(err);
        console.error('[lx.request] fetch/text catch: ' + errMsg);
        safeCallback(new Error(errMsg), null, null);
      })
      // __native_send_request(method, url, data, options, (err, resp, body) => {
      //   if (aborted) return;
      //   if (err) {
      //     safeCallback(new Error(err), null, null);
      //     return;
      //   }
      //   console.error('[lx.request] fetch resolved, status=' + resp.status + ' url=' + url.substring(0, 100));
      //   try {
      //     body = resp.body = resp.raw.toString()
      //     try {
      //       resp.body = JSON.parse(resp.body)
      //     } catch (_) {}
      //     body = resp.body
      //
      //     var response = {
      //       statusCode: resp.statusCode,
      //       statusMessage: resp.statusMessage,
      //       headers: resp.headers,
      //       bytes: resp.bytes,
      //       raw: resp.raw,
      //       body,
      //     };
      //     console.error('[lx.request] calling safeCallback, statusCode=' + response.statusCode);
      //     safeCallback(null, response, body);
      //     console.error('[lx.request] safeCallback returned');
      //   } catch (err) {
      //     if (aborted) return;
      //     var errMsg = (err && err.message) ? err.message : String(err);
      //     console.error('[lx.request] fetch/text catch: ' + errMsg);
      //     safeCallback(new Error(errMsg), null, null);
      //   }
      // })

      return () => {
        aborted = true;
      }
    },
    send(eventName, data) {
      console.error('[lx.send] eventName=' + eventName);
      if (eventName === 'inited') {
        if (data && data.sources) {
          const sources = {}
          for (const source of allSources) {
            const userSource = data.sources[source]
            if (!userSource || userSource.type !== 'music') continue
            const qualitys = supportQualitys[source]
            const actions = supportActions[source]
            sources[source] = {
              name: userSource.name,
              type: userSource.type,
              actions: actions.filter(a => userSource.actions.includes(a)),
              qualitys: qualitys.filter(q => userSource.qualitys.includes(q)),
            }
          }
          data.sources = this.sources = sources
          console.error('[lx.send] inited sources=' + JSON.stringify(Object.keys(data.sources)));
        } else {
          console.error('[lx.send] inited but no sources in data');
        }
      }
      if (typeof globalThis.sendMessage === 'function') {
        globalThis.sendMessage(eventName, JSON.stringify(data))
      } else {
        console.error('[lx.send] globalThis.sendMessage is not a function!');
      }
      return Promise.resolve()
    },
    on(eventName, handler) {
      _eventHandlers[eventName] = handler
      return Promise.resolve()
    },
    utils: {
      crypto: {
        aesEncrypt(buffer, mode, key, iv) {
          return globalThis.crypto.aesEncrypt(buffer, mode, key, iv)
        },
        rsaEncrypt(buffer, key) {
          return globalThis.crypto.rsaEncrypt(buffer, key)
        },
        randomBytes(size) {
          return globalThis.crypto.randomBytes(size);
        },
        md5(str) {
          return globalThis.crypto.md5(str).toString()
        },
      },
      buffer: {
        from(...args) {
          return Buffer.from(...args)
        },
        bufToString(buf, format) {
          return Buffer.from(buf, 'binary').toString(format)
        },
      },
      zlib: {
        inflate(buf) {
          return globalThis.zlib.inflate(buf)
        },
        deflate(data) {
          return globalThis.zlib.deflate(data)
        },
      },
    },
    currentScriptInfo: _scriptInfo,
    async _dispatch(requestId, eventName, data) {
      return new Promise((resolve, reject) => {
        const handler = _eventHandlers[eventName];
        if (typeof handler !== 'function') {
          reject('No handler registered for event: ' + eventName);
          return;
        }
        var settled = false;

        function sendResult(value) {
          if (settled) return;
          settled = true;
          console.error('[_dispatch] resolve, requestId=' + requestId + ', value=' + (typeof value === 'string' ? value.substring(0, 200) : String(value)));
          resolve(value);
        }

        function sendError(err) {
          if (settled) return;
          settled = true;
          var errMsg = (err && err.message) ? err.message : String(err);
          console.error('[_dispatch] reject, requestId=' + requestId + ', error=' + errMsg);
          reject(errMsg);
        }

        try {
          var result = handler.call(this, data);
          var isThenable = (result && typeof result.then === 'function');
          console.error('[_dispatch] handler returned, isThenable=' + isThenable + ' requestId=' + requestId);

          if (isThenable) {
            var timeoutId = setTimeout(function() {
              if (settled) return;
              console.error('[_dispatch] TIMEOUT fired, settled=' + settled + ' requestId=' + requestId);
              sendError(new Error('dispatch timeout: handler Promise did not settle within 18s'));
            }, 18000);

            result.then(function(value) {
              console.error('[_dispatch] Promise resolved, requestId=' + requestId);
              clearTimeout(timeoutId);
              sendResult(value);
            }).catch(function(err) {
              console.error('[_dispatch] Promise rejected, requestId=' + requestId);
              clearTimeout(timeoutId);
              sendError(err);
            });
          } else {
            sendResult(result);
          }
        } catch (err) {
          sendError(err);
        }
      })
    }
  }
  globalThis.initEnv = function (userApi){
    _scriptInfo.name= userApi.name
    _scriptInfo.description= userApi.description
    _scriptInfo.version= userApi.version
    _scriptInfo.author= userApi.author
    _scriptInfo.homepage= userApi.homepage
    _scriptInfo.rawScript= userApi.rawScript
  }
  // Browser-like global aliases (needed by obfuscated scripts)
  globalThis.window = globalThis;
  globalThis.global = globalThis;
  if (typeof clearTimeout !== "function"){
    globalThis.clearTimeout = function clearTimeout(index) {}
  }
})()

""";
