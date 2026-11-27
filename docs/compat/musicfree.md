# MusicFree 插件兼容

实现位置：`lib/features/plugins/runtime/musicfree_compat.dart`。

## 目标

- 直接加载 MusicFree 上游插件源码，不为兼容改动插件文件。
- QuickJS 运行时只提供 `fetch` 与 JS 标准内建对象，npm 依赖通过运行时模块表按需提供。
- 插件以 CommonJS 形式执行：`module` / `exports` / `require` / `console` / `env`。

## 音质档位

宿主四档与 MusicFree 官方值一一对应，直接作为 `getMediaSource(item, quality)` 的第二个参数：

| 宿主 | 传给 MusicFree |
|---|---|
| `low` | `low` |
| `standard` | `standard` |
| `high` | `high` |
| `lossless` | `super` |

对应 LX 音源的 `128k/320k/flac/flac24bit` 映射见 [lx.md](lx.md)。

## 兼容进度

状态说明：✅ 已兼容　⚠️ 部分可用　❌ 未兼容　— 目标外。完成一项就更新本表。

| 能力 | 状态 | 当前情况 |
|---|---|---|
| 加载（CommonJS / parcel default） | ✅ | 运行时包装 + 导出归一化 |
| 基础元信息 | ✅ | platform / version / author / description / srcUrl |
| 14 个 API 方法 | ✅ | 宿主均有封装，见 `pomelo_plugin_runtime.dart` |
| 音质档位 low / standard / high / super | ✅ | 宿主四档按 low/standard/high/super 传给插件 |
| `require("axios")` / `require("he")` | ✅ | 见「已提供模块」 |
| cheerio / crypto-js / dayjs / big-integer / qs / webdav | ❌ | 暂缓，用到再补 |
| 全局 fetch / btoa / atob / console / setTimeout / setInterval | ✅ | setInterval 由兼容层补齐 |
| 全局 URL / URLSearchParams / Buffer / TextEncoder / TextDecoder / AbortController | ❌ | 缺失，相关插件会 ReferenceError |
| env（getUserVariables / os / appVersion） | ✅ | — |
| env.lang | ❌ | 缺失 |
| 歌词 translation | ❌ | 只取 rawLrc / lrc |
| 搜索类型 album / artist / sheet / lyric | ⚠️ | runtime 透传 type，UI 主要用 music |
| 可选元数据 primaryKey / hints / cacheControl / supportedSearchType | ❌ | 未消费 |
| 单次调用超时 | ✅ | 宿主超时保护 |

## 装载流程

1. `LxCompat.prelude` 建立 `__pluginModule`、`__pluginModules`、`__pluginRequire`、`__pluginConsole`、`__pluginEnv`。
2. `MusicfreeCompat.bootstrap` 向模块表注册 `axios`、`he`。
3. 插件源码包进 `(function(module, exports, require, console, env){ ... })` 执行；顶层异常写入 `__lx_loadError`，不会直接中断加载。
4. `MusicfreeCompat.normalizeExports` 处理 parcel 产物：顶层没有函数、但 `default` 是对象时，把 `default` 的属性铺平到 `module.exports`。
5. 反射 `module.exports` 上的函数作为 `supportedMethods`；没有任何函数时，继续按 LX 音源脚本识别。

`require` 只开放显式注册的模块，未注册时抛错并列出当前可用模块。

## 已提供模块

### axios

基于 `fetch` 的 Promise 垫片，覆盖 MusicFree 插件常用子集：

- 入口：`axios(config)`、`axios.request`、`get/delete/head/options(url, config)`、`post/put/patch(url, data, config)`、`axios.default = axios`。
- URL 与参数：`baseURL` 拼接；`params` 支持数组、对象（JSON 序列化）与 `Date`（ISO 字符串）。
- 请求体：字符串原样发送；对象自动 `JSON.stringify` 并补 `Content-Type: application/json`。
- 响应结构：`{ data, status, statusText, headers, config, request: null }`。
- 状态校验：默认 2xx 通过，可用 `config.validateStatus` 覆盖；非 2xx 抛出 `isAxiosError` 且带 `response`。
- 超时：`config.timeout` 触发后抛 `ECONNABORTED`。
- `responseType: 'text'` 保留原始文本，其余情况尝试 `JSON.parse`，失败则保留原文。

未实现：`axios.create`、拦截器、取消、上传/下载进度、`responseType: 'arraybuffer'`、`withCredentials` 等。需要时在 `bootstrap` 内扩展。

### he

- `decode` / `unescape` / `decodeStrict`：通过 Dart 同步桥 `mfHeDecode` 调用 `package:html` 的 HTML5 tokenizer，覆盖全部命名实体与数字实体。
  - 无 `&` 的文本直接返回，不进入解析。
  - 真实 `<` / `>` 先转义，避免被当作标签解析掉；未知实体原样保留。
- `encode` / `escape` / `encodeStrict`：本地实现，仅转 `& < > " '`，非 ASCII 字符保持原样（与 `he` 默认行为一致）。
- 未实现 `he.decode(value, options)` 的第二参数（attribute 模式）。

### env 与 console

- `env`：`appVersion`、`os`、`userVariables`、`getUserVariables()`。
- `console.log/info/warn/error` 通过 `sendMessage('pluginLog', ...)` 回传宿主，不占用插件调用返回值。

## 新增模块

1. 纯 JS 模块：在 `MusicfreeCompat.bootstrap` 内给 `__pluginModules[name]` 赋值。
2. 需要宿主能力的模块：在 `MusicfreeCompat.installBridges` 中用 `js.onMessage(name, handler)` 注册同步桥，JS 侧通过 `sendMessage(name, JSON.stringify(...))` 调用。
3. 同步桥只能返回可 JSON 序列化的值；耗时操作不要放在同步桥里，避免阻塞插件调用。

## 内置插件

- 上游原文件位于 `scripts/musicfree-plugins/`，清单与来源见该目录的 `README.md`。
- 内置 seed 在 `lib/features/plugins/data/builtin_plugins.dart`；修改内置插件文件后递增 `_builtinSeedVersion`，已安装旧版的用户会重新预装。
- 插件内容保持上游原样，兼容差异全部收敛在 `musicfree_compat.dart`。

## 测试与排查

```powershell
$env:LIBQUICKJSC_TEST_PATH="<项目>/third_party/quickjs_engine/native/build/Release/quickjs_c_bridge_plugin.dll"
flutter test test/scripts
```

- `musicfree_plugins_test.dart` 覆盖内置插件的加载、搜索、取链。
- `real_scripts_test.dart` 覆盖 `scripts/` 下的真实脚本。
- 取链失败若是上游 403/503/404，通常与兼容层无关，先看插件日志与接口状态。
- `require("x") is not available`：模块未注册。
- 插件方法读不到：检查是否需要 `normalizeExports`（parcel 的 `default` 导出形态）。
