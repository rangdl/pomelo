// udio (udio.com) —— 改造自 qwerwhr/musicfree-plugins/udio.js
// pomelo 适配：页面顶部注入 fetch 版 axios 兼容层，移除 require('axios')。协议：search/getMediaSource/getTopLists。
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
};
function formatMusicItem(it) {
    return {
        id: it.id,
        artist: it.artist,
        title: it.title,
        createdAt: it.created_at,
        artwork: it.image_path,
        url: it.song_path,
        duration: it.duration,
        mv: it.video_path,
        rawLrc: it.lyrics,
    };
}
async function searchMusic(query, page) {
    const pageSize = 30;
    const data = `{"searchQuery":{"sort":"plays","searchTerm":"${query}"},"pageParam":${page - 1},"pageSize":${pageSize},"trendingId":"93de406e-bdc1-40a6-befd-90637a362158"}`;
    const config = {
        method: "post",
        url: "https://www.udio.com/api/songs/search",
        headers: {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 Edg/106.0.0.0",
            host: "www.udio.com",
        },
        data: data,
    };
    const result = (await (0, axios_1.default)(config)).data.data;
    return {
        isEnd: result.length < pageSize,
        data: result.map(formatMusicItem),
    };
}
async function search(query, page, type) {
    if (type === "music") {
        return await searchMusic(query, page);
    }
}
async function getMediaSource(musicItem, quality) {
    if (quality !== "standard") {
        return;
    }
    return musicItem.url;
}
async function getTopLists() {
    return [
        {
            title: "趋势榜",
            data: [
                {
                    id: "today",
                    maxAgeInHours: 24,
                    type: "search",
                    title: "趋势榜 - 最近一天",
                },
                {
                    id: "1week",
                    maxAgeInHours: 168,
                    type: "search",
                    title: "趋势榜 - 最近一周",
                },
                {
                    id: "1month",
                    maxAgeInHours: 720,
                    type: "search",
                    title: "趋势榜 - 最近一月",
                },
                {
                    id: "alltime",
                    type: "search",
                    title: "趋势榜 - 全部时间",
                },
            ],
        },
        {
            title: "流派榜单",
            data: [
                {
                    id: "89f0089f-1bfe-4713-8070-5830a6161afb",
                    type: "playlist",
                    title: "爵士",
                },
                {
                    id: "935deb12-dc32-4005-a1fe-3c00c284ca52",
                    type: "playlist",
                    title: "乡村",
                },
                {
                    id: "6028ad08-68cb-406d-aa35-a4917b6467d6",
                    type: "playlist",
                    title: "流行",
                },
                {
                    id: "d033aa6e-655e-45d0-8138-dc9a0dc6b3a6",
                    type: "playlist",
                    title: "摇滚",
                },
            ],
        },
    ];
}
async function getTopListDetail(topListItem) {
    if (topListItem.type === "playlist") {
        const res = (await axios_1.default.get(`https://www.udio.com/api/playlists?id=${topListItem.id}`, {
            headers,
        })).data;
        const songList = res.playlists[0].song_list.join(",");
        const songs = (await axios_1.default.get(`https://www.udio.com/api/songs?songIds=${songList}`, {
            headers,
        })).data.songs;
        return {
            isEnd: true,
            musicList: songs.map(formatMusicItem),
        };
    }
    else if (topListItem.type === "search") {
        const pageSize = 30;
        const data = `{"searchQuery":{"sort":"plays","searchTerm":""${topListItem.maxAgeInHours
            ? `,"maxAgeInHours": ${topListItem.maxAgeInHours}`
            : ""}},"pageParam":0,"pageSize":${pageSize}}`;
        const config = {
            method: "post",
            url: "https://www.udio.com/api/songs/search",
            headers: {
                "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 Edg/106.0.0.0",
                host: "www.udio.com",
            },
            data: data,
        };
        const songs = (await (0, axios_1.default)(config)).data.data;
        return {
            isEnd: true,
            musicList: songs.map(formatMusicItem),
        };
    }
}
async function getLyric(musicItem) {
    return {
        rawLrc: musicItem.rawLrc
    };
}
module.exports = {
    platform: "udio",
    author: "猫头猫",
    version: "0.0.0",
    supportedSearchType: ["music"],
    srcUrl: "https://gitee.com/maotoumao/MusicFreePlugins/raw/v0.1/dist/udio/index.js",
    cacheControl: "no-cache",
    search,
    getMediaSource,
    getTopListDetail,
    getTopLists,
    getLyric
};
