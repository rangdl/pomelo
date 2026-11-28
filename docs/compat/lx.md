# LX 音源脚本兼容

实现位置：`lib/features/plugins/runtime/lx_compat.dart`，加密工具在 `lx_crypto.dart`。

## 目标

- 直接运行 LX 音源脚本，无需修改脚本源码。
- 把 LX 协议归一成宿主统一的 `getMediaSource` 导出，与 MusicFree 插件共用调用链。
- actions 只要求 `musicUrl`；`lyric` 已实现但不在目标内，`pic` 不做。

## 兼容进度

状态说明：✅ 已兼容　⚠️ 部分可用　❌ 未兼容　— 目标外。完成一项就更新本表。

| 能力 | 状态 | 当前情况 |
|---|---|---|
| 脚本识别与初始化（inited） | ✅ | 支持等待初始化、超时与失败上报 |
| `musicUrl` action | ✅ | 字符串或 `{ url }` 返回均可 |
| `lyric` action | ✅ | 已实现，非当前目标，保留 |
| `pic` action | — | 不做 |
| qualitys 128k / 320k / flac / flac24bit | ✅ | 宿主四档按 128k/320k/flac/flac24bit 映射，缺档自动降级 |
| `lx.request` method / headers / body / form | ✅ | 见「网络请求」 |
| `lx.request` timeout / formData / 取消 | ✅ | 支持 `timeout`、multipart `formData`、返回值取消请求 |
| 二进制响应 | ✅ | `resp.raw` 为真实字节；同时提供解码后的文本 |
| `lx.utils.buffer` | ✅ | from / bufToString |
| `lx.utils.crypto` | ✅ | md5 / aes-128-cbc/ecb / rsaEncrypt / randomBytes |
| `lx.utils.zlib` | ✅ | inflate（自动识别 gzip）/ deflate |
| currentScriptInfo / EVENT_NAMES / on / send / updateAlert | ✅ | — |
| `lx.env` | ⚠️ | 固定 `'mobile'`，桌面端脚本会走移动分支 |
| `lx.version` | ✅ | 2.0.0 |

## 识别与初始化

1. 先反射 `module.exports`：存在函数即按 MusicFree 插件处理。
2. 否则检测 `__lx_requestHandler` 或 `__lx_initPayload`，存在即按 LX 脚本处理。
3. LX 脚本必须上报 `inited`；宿主等待初始化完成，超时或报错则加载失败。
4. 两者都不满足时报「无法识别的插件格式」。

## lx 协议

- `lx.on('request', handler)`：注册统一请求处理器。
- `lx.send('inited', payload)` / `lx.send('updateAlert', payload)`：初始化与更新提示。
- `lx.EVENT_NAMES`：事件名常量。
- `lx.currentScriptInfo`：脚本元信息，包含原始源码（部分脚本会校验源码原文）。
- `lx.env`：运行环境标识，当前固定为 `'mobile'`（官方桌面端为 `'desktop'`）。
- `sources` 声明支持两种形态：`['kw', 'kg']` 数组，或 `{ kw: { qualitys, actions }, ... }` 对象。

## 网络请求

`lx.request(url, options, callback)` 由宿主专用桥 `LxHttp` 实现（`plugin_worker.dart`），不使用 `fetch` 垫片，因此能拿到真实字节：

- 缺省补桌面 Chrome UA，部分接口会校验。
- `options.form` 编码为 `x-www-form-urlencoded`；对象形式的 `body` 序列化为 JSON 并补 `Content-Type`。
- `options.formData` 编码为 `multipart/form-data`，支持字符串、`Uint8Array` 与 `{ buffer, filename, contentType }`。
- `Uint8Array` 请求体以 base64 传给宿主，避免编码破坏。
- `options.timeout` 由宿主执行，超时回调 `ETIMEDOUT: 请求超时`；传 `0` 或不传按 30s 兜底。
- 返回值为取消函数：调用后中止请求且不再回调。
- 回调签名为 `(err, resp, body)`；请求失败保证回调一个 `Error`。
- `resp` 字段：`statusCode`、`statusMessage`、`headers`、`bytes`、`raw`（真实字节）、`body`。
- `body` 文本按响应 `Content-Type` 的 charset 解码（支持 GBK / GB18030 等）；未声明或声明错误时先按 UTF-8，失败再尝试 GBK。
- `body` 会尝试 `JSON.parse`，失败时保留文本。

重定向固定最多跟随 5 次；代理与证书控制未实现。

## 工具

### lx.utils.crypto

经 Dart 同步桥交给 `LxCrypto`（`pointycastle`）：

- `md5(input)`：返回十六进制字符串。
- `aesEncrypt(input, mode, key, iv)` / `aesDecrypt(...)`：支持 `aes-128-cbc`、`aes-128-ecb`（含 PKCS7 与 NoPadding 变体），输入输出为字节数组。
- `rsaEncrypt(input, key)`：支持 PEM 公钥（X.509 包装或裸 PKCS#1），返回字节数组。
- `randomBytes(size)`：使用 `Random.secure`，返回字节数组。

### lx.utils.buffer

- `buffer.from(input, encoding)`：支持字符串与字节输入。
- `buffer.bufToString(buf, format)`：`base64`、`hex`，默认按 UTF-8 解码。

### lx.utils.zlib

经 Dart 同步桥 `LxZlib` 交给 `dart:io` 内置 codec，入参出参均为字节数组：

- `zlib.inflate(input)`：自动识别 zlib 与 gzip（`0x1f 0x8b`）。
- `zlib.deflate(input)`：zlib 压缩。
- 失败时返回 rejected Promise，错误信息透传。
- 官方移动版未实现 zlib，本运行时额外提供。

## 导出包装

初始化完成后，`LxCompat` 生成与自有格式同形的导出：

- 公共字段：`platform`、`version`、`author`、`description`、`sourceKeys`、`compat: 'lx'`。
- `getMediaSource(musicItem, quality)`：从 `musicItem.sourceKey` 选择音源（宿主在调用前写入该公开字段），调用脚本的 `musicUrl` action；脚本返回字符串或 `{ url }` 均可。
- `getLyric(musicItem)`：同样从 `musicItem.sourceKey` 选源，仅当至少一个音源声明了 `lyric` action 时暴露（目标外保留）。
- 音质降级：宿主 `low/standard/high/lossless` 映射为 `128k/320k/flac/flac24bit`，按 `flac24bit > flac > 320k > 128k` 逐级降档；声明了非常规音质名时退回脚本声明的第一项。
- 曲目字段归一：`cleanItem` 剔除宿主内部标记，`normalizeItem` 补齐 `songmid`/`hash`/`name`/`singer`/`albumName`/`interval` 别名，兼容跨插件兜底传入的曲目。
- 若脚本上报了 `updateAlert`，`updateUrl` 会作为 `srcUrl` 返回。

## 已知差异

- `lx.utils.crypto` 的 AES 只支持 AES-128（`aes-128-cbc` / `aes-128-ecb`，含 PKCS7 与 NoPadding），与官方移动版一致；官方桌面版走 Node `createCipheriv`，还支持 `aes-192/256` 等 mode。SHA、DES 不在官方 API 内，本运行时也不额外提供。
- `lx.env` 固定为 `'mobile'`（官方移动版即 `mobile`，桌面版为 `desktop`）；依赖桌面端分支的脚本会走移动端逻辑。`env` 是字符串，`env?.platform` 在官方与本运行时都取不到值。
- `lx.request` 未实现代理与证书控制，重定向固定跟随 5 次。

## 测试与排查

```powershell
$env:LIBQUICKJSC_TEST_PATH="<项目>/modules/quickjs_engine/native/build/Release/quickjs_c_bridge_plugin.dll"
flutter test test/scripts
```

- `lx_compat_http_test.dart`：`lx.request` 的参数编码、响应结构与错误回调。
- `lx_http_binary_test.dart`：二进制响应、multipart formData、timeout、取消与 zlib。
- `lx_fallback_test.dart`：音源选择与音质降级。
- `real_scripts_test.dart`：`scripts/` 下的真实脚本。
- 初始化失败先看脚本是否 `send('inited')`，以及是否依赖未实现的 `lx.utils` 能力。
