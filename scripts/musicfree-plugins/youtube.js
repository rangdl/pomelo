// Youtube (youtubei) —— 改造自 qwerwhr/musicfree-plugins/Youtube.js
// pomelo 适配：页面顶部注入 fetch 版 axios 兼容层，移除 require('axios')。协议：search/getMediaSource。
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
function formatMusicItem(item) {
    var _a, _b, _c, _d, _e, _f, _g;
    return {
        id: item.videoId,
        title: (_b = (_a = item.title.runs) === null || _a === void 0 ? void 0 : _a[0]) === null || _b === void 0 ? void 0 : _b.text,
        artist: (_d = (_c = item.ownerText.runs) === null || _c === void 0 ? void 0 : _c[0]) === null || _d === void 0 ? void 0 : _d.text,
        artwork: (_g = (_f = (_e = item === null || item === void 0 ? void 0 : item.thumbnail) === null || _e === void 0 ? void 0 : _e.thumbnails) === null || _f === void 0 ? void 0 : _f[0]) === null || _g === void 0 ? void 0 : _g.url,
    };
}
let lastQuery;
let musicContinToken;
async function searchMusic(query, page) {
    if (query !== lastQuery || page === 1) {
        musicContinToken = undefined;
    }
    lastQuery = query;
    let data = JSON.stringify({
        context: {
            client: {
                hl: "zh-CN",
                gl: "US",
                deviceMake: "",
                deviceModel: "",
                userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0,gzip(gfe)",
                clientName: "WEB",
                clientVersion: "2.20231121.08.00",
                osName: "Windows",
                osVersion: "10.0",
                platform: "DESKTOP",
                userInterfaceTheme: "USER_INTERFACE_THEME_LIGHT",
                browserName: "Edge Chromium",
                browserVersion: "119.0.0.0",
                acceptHeader: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
                screenWidthPoints: 1358,
                screenHeightPoints: 1012,
                screenPixelDensity: 1,
                screenDensityFloat: 1.2395833730697632,
                utcOffsetMinutes: 480,
                memoryTotalKbytes: "8000000",
                mainAppWebInfo: {
                    pwaInstallabilityStatus: "PWA_INSTALLABILITY_STATUS_UNKNOWN",
                    webDisplayMode: "WEB_DISPLAY_MODE_BROWSER",
                    isWebNativeShareAvailable: true,
                },
                timeZone: "Asia/Shanghai",
            },
            user: {
                lockedSafetyMode: false,
            },
            request: {
                useSsl: true,
                internalExperimentFlags: [],
            },
        },
        query: musicContinToken ? undefined : query,
        continuation: musicContinToken || undefined,
    });
    var config = {
        method: "post",
        url: "https://www.youtube.com/youtubei/v1/search?prettyPrint=false",
        headers: {
            "Content-Type": "text/plain",
        },
        data: data,
    };
    const response = (await (0, axios_1.default)(config)).data;
    const contents = response.contents.twoColumnSearchResultsRenderer.primaryContents
        .sectionListRenderer.contents;
    const isEndItem = contents.find((it) => {
        var _a, _b, _c;
        return ((_c = (_b = (_a = it.continuationItemRenderer) === null || _a === void 0 ? void 0 : _a.continuationEndpoint) === null || _b === void 0 ? void 0 : _b.continuationCommand) === null || _c === void 0 ? void 0 : _c.request) === "CONTINUATION_REQUEST_TYPE_SEARCH";
    });
    if (isEndItem) {
        musicContinToken =
            isEndItem.continuationItemRenderer.continuationEndpoint
                .continuationCommand.token;
    }
    const musicData = contents.find((it) => it.itemSectionRenderer)
        .itemSectionRenderer.contents;
    let resultMusicData = [];
    for (let i = 0; i < musicData.length; ++i) {
        if (musicData[i].videoRenderer) {
            resultMusicData.push(formatMusicItem(musicData[i].videoRenderer));
        }
    }
    return {
        isEnd: !isEndItem,
        data: resultMusicData,
    };
}
async function search(query, page, type) {
    if (type === "music") {
        return await searchMusic(query, page);
    }
}
let cacheMediaSource = {
    id: null,
    urls: {},
};
function getQuality(label) {
    if (label === "small") {
        return "standard";
    }
    else if (label === "tiny") {
        return "low";
    }
    else if (label === "medium") {
        return "high";
    }
    else if (label === "large") {
        return "super";
    }
    else {
        return "standard";
    }
}
async function getMediaSource(musicItem, quality) {
    var _a, _b;
    if (musicItem.id === cacheMediaSource.id) {
        return {
            url: cacheMediaSource.urls[quality],
        };
    }
    cacheMediaSource = {
        id: null,
        urls: {},
    };
    const data = {
        context: {
            client: {
                screenWidthPoints: 689,
                screenHeightPoints: 963,
                screenPixelDensity: 1,
                utcOffsetMinutes: 120,
                hl: "en",
                gl: "GB",
                remoteHost: "1.1.1.1",
                deviceMake: "",
                deviceModel: "",
                userAgent: "com.google.android.apps.youtube.music/6.14.50 (Linux; U; Android 13; GB) gzip",
                clientName: "ANDROID_MUSIC",
                clientVersion: "6.14.50",
                osName: "Android",
                osVersion: "13",
                originalUrl: "https://www.youtube.com/tv?is_account_switch=1&hrld=1&fltor=1",
                theme: "CLASSIC",
                platform: "MOBILE",
                clientFormFactor: "UNKNOWN_FORM_FACTOR",
                webpSupport: false,
                timeZone: "Europe/Amsterdam",
                acceptHeader: "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            },
            user: { enableSafetyMode: false },
            request: {
                internalExperimentFlags: [],
                consistencyTokenJars: [],
            },
        },
        contentCheckOk: true,
        racyCheckOk: true,
        video_id: musicItem.id,
    };
    var config = {
        method: "post",
        url: "https://www.youtube.com/youtubei/v1/player?prettyPrint=false",
        headers: {
            "Content-Type": "application/json",
        },
        data: JSON.stringify(data),
    };
    const result = (await (0, axios_1.default)(config)).data;
    const formats = (_a = result.streamingData.formats) !== null && _a !== void 0 ? _a : [];
    const adaptiveFormats = (_b = result.streamingData.adaptiveFormats) !== null && _b !== void 0 ? _b : [];
    [...formats, ...adaptiveFormats].forEach((it) => {
        const q = getQuality(it.quality);
        if (q && it.url && !cacheMediaSource.urls[q]) {
            cacheMediaSource.urls[q] = it.url;
        }
    });
    return {
        url: cacheMediaSource.urls[quality],
    };
}
module.exports = {
    platform: "Youtube",
    author: '猫头猫',
    version: "0.0.1",
    supportedSearchType: ["music"],
    srcUrl: "https://gitee.com/maotoumao/MusicFreePlugins/raw/v0.1/dist/youtube/index.js",
    cacheControl: "no-cache",
    search,
    getMediaSource,
};
