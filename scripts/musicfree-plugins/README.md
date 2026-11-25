# MusicFree 插件（pomelo 适配版）

从 GitHub 搜集并按 **pomelo 运行时规则**改造的 MusicFree 插件。

## 运行时约束（改造规则的由来）

pomelo 的插件运行时（`lib/features/plugins/runtime/musicfree_runtime.dart`）把插件包在
CommonJS 包装里执行，**只提供**：

- 全局 `fetch`（基于 XHR 的实现）
- JS 内建对象（`JSON` / `Math` / `Promise` / `setTimeout` 等）
- `console`、`env`（含 `env.getUserVariables()`）

**没有** `require` / `axios` / `cheerio` / `crypto-js` / `he` 等 npm 包。所以标准
MusicFree 插件（普遍 `require("axios")`）无法原样运行。

## 改造手法

对每个插件做**最小侵入式**头部注入（不改业务逻辑）：

1. **axios → fetch 兼容层**：注入一个约 60 行的 `_axios` 垫片，实现
   `axios(config)` / `axios.get` / `axios.post` / `axios.request` / `axios.default`，
   内部翻译成 `fetch`（支持 `params`、`data`、`headers`、返回 `{data,status,headers}`）。
2. **`require("axios")` → `_axios`**：把各种写法（`const axios = ...`、
   `const axios_1 = ...`、`var $xxx$axios = ...`）统一替换。
3. **`require("he")` → `_he`**：注入轻量 `he.decode/encode`（HTML 实体解码）。
4. **parcel 打包产物**：若插件把实例挂在 `module.exports.default`，追加语句把实例
   属性直接铺到 `module.exports`（宿主读的是 `module.exports.platform` 等）。
5. **清理**：删除插件底部「加载即执行」的自测代码（`xxx().then(...)`），避免加载时就发网络请求。

## 插件清单（均已通过 `test/scripts/musicfree_plugins_test.dart` 端到端验证）

| 文件 | 平台 | 上游 | 验证结果 |
|---|---|---|---|
| `gd-music.js` | GD音乐台 | qwerwhr/musicfree-plugins `GD音乐台.js` | ✅ 搜索 + 播放直链 |
| `maoer-fm.js` | 猫耳FM | qwerwhr/musicfree-plugins `猫耳FM.js` | ✅ 搜索 + 播放直链 |
| `udio.js` | udio | qwerwhr/musicfree-plugins `udio.js` | ✅ 搜索 + 播放直链 |
| `suno.js` | suno | qwerwhr/musicfree-plugins `suno.js` | ✅ 榜单（官方 API 已 503） |
| `youtube.js` | Youtube | qwerwhr/musicfree-plugins `Youtube.js` | ✅ 加载（域名国内不可达） |
| `xiaowo.js` | 小蜗音乐 | qwerwhr/musicfree-plugins `小蜗音乐.js` | ✅ 搜索 + 播放链路 |
| `qishui.js` | 汽水音乐 | qwerwhr/musicfree-plugins `汽水qishui音乐.js` | ✅ 搜索（取链需登录/VIP） |
| `fengsui-kg.js` | 风誰·酷狗 | long-888-long/fengsui-musicfree `kg-fengsui.js` | ✅ 搜索（取链中转已失效） |
| `fengsui-kw.js` | 风誰·酷我 | long-888-long/fengsui-musicfree `kw-fengsui.js` | ✅ 搜索 + 播放直链 |
| `fengsui-qq.js` | 风誰·QQ音乐 | long-888-long/fengsui-musicfree `qq-fengsui.js` | ✅ 搜索（取链中转已失效） |
| `fengsui-wy.js` | 风誰·网易云 | long-888-long/fengsui-musicfree `wy-fengsui.js` | ✅ 搜索 + 播放直链 |

> 说明：「取链需登录/VIP」「中转失效」是**上游服务端**限制，与改造无关——插件本身
> 加载、搜索（宿主所需的最小能力）全部正常。

## 跳过（未改造）的插件及原因

- **jsjiami 混淆加密**（`开心汽水`、`碳酸氢钠`）：代码被混淆，无法安全注入/维护。
- **依赖 `cheerio` 的 HTML 抓取型**（`bilibili`、`好听轻音乐`、`歌曲宝`、`5sing`、
  `爱听`、`小枸音乐`、`种子` 等）：需完整 jQuery 式 DOM 解析，运行时无此能力，跳过。
- **依赖 `crypto-js`**（`元力MG`、`汽水vip` 部分、`QQ_念心`、`Q音` 等）：需各加密
  算法（MD5/AES/HMAC 等）实现，成本高且易错，跳过。
- **依赖私有 token + 仓库**（`GitCode`）：需要用户自己的 GitCode 仓库与访问令牌，价值低，跳过。
- **依赖 `webdav`/`qs`/`big-integer`**（`WebDAV`、`元力WY`、`溯音网易`）：需额外类库，跳过。

## 如何测试

```bash
source ./env.sh
export LIBQUICKJSC_TEST_PATH="$PWD/third_party/quickjs_engine/native/build/libquickjs_c_bridge_plugin.so"
# 首次需构建原生库：cd third_party/quickjs_engine && sh tool/build_native.sh
flutter test test/scripts/musicfree_plugins_test.dart
```

## 如何安装到应用

应用内「设置 → MusicFree 插件 → 粘贴源码安装」把对应 `.js` 文件内容粘贴进去即可；
或用 `PluginRepository.install(source)` 以编程方式安装。
