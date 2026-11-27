/*!
 * @name 聚合音源·后端版（36 个后端 · v4）
 * @version 4.0.0
 * @description 不再整份嵌入其它音源脚本：把各音源的 API 拆成独立后端，由统一运行时按平台调度
 * @license 仅限个人学习使用，请自行遵守各平台条款
 *
 * 设计：
 * - 每个后端只负责「构造请求 + 解析 URL」，注册、排序、竞速、校验、熔断、缓存、降级、取消全部由运行时负责
 * - 同平台候选按「上次命中 → 原始顺序 → 冷却中」排序，120ms 阶梯放行，最多 3 个并行，先过校验者胜
 * - 校验：Range bytes=0-511 优先，失败再 HEAD；检查 content-type 与 content-length（挡提示音/试听片段）
 * - 错误四分类：business 不计数、limited 立即冷却 60s、network 2 次 45s、media 2 次 90s
 * - 缓存：20s 直出；20s~6h 先复检；失败不缓存；同键并发合并
 * - 音质：只声明至少 2 个后端支持的档位；某档位无候选或全失败时自动降级（最多 2 档）
 */
;(function () {
  'use strict'
  var realLx = globalThis.lx
  if (!realLx || typeof realLx.on !== 'function' || typeof realLx.send !== 'function') {
    throw new Error('聚合音源：当前运行环境没有提供 LX 接口')
  }
  var EVENT_NAMES = realLx.EVENT_NAMES || { request: 'request', inited: 'inited' }
  var UA = 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36'

  var CONFIG = {
    HEDGE_DELAY: 120,
    MAX_PARALLEL: 3,
    ATTEMPT_TIMEOUT: 3000,
    CHECK_TIMEOUT: 1200,
    TOTAL_TIMEOUT: 8000,
    MAX_HTTP: 5,
    HOT_TTL: 20000,
    CACHE_TTL: 21600000,
    CACHE_MAX: 400,
    MAX_DOWNGRADE: 2,
    COOLDOWN_LIMITED: 60000,
    COOLDOWN_NETWORK: 45000,
    COOLDOWN_MEDIA: 90000,
    FAIL_NETWORK: 2,
    FAIL_MEDIA: 2
  }

  var QUALITY_ORDER = ['128k', '192k', '320k', 'flac', 'flac24bit', 'hires', 'atmos', 'atmos_plus', 'master', 'spatial']
  var DOWNGRADE = {
    master: 'flac24bit', atmos_plus: 'atmos', atmos: 'flac', hires: 'flac24bit', spatial: 'flac',
    flac24bit: 'flac', flac: '320k', '320k': '192k', '192k': '128k'
  }
  var COMMON_QUALITY = { '128k': 1, '192k': 1, '320k': 1, 'flac': 1, 'flac24bit': 1, 'hires': 1 }

/* 后端定义：每个 provider 只负责「构造请求 + 解析出音频 URL」，不注册事件、不自己调度。
   运行时统一做排序、竞速、校验、熔断、缓存、降级、取消。
   这里只保留 2026-11 实测能返回地址的后端；挂掉的服务不要留，避免无意义重试。 */
var PROVIDERS = []

function pQuery(obj) {
  var keys = Object.keys(obj)
  var out = []
  for (var i = 0; i < keys.length; i++) {
    if (obj[keys[i]] === undefined || obj[keys[i]] === null || obj[keys[i]] === '') continue
    out.push(encodeURIComponent(keys[i]) + '=' + encodeURIComponent(obj[keys[i]]))
  }
  return out.join('&')
}
function pJson(v) {
  if (v && typeof v === 'object') return v
  if (typeof v === 'string') {
    try { return JSON.parse(v) } catch (e) {}
  }
  throw new Error('接口返回的不是 JSON')
}
function pPick(obj, paths) {
  for (var i = 0; i < paths.length; i++) {
    var cur = obj, keys = paths[i].split('.'), ok = true
    for (var j = 0; j < keys.length; j++) {
      if (cur === null || cur === undefined) { ok = false; break }
      cur = cur[keys[j]]
    }
    if (ok && typeof cur === 'string' && /^https?:\/\//i.test(cur.trim())) return cur.trim()
  }
  return ''
}
function pLevel(q) { return { '128k': 'standard', '320k': 'exhigh', flac: 'lossless', flac24bit: 'lossless' }[q] }
function pBr(q) { return { '128k': '128kmp3', '320k': '320kmp3', flac: '2000kflac', flac24bit: '4000kflac' }[q] }
var P_UA = 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36'

// wwwweb 是跨平台网关，但按「一个服务一个后端」拆成 4 条，便于分别熔断
function wwwweb(platform, qualitys) {
  return {
    id: platform + '-wwwweb', name: 'wwwweb(' + platform + ')', platforms: [platform], qualitys: qualitys,
    run: function (ctx) {
      return ctx.http('https://c.wwwweb.top/music/url', {
        method: 'POST',
        headers: { 'User-Agent': 'lx-music-mobile/2.0.0', 'Content-Type': 'application/json' },
        body: JSON.stringify({ source: platform, musicId: ctx.getId(), quality: ctx.quality })
      }).then(function (r) {
        var d = pJson(r.body)
        var u = pPick(d, ['url', 'data.url'])
        if (u) return u
        throw new Error('wwwweb(' + platform + ') 没有返回地址')
      })
    }
  }
}

// ==================== 酷我 ====================

// 酷我官方移动接口（nmobi）——轻量/酷我手机版/monster 实际都打这一个接口
PROVIDERS.push({
  id: 'kw-nmobi', name: '酷我官方 nmobi', platforms: ['kw'],
  qualitys: ['128k', '320k', 'flac', 'flac24bit'],
  run: function (ctx) {
    var url = 'https://nmobi.kuwo.cn/mobi.s?' + pQuery({
      f: 'web', user: 0, source: 'kwplayerhd_ar_4.3.0.8_tianbao_T1A_qirui.apk',
      type: 'convert_url_with_sign', rid: ctx.getId(), br: pBr(ctx.quality)
    })
    return ctx.http(url, { headers: { 'User-Agent': 'okhttp/4.10.0' } }).then(function (r) {
      var d = pJson(r.body)
      if (Number(d && d.code) === 200 && d.data && d.data.url) return String(d.data.url).split('?')[0]
      throw new Error('酷我接口未返回地址')
    })
  }
})

// 酷我官方另一域名 + jiakong 来源（KuwoDES）已移除：
// 实测对部分歌曲只返回 11 秒试听（185,336 字节），不是完整音频。

PROVIDERS.push(wwwweb('kw', ['128k', '320k', 'flac']))

// 念心自家 PHP 网关（服务端 302 到音频）
PROVIDERS.push({
  id: 'kw-nianxin', name: '念心 PHP(酷我)', platforms: ['kw'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return Promise.resolve('http://mcp.nianxinxz.com/share/ceshi/kw.php?' + pQuery({ id: ctx.getId(), level: pLevel(ctx.quality), type: 'mp3' }))
  }
})

// ==================== QQ ====================

// 讯汇 QQ 专用（仅 128k）
PROVIDERS.push({
  id: 'tx-xunhuisi', name: '讯汇 QQ(128k)', platforms: ['tx'],
  qualitys: ['128k'],
  run: function (ctx) {
    var url = 'https://api.xunhuisi.store/API/QQMusic/Song.php?' + pQuery({ mid: ctx.getId(), type: 'json' })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var d = pJson(r.body)
      if (Number(d && d.code) === 200 && typeof d.music_url === 'string') return d.music_url.trim()
      throw new Error('讯汇接口没有地址')
    })
  }
})

// cyapi（稳定版 QQ）
PROVIDERS.push({
  id: 'tx-cyapi', name: 'cyapi(QQ)', platforms: ['tx'],
  qualitys: ['128k', '320k', 'flac', 'flac24bit'],
  run: function (ctx) {
    var url = 'https://cyapi.top/API/qq_music.php?' + pQuery({
      apikey: '1ffdf5733f5d538760e63d7e46ba17438d9f7b9dfc18c51be1109386fd74c3a1',
      type: 'json', mid: ctx.getId()
    })
    return ctx.http(url, { headers: { 'User-Agent': P_UA, Accept: 'application/json' } }).then(function (r) {
      var d = pJson(r.body)
      var u = pPick(d, ['url', 'data.url', 'data.play_url'])
      if (u) return u
      throw new Error('cyapi 没有返回地址')
    })
  }
})

PROVIDERS.push({
  id: 'tx-nianxin', name: '念心 PHP(QQ)', platforms: ['tx'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return Promise.resolve('http://mcp.nianxinxz.com/share/ceshi/tx.php?' + pQuery({ id: ctx.getId(), level: pLevel(ctx.quality), type: 'mp3' }))
  }
})

// ==================== 网易 ====================

PROVIDERS.push(wwwweb('wy', ['128k', '320k', 'flac', 'flac24bit']))

// qjqq
PROVIDERS.push({
  id: 'wy-qjqq', name: 'qjqq(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return ctx.http('https://metings.qjqq.cn/Song_V1', {
      method: 'POST',
      headers: { 'User-Agent': P_UA, 'Content-Type': 'application/x-www-form-urlencoded' },
      body: pQuery({ url: ctx.getId(), level: pLevel(ctx.quality), type: 'json' })
    }).then(function (r) {
      var u = pPick(pJson(r.body), ['data.url', 'url', 'data'])
      if (u) return u
      throw new Error('qjqq 没有返回地址')
    })
  }
})

// GD 公共接口（5 分钟 40 次上限，超了直接报限流）
var gdTimes = []
PROVIDERS.push({
  id: 'wy-gd', name: 'GD 公共(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var now = Date.now(), alive = []
    for (var i = 0; i < gdTimes.length; i++) if (now - gdTimes[i] < 300000) alive.push(gdTimes[i])
    gdTimes = alive
    if (gdTimes.length >= 40) throw new Error('GD 接口限流')
    gdTimes.push(now)
    var br = { '128k': 128, '320k': 320, flac: 740 }[ctx.quality]
    var url = 'https://music-api.gdstudio.xyz/api.php?' + pQuery({ types: 'url', source: 'netease', id: ctx.getId(), br: br })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url', 'data'])
      if (u) return u
      throw new Error('GD 接口没有返回地址')
    })
  }
})

// 网易官方外链（仅 128k，非 VIP 歌曲可用）
PROVIDERS.push({
  id: 'wy-163outer', name: '网易官方外链(128k)', platforms: ['wy'],
  qualitys: ['128k'],
  run: function (ctx) {
    return Promise.resolve('https://music.163.com/song/media/outer/url?id=' + encodeURIComponent(ctx.getId()) + '.mp3')
  }
})

PROVIDERS.push({
  id: 'wy-nianxin', name: '念心 PHP(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return Promise.resolve('http://mcp.nianxinxz.com/share/ceshi/wy.php?' + pQuery({ id: ctx.getId(), level: pLevel(ctx.quality), type: 'mp3' }))
  }
})

PROVIDERS.push({
  id: 'wy-nxinxz', name: '念心 nxinxz(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return Promise.resolve('http://music.nxinxz.com/csy/wy.php?' + pQuery({ id: ctx.getId(), level: pLevel(ctx.quality), type: 'mp3' }))
  }
})

// ==================== 酷狗 ====================

PROVIDERS.push({
  id: 'kg-nianxin', name: '念心 PHP(酷狗)', platforms: ['kg'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return Promise.resolve('http://mcp.nianxinxz.com/share/ceshi/kg.php?' + pQuery({ id: ctx.getId(), level: pLevel(ctx.quality), type: 'mp3' }))
  }
})

// ==================== 咪咕 ====================

// 咪咕官方 listen-url（monster 内置 token，会过期）
PROVIDERS.push({
  id: 'mg-migu', name: '咪咕官方 listen-url', platforms: ['mg'],
  qualitys: ['128k', '320k', 'flac', 'flac24bit'],
  run: function (ctx) {
    var flag = { '128k': 'PQ', '320k': 'HQ', flac: 'SQ', flac24bit: 'ZQ' }[ctx.quality]
    var id = ctx.info.copyrightId || ctx.getId()
    var url = 'https://app.c.nf.migu.cn/MIGUM2.0/strategy/listen-url/v2.4?' + pQuery({ netType: '01', resourceType: 'E', songId: id, toneFlag: flag })
    return ctx.http(url, {
      headers: {
        'User-Agent': P_UA, channel: '014000D',
        token: '848401000134020058524459344E544130526A4932517A55344D7A56434E55453240687474703A2F2F70617373706F72742E6D6967752E636E2F6E303030312F4062393662376634326336326434303935393366666433366434313939393033300300040298EAFB0400063232303032340500164D4759355A4463784D324E684E4449324F57566B4E51FF0020795263B9A333A4580E13DD7F28820A8B9788F30062F6025FA08BF10CC5A8AA04',
        aversionid: 'DF94898993A5A28A64968A9FD0ADA0749397878BC39DD7BC68C584A1BAAFC96EC5938D8D8ED1A490949A8F9EB680997296DFD0D391D6ABBC69928AD0B57D99779CC8B88CDDECEE89628F89A1827E986F94978AD392A7A2916A928AA4878199779C'
      }
    }).then(function (r) {
      var d = pJson(r.body)
      var u = d && d.data && d.data.url
      if (!u) throw new Error('咪咕接口没有地址')
      if (u.indexOf('//') === 0) u = 'https:' + u
      return u.replace(/\+/g, '%2B').split('?')[0]
    })
  }
})

PROVIDERS.push({
  id: 'mg-nianxin', name: '念心 PHP(咪咕)', platforms: ['mg'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return Promise.resolve('http://mcp.nianxinxz.com/share/ceshi/mg.php?' + pQuery({ id: ctx.info.copyrightId || ctx.getId(), level: pLevel(ctx.quality), type: 'mp3' }))
  }
})

// ==================== 第二批：从其他音源拆出的独立后端 ====================

// —— 网易 ——

PROVIDERS.push({
  id: 'wy-163api', name: '网易官方 enhance', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var br = { '128k': 128000, '320k': 320000, flac: 999000 }[ctx.quality] || 320000
    var url = 'https://music.163.com/api/song/enhance/player/url?' + pQuery({ id: ctx.getId(), ids: '[' + ctx.getId() + ']', br: br })
    return ctx.http(url, { headers: { 'User-Agent': P_UA, Referer: 'https://music.163.com/' } }).then(function (r) {
      var d = pJson(r.body)
      var item = d && d.data && d.data[0]
      if (item && item.url) return item.url
      throw new Error('网易官方无地址')
    })
  }
})

PROVIDERS.push({
  id: 'wy-oiapi', name: '溯音163(oiapi)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return ctx.http('https://oiapi.net/api/Music_163?' + pQuery({ id: ctx.getId() }), { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var d = pJson(r.body)
      var u = pPick(d, ['url', 'data.url', 'data.0.url'])
      if (u) return u
      throw new Error('溯音163 无地址')
    })
  }
})

PROVIDERS.push({
  id: 'wy-cenguigui', name: '笒鬼鬼(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return ctx.http('https://api.cenguigui.cn/api/netease/music_v1.php?' + pQuery({ id: ctx.getId() }), { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('笒鬼鬼无地址')
    })
  }
})

PROVIDERS.push({
  id: 'wy-bugpk', name: 'Bugpk 外链', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return ctx.http('https://api.bugpk.com/api/163_music?' + pQuery({ type: 'json', ids: ctx.getId() }), { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url', 'data.0.url'])
      if (u) return u
      throw new Error('Bugpk 无地址')
    })
  }
})

PROVIDERS.push({
  id: 'wy-sayqz', name: '幻音解析(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://music-dl.sayqz.com/api/?' + pQuery({ source: 'netease', id: ctx.getId(), type: 'url', br: ctx.quality })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('幻音无地址')
    })
  }
})

PROVIDERS.push({
  id: 'wy-ffapi', name: 'FFAPI 网易', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://ffapi.cn/int/v1/netease_url?' + pQuery({ id: ctx.getId(), quality: 'exhigh' })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('FFAPI 无地址')
    })
  }
})

PROVIDERS.push({
  id: 'wy-lzm', name: 'Lzm(网易)', platforms: ['wy'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    return ctx.http('https://music.lzmhhh.com/api/music/url', {
      method: 'POST',
      headers: { 'User-Agent': P_UA, 'Content-Type': 'application/x-www-form-urlencoded', Referer: 'https://music.lzmhhh.com/' },
      body: pQuery({ id: ctx.getId(), type: 'wy' })
    }).then(function (r) {
      var d = pJson(r.body)
      var u = (typeof d.data === 'string' && /^https?:\/\//.test(d.data)) ? d.data : pPick(d, ['url', 'data.url'])
      if (u) return u
      throw new Error('Lzm 无地址')
    })
  }
})

// —— QQ ——

PROVIDERS.push({
  id: 'tx-vkeys', name: 'Vkeys(QQ)', platforms: ['tx'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://api.vkeys.cn/v2/music/tencent/geturl?' + pQuery({ mid: ctx.getId() })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url', 'data'])
      if (u) return u
      throw new Error('Vkeys 无地址')
    })
  }
})

PROVIDERS.push({
  id: 'tx-vkeys-hires', name: 'Vkeys 无损(QQ)', platforms: ['tx'],
  qualitys: ['flac', 'flac24bit'],
  run: function (ctx) {
    var url = 'https://api.vkeys.cn/music/tencent/song/link?' + pQuery({ mid: ctx.getId() })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url', 'data'])
      if (u) return u
      throw new Error('Vkeys 无损无地址')
    })
  }
})

// 流云 BaiMusic（QQ）已移除：实测对部分歌曲返回 148,117 字节的短提示音。

PROVIDERS.push({
  id: 'tx-sayqz', name: '幻音解析(QQ)', platforms: ['tx'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://music-dl.sayqz.com/api/?' + pQuery({ source: 'qq', id: ctx.getId(), type: 'url', br: ctx.quality })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('幻音QQ无地址')
    })
  }
})

// —— 酷我 ——

PROVIDERS.push({
  id: 'kw-antiserver', name: '酷我 antiserver', platforms: ['kw'],
  qualitys: ['128k', '320k'],
  run: function (ctx) {
    var url = 'https://antiserver.kuwo.cn/anti.s?' + pQuery({ type: 'convert_url', rid: ctx.getId(), format: 'mp3', response: 'url' })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var t = String(r.body || '').trim()
      if (/^https?:\/\//.test(t)) return t
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('antiserver 无地址')
    })
  }
})

PROVIDERS.push({
  id: 'kw-sayqz', name: '幻音解析(酷我)', platforms: ['kw'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://music-dl.sayqz.com/api/?' + pQuery({ source: 'kuwo', id: ctx.getId(), type: 'url', br: ctx.quality })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('幻音酷我无地址')
    })
  }
})

// —— 酷狗 ——

PROVIDERS.push({
  id: 'kg-haitang', name: '海棠(酷狗)', platforms: ['kg'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://music.haitangw.cc/kgqq/kg.php?' + pQuery({ type: 'mp3', id: ctx.getId(), level: ctx.quality })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('海棠无地址')
    })
  }
})

PROVIDERS.push({
  id: 'kg-nxinxz', name: '念心备用(酷狗)', platforms: ['kg'],
  qualitys: ['128k', '320k', 'flac'],
  run: function (ctx) {
    var url = 'https://music.nxinxz.com/kgqq/kg.php?' + pQuery({ id: ctx.getId(), level: ctx.quality, type: 'mp3' })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['url', 'data.url'])
      if (u) return u
      throw new Error('念心酷狗无地址')
    })
  }
})

// —— 咪咕（按歌名搜索，必须校验歌手） ——

PROVIDERS.push({
  id: 'mg-oiapi', name: '溯音咪咕(oiapi)', platforms: ['mg'],
  qualitys: ['128k'],
  run: function (ctx) {
    if (!ctx.name) throw new Error('缺少歌名')
    var url = 'https://oiapi.net/api/MiGu_Music?' + pQuery({ msg: ctx.name + ' ' + ctx.singer, n: 1, type: 'json' })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var d = pJson(r.body)
      var u = pPick(d, ['data.url', 'data.musicUrl', 'data.playUrl', 'url', 'musicInfo'])
      if (u) return u
      throw new Error('溯音咪咕无地址')
    })
  }
})

PROVIDERS.push({
  id: 'mg-xcvts', name: 'XCVTS 咪咕', platforms: ['mg'],
  qualitys: ['128k'],
  run: function (ctx) {
    if (!ctx.name) throw new Error('缺少歌名')
    var url = 'https://api.xcvts.cn/api/music/migu?' + pQuery({ gm: ctx.name })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var u = pPick(pJson(r.body), ['data.url', 'url', 'musicInfo'])
      if (u) return u
      throw new Error('XCVTS 咪咕无地址')
    })
  }
})

// —— 汽水（新增平台） ——

PROVIDERS.push({
  id: 'qs-vsaa', name: '汽水 VIP(vsaa)', platforms: ['qs'],
  qualitys: ['128k', '320k', 'flac', 'flac24bit'],
  run: function (ctx) {
    var q = { '128k': 'low', '320k': 'standard', flac: 'lossless', flac24bit: 'hi_res' }[ctx.quality] || 'standard'
    var url = 'https://api.vsaa.cn/api/music.qishui.vip?' + pQuery({ act: 'song', id: ctx.getId(), quality: q })
    return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
      var d = pJson(r.body)
      var song = (d.data && d.data[0]) || d.data || {}
      if (!song.url) throw new Error('汽水未返回地址')
      if (!song.ekey) return song.url
      return ctx.http('https://proxy.qishui.vsaa.cn/qishui/proxy', {
        method: 'POST',
        headers: { 'User-Agent': P_UA, 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: song.url, key: song.ekey, filename: song.name || 'KMusic', ext: song.codec_type ? String(song.codec_type) : 'aac' })
      }).then(function (pr) {
        var pd = pJson(pr.body)
        if (Number(pd.code) === 200 && pd.url) return pd.url
        throw new Error('汽水代理解密失败')
      })
    })
  }
})

// ==================== 授权类：内置他人 key/卡密，单独分组，只在普通后端之后尝试 ====================

function hywProvider(platform, qualitys) {
  return {
    id: platform + '-hyw', name: 'HYW(' + platform + ')', group: 'auth',
    platforms: [platform], qualitys: qualitys,
    run: function (ctx) {
      var q = { '128k': '128k', '320k': '320k', flac: 'lossless', flac24bit: 'lossless' }[ctx.quality] || '320k'
      var url = 'https://103.79.184.97/api/music/url?' + pQuery({ source: platform, songId: ctx.getId(), quality: q, key: '6C1F-53W0-GRKI-EVFG' })
      return ctx.http(url, { headers: { 'User-Agent': P_UA } }).then(function (r) {
        var u = pPick(pJson(r.body), ['url', 'data.url'])
        if (u) return u
        throw new Error('HYW 无地址')
      })
    }
  }
}
PROVIDERS.push(hywProvider('wy', ['128k', '320k', 'flac']))
PROVIDERS.push(hywProvider('tx', ['128k', '320k', 'flac']))
PROVIDERS.push(hywProvider('kw', ['128k', '320k', 'flac']))
PROVIDERS.push(hywProvider('kg', ['128k', '320k', 'flac']))

// 实网探测后剔除（不可达 / 无地址 / 返回 401）。修正后可从这里移除再启用。
var DROP_UNAVAILABLE = [
  'wy-sayqz', 'tx-sayqz', 'kw-sayqz', // 域名在本机 DNS 无法解析
  'wy-ffapi',                          // ECONNREFUSED
  'wy-oiapi',                          // 持续超时
  'wy-cenguigui', 'wy-lzm',            // 无地址 / 需要密码
  'wy-hyw', 'tx-hyw', 'kw-hyw', 'kg-hyw' // 12s 超时，不可达
]
for (var di = PROVIDERS.length - 1; di >= 0; di--) {
  if (DROP_UNAVAILABLE.indexOf(PROVIDERS[di].id) !== -1) PROVIDERS.splice(di, 1)
}


  var health = {}
  var lastGood = {}
  var cache = new Map()
  var inflight = {}
  var stats = { cacheHits: 0, launched: 0, wins: 0, timeouts: 0, cooldowns: 0, requests: 0, unverified: 0 }
  var httpActive = 0
  var httpQueue = []
  var activeJobs = []

  if (typeof globalThis.window === 'undefined') globalThis.window = globalThis

  // ==================== 网络层 ====================
  function drain() {
    while (httpActive < CONFIG.MAX_HTTP && httpQueue.length) {
      var job = httpQueue.shift()
      if (job.aborted) continue
      startJob(job)
    }
  }
  function startJob(job) {
    var done = false
    httpActive++
    activeJobs.push(job)
    function finish(err, res, body) {
      if (done) return
      done = true
      if (httpActive > 0) httpActive--
      var at = activeJobs.indexOf(job)
      if (at !== -1) activeJobs.splice(at, 1)
      if (!job.aborted && typeof job.cb === 'function') job.cb(err, res, body)
      drain()
    }
    try {
      var handle = realLx.request(job.url, job.options, finish)
      job.handle = (typeof handle === 'function') ? handle : null
      if (job.aborted && job.handle) { try { job.handle() } catch (e) {} }
    } catch (e) { finish(e) }
  }
  function gatedRequest(pid, url, options, cb) {
    var job = { pid: pid, at: Date.now(), url: url, options: options || {}, cb: cb, aborted: false, handle: null }
    httpQueue.push(job)
    drain()
    return function abort() {
      job.aborted = true
      if (job.handle) { try { job.handle() } catch (e) {} }
      job.handle = null
    }
  }
  function abortScope(pidSet, since) {
    var i
    for (i = httpQueue.length - 1; i >= 0; i--) {
      var q = httpQueue[i]
      if (q.pid in pidSet && q.at >= since) httpQueue.splice(i, 1)
    }
    for (i = activeJobs.length - 1; i >= 0; i--) {
      var job = activeJobs[i]
      if (job.pid in pidSet && job.at >= since) {
        job.aborted = true
        if (job.handle) { try { job.handle() } catch (e) {} }
        job.handle = null
        activeJobs.splice(i, 1)
        if (httpActive > 0) httpActive--
      }
    }
    drain()
  }

  // 后端使用的 HTTP：失败时抛出带 HTTP 状态的消息，便于运行时分流
  function providerHttp(pid, url, options) {
    options = options || {}
    if (typeof options.body === 'string' && !options.headers) options.headers = {}
    return new Promise(function (resolve, reject) {
      var timer = null, done = false
      function finish(err, res, body) {
        if (done) return
        done = true
        if (timer) clearTimeout(timer)
        if (err) return reject(err instanceof Error ? err : new Error(String(err)))
        var status = Number((res && res.statusCode) || 0)
        if (status === 429) return reject(new Error('接口限流 429'))
        if (status >= 400) return reject(new Error('HTTP ' + status))
        resolve({ statusCode: status, headers: (res && res.headers) || {}, body: (res && res.body !== undefined) ? res.body : body })
      }
      timer = setTimeout(function () { finish(new Error('后端请求超时')) }, CONFIG.ATTEMPT_TIMEOUT)
      try {
        gatedRequest(pid, url, options, function (err, res, body) { finish(err, res, body) })
      } catch (e) { finish(e) }
    })
  }

  // ==================== 工具 ====================
  function getId(platform, info) {
    info = info || {}
    var v
    if (platform === 'kw') v = info.rid || info.songmid || info.id || info.songId
    else if (platform === 'kg') v = info.hash || info.songmid || info.id
    else if (platform === 'tx') v = info.songmid || info.strMediaMid || info.id
    else if (platform === 'wy') v = info.songmid || info.id || info.songId
    else if (platform === 'mg') v = info.copyrightId || info.songmid || info.id
    else v = info.songmid || info.id
    return (v === undefined || v === null) ? '' : String(v)
  }

  function qualityOf(req) {
    var info = req.info || {}
    return info.type || info.quality || ''
  }
  function durationOf(info) {
    var v = (info && (info.interval || info.duration || info.DURATION)) || 0
    if (typeof v === 'string' && v.indexOf(':') >= 0) {
      var parts = v.split(':'), sec = 0
      for (var i = 0; i < parts.length; i++) sec = sec * 60 + (Number(parts[i]) || 0)
      return sec
    }
    v = Number(v) || 0
    return v > 10000 ? v / 1000 : v
  }
  function isLossless(q) { return /^(flac|flac24bit|hires|master|atmos|atmos_plus)$/.test(q) }
  function header(res, name) {
    var h = (res && res.headers) || {}, keys = Object.keys(h)
    for (var i = 0; i < keys.length; i++) if (keys[i].toLowerCase() === name) return String(h[keys[i]])
    return ''
  }
  function rawRequest(url, options, timeout) {
    return new Promise(function (resolve) {
      var done = false, timer = null
      function finish(err, res) { if (done) return; done = true; if (timer) clearTimeout(timer); resolve({ error: err || null, res: res || null }) }
      timer = setTimeout(function () { finish(new Error('预检超时')) }, timeout)
      try { realLx.request(url, options, function (err, res) { finish(err, res) }) } catch (e) { finish(e) }
    })
  }
  function sizeLimit(info) {
    var d = durationOf(info)
    // 300KB 绝对下限用于挡「7 秒开卡提示音」这类整段替换；已知时长时再按 128kbps 估算
    return Math.max(300 * 1024, d > 0 ? d * 3000 : 0)
  }
  function totalSize(res) {
    var m = /\/\s*(\d+)/.exec(header(res, 'content-range'))
    if (m) return Number(m[1])
    var cl = Number(header(res, 'content-length')) || 0
    if (cl > 0 && (Number(res.statusCode) || 0) === 200) return cl
    return 0
  }
  // 用前 512 字节里的 MP3 帧头估算时长，专门识别“体积过 300KB 的短提示音”
  function mp3Duration(total, body) {
    if (!total || !body || typeof body !== 'string') return 0
    var n = Math.min(body.length, 4096), i = 0
    if (n > 10 && body.charCodeAt(0) === 0x49 && body.charCodeAt(1) === 0x44 && body.charCodeAt(2) === 0x33) {
      i = 10 + ((body.charCodeAt(6) & 0x7f) << 21 | (body.charCodeAt(7) & 0x7f) << 14 | (body.charCodeAt(8) & 0x7f) << 7 | (body.charCodeAt(9) & 0x7f))
    }
    for (; i + 3 < n && i < 2048; i++) {
      if (body.charCodeAt(i) !== 0xFF || (body.charCodeAt(i + 1) & 0xE0) !== 0xE0) continue
      var ver = (body.charCodeAt(i + 1) >> 3) & 3
      var layer = (body.charCodeAt(i + 1) >> 1) & 3
      if (ver === 1 || layer !== 1) continue
      var idx = (body.charCodeAt(i + 2) >> 4) & 0x0F
      var table = ver === 3
        ? [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
        : [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160]
      var kbps = table[idx] || 0
      if (kbps > 0) return total / (kbps * 1000 / 8)
      return 0
    }
    return 0
  }
  function rangeCheck(url, info, timeout) {
    return rawRequest(url, {
      method: 'GET', timeout: timeout, follow_max: 5,
      headers: { 'User-Agent': UA, 'Range': 'bytes=0-511' }
    }, timeout).then(function (r) {
      if (r.error || !r.res) return 'unknown'
      var sc = Number(r.res.statusCode) || 0
      if (sc === 403 || sc === 405 || sc === 0) return 'unknown'
      if (sc >= 400) return false
      var ct = header(r.res, 'content-type').toLowerCase()
      if (/text\/html|application\/json|text\/plain/.test(ct)) return false
      if (ct && !/audio|octet-stream|application\/ogg/.test(ct)) return false
      var total = totalSize(r.res)
      if (total > 0) {
        var secs = mp3Duration(total, r.res.body)
        var expect = Number(info && info.interval) || 0
        if (secs > 0 && secs < 30 && (!expect || secs < expect * 0.5)) return false
        if (total < sizeLimit(info)) return false
      }
      return true
    })
  }
  function headCheck(url, quality, info, timeout) {
    return rawRequest(url, {
      method: 'HEAD', timeout: timeout, follow_max: 5,
      headers: { 'User-Agent': UA }
    }, timeout).then(function (r) {
      if (r.error || !r.res) return true
      var sc = Number(r.res.statusCode) || 0
      if (sc === 403 || sc === 405 || sc === 0) return true
      if (sc >= 400) return false
      var ct = header(r.res, 'content-type').toLowerCase()
      if (/text\/html|application\/json|text\/plain/.test(ct)) return false
      var size = Number(header(r.res, 'content-length')) || 0
      var minimum = sizeLimit(info)
      if (size > 0 && size < minimum) return false
      return true
    })
  }
  function isValid(url, quality, info) {
    var path = String(url).split('?')[0].toLowerCase()
    if (isLossless(quality) && /\.mp3$/.test(path)) return Promise.resolve(false)
    return rangeCheck(url, info, CONFIG.CHECK_TIMEOUT).then(function (verdict) {
      if (verdict !== 'unknown') return verdict
      return headCheck(url, quality, info, CONFIG.CHECK_TIMEOUT)
    })
  }

  // ==================== 注册表 ====================
  function unionQualitys(items) {
    var count = {}, total = items.length
    for (var i = 0; i < items.length; i++) {
      var qs = items[i].qualitys || []
      for (var j = 0; j < qs.length; j++) count[qs[j]] = (count[qs[j]] || 0) + 1
    }
    var out = []
    for (var k = 0; k < QUALITY_ORDER.length; k++) {
      var q = QUALITY_ORDER[k]
      var need = COMMON_QUALITY[q] ? 2 : 3
      if (total === 1) need = 1
      if ((count[q] || 0) >= need) out.push(q)
      delete count[q]
    }
    for (var extra in count) if (total === 1 || count[extra] >= 2) out.push(extra)
    return out.length ? out : ['128k', '320k', 'flac']
  }

  var registry = {}
  ;(function () {
    for (var i = 0; i < PROVIDERS.length; i++) {
      var p = PROVIDERS[i]
      if (!p || !p.platforms) continue
      for (var j = 0; j < p.platforms.length; j++) {
        var pf = p.platforms[j]
        if (!registry[pf]) registry[pf] = []
        registry[pf].push(p)
      }
    }
  })()

  var sources = {}
  for (var platform in registry) {
    sources[platform] = { name: '聚合音源', type: 'music', actions: ['musicUrl'], qualitys: unionQualitys(registry[platform]) }
  }

  realLx.on(EVENT_NAMES.request, handleRequest)
  realLx.send(EVENT_NAMES.inited, { status: true, openDevTools: false, openDevMode: false, sources: sources })

  // ==================== 健康度 ====================
  function healthKey(platform, pid) { return platform + '|' + pid }
  function classify(err) {
    var m = String((err && err.message) || err || '')
    if (/401|403|429|限流|授权|token|license|apikey|卡密/i.test(m)) return 'limited'
    if (/没有|无可用|未找到|无版权|不存在|未配置|缺(少)?(酷狗|歌曲)?\s*(hash|id)|not found|no\s*(song|result|data)|empty|为空/i.test(m)) return 'business'
    if (/链接|音频|非音频|短片段|试听|media|校验/i.test(m)) return 'media'
    return 'network'
  }
  function note(platform, pid, error) {
    var k = healthKey(platform, pid), h = health[k]
    if (!error) { if (h) { h.fails = 0; h.until = 0 } return }
    var kind = classify(error)
    if (kind === 'business') return
    if (!h) h = health[k] = { fails: 0, until: 0, kind: '' }
    h.kind = kind
    if (kind === 'limited') { h.until = Date.now() + CONFIG.COOLDOWN_LIMITED; h.fails = 0; stats.cooldowns++; return }
    h.fails++
    var limit = kind === 'media' ? CONFIG.FAIL_MEDIA : CONFIG.FAIL_NETWORK
    if (h.fails >= limit) {
      h.until = Date.now() + (kind === 'media' ? CONFIG.COOLDOWN_MEDIA : CONFIG.COOLDOWN_NETWORK)
      h.fails = 0
      stats.cooldowns++
    }
  }
  function orderCandidates(platform, all) {
    var now = Date.now(), head = [], normal = [], auth = [], cold = []
    var lg = lastGood[platform]
    for (var i = 0; i < all.length; i++) {
      var it = all[i]
      var h = health[healthKey(platform, it.id)]
      if (h && h.until > now) { cold.push(it); continue }
      if (it.id === lg) head.push(it)
      else if (it.group === 'auth') auth.push(it)
      else normal.push(it)
    }
    cold.sort(function (a, b) {
      return ((health[healthKey(platform, a.id)] || {}).until || 0) - ((health[healthKey(platform, b.id)] || {}).until || 0)
    })
    return head.concat(normal, auth, cold)
  }

  // ==================== 缓存 ====================
  function cacheKey(req) {
    var info = req.info || {}
    var mi = info.musicInfo || {}
    var id = mi.songmid || mi.hash || mi.rid || mi.id || mi.songId || mi.copyrightId || ''
    if (!id) return ''
    return req.source + '|' + qualityOf(req) + '|' + id
  }
  function cacheGet(key, quality, info) {
    var e = cache.get(key)
    if (!e) return null
    var age = Date.now() - e.at
    if (age > CONFIG.CACHE_TTL) { cache.delete(key); return null }
    if (age <= CONFIG.HOT_TTL) return Promise.resolve(e.url)
    return isValid(e.url, quality, info).then(function (ok) {
      if (!ok) { cache.delete(key); return null }
      cache.delete(key); cache.set(key, { url: e.url, at: e.at })
      return e.url
    }, function () { return e.url })
  }
  function cacheSet(key, url) {
    if (!key || !url) return
    cache.delete(key)
    cache.set(key, { url: url, at: Date.now() })
    while (cache.size > CONFIG.CACHE_MAX) cache.delete(cache.keys().next().value)
  }
  function clearAll() {
    cache.clear()
    for (var f in inflight) delete inflight[f]
    for (var h in health) delete health[h]
    for (var g in lastGood) delete lastGood[g]
    for (var s in stats) if (typeof stats[s] === 'number') stats[s] = 0
  }

  // ==================== 调度 ====================
  function makeCtx(platform, provider, quality, info) {
    var utils = realLx.utils || {}
    var crypto = utils.crypto || {}
    var buffer = utils.buffer || {}
    return {
      platform: platform,
      quality: quality,
      info: info || {},
      name: String((info && info.name) || ''),
      singer: String((info && (info.singer || info.artist)) || ''),
      getId: function () { return getId(platform, info) },
      http: function (url, options) { return providerHttp(provider.id, url, options) },
      md5: crypto.md5,
      aesEncrypt: crypto.aesEncrypt,
      randomBytes: crypto.randomBytes,
      rsaEncrypt: crypto.rsaEncrypt,
      bufToString: buffer.bufToString
    }
  }

  function attempt(platform, provider, req, action, quality, budget) {
    return new Promise(function (resolve, reject) {
      var done = false
      var timer = setTimeout(function () { if (!done) { done = true; reject(new Error('后端超时')) } }, budget)
      function ok(v) { if (done) return; done = true; clearTimeout(timer); resolve(v) }
      function bad(e) { if (done) return; done = true; clearTimeout(timer); reject(e) }
      Promise.resolve().then(function () {
        return provider.run(makeCtx(platform, provider, quality, (req.info && req.info.musicInfo) || {}))
      }).then(function (url) {
        if (done) return
        if (typeof url !== 'string' || !/^https?:\/\//i.test(url)) return bad(new Error('后端返回的不是音频地址'))
        if (action !== 'musicUrl') return ok(url)
        isValid(url, quality, (req.info && req.info.musicInfo) || {}).then(function (valid) {
          if (!valid) return bad(new Error('链接校验未通过'))
          ok(url)
        }, function () { ok(url) })
      }, function (e) { bad(e) })
    })
  }

  function runChain(platform, items, req, action, quality) {
    return new Promise(function (resolve, reject) {
      if (!items.length) return reject(new Error('该音质没有可用后端'))
      var deadline = Date.now() + CONFIG.TOTAL_TIMEOUT
      var requestStart = Date.now()
      var launched = 0, active = 0, finished = false
      var failures = [], lastLaunchAt = 0, tick = null
      var pidSet = {}
      for (var i0 = 0; i0 < items.length; i0++) pidSet[items[i0].id] = 1

      function stop() { if (tick) { clearInterval(tick); tick = null } }
      function finishErr(msg) {
        if (finished) return
        finished = true; stop(); abortScope(pidSet, requestStart)
        reject(new Error('聚合音源：' + msg + (failures.length ? '（' + failures.join('；') + '）' : '')))
      }
      function succeed(value) {
        if (finished) return
        finished = true; stop(); abortScope(pidSet, requestStart)
        stats.wins++; resolve(value)
      }
      function launchOne() {
        var item = items[launched++]
        var budget = Math.min(CONFIG.ATTEMPT_TIMEOUT, Math.max(500, deadline - Date.now()))
        active++
        lastLaunchAt = Date.now()
        stats.launched++
        attempt(platform, item, req, action, quality, budget).then(function (v) {
          if (finished) return
          active--
          note(platform, item.id, null)
          lastGood[platform] = item.id
          succeed(v)
        }, function (e) {
          if (finished) return
          active--
          if (e && e.message === '后端超时') stats.timeouts++
          failures.push(item.name + ' ' + ((e && e.message) || e))
          note(platform, item.id, e)
          pump()
        })
      }
      function pump() {
        if (finished) return
        var now = Date.now()
        if (now > deadline) return finishErr('总超时')
        if (launched >= items.length && active === 0) return finishErr('全部后端均失败')
        if (launched >= items.length || active >= CONFIG.MAX_PARALLEL) return
        if (active === 0 || now - lastLaunchAt >= CONFIG.HEDGE_DELAY) launchOne()
      }
      tick = setInterval(pump, 60)
      pump()
    })
  }

  function candidatesFor(platform, quality) {
    var all = registry[platform] || [], out = []
    for (var i = 0; i < all.length; i++) {
      if (all[i].qualitys.indexOf(quality) !== -1 || quality === '') out.push(all[i])
    }
    return orderCandidates(platform, out)
  }

  function runWithDowngrade(platform, req, action) {
    var q = qualityOf(req)
    var steps = 0
    function go(quality) {
      var items = candidatesFor(platform, quality)
      if (!items.length) {
        var nq = DOWNGRADE[quality]
        if (!nq || steps >= CONFIG.MAX_DOWNGRADE) return Promise.reject(new Error('没有支持该音质的后端'))
        steps++
        return go(nq)
      }
      return runChain(platform, items, req, action, quality).then(null, function (err) {
        var nq = DOWNGRADE[quality]
        if (action !== 'musicUrl' || !nq || steps >= CONFIG.MAX_DOWNGRADE) throw err
        steps++
        return go(nq)
      })
    }
    return go(q)
  }

  function handleRequest(req) {
    req = req || {}
    var platform = req.source
    var action = req.action || 'musicUrl'
    if (!registry[platform]) return Promise.reject(new Error('聚合音源：不支持平台 ' + platform))
    stats.requests++
    var quality = qualityOf(req)
    var info = (req.info && req.info.musicInfo) || {}
    var key = (action === 'musicUrl') ? cacheKey(req) : ''
    if (key) {
      var hit = cacheGet(key, quality, info)
      if (hit) {
        stats.cacheHits++
        return hit.then(function (url) { return url || resolveAndStore(key, platform, req, action) })
      }
      if (inflight[key]) return inflight[key]
    }
    return resolveAndStore(key, platform, req, action)
  }

  function resolveAndStore(key, platform, req, action) {
    var task = runWithDowngrade(platform, req, action)
    if (key) {
      inflight[key] = task
      task.then(function (v) {
        if (typeof v === 'string') cacheSet(key, v)
        if (inflight[key] === task) delete inflight[key]
      }, function () { if (inflight[key] === task) delete inflight[key] })
    }
    return task
  }

  if (globalThis.__LX_AGG_TEST__) {
    globalThis.__LX_AGG_TEST_API__ = {
      registry: registry, sources: sources, providers: PROVIDERS, health: health,
      lastGood: lastGood, stats: stats, CONFIG: CONFIG,
      handleRequest: handleRequest, clearCache: clearAll
    }
  }
})()
