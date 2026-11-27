# MusicFree 插件（上游原样版）

从 GitHub 搜集的 MusicFree 插件。插件文件**保持上游源码原样**，兼容逻辑全部
收敛在 pomelo 运行时（`lib/features/plugins/runtime/musicfree_compat.dart`）。

## 运行时兼容层

插件运行时的 CommonJS 包装、`axios` / `he` 模块和导出归一化详见
[docs/compat/musicfree.md](../../docs/compat/musicfree.md)。

未注册的模块（`cheerio` / `crypto-js` / `qs` / `webdav` 等）仍会抛错。

## 插件清单（源码均为上游原文，已通过 `test/scripts/musicfree_plugins_test.dart` 端到端验证）

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
| `migu.js` | 咪咕音乐 | Domdkw/MusicFree-migu `dist/migu-plugin.js` | ✅ 搜索 + 播放直链 + 歌词 + 榜单 |

> 说明：「取链需登录/VIP」「中转失效」是**上游服务端**限制，与运行时无关——插件本身
> 加载、搜索（宿主所需的最小能力）全部正常。

## 跳过（不兼容）的插件及原因

- **jsjiami 混淆加密**（`开心汽水`、`碳酸氢钠`）：代码被混淆，无法改造/维护。
- **依赖 `cheerio` 的 HTML 抓取型**（`bilibili`、`好听轻音乐`、`歌曲宝`、`5sing`、
  `爱听`、`小枸音乐`、`种子` 等）：需完整 jQuery 式 DOM 解析，运行时无此能力，跳过。
- **依赖 `crypto-js`**（`元力MG`、`汽水vip` 部分、`QQ_念心`、`Q音` 等）：需各加密
  算法（MD5/AES/HMAC 等）实现，成本高且易错，跳过。
- **依赖私有 token + 仓库**（`GitCode`）：需要用户自己的 GitCode 仓库与访问令牌，价值低，跳过。
- **依赖 `webdav`/`qs`/`big-integer`**（`WebDAV`、`元力WY`、`溯音网易`）：需额外类库，跳过。

## 如何测试

```bash
source ./env.sh
export LIBQUICKJSC_TEST_PATH="$PWD/modules/quickjs_engine/native/build/libquickjs_c_bridge_plugin.so"
# Windows: $env:LIBQUICKJSC_TEST_PATH = "$PWD\modules\quickjs_engine\native\build\Release\quickjs_c_bridge_plugin.dll"
# 首次需构建原生库：cd modules/quickjs_engine && sh tool/build_native.sh
flutter test test/scripts/musicfree_plugins_test.dart
```

## 如何安装到应用

应用内「设置 → MusicFree 插件 → 粘贴源码安装」把对应 `.js` 文件内容粘贴进去即可；
或用 `PluginRepository.install(source)` 以编程方式安装。
