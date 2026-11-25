// suno (studio-api.suno.ai) —— 改造自 qwerwhr/musicfree-plugins/suno.js
// pomelo 适配：页面顶部注入 fetch 版 axios 兼容层，移除 require('axios')。协议：getTopLists/getTopListDetail/getLyric。
// ==== pomelo 运行时兼容层：用全局 fetch 实现 axios 的最小子集 ====
// 本项目的 quickjs 运行时只提供 fetch 与 JS 内建对象，没有 require/axios。
// 本层把插件对 axios.get/post/request 的调用翻译成 fetch。
function __pmQs(obj) {
  if (!obj) return '';
  return Object.keys(obj)
    .filter(function (k) { return obj[k] !== undefined && obj[k] !== null; })
    .map(function (k) { return encodeURIComponent(k) + '=' + encodeURIComponent(obj[k]); })
    .join('&');
}
function __pmUrl(url, params) {
  var q = __pmQs(params);
  if (!q) return url;
  return url + (url.indexOf('?') === -1 ? '?' : '&') + q;
}
async function __pmAxiosRequest(config) {
  config = config || {};
  var method = String(config.method || 'get').toUpperCase();
  var url = __pmUrl(config.url || config.uri || '', config.params);
  var headers = {};
  var src = config.headers || {};
  Object.keys(src).forEach(function (k) { headers[k] = src[k]; });
  var body;
  if (config.data !== undefined && config.data !== null) {
    if (typeof config.data === 'string') {
      body = config.data;
    } else {
      body = JSON.stringify(config.data);
      if (!headers['Content-Type'] && !headers['content-type']) {
        headers['Content-Type'] = 'application/json';
      }
    }
  }
  var resp = await fetch(url, { method: method, headers: headers, body: body });
  var txt = await resp.text();
  var data;
  try { data = JSON.parse(txt); } catch (e) { data = txt; }
  return { data: data, status: resp.status, headers: resp.headers, config: config };
}
var _axios = function (config) {
  if (typeof config === 'string') config = { url: config };
  return __pmAxiosRequest(config);
};
_axios.get = function (url, config) {
  config = config || {};
  config.url = url;
  config.method = 'get';
  return __pmAxiosRequest(config);
};
_axios.post = function (url, data, config) {
  config = config || {};
  config.url = url;
  config.method = 'post';
  config.data = data;
  return __pmAxiosRequest(config);
};
_axios.request = _axios;
_axios.default = _axios;
// ==== 兼容层结束 ====

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const axios_1 = _axios; const __axios_default = _axios;
const headers = {
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
    host: "studio-api.suno.ai"
};
async function getTopLists() {
    return [
        {
            title: "趋势榜",
            data: [
                {
                    id: "1190bf92-10dc-4ce5-968a-7a377f37f984",
                    title: "趋势榜 - 最近一天",
                },
                {
                    id: "08a079b2-a63b-4f9c-9f29-de3c1864ddef",
                    title: "趋势榜 - 最近一周",
                },
                {
                    id: "845539aa-2a39-4cf5-b4ae-16d3fe159a77",
                    title: "趋势榜 - 最近一月",
                },
                {
                    id: "6943c7ee-cbc5-4f72-bc4e-f3371a8be9d5",
                    title: "趋势榜 - 全部时间",
                },
            ],
        },
        {
            title: "最新榜",
            data: [
                {
                    id: "cc14084a-2622-4c4b-8258-1f6b4b4f54b3",
                    title: "最新榜",
                },
            ],
        },
        {
            title: "其他类别",
            data: [
                {
                    id: "1ac7823f-8faf-474f-b14c-e4f7c7bb373f",
                    title: "动物开会",
                },
                {
                    id: '6713d315-3541-460d-8788-162cce241336',
                    title: 'Lo-Fi'
                }
            ],
        },
    ];
}
async function getTopListDetail(topListItem) {
    const result = (await axios_1.default.get(`https://studio-api.suno.ai/api/playlist/${topListItem.id}/?page=0`, {
        headers
    })).data;
    return {
        isEnd: true,
        musicList: result.playlist_clips.map(it => {
            var _a, _b;
            const clip = it.clip;
            return {
                id: clip.id,
                url: clip.audio_url,
                artwork: clip.image_large_url || clip.image_url,
                duration: (_a = clip.metadata) === null || _a === void 0 ? void 0 : _a.duration,
                title: clip.title,
                artist: clip.display_name,
                userId: clip.user_id,
                rawLrc: (_b = clip.metadata) === null || _b === void 0 ? void 0 : _b.prompt
            };
        })
    };
}
async function getLyric(musicItem) {
    return {
        rawLrc: musicItem.rawLrc
    };
}
module.exports = {
    platform: "suno",
    version: "0.0.0",
    srcUrl: "https://gitee.com/maotoumao/MusicFreePlugins/raw/v0.1/dist/suno/index.js",
    cacheControl: "no-cache",
    getTopLists,
    getTopListDetail,
    getLyric
};
getTopListDetail({
    id: "1ac7823f-8faf-474f-b14c-e4f7c7bb373f",
    title: "最新榜",
}).then(e => console.log(e.musicList[0]));
