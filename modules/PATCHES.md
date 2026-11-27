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

### 补丁 1：XHR 支持二进制响应（arraybuffer）

**问题**：quickjs_engine 的 XHR 只支持文本响应，`responseType='arraybuffer'`
直接报 `XHR arraybuffer response is not supported!`。且 Dart 侧用
`utf8.decode(bodyBytes)` 强解，遇到二进制会抛 `FormatException`。

**改动**（`lib/extensions/xhr.dart`）：
1. 请求完成后把响应原始字节 `base64.encode(response.bodyBytes)` 放进回灌数据
   （`XhtmlHttpResponseInfo.bodyB64` 与 `XmlHttpRequestResponse.bodyB64`）。
2. `utf8.decode(...)` 加 `allowMalformed: true`，二进制响应不再崩溃。
3. JS 侧新增全局 `__b64ToArrayBuffer(base64)`（纯 JS 实现，不依赖 `atob`），
   `responseType === 'arraybuffer'` 时用它把 base64 还原成 `ArrayBuffer` 赋给
   `xhr.response`。

**影响面**：向后兼容。文本/JSON 行为不变；只有显式设置 `responseType='arraybuffer'`
的调用方（MusicFree axios 垫片的二进制请求）才走新分支。

**上游升级注意**：若上游也实现了 arraybuffer，优先采用上游实现并删除本补丁；
注意保留 `__b64ToArrayBuffer` 注入时机（需在插件脚本执行前定义）。

---

## 维护约定

- 每新增一处对 vendored 模块的修改，都在本文件追加一节：「问题 / 改动 / 影响面 /
  上游升级注意」。
- patch 尽量**增量、向后兼容**，避免大范围重排上游代码，降低升级 merge 成本。
- 改动处代码内保留中文注释说明用途，便于日后对照本文件定位。
