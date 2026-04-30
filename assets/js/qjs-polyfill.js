globalThis.navigator = { userAgent: 'QuickJS' };
globalThis.window = globalThis;



/**
 * QuickJS 环境下的 Buffer 兼容层
 * 使用 CryptoJS 优化实现
 * 完全兼容 Node.js Buffer API 的核心功能
 */
const BufferPolyfill = {
  /**
   * 创建 Buffer (类似 Node.js Buffer.from)
   * @param {*} arg - 支持多种输入类型
   * @param {string} encoding - 编码格式 ('hex', 'base64', 'utf8', 'binary', 'latin1')
   * @returns {Uint8Array}
   */
  from(arg, encoding) {
    // 1. 处理数字（创建指定大小的 Buffer）
    if (typeof arg === 'number') {
      return new Uint8Array(arg);
    }

    // 2. 处理字符串
    if (typeof arg === 'string') {
      return this._fromString(arg, encoding);
    }

    // 3. 处理数组
    if (Array.isArray(arg)) {
      const bytes = new Uint8Array(arg.length);
      for (let i = 0; i < arg.length; i++) {
        bytes[i] = arg[i] & 0xFF;
      }
      return bytes;
    }

    // 4. 处理 Uint8Array（复制）
    if (arg instanceof Uint8Array) {
      const copy = new Uint8Array(arg.length);
      copy.set(arg);
      return copy;
    }

    // 5. 处理 ArrayBuffer
    if (arg instanceof ArrayBuffer) {
      return new Uint8Array(arg);
    }

    // 6. 处理 CryptoJS WordArray
    if (arg && arg.words && arg.sigBytes !== undefined) {
      return this._wordArrayToBytes(arg);
    }

    throw new Error(`Unsupported argument type for Buffer.from: ${typeof arg}`);
  },

  /**
   * 从字符串创建 Buffer（使用 CryptoJS 优化）
   * @private
   */
  _fromString(str, encoding) {
    encoding = (encoding || 'utf8').toLowerCase();

    switch(encoding) {
      case 'hex':
        // 使用 CryptoJS 解析 Hex
        const hexWordArray = CryptoJS.enc.Hex.parse(str);
        return this._wordArrayToBytes(hexWordArray);

      case 'base64':
        // 使用 CryptoJS 解析 Base64
        const base64WordArray = CryptoJS.enc.Base64.parse(str);
        return this._wordArrayToBytes(base64WordArray);

      case 'utf8':
      case 'utf-8':
        // 使用 CryptoJS 解析 UTF-8
        const utf8WordArray = CryptoJS.enc.Utf8.parse(str);
        return this._wordArrayToBytes(utf8WordArray);

      case 'binary':
      case 'latin1':
        // 使用 CryptoJS 解析 Latin1
        const latin1WordArray = CryptoJS.enc.Latin1.parse(str);
        return this._wordArrayToBytes(latin1WordArray);

      default:
        throw new Error(`Unsupported encoding: ${encoding}`);
    }
  },

  /**
   * 将 Buffer 转换为字符串（使用 CryptoJS 优化）
   * @param {Uint8Array} buf - Buffer/Uint8Array
   * @param {string} encoding - 编码格式 ('hex', 'base64', 'utf8', 'binary', 'latin1')
   * @returns {string}
   */
  bufToString(buf, encoding) {
    if (!buf || !(buf instanceof Uint8Array)) {
      throw new Error('First argument must be a Uint8Array/Buffer');
    }

    encoding = (encoding || 'utf8').toLowerCase();

    // 将 Uint8Array 转换为 CryptoJS WordArray
    const wordArray = this._bytesToWordArray(buf);

    switch(encoding) {
      case 'hex':
        return CryptoJS.enc.Hex.stringify(wordArray);

      case 'base64':
        return CryptoJS.enc.Base64.stringify(wordArray);

      case 'utf8':
      case 'utf-8':
        return CryptoJS.enc.Utf8.stringify(wordArray);

      case 'binary':
      case 'latin1':
        return CryptoJS.enc.Latin1.stringify(wordArray);

      default:
        throw new Error(`Unsupported encoding: ${encoding}`);
    }
  },

  /**
   * 将 Uint8Array 转换为 CryptoJS WordArray
   * @private
   */
  _bytesToWordArray(bytes) {
    const words = [];
    const len = bytes.length;

    for (let i = 0; i < len; i += 4) {
      const word =
        ((bytes[i] || 0) << 24) |
        ((bytes[i+1] || 0) << 16) |
        ((bytes[i+2] || 0) << 8) |
        ((bytes[i+3] || 0));
      words.push(word);
    }

    return CryptoJS.lib.WordArray.create(words, len);
  },

  /**
   * 将 CryptoJS WordArray 转换为 Uint8Array
   * @private
   */
  _wordArrayToBytes(wordArray) {
    const words = wordArray.words;
    const sigBytes = wordArray.sigBytes;
    const bytes = new Uint8Array(sigBytes);

    for (let i = 0; i < sigBytes; i++) {
      const wordIndex = Math.floor(i / 4);
      const byteIndex = i % 4;
      const word = words[wordIndex];
      bytes[i] = (word >>> (24 - byteIndex * 8)) & 0xFF;
    }

    return bytes;
  },

  /**
   * 分配新的 Buffer（类似 Node.js Buffer.alloc）
   * @param {number} size - 字节大小
   * @param {*} fill - 填充值（可选）
   * @param {string} encoding - 编码（可选）
   * @returns {Uint8Array}
   */
  alloc(size, fill, encoding) {
    const buffer = new Uint8Array(size);

    if (fill !== undefined) {
      if (typeof fill === 'string') {
        const fillBuffer = this.from(fill, encoding);
        const fillLen = fillBuffer.length;
        for (let i = 0; i < size; i++) {
          buffer[i] = fillBuffer[i % fillLen];
        }
      } else if (typeof fill === 'number') {
        for (let i = 0; i < size; i++) {
          buffer[i] = fill & 0xFF;
        }
      } else if (fill instanceof Uint8Array) {
        const fillLen = fill.length;
        for (let i = 0; i < size; i++) {
          buffer[i] = fill[i % fillLen];
        }
      }
    }

    return buffer;
  },

  /**
   * 分配未初始化的 Buffer（性能优化）
   * @param {number} size - 字节大小
   * @returns {Uint8Array}
   */
  allocUnsafe(size) {
    return new Uint8Array(size);
  },

  /**
   * 将多个 Buffer 连接成一个
   * @param {Array<Uint8Array>} list - Buffer 数组
   * @param {number} totalLength - 总长度（可选）
   * @returns {Uint8Array}
   */
  concat(list, totalLength) {
    if (!Array.isArray(list)) {
      throw new Error('First argument must be an array');
    }

    if (list.length === 0) {
      return new Uint8Array(0);
    }

    if (totalLength === undefined) {
      totalLength = 0;
      for (let i = 0; i < list.length; i++) {
        totalLength += list[i].length;
      }
    }

    const result = new Uint8Array(totalLength);
    let offset = 0;

    for (let i = 0; i < list.length; i++) {
      result.set(list[i], offset);
      offset += list[i].length;
    }

    return result;
  },

  /**
   * 判断是否是 Buffer
   * @param {*} obj
   * @returns {boolean}
   */
  isBuffer(obj) {
    return obj instanceof Uint8Array;
  },

  /**
   * 获取字节长度
   * @param {string} str - 字符串
   * @param {string} encoding - 编码
   * @returns {number}
   */
  byteLength(str, encoding) {
    const buffer = this.from(str, encoding);
    return buffer.length;
  }
};

// 添加 Uint8Array 原型方法（模拟 Buffer 实例方法）
Uint8Array.prototype.toString = function(encoding) {
  return BufferPolyfill.bufToString(this, encoding);
};

Uint8Array.prototype.equals = function(other) {
  if (!(other instanceof Uint8Array)) return false;
  if (this.length !== other.length) return false;
  for (let i = 0; i < this.length; i++) {
    if (this[i] !== other[i]) return false;
  }
  return true;
};

// 挂载到全局
if (typeof globalThis !== 'undefined') {
  globalThis.Buffer = BufferPolyfill;
}


// 在 QuickJS 环境中，假设 CryptoJS 已被加载

class AESEncryption {
  /**
   * AES 加密（与 Node.js crypto.createCipheriv 参数风格一致）
   * @param {Buffer|Uint8Array|string} data - 输入数据
   * @param {string} algorithm - 算法名称，如 'aes-128-cbc', 'aes-256-cbc', 'aes-128-ecb' 等
   * @param {Buffer|Uint8Array|string} key - 密钥
   * @param {Buffer|Uint8Array|string} iv - 初始向量（ECB 模式不需要）
   * @returns {Uint8Array} 加密后的数据
   */
  aesEncrypt(data, algorithm, key, iv) {
    // 1. 从算法名称解析模式和密钥长度
    const { mode, keyLength } = this._parseAlgorithm(algorithm);

    // 2. 转换输入为 WordArray
    const dataWordArray = this._toWordArray(data);
    const keyWordArray = this._toWordArray(key);

    // 3. 验证密钥长度
    const expectedKeyLength = keyLength / 8;
    if (keyWordArray.sigBytes !== expectedKeyLength) {
      throw new Error(`Invalid key length: expected ${expectedKeyLength} bytes, got ${keyWordArray.sigBytes} bytes`);
    }

    // 4. 配置加密选项
    const cfg = {
      mode: this._getModeByNodeName(mode),
      padding: CryptoJS.pad.Pkcs7
    };

    // 5. ECB 模式不需要 IV
    if (mode !== 'ecb') {
      if (!iv) {
        throw new Error(`IV is required for ${mode} mode`);
      }
      const ivWordArray = this._toWordArray(iv);
      // 验证 IV 长度（应该是 16 字节）
      if (ivWordArray.sigBytes !== 16) {
        throw new Error(`Invalid IV length: expected 16 bytes, got ${ivWordArray.sigBytes} bytes`);
      }
      cfg.iv = ivWordArray;
    }

    // 6. 执行加密
    const encrypted = CryptoJS.AES.encrypt(dataWordArray, keyWordArray, cfg);

    // 7. 返回 Uint8Array 格式的密文
    return this._wordArrayToBuffer(encrypted.ciphertext);
  }

  /**
   * AES 解密（与 Node.js crypto.createDecipheriv 参数风格一致）
   * @param {Buffer|Uint8Array|string} encryptedData - 加密的数据
   * @param {string} algorithm - 算法名称，如 'aes-128-cbc', 'aes-256-cbc', 'aes-128-ecb' 等
   * @param {Buffer|Uint8Array|string} key - 密钥
   * @param {Buffer|Uint8Array|string} iv - 初始向量（ECB 模式不需要）
   * @returns {Uint8Array} 解密后的数据
   */
  aesDecrypt(encryptedData, algorithm, key, iv) {
    // 1. 从算法名称解析模式和密钥长度
    const { mode, keyLength } = this._parseAlgorithm(algorithm);

    // 2. 转换输入为 WordArray
    const ciphertextWordArray = this._toWordArray(encryptedData);
    const keyWordArray = this._toWordArray(key);

    // 3. 验证密钥长度
    const expectedKeyLength = keyLength / 8;
    if (keyWordArray.sigBytes !== expectedKeyLength) {
      throw new Error(`Invalid key length: expected ${expectedKeyLength} bytes, got ${keyWordArray.sigBytes} bytes`);
    }

    // 4. 创建 CipherParams 对象
    const cipherParams = CryptoJS.lib.CipherParams.create({
      ciphertext: ciphertextWordArray
    });

    // 5. 配置解密选项
    const cfg = {
      mode: this._getModeByNodeName(mode),
      padding: CryptoJS.pad.Pkcs7
    };

    // 6. ECB 模式不需要 IV
    if (mode !== 'ecb') {
      if (!iv) {
        throw new Error(`IV is required for ${mode} mode`);
      }
      const ivWordArray = this._toWordArray(iv);
      if (ivWordArray.sigBytes !== 16) {
        throw new Error(`Invalid IV length: expected 16 bytes, got ${ivWordArray.sigBytes} bytes`);
      }
      cfg.iv = ivWordArray;
    }

    // 7. 执行解密
    const decrypted = CryptoJS.AES.decrypt(cipherParams, keyWordArray, cfg);

    // 8. 返回 Uint8Array 格式的明文
    return this._wordArrayToBuffer(decrypted);
  }

  /**
   * 将字符串转换为 Uint8Array (UTF-8 编码)
   * @private
   */
  _stringToUint8Array(str) {
    const utf8 = unescape(encodeURIComponent(str));
    const bytes = new Uint8Array(utf8.length);
    for (let i = 0; i < utf8.length; i++) {
      bytes[i] = utf8.charCodeAt(i);
    }
    return bytes;
  }

  /**
   * 将 Uint8Array 转换为字符串 (UTF-8 解码)
   * @private
   */
  _uint8ArrayToString(bytes) {
    let str = '';
    for (let i = 0; i < bytes.length; i++) {
      str += '%' + ('0' + bytes[i].toString(16)).slice(-2);
    }
    return decodeURIComponent(str);
  }

  /**
   * 将输入转换为 CryptoJS 的 WordArray
   * @private
   */
  _toWordArray(input) {
    // 处理 Uint8Array 或 Buffer
    if (input instanceof Uint8Array || (typeof Buffer !== 'undefined' && input instanceof Buffer)) {
      const words = [];
      for (let i = 0; i < input.length; i += 4) {
        const word =
          ((input[i] || 0) << 24) |
          ((input[i + 1] || 0) << 16) |
          ((input[i + 2] || 0) << 8) |
          ((input[i + 3] || 0));
        words.push(word);
      }
      return CryptoJS.lib.WordArray.create(words, input.length);
    }
    // 处理字符串（默认当作 UTF-8）
    else if (typeof input === 'string') {
      // 先转换为 Uint8Array，再转换为 WordArray
      const bytes = this._stringToUint8Array(input);
      const words = [];
      for (let i = 0; i < bytes.length; i += 4) {
        const word =
          ((bytes[i] || 0) << 24) |
          ((bytes[i + 1] || 0) << 16) |
          ((bytes[i + 2] || 0) << 8) |
          ((bytes[i + 3] || 0));
        words.push(word);
      }
      return CryptoJS.lib.WordArray.create(words, bytes.length);
    }
    // 处理 Hex 字符串
    else if (typeof input === 'string' && /^[0-9a-fA-F]+$/.test(input)) {
      return CryptoJS.enc.Hex.parse(input);
    }
    // 假设已经是 WordArray
    else if (input && input.words && input.sigBytes !== undefined) {
      return input;
    }
    else {
      throw new Error('Unsupported input type for _toWordArray');
    }
  }

  /**
   * 将 CryptoJS WordArray 转换为 Uint8Array
   * @private
   */
  _wordArrayToBuffer(wordArray) {
    const words = wordArray.words;
    const sigBytes = wordArray.sigBytes;
    const bytes = new Uint8Array(sigBytes);

    for (let i = 0; i < sigBytes; i++) {
      const wordIndex = Math.floor(i / 4);
      const byteIndex = i % 4;
      const word = words[wordIndex];
      bytes[i] = (word >>> (24 - byteIndex * 8)) & 0xFF;
    }

    return bytes;
  }

  /**
   * 解析 Node.js 风格的算法名称
   * @private
   * @param {string} algorithm - 如 'aes-128-cbc', 'aes-256-ecb', 'aes-192-gcm' 等
   * @returns {Object} { mode: string, keyLength: number }
   */
  _parseAlgorithm(algorithm) {
    // 匹配格式: aes-{keyLength}-{mode}
    const match = algorithm.match(/^aes-(\d+)-(\w+)$/);
    if (!match) {
      throw new Error(`Unsupported algorithm: ${algorithm}. Expected format: aes-128-cbc, aes-256-ecb, etc.`);
    }

    const keyLength = parseInt(match[1], 10); // 128, 192, 256
    const mode = match[2].toLowerCase();      // cbc, ecb, cfb, ofb, ctr, gcm 等

    // 验证密钥长度
    if (![128, 192, 256].includes(keyLength)) {
      throw new Error(`Invalid key length: ${keyLength}. Must be 128, 192, or 256`);
    }

    // 验证模式（CryptoJS 支持的模式）
    const supportedModes = ['cbc', 'ecb', 'cfb', 'ofb', 'ctr'];
    if (!supportedModes.includes(mode)) {
      throw new Error(`Unsupported mode: ${mode}. Supported modes: ${supportedModes.join(', ')}`);
    }

    return { mode, keyLength };
  }

  /**
   * 根据 Node.js 模式名获取 CryptoJS 的模式对象
   * @private
   */
  _getModeByNodeName(mode) {
    const modeMap = {
      'cbc': CryptoJS.mode.CBC,
      'ecb': CryptoJS.mode.ECB,
      'cfb': CryptoJS.mode.CFB,
      'ofb': CryptoJS.mode.OFB,
      'ctr': CryptoJS.mode.CTR
    };

    const cryptoJSMode = modeMap[mode];
    if (!cryptoJSMode) {
      throw new Error(`Mode '${mode}' is not supported by CryptoJS`);
    }

    return cryptoJSMode;
  }

  /**
   * 辅助方法：生成随机字节数组
   * @param {number} size - 字节数
   * @returns {Uint8Array} 随机字节数组
   */
  randomBytes(size) {
    const bytes = new Uint8Array(size);
    for (let i = 0; i < size; i++) {
      bytes[i] = Math.floor(Math.random() * 256);
    }
    return bytes;
  }

  /**
   * 辅助方法：将 Uint8Array 转换为 Hex 字符串
   * @param {Uint8Array} bytes
   * @returns {string}
   */
  bytesToHex(bytes) {
    let hex = '';
    for (let i = 0; i < bytes.length; i++) {
      hex += ('0' + bytes[i].toString(16)).slice(-2);
    }
    return hex;
  }

  /**
   * 辅助方法：将 Hex 字符串转换为 Uint8Array
   * @param {string} hex
   * @returns {Uint8Array}
   */
  hexToBytes(hex) {
    const bytes = new Uint8Array(hex.length / 2);
    for (let i = 0; i < hex.length; i += 2) {
      bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
    }
    return bytes;
  }
}
