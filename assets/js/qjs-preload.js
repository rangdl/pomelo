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

  globalThis.lx = {
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

      __native_send_request(method, url, data, options, (err, resp, body) => {
        if (aborted) return;
        console.error('[lx.request] fetch resolved, status=' + resp.status + ' url=' + url.substring(0, 100));
        try {
          if (err) {
            throw new Error(err);
          } else {
            body = resp.body = resp.raw.toString()
            try {
              resp.body = JSON.parse(resp.body)
            } catch (_) {}
            body = resp.body

            var response = {
              statusCode: resp.statusCode,
              statusMessage: resp.statusMessage,
              headers: resp.headers,
              bytes: resp.bytes,
              raw: resp.raw,
              body,
            };
            console.error('[lx.request] calling safeCallback, statusCode=' + response.statusCode);
            safeCallback(null, response, body);
            console.error('[lx.request] safeCallback returned');
          }
        } catch (err) {
          if (aborted) return;
          var errMsg = (err && err.message) ? err.message : String(err);
          console.error('[lx.request] fetch/text catch: ' + errMsg);
          safeCallback(new Error(errMsg), null, null);
        }
      })

      return () => {
        aborted = true;
      }
    },
    send(eventName, data) {
      console.error('[lx.send] eventName=' + eventName);
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
          return new AESEncryption().aesEncrypt(buffer, mode, key, iv)
        },
        rsaEncrypt(buffer, key) {
          const keyObj = KEYUTIL.getKey(key);
          const plaintext = buffer.toString('utf8')
          const encryptedHex = KJUR.crypto.Cipher.encrypt(plaintext, keyObj);
          return Buffer.from(hextob64(encryptedHex), 'base64');
        },
        randomBytes(size) {
          const bytes = new Uint8Array(size);
          for (let i = 0; i < size; i++) {
            bytes[i] = Math.floor(Math.random() * 256);
          }
          return bytes;
        },
        md5(str) {
          return CryptoJS.MD5(str).toString()
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
          return new Promise((resolve, reject) => {
            try {
              const result = pako.inflate(buf);
              resolve(result)
            } catch (err) {
              reject(err);
            }
          })
        },
        deflate(data) {
          return new Promise((resolve, reject) => {
            try {
              const result = pako.deflate(data);
              resolve(result)
            } catch (err) {
              reject(err);
            }
          })
        },
      },
    },
    currentScriptInfo: _scriptInfo,
    // dispatchResult
    // dispatchError
    _dispatch(requestId, eventName, data){
      // 如果源码转了base64则放开这两行
      // data = globalThis.lx.utils.buffer.bufToString(globalThis.lx.utils.buffer.from(data, 'base64'), 'utf-8')
      // data = JSON.parse(data)
      const handler = _eventHandlers[eventName];
      console.log(typeof handler)
      if (typeof handler !== 'function') {
        if (typeof globalThis.sendMessage === 'function') {
          globalThis.sendMessage('dispatchError', JSON.stringify({
            id: requestId,
            error: 'No handler registered for event: ' + eventName
          }));
        }
        return;
      }
      
      var settled = false;

      function sendResult(value) {
        if (settled) return;
        settled = true;
        console.error('[_dispatch] sendResult called, requestId=' + requestId + ' value=' + (typeof value === 'string' ? value.substring(0, 200) : String(value)));
        if (typeof globalThis.sendMessage === 'function') {
          globalThis.sendMessage('dispatchResult', JSON.stringify({
            id: requestId,
            result: value
          }));
        }
      }

      function sendError(err) {
        if (settled) return;
        settled = true;
        var errMsg = (err && err.message) ? err.message : String(err);
        console.error('[_dispatch] sendError called, requestId=' + requestId + ' error=' + errMsg);
        if (typeof globalThis.sendMessage === 'function') {
          globalThis.sendMessage('dispatchError', JSON.stringify({
            id: requestId,
            error: errMsg
          }));
        }
      }

      try {
        var result = handler(data);
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
          }, function(err) {
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

    }
  }
  globalThis.initEnv = function (userApi){
    // 如果源码转了base64则放开这一行
    // userApi.rawScript = globalThis.lx.utils.buffer.bufToString(globalThis.lx.utils.buffer.from(userApi.rawScript, 'base64'), 'utf-8')
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
})()
