# 本地 vendored 模块 —— 补丁记录

本目录（`modules/`）存放**直接内嵌在仓库、允许就地修改**的第三方包。它们不是从
pub.dev 拉取的普通依赖，而是以 `path:` 依赖接入（见 `pubspec.yaml`），随本项目一起
提交、构建。

之所以单独放这里而不是 `~/.pub-cache`：这些包需要打本地 patch 才能满足需求。
**升级上游时必须逐条对照本文件重放/核对改动**，否则会丢失功能。

---

## quickjs_engine

- 当前位置：`modules/quickjs_engine/`
- 版本：0.1.7
- 上游：<https://github.com/denisnadey/flutter_full_svg_support>（`packages/quickjs_engine`，
  其本身是 `flutter_js` 对 QuickJS-NG 的 fork）
- 本地改动涉及文件：`lib/extensions/xhr.dart`（其余文件保持上游原样）

### 补丁 1：XHR 增强为完整 HTTP 引擎

**问题**：上游 XHR 能力偏弱——
- 只支持文本响应，`responseType='arraybuffer'` 直接报错；Dart 侧
  `utf8.decode(bodyBytes)` 强解，遇二进制抛 `FormatException`；
- 不支持每个请求单独的超时（只有全局 30s）；
- 不支持 multipart/form-data；
- `abort()` 只把 JS 侧状态置 UNSENT，Dart 侧请求不会取消、结果仍会回灌。

**改动**（`lib/extensions/xhr.dart`）：
1. **二进制响应**：请求完成后把原始字节 `base64.encode(response.bodyBytes)` 回灌
   （`XhtmlHttpResponseInfo.bodyB64` / `XmlHttpRequestResponse.bodyB64`）；
   `utf8.decode(...)` 加 `allowMalformed: true`；JS 侧新增全局
   `__b64ToArrayBuffer(base64)`（纯 JS，不依赖 `atob`），`responseType==='arraybuffer'`
   时还原成 `ArrayBuffer` 赋给 `xhr.response`。
2. **每请求超时**：XHR 新增 `timeout` 属性，经 `SendNative` 第 6 个参数传入
   `XhrPendingCall.timeoutMs`，请求按它 `.timeout(...)`（缺省仍用全局 30s）。
3. **multipart/form-data**：`send()` 的 body 若为数组即视为 formData 字段列表，
   Dart 侧用 `http.MultipartRequest` 组装（支持 base64 文件与普通字段）。
4. **abort 真生效**：`abort()` 通过 `XhrAbortNative` 消息把请求 id 通知 Dart，
   `XhrPendingCall` 结果回灌前检查 id 是否已 abort，命中则丢弃；
   （`package:http` 无法中断底层 socket，故采用「结果丢弃 + 尽快返回」策略。）
5. **文本按 charset 解码**：Dart 侧 `_decodeXhrText` 按响应头 `Content-Type` 的
   charset 解码，未声明按 UTF-8，失败再试 GBK，最后 `allowMalformed`。
   为此在 `pubspec.yaml` 增加 `charset` 依赖（本地 patch 的一部分）。
6. **二进制请求体**：`send(Uint8Array/ArrayBuffer)` 时 JS 侧转成 `{__b64}`，
   Dart 侧解码为字节作请求体（供 LX 的二进制 body 使用）。

**保留**：`xhrSetHttpClient()` 注入点不变（三个测试依赖它注入容错 client）。
底层仍用 `package:http`（默认 `IOClient` 即 `dart:io HttpClient`），不换底层，
以保住跨平台与测试可注入性。

**影响面**：向后兼容。文本/JSON、原有 get/post 等行为不变；新能力均为增量。

**上游升级注意**：若上游实现了 arraybuffer / timeout / multipart / abort，优先用
上游实现并删除对应补丁；注意保留 `__b64ToArrayBuffer` 与 `__xhrAbortNative`
的注入时机（需在插件脚本执行前定义），以及 `XhrAbortNative` 消息监听；
`charset` 依赖与 `dart:io` 的 `ContentType` 导入也是补丁的一部分。

### 补丁 2（应用层）：LX 的 lx.request 统一走 XHR

> 这一条不在 vendored 包内，改动在 `lib/features/plugins/runtime/`（lx_compat.dart /
> plugin_worker.dart），记录在此以便理解整体架构；升级 quickjs_engine 不受影响。

**背景**：此前 LX 有一整套专用二进制 HTTP 通道（`LxHttp`/`LxHttpCancel` 消息 +
`_runLxHttp` + `_decodeLxText` + `_settleLxHttp` 等，位于 plugin_worker.dart），
与 XHR 重复实现「Dart 取字节 → base64 回灌 → JS 还原」。

**改动**：
- `lx_compat.dart` 的 `__lx_do_request` 改为直接用 `XMLHttpRequest`
  （`responseType='arraybuffer'`）：文本优先用宿主已按 charset 解码的
  `responseText`，仅在缺失时对原始字节做 UTF-8 兜底；formData 数组直接
  `xhr.send(formData)`，二进制 body 用 `{__b64}`；取消函数调用 `xhr.abort()`。
- `plugin_worker.dart` 删除整套 `LxHttp` 桥（消息注册、`_runLxHttp`、
  `_decodeLxText`、`_settleLxHttp`、`_disposeLxHttp`、`_LxHttpTask`、
  `_lxHttpClient`），仅保留 `LxZlib` 桥；相关 `charset` / `dart:io HttpClient`
  导入一并清理。

**效果**：Dart 侧只剩一套 HTTP 执行路径（XHR），formData / 超时 / 取消 / charset
解码全部惠及 LX 与 MusicFree 两类插件。LX 脚本对外接口（`lx.request`）不变。

---

## 维护约定

- 每新增一处对 vendored 模块的修改，都在本文件追加一节：「问题 / 改动 / 影响面 /
  上游升级注意」。
- patch 尽量**增量、向后兼容**，避免大范围重排上游代码，降低升级 merge 成本。
- 改动处代码内保留中文注释说明用途，便于日后对照本文件定位。
