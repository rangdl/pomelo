// 猫耳FM (missevan.com) —— 改造自 qwerwhr/musicfree-plugins/猫耳FM.js
// pomelo 适配：页面顶部注入 fetch 版 axios 兼容层，移除 require('axios')。协议：search/getMediaSource/getAlbumInfo。
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
const pageSize = 30;
function validMusicFilter(_) {
    return `${_.pay_type}` === "0";
}
function formatMusicItem(_) {
    var _a;
    return {
        id: _.id,
        artwork: _.front_cover,
        title: _.soundstr,
        artist: _.username,
        user_id: _.user_id,
        duration: +((_a = _.duration) !== null && _a !== void 0 ? _a : 0),
    };
}
function formatAlbumItem(_) {
    return {
        id: _.id,
        artist: _.author,
        title: _.name,
        artwork: _.cover,
        description: _.abstract,
    };
}
const searchHeaders = {
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
    accept: "application/json",
    "accept-encoding": "gzip, deflate, br",
    referer: "https://www.missevan.com/sound/search",
};
async function searchMusic(query, page) {
    const res = (await axios_1.default.get("https://www.missevan.com/sound/getsearch", {
        params: {
            s: query,
            p: page,
            type: 3,
            page_size: pageSize,
        },
        headers: searchHeaders,
    })).data.info;
    return {
        isEnd: res.pagination.p >= res.pagination.maxpage,
        data: res.Datas.filter(validMusicFilter).map(formatMusicItem),
    };
}
async function searchAlbum(query, page) {
    const res = (await axios_1.default.get("https://www.missevan.com/dramaapi/search", {
        headers: searchHeaders,
        params: {
            s: query,
            page,
        },
    })).data.info;
    return {
        isEnd: res.pagination.p >= res.pagination.maxpage,
        data: res.Datas.filter(validMusicFilter).map(formatAlbumItem),
    };
}
async function getAlbumInfo(albumItem) {
    const res = (await axios_1.default.get("https://www.missevan.com/dramaapi/getdrama", {
        headers: {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
            accept: "application/json",
            "accept-encoding": "gzip, deflate, br",
            referer: `https://www.missevan.com/mdrama/${albumItem.id}`,
        },
        params: {
            drama_id: albumItem.id,
        },
    })).data;
    return {
        musicList: res.info.episodes.episode
            .filter(validMusicFilter)
            .map(_ => {
            const r = formatMusicItem(_);
            r.artwork = albumItem.artwork;
            return r;
        }),
    };
}
async function getMediaSource(musicItem, quality) {
    if (quality === "high" || quality === "super") {
        return;
    }
    const res = (await axios_1.default.get("https://www.missevan.com/sound/getsound", {
        headers: {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
            accept: "application/json",
            "accept-encoding": "gzip, deflate, br",
            referer: `https://www.missevan.com/sound/player?id=${musicItem.id}`,
        },
        params: {
            soundid: musicItem.id,
        },
    })).data.info;
    if (quality === "low") {
        return {
            url: res.sound.soundurl_128,
        };
    }
    else {
        return {
            url: res.sound.soundurl,
        };
    }
}
async function getRecommendSheetTags() {
    const res = (await axios_1.default.get(`https://www.missevan.com/malbum/recommand`, {
        headers: {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
            accept: "application/json",
            "accept-encoding": "gzip, deflate, br",
            referer: `https://www.missevan.com`,
        }
    })).data.info;
    const data = Object.entries(res !== null && res !== void 0 ? res : {}).map(group => ({
        title: group[0],
        data: group[1].map(_ => ({
            id: _[0],
            title: _[1]
        }))
    }));
    return {
        data,
    };
}
async function getRecommendSheetsByTag(tag, page) {
    const res = (await axios_1.default.get(`https://www.missevan.com/explore/tagalbum`, {
        headers: {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
            accept: "application/json",
            "accept-encoding": "gzip, deflate, br",
            referer: `https://m.missevan.com`,
        },
        params: {
            order: 0,
            tid: (tag === null || tag === void 0 ? void 0 : tag.id) || 0,
            p: page
        }
    })).data;
    return {
        isEnd: res.page >= res.maxpage,
        data: res.albums.map(sheet => ({
            id: sheet.id,
            title: sheet.title,
            artwork: sheet.front_cover,
            artist: sheet.username,
            createUserId: sheet.user_id
        }))
    };
}
async function getMusicSheetInfo(sheet, page) {
    const res = (await axios_1.default.get(`https://www.missevan.com/sound/soundalllist`, {
        headers: {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
            accept: "application/json",
            "accept-encoding": "gzip, deflate, br",
            referer: `https://m.missevan.com`,
        },
        params: {
            albumid: sheet.id
        }
    })).data.info;
    return {
        isEnd: true,
        musicList: res.sounds.filter(validMusicFilter).map(item => ({
            id: item.id,
            title: item.soundstr,
            artwork: item.front_cover,
            url: item.soundurl,
            artist: item.username,
        }))
    };
}
module.exports = {
    platform: "猫耳FM",
    author: '猫头猫',
    version: "0.1.4",
    appVersion: ">0.1.0-alpha.0",
    srcUrl: "https://gitee.com/maotoumao/MusicFreePlugins/raw/v0.1/dist/maoerfm/index.js",
    cacheControl: "no-cache",
    supportedSearchType: ["music", "album",],
    async search(query, page, type) {
        if (type === "music") {
            return await searchMusic(query, page);
        }
        if (type === "album") {
            return await searchAlbum(query, page);
        }
    },
    getMediaSource,
    getAlbumInfo,
    getRecommendSheetTags,
    getRecommendSheetsByTag,
    getMusicSheetInfo
};
