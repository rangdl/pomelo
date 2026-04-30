(function (){
  const sendMessage = (action, data, status, message) => {
    // ipcRenderer.send(action, { data, status, message })
    console.log('sendMessage')
    console.log(action, data, status, message)
  }
  let isInitedApi = false
  let isShowedUpdateAlert = false
  // 音源环境
  const USER_API_RENDERER_EVENT_NAME = {
    init: 'init',
    showUpdateAlert: 'showUpdateAlert',
    request: 'request',
    cancelRequest: 'cancelRequest',
    response: 'response',
  }
  const EVENT_NAMES = {
    request: 'request',
    inited: 'inited',
    updateAlert: 'updateAlert',
  }
  const eventNames = Object.values(EVENT_NAMES)
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

  const verifyLyricInfo = (info) => {
    if (typeof info != 'object' || typeof info.lyric != 'string') throw new Error('failed')
    if (info.lyric.length > 51200) throw new Error('failed')
    return {
      lyric: info.lyric,
      tlyric: (typeof info.tlyric == 'string' && info.tlyric.length < 5120) ? info.tlyric : null,
      rlyric: (typeof info.rlyric == 'string' && info.rlyric.length < 5120) ? info.rlyric : null,
      lxlyric: (typeof info.lxlyric == 'string' && info.lxlyric.length < 8192) ? info.lxlyric : null,
    }
  }

  async function fetchRequest(method, url, data, options,callback){
    if (options.json){
      options.headers = options.headers || {}
      options.headers['Content-Type'] = 'application/json'
      data = JSON.stringify(data)
    }
    if (method.toLocaleUpperCase() === 'GET') data = null
    fetch(url, {method: method, body: data, headers: options.headers})
    .then(async (response) => {
      console.log('fetch success')
      let body = await response.text()
      if (options.json) body = response.json()
      callback(null, response, body)
    }).catch((err)=>{
      console.log('setup err')
      callback(err, null, null)
    })
  }

  globalThis.setup = (userApi, rawScript)=>{
    delete globalThis.setup
    if (typeof userApi === 'string') {
      userApi = JSON.parse(userApi)
    }
    userApi.rawScript = rawScript
    const handleRequest = (context, { requestKey, data }) => {
      if (!events.request) return sendMessage(USER_API_RENDERER_EVENT_NAME.response, { requestKey }, false, 'Request event is not defined')
      try {
        events.request.call(context, { source: data.source, action: data.action, info: data.info }).then(response => {
          let sendData = {
            source: data.source,
            action: data.action,
          }
          switch (data.action) {
            case 'musicUrl':
              if (typeof response != 'string' || response.length > 2048 || !/^https?:/.test(response)) throw new Error('failed')
              sendData.data = {type: data.info.type, url: response}
              break
            case 'lyric':
              sendData.data = verifyLyricInfo(response)
              break
            case 'pic':
              if (typeof response != 'string' || response.length > 2048 || !/^https?:/.test(response)) throw new Error('failed')
              sendData.result = response
              break
          }
          sendMessage(USER_API_RENDERER_EVENT_NAME.response, sendData, true)
        }).catch(err => {
          sendMessage(USER_API_RENDERER_EVENT_NAME.response, { requestKey }, false, err.message)
        })
      } catch (err) {
        sendMessage(USER_API_RENDERER_EVENT_NAME.response, { requestKey }, false, err.message)
      }
    }
    const handleInit = (context, info) => {
      if (!info) {
        sendMessage(USER_API_RENDERER_EVENT_NAME.init, null, false, 'Missing required parameter init info')
        return
      }
      if (info.openDevTools === true) {
        sendMessage(USER_API_RENDERER_EVENT_NAME.openDevTools)
      }
      const sourceInfo = {
        sources: {},
      }
      try {
        for (const source of allSources) {
          const userSource = info.sources[source]
          if (!userSource || userSource.type !== 'music') continue
          const qualitys = supportQualitys[source]
          const actions = supportActions[source]
          sourceInfo.sources[source] = {
            type: 'music',
            actions: actions.filter(a => userSource.actions.includes(a)),
            qualitys: qualitys.filter(q => userSource.qualitys.includes(q)),
          }
        }
      } catch (error) {
        console.log(error)
        sendMessage(USER_API_RENDERER_EVENT_NAME.init, null, false, error.message)
        return
      }
      sendMessage(USER_API_RENDERER_EVENT_NAME.init, sourceInfo, true)
      // handler = (data) => {
      //   const requestKey = `request__${Math.random().toString().substring(2)}`
      //   const bridgeResponse = bridge.create(USER_API_RENDERER_EVENT_NAME.response, requestKey)
      //   if (!sources[data.source]){
      //     bridge.call(USER_API_RENDERER_EVENT_NAME.response, false, { key: requestKey, data: '不支持的音源: ' + data.source })
      //     return bridgeResponse
      //   }
      //   if (!sources[data.source].qualitys.includes(data.info.type)){
      //     data.info.type = '128k' // 请求的音质不在支持列表回退到128k
      //   }
      //   handleRequest(context, { requestKey, data })
      //   return bridgeResponse
      // }
      globalThis.jsCall = (data) => {
        console.log('jsCall')
        data = globalThis.lx.utils.buffer.bufToString(globalThis.lx.utils.buffer.from(data, 'base64'), 'utf-8')
        data = JSON.parse(data)
        handleRequest(context, data)
      }
    }
    const handleShowUpdateAlert = (data, resolve, reject) => {
      isShowedUpdateAlert = true
      if (!data || typeof data != 'object') return reject(new Error('parameter format error.'))
      if (!data.log || typeof data.log != 'string') return reject(new Error('log is required.'))
      if (data.updateUrl && !/^https?:\/\/[^\s$.?#].[^\s]*$/.test(data.updateUrl) && data.updateUrl.length > 1024) delete data.updateUrl
      if (data.log.length > 1024) data.log = data.log.substring(0, 1024) + '...'
      sendMessage(USER_API_RENDERER_EVENT_NAME.showUpdateAlert, {
        log: data.log,
        updateUrl: data.updateUrl,
      })
      resolve()
    }

    const events= {
      request: null,
    }
    globalThis.lx = {
      EVENT_NAMES,
      request(url, { method = 'get', timeout, headers, body, form, formData }, callback) {
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
        console.log('native request start')
        let request = __native_send_request(method, url, data, options, (err, resp, body) => {
          console.log('native request end')
          console.log(err)
          console.log(typeof resp)
          console.log(resp)
          console.log(resp.body)
          console.log(resp['body'])
          console.log(typeof body)
          try {
            if (err) {
              callback.call(this, err, null, null)
            } else {
              // body = resp.body = resp.raw.toString()
              try {
                resp.body = JSON.parse(resp.body)
              } catch (_) {}
              body = resp.body
              console.log('native request start - 0')
              console.log(body)
              console.log('native request start - 0')
              callback.call(this, err, {
                statusCode: resp.statusCode,
                statusMessage: resp.statusMessage,
                headers: resp.headers,
                bytes: resp.bytes,
                raw: resp.raw,
                body,
              }, body)
            }
          } catch (err) {
            onError(err.message)
          }
        }).request

        return () => {
          if (!request.aborted) request.abort()
          request = null
        }
      },
      send(eventName, data) {
        console.log('send')
        return new Promise((resolve, reject) => {
          if (!eventNames.includes(eventName)) return reject(new Error('The event is not supported: ' + eventName))
          switch (eventName) {
            case EVENT_NAMES.inited:
              if (isInitedApi) return reject(new Error('Script is inited'))
              isInitedApi = true
              handleInit(this, data)
              resolve()
              break
            case EVENT_NAMES.updateAlert:
              if (isShowedUpdateAlert) return reject(new Error('The update alert can only be called once.'))
              handleShowUpdateAlert(data, resolve, reject)
              break
            default:
              reject(new Error('Unknown event name: ' + eventName))
          }
        })
      },
      on(eventName, handler) {
        if (!eventNames.includes(eventName)) return Promise.reject(new Error('The event is not supported: ' + eventName))
        switch (eventName) {
          case EVENT_NAMES.request:
            events.request = handler
            break
          default: return Promise.reject(new Error('The event is not supported: ' + eventName))
        }
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
      currentScriptInfo: {
        name: userApi.name,
        description: userApi.description,
        version: userApi.version,
        author: userApi.author,
        homepage: userApi.homepage,
        rawScript: userApi.rawScript,
      },
      version: '2.0.0',
      env: 'desktop',
    }
    try {
      userApi.rawScript = globalThis.lx.utils.buffer.bufToString(globalThis.lx.utils.buffer.from(userApi.rawScript, 'base64'), 'utf-8')
      const wrappedScript = `with(this){${userApi.rawScript}\n}`;
      const fn = new Function(wrappedScript);
      fn.call(globalThis);
    }catch (e){
      console.error(e)
    }
  }
})()
